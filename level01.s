                processor 6502

                include memory.s

                org lvlActX
                incbin bg/level01.lva

                org lvlObjX
                incbin bg/level01.lvo

                org lvlSpawnT
                incbin bg/level01.lvr

                org lvlCodeStart

InitLevel:      jmp DoNothing

UpdateLevel:    
DoNothing:      rts

                org chars
                incbin bg/level01.chr
                incbin bg/level01.chi
                incbin bg/level01.chc


