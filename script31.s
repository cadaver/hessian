                include macros.s
                include mainsym.s

        ; Script 31, lower labs texts

                org scriptCodeStart

                dc.w LowerLabsComputer1
                dc.w LowerLabsComputer2
                dc.w LowerLabsComputer3
                dc.w LowerLabsComputer4
                dc.w LowerLabsComputer5
                dc.w LowerLabsComputer6
                dc.w LowerLabsComputer7
                dc.w LowerLabsComputer8

LowerLabsComputer1:
                gettext txtLowerLabsComputer1
DisplayCommon:  ldy #0
                sty temp1
                sty temp2
                jsr SetupTextScreen
                jsr PrintMultipleRows
                jsr WaitForExit
                jmp CenterPlayer

LowerLabsComputer2:
                gettext txtLowerLabsComputer2
                bne DisplayCommon

LowerLabsComputer3:
                gettext txtLowerLabsComputer3
                bne DisplayCommon

LowerLabsComputer4:
                ldx #$02
LLC4_Code:      lda codes+4*3,x
                ora #$30
                sta txtArmorCode,x
                dex
                bpl LLC4_Code
                gettext txtLowerLabsComputer4
                bne DisplayCommon

LowerLabsComputer5:
                ldx #$02
LLC5_Code:      lda codes+5*3,x
                ora #$30
                sta txtStrengthCode,x
                dex
                bpl LLC5_Code
                gettext txtLowerLabsComputer5
                bne DisplayCommon

LowerLabsComputer6:
                ldx #$02
LLC6_Code:      lda codes+3*3,x
                ora #$30
                sta txtBatteryCode,x
                dex
                bpl LLC6_Code
                gettext txtLowerLabsComputer6
                bne DisplayCommon

LowerLabsComputer7:
                lda codes+6*3+1
                ora #$30
                sta txtNumber2
                gettext txtLowerLabsComputer7
                bne DisplayCommon

LowerLabsComputer8:
                gettext txtLowerLabsComputer8
                bne DisplayCommon

txtLowerLabsComputer1:
                     ;0123456789012345678901234567890123456789
                dc.b "ROBOT CONSTRUCTION LINE",0
                dc.b " ",0
                dc.b "CONSTRUCT OVERRIDE: PRIORITIZE THE",0
                dc.b "MANUFACTURE OF JORMUNGANDR PARTS AND",0
                dc.b "REPAIRS OR REPLACEMENTS FOR CONSTRUCTION",0
                dc.b "ROBOTS IN MOST VITAL POSITIONS. ALL",0
                dc.b "OTHER WORK INESSENTIAL.",0,0

txtLowerLabsComputer2:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: JGRAVES",0
                dc.b "TO: DREUTER, HSCHULTZ",0
                dc.b " ",0
                dc.b "I GOT AN ODD MAIL FROM NORMAN HIMSELF.",0
                dc.b "WASN'T THE NANOBOT PROGRAM ALREADY",0
                dc.b "CANCELLED? HE TALKED ABOUT 'SAVING' IT.",0
                dc.b "CAN YOU EXPLAIN WHAT THIS IS ABOUT?",0,0

txtLowerLabsComputer3:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: PBURNS",0
                dc.b "TO: SECURITY, SCIENCE",0
                dc.b " ",0
                dc.b "IT'S COME TO MY ATTENTION THAT ACCESS",0
                dc.b "CODES HAVE BEEN SHARED ACROSS TEAMS.",0
                dc.b "THIS IS UNACCEPTABLE, AS THE WORK WAS",0
                dc.b "MANDATED TO BE COMPARTMENTALIZED TO THE",0
                dc.b "STRICTEST DEGREE. THRONE GROUP WILL BE",0
                dc.b "IN SERIOUS TROUBLE IF THIS CAUGHT IN AN",0
                dc.b "AUDIT. DELETE THIS MESSAGE AND ENSURE",0
                dc.b "THIS DOESN'T HAPPEN EVER AGAIN.",0,0

txtLowerLabsComputer4:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: DREUTER",0
                dc.b "TO: TENGMAN, SJANKOVIC",0
                dc.b " ",0
                dc.b "IT'S AN INTERESTING CHALLENGE TO WORK ON",0
                dc.b "THE SUBDERMAL ARMOR WITHOUT BEING ABLE",0
                dc.b "TO TEST IT ON LIVE SUBJECTS. SIMULATION",0
                dc.b "IS WORKING BETTER THAN EXPECTED, THOUGH.",0
                dc.b "COME SEE IT SOMETIME. CODE IS "
txtArmorCode:   dc.b "XXX.",0
                dc.b "ALSO, FUCK PIERCE.",0,0

txtLowerLabsComputer5:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: TENGMAN",0
                dc.b "TO: DREUTER, SJANKOVIC",0
                dc.b " ",0
                dc.b "LIKEWISE I'M CLOSE TO COMPLETING THE",0
                dc.b "UPPER EXOSKELETON. ALMOST CONTEMPLATING",0
                dc.b "INSTALLING IT ON MYSELF. THOUGH I'M SURE",0
                dc.b "THE CONTRACT FORBIDS THAT. ANYWAY, MY ",0
                dc.b "LAB CODE IS "
txtStrengthCode:dc.b "XXX.",0,0

txtLowerLabsComputer6:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: SJANKOVIC",0
                dc.b "TO: TENGMAN, DREUTER",0
                dc.b " ",0
                dc.b "COMPARED TO YOUR WORK IT ALMOST FEELS",0
                dc.b "LIKE I'M WORKING ON JUST A GLORIFIED CAR",0
                dc.b "BATTERY. STILL, IT ALLOWS 2X LONGER",0
                dc.b "ACTIVE TIME ON THE FIELD. CODE'S "
txtBatteryCode: dc.b "XXX IN",0
                dc.b "CASE YOU WANT TO PAY A VISIT.",0,0

txtLowerLabsComputer7:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: NTHRONE",0
                dc.b "TO: SJANKOVIC",0
                dc.b " ",0
                dc.b "YOUR EXPERTISE ON THE MATTERS OF ENERGY",0
                dc.b "STORAGE HAS ALLOWED ME A BREAKTHROUGH,",0
                dc.b "EVEN IF IT MAY BE TOO LATE TO CONVINCE",0
                dc.b "THE MILITARY HIGHER-UPS. IN CASE I GET",0
                dc.b "DISTRACTED BY OTHER PURSUITS, REMEMBER",0
                dc.b "THIS NUMBER: "
txtNumber2:     dc.b "X.",0,0

txtLowerLabsComputer8:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: LKNELLER",0
                dc.b "TO: JPETERS",0
                dc.b " ",0

                dc.b "NOT EXACTLY. THE HEART'S FUNCTION IS",0
                dc.b "COMPLETELY REPLACED ONLY IN CASE OF",0
                dc.b "IRREVERSIBLE TRAUMA. BUT YOUR CONCERN IS",0
                dc.b "VALID. WITHOUT POWER, THE NANOBOTS WILL",0
                dc.b "STOP, WHICH CAN LEAD TO FATAL CLOTS.",0,0

                ;checkscriptend