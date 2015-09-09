                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    lda chars+247*8
                eor #%00111100
                sta chars+247*8
                sta chars+247*8+7
                lda chars+247*8+2
                eor #%11000011
                sta chars+247*8+2
                sta chars+247*8+5
                rts

                org charInfo
                incbin bg/world13.chi
                incbin bg/world13.chc

                org chars
                incbin bg/world13.chr

                org charsetLoadBlockInfo
                incbin bg/world13.bli

                org charsetLoadProperties
                dc.b 3                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter