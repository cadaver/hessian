                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    inc bgDelay
                lda bgDelay
                and #$03
                bne SkipLava1
                ldy chars+254*8+7
                ldx #$06
ScrollLava1:    lda chars+254*8,x
                sta chars+254*8+1,x
                dex
                bpl ScrollLava1
                sty chars+254*8
SkipLava1:      lda bgDelay
                and #$07
                bne SkipLava2
                ldy chars+255*8+7
                ldx #$02
ScrollLava2:    lda chars+255*8+4,x
                sta chars+255*8+5,x
                dex
                bpl ScrollLava2
                sty chars+255*8+4
SkipLava2:      rts

bgDelay:        dc.b 0

                org charInfo
                incbin bg/world11.chi
                incbin bg/world11.chc

                org chars
                incbin bg/world11.chr

                org charsetLoadBlockInfo
                incbin bg/world11.bli

                org charsetLoadName
                dc.b "NETHER TUNNEL",0

                org charsetLoadWaterSplashColor
                dc.b 7                          ;Water splash color override
                dc.b $81                        ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 20                         ;Air toxicity delay counter