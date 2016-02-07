                processor 6502

                include memory.s
                include mainsym.s

                org lvlCodeStart

UpdateLevel:    rts

                org charInfo
                incbin world15half.chi

txtEnding1:     dc.b " HACKED 2ND STRIKE SYSTEMS ATTACK",0
                dc.b "AT RANDOM. RETALIATIONS ENSUE, AND",0
                dc.b "     A NUCLEAR WINTER BEGINS.",0,0

                org charColors
                incbin world15half.chc

txtEnding2:     dc.b " JORMUNGANDR TRAVERSES THE CRUST.",0
                dc.b "MASSIVE VOLCANIC ERUPTIONS BLACKEN",0
                dc.b "THE SUN, AND A NEW ICE AGE BEGINS.",0,0

                org chars
                incbin world15half.chr

                org chars+$400

txtEnding3:     dc.b " THE THRONE GROUP SCIENCE COMPLEX",0
                dc.b "INCIDENT IS OVER, WITH JORMUNGANDR",0
                dc.b " AND THE CONSTRUCT BOTH DEFEATED.",0,0

                org chars+$480

txtEnding3_2a:  dc.b " KIM CONSIDERS HER OPTIONS: STAY,",0
                dc.b " AND RISK INDEFINITE DETENTION BY",0
                dc.b "  THE MILITARY? OR RUN, HOW FAR?",0,0

                org chars+$700

txtEnding3_2b:  dc.b "KIM MEDITATES ON HER FUTURE AS THE",0
                dc.b "  ONLY SELF-RECHARGING 'HESSIAN'",0
                dc.b " ALIVE - SHE COULD IMAGINE WORSE.",0,0
