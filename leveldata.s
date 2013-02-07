        ; This file is programmatically generated from leveldata (countobj utility)

                include levelactors.s

        ; Check for size exceeded. The game start script does not handle
        ; more than 255 bytes for the bitarea

                if LVLDATAACTTOTALSIZE > 255
                    err
                endif