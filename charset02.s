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
                sta chars+225*8+2
                lda randomAreaStart,x
                lsr
                lsr
                jsr BgAnimSub
                sta chars+226*8+2
                lda randomAreaStart,x
                lsr
                lsr
                lsr
                lsr
                jsr BgAnimSub
                sta chars+227*8+2
                inx
                stx bgAnimIndex
ULSkipFlash:    lda bgAnimDelay
                and #$1f
                bne ULSkipCursor
                lda chars+235*8+2
                eor #%00100000
                sta chars+235*8+2
ULSkipCursor:   rts

BgAnimSub:      and #$03
                tay
                lda lightTbl,y
                rts

lightTbl:       dc.b %00010001
                dc.b %00010011
                dc.b %00110001
                dc.b %00110011

bgAnimDelay:    dc.b 0
bgAnimIndex:    dc.b 0

                org charInfo
                incbin bg/world02.chi
                incbin bg/world02.chc

                org chars
                incbin bg/world02.chr

                org charsetLoadBlockInfo
                incbin bg/world02.bli

                org charsetLoadProperties
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter