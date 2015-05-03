                processor 6502

                include memory.s

                org lvlCodeStart

UpdateLevel:    ldy chars+23*8+7
                ldx #$06
UL_Loop:        lda chars+23*8,x
                sta chars+23*8+1,x
                dex
                bpl UL_Loop
                sty chars+23*8
                rts

                org charInfo
                incbin bg/level02.chi
                incbin bg/level02.chc

                org chars
                incbin bg/level02.chr

                org lvlDataActX
                incbin bg/level02.lva

                org lvlLoadName
                dc.b "TESTING",0

                org lvlLoadWaterDamage
                dc.b 0                          ;Water damage

                org blockInfo
                incbin bg/level02.bli