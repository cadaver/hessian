                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    inc bgDelay
                lda bgDelay
                and #$07
                bne UL_SkipWater1
                ldx #$00
                jsr UL_ScrollWaterSub
                ldy chars+102*8
UL_ScrollBubbles:
                lda chars+102*8+1,x
                sta chars+102*8,x
                inx
                cpx #$06
                bcc UL_ScrollBubbles
                sty chars+102*8+6
UL_SkipWater1:  lda bgDelay
                and #$0f
                bne UL_SkipWater2
                ldx #$02
                jsr UL_ScrollWaterSub
UL_SkipWater2:  rts

UL_ScrollWaterSub:
                lda chars+101*8,x
                asl
                rol chars+100*8,x
                adc #$00
                asl
                rol chars+100*8,x
                adc #$00
                sta chars+101*8,x
                lda chars+100*8,x
                sta chars+103*8,x
                rts

bgDelay:        dc.b 0


                org charInfo
                incbin bg/world10.chi
                incbin bg/world10.chc

                org chars
                incbin bg/world10.chr

                org charsetLoadBlockInfo
                incbin bg/world10.bli

                org charsetLoadName
                dc.b "LOWER LABS",0

                org charsetLoadWaterSplashColor
                dc.b 5                          ;Water splash color override
                dc.b 20                         ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter + $80 parallax flag