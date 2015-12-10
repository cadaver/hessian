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

BasicStart:     ldx #AutoStartEnd-AutoStart
Copy:           lda BasicEnd-1,x
                sta AutoStart-1,x
                dex
                bne Copy
                jmp AutoStart
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
                ldx #38
ShowMessage:    lda #$0f
                sta colors+12*40,x
                lda message-1,x
                and #$3f
                sta $2000+12*40,x
                dex
                bne ShowMessage
MessageDone:    ldx #LoadExomizerEnd-LoadExomizer-1
CopyToStack:    lda LoadExomizer,x              ;This code will be overwritten by loader, so copy elsewhere
                sta $0100,x
                dex
                bpl CopyToStack
                jmp $100

loaderFileName: dc.b "00"
message:        dc.b "HOLD SPACE/FIRE TO DISABLE FAST LOADER"

LoadExomizer:   ldy #$00
LoadExomizerLoop:
                jsr ChrIn
                sta exomizerCodeStart,y
                iny
                cpy #packedLoaderStart-exomizerCodeStart ;Load Exomizer
                bne LoadExomizerLoop
                lda #<loaderCodeStart
                ldx #>loaderCodeStart
                jsr LoadFile                    ;Load rest of code with Exomizer
                inc $01                         ;Kernal back on
                jmp loaderCodeEnd               ;Jump to InitLoader
LoadExomizerEnd:

AutoStartEnd:
