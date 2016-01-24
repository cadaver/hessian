                include macros.s
                include mainsym.s

        ; Script 28, entrance computer texts #1

                org scriptCodeStart

                dc.w LobbyComputer
                dc.w TheatreComputer

LobbyComputer:  jsr SetupTextScreen
                gettext txtLobbyComputer
DisplayCommon:  ldy #0
                sty temp1
                sty temp2
                jsr PrintMultipleRows
                jsr WaitForExit
                jmp CenterPlayer

TheatreComputer:jsr SetupTextScreen
                gettext txtTheatreComputer
                bne DisplayCommon

txtLobbyComputer:
                     ;0123456789012345678901234567890123456789
                dc.b "WHAT'S THAT? GUNFIRE? EXPLOSIONS?",0
                dc.b "SEEMS TO COME FROM THE PARKING GARAGE.",0
                dc.b "A TERRORIST ATTACK?",0
                dc.b "SHIT. PHONE IS DEAD.",0
                dc.b "I SEE THEM NOW. THEY'RE NOT H-",0,0

txtTheatreComputer:
                     ;0123456789012345678901234567890123456789
                dc.b "WHAT IS THRONE GROUP?",0
                dc.b "AN INTERNAL PRESENTATION",0
                dc.b " ",0
                dc.b "THRONE GROUP REPRESENTS INTELLECTUAL",0
                dc.b "BRAVERY AND COMMITMENT TO EXCELLENCE.",0
                dc.b "WE REJECT ANY LIMITS IN THE PURSUIT",0
                dc.b "TO ADVANCE MANKIND.",0
                dc.b " ",0
                dc.b "IN AN IDEAL WORLD WE WOULD NOT HAVE TO",0
                dc.b "CONTEND WITH MINOR DETAILS LIKE MONEY.",0
                dc.b "BUT SINCE SUCH WORLD DOES NOT EXIST, WE",0
                dc.b "DO THE NEXT BEST THING - CHOOSE CLIENTS",0
                dc.b "WHO MATCH OUR VISION THE CLOSEST.",0
                dc.b " ",0
                dc.b "SOME ARE AFRAID OF CONCEPTS SUCH AS",0
                dc.b "SINGULARITY, OR THE POST-HUMAN AGE. WE",0
                dc.b "SHOULD NOT BE. IF WE MANAGE TO CREATE",0
                dc.b "SOMETHING THAT SHAKES THE WORLD TO ITS",0
                dc.b "CORE, WE SHOULD ONLY BE PROUD.",0
                dc.b " ",0
                dc.b "- NORMAN THRONE",0,0

                checkscriptend