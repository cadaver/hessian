                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 3

                rorg $0000
                
                dc.w text12_0
                dc.w text12_1
                dc.w text12_2

text12_0:       dc.b 34,"SO THESE ARE THE OLD TUNNELS. SHOULD BE NO MACHINES HERE. "
                dc.b "STILL, DOESN'T LOOK EXACTLY SAFE SO I'LL WAIT HERE AND LET YOU DO THE EXPLORING.",34,0

text12_1:       dc.b 34,"THE PLOT THICKENS. A SECRET LAB.",34,0

text12_2:       dc.b 34,"A BUNKER? I HAD NO IDEA. POSSIBLY FOR NORMAN'S EXTRA-PRIVATE WORK.",34,0

dataEnd:
                rend
