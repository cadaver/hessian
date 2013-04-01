                include macros.s
                include mainsym.s
                
                org saveStateStart

                ds.b saveStateEnd - saveStateStart, 0
