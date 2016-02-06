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
                incbin world15opt.chr

                org chars+$400

txtEnding3:     dc.b "THE BATTLE OVER, KIM CONSIDERS HER",0
                dc.b " OPTIONS. STAY AS A MILITARY TEST",0
                dc.b "  SUBJECT? OR RUN, BUT HOW FAR?",0,0

                org chars+$480

txtEnding3b:    dc.b " THE BATTLE OVER, KIM MEDITATES ON",0
                dc.b "  HER FUTURE AS THE ONLY ",34,"HESSIAN",34,0
                dc.b "   SUBJECT ABLE TO SELF-RECHARGE.",0,0
