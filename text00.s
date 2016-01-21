                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 6

                rorg $0000

                dc.w text0_0
                dc.w text0_1
                dc.w text0_2
                dc.w text0_3
                dc.w text0_4
                dc.w text0_5

text0_0:        dc.b 34,"GOOD, YOU'RE ON YOUR FEET. I'M VIKTOR - WE NEED TO REACH THE OTHERS, WHO ARE HOLED UP ON THE PARKING GARAGE BOTTOM LEVEL. FOLLOW ME.",34,0

text0_1:        dc.b 34,"ARGH, I'M NO GOOD TO GO ON. SEARCH THE UPSTAIRS - YOU'LL NEED A PASSCARD WE USED TO LOCK UP THIS PLACE. "
                dc.b "WATCH OUT FOR MORE OF THOSE BASTARDS.. AND ONE FINAL THING - THE NANOBOTS RUNNING YOUR BODY DEPEND ON BATTERY POWER. "
                dc.b "DON'T RUN OUT.",34,0

text0_2:        dc.b 34,"I SEE VIKTOR DIDN'T MAKE IT. BUT YOU DID, THAT'S WHAT COUNTS. AMOS, NANOSURGEON. SHE'S LINDA, CYBER-PSYCHOLOGIST. "
                dc.b "YOU'VE SEEN HOW OUR CREATIONS HAVE TURNED ON US. TOTAL INTERNET AND PHONE BLACKOUT. WE'RE STUCK AND HELP IS UNLIKELY. "
                dc.b "AS THE ONLY ENHANCED PERSON IN THIS ROOM, RIGHT NOW YOU'RE OUR BEST BET.",34,0

text0_3:        dc.b 34,"COMMON SENSE WOULD DICTATE WE ATTEMPT TO ESCAPE. BUT THESE MACHINES' HIGHLY COORDINATED ACTIONS "
                dc.b "SUGGEST A CENTRAL AI, WHICH I DIDN'T KNOW WE HAD DEVELOPED. "
                dc.b "THERE MAY BE MORE THAN OUR LIVES AT STAKE.",34,0

text0_4:        dc.b 34,"YES. WE MUST FIND OUT THEIR ULTIMATE AIM BEYOND JUST KILLING EVERYONE. "
                dc.b "TAKE THIS SECURITY PASS TO ACCESS THE UPPER LABS, PLUS A WIRELESS CAMERA/RADIO "
                dc.b "SET SO WE CAN STAY IN TOUCH.",34,0

text0_5:        dc.b 34,"GOOD LUCK.",34,0

dataEnd:

                rend