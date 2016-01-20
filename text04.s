                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 15

                rorg $0000

                dc.w text4_0
                dc.w text4_1
                dc.w text4_2
                dc.w text4_3
                dc.w text4_4
                dc.w text4_5
                dc.w text4_6
                dc.w text4_7
                dc.w text4_8
                dc.w text4_9
                dc.w text4_a
                dc.w text4_b
                dc.w text4_c
                dc.w text4_d
                dc.w text4_e

text4_0:        dc.b 34,"THERE YOU ARE. THE PLAN IS THIS: YOU'LL NEED A LUNG FILTER TO SURVIVE THE TUNNELS. THE OPERATING ROOM IS ON THE LOWER LABS "
                dc.b "RIGHT SIDE, AT THE VERY BOTTOM. LEAD THE WAY.",34,0

text4_1:        dc.b 34,"WE'D NEVER HAVE MADE IT ALONE. NOW WE NEED TO SET UP. WE'LL CALL YOU WHEN IT'S TIME.",34,0

text4_2:        dc.b 34,"LINDA HERE. WE GOT AHEAD OF OURSELVES - THERE ARE NO LUNG FILTERS STORED HERE. SINCE YOU'RE MUCH BETTER SUITED TO EXPLORING, "
                dc.b "WE'LL HAVE TO ASK YOU TO FIND ONE. THERE SHOULD BE AT LEAST ONE PACKAGE SOMEWHERE IN THE LOWER LABS.",34,0

text4_3:        dc.b 34,"YOU GOT THE FILTER? EXCELLENT. WE'RE READY, FOR REAL THIS TIME. THIS IS A STANDARD NANO-ASSISTED "
                dc.b "PROCEDURE WITH SOME RISK INVOLVED. THE TUNNELS BELOW SHOULD BE SURVIVABLE AFTER. "
                dc.b "STEP TO THE OPERATING TABLE WHEN YOU WISH TO PROCEED.",34,0

text4_4:        dc.b 34,"GOOD. WE WILL BEGIN. LINDA, JUST IN CASE WE GET COMPANY, THERE SHOULD BE A WEAPON IN THE CUPBOARD.",34,0

text4_5:        dc.b 34,"GOT IT.",34,0

text4_6:        dc.b 34,"MINOR COMPLICATIONS. THE NANOBOTS WILL TAKE CARE OF IT.",34,0

text4_7:        dc.b 34,"WHAT'S THAT?",34,0

text4_8:        dc.b 34,"NO! AMOS.. TOO LATE.",34,0

text4_9:        dc.b 34,"YOU OK? AMOS IS GONE, BUT WE HAVE TO GET MOVING. THERE COULD BE MORE AT ANY MOMENT.",34,0

text4_a:        dc.b 34,"DO YOU NOTICE? IT'S HARDER TO BREATHE. DAMN.. IT'S THE AI DOING THIS!",34,0

text4_b:        dc.b 34,"I CAN'T GO ON.. BUT I REMEMBER THE CODE. IT'S "
text4_c:        dc.b "000. GO!",34,0

text4_d:        dc.b 34,"JEFF HERE. AS YOU CUT OFF THE AI FROM THE SUBNETS, THE SABOTAGE MUST BE PHYSICAL, SOMEWHERE "
                dc.b "CLOSE. DON'T THINK YOU HAVE TIME TO FIX IT NOW THOUGH.",34,0

text4_e:        dc.b 34,"AIR! AT LAST. THAT WAS QUICK THINKING TO HEAD THIS WAY. THANK YOU. I'LL CATCH MY BREATH FOR A WHILE.",34,0

dataEnd:
                rend
