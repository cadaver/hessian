                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    ldy chars+101*8+7
                ldx #$06
UL_WaterLoop:   lda chars+101*8,x
                sta chars+101*8+1,x
                dex
                bpl UL_WaterLoop
                sty chars+101*8
                lda chars+101*8+7
                and #%11111100
                sta chars+102*8+7
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
                lda chars+104*8,x
                asl
                rol chars+103*8,x
                adc #$00
                sta chars+104*8,x
UL_SkipWater2:  rts

bgDelay:        dc.b 0

                org charInfo
                incbin bg/world09.chi
                incbin bg/world09.chc

                org chars
                incbin bg/world09.chr

                org charsetLoadProperties
                dc.b 3                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter