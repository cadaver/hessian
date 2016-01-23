                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 4

                rorg $0000

                dc.w text5_0
                dc.w text5_1
                dc.w text5_2
                dc.w text5_3

        ; Reordered to compress better
        
text5_3:        dc.b 34,"YOU'VE GOT THE OLD TUNNELS PASS? I THINK WE SHOULD HEAD THERE IMMEDIATELY.",34,0

text5_1:        dc.b 34,"HEY. I APPRECIATE YOU CHECKING ON ME. THIS PLACE IS SECURE SO FAR, BUT I BET THE AI "
                dc.b "IS AWARE OF IT. THERE'S SOMETHING ELSE I FOUND: THE SO-CALLED 'OLD TUNNELS' "
                dc.b "WHICH ALSO BRANCH OFF FROM THE LOWER LABS. HAVEN'T SEEN MACHINE TRAFFIC FROM "
                dc.b "THERE AT ALL. COULD BE THEIR BLIND SPOT, AND THEREFORE SAFE.",34,0

text5_0:        dc.b 34,"KIM, IT'S JEFF. I'VE BEEN DECRYPTING MORE OF THE MACHINES' NET TRAFFIC. 'CONSTRUCT' HAS TO BE THE NAME OF THE CENTRAL AI. "
                dc.b "IT TASKED THE MACHINES TO BUILD 'JORMUNGANDR.' AMOUNT OF MATERIALS USED WAS ASTRONOMICAL. "
                dc.b "IF THEY FOLLOW NORSE MYTHS, THAT SHOULD BE ONE HUGE SERPENT. FUN, RIGHT?",34,0

text5_2:        dc.b 34,"BUT GO AND TAKE CARE OF THOSE SCIENTISTS NOW. THEY'RE MUCH MORE EXPOSED.",34,0

dataEnd:
                rend