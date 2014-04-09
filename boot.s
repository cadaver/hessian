        ; Autostarting bootpart

                include memory.s
                include kernal.s
                include loadsym.s

        ; SYS instruction if autostart not used

                org $02c3

                dc.b $0b,$08,$0a,$00,$9e
                dc.b $32,$30,$36,$31
                dc.b $00,$00,$00

BasicStart:     lda #$30
                sta loaderFileName
                sta loaderFileName+1

AutoStart:      ldx #<loaderFileName
                ldy #>loaderFileName
                tya
                jsr SetNam
                ldx $ba                         ;Use last used device
                ldy #$00                        ;A is still $02 (file number)
                sty $d011                       ;Blank screen
                jsr SetLFS
                jsr Open
                ldx #$02                        ;Open file $02 for input
                jsr ChkIn
                ldx #71-1
LoadLoop:       jsr ChrIn                       ;Load 71 bytes of loader
                sta depackCodeStart,x           ;depacker, stored backwards
                dex
                bpl LoadLoop                    ;The first bytes are actually
                txs                             ;the depacker & loader start
                rts                             ;addresses

loaderFileName: dc.b "00"

                org ierror
                dc.b <AutoStart, >AutoStart
                dc.b <AutoStart, >AutoStart

bootCodeEnd:

