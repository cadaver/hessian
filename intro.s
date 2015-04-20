                include macros.s
                include mainsym.s

                org introStart
                ds.b 1024,$71                   ;Blank char

                org $f000
                incbin covert.chr
                ds.b 8,$ff

                org introCodeStart

LOGO_FADE_FRAMES = 4

                lda $dd00
                and #$fc
                sta $dd00
                lda #$bc
                sta $d018
                lda #$18
                sta $d016
                lda #$08
                ldx #$00
                stx $d415                       ;Set filter lowbyte for all subsequent music
                stx $d021
                stx $d022
                stx $d023
SetColors:      sta $d800,x
                sta $d900,x
                sta $da00,x
                sta $db00,x
                inx
                bne SetColors
                ldx #29
DrawLogo:       lda covertLogoData,x
                sta introStart+10*40+5,x
                lda covertLogoData+30,x
                sta introStart+11*40+5,x
                lda covertLogoData+60,x
                sta introStart+12*40+5,x
                lda covertLogoData+90,x
                sta introStart+13*40+5,x
                dex
                bpl DrawLogo
                jsr WaitBottom
                lda #$1b
                sta $d011                       ;Show logo
                lda fastLoadMode
                cmp #$01
                beq NoMusic                     ;If not using Kernal slow loading, play music now
                sei
                lda #$00
                jsr musicData
                lda #<MusicIrq
                sta $fffe
                lda #>MusicIrq
                sta $ffff
                lda #$fc
                sta $d012
                lda #$01
                sta $d01a
                cli

NoMusic:        ldx #$00
FadeInLoop:     inx
                jsr SetLogoColors
                cpx #LOGO_FADE_FRAMES
                bcc FadeInLoop

                lda fastLoadMode
                cmp #$01
                beq NoPause
                ldx #100                        ;If using fastloading, pause for 2 seconds
PauseLoop:      jsr WaitBottom                  ;to show the logo a little longer
                dex
                bne PauseLoop

NoPause:        lda #<$2000
                ldx #>$2000
                jsr LoadFile                    ;Load bitmap data attached to this file

                lda #$34                        ;Copy bitmap to proper videobank
                sta $01                         ;(loader does not support loading under I/O)
                ldy #$00
                sty zpSrcLo
                sty zpDestLo
                lda #$20
                sta zpSrcHi
                lda #$c0
                sta zpDestHi
CopyPicture:    lda (zpSrcLo),y
                sta (zpDestLo),y
                iny
                bne CopyPicture
                inc zpSrcHi
                inc zpDestHi
                lda zpDestHi
                cmp #$e0
                bcc CopyPicture
                lda #$35
                sta $01

                ldx #LOGO_FADE_FRAMES
FadeOutLoop:    jsr SetLogoColors
                dex
                bpl FadeOutLoop

                lda #$a0
                sta $d018
                ldx #$00
                stx $d011                       ;Blank screen now until ready to show
                lda #<$e800
                ldx #>$e800
                jsr LoadFile                    ;Load screen & color data
                lda #<$d800
                ldx #>$d800
                jsr LoadFile
                jsr WaitBottom
                lda #$3b
                sta $d011                       ;Show loading picture

                lda #>(InitAll-1)               ;Store mainpart entrypoint to stack
                pha
                lda #<(InitAll-1)
                pha
                lda #<loaderCodeEnd
                ldx #>loaderCodeEnd
                jmp LoadFile                    ;Load mainpart

SetLogoColors:  ldy #$03
SetLogoDelay:   jsr WaitBottom
                dey
                bne SetLogoDelay
                lda logoColors,x
                sta $d021
                lda logoColors+1,x
                sta $d022
                lda logoColors+2,x
                sta $d023
                rts

MusicIrq:       sta irqSaveA
                stx irqSaveX
                sty irqSaveY
                lda $01
                sta irqSave01
                lda #$35
                sta $01
                jsr musicData+3
                dec $d019
                lda irqSave01
                sta $01
                lda irqSaveA
                ldx irqSaveX
                ldy irqSaveY
                rti

logoColors:     dc.b 0,0,0,0,11,12,13

covertLogoData: incbin covertscr.dat

                org musicData
                incbin loadermusic.bin
