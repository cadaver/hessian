                include macros.s
                include mainsym.s

        ; Script 30, upper labs computer texts #1

                org scriptCodeStart

                dc.w LabComputer1
                dc.w LabComputer2
                dc.w LabComputer3
                dc.w LabComputer4
                dc.w LabComputer5
                dc.w LabComputer6
                dc.w LabComputer7
                dc.w LabComputer8
                dc.w LabComputer9

LabComputer1:   jsr SetupTextScreen
                ldx #$02
LC1_Code:       lda codes+2*3,x
                ora #$30
                sta txtExoskeletonCode,x
                dex
                bpl LC1_Code
                gettext txtLabComputer1
DisplayCommon:  ldy #0
                sty temp1
                sty temp2
                jsr PrintMultipleRows
                jsr WaitForExit
                jmp CenterPlayer

LabComputer2:   jsr SetupTextScreen
                ldx #$02
LC2_Code:       lda codes+3,x
                ora #$30
                sta txtHealingCode,x
                dex
                bpl LC2_Code
                gettext txtLabComputer2
                bne DisplayCommon

LabComputer3:   jsr SetupTextScreen
                gettext txtLabComputer3
                bne DisplayCommon

LabComputer4:   jsr SetupTextScreen
                gettext txtLabComputer4
                bne DisplayCommon

LabComputer5:   jsr SetupTextScreen
                lda codes+6*3
                ora #$30
                sta txtNumber1
                gettext txtLabComputer5
                bne DisplayCommon

LabComputer6:   jsr SetupTextScreen
                gettext txtLabComputer6
                bne DisplayCommon

LabComputer7:   jsr SetupTextScreen
                gettext txtLabComputer7
                bne DisplayCommon

LabComputer8:   jsr SetupTextScreen
                gettext txtLabComputer8
                bne DisplayCommon

LabComputer9:   jsr SetupTextScreen
                gettext txtLabComputer9
                bne DisplayCommon

                     ;0123456789012345678901234567890123456789
txtLabComputer1:dc.b "FROM: MJONSSON",0
                dc.b "TO: KKRUGER",0
                dc.b " ",0
                dc.b "IT'S BEEN A LONG, HARD CRUNCH. THE LOWER",0
                dc.b "EXOSKELETON UPGRADE IS AS FINALIZED AS",0
                dc.b "IT'S GOING TO BE. THE LAB CODE IS "
txtExoskeletonCode:
                dc.b "XXX IN",0
                dc.b "CASE YOU WANT TO CHECK. STILL, I BELIEVE",0
                dc.b "THIS WORK IS NEVER GOING TO BE ACCEPTED.",0,0

                     ;0123456789012345678901234567890123456789
txtLabComputer2:dc.b "FROM: KKRUGER",0
                dc.b "TO: MJONSSON",0
                dc.b " ",0
                dc.b "MY THOUGHTS AFTER WORKING ON THE FASTER",0
                dc.b "RECOVERY UPGRADE ARE SIMILAR. THE PUBLIC",0
                dc.b "COULD ONLY EVER SEE THIS PROJECT AS AN",0
                dc.b "ABOMINATION. SINCE YOU SHARED YOURS, MY",0
                dc.b "LAB CODE IS "
txtHealingCode: dc.b "XXX.",0,0

                     ;0123456789012345678901234567890123456789
txtLabComputer3:dc.b "FROM: RTHRONE",0
                dc.b "TO: SCIENCE.UPPER",0
                dc.b " ",0
                dc.b "WE MAY HAVE A SITUATION. DO NOT GO NEAR",0
                dc.b "THE COMBAT ROBOT PROTOTYPES. THEY ARE",0
                dc.b "RECEIVING COMMANDS FROM A SOURCE THAT IS",0
                dc.b "PRESENTLY NOT UNDER OUR CONTROL. IF YOU",0
                dc.b "CAN, SEAL THE ROBOTS OFF, THEN VACATE",0
                dc.b "THE LABORATORIES.",0,0

                     ;0123456789012345678901234567890123456789
txtLabComputer4:dc.b "FROM: HSCHULZ",0
                dc.b "TO: SCIENCE.UPPER",0
                dc.b " ",0
                dc.b "I WOULD LIKE TO REMIND THAT SPECULATION",0
                dc.b "IS SELDOM HEALTHY. NORMAN HAS STEERED",0
                dc.b "THIS OUTFIT FOR YEARS WITH NOTHING BUT",0
                dc.b "STELLAR RESULTS. IF HE RETREATS INTO",0
                dc.b "PRIVACY, IT HAS TO BE FOR A GOOD REASON.",0,0

                     ;0123456789012345678901234567890123456789
txtLabComputer5:dc.b "FROM: NTHRONE",0
                dc.b "TO: JGRAVES",0
                dc.b " ",0
                dc.b "I BELIEVE I HAVE THE MISSING PIECE TO",0
                dc.b "SAVE THE 'HESSIAN' PROJECT. I'M NOT",0
                dc.b "READY TO SHARE IT YET, FOR IT MAY BE",0
                dc.b "UNSAFE AND REQUIRE FURTHER CALIBRATION.",0
                dc.b "FOR NOW, JUST REMEMBER THIS NUMBER: "
txtNumber1:     dc.b "X.",0,0

                     ;0123456789012345678901234567890123456789
txtLabComputer6:dc.b "FROM: MJONSSON",0
                dc.b "TO: ACOLLIER, LMATHIEU",0
                dc.b " ",0
                dc.b "ON THE SUBJECT OF NORMAN'S ABSENCE: AT",0
                dc.b "THE COMBAT ROBOT PROJECT KICKOFF HE",0
                dc.b "TALKED ANIMATEDLY OF THE POSSIBILITY OF",0
                dc.b "UPLOADING A HUMAN MIND AS THE BLUEPRINT",0
                dc.b "FOR A SUPERIOR AI. I ASSUME THIS WOULD",0
                dc.b "BE A SOLITARY PURSUIT.",0,0

                     ;0123456789012345678901234567890123456789
txtLabComputer7:dc.b "IT OCCURRED TO ME THAT THE 'HESSIAN'",0
                dc.b "PROJECT WOULD HAVE NEEDED A DIFFERENT",0
                dc.b "CLIENT: THE ILLUMINATI. I MEAN, NOT JUST",0
                dc.b "MIND CONTROLLED ASSASSINS, BUT BATTERY-",0
                dc.b "DEPENDENT ENHANCED ASSASSINS! JUST DENY",0
                dc.b "THEIR DAILY CHARGE IF THEY DISOBEY OR",0
                dc.b "PERFORM POORLY.",0,0

                     ;0123456789012345678901234567890123456789
txtLabComputer8:dc.b "THE EMP GENERATOR",0
                dc.b " ",0
                dc.b "A PORTABLE DEFENSE OR DISCIPLINARY TOOL",0
                dc.b "FOR WORKING WITH COMBAT ROBOTS. DUE TO",0
                dc.b "BATTERY DRAIN 'HESSIAN' SUBJECTS ARE",0
                dc.b "DISCOURAGED FROM WIELDING ONE.",0,0

                     ;0123456789012345678901234567890123456789
txtLabComputer9:dc.b "SMART MINE",0
                dc.b " ",0
                dc.b "1) DETONATE ON ENEMY CONTACT",0
                dc.b "2) FALLBACK TO TIME DELAY",0,0

                ;checkscriptend