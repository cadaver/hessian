                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    inc bgAnimDelay
                lda bgAnimDelay
                and #$03
                bne ULSkipFlash
                ldx bgAnimIndex
                lda randomAreaStart,x
                jsr BgAnimSub
                sta chars+102*8+2
                lda randomAreaStart,x
                lsr
                lsr
                jsr BgAnimSub
                sta chars+102*8+7
                lda randomAreaStart,x
                lsr
                lsr
                lsr
                lsr
                jsr BgAnimSub
                sta chars+105*8+4
                inx
                stx bgAnimIndex
ULSkipFlash:    rts

BgAnimSub:      and #$03
                tay
                lda lightTbl,y
                rts

lightTbl:       dc.b %10101000
                dc.b %10101100
                dc.b %11101000
                dc.b %11101100

bgAnimDelay:    dc.b 0
bgAnimIndex:    dc.b 0

                org charInfo
                incbin bg/level06.chi
                incbin bg/level06.chc

                org chars
                incbin bg/level06.chr

                org lvlDataActX
                incbin bg/level06.lva

                org lvlLoadName
                dc.b "HIDEOUT",0

                org lvlLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter

                org blockInfo
                incbin bg/level06.bli
