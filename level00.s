                processor 6502

                include memory.s
                include mainsym.s

                org lvlObjX
                incbin bg/world00.lvo

                org lvlName
                dc.b "TEST 1",0

                org lvlWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter