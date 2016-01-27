                include macros.s
                include mainsym.s

        ; Script 5, IT & security computer texts

menuSelection   = wpnBits

                org scriptCodeStart

                dc.w RadioSecurityCenter
                dc.w SecurityComputer1
                dc.w SecurityComputer2
                dc.w SecurityComputer3
                dc.w SecurityComputer4
                dc.w SecurityComputer5
                dc.w SecurityComputer6

        ; Radio speech when entering security center
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioSecurityCenter:
                lda #PLOT_AMPINSTALLED             ;If lower labs already visited/completed, skip this
                jsr GetPlotBit
                bne RSC_Skip
                gettext txtRadioSecurityCenter
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jsr PlaySfx
RSC_Skip:       rts

SecurityComputer1:
                ldx #$02
SC1_Code:       lda codes,x
                ora #$30
                sta txtFirearmCode,x
                dex
                bpl SC1_Code
                gettext txtSecurityComputer1
DisplayCommon:  ldy #0
                sty temp1
                sty temp2
                jsr SetupTextScreen
                jsr PrintMultipleRows
                jsr WaitForExit
                jmp CenterPlayer

SecurityComputer2:
                gettext txtSecurityComputer2
                bne DisplayCommon

SecurityComputer3:
                gettext txtSecurityComputer3
                bne DisplayCommon

SecurityComputer4:
                gettext txtSecurityComputer4
                bne DisplayCommon

SecurityComputer5:
                gettext txtSecurityComputer5
                bne DisplayCommon

SecurityComputer6:
                jsr SetupTextScreen
                lda #11
                sta temp1
                lda #8
                sta temp2
                gettext txtSecurityComputer6
                jsr PrintMultipleRows
                lda #0
                sta menuSelection
SC6_Redraw:     lda #$20
SC6_ArrowLastPos:
                sta screen1+2*40
                lda #11
                sta temp1
                lda menuSelection
                clc
                adc #10
                sta temp2
                lda #<txtArrow
                ldx #>txtArrow
                jsr PrintText
                lda zpDestLo
                sta SC6_ArrowLastPos+1
                lda zpDestHi
                sta SC6_ArrowLastPos+2
                lda #21
                sta temp1
                lda #10
                sta temp2
SC6_PrintCell:  ldy temp2
                cpy #12
                bcs SC6_ControlLoop
                lda lvlObjB+$16-10,y
                bmi SC6_CellOpen
SC6_CellClosed: gettext txtClosed
                bne SC6_CellCommon
SC6_CellOpen:   gettext txtOpen
SC6_CellCommon: jsr PrintText
                inc temp2
                bne SC6_PrintCell
SC6_ControlLoop:jsr FinishFrame
                jsr GetControls
                jsr GetFireClick
                ldy menuSelection
                bcs SC6_Action
                lda prevJoy
                and #JOY_UP|JOY_DOWN
                bne SC6_ControlLoop
                lda joystick
                lsr
                bcs SC6_Up
                lsr
                bcs SC6_Down
                lda keyType
                bmi SC6_ControlLoop
SC6_Exit:       ldy lvlObjNum
                jsr InactivateObject            ;Allow immediate re-entry
                jmp CenterPlayer
SC6_Action:     lda #SFX_SELECT
                jsr PlaySfx
                cpy #2
                bcs SC6_Exit
                tya
                adc #$16
                tay
                jsr ToggleObject
                jmp SC6_Redraw
SC6_Up:         dey
                bpl SC6_NotOver
                ldy #2
SC6_NotOver:    sty menuSelection
                lda #SFX_SELECT
                jsr PlaySfx
                jmp SC6_Redraw
SC6_Down:       iny
                cpy #3
                bcc SC6_NotOver
                ldy #0
                bcs SC6_NotOver

txtRadioSecurityCenter:
                dc.b 34,"IT'S AMOS. GOOD THINKING, THE ARMORY SHOULD HOLD POWERFUL WEAPONRY. STAY ALERT THOUGH, "
                dc.b "ANY GUARDS INSIDE MAY THINK YOU'VE GONE ROGUE. OR THE WORSE OPTION, THAT THEY'RE SOMEHOW COMPLICIT.",34,0

txtSecurityComputer1:
                     ;0123456789012345678901234567890123456789
                dc.b "RE: RESEARCH LAB",0
                dc.b " ",0
                dc.b "LIKE YOU SAW, RUTGER'S HEAVY SECURITY",0
                dc.b "FORCE TESTED THE MOTOR SKILL (AIMING)",0
                dc.b "UPGRADE SUCCESSFULLY. THE BASE NANOBOT",0
                dc.b "PACKAGE IS NATURALLY REQUIRED. LAB ENTRY",0
                dc.b "CODE IS "
txtFirearmCode: dc.b "XXX. THOUGHT IT WAS FAIR FOR YOU",0
                dc.b "TO KNOW.",0,0

txtSecurityComputer2:
                     ;0123456789012345678901234567890123456789
                dc.b "RE: PRISONER",0
                dc.b " ",0
                dc.b "TREAT THE PRISONER WITH RESPECT, BUT",0
                dc.b "ASSUME HE IS DANGEROUS. NOTE ESPECIALLY",0
                dc.b "THE PROTOTYPE ROBOT ARM. ITS STRENGTH IS",0
                dc.b "WELL BEYOND NORMAL HUMAN CAPABILITY. WE",0
                dc.b "WILL ARRIVE SHORTLY TO TRANSPORT HIM.",0
                dc.b " ",0
                dc.b "--",0
                dc.b "RUTGER THRONE",0
                dc.b "HEAD OF SECURITY",0,0

txtSecurityComputer3:
                     ;0123456789012345678901234567890123456789
                dc.b "IT SEEMS THERE'S A SITUATION. ORDERS ARE",0
                dc.b "TO HOLD THIS STATION. CAMERAS SHOW JUST",0
                dc.b "NOISE. BUT THIS IS EXACTLY WHAT I SIGNED",0
                dc.b "UP FOR. I'M 100% COMBAT READY IF ANYONE",0
                dc.b "ASKS.",0
                dc.b " ",0
                dc.b "THE PRISONER WE HAD EARLIER WAS HOODED,",0
                dc.b "BUT I THOUGHT HE LOOKED FAMILIAR. HE'S",0
                dc.b "ALREADY OUT OF OUR HANDS NOW. SHOULD",0
                dc.b "CHECK THE CELLS IN CASE HE LEFT ANYTHING",0
                dc.b "BEHIND.",0,0

txtSecurityComputer4:
                     ;0123456789012345678901234567890123456789
                dc.b "PARKING GARAGE: CAMERAS OFFLINE",0
                dc.b "LOBBY & OFFICES: CAMERAS OFFLINE",0
                dc.b "UPPER LABS: CAMERAS OFFLINE",0,0

txtSecurityComputer5:
                     ;0123456789012345678901234567890123456789
                dc.b "FWD: RE: RESEARCH LAB",0
                dc.b " ",0
                dc.b "BASE NANOBOT PACKAGE? DOES IT ACTUALLY",0
                dc.b "MEAN YOUR HEART BECOMES AN INERT PIECE",0
                dc.b "OF MEAT, WHILE THOSE TINY BOTS PUMP YOUR",0
                dc.b "BLOOD, AND YOU'LL DEPEND ON BATTERIES",0
                dc.b "FOREVER? THAT'S BEYOND STUPID. NO WONDER",0
                dc.b "THE PROJECT'S BEING AXED.",0,0

txtSecurityComputer6:
                dc.b "CELL DOOR CONTROLS",0
                dc.b " ",0
                dc.b "  CELL 1:",0
                dc.b "  CELL 2:",0
                dc.b "  EXIT",0,0

txtArrow:       dc.b 62,0
txtClosed:      dc.b "CLOSED",0
txtOpen:        dc.b "OPEN  ",0

                checkscriptend