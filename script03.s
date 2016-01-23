                include macros.s
                include mainsym.s

        ; Script 3, triggers for entering some early areas
        
                org scriptCodeStart

                dc.w RadioUpperLabsEntrance
                dc.w RadioSecurityCenter

        ; Radio speech for upper labs entrance
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioUpperLabsEntrance:
                ldy #ITEM_SECURITYPASS
                jsr FindItem
                bcc RULI_NoPass
                gettext txtRadioUpperLabs
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx
RULI_NoPass:    ldy lvlObjNum
                jmp InactivateObject            ;Retry later to check for pass

        ; Radio speech when entering security center
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioSecurityCenter:
                lda #PLOT_ELEVATOR1             ;If lower labs already visited/completed, skip this
                jsr GetPlotBit
                bne RSC_Skip
                gettext txtRadioSecurityCenter
                jmp RadioMsg
RSC_Skip:       rts

txtRadioUpperLabs:
                dc.b 34,"AMOS HERE. YOU'RE CLOSE TO THE UPPER LABS. SEE IF YOU CAN FIND ANY CLUES. "
                dc.b "IF NOT, YOU'LL HAVE TO PUSH ON TO THE HIGH-CLEARANCE LOWER LABS. "
                dc.b "ALSO LOOK FOR CODE-LOCKED ROOMS, WHICH WERE USED FOR NANOBOT RESEARCH AS PART "
                dc.b "OF THE 'HESSIAN' MILITARY CONTRACT. FIND THE ENTRY CODES, AND YOU CAN UPGRADE "
                dc.b "YOUR ABILITIES. UPGRADES WILL CONSUME MORE POWER, THOUGH.",34,0

txtRadioSecurityCenter:
                dc.b 34,"IT'S AMOS. GOOD THINKING, THE ARMORY SHOULD HOLD POWERFUL WEAPONRY. STAY ALERT THOUGH, "
                dc.b "ANY GUARDS INSIDE MAY THINK YOU'VE GONE ROGUE. OR THE WORSE OPTION, THAT THEY'RE SOMEHOW COMPLICIT.",34,0

                checkscriptend

