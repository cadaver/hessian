                processor 6502

                include memory.s
                include mainsym.s

                org lvlName
                dc.b "UNDERGROUND",0

                org lvlCodeStart

UpdateLevel:    inc UL_RandomIndex
                ldx UL_RandomIndex
                lda randomAreaStart,x
                ldy UL_LightOn
                beq UL_NoLight
UL_HasLight:    cmp #$c0
                bcs UL_Toggle
                rts
UL_NoLight:     cmp #$f8
                bcs UL_Toggle
                rts
UL_Toggle:      tya
                eor #$01
                sta UL_LightOn
                lda chars+25*8
                eor #%00010101
                sta chars+25*8
                sta chars+25*8+3
                lda chars+25*8+1
                eor #%01101010
                sta chars+25*8+1
                sta chars+25*8+2
                lda chars+26*8
                eor #%01010101
                sta chars+26*8
                sta chars+26*8+3
                lda chars+26*8+1
                eor #%10101010
                sta chars+26*8+1
                sta chars+26*8+2
                lda chars+27*8
                eor #%01010100
                sta chars+27*8
                sta chars+27*8+3
                lda chars+27*8+1
                eor #%10101001
                sta chars+27*8+1
                sta chars+27*8+2
UL_Done:        rts
UL_LightOn:     dc.b 1
UL_RandomIndex: dc.b 0

                org charInfo
                incbin bg/level04.chi
                incbin bg/level04.chc

                org chars
                incbin bg/level04.chr

                org lvlDataActX
                incbin bg/level04.lva

