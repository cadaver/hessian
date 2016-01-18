                include macros.s
                include mainsym.s

        ; Script 10, old tunnels lab

                org scriptCodeStart

                dc.w HackerFollowFinish
                dc.w EnterLab
                dc.w HackerEnterLab
                dc.w LabComputer
                dc.w GiveLaptop2
                dc.w ScientistEnterLab
                dc.w Hazmat
                dc.w HazmatLeave
                dc.w DestroyComment

        ; Finish escorting Jeff to old tunnels
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerFollowFinish:
                ldx actIndex
                lda actXH,x
                cmp #$04
                bcc HFF_Run
                lda #AIMODE_TURNTO
                sta actAIMode,x
                lda actSX,x                     ;Wait for stop so that speech bubble isn't off
                bne HFF_Wait
                lda #<txtEnterOldTunnels
                ldx #>txtEnterOldTunnels
HFF_SpeakAndStopScript:
                ldy #$00
                sty actScriptF+2                ;Stop script for now
                ldy #ACT_HACKER
                jmp SpeakLine
HFF_Run:        lda #AIMODE_IDLE
                sta actAIMode,x
                lda #JOY_RIGHT
                sta actMoveCtrl,x
HFF_Wait:
EL_NoActors:    rts

        ; Enter old tunnels lab
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EnterLab:       lda lvlObjB+$0c                 ;If player closed door from inside, no-one can enter
                bpl EL_NoActors

                lda #ACT_SCIENTIST3
                jsr FindActor                   ;Skip if already onscreen
                bcs EL_NoActor1
                lda #ACT_SCIENTIST3
                jsr FindLevelActor
                bcc EL_NoActor1
                lda lvlActOrg,y
                cmp #$0f+ORG_GLOBAL
                bne EL_NoActor1
                lda lvlActX,y
                cmp #$5a
                bcs EL_NoActor1                 ;Already in lab or in the shaft?
                lda #$6e
                sta lvlActX,y
                lda #$4c
                sta lvlActY,y
                lda #$10+AIMODE_IDLE
                sta lvlActF,y
                lda #<EP_SCIENTISTENTERLAB
                sta actScriptEP+1
                lda #>EP_SCIENTISTENTERLAB
                sta actScriptF+1
                lda #PLOT_OLDTUNNELSLAB1
                jsr SetPlotBit

EL_NoActor1:    lda #ACT_HACKER
                jsr FindActor                   ;Skip if already onscreen
                bcs EL_NoActor2
                lda #ACT_HACKER
                jsr FindLevelActor
                bcc EL_NoActor2
                lda lvlActOrg,y
                cmp #$0f+ORG_GLOBAL
                bne EL_NoActor2
                lda lvlActX,y
                cmp #$5a
                bcs EL_NoActor2                 ;Already in lab or in the shaft?
                lda #$6e
                sta lvlActX,y
                lda #$4c
                sta lvlActY,y
                lda #$00+AIMODE_IDLE
                sta lvlActF,y
                lda #<EP_HACKERENTERLAB
                sta actScriptEP+2
                lda #>EP_HACKERENTERLAB
                sta actScriptF+2
                lda #PLOT_OLDTUNNELSLAB2
                jsr SetPlotBit
EL_NoActor2:
HEL_Wait:       rts

        ; Jeff in lab
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerEnterLab: ldx actIndex
                lda actXH,x
                cmp #$70
                bcs HEL_Done
                jmp HFF_Run
HEL_Done:       lda #AIMODE_TURNTO
                sta actAIMode,x
                lda actSX,x
                bne HEL_Wait
                lda #<txtEnterLab
                ldx #>txtEnterLab
                jmp HFF_SpeakAndStopScript

        ; Lab computer
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

LabComputer:    lda #ACT_HACKER
                jsr FindLevelActor
                bcc LC_NoActor
                lda lvlActOrg,y
                cmp #$0f+ORG_GLOBAL
                bne LC_NoActor
                lda lvlActX,y
                cmp #$70
                bne LC_NoActor
                lda #$88
                sta lvlActX,y
                lda #$48
                sta lvlActY,y
                lda #$10+AIMODE_TURNTO
                sta lvlActF,y
                lda #<EP_GIVELAPTOP2
                sta actScriptEP+2
                lda #>EP_GIVELAPTOP2
                sta actScriptF+2
                lda #$00
                sta scriptVariable
LC_NoActor:     jsr SetupTextScreen
                lda #0
                sta temp1
                sta temp2
                lda #<txtLabComputer
                ldx #>txtLabComputer
                jsr PrintMultipleRows
                jsr WaitForExit
                jmp CenterPlayer

        ; Jeff gives laptop after reading apocalyptic note
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

GiveLaptop2:    lda scriptVariable
                bne GiveLaptop2b
                inc scriptVariable
                lda #<txtGiveLaptop2
                ldx #>txtGiveLaptop2
                ldy #ACT_HACKER
                jmp SpeakLine
GiveLaptop2b:   lda #SFX_PICKUP
                jsr PlaySfx
                lda #ITEM_LAPTOP
                ldx #1
                jsr AddItem
                lda #0
                sta actScriptF+2
SEL_Wait:       rts

        ; Linda in lab
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ScientistEnterLab:
                ldx actIndex
                lda actXH,x
                cmp #$71
                bcs SEL_Done
                jmp HFF_Run
SEL_Done:       lda #AIMODE_TURNTO
                sta actAIMode,x
                lda actSX,x
                bne SEL_Wait
                lda #<txtEnterLab2
                ldx #>txtEnterLab2
                ldy #$00
                sty actScriptF+1                ;Stop script for now
                ldy #ACT_SCIENTIST3
                jmp SpeakLine

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
                lda #<txtHazmat
                ldx #>txtHazmat
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

DestroyComment: lda #$00
                sta actScriptF+1                ;Stop actor script after line
                ldy #ACT_SCIENTIST3
                lda #<txtDestroyComment
                ldx #>txtDestroyComment
                jmp SpeakLine

        ; Messages

txtEnterOldTunnels:
                dc.b 34,"SO THESE ARE THE OLD TUNNELS. SHOULD BE NO MACHINES HERE. "
                dc.b "STILL, DOESN'T LOOK EXACTLY SAFE SO I'LL WAIT HERE AND LET YOU DO THE EXPLORING.",34,0

txtEnterLab:    dc.b 34,"THE PLOT THICKENS. A SECRET LAB.",34,0

                     ;0123456789012345678901234567890123456789
txtLabComputer: dc.b "NOTE #4",0
                dc.b " ",0
                dc.b "THE AI HAS REPURPOSED THE FIBER-OPTIC",0
                dc.b "LINK BETWEEN THE SERVER VAULT AND THE",0
                dc.b "INVENTION CHAMBER.",0
                dc.b " ",0
                dc.b "I CALL IT A 'BI-DIRECTIONAL REVENGE",0
                dc.b "PROTOCOL.' IF COMMUNICATION ON THE LINE",0
                dc.b "CEASES DUE TO EITHER JORMUNGANDR OR THE",0
                dc.b "AI BEING INCAPACITATED, THE ONE THAT",0
                dc.b "REMAINS WILL LAUNCH ITS ATTACK.",0
                dc.b " ",0
                dc.b "N.T",0,0

txtGiveLaptop2: dc.b 34,"SORRY FOR SNEAKING UP ON YOU. BUT THAT'S TRUE EVIL GENIUS. TAKE THIS LAPTOP. "
                dc.b "IF YOU FIND THE LINK, WE MIGHT BE ABLE TO FAKE THE COMMUNICATION. THEN YOU CAN PROCEED "
                dc.b "TO BLAST THEM BOTH TO HELL. OF COURSE.. "
                dc.b "TAMPERING WITH IT COULD ALREADY TRIGGER ARMAGEDDON.",34,0

txtEnterLab2:   dc.b 34,"A BUNKER? I HAD NO IDEA. POSSIBLY FOR NORMAN'S EXTRA-PRIVATE WORK.",34,0

txtHazmat:      dc.b 34,"THE MACHINE'S GOOD TO GO? I'M READY TOO.. I THINK. ANYTHING COULD GO WRONG, "
                dc.b "NATURALLY. BUT THERE'S NOT MUCH CHOICE. ONCE I'M THROUGH THE WALL, JORMUNGANDR IN "
                dc.b "SIGHT, I'LL WAIT UNTIL YOU'RE ABOUT TO DESTROY THE AI. THEN IT'S FULL SPEED AHEAD. "
                dc.b "BUT NOW, I BELIEVE IT'S TIME FOR FAREWELL. WAS AN HONOR, KIM.",34,0

txtDestroyComment:
                dc.b 34,"JEFF'S BEING VERY BRAVE. THE PLAN'S NOT WHAT I WOULD CALL SANE, BUT LIKE HIM I SEE LITTLE CHOICE.",34,0

                checkscriptend
