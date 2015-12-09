        ; Autostarting bootpart

                include memory.s
                include kernal.s
                
        ; SYS instruction if autostart not used

                org $032a

                dc.b $0b,$08                    ;Getin vector (BASIC next line address)
                dc.w AutoStart                  ;Clall vector + BASIC line number
                dc.b $9e,$32,$30,$36,$31        ;Sys instruction
                dc.b $00,$00,$00

                rorg 2061

BasicStart:     ldx #AutoStartEnd-AutoStart-1
Copy:           lda BasicEnd,x
                sta AutoStart,x
                dex
                bpl Copy
                jmp AutoStart
BasicEnd:
                rend

AutoStart:      ldx #$00
ShowMessage:    lda #$01
                sta colors+24*40+1,x
                lda message,x
                beq MessageDone
                and #$3f
                sta $0400+24*40+1,x
                inx
                bne ShowMessage
MessageDone:    lda #$02
                ldx #<loaderFileName
                ldy #>loaderFileName
                jsr SetNam
                ldx $ba                         ;Use last used device
                ldy #$00                        ;A is still $02 (file number)
                jsr SetLFS
                jsr Open
                ldx #$02                        ;Open file $02 for input
                jsr ChkIn
LoadLoop:       jsr ChrIn
LoadDest:       sta $0800
                inc LoadDest+1
                bne NoHighByte
                inc LoadDest+2
NoHighByte:     lda status                      ;EOF?
                beq LoadLoop
                jmp $0800

loaderFileName: dc.b "00"
message:        dc.b "HOLD SPACE/FIRE TO DISABLE FAST LOADER",0

AutoStartEnd:
