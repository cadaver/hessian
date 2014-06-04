                processor 6502

                include memory.s

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
UL_NoWaterAnim2:tya
                and #$01
                beq UL_NoRainAnim
                ldx #$06
                lda chars+112*8+7
                pha
                lda chars+113*8+7
                pha
UL_RainLoop:    lda chars+112*8,x
                sta chars+112*8+1,x
                lda chars+113*8,x
                sta chars+113*8+1,x
                dex
                bpl UL_RainLoop
                pla
                sta chars+113*8
                pla
                sta chars+112*8
UL_NoRainAnim:  rts

UL_WaterSub:    sta UL_WaterCmp+1
UL_WaterLoop:   lda chars+78*8,x
                asl
                rol chars+77*8,x
                adc #$00
                asl
                rol chars+77*8,x
                adc #$00
                sta chars+78*8,x
                inx
UL_WaterCmp:    cpx #$00
                bcc UL_WaterLoop
                rts

                org charInfo
                incbin bg/level00.chi
                incbin bg/level00.chc

                org chars
                incbin bg/level00.chr

                org lvlDataActX
                incbin bg/level00.lva

                org lvlLoadName
                dc.b "CARGO SHIP",0

                org lvlLoadWaterDamage
                dc.b 0                          ;Water damage
                dc.b 0                          ;Water splash color override

                org blockInfo
                incbin bg/level00.bli
