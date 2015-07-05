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
                lda chars+235*8+3
                eor #%00100000
                sta chars+235*8+3
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
                incbin bg/level02.chi
                incbin bg/level02.chc

                org chars
                incbin bg/level02.chr

                org lvlDataActX
                incbin bg/level02.lva

                org lvlLoadName
                dc.b "ENTRANCE",0

                org lvlLoadWaterSplashColor
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter

                org blockInfo
                incbin bg/level02.bli
