                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    rts

                org charInfo
                incbin world15half.chi

txtEnding1:     dc.b "HACKED SECOND STRIKE SYSTEMS ATTACK",0
                dc.b "RANDOM TARGETS. RETALIATIONS FOLLOW",0
                dc.b "    AND A NUCLEAR WINTER BEGINS.",0,0

                org charColors
                incbin world15half.chc

txtEnding2:     dc.b "JORMUNGANDR DISRUPTS EARTH'S CRUST.",0
                dc.b " MASSIVE VOLCANO ERUPTIONS BLACKEN",0
                dc.b "  THE SUN - A NEW ICE AGE BEGINS.",0,0

                org chars
                incbin world15half.chr

                org chars+$400

txtEnding3:     dc.b "THE AI INCIDENT AT THE THRONE GROUP",0
                dc.b " COMPLEX IS OVER, WITH JORMUNGANDR",0
                dc.b "  AND THE CONSTRUCT BOTH DEFEATED.",0,0

                org chars+$480

txtEnding3_2a:  dc.b "KIM CONSIDERS HER OPTIONS: STAY AND",0
                dc.b " RISK INDEFINITE MILITARY CUSTODY.",0
                dc.b "  OR RUN AWAY UNTIL OUT OF POWER?",0,0

                org chars+$700

txtEnding3_2b:  dc.b " KIM REFLECTS ON HER FUTURE AS THE",0
                dc.b " ONLY SELF-RECHARGING 'HESSIAN' SO",0
                dc.b "   FAR. SHE COULD IMAGINE WORSE.",0,0
