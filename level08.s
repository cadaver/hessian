                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    rts

                org charInfo
                incbin bg/level08.chi
                incbin bg/level08.chc

                org chars
                incbin bg/level08.chr

                org lvlDataActX
                incbin bg/level08.lva

                org lvlLoadName
                dc.b "UPPER LABS",0

                org lvlLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter

                org blockInfo
                incbin bg/level08.bli
