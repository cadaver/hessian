                include macros.s
                include mainsym.s

        ; Script 19, old tunnels

                org scriptCodeStart

                dc.w ReachOldTunnels
                dc.w HackerFollowFinish
                dc.w EnterLab
                dc.w HackerEnterLab
                dc.w ScientistEnterLab
                dc.w Hazmat
                dc.w HazmatLeave
                dc.w DestroyComment

        ; Escaped to old tunnels
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ReachOldTunnels:
                lda #$03
                jsr MoveCommon
                bcc ROT_Wait
                gettext txtNoAirVictory
ROT_SpeakAndStopScript:
                ldy #$00
                sty actScriptF+1                ;Stop script for now
                ldy #ACT_SCIENTIST3
                jmp SpeakLine

MoveCommon:     ldx actIndex
                cmp actXH,x
                bne MC_Run
                lda #AIMODE_TURNTO
                sta actAIMode,x
                lda actSX,x                     ;Wait for stop so that speech bubble isn't off
                bne MC_Wait
                sec
                rts
MC_Run:         lda #AIMODE_IDLE
                sta actAIMode,x
                lda #JOY_RIGHT
                sta actMoveCtrl,x
MC_Wait:        clc
HFF_Wait:
ROT_Wait:       rts

        ; Finish escorting Jeff to old tunnels
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerFollowFinish:
                lda #$04
                jsr MoveCommon
                bcc HFF_Wait
                gettext txtHackerFollowFinish
HFF_SpeakAndStopScript:
                ldy #$00
                sty actScriptF+2                ;Stop script for now
                ldy #ACT_HACKER
                jmp SpeakLine

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
                ldx #>EP_SCIENTISTENTERLAB
                sta actScriptEP+1
                stx actScriptF+1
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
                ldx #>EP_HACKERENTERLAB
                sta actScriptEP+2
                stx actScriptF+2
                lda #PLOT_OLDTUNNELSLAB2
                jsr SetPlotBit
EL_NoActor2:
EL_NoActors:
SEL_Wait:
HEL_Wait:       rts

        ; Jeff in lab
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerEnterLab: lda #$70
                jsr MoveCommon
                bcc HEL_Wait
                gettext txtHackerEnterLab
                jmp HFF_SpeakAndStopScript

        ; Linda in lab
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ScientistEnterLab:
                lda #$71
                jsr MoveCommon
                bcc SEL_Wait
                gettext txtEnterLab
                jmp ROT_SpeakAndStopScript

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
DC_Wait:
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
                jsr MC_Run
                jsr SetNotPersistent            ;Disappear if leave the screen
                lda actXH,x
                cmp #$63
                bcc HL_NoExit
                lda actXL,x
                cmp #$f8
                bcc HL_NoExit
                jsr RemoveActor                 ;Remove without being put back to leveldata = disappear
HL_NotOnScreen: jmp StopScript

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
                gettext txtDestroyComment
                jmp ROT_SpeakAndStopScript

        ; Messages

txtNoAirVictory:dc.b 34,"AIR! AT LAST. THAT WAS QUICK THINKING TO HEAD THIS WAY. THANK YOU. I'LL CATCH MY BREATH FOR A WHILE.",34,0

txtHackerFollowFinish:
                dc.b 34,"SO THESE ARE THE OLD TUNNELS. SHOULD BE NO ROBOTS HERE. "
                dc.b "STILL, DOESN'T LOOK EXACTLY SAFE SO I'LL WAIT HERE AND LET YOU DO THE EXPLORING.",34,0

txtHackerEnterLab:
                dc.b 34,"THE PLOT THICKENS. A SECRET LAB.",34,0

txtEnterLab:    dc.b 34,"A BUNKER? I HAD NO IDEA. POSSIBLY FOR NORMAN'S EXTRA-PRIVATE WORK.",34,0

txtMachineReady:dc.b 34,"THE MACHINE'S GOOD TO GO? I'M READY TOO.. I THINK. ANYTHING COULD GO WRONG, "
                dc.b "NATURALLY. BUT THERE'S NOT MUCH CHOICE. ONCE I'M THROUGH THE WALL, JORMUNGANDR IN "
                dc.b "SIGHT, I'LL WAIT UNTIL YOU'RE ABOUT TO DESTROY THE AI. THEN IT'S FULL SPEED AHEAD. "
                dc.b "NOW, I BELIEVE IT'S FAREWELL. TAKE CARE, KIM.",34,0

txtDestroyComment:
                dc.b 34,"JEFF'S BEING VERY BRAVE. THE PLAN'S NOT WHAT I WOULD CALL SANE, BUT LIKE HIM I SEE LITTLE CHOICE.",34,0

                checkscriptend
