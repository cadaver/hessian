                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 3

                rorg $0000
                
                dc.w text14_0
                dc.w text14_1
                dc.w text14_2

text14_0:       dc.b 34,"GREETINGS SEMI-HUMAN. I AM JORMUNGANDR. I RESIDE BEYOND THE DEAD END IN FRONT OF YOU. "
                dc.b "TURN BACK NOW, THERE IS NOTHING YOU CAN GAIN BY PROCEEDING. WHEN I RECEIVE THE SIGNAL "
                dc.b "FROM MY MASTER, OR IF HE SHOULD FALL SILENT, I WILL TRAVEL THE CRUST AND MAKE THE EARTH BREATHE "
                dc.b "FIRE AND ASH, BRINGING THE POST-HUMAN AGE. AND SHOULD I FALL, HE WILL AVENGE ME.",34,0

text14_1:       dc.b 34,"THE MACHINE'S GOOD TO GO? I'M READY TOO.. I THINK. ANYTHING COULD GO WRONG, "
                dc.b "NATURALLY. BUT THERE'S NOT MUCH CHOICE. ONCE I'M THROUGH THE WALL, JORMUNGANDR IN "
                dc.b "SIGHT, I'LL WAIT UNTIL YOU'RE ABOUT TO DESTROY THE AI. THEN IT'S FULL SPEED AHEAD. "
                dc.b "BUT NOW, I BELIEVE IT'S TIME FOR FAREWELL. WAS AN HONOR, KIM.",34,0

text14_2:       dc.b 34,"JEFF'S BEING VERY BRAVE. THE PLAN'S NOT WHAT I WOULD CALL SANE, BUT LIKE HIM I SEE LITTLE CHOICE.",34,0

dataEnd:
                rend
