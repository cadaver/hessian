        ; Autostarting bootpart

                include memory.s
                include kernal.s
                include loadsym.s

        ; SYS instruction if autostart not used

                org $032a

                dc.b $0b,$08                    ;Getin vector (BASIC next line address)
                dc.w AutoStart                  ;Clall vector + BASIC line number
                dc.b $9e,$32,$30,$36,$31        ;Sys instruction
                dc.b $00,$00,$00

                rorg $080d

BasicStart:     ldx #AutoStartEnd-loaderFileName-1
Copy:           lda BasicEnd+loaderFileName-AutoStart,x ;Just need to relocate data, not code
                sta loaderFileName,x
                dex
                bpl Copy
BasicEnd:
                rend

AutoStart:      lda #$02
                ldx #<loaderFileName
                ldy #>loaderFileName
                jsr SetNam
                ldx $ba                         ;Use last used device
                ldy #$00                        ;A is still $02 (file number)
                jsr SetLFS
                jsr Open
                ldx #$02                        ;Open file $02 for input
                jsr ChkIn
                ldy #$00
                sty $d020
                sty $d021
                lda #$20
ClearScreen:    sta $2000,y                     ;Use another screen as $400 is trashed during load
                sta $2100,y
                sta $2200,y
                sta $2300,y
                iny
                bne ClearScreen
                lda #$84
                sta $d018
                ldy #38
ShowMessage:    lda #$0f
                sta colors+12*40,y
                lda message-1,y
                and #$3f
                sta $2000+12*40,y
                dey
                bne ShowMessage
MessageDone:
LoadLoop:       jsr ChrIn
                sta loaderInitEnd,y
                iny
                cpy #214                        ;Load 214 bytes (loader depacker)
                bne LoadLoop
                jmp loaderInitEnd

loaderFileName: dc.b "00"
message:        dc.b "HOLD SPACE/FIRE TO DISABLE FAST LOADER"

AutoStartEnd:
