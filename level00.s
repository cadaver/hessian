                processor 6502

                include memory.s

                org lvlObjX
                incbin bg/level00.lvo

                org lvlSpawnT
                incbin bg/level00.lvr

                org lvlCodeStart

UpdateLevel:    inc UL_Delay+1
UL_Delay:       lda #$00
                and #$03
                bne UL_NoWaterAnim
                ldx #$00
UL_WaterLoop:   lda chars+78*8,x
                asl
                rol chars+77*8,x
                adc #$00
                asl
                rol chars+77*8,x
                adc #$00
                sta chars+78*8,x
                inx
                cpx #$08
                bcc UL_WaterLoop
UL_NoWaterAnim: lda UL_Delay+1
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

                org charInfo
                incbin bg/level00.chi
                incbin bg/level00.chc

                org chars
                incbin bg/level00.chr

                org lvlName
                dc.b "GHOST SHIP",0
