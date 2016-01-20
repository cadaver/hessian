                include macros.s
                include mainsym.s

        ; Script 2, early interactions and first bosses

CHUNK_DURATION = 40

                org scriptCodeStart

                dc.w GameStart
                dc.w Scientist1
                dc.w Scientist2
                dc.w RadioUpperLabsEntrance
                dc.w RadioSecurityCenter
                dc.w MoveRotorDrone
                dc.w DestroyRotorDrone
                dc.w Hacker
                dc.w Hacker2
                dc.w InstallAmplifier
                dc.w RunLaser
                dc.w SwitchGenerator
                dc.w SwitchLaser
                dc.w MoveGenerator
                dc.w MoveLargeSpider
                dc.w OpenWall
                dc.w MoveAcid
                dc.w RadioCaves
                dc.w RadioLowerLabs

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
                gettext TEXT_WAREHOUSE1
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
                gettext TEXT_WAREHOUSE2
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
                gettext TEXT_PARKINGGARAGE1
                jmp SpeakLine

S2_Dialogue2:   inc scriptVariable
                ldy #ACT_SCIENTIST3
                gettext TEXT_PARKINGGARAGE2
                jmp SpeakLine

S2_Dialogue3:   inc scriptVariable
                ldy #ACT_SCIENTIST2
                gettext TEXT_PARKINGGARAGE3
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
                gettext TEXT_PARKINGGARAGE4
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
                gettext TEXT_ENTERUPPERLABS
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
                gettext TEXT_ENTERSECURITYCENTER
                jmp RadioMsg
RSC_Skip:       rts

        ; Rotor drone boss move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveRotorDrone: lda actHp,x
                beq MRD_Fall
                lda #MUSIC_MAINTENANCE+1        ;If alive, play the bossfight music
                jsr PlaySong
                ldx actIndex
                lda #-1                         ;Stay higher than normal flyers
                sta actFall,x
                lda actCtrl,x
                and #JOY_FIRE
                beq MRD_NotFiring
                lda actCtrl,x                   ;Convert horizontal firing to diagonal down
                ora #JOY_DOWN
                sta actCtrl,x
MRD_NotFiring:  lda actYH,x                     ;Prevent going outside zone
                cmp limitU
                bcs MRD_NoLimitU
                lda actMoveCtrl,x
                and #$ff-JOY_UP
                ora #JOY_DOWN
                sta actMoveCtrl,x
                bne MRD_ControlsOK
MRD_NoLimitU:   adc #$00
                cmp limitD
                bne MRD_ControlsOK
                lda actMoveCtrl,x
                and #$ff-JOY_DOWN
                ora #JOY_UP
                sta actMoveCtrl,x
MRD_ControlsOK: jsr MoveAccelerateFlyer
                lda #$00
                ldy actSX,x
                bmi MRD_SpeedNeg
MRD_SpeedPos:   cpy #1*8
                bcc MRD_FrameOK
                lda #$08
                bne MRD_FrameOK
MRD_SpeedNeg:   cpy #-1*8+1
                bcs MRD_FrameOK
                lda #$04
MRD_FrameOK:    sta temp1
                inc actFd,x
                lda actFd,x
                and #$01
                ora temp1
                sta adRotorDroneFrames
                ora #$02
                sta adRotorDroneFrames+1
                jmp AttackGeneric
MRD_Fall:       jsr Random
                and #$01
                sta shakeScreen
                jsr FallingMotionCommon
                tay
                beq MRD_ContinueFall
                lda #MUSIC_MAINTENANCE          ;Back to the normal music
                jsr PlaySong
                ldx actIndex
                jmp ExplodeEnemy2_8             ;Drop item & explode at any collision
MRD_ContinueFall:
                jsr Random                      ;Spawn explosions randomly while falling
                and #$3f
                clc
                adc #$10
                adc actTime,x
                sta actTime,x
                bcc MRD_NoExplosion
                jsr GetAnyFreeActor
                bcc MRD_NoExplosion
                jsr SpawnActor                  ;Actor type undefined at this point, will be initialized below
                tya
                tax
                jsr ExplodeActor
                ldx actIndex
MRD_NoExplosion:
                rts

        ; Rotor drone boss destroy routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DestroyRotorDrone:
                lda #-2*8                       ;Give upward speed so that the fall lasts longer
                sta actSY,x
                lda #PLOT_HIDEOUTOPEN
                jmp SetPlotBit

        ; Hacker script routine (initial scene in the hideout)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Hacker:         jsr CheckDistance
                jsr AddQuestScore
                gettext TEXT_HACKER1PERCENT
                sta zpDestLo
                stx zpDestHi
H_Random:       jsr Random
                and #$03
                beq H_Random
                clc
                adc #$36                        ;Randomize between 75%, 85%, 95%
                ldy #$00
                sta (zpDestLo),y                ;Modify text resource
                lda #<EP_HACKER2
                sta actScriptEP+2               ;Set 2nd script
                gettext TEXT_HACKER1
H_SpeakCommon:  ldy #ACT_HACKER
                jmp SpeakLine

CheckDistance:  lda actXH+ACTI_PLAYER
                cmp #$1c
                bcc CD_Close
                pla                             ;If far, do not return
                pla
H_NoItem:
CD_Close:       rts

        ; Hacker script routine 2 (when picking up the amp)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Hacker2:        ldy #ITEM_AMPLIFIER
                jsr FindItem
                bcc H_NoItem
                lda actF1+ACTI_PLAYER           ;Wait until player is standing again
                cmp #FR_DUCK
                bcs H_NoItem
                lda #$00                        ;No more scripts for now
                sta actScriptF+2
                gettext TEXT_HACKER2
                jmp H_SpeakCommon

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
                jsr GetAnyFreeActor
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
                jsr SetMenuMode                 ;X=0 on return
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

        ; Large spider boss move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveLargeSpider:lda actHp,x
                bne MLS_Alive
MLS_Dying:      lda actXH,x                     ;Reached the wall?
                cmp #$3d
                bne MLS_DyingNoWall
                lda actXL,x
                cmp #$60
                bcs MLS_DyingNoWall
                jmp MLS_Explode
MLS_DyingNoWall:lda #<EP_OPENWALL               ;Wall script runs until spider no longer exists, then activates the wall object
                ldx #>EP_OPENWALL
                jsr SetScript
                ldx actIndex
                lda actFd,x
                and #$08
                beq MLS_DyingNoFlash
                lda #$0c
MLS_DyingNoFlash:
                sta actFlash,x
                jsr Random
                pha
                and #$01
                sta shakeScreen
                pla                             ;Spawn explosions randomly while retreating
                cmp #$20
                bcs MLS_NoDyingExplosion
                jsr GetAnyFreeActor
                bcc MLS_NoDyingExplosion
                jsr SpawnActor                  ;Actor type undefined at this point, will be initialized below
                tya
                tax
                jsr ExplodeActor
                jsr Random
                jsr MoveActorX
                dec actYH,x
                jsr Random
                sta actYL,x
                ldx actIndex
MLS_NoDyingExplosion:
                lda #JOY_LEFT
                bne MLS_ForcedMoveImmediate

MLS_Alive:      lda #MUSIC_CAVES+1
                jsr PlaySong
                ldx actIndex
MLS_Decision:   lda actXH,x                     ;Move forward when about to hit the left wall
                cmp #$3d
                bne MLS_NotAtWall
                lda #JOY_RIGHT
MLS_ForcedMoveImmediate:
                pha
                lda #$00                        ;After forced move, make next random decision
                sta actTime,x                   ;immediately
                pla
                bne MLS_StoreMove
MLS_NotAtWall:  cmp #$3e                        ;Do not perform retreat when almost at the wall
                beq MLS_NotTooClose             ;(too easy to exploit)
                ldy #ACTI_PLAYER
                lda actHp,y                     ;If already dead, no need
                beq MLS_NotTooClose
                jsr GetActorDistance            ;Get X-distance to player
                lda temp6
                bne MLS_NotTooClose             ;If too close, retreat
                lda actD+ACTI_PLAYER
                asl
                lda #JOY_LEFT
                bcc MLS_ForcedMoveImmediate
                asl
                bne MLS_ForcedMoveImmediate
MLS_NotTooClose:dec actTime,x
                bpl MLS_Move
                lda actAttackD+ACTI_PLAYER      ;If player is attacking now, always attack
                beq MLS_NoForcedAttack          ;as the next decision
                lda #$03
                bne MLS_ForcedMove
MLS_NoForcedAttack:
                jsr Random
                and #$03
                cmp #$02                        ;Do not attack twice in a row
                bcc MLS_ForcedMove
                ldy actMoveCtrl,x
                cpy #JOY_FIRE
                beq MLS_NoForcedAttack          ;Rerandomize in that case
MLS_ForcedMove: tay
                jsr Random
                and spiderDelayAndTbl,y
                clc
                adc #$10
                sta actTime,x
                lda spiderMoveTbl,y
MLS_StoreMove:  sta actMoveCtrl,x
MLS_Move:       jsr MoveGeneric
                lda actXL+ACTI_PLAYER
                cmp actXL,x
                lda actXH+ACTI_PLAYER           ;Override direction: always face player
                sbc actXH,x
                sta actD,x
                lda actSX,x
                jsr Asr8
                clc
                adc actFd,x
                bpl MLS_NotOverNeg
                clc
                adc #$60
MLS_NotOverNeg: cmp #$60
                bcc MLS_NotOverPos
                sbc #$60
MLS_NotOverPos: sta actFd,x
                lsr
                lsr
                lsr
                lsr
                lsr
                sta actF1,x
                lda actMoveCtrl,x               ;About to launch acid?
                cmp #JOY_FIRE
                bne MLS_NoAttack
                lda #2
                sta actF1,x
                lda #$40                        ;Reset walking animation after attack
                sta actFd,x
                lda actTime,x
                cmp #8
                bcs MLS_NoAttack
                cmp #4
                bcc MLS_NoAttack
                php
                inc actF1,x
                plp
                bne MLS_NoAttack

MLS_Attack:     lda #ACTI_FIRSTNPCBULLET
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc MLS_NoAttack
                lda #SFX_SHOTGUN
                jsr PlaySfx
                lda #<(-9*8)
                sta temp3
                lda #>(-9*8)
                sta temp4
                lda actD,x
                bmi MLS_AttackLeft
MLS_AttackRight:lda #<28*8
                sta temp1
                lda #>28*8
                sta temp2
                lda #ACT_ACID
                jsr SpawnWithOffset
                tya
                tax
                jsr InitActor
                lda #6*8+4
                sta actSX,x
                lda actXH,x
                sec
                sbc actXH+ACTI_PLAYER           ;Player is on the right -> negative
MLS_AttackCommon:
                asl
                asl
                adc #-3*8-2
                sta actSY,x
                ldx actIndex
MLS_NoAttack:   rts

MLS_AttackLeft: lda #<(-28*8)
                sta temp1
                lda #>(-28*8)
                sta temp2
                lda #ACT_ACID
                jsr SpawnWithOffset
                tya
                tax
                jsr InitActor
                lda #-6*8-4
                sta actSX,x
                lda actXH+ACTI_PLAYER
                sec
                sbc actXH,x                    ;Player is on the left -> negative
                jmp MLS_AttackCommon

MLS_Explode:    lda #MUSIC_CAVES
                jsr PlaySong
                ldx actIndex
                lda #-15*8
                jsr MoveActorYNoInterpolation
                lda #6
                ldy #$ff
                jsr ExplodeEnemyMultiple
                lda #-2*8-8
                sta temp7                       ;Initial base X-speed
                lda #0
                sta temp8                       ;Initial shape
MLS_ChunkLoop:  jsr GetAnyFreeActor
                bcc MLS_ChunkDone
                lda #ACT_SPIDERCHUNK
                jsr SpawnActor
                jsr Random
                and #$0f                        ;Randomize upward + sideways speed
                clc
                adc #-7*8
                sta actSY,y
                jsr Random
                and #$0f
                clc
                adc temp7
                sta actSX,y
                lda temp8
                sta actF1,y
                inc temp8
                lda #CHUNK_DURATION
                sta actTime,y
                lda temp7
                bpl MLS_ChunkDone
                clc
                adc #2*8
                sta temp7
                bne MLS_ChunkLoop
MLS_ChunkDone:  rts

        ; Script routine for opening the wall after spider death
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

OpenWall:       lda #ACT_LARGESPIDER            ;Run either when the spider has exploded, or player exits the zone
                jsr FindActor
                bcs OW_HasSpider
                ldy #7
                jsr ActivateObject
                jmp StopScript
MA_NotDone:
OW_HasSpider:   rts

        ; Acid move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveAcid:       lda actHp+ACTI_PLAYER
                beq MA_NoPlayerCollision
                lda #DMG_ACID
                jsr CollideAndDamagePlayer
                bcs MA_StartPlayerSplash
MA_NoPlayerCollision:
                jsr FallingMotionCommon
                tay                             ;Any collision -> splash
                bne MA_StartSplash
                lda #1
                ldy #3
                jmp LoopingAnimation
MA_StartSplash: lda #ACT_WATERSPLASH
                jsr TransformActor
MA_SplashCommon:jsr NoInterpolation
                lda #13
                sta actFlash,x
                lda #SFX_SPLASH
                jmp PlaySfx
MA_StartPlayerSplash:
                lda #ACT_EXPLOSION
                jsr TransformActor
                lda #-4*8
                jsr MoveActorY
                lda #2
                sta actF1,x
                bne MA_SplashCommon

        ; Radio speech when entering caves
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioCaves:     gettext TEXT_ENTERCAVES
                jmp RadioMsg

        ; Radio speech shortly after entering lower labs
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioLowerLabs: gettext TEXT_ENTERLOWERLABS
                jmp RadioMsg

        ; Variables

laserTime:      dc.b 0

        ; Persistent NPC table

npcX:           dc.b $39,$38,$17
npcY:           dc.b $28,$28,$30
npcF:           dc.b $30+AIMODE_TURNTO,$10+AIMODE_TURNTO,$30+AIMODE_TURNTO
npcT:           dc.b ACT_SCIENTIST2, ACT_SCIENTIST3,ACT_HACKER
npcWpn:         dc.b $00,$00,$00
npcOrg:         dc.b 1+ORG_GLOBAL,1+ORG_GLOBAL,4+ORG_GLOBAL

        ; Other tables

spiderMoveTbl:  dc.b JOY_LEFT,JOY_RIGHT,JOY_FIRE,JOY_FIRE
spiderDelayAndTbl:
                dc.b $1f,$1f,$07,$07
laserColorTbl:  dc.b $0c,$0e

        ; Messages

txtGeneratorOn: dc.b "GENERATOR ON",0
txtNoPower:     dc.b "NO POWER",0
txtAmpInstalled:dc.b "AMPLIFIER INSTALLED",0
txtCantInstall: dc.b "TURN OFF TO INSTALL",0

                checkscriptend
