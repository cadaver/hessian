        ; Loader part

                include memory.s
                include kernal.s
                include ldepacksym.s

MW_LENGTH       = 32            ;Bytes in one M-W command

LOAD_KERNAL     = $00           ;Load using Kernal and do not allow interrupts
LOAD_FAKEFAST   = $01           ;Load using Kernal, interrupts allowed
LOAD_FAST       = $80           ;(or any other negative value) Load using custom serial protocol, Kernal not used at all after startup

tablBi          = depackBuffer
tablLo          = depackBuffer + 52
tablHi          = depackBuffer + 104

drvFileTrk      = $0300
drvFileSct      = $0380
drvBuf          = $0400         ;Sector data buffer
drvStart        = $0500
drvSendTblHigh  = $0700
InitializeDrive = $d005         ;1541 only

                org loaderCodeStart

        ; Loading initialization related subroutines, also used by mainpart

WaitBottom:     lda $d011                       ;Wait until bottom of screen
                bmi WaitBottom
WB_Loop2:       lda $d011
                bpl WB_Loop2
                rts

SilenceSID:     ldx #$00                        ;Mute SID by setting frequencies to zero
                txa
                jsr SS_Sub
                inx
SS_Sub:         sta $d400,x
                sta $d407,x
                sta $d40e,x
                rts

        ; IRQ redirector when Kernal is on

RedirectIrq:    ldx $01
                lda #$35                        ;Note: this will necessarily have overhead,
                sta $01                         ;which means that the sensitive IRQs like
                lda #>RI_Return                 ;the panel-split should take extra advance
                pha
                lda #<RI_Return
                pha
                php
                jmp ($fffe)
RI_Return:      stx $01
                jmp $ea81

        ; NMI routine

NMI:            rti

        ; Loader runtime data

fileNumber:     dc.b $01                        ;Initial filenumber for the concatenated intro + main part
fastLoadMode:   dc.b LOAD_KERNAL

                org loaderCodeEnd

        ; Loader initialization
        ; Assumption: $01 has value $35, interrupts are off

InitLoader:     inc $01                         ;Kernal back on (the initial GetByte routine switches it off)
                lda #$02
                jsr Close                       ;Close the file loaded from
                lda #$0b
                sta $d011                       ;Blank screen
                ldx #ilFastLoadEnd-ilFastLoadStart
IL_CopyFastLoad:lda ilFastLoadStart-1,x         ;Copy fastload file routines
                sta OpenFile-1,x
                dex
                bne IL_CopyFastLoad
                stx $d07f                       ;Disable SCPU hardware regs
                stx $d07a                       ;SCPU to slow mode
                stx $d030                       ;C128 back to 1MHz mode
                stx messages                    ;Disable KERNAL messages
                stx fileOpen                    ;Clear fileopen indicator
                stx ntscFlag
IL_DetectNtsc1: lda $d012                       ;Detect PAL/NTSC
IL_DetectNtsc2: cmp $d012
                beq IL_DetectNtsc2
                bmi IL_DetectNtsc1
                cmp #$20
                bcs IL_IsPal
                lda #$f0                        ;Adjust 2-bit transfer delay for NTSC
                sta ilFastLoadStart+FL_Delay-OpenFile
                sta ntscFlag
IL_IsPal:       lda #$7f                        ;Disable & acknowledge IRQ sources
                sta $dc0d
                lda $dc0d
                inc $d019
                lda #<NMI                       ;Set NMI vector
                sta $0318
                sta $fffa
                sta $fffe
                lda #>NMI
                sta $0319
                sta $fffb
                sta $ffff
                lda #<RedirectIrq               ;Setup the IRQ redirector for Kernal on mode
                sta $0314
                lda #>RedirectIrq
                sta $0315
                lda #$81                        ;Run Timer A once to disable NMI from Restore keypress
                sta $dd0d                       ;Timer A interrupt source
                lda #$01                        ;Timer A count ($0001)
                sta $dd04
                stx $dd05
                lda #%00011001                  ;Run Timer A in one-shot mode
                sta $dd0e
IL_CheckSafeMode:
                lda $dc00                       ;Check for safe mode loader
                and $dc01
                and #$10
                bne IL_DetectDrive
IL_SafeMode:    lda #$06
                sta $d020
                bne IL_NoFastLoad

IL_NoSerial:    inc fastLoadMode                ;Serial bus not used: switch to "fake" IRQ-loading mode
IL_NoFastLoad:  lda #<(ilSlowLoadStart-1)
                sta IL_CopyLoaderCode+1
                lda #>(ilSlowLoadStart-1)
                sta IL_CopyLoaderCode+2
                jmp IL_Done

IL_DetectDrive: lda #$aa
                sta $a5
UploadDriveCode:ldy #$00                        ;Init selfmodifying addresses
                beq UDC_NextPacket
UDC_SendMW:     lda ilMWString,x                ;Send M-W command (backwards)
                jsr CIOut
                dex
                bpl UDC_SendMW
                ldx #MW_LENGTH
UDC_SendData:   lda ilDriveCode,y              ;Send one byte of drive code
                jsr CIOut
                iny
                bne UDC_NotOver
                inc UDC_SendData+2
UDC_NotOver:    inc ilMWString+2               ;Also, move the M-W pointer forward
                bne UDC_NotOver2
                inc ilMWString+1
UDC_NotOver2:   dex
                bne UDC_SendData
                jsr UnLsn                       ;Unlisten to perform the command
UDC_NextPacket: lda fa                          ;Set drive to listen
                jsr Listen
                lda status                      ;Quit if error (IDE64?)
                bmi IL_NoSerial
                lda #$6f
                jsr Second
                ldx #$05
                dec ilNumPackets                ;All "packets" sent?
                bpl UDC_SendMW
UDC_SendME:     lda ilMEString-1,x              ;Send M-E command (backwards)
                jsr CIOut
                dex
                bne UDC_SendME
                jsr UnLsn
IL_WaitDataLow: lda status                      ;If error, it's probably IDE64
                bmi IL_NoSerial
                bit $dd00                       ;Wait for drivecode to signal activation with DATA=low
                bpl IL_FastLoadOK               ;If not detected within time window, use slow loading
                dex
                bne IL_WaitDataLow
                lda $a3                         ;If $00 in serial EOI byte, possibly JiffyDos protocol + SD2IEC with no fastload support
                beq IL_NoFastLoad
                lda $a5                         ;If serial delay was unchanged, VICE's true drive emu
                cmp #$aa
                beq IL_NoSerial
                bne IL_NoFastLoad

IL_FastLoadOK:  dec fastLoadMode
IL_Done:        ldx #loaderCodeStart-OpenFile
IL_CopyLoaderCode:
                lda ilFastLoadStart-1,x         ;Copy either fastload or slowload IO code
                sta OpenFile-1,x
                dex
                bne IL_CopyLoaderCode
                stx $dd00                       ;Always use videobank 0
                lda #$35                        ;Loader needs Kernal off to use the buffers
                sta $01                         ;under ROM
                lda #<introStart                ;Load the intro
                ldx #>introStart
                jsr LoadFile
                jmp introCodeStart

        ; Slow fileopen / getbyte / save routines

ilSlowLoadStart:

                rorg OpenFile

                jmp SlowOpen
                jmp SlowSave

SlowGetByte:    lda fileOpen
                beq SGB_Closed
                lda #$36
                sta $01
                jsr ChrIn
                pha
                lda status
                bne SGB_EOF
                dec $01
SGB_LastByte:   pla
                clc
SO_Done:        rts
SGB_EOF:        pha
                tya
                pha
                jsr CloseKernalFile
                pla
                tay
                pla
                and #$83
                sta SGB_Closed+1
                beq SGB_LastByte
                pla
SGB_Closed:     lda #$00
                sec
                rts

SlowOpen:       lda fileOpen
                bne SO_Done
                jsr PrepareKernalIO
                jsr SetFileName
                ldy #$00                        ;A is $02 here
                jsr SetLFSOpen
                jsr ChkIn
                jmp KernalOff                   ;Kernal off after opening

SlowSave:       sta zpSrcLo
                stx zpSrcHi
                jsr PrepareKernalIO
                lda #$05
                ldx #<scratch
                ldy #>scratch
                jsr SetNam
                lda #$0f
                tay
                jsr SetLFSOpen
                lda #$0f
                jsr Close
                jsr SetFileName
                ldy #$01                        ;Open for write
                jsr SetLFSOpen
                jsr ChkOut
                ldy #$00
                lda zpBitsLo
                beq SS_PreDecrement
SS_Loop:        lda (zpSrcLo),y
                jsr ChrOut
                iny
                bne SS_NotOver
                inc zpSrcHi
SS_NotOver:     dec zpBitsLo
                bne SS_Loop
SS_PreDecrement:dec zpBitsHi
                bpl SS_Loop

CloseKernalFile:lda #$02
                jsr Close
                dec fileOpen
KernalOff:      dec $01
                rts

PrepareKernalIO:inc fileOpen                    ;Set fileopen indicator, raster delays are to be expected
                lda fileNumber                  ;Convert filename
                pha
                and #$0f
                ldx #$01
                jsr CFN_Sub
                pla
                lsr
                lsr
                lsr
                lsr
                dex
                jsr CFN_Sub
SL_StopIrqJsr:  jsr StopIrqDummy
KernalOnFast:   lda #$36
                sta $01
StopIrqDummy:   rts

SetFileName:    lda #$02
                ldx #<fileName
                ldy #>fileName
                jmp SetNam

SetLFSOpen:     ldx fa
                jsr SetLFS
                jsr Open
                ldx #$02
                rts

CFN_Sub:        ora #$30
                cmp #$3a
                bcc CFN_Number
                adc #$06
CFN_Number:     sta fileName,x
                rts

scratch:        dc.b "S0:"
fileName:       dc.b "  "

SlowLoadEnd:

                rend

ilSlowLoadEnd:

        ; Fast fileopen / getbyte / save routines

ilFastLoadStart:

                rorg OpenFile

        ; Open file
        ;
        ; Parameters: fileNumber
        ; Returns: -
        ; Modifies: A,X,Y

                jmp FastOpen

        ; Save file
        ;
        ; Parameters: A,X startaddress, zpBitsLo amount of bytes, fileNumber
        ; Returns: -
        ; Modifies: A,X,Y

                jmp FastSave

        ; Read a byte from an opened file
        ;
        ; Parameters: -
        ; Returns: if C=0, byte in A. If C=1, EOF/errorcode in A:
        ; $00 - EOF (no error)
        ; $02 - File not found
        ; $80 - Device not present
        ; Modifies: A,X

GetByte:        ldx #$00
                lda loadBuffer,x
GB_EndCmp:      cpx #$00
                bcs FL_FillBuffer
                inc GetByte+1
FO_Done:
GB_FileEnd:     rts

FastOpen:       lda fileOpen                    ;A file already open? If so, do nothing
                bne FO_Done                     ;(allows chaining of files)
                inc fileOpen
                jsr FL_SendCmdAndFileName       ;Command 0 = load
FL_FillBuffer:  ldx fileOpen                    ;If file closed, errorcode in A & C=1
                beq GB_FileEnd
                dex                             ;X=0
                pha                             ;Preserve A (the byte that was read if called from GetByte)
FL_FillBufferWait:
                bit $dd00                       ;Wait for 1541 to signal data ready by setting DATA high
                bpl FL_FillBufferWait
FL_FillBufferLoop:
FL_SpriteWait:  lda $d012                       ;Check for sprite Y-coordinate range
FL_MaxSprY:     cmp #$00                        ;(max & min values are filled in the
                bcs FL_NoSprites                ;raster interrupt)
FL_MinSprY:     cmp #$00
                bcs FL_SpriteWait
FL_NoSprites:   sei
FL_WaitBadLine: lda $d011
                clc
                sbc $d012
                and #$07
                beq FL_WaitBadLine
                lda #$10
                nop
                sta $dd00                       ;Set CLK low
                lda #$00
                nop
                sta $dd00                       ;Set CLK high
FL_Delay:       bne FL_ReceiveByte              ;2 cycles on PAL, 3 on NTSC
FL_ReceiveByte: lda $dd00
                lsr
                lsr
                eor $dd00
                lsr
                lsr
                eor $dd00
                lsr
                lsr                             ;C=0 for looping again & return (no EOF or error)
                eor $dd00
                cli
FL_Sta:         sta loadBuffer,x
                inx
FL_NextByte:    bne FL_FillBufferLoop
                dex                             ;X=$ff (end cmp for full buffer)
                lda loadBuffer
                bne FL_FullBuffer
                ldx loadBuffer+1                ;File ended if T&S both zeroes
                bne FL_PartialBuffer
                dec fileOpen
                ldx #$02
FL_PartialBuffer:
FL_FullBuffer:  stx GB_EndCmp+1
                ldx #$02
                stx GetByte+1                   ;Set buffer read position
                pla                             ;Restore A
                rts

FL_SendCmdAndFileName:
                ora fileNumber
FL_SendByte:    sta loadTempReg
                ldx #$08                        ;Bit counter
FL_SendLoop:    bit $dd00                       ;Wait for both DATA & CLK to go high
                bpl FL_SendLoop
                bvc FL_SendLoop
                lsr loadTempReg                 ;Send one bit
                lda #$10
                bcc FL_ZeroBit
                eor #$30
FL_ZeroBit:     sta $dd00
                lda #$c0                        ;Wait for CLK & DATA low (diskdrive answers)
FL_SendAck:     bit $dd00
                bne FL_SendAck
                lda #$00                        ;CLK & DATA both high after sending 1 bit
                sta $dd00
                dex
                bne FL_SendLoop
                rts

FastSave:       sta zpSrcLo
                stx zpSrcHi
                lda #$80                        ;Command $80 = save
                jsr FL_SendCmdAndFileName
                lda zpBitsLo
                jsr FL_SendByte
                lda zpBitsHi
                jsr FL_SendByte
                ldy #$00
                lda zpBitsLo
                beq FS_PreDecrement
FS_Loop:        lda (zpSrcLo),y
                jsr FL_SendByte
                iny
                bne FS_NotOver
                inc zpSrcHi
FS_NotOver:     dec zpBitsLo
                bne FS_Loop
FS_PreDecrement:dec zpBitsHi
                bpl FS_Loop
                rts

FastLoadEnd:

                rend

ilFastLoadEnd:


                if ilFastLoadEnd - ilFastLoadStart > $ff
                err
                endif

                if ilSlowLoadEnd - ilSlowLoadStart > $ff
                err
                endif

                if FastLoadEnd > loaderCodeStart
                err
                endif

                if SlowLoadEnd > loaderCodeStart
                err
                endif

        ; Diskdrive code + upload commands

ilMWString:     dc.b MW_LENGTH,>drvStart, <drvStart,"W-M"
ilMEString:     dc.b >DrvDetect,<DrvDetect, "E-M"
ilNumPackets:   dc.b (ilDriveCodeEnd-ilDriveCode+MW_LENGTH-1)/MW_LENGTH

ilDriveCode:
                rorg drvStart

DrvMain:
DrvLoop:        cli                             ;Allow interrupts so that motor stops
                jsr DrvGetByte                  ;Get command + filenumber
                bpl DrvLoad
                jmp DrvSave
DrvLoad:        tay
                lda drvFileSct,y
                ldx drvFileTrk,y
                bne DrvFound
DrvFileNotFound:ldx #$02                        ;Return code $02 = File not found
DrvEndMark:     stx drvBuf+2                    ;Send endmark, return code in X
                lda #$00
                sta drvBuf
                sta drvBuf+1
                beq DrvSendBlk

DrvFound:
DrvSectorLoop:  jsr DrvReadSector               ;Read the data sector
DrvSendBlk:
Drv2MHzSend:    lda drvBuf
                ldx #$00                        ;Set DATA=high to mark data available
Drv2MHzSerialAcc1:
                stx $1800
                tay
                and #$0f
                tax
                lda #$04                        ;Wait for CLK=low
Drv2MHzSerialAcc2:
                bit $1800
                beq Drv2MHzSerialAcc2
                lda drvSendTbl,x
                nop
                nop
Drv2MHzSerialAcc3:
                sta $1800
                asl
                and #$0f
                cmp ($00,x)
                nop
Drv2MHzSerialAcc4:
                sta $1800
                lda drvSendTblHigh,y
                cmp ($00,x)
                nop
Drv2MHzSerialAcc5:
                sta $1800
                asl
                and #$0f
                cmp ($00,x)
                nop
Drv2MHzSerialAcc6:
                sta $1800
                inc Drv2MHzSend+1
                bne Drv2MHzSend
DrvSendDone:    jsr DrvNoData
                lda drvBuf+1                    ;Follow the T/S chain
                ldx drvBuf
                bne DrvSectorLoop
                tay                             ;If 2 first bytes are both 0,
                bne DrvEndMark                  ;endmark has been sent and can
                jmp DrvLoop                     ;return to main loop

DrvGetSaveByte:
DrvSaveCountLo: lda #$00
                tay
DrvSaveCountHi: ora #$00
                beq DrvNoMoreBytes
                dec DrvSaveCountLo+1
                tya
                bne DrvGetByte
                dec DrvSaveCountHi+1

DrvGetByte:     ldy #$08                        ;Bit counter
DrvGetBitLoop:  lda #$00
DrvSerialAcc7:  sta $1800                       ;Set CLK & DATA high for next bit
DrvSerialAcc8:  lda $1800
                bmi DrvQuit                     ;Quit if ATN is low
                and #$05                        ;Wait for CLK or DATA going low
                beq DrvSerialAcc8
                sei                             ;Disable interrupts after 1st bit to make sure "no data" signal will be on time
                lsr                             ;Read the data bit
                lda #$02
                bcc DrvGetZero
                lda #$08
DrvGetZero:     ror drvReceiveBuf               ;Store the data bit
DrvSerialAcc9:  sta $1800                       ;And acknowledge by pulling the other line low
DrvSerialAcc10: lda $1800                       ;Wait for either line going high
                and #$05
                cmp #$05
                beq DrvSerialAcc10
                dey
                bne DrvGetBitLoop
DrvNoData:      lda #$02                        ;DATA low - no sector data to be transmitted yet
DrvSerialAcc11: sta $1800                       ;or C64 cannot yet transmit next byte
                lda drvReceiveBuf
DrvFindFileOK:  clc
                rts
DrvFindFileError:
DrvNoMoreBytes: sec
                rts

DrvQuit:        pla
                pla
DrvExitJump:    lda #$1a                        ;Restore data direction when exiting
                sta $1802
                jmp InitializeDrive             ;1541 = exit through Initialize, others = exit through RTS

                if DrvSerialAcc11 - DrvMain > $ff
                    err
                endif

DrvDecodeLetter:sec
                sbc #$30
                cmp #$10
                bcc DrvDecodeLetterDone
                sbc #$07
DrvDecodeLetterDone:
                rts

DrvSave:        and #$7f                        ;Extract filenumber
                pha
                jsr DrvGetByte                  ;Get amount of bytes to expect
                sta DrvSaveCountLo+1
                jsr DrvGetByte
                sta DrvSaveCountHi+1
                pla
                tay
                ldx drvFileTrk,y
                bne DrvSaveFound                ;If file not found, just receive the bytes
                beq DrvSaveFinish
DrvSaveFound:   lda drvFileSct,y
DrvSaveSectorLoop:
                jsr DrvReadSector               ;First read the sector for T/S chain
                ldx #$02
DrvSaveByteLoop:jsr DrvGetSaveByte              ;Then get bytes from C64 and write
                bcs DrvSaveSector               ;If last byte, save the last sector
                sta drvBuf,x
                inx
                bne DrvSaveByteLoop
DrvSaveSector:  lda #$90
                jsr DrvDoJob
                lda drvBuf+1                    ;Follow the T/S chain
                ldx drvBuf
                bne DrvSaveSectorLoop
DrvSaveFinish:  jsr DrvGetSaveByte              ;Make sure all bytes are received
                bcc DrvSaveFinish
DrvFlush:       lda #$a2                        ;Flush buffers (1581 and CMD drives)
DrvFlushJsr:    jsr DrvDoJob
                jmp DrvLoop

DrvReadSector:
DrvReadTrk:     stx $1000
DrvReadSct:     sta $1000
                lda #$80
DrvDoJob:       sta DrvRetry+1
                jsr DrvLed
DrvRetry:       lda #$80
                ldx #$01
DrvExecJsr:     jsr Drv1541Exec                 ;Exec buffer 1 job
                cmp #$02                        ;Error?
                bcs DrvRetry                    ;Retry indefinitely until success
DrvSuccess:     sei                             ;Make sure interrupts now disabled
DrvLed:         lda #$08
DrvLedAcc0:     eor $1c00
DrvLedAcc1:     sta $1c00
                rts

Drv1541Exec:    sta $01                         ;Set command for execution
                cli                             ;Allow interrupts to execute command
Drv1541ExecWait:
                lda $01                         ;Wait until command finishes
                bmi Drv1541ExecWait
                rts

DrvFdExec:      jsr $ff54                       ;FD2000 fix By Ninja
                lda $03
                rts

drvSendTbl:     dc.b $0f,$07,$0d,$05
                dc.b $0b,$03,$09,$01
                dc.b $0e,$06,$0c,$04
                dc.b $0a,$02,$08,$00

drv1541DirSct  = drvSendTbl+7                   ;Byte $01
drv1581DirSct  = drvSendTbl+5                   ;Byte $03

drv1541DirTrk:  dc.b 18

drvReceiveBuf:

drvRuntimeEnd:
                if DrvDetect > drvSendTblHigh
                    err
                endif

DrvBuildSendTbl:txa                             ;Build high nybble send table
                lsr                             ;May overwrite init drivecode
                lsr
                lsr
                lsr
                tay
                lda drvSendTbl,y
                sta drvSendTblHigh,x
                inx
                bne DrvBuildSendTbl
                rts

DrvDetect:      sei
                ldy #$01
DrvIdLda:       lda $fea0                       ;Recognize drive family
                ldx #$03                        ;(from Dreamload)
DrvIdLoop:      cmp drvFamily-1,x
                beq DrvFFound
                dex                             ;If unrecognized, assume 1541
                bne DrvIdLoop
                beq DrvIdFound
DrvFFound:      lda #<(drvIdByte-1)
                sta DrvIdLoop+1
                lda drvIdLocLo-1,x
                sta DrvIdLda+1
                lda drvIdLocHi-1,x
                sta DrvIdLda+2
                dey
                bpl DrvIdLda
DrvIdFound:     lda drvJobTrkLo,x                ;Patch job track/sector
                sta DrvReadTrk+1
                clc
                adc #$01
                sta DrvReadSct+1
                lda drvJobTrkHi,x
                sta DrvReadTrk+2
                adc #$00
                sta DrvReadSct+2
                txa
                bne DrvNot1541
                lda #$2c                        ;On 1541, patch out the flush ($a2) job call
                sta DrvFlushJsr
                lda #$7a                        ;Set data direction so that can compare against $1800 being zero
                sta $1802
                ldy #Drv1MHzSendEnd-Drv1MHzSend ;And finally copy 1MHz transfer code
Drv1MHzCopy:    lda Drv1MHzSend,y
                sta Drv2MHzSend,y
                dey
                bpl Drv1MHzCopy
                bmi DrvDetectDone
DrvNot1541:     lda drvDirTrkLo-1,x             ;Patch directory track/sector
                sta DrvDirTrk+1
                lda drvDirTrkHi-1,x
                sta DrvDirTrk+2
                lda drvDirSctLo-1,x
                sta DrvDirSct+1
                lda drvDirSctHi-1,x
                sta DrvDirSct+2
                lda drvExecLo-1,x               ;Patch job exec address
                sta DrvExecJsr+1
                lda drvExecHi-1,x
                sta DrvExecJsr+2
                lda drvLedBit-1,x               ;Patch drive led accesses
                sta DrvLed+1
                lda drvLedAdrHi-1,x
                sta DrvLedAcc0+2
                sta DrvLedAcc1+2
                lda #$60                        ;Patch exit jump as RTS
                sta DrvExitJump
                lda drv1800Lo-1,x               ;Patch $1800 accesses
                sta DrvPatch1800Lo+1
                lda drv1800Hi-1,x
                sta DrvPatch1800Hi+1
                ldy #10
DrvPatch1800Loop:
                ldx drv1800Ofs,y
DrvPatch1800Lo: lda #$00
                sta DrvMain+1,x
DrvPatch1800Hi: lda #$00
                sta DrvMain+2,x
                dey
                bpl DrvPatch1800Loop
DrvDetectDone:  jsr DrvNoData                   ;DATA low while building the decodetable / caching directory to signal C64
DrvDirTrk:      ldx drv1541DirTrk
DrvDirSct:      lda drv1541DirSct               ;Read disk directory
DrvDirLoop:     jsr DrvReadSector               ;Read sector
                ldy #$02
DrvNextFile:    lda drvBuf,y                    ;File type must be PRG
                and #$83
                cmp #$82
                bne DrvSkipFile
                lda drvBuf+5,y                  ;Must be two-letter filename
                cmp #$a0
                bne DrvSkipFile
                lda drvBuf+3,y                  ;Convert filename (assumed to be hexadecimal)
                jsr DrvDecodeLetter             ;into an index number for the cache
                asl
                asl
                asl
                asl
                sta DrvIndexOr+1
                lda drvBuf+4,y
                jsr DrvDecodeLetter
DrvIndexOr:     ora #$00
                tax
                lda drvBuf+1,y
                sta drvFileTrk,x
                lda drvBuf+2,y
                sta drvFileSct,x
DrvSkipFile:    tya
                clc
                adc #$20
                tay
                bcc DrvNextFile
                lda drvBuf+1                    ;Go to next directory block, until no
                ldx drvBuf                      ;more directory blocks
                bne DrvDirLoop
                lda #>(DrvMain-1)               ;Push drive mainloop address
                pha
                lda #<(DrvMain-1)
                pha
                jmp DrvBuildSendTbl             ;X=0 for DrvBuildSendTbl

        ; 1MHz transfer routine

Drv1MHzSend:    ldx #$00
Drv1MHzSendLoop:lda drvBuf
                tay
                and #$0f
                stx $1800                       ;Set DATA=high to mark data available
                tax
                lda drvSendTbl,x
Drv1MHzWait:    ldx $1800                       ;Wait for CLK=low
                beq Drv1MHzWait
                sta $1800
                asl
                and #$0f
                sta $1800
                lda drvSendTblHigh,y
                sta $1800
                asl
                and #$0f
                sta $1800
                inc Drv2MHzSend+Drv1MHzSendLoop-Drv1MHzSend+1
                bne Drv1MHzSendLoop
                jmp DrvSendDone
Drv1MHzSendEnd:

                if Drv1MHzSendEnd > $0800
                    err
                endif

drvFamily:      dc.b $43,$0d,$ff
drvIdLocLo:     dc.b $a4,$c6,$e9
drvIdLocHi:     dc.b $fe,$e5,$a6
drvIdByte:      dc.b "8","F","H"

drvExecLo:      dc.b <$ff54,<DrvFdExec,<$ff4e
drvExecHi:      dc.b >$ff54,>DrvFdExec,>$ff4e

drvDirSctLo:    dc.b <drv1581DirSct,<$56,<$2ba9
drvDirSctHi:    dc.b >drv1581DirSct,>$56,>$2ba9

drvDirTrkLo:    dc.b <$022b,<$54,<$2ba7
drvDirTrkHi:    dc.b >$022b,>$54,>$2ba7

drvJobTrkLo:    dc.b <$0008,<$000d,<$000d,<$2802
drvJobTrkHi:    dc.b >$0008,>$000d,>$000d,>$2802

drvLedBit:      dc.b $40,$40,$00
drvLedAdrHi:    dc.b $40,$40,$05
drv1800Lo:      dc.b <$4001,<$4001,<$8000
drv1800Hi:      dc.b >$4001,>$4001,>$8000

drv1800Ofs:     dc.b Drv2MHzSerialAcc1-DrvMain
                dc.b Drv2MHzSerialAcc2-DrvMain
                dc.b Drv2MHzSerialAcc3-DrvMain
                dc.b Drv2MHzSerialAcc4-DrvMain
                dc.b Drv2MHzSerialAcc5-DrvMain
                dc.b Drv2MHzSerialAcc6-DrvMain
                dc.b DrvSerialAcc7-DrvMain
                dc.b DrvSerialAcc8-DrvMain
                dc.b DrvSerialAcc9-DrvMain
                dc.b DrvSerialAcc10-DrvMain
                dc.b DrvSerialAcc11-DrvMain

                rend

ilDriveCodeEnd:

loaderInitEnd: