        ; Autostarting bootpart

                include memory.s
                include kernal.s
                include ldepacksym.s

                org $032a

                dc.b $0b,$08                    ;GETIN vector or BASIC next line address
                dc.w AutoStart                  ;CLALL vector or BASIC line number
                dc.b $9e,$32,$30,$36,$31        ;Sys instruction
                dc.b $00,$00,$00

                rorg $080d

BasicStart:     lda #<(BootStart-AutoStart+BasicEnd-1)
                sta BasicEnd+3
                lda #>(BootStart-AutoStart+BasicEnd-1)
                sta BasicEnd+4
BasicEnd:
                rend

AutoStart:      ldx #BootEnd-BootStart
CopyBoot:       lda BootStart-1,x
                dc.b $9d,$ff,$00                ;stx $00ff,x
                dex
                bne CopyBoot
                jmp $0100

BootStart:
                rorg $0100

                stx $d020
                stx $d021
                txa
ClearScreen:    sta $d800,x
                sta $d900,x
                sta $da00,x
                sta $db00,x
                inx
                bne ClearScreen
                lda #$02
                ldx #<loaderFileName
                ldy #>loaderFileName
                jsr SetNam
                ldx $ba                         ;Use last used device
                ldy #$00                        ;A is still $02 (file number)
                jsr SetLFS
                jsr Open
                ldx #$02                        ;Open file $02 for input
                jsr ChkIn
                ldy #38
ShowMessage:    lda #$0f
                sta colors+1*40,y
                lda message-1,y
                and #$3f
                sta $0400+1*40,y
                dey
                bne ShowMessage
LoadExomizer:   jsr ChrIn                       ;Load Exomizer as unpacked data
                sta exomizerCodeStart,y
                iny
                cpy #packedLoaderStart-exomizerCodeStart
                bne LoadExomizer
                lda #<loaderCodeStart
                ldx #>loaderCodeStart
                jsr LoadFile                    ;Load rest of loader code with Exomizer
                jmp loaderCodeEnd               ;Jump to InitLoader

loaderFileName: dc.b "00"
message:        dc.b "HOLD SPACE/FIRE TO DISABLE FAST LOADER"

                rend
BootEnd:
