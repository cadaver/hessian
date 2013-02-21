                processor 6502

                include memory.s
                include mainsym.s

                org lvlName
                dc.b "UNDERGROUND",0

                org lvlCodeStart

UpdateLevel:    inc UL_Delay+1
UL_Delay:       lda #$00
                tay
                and #$07
                bne UL_NoWaterAnim
                ldx #$07
UL_WaterLoop:   lda chars+28*8,x
                asl
                adc #$00
                asl
                adc #$00
                sta chars+28*8,x
                dex
                bne UL_WaterLoop
UL_NoWaterAnim: inc UL_RandomIndex+1
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
                ldx #0
                jsr UL_ToggleSub
                ldx #8
                jsr UL_ToggleSub
                ldx #16
UL_ToggleSub:   ldy #3
UL_ToggleLoop:  lda chars+25*8,x
                pha
                lda chars+50*8,x
                sta chars+25*8,x
                pla
                sta chars+50*8,x
                inx
                dey
                bpl UL_ToggleLoop
UL_NoToggle:    rts

                org lvlWaterSplashColor
                dc.b $05                        ;Water splash color override
                dc.b $08                        ;Water damage

                org charInfo
                incbin bg/level04.chi
                incbin bg/level04.chc

                org chars
                incbin bg/level04.chr

                org lvlDataActX
                incbin bg/level04.lva

