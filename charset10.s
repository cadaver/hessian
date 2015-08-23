                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    inc bgDelay
                lda bgDelay
                tay
                and #$07
                bne UL_SkipWater1
                tax
                jsr UL_ScrollWaterSub
                lda chars+102*8
                pha
UL_ScrollBubbles:
                lda chars+102*8+1,x
                sta chars+102*8,x
                inx
                cpx #$06
                bcc UL_ScrollBubbles
                pla
                sta chars+102*8+6
UL_SkipWater1:  tya
                and #$0f
                bne UL_SkipWater2
                ldx #$02
                jsr UL_ScrollWaterSub
UL_SkipWater2:  tya
                and #$1f
                bne ULSkipCursor
                lda chars+178*8+6
                eor #%00100000
                sta chars+178*8+6
ULSkipCursor:   tya
                and #$03
                bne ULSkipLights
                tax
                inc ULRandom+1
ULRandom:       lda randomAreaStart
                pha
                jsr ULLightSub
                pla
                lsr
                lsr
                pha
                ldx #$08
                jsr ULLightSub
                pla
                lsr
                lsr
                ldx #$10
ULLightSub:     and #$03
                tay
                lda lightTbl,y
                sta chars+238*8+2,x
ULSkipLights:   rts

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

lightTbl:       dc.b %00010001
                dc.b %00010011
                dc.b %00110001
                dc.b %00110011

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
                dc.b 25                         ;Air toxicity delay counter + $80 parallax flag