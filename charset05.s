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
                lda waterTbl1,x
                sta chars+228*8
                lda waterTbl1+1,x
                sta chars+229*8
                lda waterTbl2,x
                sta chars+228*8+2
                sta chars+230*8+3
                lda waterTbl2+1,x
                sta chars+229*8+2
                lda waterTbl3,x
                sta chars+230*8
                inx
                txa
                and #$03
                sta UL_NoLightAnim+1
UL_NoAnim:      rts

charOffsetTbl:  dc.b 0,8,16
eorValue1Tbl:   dc.b %01101010,%10101010,%10101001
eorValue2Tbl:   dc.b %10010101,%01010101,%01010110

waterTbl1:      dc.b %00101010,%10001010,%00100010,%10101000,%10100010
waterTbl2:      dc.b %00000101,%00010100,%01010000,%01000001,%00000100
waterTbl3:      dc.b %10111111,%11111110,%01111110,%11111011

                org charInfo
                incbin bg/world05.chi
                incbin bg/world05.chc

                org chars
                incbin bg/world05.chr

                org charsetLoadBlockInfo
                incbin bg/world05.bli

                org charsetLoadName
                dc.b "SERVICE TUNNELS",0

                org charsetLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter