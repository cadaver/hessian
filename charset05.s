                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    inc UL_Delay+1
UL_Delay:       lda #$00
                and #$07
                bne UL_NoAnim
UL_GetRandom:   lda randomAreaStart
                inc UL_GetRandom+1
                ldy #$00
                cmp #$02
                bcc UL_LightOff
                iny
UL_LightOff:
UL_LightState:  cpy #$01
                beq UL_NoLightAnim
                sty UL_LightState+1
                ldy #2
UL_ToggleLightLoop:
                ldx charOffsetTbl,y
                lda chars+25*8+4,x
                eor eorValue1Tbl,y
                sta chars+25*8+4,x
                sta chars+25*8+7,x
                lda chars+25*8+5,x
                eor eorValue2Tbl,y
                sta chars+25*8+5,x
                sta chars+25*8+6,x
                dey
                bpl UL_ToggleLightLoop
UL_NoLightAnim: ldx #$00
                jsr UL_ScrollWaterSub
                lsr
                ora chars+228*8,x
                ora #$aa
                sta chars+230*8,x
                ldx #$02
                lda UL_Delay+1
                and #$0f
                bne UL_SkipWater2
                jsr UL_ScrollWaterSub
                sta chars+230*8+1,x
UL_SkipWater2:
UL_NoAnim:      rts

UL_ScrollWaterSub:
                lda chars+229*8,x
                asl
                rol chars+228*8,x
                adc #$00
                asl
                rol chars+228*8,x
                adc #$00
                sta chars+229*8,x
                lda chars+228*8,x
                rts

charOffsetTbl:  dc.b 0,8,16
eorValue1Tbl:   dc.b %01101010,%10101010,%10101001
eorValue2Tbl:   dc.b %10010101,%01010101,%01010110

                org charInfo
                incbin bg/world05.chi
                incbin bg/world05.chc

                org chars
                incbin bg/world05.chr

                org charsetLoadProperties
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter