                processor 6502

                include memory.s

                org lvlName
                dc.b "UPPER METROPOL",0

                org lvlCodeStart

UpdateLevel:    rts

                org charInfo
                incbin bg/level03.chi
                incbin bg/level03.chc

                org chars
                incbin bg/level03.chr

                org lvlDataActX
                incbin bg/level03.lva

