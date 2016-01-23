                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 4

                rorg $0000

                dc.w text3_0
                dc.w text3_1
                dc.w text3_2
                dc.w text3_3

text3_0:        dc.b 34,"HEY. YOU MUST BE KIM. THE SCIENTISTS TOLD YOU MIGHT DROP BY. "
                dc.b "I'M JEFF. SORRY ABOUT THAT SENTRY DRONE, HAD TO MAKE SURE YOU'RE NOT A MACHINE. "
                dc.b "I'D ESTIMATE YOUR FIGHTING STYLE AS "
text3_1:        dc.b "X5% HUMAN. YOU CAME FOR THAT SIGNAL AMP FOR THE LASER, RIGHT? "
                dc.b "NEVER TESTED IT SO CAN'T BE SURE WHAT HAPPENS WHEN YOU PLUG IT IN. OH, FEEL FREE TO USE THE RECYCLER "
                dc.b "AT THE BACK. BUT DON'T TOUCH ANYTHING ELSE.",34,0

text3_2:        dc.b 34,"IT'S A MESSED UP SITUATION ALL RIGHT. BUT WITH WHAT WE'RE DOING, "
                dc.b "IT WAS BOUND TO HAPPEN SOONER OR LATER.",34,0

text3_3:        dc.b 34,"AMOS HERE. TRY USING THE AMPLIFIER YOU GOT ON THE LASER. BOOSTED, IT MIGHT BREACH THE WALL.",34,0

dataEnd:

                rend