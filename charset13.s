                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    rts

                org charInfo
                incbin bg/world13.chi
                incbin bg/world13.chc

                org chars
                incbin bg/world13.chr

                org charsetLoadBlockInfo
                incbin bg/world13.bli

                org charsetLoadName
                dc.b "BIO-DOME",0

                org charsetLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                         ;Air toxicity delay counter + $80 parallax flag