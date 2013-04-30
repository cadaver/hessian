                include macros.s
                include mainsym.s

                org $0000

                ds.b MAX_SAVES*SAVEDESCSIZE,0

