                processor 6502

                include memory.s

                org lvlActX
                incbin bg/testlev.lva

                org lvlCodeStart
                
InitLevel:      jmp DoNothing

UpdateLevel:    ldx #$06
                ldy chars+128*8+7
UL_Loop:        lda chars+128*8,x
                sta chars+128*8+1,x
                dex
                bpl UL_Loop
                sty chars+128*8
DoNothing:      rts

                org chars
                incbin bg/testlev.chr
                incbin bg/testlev.chi
                incbin bg/testlev.chc


