                processor 6502

                include memory.s

                org lvlCodeStart

UpdateLevel:    inc rainDelay
                lda rainDelay
                and #$03
                bne UL_SkipRain
                lda chars+43*8+7
                pha
                ldx #$06
UL_Rain:        lda chars+43*8,x
                sta chars+43*8+1,x
                sta chars+44*8+1,x
                dex
                bpl UL_Rain
                pla
                sta chars+43*8
                sta chars+44*8
UL_SkipRain:    rts

rainDelay:      dc.b 0

                org charInfo
                incbin bg/level01.chi
                incbin bg/level01.chc

                org chars
                incbin bg/level01.chr

                org lvlDataActX
                incbin bg/level01.lva

                org lvlLoadName
                dc.b "COURTYARD",0

                org lvlLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter

                org blockInfo
                incbin bg/level01.bli
