                include macros.s
                include mainsym.s

        ; Script 19, old tunnels

                org scriptCodeStart

                dc.w ReachOldTunnels
                dc.w HackerFollowFinish
                dc.w EnterLab
                dc.w HackerEnterLab
                dc.w ScientistEnterLab

        ; Escaped to old tunnels
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ReachOldTunnels:
                ldx actIndex
                lda actXH,x
                cmp #$03
                bcc ROT_Run
                lda #AIMODE_TURNTO
                sta actAIMode,x
                lda actSX,x                     ;Wait for stop so that speech bubble isn't off
                bne ROT_Wait
                gettext txtNoAirVictory
ROT_SpeakAndStopScript:
                ldy #$00
                sty actScriptF+1                ;Stop script for now
                ldy #ACT_SCIENTIST3
                jmp SpeakLine
ROT_Run:        lda #AIMODE_IDLE
                sta actAIMode,x
                lda #JOY_RIGHT
                sta actMoveCtrl,x
ROT_Wait:       rts

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
                gettext txtHackerFollowFinish
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
                gettext txtHackerEnterLab
                jmp HFF_SpeakAndStopScript

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
                gettext txtEnterLab
                ldy #$00
                sty actScriptF+1                ;Stop script for now
                ldy #ACT_SCIENTIST3
                jmp SpeakLine
SEL_Wait:       rts

        ; Messages

txtNoAirVictory:dc.b 34,"AIR! AT LAST. THAT WAS QUICK THINKING TO HEAD THIS WAY. THANK YOU. I'LL CATCH MY BREATH FOR A WHILE.",34,0

txtHackerFollowFinish:
                dc.b 34,"SO THESE ARE THE OLD TUNNELS. SHOULD BE NO ROBOTS HERE. "
                dc.b "STILL, DOESN'T LOOK EXACTLY SAFE SO I'LL WAIT HERE AND LET YOU DO THE EXPLORING.",34,0

txtHackerEnterLab:
                dc.b 34,"THE PLOT THICKENS. A SECRET LAB.",34,0

txtEnterLab:    dc.b 34,"A BUNKER? I HAD NO IDEA. POSSIBLY FOR NORMAN'S EXTRA-PRIVATE WORK.",34,0

                checkscriptend
