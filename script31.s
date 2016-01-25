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
                dc.w LowerLabsComputer9

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

LowerLabsComputer9:
                ldx #$30
                lda #PLOT_ELEVATOR1
                jsr GetPlotBit
                bne LLC9_ZeroUse                ;Show zero CPU after Construct is disconnected
                ldx #$39
                jsr Random
                and #$07
                ora #$30
                bne LLC9_Common
LLC9_ZeroUse:   txa
LLC9_Common:    stx txtCpuUse
                sta txtCpuUse+1
                gettext txtLowerLabsComputer9
                jmp DisplayCommon

txtLowerLabsComputer1:
                     ;0123456789012345678901234567890123456789
                dc.b "ROBOT CONSTRUCTION LINE",0
                dc.b " ",0
                dc.b "CONSTRUCT OVERRIDES:",0
                dc.b "- PRIORITIZE COMPLETION OF JORMUNGANDR",0
                dc.b "- REPAIRS ONLY TO VITAL BUILDER ROBOTS",0
                dc.b "- ALL OTHER WORK INESSENTIAL",0,0

txtLowerLabsComputer2:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: RGRAVES",0
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
                dc.b "THIS IS UNACCEPTABLE, AND THRONE GROUP",0
                dc.b "WILL BE IN SERIOUS TROUBLE IF THIS IS",0
                dc.b "EVER CAUUGHT IN AN AUDIT. DELETE THIS",0
                dc.b "MESSAGE NOW AND DON'T MAKE ME REMIND",0
                dc.b "EVER AGAIN.",0,0

txtLowerLabsComputer4:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: DREUTER",0
                dc.b "TO: TENGMAN, SJANKOVIC",0
                dc.b " ",0
                dc.b "IT'S AN INTERESTING CHALLENGE TO WORK ON",0
                dc.b "THE SUBDERMAL ARMOR WITHOUT BEING ABLE",0
                dc.b "TO TEST IT ON LIVE SUBJECTS. SIMULATION",0
                dc.b "QUALITY WAS A POSITIVE SURPRISE, THOUGH.",0
                dc.b "COME SEE IT SOMETIME, CODE IS "
txtArmorCode:   dc.b "XXX. ALSO,",0
                dc.b "FUCK PIERCE.",0,0

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
                dc.b "BATTERY. STILL, IT ALLOWS A SOLDIER 2X",0
                dc.b "LONGER OPERATING TIME. CODE'S "
txtBatteryCode: dc.b "XXX IN",0
                dc.b "CASE YOU WANT TO PAY A VISIT.",0,0

txtLowerLabsComputer7:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: NTHRONE",0
                dc.b "TO: BFJORD",0
                dc.b " ",0
                dc.b "YOUR EXPERTISE ON METABOLISM HAS ALLOWED",0
                dc.b "ME A BREAKTHROUGH, THOUGH IT MAY BE TOO",0
                dc.b "LATE TO MAKE THE MILITARY HIGHER-UPS RE-",0
                dc.b "CONSIDER. IN CASE I DON'T, REMEMBER THIS",0
                dc.b "NUMBER: "
txtNumber2:     dc.b "X.",0,0

txtLowerLabsComputer8:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: LKNELLER",0
                dc.b "TO: JPETERS",0
                dc.b " ",0
                dc.b "NOT EXACTLY. THE HEART'S FUNCTION IS",0
                dc.b "COMPLETELY REPLACED ONLY IN CASE OF",0
                dc.b "IRREVERSIBLE TRAUMA. BUT YOUR CONCERN IS",0
                dc.b "VALID. WITHOUT POWER THE BOTS CAN'T",0
                dc.b "MOVE, WHICH CAN LEAD TO A FATAL CLOT.",0,0
                
txtLowerLabsComputer9:
                dc.b "CONSTRUCT AUXILIARY PROCESSING NODE",0
                dc.b "CPU USAGE "
txtCpuUse:      dc.b "XX%",0,0


                ;checkscriptend