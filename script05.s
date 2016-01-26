                include macros.s
                include mainsym.s

        ; Script 5, code entry

numberIndex     = menuCounter

                org scriptCodeStart

                dc.w EnterCode
                dc.w EnterCodeLoop

        ; Messages

txtKeypadTbl:   dc.b <txtKeypad0
                dc.b <txtKeypad1
                dc.b <txtKeypad2
                dc.b <txtKeypad3
                dc.b <txtKeypad4
                dc.b <txtKeypad5
                dc.b <txtKeypad6
                dc.b <txtKeypad7

txtKeypad0:     dc.b "MOTOR SKILL"
txtLab:         dc.b " LAB",0
txtKeypad1:     dc.b "HEAL BOOST"
                textjump txtLab
txtKeypad2:     dc.b "LOWER EXO"
                textjump txtLab
txtKeypad3:     dc.b "AUX BATTERY"
                textjump txtLab
txtKeypad4:     dc.b "SUB-D ARMOR"
                textjump txtLab
txtKeypad5:     dc.b "UPPER EXO"
                textjump txtLab
txtKeypad6:     dc.b "SUITE"
                textjump txtLab
txtKeypad7:     dc.b "NETHER TUNNEL"

        ; Enter keypad code script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EnterCode:      lda #0
                ldx #2
EC_Reset:       sta codeEntry,x
                dex
                bpl EC_Reset
                ldx #MAX_CODES-1
EC_FindLoop:    lda lvlObjNum
                cmp codeObject,x                ;All object numbers for code doors are unique, don't
                beq EC_Found                    ;need to check level
                dex
                bpl EC_FindLoop
EC_Found:       stx doorIndex
                lda #<EP_ENTERCODELOOP
                ldx #>EP_ENTERCODELOOP
                jsr SetScript
                ldx #MENU_INTERACTION
                jmp SetMenuMode

        ; Enter keypad code interaction loop
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EnterCodeLoop:  ldx doorIndex
                lda txtKeypadTbl,x
                ldx #>txtKeypad0
                jsr PrintPanelTextIndefinite
                ldy #$00
                ldx #25
ECL_Redraw:     cpy numberIndex
                beq ECL_HasDigit
                bcs ECL_EmptyDigit
ECL_HasDigit:   lda codeEntry,y
                ora #$30
                skip2
ECL_EmptyDigit: lda #"-"
                inx
                jsr PrintPanelChar
                iny
                cpy #3
                bcc ECL_Redraw
CheckForExit:   lda joystick
                and #JOY_DOWN
                bne ECL_Finish
                lda keyType
                bpl ECL_Finish
                jsr MenuControl
                ldx numberIndex
                lsr
                bcs ECL_MoveLeft
                lsr
                bcs ECL_MoveRight
                jsr GetFireClick
                bcs ECL_Next
ECL_Done:       rts
ECL_MoveLeft:   lda #$fe                        ;C=1
                skip2
ECL_MoveRight:  lda #$00                        ;C=1
                adc codeEntry,x
                bmi ECL_OverNeg
                cmp #10
                bcc ECL_NotOver
                lda #0
                skip2
ECL_OverNeg:    lda #9
ECL_NotOver:    sta codeEntry,x
ECL_Sound:      lda #SFX_SELECT
                jmp PlaySfx
ECL_Next:       jsr ECL_Sound
                inx
                stx numberIndex
                cpx #3
                bcc ECL_Done
                lda doorIndex
                asl
                adc doorIndex
                tay
                ldx #$00
ECL_VerifyLoop: lda codeEntry,x
                cmp codes,y
                bne ECL_Finish
                iny
                inx
                cpx #$03
                bcc ECL_VerifyLoop
                jsr OO_RequirementOK            ;Open the door if code right
ECL_Finish:     jsr StopScript
                jmp SetMenuMode                 ;X=0 on return

        ; Variables

doorIndex:      dc.b 0

        ; Code entry object numbers

codeObject:     dc.b $12,$29,$27,$16,$26,$22,$08,$31

                checkscriptend