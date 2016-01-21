                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 7

                rorg $0000

                dc.w text1_0
                dc.w text1_1
                dc.w text1_2
                dc.w text1_3
                dc.w text1_4
                dc.w text1_5
                dc.w text1_6

text1_0:        dc.b 34,"AMOS HERE. YOU'RE CLOSE TO THE UPPER LABS. SEE IF YOU CAN FIND ANY CLUES. "
                dc.b "IF NOT, YOU'LL HAVE TO PUSH ON TO THE HIGH-CLEARANCE LOWER LABS. "
                dc.b "ALSO LOOK FOR CODE-LOCKED ROOMS, WHICH WERE USED FOR NANOBOT UPGRADE RESEARCH AS PART "
                dc.b "OF THE 'HESSIAN' MILITARY CONTRACT. FIND THE ENTRY CODES, AND YOU CAN IMPROVE "
                dc.b "YOUR ABILITIES, AT THE COST OF FASTER BATTERY DRAIN.",34,0

text1_1:        dc.b 34,"IT'S AMOS. GOOD THINKING, THE ARMORY SHOULD HOLD POWERFUL WEAPONRY. STAY ALERT THOUGH, "
                dc.b "ANY GUARDS INSIDE MAY THINK YOU'VE GONE ROGUE. OR THE WORSE OPTION, THAT THEY'RE SOMEHOW "
                dc.b "COMPLICIT.",34,0

text1_2:        dc.b 34,"AMOS HERE AGAIN. YOU NEED A WAY AROUND. "
                dc.b "THE LASER IN THE BASEMENT MIGHT CUT THROUGH THE WALL, IF ITS POWER IS BOOSTED. "
                dc.b "OUR IT SPECIALIST JEFF COULD HAVE IDEAS. HE'S GOT A PRIVATE HIDEOUT "
                dc.b "IN THE SERVICE TUNNELS. JUST WATCH OUT, HE'S A BIT STRANGE.",34,0

text1_3:        dc.b 34,"SEARCH THE ENTRANCE OFFICES FOR THE SERVICE PASS.",34,0

text1_4:        dc.b 34,"HEY. YOU MUST BE KIM. THE SCIENTISTS TOLD YOU MIGHT DROP BY. "
                dc.b "I'M JEFF. SORRY ABOUT THAT SENTRY DRONE, HAD TO MAKE SURE YOU'RE NOT A MACHINE. "
                dc.b "I'D ESTIMATE YOUR FIGHTING STYLE AS "
text1_5:        dc.b "X5% HUMAN. YOU CAME FOR THAT SIGNAL AMP FOR THE LASER, RIGHT? "
                dc.b "NEVER TESTED IT SO CAN'T BE SURE WHAT HAPPENS WHEN YOU PLUG IT IN. OH, FEEL FREE TO USE THE RECYCLER "
                dc.b "AT THE BACK. BUT DON'T TOUCH ANYTHING ELSE.",34,0

text1_6:        dc.b 34,"IT'S A MESSED UP SITUATION ALL RIGHT. BUT WITH WHAT WE'RE DOING, "
                dc.b "IT WAS BOUND TO HAPPEN SOONER OR LATER.",34,0

dataEnd:

                rend