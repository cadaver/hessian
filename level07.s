                processor 6502

                include memory.s

                org lvlCodeStart

UpdateLevel:    rts

                org charInfo
                incbin bg/level07.chi
                incbin bg/level07.chc

                org chars
                incbin bg/level07.chr

                org lvlDataActX
                incbin bg/level07.lva

                org lvlLoadName
                dc.b "METROPOL INSIDE",0

                org lvlLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water damage
