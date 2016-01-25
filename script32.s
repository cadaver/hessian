                include macros.s
                include mainsym.s

        ; Script 31, lower security texts

menuSelection   = wpnBits

                org scriptCodeStart

                dc.w LowerSecurityComputer1
                dc.w LowerSecurityComputer2
                dc.w LowerSecurityComputer3
                dc.w LowerSecurityComputer4
                dc.w LowerSecurityComputer5

LowerSecurityComputer1:
                gettext txtLowerSecurityComputer1
DisplayCommon:  ldy #0
                sty temp1
                sty temp2
                jsr SetupTextScreen
                jsr PrintMultipleRows
                jsr WaitForExit
                jmp CenterPlayer

LowerSecurityComputer2:
                gettext txtLowerSecurityComputer2
                bne DisplayCommon

LowerSecurityComputer3:
                gettext txtLowerSecurityComputer3
                bne DisplayCommon

LowerSecurityComputer5:
                gettext txtLowerSecurityComputer5
                bne DisplayCommon

LowerSecurityComputer4:
                jsr SetupTextScreen
                lda #11
                sta temp1
                lda #8
                sta temp2
                gettext txtLowerSecurityComputer4
                jsr PrintMultipleRows
                lda #0
                sta menuSelection
LSC4_Redraw:    lda #$20
LSC4_ArrowLastPos:
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
                sta LSC4_ArrowLastPos+1
                lda zpDestHi
                sta LSC4_ArrowLastPos+2
                lda #21
                sta temp1
                lda #10
                sta temp2
LSC4_PrintCell: ldy temp2
                cpy #12
                bcs LSC4_ControlLoop
                lda lvlObjB+$06-10,y
                bmi LSC4_CellOpen
LSC4_CellClosed:gettext txtClosed
                bne LSC4_CellCommon
LSC4_CellOpen:  gettext txtOpen
LSC4_CellCommon:jsr PrintText
                inc temp2
                bne LSC4_PrintCell
LSC4_ControlLoop:jsr FinishFrame
                jsr GetControls
                jsr GetFireClick
                ldy menuSelection
                bcs LSC4_Action
                lda prevJoy
                and #JOY_UP|JOY_DOWN
                bne LSC4_ControlLoop
                lda joystick
                lsr
                bcs LSC4_Up
                lsr
                bcs LSC4_Down
                lda keyType
                bmi LSC4_ControlLoop
LSC4_Exit:      ldy lvlObjNum
                jsr InactivateObject            ;Allow immediate re-entry
                jmp CenterPlayer
LSC4_Action:    lda #SFX_SELECT
                jsr PlaySfx
                cpy #2
                bcs LSC4_Exit
                tya
                adc #$06
                tay
                jsr ToggleObject
                jmp LSC4_Redraw
LSC4_Up:        dey
                bpl LSC4_NotOver
                ldy #2
LSC4_NotOver:   sty menuSelection
                lda #SFX_SELECT
                jsr PlaySfx
                jmp LSC4_Redraw
LSC4_Down:      iny
                cpy #3
                bcc LSC4_NotOver
                ldy #0
                bcs LSC4_NotOver

txtLowerSecurityComputer1:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: BJAEGER",0
                dc.b "TO: GKRAMER",0
                dc.b " ",0
                dc.b "I BELIEVE WE WILL NOT BE TESTING THE",0
                dc.b "UPGRADE FOR OURSELVES. BUT THANKS FOR",0
                dc.b "CODE ANYWAY.",0,0

txtLowerSecurityComputer2:
                     ;0123456789012345678901234567890123456789
                dc.b "FROM: RTHRONE",0
                dc.b "TO: SECURITY.LOWER",0
                dc.b " ",0
                dc.b "IN ADDITION TO THE DANGER POSED BY THE",0
                dc.b "ROBOTS, THE LAB VENTILATION SYSTEM COULD",0
                dc.b "BE MANIPULATED BY THE AI. THEREFORE I",0
                dc.b "STRONGLY SUGGEST TO HOLD POSITION. ALSO,",0
                dc.b "CHECK THE PRISONER REGULARLY. I FORESEE",0
                dc.b "POTENTIAL FOR SELF-HARM.",0,0

txtLowerSecurityComputer3:
                     ;0123456789012345678901234567890123456789
                dc.b "NINE LEVELS OF POWER",0
                dc.b " ",0
                dc.b "1. STRENGTH OF MIND AND BODY",0
                dc.b "2. DIRECTION OF POWER",0
                dc.b "3. HARMONY WITH THE UNIVERSE",0
                dc.b "4. HEALING OF SELF AND OTHERS",0
                dc.b "5. PREMONITION OF DANGER",0
                dc.b "6. KNOWING THOUGHTS OF OTHERS",0
                dc.b "7. MASTERY OF SPACE AND TIME",0
                dc.b "8. CONTROL OF THE ELEMENTS OF NATURE",0
                dc.b "9. ENLIGHTENMENT",0,0

txtLowerSecurityComputer4:
                dc.b "CELL DOOR CONTROLS",0
                dc.b " ",0
                dc.b "  CELL 1:",0
                dc.b "  CELL 2:",0
                dc.b "  EXIT",0,0

txtLowerSecurityComputer5:
                     ;0123456789012345678901234567890123456789
                dc.b "THE UPPER SECURITY GUYS THINK THEY'RE",0
                dc.b "COMBAT READY, BUT THEY'RE JUST PUSSIES",0
                dc.b "WHO ONLY HAVE TO HANDLE THE OCCASIONAL",0
                dc.b "AGITATED SUIT OR DRUNK TRESPASSER. WE AT",0
                dc.b "LEAST RISK SUFFOCATION DEEP BELOW GROUND",0
                dc.b "EACH DAY.",0
                dc.b " ",0
                dc.b "RUTGER'S MEN HAVE ALL THE LATEST AND",0
                dc.b "HEAVIEST HARDWARE, BUT I DON'T ENVY THEM",0
                dc.b "IN THE LEAST. THE BIO-DOME EXPERIMENTAL",0
                dc.b "LIFEFORMS KEEP THEM ON THEIR TOES EVERY",0
                dc.b "SECOND. THEY'RE THE TRUE COMBAT READY IF",0
                dc.b "ANY.",0,0

txtArrow:       dc.b 62,0
txtClosed:      dc.b "CLOSED",0
txtOpen:        dc.b "OPEN  ",0

                checkscriptend