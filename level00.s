                processor 6502

                include memory.s

                org lvlCodeStart

UpdateLevel:    ldx #3
UL_Light:       lda chars+75*8+1,x
                eor #%00010100
                sta chars+75*8+1,x
                sta chars+76*8+1,x
                dex
                bpl UL_Light
                rts

                org charInfo
                incbin bg/level00.chi
                incbin bg/level00.chc

                org chars
                incbin bg/level00.chr

                org lvlDataActX
                incbin bg/level00.lva

                org lvlLoadName
                dc.b "STORAGE",0

                org lvlLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter

                org blockInfo
                incbin bg/level00.bli
