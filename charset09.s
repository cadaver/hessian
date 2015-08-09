                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    lda mapX
                asl
                asl
                ora blockX
                sta UL_XAdd+1
                lda mapY
                asl
                asl
                ora blockY
                sta UL_YAdd+1



                lda Irq1_ScrollX+1
                clc
UL_XAdd:        adc #$00
                and #$07
                asl
                asl
                asl
                sta UL_XPos+1
                sta UL_Reload+1
                adc #$08
                sta UL_EndCmp+1
                lda Irq1_ScrollY+1
                clc
UL_YAdd:        adc #$00
                and #$07
UL_XPos:        ora #$00
                tay
                ldx #$00
UL_Loop:        lda chars+52*8,y
                sta chars+13*8,x
                iny
UL_EndCmp:      cpy #$00
                bne UL_NoReload
UL_Reload:      ldy #$00
UL_NoReload:    inx
                cpx #$08
                bne UL_Loop
                rts


                org charInfo
                incbin bg/world09.chi
                incbin bg/world09.chc

                org chars
                incbin bg/world09.chr

                org charsetLoadBlockInfo
                incbin bg/world09.bli

                org charsetLoadName
                dc.b "UNDERGROUND",0

                org charsetLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter