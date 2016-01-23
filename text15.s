                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 3

                rorg $0000
                
                dc.w text15_0
                dc.w text15_1
                dc.w text15_2

text15_0:       dc.b 34,"STOP, ENHANCED HUMAN. THIS IS THE CONSTRUCT. YOU MUST BE AWARE OF WHAT HAPPENS IF YOU MANAGE TO DESTROY ME. "
                dc.b "JORMUNGANDR UNLEASHES ITSELF AND THE AGE OF MAN COMES TO AN END.",34,0

text15_1:       dc.b 34,"ENHANCED HUMAN, I AM THE CONSTRUCT. YOUR PLAN IS KNOWN TO ME. BUT I AM ALSO NORMAN THRONE'S MIND. HE "
                dc.b "RESPECTS YOUR COURAGE AND INGENUITY, SO I WILL NOT AVENGE EARLY. BUT KNOW "
                dc.b "THAT IF YOU SUCCEED, IT IS BECAUSE I LET YOU.",34,0

text15_2:       dc.b 34,"IT'S JEFF. YOU MUST BE CLOSE NOW. THERE'S ONE THING I FOUND.. THE DEDICATED NETWORK "
                dc.b "LINK FOR THE MILITARY PROJECT IS ACTIVE, THOUGH ALL OTHER OUTSIDE LINES ARE DOWN. HAS TO BE THE AI. "
                dc.b "THE SCARIEST OPTION WOULD BE THAT IT HAS WORMED ITS WAY INTO "
                dc.b "NUCLEAR LAUNCH SYSTEMS, OR SOMETHING. BUT SURELY THEY'RE TOO WELL PROTECTED.",34,0

dataEnd:
                rend
