                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    inc animDelay
                lda Irq1_Bg3+1
                cmp #$0c
                bne SkipColorAnim
                lda animDelay
                and #$1f
                tax
                lda colorTbl,x
                sta Irq1_Bg2+1
SkipColorAnim:  lda animDelay
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


colorTbl:       dc.b 2,2,2,2,8,2,8,2,8,8,8,8,12,8,12,8
                dc.b 12,12,12,12,8,12,8,12,8,8,8,8,2,8,2,8


animDelay:      dc.b 0
randomIndex:    dc.b 0

                org charInfo
                incbin bg/world07.chi
                incbin bg/world07.chc

                org chars
                incbin bg/world07.chr

                org charsetLoadProperties
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 20+$80                     ;Air toxicity delay counter ($80=not affected by filter)