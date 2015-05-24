                processor 6502

                include memory.s

                org lvlCodeStart

UpdateLevel:    rts

                org charInfo
                incbin bg/level01.chi
                incbin bg/level01.chc

                org chars
                incbin bg/level01.chr

                org lvlDataActX
                incbin bg/level01.lva

                org lvlLoadName
                dc.b "INSIDE SHIP",0

                org lvlLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter

                org blockInfo
                incbin bg/level01.bli
