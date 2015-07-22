                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    rts

                org charInfo
                incbin bg/world03.chi
                incbin bg/world03.chc

                org chars
                incbin bg/world03.chr

                org charsetLoadBlockInfo
                incbin bg/world03.bli

                org charsetLoadName
                dc.b "CAR PARK",0

                org charsetLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter