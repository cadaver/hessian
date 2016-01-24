                include macros.s
                include mainsym.s

        ; Script 24, destroy plan finalize + approaching Jormungandr

                org scriptCodeStart

                dc.w Hazmat
                dc.w HazmatLeave
                dc.w DestroyComment
                dc.w RadioHackerWarning

        ; Hazmat NPC (Jeff or Linda)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Hazmat:         lda actXH+ACTI_PLAYER           ;Wait until player close enough
                cmp #$63
                bcs H_Wait
                jsr AddQuestScore
                lda #PLOT_RIGTUNNELMACHINE
                jsr SetPlotBit
                lda #$00
                sta actScriptF+3                ;Stop actor script, but use a continuous script to walk away
                lda #<EP_HAZMATLEAVE
                ldx #>EP_HAZMATLEAVE
                jsr SetScript
                ldy #ACT_HAZMAT
                gettext txtMachineReady
                jmp SpeakLine
HL_NoExit:
HL_Wait:
H_Wait:         rts

        ; Hazmat NPC walks off screen
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HazmatLeave:    lda #ACT_HAZMAT
                jsr FindActor
                bcc HL_NotOnScreen
                lda textTime
                bne HL_Wait
                lda #AIMODE_IDLE
                sta actAIMode,x
                lda #JOY_RIGHT
                sta actMoveCtrl,x
                lda actXH,x
                cmp #$63
                bcc HL_NoExit
                lda actXL,x
                cmp #$f8
                bcc HL_NoExit
                jsr RemoveActor                 ;Remove without being put back to leveldata = disappear
                jmp StopScript
HL_NotOnScreen: lda #ACT_HAZMAT
                jsr FindLevelActor
                bcc HL_NoLevelActor
                lda #ACT_NONE                   ;Disappear from the game world
                sta lvlActT,y
HL_NoLevelActor:jmp StopScript

        ; Linda comments the destroy plan
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

DestroyComment: lda scriptVariable
                php
                inc scriptVariable
                plp
                beq DC_Wait                     ;Wait until screen on
                lda #$00
                sta actScriptF+1                ;Stop actor script after line
                ldy #ACT_SCIENTIST3
                gettext txtDestroyComment
                jmp SpeakLine
RHW_NoActor:
RHW_HasItem:
DC_Wait:        rts

        ; Radio message when entering Jormungandr's lair without biometric ID
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioHackerWarning:
                lda #ACT_HACKER
                jsr FindLevelActor
                bcc RHW_NoActor
                ldy #ITEM_BIOMETRICID
                jsr FindItem
                bcs RHW_HasItem
                gettext txtRadioHackerWarning
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx

        ; Messages

txtMachineReady:dc.b 34,"THE MACHINE'S GOOD TO GO? I'M READY TOO.. I THINK. ANYTHING COULD GO WRONG, "
                dc.b "NATURALLY. BUT THERE'S NOT MUCH CHOICE. ONCE I'M THROUGH THE WALL, JORMUNGANDR IN "
                dc.b "SIGHT, I'LL WAIT UNTIL YOU'RE ABOUT TO DESTROY THE AI. THEN IT'S FULL SPEED AHEAD. "
                dc.b "NOW, I BELIEVE IT'S FAREWELL. TAKE CARE, KIM.",34,0

txtDestroyComment:
                dc.b 34,"JEFF'S BEING VERY BRAVE. THE PLAN'S NOT WHAT I WOULD CALL SANE, BUT LIKE HIM I SEE LITTLE CHOICE.",34,0

txtRadioHackerWarning:
                dc.b 34,"IT'S JEFF. YOU MUST BE CLOSE NOW. THERE'S ONE THING I FOUND.. THE DEDICATED MILITARY NETWORK "
                dc.b "LINK IS ACTIVE, THOUGH ALL OTHER OUTSIDE LINES ARE DOWN. HAS TO BE THE AI. "
                dc.b "THE SCARIEST OPTION WOULD BE THAT IT HAS WORMED ITS WAY INTO "
                dc.b "NUCLEAR LAUNCH SYSTEMS OR SOMETHING. BUT NO. THAT CAN'T HAPPEN IN REALITY.",34,0

                checkscriptend
