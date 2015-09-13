                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    inc animDelay
                lda animDelay
                and #$07
                bne SkipMonitor
                ldx #$00
ScrollMonitor:  lda chars+216*8+1,x
                sta chars+216*8,x
                lda chars+217*8+1,x
                sta chars+217*8,x
                inx
                cpx #$07
                bcc ScrollMonitor
                lda animDelay
                and #$08
                beq EmptyRow
                inc randomIndex
                ldx randomIndex
                lda randomAreaStart,x
                ora #%10101010
                sta chars+216*8+7
                lda randomAreaStart+$100,x
                ora #%10101010
                sta chars+217*8+7
SkipMonitor:    rts
EmptyRow:       lda #$ff
                sta chars+216*8+7
                sta chars+217*8+7
                rts

animDelay:      dc.b 0
randomIndex:    dc.b 0

                org charInfo
                incbin bg/world07.chi
                incbin bg/world07.chc

                org chars
                incbin bg/world07.chr

                org charsetLoadBlockInfo
                incbin bg/world07.bli

                org charsetLoadProperties
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 25                         ;Air toxicity delay counter