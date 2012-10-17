                processor 6502

                include memory.s

                org lvlActX
                incbin bg/testlev.lva

                org lvlObjX
                incbin bg/testlev.lvo
                
                org lvlSpawnT
                incbin bg/testlev.lvr

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
                incbin bg/testlev.chr
                incbin bg/testlev.chi
                incbin bg/testlev.chc


