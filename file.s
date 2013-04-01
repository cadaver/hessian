C_MAP           = 0
C_BLOCKS        = 1
C_FIRSTSPR      = 2
C_COMMON        = 2
C_ITEM          = 3
C_WEAPON        = 4
C_PLAYER        = 5
C_FIRSTPURGEABLE = C_PLAYER

F_LOGO          = $03
F_SPRITE        = $04
F_MUSIC         = $08
F_SCRIPT        = $09
F_LEVEL         = $0a
F_OPTIONS       = $70
F_SAVE          = $71

MAX_CHUNKFILES   = 32

        ; Create a number-based file name
        ;
        ; Parameters: A file number, X file number add
        ; Returns: fileName
        ; Modifies: A,X,zpSrcLo

MakeFileName:   stx zpSrcLo
                clc
                adc zpSrcLo
MakeFileName_Direct:
                sta fileNumber
                rts

        ; Load a file while handling retry. PostLoad is called automatically after to reinit map/block-
        ; tables
        ;
        ; Parameters: A,X load address, filename
        ; Returns: fileName
        ; Modifies: A,X,Y,loader temp vars

LFR_Error:      jsr LFR_ErrorPrompt
LFR_AddressLo:  lda #$00
LFR_AddressHi:  ldx #$00
LoadFileRetry:  sta LFR_AddressLo+1
                stx LFR_AddressHi+1
                jsr LoadFile
                bcs LFR_Error
                jmp PostLoad

LFR_ErrorPrompt:
                if USE_FLIPDISK_PROMPT > 0
                cmp #$02
                beq LFR_FlipDisk
LFR_DiskError:  lda #<txtDiskError
                ldx #>txtDiskError
                bne LFR_MessageCommon
LFR_FlipDisk:   lda #<txtFlipDisk
                ldx #>txtFlipDisk
                else
                lda #<txtDiskError
                ldx #>txtDiskError
                endif
LFR_MessageCommon:
                ldy #INDEFINITE_TEXT_DURATION
                jsr PrintPanelText
LFR_WaitFire:   jsr GetControls
                jsr GetFireClick
                bcc LFR_WaitFire
                jmp ClearPanelText

LF_NoMemory:    lda #$00                        ;No memory, purge the oldest chunkfile
                sta zpBitBuf
                ldx #C_FIRSTPURGEABLE
LF_PurgeLoop:   ldy fileHi,x
                beq LF_PurgeSkip
                ldy fileAge,x
                cpy zpBitBuf
                bcc LF_PurgeSkip
                sty zpBitBuf
                txa
LF_PurgeSkip:   inx
                cpx #MAX_CHUNKFILES
                bcc LF_PurgeLoop
                tay
                jsr PurgeFile
                jmp LF_MemLoop

        ; Allocate & load a chunk-file. If no memory, purge unused files
        ;
        ; Parameters: Y file number, fileName
        ; Returns: C=0 OK C=1 Error
        ; Modifies: A,X,Y,temp6-temp8,loader temp vars (chunk number stored to temp6)

LoadAllocFile:  sty temp6
                jsr OpenFile
                ldy temp6                       ;Purge if in memory
                jsr PurgeFile
                jsr GetByte                     ;Get datasize lowbyte, or abort due to error
                bcs LF_Error
                sta temp7
                jsr GetByte                     ;Get datasize highbyte
                sta temp8
                jsr GetByte                     ;Get object count
                sta fileNumObjects,y
LF_MemLoop:     ldy temp6
                lda temp7
                clc
                adc freeMemLo
                lda temp8                       ;Check for enough memory
                adc freeMemHi
                cmp #>fileAreaEnd
                bcs LF_NoMemory
LF_HasMemory:   lda freeMemLo                   ;We can load here
                ldx freeMemHi
                jsr LoadFile
                bcs LF_Error                    ;Error in loading?

        ; Increase the age of loaded chunk-files (performed after each chunk-file load)

AgeFiles:       ldx #MAX_CHUNKFILES-1
                lda #$ff
AF_Loop:        ldy fileHi,x
                beq AF_Skip
                inc fileAge,x
                bne AF_Skip
                sta fileAge,x
AF_Skip:        dex
                bpl AF_Loop

        ; Finish loading, relocate chunk object pointers

                ldy temp6
                lda freeMemLo                   ;Increment free mem pointer
                sta zpBitsLo
                sta zpDestLo
                sta fileLo,y
                adc temp7                       ;C=0 here
                sta freeMemLo
                lda freeMemHi
                sta zpBitsHi
                sta zpDestHi
                sta fileHi,y
                adc temp8
                sta freeMemHi
                if SHOW_FREE_MEMORY > 0
                jsr PrintFreeMem
                endif
                ldx fileNumObjects,y
LF_Relocate2:   txa
                beq LF_RelocDone
                ldy #$00
LF_Relocate:    lda (zpDestLo),y                ;Relocate object pointers
                clc
                adc zpBitsLo
                sta (zpDestLo),y
                iny
                lda (zpDestLo),y
                adc zpBitsHi
                sta (zpDestLo),y
                iny
                dex
                bne LF_Relocate
LF_RelocDone:
LSpr_Done:      clc                             ;OK!
LF_Error:
PF_Done:        rts

                if SHOW_FREE_MEMORY > 0
PrintFreeMem:   ldx #0
                lda #<fileAreaEnd
                sec
                sbc freeMemLo
                pha
                lda #>fileAreaEnd
                sbc freeMemHi
                jsr PrintHexByte
                pla
PrintHexByte:   pha
                lsr
                lsr
                lsr
                lsr
                jsr PrintHexDigit
                pla
                and #$0f
PrintHexDigit:  cmp #$0a
                bcc PrintHexDigit_IsNumber
                adc #$06
PrintHexDigit_IsNumber:
                adc #$30
                sta screen1+SCROLLROWS*40,x
                lda #$01
                sta colors+SCROLLROWS*40,x
                inx
                rts
                endif

        ; Remove a chunk-file from memory
        ;
        ; Parameters: Y file number
        ; Returns: -
        ; Modifies: A,X,loader temp vars

PurgeFile:      sty zpLenLo
                lda fileHi,y                    ;Check that chunk exists
                beq PF_Done
                sta zpDestHi
                lda fileLo,y
                sta zpDestLo
                lda #$ff                        ;Invalidate last used spritefile (may have moved in memory)
                sta sprFileNum
                lda freeMemLo
                sta zpSrcLo
                lda freeMemHi
                sta zpSrcHi
                ldx #MAX_CHUNKFILES-1
PF_FindSizeLoop:cpx zpLenLo
                beq PF_FindSizeSkip
                ldy fileLo,x
                cpy zpDestLo
                lda fileHi,x
                sbc zpDestHi
                bcc PF_FindSizeSkip
                cpy zpSrcLo
                lda fileHi,x
                sbc zpSrcHi
                bcs PF_FindSizeSkip
                sty zpSrcLo
                lda fileHi,x
                sta zpSrcHi
PF_FindSizeSkip:dex
                bpl PF_FindSizeLoop
                lda freeMemLo                   ;How much memory to shift
                sec
                sbc zpSrcLo
                sta zpBitsLo
                lda freeMemHi
                sbc zpSrcHi
                sta zpBitsHi
                jsr CopyMemory_PointersSet
                lda zpDestLo
                sbc zpSrcLo
                sta zpBitsLo
                lda zpDestHi
                sbc zpSrcHi
                sta zpBitsHi                    ;Negative delta to filepointers
                ldx #<freeMemLo
                ldy #<zpBitsLo
                jsr Add16                       ;Shift the free memory pointer
                if SHOW_FREE_MEMORY > 0
                jsr PrintFreeMem
                endif
                ldy #MAX_CHUNKFILES-1
PF_RelocLoop:   cpy zpLenLo                     ;Do not relocate itself
                beq PF_RelocNext
                ldx zpLenLo
                lda fileLo,y                    ;Need relocation? (higher in memory than purged file)
                cmp fileLo,x
                lda fileHi,y
                sbc fileHi,x
                bcc PF_RelocNext
PF_RelocOk:     lda fileLo,y                    ;Relocate the file pointer
                clc
                adc zpBitsLo
                sta fileLo,y
                sta zpDestLo
                lda fileHi,y
                adc zpBitsHi
                sta fileHi,y
                sta zpDestHi
                ldx fileNumObjects,y            ;Number of objects
                sty zpBitBuf
                jsr LF_Relocate2                ;Relocate the object pointers
                ldy zpBitBuf
PF_RelocNext:   dey
                bpl PF_RelocLoop
                ldy zpLenLo
                lda #$00
                sta fileHi,y                    ;Mark chunk not in memory
                sta fileAge,y                   ;and reset age for eventual reload
                rts

SaveState_CopyMemory:
                ldy #<(playerStateEnd-playerStateStart)
                sty zpBitsLo
                ldy #>(playerStateEnd-playerStateStart)
                sty zpBitsHi

        ; Copy a block of memory
        ;
        ; Parameters: A,X: destination, zpSrcLo,Hi source zpBitsLo,Hi amount of bytes
        ; Returns: -
        ; Modifies: A,X,Y,loader temp vars

CopyMemory:     sta zpDestLo
                stx zpDestHi
CopyMemory_PointersSet:
                ldy #$00
                ldx zpBitsLo                    ;Predecrement highbyte if lowbyte 0 at start
                beq CM_Predecrement
CM_Loop:        lda (zpSrcLo),y
                sta (zpDestLo),y
                iny
                bne CM_NotOver
                inc zpSrcHi
                inc zpDestHi
CM_NotOver:     dex
                bne CM_Loop
CM_Predecrement:dec zpBitsHi
                bpl CM_Loop
                rts