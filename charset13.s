                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    ldx #$06
                ldy chars+141*8+7
UL_WaterLoop:   lda chars+141*8,x
                sta chars+141*8+1,x
                dex
                bpl UL_WaterLoop
                sty chars+141*8
                inc bgDelay
                inx
                lda bgDelay
                and #$07
                bne UL_SkipWater1
                jsr UL_ScrollWaterSub
UL_SkipWater1:  inx
                lda bgDelay
                and #$0f
                bne UL_SkipWater2
UL_ScrollWaterSub:
                jsr UL_ScrollWaterSub2
UL_ScrollWaterSub2:
                lda chars+136*8,x
                asl
                rol chars+135*8,x
                adc #$00
                sta chars+136*8,x
UL_SkipWater2:  rts

bgDelay:        dc.b 0

                org charInfo
                incbin bg/world13.chi
                incbin bg/world13.chc

                org chars
                incbin bg/world13.chr

                org charsetLoadBlockInfo
                incbin bg/world13.bli

                org charsetLoadName
                dc.b "BIO-DOME",0

                org charsetLoadWaterSplashColor
                dc.b 3                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter