                include macros.s
                include mainsym.s

        ; Script 5, code entry

numberIndex     = menuCounter

                org scriptCodeStart

                dc.w EnterCode
                dc.w EnterCodeLoop

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

EnterCodeLoop:  gettext txtEnterCode
                jsr PrintPanelTextIndefinite
                ldy #$00
                ldx #20
ECL_Redraw:     cpy numberIndex
                beq ECL_HasDigit
                bcs ECL_EmptyDigit
ECL_HasDigit:   lda codeEntry,y
                ora #$30
                skip2
ECL_EmptyDigit: lda #"-"
                jsr PrintPanelChar
                inx
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
                ldx #MAX_CODES-1
ECL_Verify:     lda lvlObjNum
                cmp codeObject,x                ;All object numbers for code doors are unique, don't
                beq ECL_VerifyFound             ;need to check level
                dex
                bpl ECL_Verify                  ;This should never exit the loop
ECL_VerifyFound:txa
                sta temp1
                asl
                adc temp1
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

        ; Code entry object numbers

codeObject:     dc.b $12,$29,$27,$16,$26,$22,$08,$31

        ; Messages

txtEnterCode:   dc.b "ENTER CODE",0

                checkscriptend