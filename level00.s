                processor 6502

                include memory.s

                org lvlObjX
                incbin bg/level00.lvo
                
                org lvlSpawnT
                incbin bg/level00.lvr

                org lvlName
                dc.b "GHOST SHIP",0

                org lvlCodeStart

UpdateLevel:    inc UL_Delay+1
UL_Delay:       lda #$00
                and #$03
                bne UL_NoAnim1
                ldx #$00
                lda #$03
                jsr UL_AnimSub
UL_NoAnim1:     lda UL_Delay+1
                and #$07
                bne UL_NoAnim2
                ldx #$04
                lda #$07
UL_AnimSub:     sta UL_AnimCmp+1
UL_AnimLoop:    lda chars+78*8,x
                asl
                tay
                rol chars+77*8,x
                tya
                adc #$00
                sta chars+78*8,x

                lda chars+78*8,x
                asl
                tay
                rol chars+77*8,x
                tya
                adc #$00
                sta chars+78*8,x

                inx
UL_AnimCmp:     cpx #$00
                bcc UL_AnimLoop
UL_NoAnim2:     rts

                org charInfo
                incbin bg/level00.chi
                incbin bg/level00.chc

                org chars
                incbin bg/level00.chr
