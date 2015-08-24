                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    rts

                org charInfo
                incbin bg/world11.chi
                incbin bg/world11.chc

                org chars
                incbin bg/world11.chr

                org charsetLoadBlockInfo
                incbin bg/world11.bli

                org charsetLoadName
                dc.b "NETHER TUNNEL",0

                org charsetLoadWaterSplashColor
                dc.b 7                          ;Water splash color override
                dc.b $81                        ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 25                         ;Air toxicity delay counter + $80 parallax flag