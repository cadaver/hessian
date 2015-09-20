                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    lda elevatorCounter
                clc
                adc elevatorSpeed
UL_ScrollLoop:  sta elevatorCounter
                bmi UL_ScrollUp
                cmp #$20
                bcs UL_ScrollDown
                rts
UL_ScrollUp:    clc
                adc #$20
                pha
                ldy chars+251*8+15
                ldx #14
UL_ScrollUpLoop:lda chars+251*8,x
                sta chars+251*8+1,x
                dex
                bpl UL_ScrollUpLoop
                sty chars+251*8
UL_ScrollEndCommon:
                pla
                jmp UL_ScrollLoop
UL_ScrollDown:  sbc #$20
                pha
                ldy chars+251*8
                ldx #0
UL_ScrollDownLoop:
                lda chars+251*8+1,x
                sta chars+251*8,x
                inx
                cpx #15
                bcc UL_ScrollDownLoop
                sty chars+251*8+15
                bcs UL_ScrollEndCommon

                org charInfo-2
elevatorCounter:dc.b $10
elevatorSpeed:  dc.b 0

                org charInfo
                incbin bg/world12.chi
                incbin bg/world12.chc

                org chars
                incbin bg/world12.chr

                org charsetLoadBlockInfo
                incbin bg/world12.bli

                org charsetLoadProperties
                dc.b 0                          ;Water splash color override
                dc.b 0                          ;Water toxicity delay counter ($80=not affected by filter)
                dc.b 20                         ;Air toxicity delay counter