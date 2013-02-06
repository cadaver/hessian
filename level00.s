                processor 6502

                include memory.s

                org lvlObjX
                incbin bg/level00.lvo
                
                org lvlSpawnT
                incbin bg/level00.lvr

                org lvlName
                dc.b "GHOST SHIP",0

                org lvlCodeStart

InitLevel:      jmp DoNothing

UpdateLevel:    
DoNothing:      rts

                org charInfo
                incbin bg/level00.chi
                incbin bg/level00.chc
                
                org chars
                incbin bg/level00.chr



