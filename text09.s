                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 12

                rorg $0000

                dc.w text09_0
                dc.w text09_1
                dc.w text09_2
                dc.w text09_3
                dc.w text09_4
                dc.w text09_5
                dc.w text09_6
                dc.w text09_7
                dc.w text09_8
                dc.w text09_9
                dc.w text09_a
                dc.w text09_b

text09_0:       dc.b 34,"YOU GOT THE FILTER? EXCELLENT. WE'RE READY, FOR REAL THIS TIME. THIS IS A STANDARD NANO-ASSISTED "
                dc.b "PROCEDURE WITH SOME RISK INVOLVED. THE TUNNELS BELOW SHOULD BE SURVIVABLE AFTER. "
                dc.b "STEP TO THE OPERATING TABLE WHEN YOU WISH TO PROCEED.",34,0

text09_1:       dc.b 34,"GOOD. WE WILL BEGIN. LINDA, JUST IN CASE WE GET COMPANY, THERE SHOULD BE A WEAPON IN THE CUPBOARD.",34,0

text09_2:       dc.b 34,"GOT IT.",34,0

text09_3:       dc.b 34,"MINOR COMPLICATIONS. THE NANOBOTS WILL TAKE CARE OF IT.",34,0

text09_4:       dc.b 34,"WHAT'S THAT?",34,0

text09_5:       dc.b 34,"NO! AMOS.. TOO LATE.",34,0

text09_6:       dc.b 34,"YOU OK? AMOS IS GONE, BUT WE HAVE TO GET MOVING. THERE COULD BE MORE AT ANY MOMENT.",34,0

text09_7:       dc.b 34,"DO YOU NOTICE? IT'S HARDER TO BREATHE. DAMN.. IT'S THE AI DOING THIS!",34,0

text09_8:       dc.b 34,"I CAN'T GO ON.. BUT I REMEMBER THE CODE. IT'S "
text09_9:       dc.b "XXX. GO!",34,0

text09_a:       dc.b 34,"JEFF HERE. AS YOU CUT OFF THE AI FROM THE SUBNETS, THE SABOTAGE MUST BE PHYSICAL, SOMEWHERE "
                dc.b "CLOSE. DON'T THINK YOU HAVE TIME TO FIX IT NOW THOUGH.",34,0

text09_b:       dc.b 34,"AIR! AT LAST. THAT WAS QUICK THINKING TO HEAD THIS WAY. THANK YOU. I'LL CATCH MY BREATH FOR A WHILE.",34,0

dataEnd:
                rend
