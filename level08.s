                processor 6502

                include memory.s
                include mainSym.s

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
                dc.b "METROPOL INSIDE",0

                org lvlLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water damage
