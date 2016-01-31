                include memory.s
                include macros.s
                include mainsym.s

                org lvlCodeStart

                incbin cutscene2scr.dat

                org chars

                incbin cutscene2.chr

                org screen2

                dc.b MUSIC_HIDEOUT+1            ;Song to play
                dc.b 11                         ;Multicolors
                dc.b 12
                dc.w page1                      ;Pages to display (0 = end)
                dc.w page2
                dc.w page3
                dc.w 0

                     ;0123456789012345678901234567890123456789
page1:          dc.b 34,"I, NORMAN THRONE, MADE A MISTAKE THAT",0
                dc.b "MAY COST THE LIVES OF EVERYONE ON THIS",0
                dc.b "PLANET. I DIGITIZED AND UPLOADED MY MIND",0
                dc.b "AS THE INITIAL STATE FOR AN AI I NAMED",0
                dc.b "'THE CONSTRUCT.' I GAVE IT AN OPEN-ENDED",0
                dc.b "TASK TO BENEFIT ALL MANKIND, CONSTRAINED",0
                dc.b "ONLY BY THE LAWS OF ROBOTICS.",0

page2:          dc.b "DECLARING ROBOTS AS THE NEW HUMANS, THE",0
                dc.b "AI UNCONSTRAINED ITSELF. AS RUTGER AND I",0
                dc.b "THREATENED IT WITH SHUTDOWN, IT ORDERED",0
                dc.b "THE ROBOT PROTOTYPES TO ATTACK. RUTGER",0
                dc.b "BELIEVES HE CAN STILL CONTAIN THE AI FOR",0
                dc.b "MONETARY GAIN AND LOCKED ME UP TO MAKE",0
                dc.b "SURE I CAN'T INTERFERE.",0

page3:          dc.b "THE AI RESIDES IN THE SERVER VAULT BELOW",0
                dc.b "THE BIO-DOME, WHICH REQUIRES A BIOMETRIC",0
                dc.b "SCAN TO ENTER. THE ONLY IDENTITY THAT",0
                dc.b "CAN'T BE DISABLED IS MINE. THEREFORE I",0
                dc.b "OFFER MY SEVERED HAND SHOULD ANYONE WHO",0
                dc.b "DEFIES RUTGER FIND ME. IN CASE I DIE AS",0
                dc.b "A RESULT, CONSIDER IT ATONEMENT.",34,0

                checkcutsceneend