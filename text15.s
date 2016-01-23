                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 2

                rorg $0000
                
                dc.w text15_0
                dc.w text15_1

text15_0:       dc.b 34,"STOP, ENHANCED HUMAN. THIS IS THE CONSTRUCT. YOU MUST BE AWARE OF WHAT HAPPENS IF YOU MANAGE TO DESTROY ME. "
                dc.b "JORMUNGANDR UNLEASHES ITSELF AND THE AGE OF MAN COMES TO AN END.",34,0

text15_1:       dc.b 34,"ENHANCED HUMAN, I AM THE CONSTRUCT. YOUR PLAN IS KNOWN TO ME. BUT I AM ALSO NORMAN THRONE'S MIND. HE "
                dc.b "RESPECTS YOUR COURAGE AND INGENUITY, SO I WILL NOT AVENGE EARLY. BUT KNOW "
                dc.b "THAT IF YOU SUCCEED, IT IS BECAUSE I LET YOU.",34,0
dataEnd:
                rend
