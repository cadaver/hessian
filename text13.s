                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 3

                rorg $0000
                
                dc.w text13_0
                dc.w text13_1
                dc.w text13_2

                     ;0123456789012345678901234567890123456789
text13_0:       dc.b "NOTE #4",0
                dc.b " ",0
                dc.b "THE AI HAS REPURPOSED THE FIBER-OPTIC",0
                dc.b "LINK BETWEEN THE SERVER VAULT AND THE",0
                dc.b "INVENTION CHAMBER.",0
                dc.b " ",0
                dc.b "I CALL IT A 'BI-DIRECTIONAL REVENGE",0
                dc.b "PROTOCOL.' IF COMMUNICATION ON THE LINE",0
                dc.b "CEASES DUE TO EITHER JORMUNGANDR OR THE",0
                dc.b "AI BEING DISABLED, THE ONE THAT REMAINS",0
                dc.b "WILL LAUNCH ITS ATTACK.",0,0

text13_1:       dc.b 34,"SORRY FOR SNEAKING UP ON YOU. BUT THAT IF ANY IS EVIL. TAKE THIS LAPTOP. "
                dc.b "IF YOU CAN FIND THE LINK, WE MIGHT BE ABLE TO TRICK THE PROTOCOL. THEN YOU CAN "
                dc.b "SAFELY BLAST THEM BOTH TO HELL. OF COURSE.. "
                dc.b "ANY TAMPERING COULD ALREADY TRIGGER ARMAGEDDON.",34,0

text13_2:       dc.b 34,"HEY. YOU SHOULD BE KICKING JORMUNGANDR AND CONSTRUCT ASS. I'VE NO WORRIES HERE. WELL, "
                dc.b "EXCEPT WHETHER YOU'LL RETURN ALIVE. TRY TO DO THAT, RIGHT? NOW GO KICK ASS ALREADY.",34,0

dataEnd:
                rend
