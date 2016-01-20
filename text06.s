                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 6

                rorg $0000
                
                dc.w text6_0
                dc.w text6_1
                dc.w text6_2
                dc.w text6_3
                dc.w text6_4
                dc.w text6_5

text6_0:        dc.b 34,"SO THESE ARE THE OLD TUNNELS. SHOULD BE NO MACHINES HERE. "
                dc.b "STILL, DOESN'T LOOK EXACTLY SAFE SO I'LL WAIT HERE AND LET YOU DO THE EXPLORING.",34,0

text6_1:        dc.b 34,"THE PLOT THICKENS. A SECRET LAB.",34,0

                     ;0123456789012345678901234567890123456789
text6_2:        dc.b "NOTE #4",0
                dc.b " ",0
                dc.b "THE AI HAS REPURPOSED THE FIBER-OPTIC",0
                dc.b "LINK BETWEEN THE SERVER VAULT AND THE",0
                dc.b "INVENTION CHAMBER.",0
                dc.b " ",0
                dc.b "I CALL IT A 'BI-DIRECTIONAL REVENGE",0
                dc.b "PROTOCOL.' IF COMMUNICATION ON THE LINE",0
                dc.b "CEASES DUE TO EITHER JORMUNGANDR OR THE",0
                dc.b "AI BEING INCAPACITATED, THE ONE THAT",0
                dc.b "REMAINS WILL LAUNCH ITS ATTACK.",0
                dc.b " ",0
                dc.b "N.T",0,0

text6_3:        dc.b 34,"SORRY FOR SNEAKING UP ON YOU. BUT THAT'S TRUE EVIL GENIUS. TAKE THIS LAPTOP. "
                dc.b "IF YOU FIND THE LINK, WE MIGHT BE ABLE TO FAKE THE COMMUNICATION. THEN YOU CAN PROCEED "
                dc.b "TO BLAST THEM BOTH TO HELL. OF COURSE.. "
                dc.b "TAMPERING WITH IT COULD ALREADY TRIGGER ARMAGEDDON.",34,0

text6_4:        dc.b 34,"A BUNKER? I HAD NO IDEA. POSSIBLY FOR NORMAN'S EXTRA-PRIVATE WORK.",34,0

text6_5:        dc.b 34,"HEY. YOU SHOULD BE KICKING JORMUNGANDR AND CONSTRUCT ASS, NOT CHECKING ON ME. I'VE NO WORRIES HERE. WELL, "
                dc.b "EXCEPT WHETHER YOU'LL COME BACK ALIVE. TRY TO DO THAT, RIGHT? NOW GO KICK ASS ALREADY.",34,0

dataEnd:
                rend
