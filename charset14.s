                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    rts

                org charInfo
                incbin bg/world14.chi
                incbin bg/world14.chc

                org chars
                incbin bg/world14.chr

                org charsetLoadProperties
                dc.b 3                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter