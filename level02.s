                processor 6502

                include memory.s

                org lvlName
                dc.b "LOWER METROPOL",0

                org lvlCodeStart

UpdateLevel:    inc UL_Delay+1
UL_Delay:       lda #$00
                tay
                and #$03
                bne UL_NoWaterAnim1
                ldx #$00
                lda #$03
                jsr UL_WaterSub
UL_NoWaterAnim1:tya
                and #$07
                bne UL_NoWaterAnim2
                ldx #$04
                lda #$07
                jsr UL_WaterSub
UL_NoWaterAnim2:rts

UL_WaterSub:    sta UL_WaterCmp+1
UL_WaterLoop:   lda chars+7*8,x
                lsr
                ror chars+8*8,x
                bcc UL_WaterNoMSB
                ora #$80
UL_WaterNoMSB:  lsr
                ror chars+8*8,x
                bcc UL_WaterNoMSB2
                ora #$80
UL_WaterNoMSB2: sta chars+7*8,x
                inx
UL_WaterCmp:    cpx #$00
                bcc UL_WaterLoop
                rts

                org charInfo
                incbin bg/level02.chi
                incbin bg/level02.chc

                org chars
                incbin bg/level02.chr

                org lvlDataActX
                incbin bg/level02.lva

