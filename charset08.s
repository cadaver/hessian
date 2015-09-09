                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    inc bgAnimDelay
                lda bgAnimDelay
                tay
                and #$1f
                bne ULSkipCursor
                lda chars+166*8+6
                eor #%00100000
                sta chars+166*8+6
ULSkipCursor:   tya
                and #$07                        ;Todo: must be conditional on the generator
                bne ULSkipGenerator             ;actually being switched on
                ldx #$06
ULGeneratorLoop:lda chars+227*8,x
                asl
                adc #$00
                asl
                adc #$00
                sta chars+227*8,x
                dex
                bpl ULGeneratorLoop
ULSkipGenerator:tya
                lsr
                bcc ULSkipLaser
                lda chars+246*8+1
                eor #%01010101
                sta chars+246*8+1
                sta chars+246*8+6
ULSkipLaser:    rts

bgAnimDelay:    dc.b 0

                org charInfo
                incbin bg/world08.chi
                incbin bg/world08.chc

                org chars
                incbin bg/world08.chr

                org charsetLoadBlockInfo
                incbin bg/world08.bli

                org charsetLoadProperties
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 0                          ;Air toxicity delay counter