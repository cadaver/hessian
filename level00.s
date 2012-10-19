                processor 6502

                include memory.s

                org lvlActX
                incbin bg/level00.lva

                org lvlObjX
                incbin bg/level00.lvo
                
                org lvlSpawnT
                incbin bg/level00.lvr

                org lvlCodeStart
                
InitLevel:      jmp DoNothing

UpdateLevel:    ldx #$06
                ldy chars+54*8+7
UL_Loop:        lda chars+54*8,x
                sta chars+54*8+1,x
                dex
                bpl UL_Loop
                sty chars+54*8
DoNothing:      rts

                org chars
                incbin bg/level00.chr
                incbin bg/level00.chi
                incbin bg/level00.chc


