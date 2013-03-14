                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    inc UL_RandomIndex+1
UL_RandomIndex: ldx #$00
                lda randomAreaStart,x
UL_LightOn:     ldy #$01
                beq UL_NoLight
UL_HasLight:    cmp #$c0
                bcs UL_Toggle
                rts
UL_NoLight:     cmp #$f8
                bcc UL_NoToggle
UL_Toggle:      tya
                eor #$01
                sta UL_LightOn+1
                lda chars+25*8
                eor #%10010101
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
                eor #%01010110
                sta chars+27*8
                sta chars+27*8+3
                lda chars+27*8+1
                eor #%10101001
                sta chars+27*8+1
                sta chars+27*8+2
UL_NoToggle:    rts

                org charInfo
                incbin bg/level04.chi
                incbin bg/level04.chc

                org chars
                incbin bg/level04.chr

                org lvlDataActX
                incbin bg/level04.lva

                org lvlLoadName
                dc.b "SERVICE TUNNELS",0

                org lvlLoadWaterSplashColor
                dc.b $05                        ;Water splash color override
                dc.b $10                        ;Water damage
