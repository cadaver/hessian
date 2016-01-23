                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 3

                rorg $0000

                dc.w text0_0
                dc.w text0_1
                dc.w text0_2

text0_0:        dc.b 34,"GOOD, YOU'RE ON YOUR FEET. I'M VIKTOR - WE NEED TO REACH THE OTHERS, WHO ARE HOLED UP ON THE PARKING GARAGE BOTTOM LEVEL. FOLLOW ME.",34,0

text0_1:        dc.b 34,"ARGH, I'M NO GOOD TO GO ON. SEARCH THE UPSTAIRS - YOU'LL NEED A PASSCARD WE USED TO LOCK UP THIS PLACE. "
                dc.b "WATCH OUT FOR MORE OF THOSE BASTARDS.. AND ONE FINAL THING - THE NANOBOTS RUNNING YOUR BODY DEPEND ON BATTERY POWER. "
                dc.b "DON'T RUN OUT.",34,0

text0_2:        dc.b 34,"IT'S AMOS. GOOD THINKING, THE ARMORY SHOULD HOLD POWERFUL WEAPONRY. STAY ALERT THOUGH, "
                dc.b "ANY GUARDS INSIDE MAY THINK YOU'VE GONE ROGUE. OR THE WORSE OPTION, THAT THEY'RE SOMEHOW "
                dc.b "COMPLICIT.",34,0

dataEnd:

                rend