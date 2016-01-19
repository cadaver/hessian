                include macros.s
                include mainsym.s

        ; Script 2, conversations in the game beginning

                org scriptCodeStart

                dc.w GameStart
                dc.w Scientist1
                dc.w Scientist2
                dc.w RadioUpperLabsEntrance

        ; Finalize game start. Create persistent NPCs to the leveldata and randomize entry codes
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

GameStart:      ldx #MAX_PERSISTENTNPCS-1
GS_Loop:        jsr GetLevelActorIndex
                lda npcX,x
                sta lvlActX,y
                lda npcY,x
                sta lvlActY,y
                lda npcF,x
                sta lvlActF,y
                lda npcT,x
                sta lvlActT,y
                lda npcWpn,x
                sta lvlActWpn,y
                lda npcOrg,x
                sta lvlActOrg,y
                dex
                bpl GS_Loop
                lda #<EP_SCIENTIST2         ;Initial NPC scripts to drive the plot forward
                ldx #>EP_SCIENTIST2
                sta actScriptEP
                stx actScriptF
                if SKIP_PLOT > 0
                if SKIP_PLOT2 > 0
                lda #PLOT_HIDEOUTAMBUSH
                jsr SetPlotBit
                lda #<EP_HACKERAMBUSH
                ldx #>EP_HACKERAMBUSH
                else
                lda #<EP_HACKER3
                ldx #>EP_HACKER3
                endif
                else
                lda #<EP_HACKER
                ldx #>EP_HACKER
                endif
                sta actScriptEP+2
                stx actScriptF+2
                ldx #(MAX_CODES)*3-1
GS_CodeLoop:    if CODE_CHEAT > 0
                lda #$00
                else
                jsr Random
                and #$0f
                cmp #$0a
                bcs GS_CodeLoop
                endif
                sta codes,x
                dex
                bpl GS_CodeLoop
                lda codes+MAX_CODES*3-1         ;Make the last (nether tunnels) code initially
                ora #$80                        ;impossible to enter, even by guessing
                sta codes+MAX_CODES*3-1
                jsr FindPlayerZone              ;Need to get starting level's charset so that save is named properly
                jsr SaveCheckpoint              ;Save first in-memory checkpoint immediately
                jmp CenterPlayer

        ; Scientist 1 (intro) move routine
        ;
        ; Parameters: X actor number
        ; Returns: -
        ; Modifies: various

Scientist1:     jsr MoveHuman
                lda menuMode
                cmp #MENU_DIALOGUE
                beq S1_InDialogue
                lda scriptVariable
                asl
                tay
                lda S1_JumpTbl,y
                sta S1_Jump+1
                lda S1_JumpTbl+1,y
                sta S1_Jump+2
S1_Jump:        jsr $0000
                ldx actIndex
S1_InDialogue:  rts

S1_JumpTbl:     dc.w S1_WaitFrame
                dc.w S1_IntroDialogue
                dc.w S1_SetAttack
                dc.w S1_Dying
                dc.w S1_DoNothing

S1_WaitFrame:   inc scriptVariable              ;Special case wait 1 frame (loading)
                ldx #MENU_INTERACTION           ;Set interaction mode meanwhile so that player can't move away
                jmp SetMenuMode

S1_IntroDialogue:
                inc scriptVariable
                ldy #ACT_SCIENTIST1
                gettext 0,0
                jmp SpeakLine

S1_SetAttack:   jsr S1_LimitControl
                lda actHp,x
                beq S1_Dead
                lda #JOY_RIGHT
                sta actMoveCtrl,x
                lda #ACT_SMALLDROID
                jsr FindActor
                bcc S1_NoDroid
                lda #AIMODE_FLYER
                sta actAIMode,x
                lda actIndex                    ;Make sure targets the scientist
                sta actAITarget,x
                lda actTime,x                   ;Artificially increase aggression to guarantee kill
                bmi S1_NoAggression
                clc
                adc #$20
                bpl S1_AggressionOK
                lda #$7f
S1_AggressionOK:sta actTime,x
S1_NoAggression:lda #LINE_YES
                sta actLine,x
S1_DyingContinue:
S1_NoDroid:     rts
S1_Dead:        inc scriptVariable
                lda #ACT_SMALLDROID
                jsr FindActor
                bcc S1_NoDroid
                lda #JOY_LEFT|JOY_UP
                sta actMoveCtrl,x
                lda #AIMODE_FLYERFREEMOVE
                sta actAIMode,x                 ;Fly away after kill, become nonpersistent (not found anymore)
                jmp SetNotPersistent

S1_Dying:       jsr S1_LimitControl
                lda actF1,x                     ;Wait until on the ground
                cmp #FR_DUCK+1
                beq S1_DieAgain
                cmp #FR_DIE+2
                bcc S1_DyingContinue
                lda actTime,x
                cmp #DEATH_FLICKER_DELAY+1
                bcs S1_DyingContinue
                ldy #ACTI_PLAYER                ;Turn to player
                jsr GetActorDistance
                lda temp5
                sta actD,x
                inc actHp,x                     ;Halt dying for now to speak
                lda #FR_DUCK+1
                sta actF1,x
                sta actF2,x
                lda #JOY_DOWN
                sta actMoveCtrl,x
                ldy #ACT_SCIENTIST1
                gettext 0,1
                jmp SpeakLine
S1_DieAgain:    inc scriptVariable
                lda #DEATH_FLICKER_DELAY+25
                sta actTime,x
                lda #FR_DIE+2
                sta actF1,x
                sta actF2,x
                dec actHp,x
                lda #$00
                sta temp4
                lda #ITEM_PISTOL
                jsr DI_ItemNumber
                ldy temp8
                lda #10
                sta actHp,y                     ;Full mag
S1_DoNothing:   rts

S1_LimitControl:lda #JOY_RIGHT|JOY_LEFT|JOY_DOWN|JOY_UP ;Don't allow entering the container in the beginning,
                ldy actXH+ACTI_PLAYER                   ;or going too far to the left
                cpy #$67
                bcs S1_LimitLeft
                lda #JOY_RIGHT|JOY_DOWN
S1_LimitLeft:   and joystick
                sta joystick
                rts

        ; Scientist 2 (hideout 1) script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Scientist2:     lda actXH+ACTI_PLAYER           ;Wait until player close enough
                cmp #$37
                bcc S2_Wait
                cmp #$3c
                bcs S2_Wait
                lda actYH+ACTI_PLAYER
                cmp #$29
                bcs S2_Wait
                lda actMB+ACTI_PLAYER
                lsr
                bcc S2_Wait
                lda scriptVariable
                asl
                tay
                lda S2_JumpTbl,y
                sta S2_Jump+1
                lda S2_JumpTbl+1,y
                sta S2_Jump+2
S2_Jump:        jmp $0000
S2_Wait:        rts

S2_JumpTbl:     dc.w S2_Dialogue1
                dc.w S2_Dialogue2
                dc.w S2_Dialogue3
                dc.w S2_Dialogue4

S2_Dialogue1:   jsr AddQuestScore
                inc scriptVariable
                ldy #ACT_SCIENTIST2
                gettext 0,2
                jmp SpeakLine

S2_Dialogue2:   inc scriptVariable
                ldy #ACT_SCIENTIST3
                gettext 0,3
                jmp SpeakLine

S2_Dialogue3:   inc scriptVariable
                ldy #ACT_SCIENTIST2
                gettext 0,4
                jmp SpeakLine

S2_Dialogue4:   lda #ITEM_COMMGEAR
                ldx #1
                jsr AddItem
                ldx actIndex
                lda #$00
                sta temp4
                lda #ITEM_SECURITYPASS
                jsr DI_ItemNumber
                lda actD,x
                asl
                lda #$7f
                adc #$00
                ldx temp8
                jsr MoveActorX                  ;Move item to scientist's facing direction
                lda #-16*8
                jsr MoveActorY
                lda #SFX_PICKUP
                jsr PlaySfx
                lda #$00
                sta actScriptF                  ;No more script exec here
                ldy #ACT_SCIENTIST2
                gettext 0,5
                jmp SpeakLine

        ; Radio speech for upper labs entrance
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioUpperLabsEntrance:
                ldy #ITEM_SECURITYPASS
                jsr FindItem
                bcc RULI_NoPass
                lda #SFX_RADIO
                jsr PlaySfx
                lda #<txtRadioUpperLabsIntro
                ldx #>txtRadioUpperLabsIntro
                ldy #ACT_PLAYER
                jmp SpeakLine
RULI_NoPass:    ldy lvlObjNum
                jmp InactivateObject            ;Retry later to check for pass

        ; Persistent NPC table

npcX:           dc.b $39,$38,$17
npcY:           dc.b $28,$28,$30
npcF:           dc.b $30+AIMODE_TURNTO,$10+AIMODE_TURNTO,$30+AIMODE_TURNTO
npcT:           dc.b ACT_SCIENTIST2, ACT_SCIENTIST3,ACT_HACKER
npcWpn:         dc.b $00,$00,$00
npcOrg:         dc.b 1+ORG_GLOBAL,1+ORG_GLOBAL,4+ORG_GLOBAL

        ; Texts

txtRadioUpperLabsIntro:
                dc.b 34,"AMOS HERE. YOU'RE CLOSE TO THE UPPER LABS. SEE IF YOU CAN FIND ANY CLUES. "
                dc.b "IF NOT, YOU'LL HAVE TO PUSH ON TO THE HIGH-CLEARANCE LOWER LABS. "
                dc.b "ALSO LOOK FOR CODE-LOCKED ROOMS. THESE WERE PART OF THE 'HESSIAN' MILITARY CONTRACT, "
                dc.b "WHICH LED TO THE NANO-ENHANCEMENT TECHNOLOGY. IF YOU CAN FIND THE "
                dc.b "ENTRY CODES, YOU CAN IMPROVE YOUR ABILITIES FURTHER, AT THE COST OF INCREASED "
                dc.b "BATTERY USE.",34,0

                checkscriptend

