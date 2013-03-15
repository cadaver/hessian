                include macros.s
                include mainsym.s
                
                org $0000
                
                ds.b saveStateEnd - saveStateStart, 0
