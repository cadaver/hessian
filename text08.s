                processor 6502
                org $0000

                dc.w dataEnd
                dc.b 2

                rorg $0000

                dc.w text8_0
                dc.w text8_1

text8_1:        dc.b 34,"LINDA HERE. WE GOT AHEAD OF OURSELVES - THERE'S NO LUNG FILTERS STORED IN HERE. AMOS IS QUITE ANGRY WITH HIMSELF. "
                dc.b "SINCE YOU'RE MUCH BETTER SUITED TO EXPLORING, "
                dc.b "WE'LL HAVE TO ASK YOU TO FIND ONE. THERE SHOULD BE AT LEAST ONE PACKAGE IN THE LOWER LABS SOMEWHERE.",34,0

text8_0:        dc.b 34,"WE'D NEVER HAVE MADE IT ALONE. NOW WE NEED TIME TO SET UP. WE'LL GIVE YOU A CALL WHEN READY.",34,0

dataEnd:
                rend
