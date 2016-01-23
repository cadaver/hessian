                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 3

                rorg $0000

                dc.w text2_0
                dc.w text2_1
                dc.w text2_2

text2_0:        dc.b 34,"AMOS HERE. YOU'RE CLOSE TO THE UPPER LABS. SEE IF YOU CAN FIND ANY CLUES. "
                dc.b "IF NOT, YOU'LL HAVE TO PUSH ON TO THE HIGH-CLEARANCE LOWER LABS. "
                dc.b "ALSO LOOK FOR CODE-LOCKED ROOMS, WHICH WERE USED FOR NANOBOT RESEARCH AS PART "
                dc.b "OF THE 'HESSIAN' MILITARY CONTRACT. FIND THE ENTRY CODES, AND YOU CAN UPGRADE "
                dc.b "YOUR ABILITIES. UPGRADES WILL CONSUME MORE POWER, THOUGH.",34,0

text2_1:        dc.b 34,"AMOS HERE AGAIN. YOU NEED A WAY AROUND. "
                dc.b "THE LASER IN THE BASEMENT MIGHT CUT THROUGH THE WALL, IF ITS POWER IS BOOSTED. "
                dc.b "OUR IT SPECIALIST JEFF COULD HAVE IDEAS. HE'S GOT A PRIVATE HIDEOUT "
                dc.b "IN THE SERVICE TUNNELS. JUST WATCH OUT, HE'S A BIT STRANGE.",34,0

text2_2:        dc.b 34,"SEARCH THE ENTRANCE OFFICES FOR THE SERVICE PASS.",34,0

dataEnd:

                rend