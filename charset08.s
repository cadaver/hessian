                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    inc bgAnimDelay
                lda bgAnimDelay
                and #$1f
                bne ULSkipCursor
                lda chars+166*8+6
                eor #%00100000
                sta chars+166*8+6
ULSkipCursor:   rts

bgAnimDelay:    dc.b 0

                org charInfo
                incbin bg/world08.chi
                incbin bg/world08.chc

                org chars
                incbin bg/world08.chr

                org charsetLoadBlockInfo
                incbin bg/world08.bli

                org charsetLoadName
                dc.b "UPPER LABS",0

                org charsetLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter