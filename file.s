C_MAP           = 0
C_BLOCKS        = 1
C_FIRSTSPR      = 2
C_COMMON        = 2
C_WEAPON        = 3
C_PLAYER        = 4
C_FIRSTPURGEABLE = C_PLAYER

F_SPRITE        = 2
F_MUSIC         = 5
F_LEVEL         = 6
F_SCRIPT        = 7

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
                pha
                lsr
                lsr
                lsr
                lsr
                ldx #$00
                jsr MFN_Sub
                pla
                inx
MFN_Sub:        and #$0f
                ora #$30
                cmp #$3a
                bcc MFN_Number
                adc #$06
MFN_Number:     sta fileName,x
                rts

        ; Allocate & load a chunk-file. If no memory, purge unused files
        ;
        ; Parameters: Y file number, fileName
        ; Returns: C=0 OK C=1 Error
        ; Modifies: A,X,Y,temp6-temp8,loader temp vars (chunk number stored to temp6)

LF_Error:       jmp CloseFile                   ;In case of error, close the
                                                ;file
LoadAllocFile:  sty temp6
                jsr OpenFile
LoadAllocFile_FileOpen:
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
                bcc LF_MemOk
LF_NoMemory:    jsr PurgeOldestFile
                jmp LF_MemLoop
LF_MemOk:       lda freeMemLo                   ;We can load here
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
                adc temp7
                sta freeMemLo
                lda freeMemHi
                sta zpBitsHi
                sta zpDestHi
                sta fileHi,y
                adc temp8
                sta freeMemHi
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
PF_Done:        rts

        ; Purge the chunk-file that has not been accessed for the longest time
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,loader temp vars

PurgeOldestFile:lda #$00
POF_Limit:      sta zpBitBuf
                ldy #$ff
                ldx #C_FIRSTPURGEABLE
POF_Loop:       lda fileHi,x
                beq POF_Skip
                lda fileAge,x
POF_Cmp:        cmp zpBitBuf
                bcc POF_Skip
                sta zpBitBuf
                txa
                tay
POF_Skip:       inx
                cpx #MAX_CHUNKFILES
                bcc POF_Loop
                tya
                bmi PF_Done

        ; Remove a chunk-file from memory
        ;
        ; Parameters: Y file number
        ; Returns: -
        ; Modifies: A,X,loader temp vars

PurgeFile:      sty zpLenLo
                lda #$ff                        ;Invalidate last used spritefile (may have moved in memory)
                sta sprFileNum
                lda #$00                        ;Reset chunk age
                sta fileAge,y
                lda fileLo,y
                sta zpDestLo
                lda fileHi,y                    ;Check that chunk exists
                beq PF_Done
                sta zpDestHi
                lda freeMemLo                   ;Find out size of the erased chunk
                sec
                sbc zpDestLo
                sta zpBitsLo
                lda freeMemHi
                sbc zpDestHi
                sta zpBitsHi
                ldx #MAX_CHUNKFILES-1
PF_FindSizeLoop:cpx zpLenLo
                beq PF_FindSizeSkip
                lda fileHi,x
                beq PF_FindSizeSkip
                lda fileLo,x
                sec
                sbc zpDestLo
                sta zpSrcLo
                lda fileHi,x
                sbc zpDestHi
                sta zpSrcHi
                lda zpSrcLo
                cmp zpBitsLo
                lda zpSrcHi
                sbc zpBitsHi
                bcs PF_FindSizeSkip
PF_FindSizeNewSize:
                lda zpSrcLo
                sta zpBitsLo                    ;zpBitsLo,Hi = size of purged chunk-file
                lda zpSrcHi
                sta zpBitsHi
PF_FindSizeSkip:dex
                bpl PF_FindSizeLoop
                lda zpDestLo                    ;Set source address for memory shift
                clc
                adc zpBitsLo
                sta zpSrcLo
                lda zpDestHi
                adc zpBitsHi
                sta zpSrcHi
                ldy freeMemHi
                iny
                sty zpBitBuf
                ldy #$00
PF_ShiftMemory: lda (zpSrcLo),y
                sta (zpDestLo),y
                iny
                bne PF_ShiftMemory
                inc zpSrcHi
                inc zpDestHi
                lda zpSrcHi                     ;Note: we may copy extra (up to 256 bytes)
                cmp zpBitBuf                    ;but it should do no harm
                bcc PF_ShiftMemory
PF_CopyDone:    ldx #freeMemLo                  ;Shift top of memory pointer
                ldy #zpBitsLo
                jsr Sub16
                ldx #zpBitsLo                   ;zpBitsLo,Hi = negative size of file
                jsr Negate16
                ldy #MAX_CHUNKFILES-1
PF_RelocLoop:   cpy zpLenLo                     ;Do not relocate itself
                beq PF_RelocNext
                ldx zpLenLo
                lda fileHi,y                    ;Need relocation?
                cmp fileHi,x
                bcc PF_RelocNext
                bne PF_RelocOk
                lda fileLo,y
                cmp fileLo,x
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
                rts
