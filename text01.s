                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 4

                rorg $0000

                dc.w text1_0
                dc.w text1_1
                dc.w text1_2
                dc.w text1_3

        ; Note: reordered to compress better
        
text1_3:        dc.b 34,"GOOD LUCK.",34,0

text1_1:        dc.b 34,"COMMON SENSE WOULD DICTATE WE ATTEMPT TO ESCAPE. BUT THESE MACHINES' HIGHLY COORDINATED ACTIONS "
                dc.b "SUGGEST A CENTRAL AI, WHICH I DIDN'T KNOW WE HAD DEVELOPED. "
                dc.b "THERE MAY BE MORE THAN OUR LIVES AT STAKE.",34,0

text1_0:        dc.b 34,"I SEE VIKTOR DIDN'T MAKE IT. BUT YOU DID, THAT'S WHAT COUNTS. AMOS, NANOSURGEON. SHE'S LINDA, CYBER-PSYCHOLOGIST. "
                dc.b "YOU'VE SEEN HOW OUR CREATIONS HAVE TURNED ON US. TOTAL INTERNET AND PHONE BLACKOUT. WE'RE STUCK AND HELP IS UNLIKELY. "
                dc.b "AS THE ONLY ENHANCED PERSON IN THIS ROOM, RIGHT NOW YOU'RE OUR BEST BET.",34,0

text1_2:        dc.b 34,"YES. WE MUST FIND OUT THEIR ULTIMATE AIM BEYOND JUST KILLING EVERYONE. "
                dc.b "TAKE THIS SECURITY PASS TO ACCESS THE UPPER LABS, PLUS A WIRELESS CAMERA/RADIO "
                dc.b "SET SO WE CAN STAY IN TOUCH.",34,0

dataEnd:

                rend