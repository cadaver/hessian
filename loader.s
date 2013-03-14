        ; Loader part

                include Memory.s
                include Kernal.s

RETRIES         = 5             ;Retries when reading a sector

IRQ_SPEED       = $20           ;$1c07 (head movement speed)
                                ;Safe range $20-$28+ (Graham)

MW_LENGTH       = 32            ;Bytes in one M-W command

tablBi          = depackBuffer
tablLo          = depackBuffer + 52
tablHi          = depackBuffer + 104

drvIdDrv0       = $12           ;Disk drive ID (1541 only)
drvId           = $16           ;Disk ID (1541 only)
drvFileTrk      = $0300
drvBuf          = $0400         ;Sector data buffer
drvStart        = $0500
drvFileSct      = $0680
InitializeDrive = $d005         ;1541 only

                org mainCodeStart

        ; Kernal on/off switching and other Kernal related subroutines

KernalOn:       jsr WaitBottom
FastLoadMode:   lda #$01                        ;In fake-IRQload mode IRQs continue,
                bmi KernalOnFast                ;so no setup necessary
                jsr SilenceSID
                sta $d01a                       ;Raster IRQs off
                sta $d015                       ;Sprites off
                sta $d011                       ;Blank screen
KernalOnFast:   lda #$36
                sta $01
                rts

KernalOff:      lda #$35
                sta $01
                rts

WaitBottom:     lda $d011                       ;Wait until bottom of screen
                bmi WaitBottom
WB_Loop2:       lda $d011
                bpl WB_Loop2
                rts

SilenceSID:     lda #$00
                tax
                jsr SS_Sub
                inx
SS_Sub:         sta $d400,x
                sta $d407,x
                sta $d40e,x
                rts

        ; NMI routine

NMI:            rti

        ; Open file
        ;
        ; Parameters: fileNumber
        ; Returns: -
        ; Modifies: A,X,Y

OpenFile:       jmp FastOpen
SaveFile:       jmp FastSave

        ; Read a byte from an opened file
        ;
        ; Parameters: -
        ; Returns: if C=0, byte in A. If C=1, EOF/errorcode in A:
        ; $00 - EOF (no error)
        ; $01 - Read error
        ; $02 - File not found
        ; $80 - Device not present
        ; Modifies: A

GetByte:        lda fileOpen
                beq GB_Closed
                stx loadTempReg
                inc bufferStatus
                ldx bufferStatus
                lda loadBuffer+1,x
GB_FastCmp:     cpx #$00                        ;Reach end of buffer?
                bcc GB_Done
                pha
                jsr FL_FillBuffer               ;Fill buffer for next byte
                pla
GB_Done:        ldx loadTempReg
                clc
FO_Done:        rts
GB_Closed:      lda loadBuffer+2
                sec
                rts

FastOpen:       ldx fileOpen                    ;A file already open? If so, do nothing
                bne FO_Done                     ;(allows chaining of files)
                inc fileOpen
                sta $d07a                       ;SCPU to slow mode
                lda #$00                        ;Command 0 = load
                jsr FL_SendCommand
FL_PreDelay:    inx                             ;Wait to make sure the drive has also set
                bne FL_PreDelay                 ;lines high
FL_FillBuffer:  ldx #$00
FL_FillBufferWait:
                bit $dd00                       ;Wait for 1541 to signal data ready by
                bmi FL_FillBufferWait           ;setting DATA low
FL_FillBufferLoop:
FL_SpriteWait:  lda $d012                       ;Check for sprite Y-coordinate range
FL_MaxSprY:     cmp #$00                        ;(these max & min values are filled in the
                bcs FL_NoSprites                ;raster interrupt)
FL_MinSprY:     cmp #$00
                bcs FL_SpriteWait
FL_NoSprites:   sei
FL_WaitBadLine: lda $d011
                clc
                sbc $d012
                and #$07
                beq FL_WaitBadLine
                lda $dd00
                ora #$10
                sta $dd00                       ;Set CLK low
FL_Delay:       bit $00                         ;Delay for synchronized transfer
                nop
                and #$03
                sta FL_Eor+1
                sta $dd00                       ;Set CLK high
                lda $dd00
                lsr
                lsr
                eor $dd00
                lsr
                lsr
                eor $dd00
                lsr
                lsr
FL_Eor:         eor #$00
                eor $dd00
                cli
                sta loadBuffer,x
                inx
                bne FL_FillBufferLoop
FL_Common:      stx bufferStatus                ;X is 0 here
                ldx #$fe
                lda loadBuffer                  ;Full 254 bytes?
                bne FL_FullBuffer
                ldx loadBuffer+1                ;End of load?
                bne FL_NoLoadEnd
                stx fileOpen                    ;Clear fileopen indicator
FL_NoLoadEnd:   dex
FL_FullBuffer:  stx GB_FastCmp+1
                rts

FL_SendCommand: ;jsr FL_SendByte
FL_FileNumber:  lda fileNumber                  ;Initial filenumber for the mainpart
FL_SendByte:    sta loadTempReg
                ldx #$08                        ;Bit counter
FL_SendInner:   bit $dd00                       ;Wait for both DATA & CLK to go high
                bpl FL_SendInner
                bvc FL_SendInner
                lsr loadTempReg                 ;Send one bit of filenumber
                lda #$10
                ora $dd00
                bcc FL_ZeroBit
                eor #$30
FL_ZeroBit:     sta $dd00
                lda #$c0                        ;Wait for CLK & DATA low (diskdrive answers)
FL_SendAck:     bit $dd00
                bne FL_SendAck
                lda #$ff-$30                    ;Set DATA and CLK high
                and $dd00
                sta $dd00
                dex
                bne FL_SendInner
                rts

        ; Save file
        ;
        ; Parameters: A,X startaddress, zpBitsLo amount of bytes, fileName / fileNumber
        ; Returns: -
        ; Modifies: A,X,Y

FastSave:       sta zpSrcLo
                stx zpSrcHi
                lda #$01
                jsr FL_SendCommand
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
                inc zpSrcLo
FS_NotOver:     dec zpBitsLo
                bne FS_Loop
FS_PreDecrement:dec zpBitsHi
                bpl FS_Loop
                rts

FastLoadEnd:

        ; Load file packed with Exomizer 2 forward mode
        ;
        ; Parameters: A,X load address, fileName / fileNumber
        ; Returns: C=0 if loaded OK, or C=1 and error code in A (see GetByte)
        ; Modifies: A,X,Y

LoadFile:       sta zpDestLo
                stx zpDestHi
                tsx
                stx LF_StackPtr+1
                jsr OpenFile

; -------------------------------------------------------------------
; This source code is altered and is not the original version found on
; the Exomizer homepage.
; It contains modifications made by Krill/Plush to depack a packed file
; crunched forward and to work with his loader.
;
; Further modification & bugfixing of the forward decruncher by Lasse
; Öörni
; -------------------------------------------------------------------
;
; Copyright (c) 2002 - 2005 Magnus Lind.
;
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from
; the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
;   1. The origin of this software must not be misrepresented; you must not
;   claim that you wrote the original software. If you use this software in a
;   product, an acknowledgment in the product documentation would be
;   appreciated but is not required.
;
;   2. Altered source versions must be plainly marked as such, and must not
;   be misrepresented as being the original software.
;
;   3. This notice may not be removed or altered from any distribution.
;
;   4. The names of this software and/or it's copyright holders may not be
;   used to endorse or promote products derived from this software without
;   specific prior written permission.
;
; -------------------------------------------------------------------
; no code below this comment has to be modified in order to generate
; a working decruncher of this source file.
; However, you may want to relocate the tables last in the file to a
; more suitable address.
; -------------------------------------------------------------------
;
; -------------------------------------------------------------------
; jsr this label to decrunch, it will in turn init the tables and
; call the decruncher
; no constraints on register content, however the
; decimal flag has to be #0 (it almost always is, otherwise do a cld)
exomizer:

; -------------------------------------------------------------------
; init zeropage, x and y regs.
;
  ldx #0
  ldy #0
init_zp:
  jsr GetByte
  bcs LF_Error
  sta zpBitBuf

; -------------------------------------------------------------------
; calculate tables (50 bytes)
; x and y must be #0 when entering
;
nextone:
  inx
  tya
  and #$0f
  beq shortcut    ; start with new sequence

  txa          ; this clears reg a
  lsr          ; and sets the carry flag
  ldx tablBi-1,y
rolle:
  rol
  rol zpBitsHi
  dex
  bpl rolle    ; c = 0 after this (rol zpBitsHi)

  adc tablLo-1,y
  tax

  lda zpBitsHi
  adc tablHi-1,y
shortcut:
  sta tablHi,y
  txa
  sta tablLo,y

  ldx #4
  jsr get_bits    ; clears x-reg.
  sta tablBi,y
  iny
  cpy #52
  bne nextone
  beq begin

; -------------------------------------------------------------------
; get bits (29 bytes)
;
; args:
;   x = number of bits to get
; returns:
;   a = #bits_lo
;   x = #0
;   c = 0
;   z = 1
;   zpBitsHi = #bits_hi
; notes:
;   y is untouched
; -------------------------------------------------------------------
get_bits:
  lda #$00
  sta zpBitsHi
  cpx #$01
  bcc bits_done
bits_next:
  lsr zpBitBuf
  bne bits_ok
  pha
  jsr GetByte
  bcs LF_Error
  sec
  ror
  sta zpBitBuf
  pla
bits_ok:
  rol
  rol zpBitsHi
  dex
  bne bits_next
bits_done:
  rts

exomizer_ok:
  clc
LF_Error:
LF_StackPtr:
  ldx #$ff
  txs
  rts

; -------------------------------------------------------------------
; literal sequence handling
;
literal_start:
  ldx #$10    ; these 16 bits
  jsr get_bits; tell the length of the sequence
  ldx zpBitsHi
literal_start1: ; if literal byte, a = 1, zpBitsHi = 0
  sta zpLenLo

; -------------------------------------------------------------------
; main copy loop
; x = length hi
; y = length lo
;
copy_start:
  ldy #$00
copy_next:
  bcs copy_noliteral
  jsr GetByte
  bcs LF_Error
  dc.b $2c; skip next instruction
copy_noliteral:
  lda (zpSrcLo),y
  sta (zpDestLo),y
  iny
  bne copy_skiphi1
  dex
  inc zpDestHi
  inc zpSrcHi
copy_skiphi1:
  tya
  eor zpLenLo
  bne copy_next
  txa
  bne copy_next
  tya
  clc
  adc zpDestLo
  sta zpDestLo
  bcc copy_skiphi2
  inc zpDestHi
copy_skiphi2:

; -------------------------------------------------------------------
; decruncher entry point, needs calculated tables (21(13) bytes)
; x and y must be #0 when entering
;
begin:
  inx
  jsr get_bits
  tay
  bne literal_start1; if bit set, get a literal byte
getgamma:
  inx
  jsr bits_next
  lsr
  iny
  bcc getgamma
  cpy #$11
  beq exomizer_ok   ; gamma = 17   : end of file
  bcs literal_start ; gamma = 18   : literal sequence
                    ; gamma = 1..16: sequence

; -------------------------------------------------------------------
; calulate length of sequence (zp_len) (11 bytes)
;
  ldx tablBi-1,y
  jsr get_bits
  adc tablLo-1,y  ; we have now calculated zpLenLo
  sta zpLenLo
; -------------------------------------------------------------------
; now do the hibyte of the sequence length calculation (6 bytes)
  lda zpBitsHi
  adc tablHi-1,y  ; c = 0 after this.
  pha
; -------------------------------------------------------------------
; here we decide what offset table to use (20 bytes)
; x is 0 here
;
  bne nots123
  ldy zpLenLo
  cpy #$04
  bcc size123
nots123:
  ldy #$03
size123:
  ldx tablBit-1,y
  jsr get_bits
  adc tablOff-1,y  ; c = 0 after this.
  tay      ; 1 <= y <= 52 here

; -------------------------------------------------------------------
; calulate absolute offset (zp_src)
;
  ldx tablBi,y
  jsr get_bits
  adc tablLo,y
  bcc skipcarry
  inc zpBitsHi
skipcarry:
  sec
  eor #$ff
  adc zpDestLo
  sta zpSrcLo
  lda zpDestHi
  sbc zpBitsHi
  sbc tablHi,y
  sta zpSrcHi

; -------------------------------------------------------------------
; prepare for copy loop (8(6) bytes)
;
  pla
  tax
  sec
  jmp copy_start

; -------------------------------------------------------------------
; end of decruncher
; -------------------------------------------------------------------

        ; Loader runtime data

tablBit:       dc.b 2,4,4                       ;Exomizer static tables
tablOff:       dc.b 48,32,16

scratch:        dc.b "S0:"
fileName:       dc.b "01"                       ;Initial filename for the mainpart
fileNumber:     dc.b $01                        ;Initial filenumber for the mainpart

loaderCodeEnd:                                  ;Resident code ends here!

        ; Loader initialization

InitLoader:     ldx #$ff                        ;Init stackpointer
                txs
                lda #$02                        ;Close the file loaded from
                jsr Close
                sei
                sta $d07f                       ;Disable SCPU hardware regs
                sta $d07a                       ;SCPU to slow mode
                lda #$7f                        ;Disable & acknowledge IRQ sources
                sta $dc0d
                ldx #$00
                stx $d01a
                stx $d015
                stx $d020
                stx messages                    ;Disable KERNAL messages
                stx fileOpen                    ;Clear fileopen indicator
IL_DetectNtsc1: lda $d012                       ;Detect PAL/NTSC
IL_DetectNtsc2: cmp $d012
                beq IL_DetectNtsc2
                bmi IL_DetectNtsc1
                cmp #$20
                bcc IL_IsNtsc
                lda #$2c                        ;Adjust 2-bit fastload transfer
                sta FL_Delay                    ;delay for PAL
IL_IsNtsc:      lda $dc0d
                inc $d019
                lda #<NMI                       ;Set NMI vector
                sta $0318
                sta $fffa
                sta $fffe
                lda #>NMI
                sta $0319
                sta $fffb
                sta $ffff
                lda #$81                        ;Run Timer A once to disable NMI from Restore keypress
                sta $dd0d                       ;Timer A interrupt source
                lda #$01                        ;Timer A count ($0001)
                sta $dd04
                stx $dd05
                lda #%00011001                  ;Run Timer A in one-shot mode
                sta $dd0e
                lda $dc01                       ;If space held down when starting,
                and #$10                        ;revert to slow (compatible) loading
                beq IL_NoFastLoad

IL_DetectDrive: lda #$aa
                sta $a5
                lda #(ilDriveCodeEnd-ilDriveCode+MW_LENGTH-1)/MW_LENGTH
                ldx #<ilDriveCode
                ldy #>ilDriveCode
                jsr UploadDriveCode             ;Upload test-drivecode
                lda status                      ;If error $c0, it's probably IDE64
                cmp #$c0                        ;and we must not persist with more
                beq IL_NoSerial                 ;serial IO or we'll lock up
                ldx #$00
                ldy #$00
IL_Delay:       inx                             ;Delay to make sure the test-
                bne IL_Delay                    ;drivecode executed to the end
                iny
                bpl IL_Delay
                lda fa                          ;Set drive to listen
                jsr Listen
                lda #$6f
                jsr Second
                ldx #$05
IL_DDSendMR:    lda ilMRString,x                ;Send M-R command (backwards)
                jsr CIOut
                dex
                bpl IL_DDSendMR
                jsr UnLsn
                lda fa
                jsr Talk
                lda #$6f
                jsr Tksa
                lda #$00
                jsr ACPtr                       ;First byte: test value
                pha
                jsr ACPtr                       ;Second byte: drive type
                tax
                jsr UnTlk
                pla
                cmp #$aa                        ;Drive can execute code, so can
                beq IL_FastLoadOK               ;use fastloader
                lda $a5                         ;If serial bus delay counter is
                cmp #$aa                        ;unchanged, it's probably VICE's
                bne IL_NoFastLoad               ;virtual device trap
IL_NoSerial:    lda #$80                        ;Serial bus not used: switch to
                sta FastLoadMode+1              ;"fake" IRQ-loading mode
IL_NoFastLoad:  ldx #ilSlowLoadEnd-ilSlowLoadStart
IL_CopySlowLoad:lda ilSlowLoadStart-1,x         ;Copy slowload routines
                sta OpenFile-1,x
                dex
                bne IL_CopySlowLoad
                jmp IL_Done

IL_FastLoadOK:  dec FastLoadMode+1              ;Use normal IRQ-loading
                txa                             ;1541?
                beq IL_Is1541
                lda #>DrvMain_Not1541           ;If not, skip the $1c07 write
                sta iflMEString                 ;on loader init
                lda #<DrvMain_Not1541
                sta iflMEString+1
IL_Is1541:      lda ilDirTrkLo,x                ;Patch directory
                sta DrvDirTrk+1-drvStart+driveCode
                lda ilDirTrkHi,x
                sta DrvDirTrk+2-drvStart+driveCode
                lda ilDirSctLo,x
                sta DrvDirSct+1-drvStart+driveCode
                lda ilDirSctHi,x
                sta DrvDirSct+2-drvStart+driveCode
                lda ilExecLo,x                  ;Patch job exec address
                sta DrvExecJsr+1-drvStart+driveCode
                lda ilExecHi,x
                sta DrvExecJsr+2-drvStart+driveCode
                lda ilJobTrkLo,x                ;Patch job track/sector
                sta DrvReadTrk+1-drvStart+driveCode
                adc #$00                        ;C=1 here, so adds 1
                sta DrvReadSct+1-drvStart+driveCode
                lda ilJobTrkHi,x
                sta DrvReadTrk+2-drvStart+driveCode
                adc #$00
                sta DrvReadSct+2-drvStart+driveCode
                lda ilExitJump,x                ;Patch exit jump
                sta DrvExitJump-drvStart+driveCode
                lda ilLedBit,x
                sta DrvLed+1-drvStart+driveCode
                lda ilLedAdrHi,x
                sta DrvLedAcc0+2-drvStart+driveCode
                sta DrvLedAcc1+2-drvStart+driveCode
                lda il1800Lo,x
                sta IL_Patch1800Lo+1
                lda il1800Hi,x
                sta IL_Patch1800Hi+1
                ldy #10
IL_PatchLoop:   ldx il1800Ofs,y
IL_Patch1800Lo: lda #$00                        ;Patch all $1800 accesses
                sta DrvMain+1-drvStart+driveCode,x
IL_Patch1800Hi: lda #$00
                sta DrvMain+2-drvStart+driveCode,x
                dey
                bpl IL_PatchLoop
                cmp #$18
                bne IL_StartFastLoad            ;Copy the 1 Mhz routine for 1541
                ldy #il1MHzEnd-il1MHzStart-1
IL_1MHzCopy:    lda il1MHzStart,y
                sta Drv1MHzSend-drvStart+driveCode,y
                dey
                bpl IL_1MHzCopy
IL_StartFastLoad: 
                lda #(drvEnd-drvStart+MW_LENGTH-1)/MW_LENGTH
                ldx #<driveCode
                ldy #>driveCode
                jsr UploadDriveCode             ;Then start fastloader

IL_Done:        jsr KernalOff
                lda #>(loaderCodeEnd-1)         ;Mainpart startaddress-1
                pha
                lda #<(loaderCodeEnd-1)
                pha
                lda #<loaderCodeEnd
                ldx #>loaderCodeEnd
                jmp LoadFile                    ;Code here will be overwritten

UploadDriveCode:sta loadTempReg                 ;Number of "packets" to send
                stx zpSrcLo
                sty zpSrcHi
                ldy #$00                        ;Init selfmodifying addresses
                sty iflMWString+2
                lda #>drvStart
                sta iflMWString+1
                bne UDC_NextPacket
UDC_SendMW:     lda iflMWString,x               ;Send M-W command (backwards)
                jsr CIOut
                dex
                bpl UDC_SendMW
                ldx #MW_LENGTH
UDC_SendData:   lda (zpSrcLo),y                 ;Send one byte of drive code
                jsr CIOut
                iny
                bne UDC_NotOver
                inc zpSrcHi
UDC_NotOver:    inc iflMWString+2               ;Also, move the M-W pointer forward
                bne UDC_NotOver2
                inc iflMWString+1
UDC_NotOver2:   dex
                bne UDC_SendData
                jsr UnLsn                       ;Unlisten to perform the command
UDC_NextPacket: lda fa                          ;Set drive to listen
                jsr Listen
                lda status                      ;Quit if error (IDE64)
                cmp #$c0
                beq UDC_Quit
                lda #$6f
                jsr Second
                ldx #$05
                dec loadTempReg                 ;All "packets" sent?
                bpl UDC_SendMW
UDC_SendME:     lda iflMEString-1,x             ;Send M-E command (backwards)
                jsr CIOut
                dex
                bne UDC_SendME
                jsr UnLsn
UDC_Quit:       rts

        ; Diskdrive code

driveCode:
                rorg drvStart

DrvMain:        lda #IRQ_SPEED                  ;Speed up the controller a bit
                sta $1c07                       ;(1541 only)
DrvMain_Not1541:
DrvLoop:        cli
                ldy #$08                        ;Filenumber bit counter
DrvNameBitLoop:
DrvSerialAcc1:  lda $1800
                bpl DrvNoQuit                   ;Quit if ATN is low
DrvExitJump:    jmp InitializeDrive             ;1541 = exit through Initialize
                                                ;Others = exit through RTS
DrvNoQuit:      and #$05                        ;Wait for CLK or DATA going low
                beq DrvNameBitLoop
                lsr                             ;Read the data bit
                lda #$02                        ;Pull the other line low to acknowledge
                bcc DrvNameZero
                lda #$08
DrvNameZero:    ror DrvFileName+1               ;Store the data bit
DrvSerialAcc2:  sta $1800
DrvNameWait:
DrvSerialAcc3:  lda $1800                       ;Wait for either line going high
                and #$05
                cmp #$05
                beq DrvNameWait
                lda #$00
DrvSerialAcc4:  sta $1800                       ;Set CLK & DATA high
                dey
                bne DrvNameBitLoop              ;Loop until all bits have been received
                sei                             ;Disable interrupts after first byte
DrvDirCached:   lda #$00                        ;Cache directory if necessary
                bne DrvCacheValid
                jsr DrvCacheDir
DrvCacheValid:
DrvFileName:    ldy #$00
                ldx drvFileTrk,y
                bne DrvFound
                stx DrvDirCached+1              ;If file not found, reset caching
DrvFileNotFound:ldx #$02                        ;Return code $02 = File not found
DrvEndMark:     stx drvBuf+2                    ;Send endmark, return code in X
                lda #$00
                sta drvBuf
                sta drvBuf+1
                beq DrvSendBlk

DrvFound:       lda drvFileSct,y                ;File found, get starting T&S
DrvSectorLoop:  jsr DrvReadSector               ;Read the data sector
                bcs DrvEndMark                  ;Quit if cannot read
                lda DrvDirCached+1              ;If disk ID changed and dir cache invalidated,
                beq DrvFileNotFound             ;treat as file not found error
DrvSendBlk:     ldy #$00
                ldx #$02
DrvSendLoop:    lda drvBuf,y
                lsr
                lsr
                lsr
                lsr
DrvSerialAcc5:  stx $1800                       ;Set DATA=low for first byte, high for
                tax                             ;subsequent bytes
                lda drvSendTbl,x
                pha
                lda drvBuf,y
                and #$0f
                tax
                lda #$04
DrvSerialAcc6:  bit $1800                       ;Wait for CLK=low
                beq DrvSerialAcc6
                lda drvSendTbl,x
DrvSerialAcc7:  sta $1800

        ; 2MHz send timing code from ULoad3 by MagerValp

Drv2MHzSend:    jsr DrvDelay18
                nop
                asl
                and #$0f
Drv2MHzSerialAcc8:
                sta $1800
                cmp ($00,x)
                nop
                pla
Drv2MHzSerialAcc9:
                sta $1800
                cmp ($00,x)
                nop
                asl
                and #$0f
Drv2MHzSerialAcc10:
                sta $1800
                ldx #$00
                iny
                bne DrvSendLoop
                jsr DrvDelay12
Drv2MHzSerialAcc11:
                stx $1800                       ;Finish send: DATA & CLK both high

DrvSendDone:    lda drvBuf+1                    ;Follow the T/S chain
                ldx drvBuf
                bne DrvSectorLoop
                tay                             ;If 2 first bytes are both 0,
                bne DrvEndMark                  ;endmark has been sent and can
                jmp DrvLoop                     ;return to main loop

DrvReadSector:
DrvReadTrk:     stx $1000
DrvReadSct:     sta $1000
                jsr DrvLed
                ldy #RETRIES                    ;Retry counter
DrvRetry:       lda #$80
                ldx #$01
DrvExecJsr:     jsr Drv1541Exec                 ;Exec buffer 1 job
                cmp #$02                        ;Error?
                bcc DrvSuccess
DrvSkipId:      dey                             ;Decrease retry counter
                bne DrvRetry
DrvFailure:     ldx #$01                        ;Return code $01 - Read error
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
                pha                             ;Save returncode
                ldx #$02
DrvCheckId:     lda drvId-1,x                   ;Check for disk ID change
                cmp drvIdDrv0-1,x               ;(1541 only)
                beq DrvIdOk
                sta drvIdDrv0-1,x
                lda #$00                        ;If changed, force recache of dir
                sta DrvDirCached+1
DrvIdOk:        dex
                bne DrvCheckId
                pla
                rts

DrvFdExec:      jsr $ff54                       ;FD2000 fix By Ninja
                lda $03
                rts

DrvDelay18:     cmp ($00,x)
DrvDelay12:     rts

DrvCacheDir:    tax                             ;A=0 here
DrvClearCache:  sta drvFileTrk,x                ;Clear tracknumbers first
                inx
                bne DrvClearCache
DrvDirTrk:      ldx $1000
DrvDirSct:      lda $1000                       ;Read disk directory
DrvDirLoop:     jsr DrvReadSector               ;Read sector
                bcs DrvDirCacheDone             ;If failed, abort caching
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
DrvDirCacheDone:inc DrvDirCached+1
                rts

DrvDecodeLetter:sec
                sbc #$30
                cmp #$10
                bcc DrvDecodeLetterDone
                sbc #$07
DrvDecodeLetterDone:
                rts

drvSendTbl:     dc.b $0f,$07,$0d,$05
                dc.b $0b,$03,$09,$01
                dc.b $0e,$06,$0c,$04
                dc.b $0a,$02,$08,$00

drv1541DirSct  = drvSendTbl+7                   ;Byte $01
drv1581DirSct  = drvSendTbl+5                   ;Byte $03

drv1541DirTrk:  dc.b 18

drvEnd:
                if drvEnd > drvFileSct
                    err
                endif

                rend

        ;Drive detection drivecode
        
ilDriveCode:
                rorg drvStart

                asl drvReturn                   ;Modify first returnvalue to prove
                                                ;we've executed something :)
                lda $fea0                       ;Recognize drive family
                ldx #3                          ;(from Dreamload)
DrvFLoop:       cmp drvFamily-1,x
                beq DrvFFound
                dex                             ;If unrecognized, assume 1541
                bne DrvFLoop
                beq DrvIdFound
DrvFFound:      lda drvIdLoclo-1,x
                sta DrvIdLda+1
                lda drvIdLochi-1,x
                sta DrvIdLda+2
DrvIdLda:       lda $fea4                       ;Recognize drive type
                ldx #3                          ;3 = CMD HD
DrvIdLoop:      cmp drvIdbyte-1,x               ;2 = CMD FD
                beq DrvIdFound                  ;1 = 1581
                dex                             ;0 = 1541
                bne DrvIdLoop
DrvIdFound:     stx drvReturn2
                rts

drvFamily:      dc.b $43,$0d,$ff
drvIdLoclo:     dc.b $a4,$c6,$e9
drvIdLochi:     dc.b $fe,$e5,$a6
drvIdbyte:      dc.b "8","F","H"

drvReturn:      dc.b $55
drvReturn2:     dc.b $00

                rend

ilDriveCodeEnd:

        ; 1MHz transfer drivecode

il1MHzStart:
                rorg Drv2MHzSend

Drv1MHzSend:    asl
                and #$0f
Drv1MHzSerialAcc8:
                sta $1800
                pla
Drv1MHzSerialAcc9:
                sta $1800
                asl
                and #$0f
Drv1MHzSerialAcc10:
                sta $1800
                ldx #$00
                iny
                bne DrvSendLoop
                nop
Drv1MHzSerialAcc11: stx $1800                       ;Finish send: DATA & CLK both high
                beq DrvSendDone

                rend
il1MHzEnd:

        ; Slow fileopen / getbyte / save routines

ilSlowLoadStart:

                rorg OpenFile

                jmp SlowOpen
                jmp SlowSave

SlowGetByte:    lda fileOpen
                beq SGB_Closed
                stx bufferStatus
                jsr KernalOnFast
                jsr ChrIn
                sta loadTempReg
                lda status
                bne SGB_EOF
                jsr KernalOff
SGB_Done:       lda loadTempReg
                clc
SGB_Common:     ldx bufferStatus
SO_Done:        rts

SGB_EOF:        and #$83
                sta SGB_Closed+1
                php
                sty SGB_SaveY+1
                jsr CloseKernalFile
SGB_SaveY:      ldy #$00
                plp
                beq SGB_Done                    ;If zero return code, return last file byte now
SGB_Closed:     lda #$00
                sec
                bcs SGB_Common

SlowOpen:       lda fileOpen
                bne SO_Done
                inc fileOpen
                jsr KernalOn
                jsr SetFileName
                ldy #$00                        ;A is $02 here
                jsr SetLFSOpen
                jsr ChkIn
                jmp KernalOff                   ;Kernal off after opening

SlowSave:       sta zpSrcLo
                stx zpSrcHi
                inc fileOpen                    ;Set fileopen indicator, raster delays are to be expected
                sta $d07a                       ;SCPU to slow mode
                jsr KernalOn
                jsr ConvertFileName
                lda #$05
                ldx #<scratch
                ldy #>scratch
                jsr SetNam
                lda #$0f
                tay
                jsr SetLFSOpen
                lda #$0f
                jsr Close
                jsr SetFileNameOnly
                ldy #$01                        ;Open for write
                ldx fa
                jsr SetLFSOpen
                jsr ChkOut
                ldy #$00
SF_Loop:        lda (zpSrcLo),y
                jsr ChrOut
                inc zpSrcLo
                bne SF_Ok
                inc zpSrcHi
SF_Ok:          lda zpSrcLo
                cmp zpDestLo
                bne SF_Loop
                lda zpSrcHi
                cmp zpDestHi
                bne SF_Loop

CloseKernalFile:lda #$02
                jsr Close
                dec fileOpen
                jmp KernalOff

SetFileName:    jsr ConvertFileName
SetFileNameOnly:lda #$02
                ldx #<fileName
                ldy #>fileName
                jmp SetNam

ConvertFileName:
                lda fileNumber
                pha
                lsr
                lsr
                lsr
                lsr
                ldx #$00
                jsr CFN_Sub
                pla
                inx
CFN_Sub:        and #$0f
                ora #$30
                cmp #$3a
                bcc CFN_Number
                adc #$06
CFN_Number:     sta fileName,x
                rts

SetLFSOpen:     ldx fa
                jsr SetLFS
                jsr Open
                ldx #$02
                rts

SlowLoadEnd:
                if SlowLoadEnd > FastLoadEnd
                err
                endif

                rend

ilSlowLoadEnd:

ilMRString:     dc.b 2,>drvReturn,<drvReturn,"R-M"

il1800Ofs:      dc.b DrvSerialAcc1-DrvMain
                dc.b DrvSerialAcc2-DrvMain
                dc.b DrvSerialAcc3-DrvMain
                dc.b DrvSerialAcc4-DrvMain
                dc.b DrvSerialAcc5-DrvMain
                dc.b DrvSerialAcc6-DrvMain
                dc.b DrvSerialAcc7-DrvMain
                dc.b Drv2MHzSerialAcc8-DrvMain
                dc.b Drv2MHzSerialAcc9-DrvMain
                dc.b Drv2MHzSerialAcc10-DrvMain
                dc.b Drv2MHzSerialAcc11-DrvMain

il1800Lo:       dc.b <$1800,<$4001,<$4001,<$8000
il1800Hi:       dc.b >$1800,>$4001,>$4001,>$8000

ilDirTrkLo:     dc.b <drv1541DirTrk,<$022b,<$54,<$2ba7
ilDirTrkHi:     dc.b >drv1541DirTrk,>$022b,>$54,>$2ba7
ilDirSctLo:     dc.b <drv1541DirSct,<drv1581DirSct,<$56,<$2ba9
ilDirSctHi:     dc.b >drv1541DirSct,>drv1581DirSct,>$56,>$2ba9

ilExecLo:       dc.b <Drv1541Exec,<$ff54,<DrvFdExec,<$ff4e
ilExecHi:       dc.b >Drv1541Exec,>$ff54,>DrvFdExec,>$ff4e

ilJobTrkLo:     dc.b <$0008,<$000d,<$000d,<$2802
ilJobTrkHi:     dc.b >$0008,>$000d,>$000d,>$2802

ilExitJump:     dc.b $4c,$60,$60,$60

ilLedBit:       dc.b $08,$40,$40,$00
ilLedAdrHi:     dc.b $1c,$40,$40,$05

iflMWString:    dc.b MW_LENGTH,>drvStart, <drvStart,"W-M"
iflMEString:    dc.b >DrvMain,<DrvMain, "E-M"
