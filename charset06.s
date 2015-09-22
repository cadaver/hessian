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
                sta chars+96*8+5
                lda randomAreaStart,x
                lsr
                lsr
                jsr BgAnimSub
                sta chars+99*8+1
                lda randomAreaStart,x
                lsr
                lsr
                lsr
                lsr
                jsr BgAnimSub
                sta chars+99*8+5
                inx
                stx bgAnimIndex
ULSkipFlash:    rts

BgAnimSub:      and #$03
                tay
                lda lightTbl,y
                rts

lightTbl:       dc.b %01010110
                dc.b %01011110
                dc.b %11010110
                dc.b %11011110

bgAnimDelay:    dc.b 0
bgAnimIndex:    dc.b 0

                org charInfo
                incbin bg/world06.chi
                incbin bg/world06.chc

                org chars
                incbin bg/world06.chr

                org charsetLoadProperties
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter
