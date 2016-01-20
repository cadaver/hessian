                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 6

                rorg $0000

                dc.w text3_0
                dc.w text3_1
                dc.w text3_2
                dc.w text3_3
                dc.w text3_4
                dc.w text3_5

        ; Note: order tweaked to compress better
        
text3_1:        dc.b 34,"KIM, IT'S JEFF. I'VE BEEN DECRYPTING MORE OF THE MACHINES' TRAFFIC. 'CONSTRUCT' HAS TO BE THE NAME OF THE CENTRAL AI. "
                dc.b "IT TASKED THE MACHINES TO BUILD 'JORMUNGANDR.' AMOUNT OF MATERIALS USED WAS ASTRONOMICAL. "
                dc.b "IF THEY FOLLOW NORSE MYTHS, THAT SHOULD BE ONE HUGE SERPENT. FUN, RIGHT?",34,0

text3_2:        dc.b 34,"IT'S JEFF. FOUND SOMETHING. THERE'S A BLACKOUT TO THE OUTSIDE, RIGHT? BUT "
                dc.b "TRAFFIC IS GOING OUT ON THE LINK THAT WAS INSTALLED FOR THE MILITARY PROJECT. HEAVILY "
                dc.b "ENCRYPTED, SO I CAN'T KNOW WHAT. BUT IT HAS TO BE THE AI. HMM.. WHAT? I'M SEEING MOVE-",34," (STATIC)",0

text3_4:        dc.b 34,"THEY JAMMED THE RADIO AND FOOLED THE DOOR CAMERA TO GET IN. ONE MORE SECOND AND.. "
                dc.b "I'D HUG YOU, BUT THOSE GUNS ARE IN THE WAY. WILL SET A HARD LOCK-DOWN NOW, "
                dc.b "SO USE THE RECYCLER IF YOU NEED.",0

text3_5:        dc.b "ALSO TAKE THIS LAPTOP. MY THEORY IS, THE AI HAS A DEDICATED NETWORK LINK. "
                dc.b "IF YOU CAN FIND IT, WE MAY BE ABLE TO CUT IT OFF COMPLETELY.",34,0

text3_3:        dc.b 34,"SUCKS IT HAPPENED LIKE THIS. BUT WITH YOU HERE, IT SUCKS A BIT LESS. PROMISE ME TO KICK THEIR ASS.",34,0

text3_0:        dc.b 34,"AMOS HERE. GREAT JOB FIXING THE ELEVATOR. WE'VE FIGURED OUT THE NEXT STEP "
                dc.b "AND NEED TO REACH THE LOWER LABS NOW. BUT GOING ON OUR OWN IS LIKELY TO "
                dc.b "GET US KILLED. WE MANAGED TO SAFELY REACH THE UPPER LABS RECYCLING STATION, MEET US THERE.",34,0

dataEnd:
                rend