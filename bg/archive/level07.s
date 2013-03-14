                processor 6502

                include memory.s
                include mainSym.s

                org lvlCodeStart

UpdateLevel:    inc UL_Delay+1
UL_Delay:       lda #$00
                and #$03
                bne UL_Skip
                inc UL_RandomIndex+1
UL_RandomIndex: ldx #$00
                lda randomAreaStart,x
                and #$03
                tay
                lda bitTbl,y
                sta chars+210*8+2
                lda randomAreaStart+$100,x
                and #$03
                tay
                lda bitTbl,y
                sta chars+210*8+7
                lda randomAreaStart+$200,x
                and #$03
                tay
                lda bitTbl,y
                sta chars+213*8+4
UL_Skip:        rts

bitTbl:         dc.b %10101000
                dc.b %10101100
                dc.b %11101000
                dc.b %11101100

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
