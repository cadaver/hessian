                include memory.s
                include mainsym.s

                org lvlCodeStart

                incbin cutscene3scr.dat

                org chars

                incbin cutscene3.chr

                org screen2

                dc.b MUSIC_OFFICES+1            ;Song to play
                dc.b 11                         ;Multicolors
                dc.b 12
                dc.w page1                      ;Pages to display (0 = end)
                dc.w 0

page1:               ;0123456789012345678901234567890123456789
                dc.b 0
                dc.b "THE TUNNEL BORING MACHINE EATS INTO THE",0
                dc.b "COLLAPSED WALL. KIM DARES NOT TO LET GO",0
                dc.b "IN CASE IT WOULD GET STUCK, AND PUSHES",0
                dc.b "ON UNTIL THERE'S LIGHT AHEAD. TOO LATE",0
                dc.b "TO BRAKE, THE MACHINE ROLLS DOWNHILL..",0
                dc.b 0
