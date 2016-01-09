                include macros.s
                include mainsym.s

        ; Script 5, laser + other interactions

                org scriptCodeStart

                dc.w SwitchGenerator
                dc.w SwitchLaser
                dc.w InstallAmplifier
                dc.w RunLaser
                dc.w MoveGenerator
                dc.w Scientist1
                dc.w CreatePersistentNPCs
                dc.w Scientist2

        ; Switch generator script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

SwitchGenerator:lda #PLOT_GENERATOR
                jsr GetPlotBit
                bne SG_AlreadyOn
                lda #PLOT_GENERATOR
                jsr SetPlotBit
                jsr AddQuestScore
                lda #<txtGeneratorOn
                ldx #>txtGeneratorOn
                ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText
SL_Broken:
SG_AlreadyOn:   rts

        ; Switch laser script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

SwitchLaser:    lda #PLOT_GENERATOR
                jsr GetPlotBit
                beq SL_NoPower
                lda lvlObjB+$2b                 ;Wall already opened?
                bmi SL_Broken
                ldy #$0f
                jsr ToggleObject
                lda #PLOT_AMPINSTALLED
                jsr GetPlotBit
                bne SL_IsAmplified
                rts
SL_NoPower:     lda #<txtNoPower
                ldx #>txtNoPower
SL_TextCommon:  ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText
SL_IsAmplified: lda #$00
                sta laserTime
                lda limitR
                sec
                sbc #10
                sta mapX
                lda #0
                sta blockX
                jsr RedrawScreen
                ldx #MENU_INTERACTION
                jsr SetMenuMode
                lda #<EP_RUNLASER
                ldx #>EP_RUNLASER
                jmp SetScript

        ; Install amplifier script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

InstallAmplifier:
                lda lvlObjB+$0e
                bpl IA_NotOpen
                lda lvlObjB+$0f
                bmi IA_IsLive
                jsr AddQuestScore
                lda #SFX_POWERUP
                jsr PlaySfx
                lda #PLOT_AMPINSTALLED
                jsr SetPlotBit
                ldy #ITEM_AMPLIFIER
                jsr RemoveItem
                lda #<txtAmpInstalled
                ldx #>txtAmpInstalled
                jmp SL_TextCommon
IA_IsLive:      lda #<txtCantInstall
                ldx #>txtCantInstall
                jsr SL_TextCommon
                lda #ACTI_FIRSTPLRBULLET
                ldy #ACTI_LASTPLRBULLET
                jsr GetFreeActor
                bcc IA_NoEffect
                tya
                tax
                lda lvlObjX+$0e
                sta actXH,x
                lda lvlObjY+$0e
                and #$7f
                sta actYH,x
                lda #$80
                sta actXL,x
                lda #$40
                sta actYL,x
                lda #ACT_EMP
                sta actT,x
                jsr InitActor
                lda #COLOR_FLICKER
                sta actFlash,x
                lda #8
                sta actTime,x
                lda #0
                sta actBulletDmgMod-ACTI_FIRSTPLRBULLET,x
                jsr NoInterpolation
IA_NoEffect:    ldx #ACTI_PLAYER
                lda #DMG_PISTOL+NOMODIFY
                jmp DamageSelf
IA_NotOpen:     rts

        ; Laser effect continuous script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RunLaser:       lda #0
                sta scrollSX                    ;Prevent scrolling by player position
                inc laserTime
                lda laserTime
                cmp #80
                bcc RL_Animate
                beq RL_Explode
                cmp #110
                bcs RL_Finish
                rts
RL_Animate:     and #$01
                tay
                lda laserColorTbl,y
                sta Irq1_Bg3+1
                tya
                bne RL_NoSound
                lda #SFX_DAMAGE
                jmp PlaySfx
RL_NoSound:     jsr Random
                pha
                and #$01
                sta shakeScreen
                pla
                cmp #$80
                bcs RL_NoNewExplosion
                lda #ACTI_FIRSTNPC              ;Use any free actors for explosions
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc RL_NoNewExplosion
                tya
                tax
                lda lvlObjX+$2b
                sta actXH,x
                lda lvlObjY+$2b
                and #$7f
                sta actYH,x
                jsr Random
                and #$7f
                clc
                adc #$40
                sta actXL,x
                jsr Random
                and #$3f
                sta actYL,x
                lda #ACT_EXPLOSION
                sta actT,x
                jsr InitActor
RL_NoNewExplosion:
                rts
RL_Explode:     ldy #$0f
                jsr ToggleObject
                ldy #$2b
                jsr ToggleObject
                jsr AddQuestScore
                lda #SFX_EXPLOSION
                jmp PlaySfx
RL_Finish:      jsr StopScript
                ldx #MENU_NONE
                jsr SetMenuMode
                jmp CenterPlayer

        ; Generator (screen shake) move routine
        ;
        ; Parameters: X actor number
        ; Returns: -
        ; Modifies: various

MoveGenerator:  lda #PLOT_GENERATOR
                jsr GetPlotBit
                beq MG_NotOn
                inc actFd,x
                lda actFd,x
                and #$01
                sta shakeScreen
                inc actTime,x
                lda actTime,x
                cmp #$03
                bcc MG_NoSound
                lda #SFX_GENERATOR
                jsr PlaySfx
                lda #$00
                sta actTime,x
MG_NoSound:
MG_NotOn:       rts

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
                lda #<txtIntroDialogue
                ldx #>txtIntroDialogue
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
                lda #<txtDyingDialogue
                ldx #>txtDyingDialogue
                jmp SpeakLine
S1_DieAgain:    inc scriptVariable
                lda #DEATH_FLICKER_DELAY+25
                sta actTime,x
                lda #FR_DIE+2
                sta actF1,x
                sta actF2,x
                dec actHp,x
                lda #ITEM_PISTOL
                jsr DI_ItemNumber
                ldx temp8
                lda #10
                sta actHp,x                     ;Full mag
S1_DoNothing:   rts

S1_LimitControl:lda #JOY_RIGHT|JOY_LEFT|JOY_DOWN|JOY_UP ;Don't allow entering the container in the beginning,
                ldy actXH+ACTI_PLAYER                   ;or going too far to the left
                cpy #$67
                bcs S1_LimitLeft
                lda #JOY_RIGHT|JOY_DOWN
S1_LimitLeft:   and joystick
                sta joystick
                rts

        ; Create persistent NPCs to the leveldata
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

CreatePersistentNPCs:
                ldx #MAX_PERSISTENTNPCS-1
CPNPC_Loop:     jsr GetLevelActorIndex
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
                bpl CPNPC_Loop
                lda #<EP_SCIENTIST2         ;Initial script to drive the plot forward
                sta actEP
                lda #>EP_SCIENTIST2
                sta actScript
S2_Wait:        rts

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

S2_JumpTbl:     dc.w S2_Dialogue1
                dc.w S2_Dialogue2
                dc.w S2_Dialogue3
                dc.w S2_Stop

S2_Dialogue1:   inc scriptVariable
                ldy #ACT_SCIENTIST2
                lda #<txtHideoutDialogue1
                ldx #>txtHideoutDialogue1
                jmp SpeakLine

S2_Dialogue2:   inc scriptVariable
                ldy #ACT_SCIENTIST3
                lda #<txtHideoutDialogue2
                ldx #>txtHideoutDialogue2
                jmp SpeakLine

S2_Dialogue3:   inc scriptVariable
                ldy #ACT_SCIENTIST2
                lda #<txtHideoutDialogue3
                ldx #>txtHideoutDialogue3
                jmp SpeakLine

S2_Stop:        ldy #$1a                        ;Show the passcard on the table
                jsr ActivateObject
                lda #ITEM_SECURITYPASS
                jsr AddQuestItem
                lda #ITEM_COMMGEAR
                jsr AddQuestItem
                lda #SFX_PICKUP
                jsr PlaySfx
                lda #$00
                sta actScript                   ;No more script exec
                rts
                
AddQuestItem:   ldx #1
                jmp AddItem


        ; Variables

laserTime:      dc.b 0

        ; Tables

laserColorTbl:  dc.b $0c,$0e

        ; Persistent NPC table

npcX:           dc.b $39,$38
npcY:           dc.b $28,$28
npcF:           dc.b $30+AIMODE_TURNTO,$10+AIMODE_TURNTO
npcT:           dc.b ACT_SCIENTIST2, ACT_SCIENTIST3
npcWpn:         dc.b $00,$00
npcOrg:         dc.b 1+ORG_GLOBAL,1+ORG_GLOBAL

        ; Messages

txtGeneratorOn: dc.b "GENERATOR ON",0
txtNoPower:     dc.b "NO POWER",0
txtAmpInstalled:dc.b "AMPLIFIER INSTALLED",0
txtCantInstall: dc.b "TURN OFF TO INSTALL",0
txtIntroDialogue:
                dc.b 34,"GOOD, YOU'RE ON YOUR FEET. I'M VIKTOR - WE NEED TO REACH THE OTHERS, WHO ARE HOLED UP ON THE PARKING GARAGE BOTTOM LEVEL. FOLLOW ME.",34,0
txtDyingDialogue:
                dc.b 34,"ARGH, I'M NO GOOD TO GO ON. SEARCH THE UPSTAIRS - YOU'LL NEED A PASSCARD WE USED TO LOCK UP THIS PLACE. "
                dc.b "WATCH OUT FOR MORE OF THOSE BASTARDS.. AND ONE FINAL THING - THE NANO-BOTS RUNNING YOUR BODY DEPEND ON BATTERY POWER. "
                dc.b "DON'T RUN OUT.",34,0
txtHideoutDialogue1:
                dc.b 34,"I SEE VIKTOR DIDN'T MAKE IT. BUT YOU DID, THAT'S WHAT COUNTS. AMOS, NANOSURGEON. SHE'S LINDA, CYBER-PSYCHOLOGIST. "
                dc.b "AS YOU'VE SEEN, OUR CREATIONS HAVE TURNED ON US. TOTAL OUTSIDE BLACKOUT. WE'RE STUCK AND HELP IS UNLIKELY. "
                dc.b "AS THE ONLY AUGMENTED PERSON IN THIS ROOM, RIGHT NOW YOU'RE OUR BEST BET.",34,0
txtHideoutDialogue2:
                dc.b 34,"COMMON SENSE WOULD DICTATE AN ESCAPE ATTEMPT. BUT THE ROBOTS' HIGHLY COORDINATED ACTIONS "
                dc.b "SUGGEST A CENTRAL INTELLIGENCE, WHICH I DIDN'T KNOW WE HAD DEVELOPED. "
                dc.b "THERE CAN BE MORE THAN OUR LIVES AT STAKE.",34,0
txtHideoutDialogue3:
                dc.b 34,"YES. WE MUST FIND OUT THEIR ULTIMATE AIM BEYOND JUST KILLING EVERYONE. "
                dc.b "TAKE THIS SECURITY PASS TO ACCESS THE UPPER LABS. PLUS A WIRELESS CAMERA/RADIO SET "
                dc.b "SO WE CAN STAY IN TOUCH. GOOD LUCK.",34,0

                checkscriptend