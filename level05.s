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
                lda chars+25*8,x
                eor eorValue1Tbl,y
                sta chars+25*8,x
                sta chars+25*8+3,x
                lda chars+25*8+1,x
                eor eorValue2Tbl,y
                sta chars+25*8+1,x
                sta chars+25*8+2,x
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
eorValue1Tbl:   dc.b %10010101,%01010101,%01010110
eorValue2Tbl:   dc.b %01101010,%10101010,%10101001

waterTbl1:      dc.b %00010101,%01000101,%00010001,%01010100,%01010001
waterTbl2:      dc.b %00001010,%00101000,%10100000,%10000010,%00001000
waterTbl3:      dc.b %01111111,%11111101,%01111101,%11110111

                org charInfo
                incbin bg/level05.chi
                incbin bg/level05.chc

                org chars
                incbin bg/level05.chr

                org lvlDataActX
                incbin bg/level05.lva

                org lvlLoadName
                dc.b "SERVICE TUNNELS",0

                org lvlLoadWaterSplashColor
                dc.b 15                         ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter

                org blockInfo
                incbin bg/level05.bli
