FR_STAND        = 0
FR_WALK         = 1
FR_JUMP         = 9
FR_DUCK         = 12
FR_ENTER        = 14
FR_CLIMB        = 15
FR_DIE          = 19
FR_ROLL         = 22
FR_SWIM         = 28
FR_PREPARE      = 32
FR_ATTACK       = 34

DEATH_DISAPPEAR_DELAY = 50
DEATH_FLICKER_DELAY = 20
DEATH_HEIGHT    = -3                            ;Ceiling check height for dead bodies
DEATH_ACCEL     = 6
DEATH_YSPEED    = -5*8
DEATH_MAX_XSPEED = 6*8
DEATH_BRAKING   = 6
DEATH_WATER_YBRAKING = 3                        ;Extra braking for corpses in water

WATER_XBRAKING = 3
WATER_YBRAKING = 3

HUMAN_MAX_YSPEED = 6*8

DAMAGING_FALL_DISTANCE = 4

INITIAL_GROUNDACC = 5
INITIAL_INAIRACC = 1
INITIAL_GROUNDBRAKE = 6
INITIAL_JUMPSPEED = 40
INITIAL_CLIMBSPEED = 84
INITIAL_HEALTIMER = 4

UPGRADE_DAMAGE_MODIFY = 6
UPGRADE_ATTACK_MODIFY = 12
UPGRADE_RELOADTIME_MODIFY = 6

HEALTIMER_RESET = $c0

DIFFICULTY_EASY = 0
DIFFICULTY_MEDIUM = 1
DIFFICULTY_HARD = 2

MAX_OXYGEN      = 200
MAX_BATTERY     = 56
LOW_BATTERY     = MAX_BATTERY/4
LOW_HEALTH      = HP_PLAYER/4

DRAIN_WALK      = 3                             ;At footstep sound, 6 per anim. cycle
DRAIN_SWIM      = 24                            ;When animation wraps
DRAIN_CLIMB     = 6                             ;At footstep sound, 12 per anim. cycle
DRAIN_JUMP      = 16
DRAIN_ROLL      = 20
DRAIN_MELEE     = 20
DRAIN_HEAL      = 96
DRAIN_EMP       = 128

UPG_MOVEMENT    = 1
UPG_STRENGTH    = 2
UPG_FIREARMS    = 4
UPG_ARMOR       = 8
UPG_HEALING     = 16
UPG_DRAIN       = 32
UPG_RECHARGE    = 64
UPG_TOXINFILTER = 128

        ; Player update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MovePlayer:     lda actCtrl+ACTI_PLAYER         ;Get new joystick controls
                sta actPrevCtrl+ACTI_PLAYER
                ldy #$00
                cpy menuMode                    ;When in inventory, no new controls
                bne MP_Scroll
                ldy actF1+ACTI_PLAYER
                cpy #FR_DUCK+1
                bne MP_NoDuckFirePrevent
                cmp #JOY_DOWN                   ;Prevent fire+down immediately after ducking
                bne MP_NoDuckFirePrevent        ;(need to release down direction first)
                lda joystick
                cmp #JOY_DOWN+JOY_FIRE
                bne MP_NoDuckFirePrevent
                ldy #$ff-JOY_FIRE
                bne MP_StoreControlMask
MP_NoDuckFirePrevent:
                lda joystick
                cmp #JOY_DOWN+JOY_FIRE
                beq MP_ControlMask
                ldy #$ff
MP_StoreControlMask:
                sty MP_ControlMask+1
MP_ControlMask: and #$ff
                sta actCtrl+ACTI_PLAYER
                cmp #JOY_FIRE
                bcc MP_NewMoveCtrl
                and #$0f                        ;When fire held down, eliminate the opposite
                tay                             ;directions from the previous move control
                lda moveCtrlAndTbl,y
                ldy actF1+ACTI_PLAYER
                cpy #FR_DUCK+1                  ;When already ducked, keep the down control
                bne MP_NotDucked
                ora #JOY_DOWN
MP_NotDucked:   and actMoveCtrl+ACTI_PLAYER
MP_NewMoveCtrl: sta actMoveCtrl+ACTI_PLAYER
MP_Scroll:      ldy #ZONEH_BG3
                lda (zoneLo),y
                bmi MP_SetWeapon                ;Scroll-disabled zone?
                jsr GetActorCharCoords          ;Check scrolling
                cmp #SCRCENTER_X-1
                bcs MP_NotLeft1
                dex
MP_NotLeft1:    cmp #SCRCENTER_X
                bcs MP_NotLeft2
                dex
MP_NotLeft2:    cmp #SCRCENTER_X+1
                bcc MP_NotRight1
                inx
MP_NotRight1:   cmp #SCRCENTER_X+2
                bcc MP_NotRight2
                inx
MP_NotRight2:   stx scrollSX
                ldx #$00
                cpy #SCRCENTER_Y-2
                bcs MP_NotUp1
                dex
MP_NotUp1:      cpy #SCRCENTER_Y
                bcs MP_NotUp2
                dex
MP_NotUp2:      cpy #SCRCENTER_Y+1
                bcc MP_NotDown1
                inx
MP_NotDown1:    cpy #SCRCENTER_Y+3
                bcc MP_NotDown2
                inx
MP_NotDown2:    stx scrollSY
MP_SetWeapon:   ldy itemIndex
                cpy #ITEM_FIRST_NONWEAPON
                bcc MP_WeaponOK
                ldy #ITEM_NONE
MP_WeaponOK:    sty actWpn+ACTI_PLAYER
                ldx #ACTI_PLAYER
                jmp MoveAndAttackHuman          ;Finally move player and handle weapon

        ; Humanoid character move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MH_DeathAnim:   lda #DEATH_HEIGHT               ;Actor height for ceiling check
                sta temp4
                lda #DEATH_ACCEL
                ldy #HUMAN_MAX_YSPEED
                jsr MoveWithGravity
                lsr
                bcs MH_DeathGrounded            ;If grounded, animate faster
                and #MB_HITWALL/2               ;If hit wall, zero X-speed
                beq MH_DeathNoHitWall
                lda #$00
                sta actSX,x
MH_DeathNoHitWall:
                lda #$06
                ldy #FR_DIE+1
                bne MH_DeathAnimDelay
MH_DeathGrounded:
                lda #DEATH_BRAKING
                jsr BrakeActorX
                lda #$02
                ldy #FR_DIE+2
MH_DeathAnimDelay:
                jsr OneShotAnimation
                lda actF1,x
                sta actF2,x
MH_DeathAnimDone:
                dec actTime,x
                bmi MH_DeathRemove
                lda actTime,x
                cmp #DEATH_FLICKER_DELAY
                bne MH_DeathDone
                lda #COLOR_FLICKER
                sta actFlash,x
MH_DeathDone:   rts
MH_DeathRemove: jmp RemoveActor

MoveHuman:      lda actMB,x
                sta temp1                       ;Movement state bits
                bpl MH_NotInWater
                lda #WATER_XBRAKING             ;Global water braking, both for alive & dead characters
                jsr BrakeActorX
                lda actF1,x                     ;Allow jump in water to begin without braking
                cmp #FR_JUMP                    ;(so that can get out of water)
                beq MH_NoYBraking
                lda actHp,x
                cmp #$01
                lda #WATER_YBRAKING
                bcs MH_NoFloating
                adc #DEATH_WATER_YBRAKING       ;Extra buoyancy for corpses
MH_NoFloating:  jsr BrakeActorY
MH_NoYBraking:
MH_NotInWater:  lda actD,x
                sta MH_OldDir+1
                ldy #AL_SIZEUP                  ;Set size up based on currently displayed
                lda (actLo),y                   ;frame
                ldy actF1,x
                sec
                sbc humanSizeReduceTbl,y
                sta actSizeU,x
                lda #$00                        ;Roll flag
                sta temp2
                ldy #AL_MOVEFLAGS
                lda (actLo),y
                sta temp3                       ;Movement capability flags
                iny
                lda (actLo),y
                sta temp4                       ;Movement speed
                lda temp1
                lsr                             ;Check after fall-effects (forced duck, damage)
                bcc MH_NoFallCheck
                ldy actFall,x
                beq MH_NoFallCheck
                and #MB_LANDED/2                ;Falling damage applied right after landing
                beq MH_NoFallDamage
                lda temp3                       ;Possibility to reduce damage by rolling
                and #AMF_ROLL
                beq MH_NoRollSave
                lda actSX,x                     ;Must be facing move direction and have some X-speed
                beq MH_NoRollSave
                eor actD,x
                bmi MH_NoRollSave
                lda actMoveCtrl,x
                and #JOY_DOWN|JOY_LEFT|JOY_RIGHT
                cmp #JOY_DOWN+1
                bcc MH_NoRollSave
                lda #$01
                sta actPrevCtrl,x               ;Reset prevctrl to allow roll regardless of timing
                sta actFall,x                   ;Also reset remaining forced ducking from fall
                dey
MH_NoRollSave:  sec
                tya
                sbc #DAMAGING_FALL_DISTANCE
                bcc MH_NoFallDamage2
                beq MH_NoFallDamage2
                asl
                sta temp8
                asl
                adc temp8
                ora #$80                        ;No modify (do not affect armor either)
                jsr DamageSelf
MH_NoFallDamage2:
                jsr PlayFootstepCheckPlayer
MH_NoFallDamage:dec actFall,x
MH_NoFallCheck: lda actF1,x                     ;Check for special movement states
                cmp #FR_CLIMB
                bcc MH_NoSpecial
                cmp #FR_SWIM
                bcs MH_IsSwimming
                cmp #FR_ROLL
                bcs MH_IsRolling
                cmp #FR_DIE
                bcs MH_IsDying
                jmp MH_Climbing
MH_IsDying:     jmp MH_DeathAnim
MH_IsSwimming:  jmp MH_Swimming
MH_IsRolling:   inc temp2
                bne MH_RollAcc
MH_NoSpecial:   cmp #FR_DUCK+1
                lda actMoveCtrl,x               ;Check turning / X-acceleration / braking
                and #JOY_LEFT|JOY_RIGHT
                beq MH_Brake
                and #JOY_RIGHT
                bne MH_TurnRight
                lda #$80
MH_TurnRight:   sta actD,x
                bcs MH_Brake2                   ;If ducking, only turn, then brake
MH_RollAcc:     lda temp1
                bpl MH_NoWaterMaxSpeed
                lsr temp4                       ;If in water, halve max speed
MH_NoWaterMaxSpeed:
                lsr                             ;Faster acceleration when on ground
                ldy #AL_GROUNDACCEL
                bcs MH_UseGroundAccel
                iny
MH_UseGroundAccel:
                lda actD,x
                asl                             ;Direction to carry
                lda (actLo),y
                ldy temp4
                jsr AccActorXNegOrPos
                jmp MH_HorizMoveDone
MH_Brake:       lda temp1                       ;Only brake when grounded
                lsr
                bcc MH_HorizMoveDone
MH_Brake2:      ldy #AL_BRAKING
                lda (actLo),y
                jsr BrakeActorX
MH_HorizMoveDone:
                lda temp1
                and #MB_HITWALL|MB_LANDED       ;If hit wall (and did not land simultaneously), reset X-speed
                cmp #MB_HITWALL
                bne MH_NoHitWall
                lda temp3
                and #AMF_WALLFLIP
                beq MH_NoWallFlip
                lda temp1                       ;Check for wallflip (push joystick up & opposite to wall)
                lsr
                bcs MH_NoWallFlip
                lda actSY,x                     ;Must not have started descending yet
                bpl MH_NoWallFlip
                lda #JOY_UP|JOY_RIGHT
                ldy actSX,x
                beq MH_NoWallFlip
                bmi MH_WallFlipRight
                lda #JOY_UP|JOY_LEFT
MH_WallFlipRight:
                cmp actMoveCtrl,x
                bne MH_NoWallFlip
                cmp #JOY_UP|JOY_RIGHT
                jsr GetSignedHalfSpeed
                sta actSX,x
                bne MH_StartJump
MH_NoWallFlip:  lda #$00
                sta actSX,x
MH_NoHitWall:   lda temp1
                lsr                             ;Grounded bit to C
                and #MB_HITCEILING/2            ;If ceiling hitting head, do not allow jump
                bne MH_NoNewJump
                bcc MH_NoNewJump
                lda actCtrl,x                   ;When holding fire can not initiate jump
                and #JOY_FIRE                   ;or grab a ladder
                bne MH_NoNewJump
                lda actFall,x                   ;If still in falling autoduck mode,
                bne MH_NoNewJump                ;no new jump
                lda actMoveCtrl,x               ;If on ground, can initiate a jump
                and #JOY_UP                     ;except if in the middle of a roll
                beq MH_NoNewJump
                lda temp2
                bne MH_NoNewJump
                txa                             ;If player, check for operating levelobjects
                bne MH_NoOperate
                ldy lvlObjNum
                bmi MH_NoOperate
                lda actMoveCtrl+ACTI_PLAYER
                cmp #JOY_UP                     ;Must be holding only UP to operate
                bne MH_NoOperate
                jsr OperateObject
                ldx #ACTI_PLAYER
                bcs MH_NoNewJump
MH_NoOperate:   lda temp3
                and #AMF_CLIMB
                beq MH_NoInitClimbUp
                jsr GetCharInfo4Above           ;Jump or climb?
                and #CI_CLIMB
                beq MH_NoInitClimbUp
                jmp MH_InitClimb
MH_NoInitClimbUp:
                lda actMoveCtrl,x               ;Jump requires left/right input (as in MW4)
                and #JOY_LEFT|JOY_RIGHT
                beq MH_NoNewJump
                lda temp3
                and #AMF_JUMP
                beq MH_NoNewJump
                lda actPrevCtrl,x
                and #JOY_UP
                bne MH_NoNewJump
MH_StartJump:   ldy #AL_JUMPSPEED
                lda (actLo),y
                sta actSY,x
                txa
                bne MH_JumpNoPlayer
                lda #UPG_MOVEMENT
                ldy #DRAIN_JUMP
                jsr DrainBatteryDouble
                lda #SFX_JUMP
                jsr PlayMovementSound
MH_JumpNoPlayer:jsr MH_ResetGrounded
MH_NoNewJump:   ldy #AL_HEIGHT                  ;Actor height for ceiling check
                lda (actLo),y
                sta temp4
                ldy #AL_FALLACCEL               ;Make jump longer by holding joystick up
                lda actSY,x                     ;as long as still has upward velocity
                bpl MH_NoLongJump
                lda actMoveCtrl,x
                and #JOY_UP
                beq MH_NoLongJump
                ldy #AL_LONGJUMPACCEL
MH_NoLongJump:  lda (actLo),y
                ldy #HUMAN_MAX_YSPEED
                jsr MoveWithGravity             ;Actually move & check collisions
                bpl MH_NoWater                  ;If in water, check for starting to swim
                lda #-3
                jsr GetCharInfoOffset           ;Must be deep in water before
                and #CI_WATER                   ;swimming kicks in
                beq MH_NoWater2
                txa                             ;If not player, kill instantly
                beq MH_CanSwim
                ldy #NODAMAGESRC
                jmp DestroyActor
MH_CanSwim:     jmp MH_InitSwim

MH_NoWater2:    lda actMB,x
MH_NoWater:     lsr                             ;Grounded bit to carry
                bcc MH_InAir
                jmp MH_OnGround

MH_InAir:       and #MB_STARTFALLING/2          ;Just dropped off a ledge?
                bne MH_StartedToFall
MH_InAirAnim:   lda actSY,x
                bpl MH_IncFall
                cmp #-2*8                       ;Do not grab when moving up fast
                bcc MH_JumpAnim
                bcs MH_NoIncFall
MH_IncFall:     lda temp3
                and #AMF_NOFALLDAMAGE
                bne MH_NoIncFall
                lda actSY,x
                bmi MH_NoIncFall
                asl
                adc actFallL,x
                sta actFallL,x
                bcc MH_NoIncFall
                inc actFall,x
MH_NoIncFall:   lda actMoveCtrl,x               ;Check for grabbing a ladder while in midair
                and #JOY_UP
                beq MH_JumpAnim
                lda actCtrl,x                   ;If fire is held, do not grab ladder
                and #JOY_FIRE
                bne MH_JumpAnim
                lda temp3
                and #AMF_CLIMB
                beq MH_JumpAnim
                jsr GetCharInfo4Above
                and #CI_CLIMB
                beq MH_JumpAnim
                jmp MH_InitClimb
MH_JumpAnim:    ldy #FR_JUMP+1
                lda actSY,x
                bpl MH_JumpAnimDown
MH_JumpAnimUp:  cmp #-1*8
                bcs MH_JumpAnimDone
                dey
                bcc MH_JumpAnimDone
MH_JumpAnimDown:cmp #2*8
                bcc MH_JumpAnimDone
                iny
MH_JumpAnimDone:tya
                jmp MH_AnimDone

MH_StartedToFall:
                jsr MH_ResetFall
                lda actAIHelp,x                 ;Check AI reactions to falling
                and #AIH_AUTOSCALEWALL
                beq MH_NoDropDown
                lda #3                          ;Allow drop down if ground reasonably close
                jsr GetCharInfoOffset
                and #CI_GROUND|CI_OBSTACLE
                bne MH_InAirAnim
MH_NoDropDown:  lda actAIHelp,x                 ;Check autoturn or stop
                and #AIH_AUTOTURNLEDGE|AIH_AUTOSTOPLEDGE
                beq MH_InAirAnim                ;If none, just fall
                php
                lda actSX,x
                jsr MoveActorXNeg
                jsr MH_SetGrounded
                plp
                bpl MH_DoAutoTurn
MH_DoAutoStop:  lda #$00
                sta actSX,x
                sta actMoveCtrl,x
                beq MH_NoAutoTurn

MH_OnGround:    and #MB_HITWALL/2
                beq MH_NoAutoTurn
                lda actAIHelp,x                 ;Check AI autoturning/jumping if hit wall
                and #AIH_AUTOSCALEWALL
                beq MH_NoAutoScale
                ldy #1
                lda actD,x
                bpl MH_CheckWallRight
                ldy #-1
MH_CheckWallRight:
                lda #-3
                jsr GetCharInfoXYOffset         ;Check that the wall is possible to scale
                and #CI_OBSTACLE|CI_SHELF       ;Do not jump to nonnavigable ledge, which could
                bne MH_NoAutoScale              ;lead to a drop
                jmp MH_StartJump
MH_NoAutoScale: lda actAIHelp,x
                and #AIH_AUTOTURNWALL
                beq MH_NoAutoTurn
MH_DoAutoTurn:  lda actSX,x
                eor actD,x
                bmi MH_NoAutoTurn
                ldy #JOY_LEFT
                lda actD,x
                eor #$80
                bmi MH_AutoTurnLeft
                ldy #JOY_RIGHT
MH_AutoTurnLeft:sta actD,x
                tya
                sta actMoveCtrl,x
MH_NoAutoTurn:  ldy temp2                       ;If rolling, continue roll animation
                beq MH_GroundAnim

MH_RollAnim:    lda #$01
                jsr AnimationDelay
                bcc MH_AnimDone3
                lda actF1,x
                adc #$00
                cmp #FR_ROLL+6                  ;Transition from roll to low duck
                bcc MH_RollAnimDone
                lda actMB,x                     ;If rolling and falling, transition
                lsr                             ;to jump instead
                bcs MH_RollToDuck
MH_RollToJump:  lda #FR_JUMP+2
                skip2
MH_RollToDuck:  lda #FR_DUCK+1
MH_RollAnimDone:jmp MH_AnimDone
MH_AnimDone3:   rts

MH_GroundAnim:  lda actFall,x                   ;Forced duck after falling
                bne MH_NoInitClimbDown
                lda actMoveCtrl,x
                and #JOY_DOWN
                beq MH_NoDuck
MH_NewDuckOrRoll:
                lda temp3
                and #AMF_ROLL
                beq MH_NoNewRoll
                lda actMB,x                     ;Can't roll in water
                bmi MH_NoNewRoll
                lda actMoveCtrl,x               ;To initiate a roll, must push the
                cmp actPrevCtrl,x               ;joystick diagonally down
                beq MH_NoNewRoll
                and #JOY_LEFT|JOY_RIGHT
                beq MH_NoNewRoll
                lda actD,x
MH_OldDir:      eor #$00
                and #$80
                bne MH_NoNewRoll                ;Also, must not have turned
MH_StartRoll:   lda #$00
                sta actFd,x
                txa
                bne MH_RollNoPlayer
                lda #UPG_MOVEMENT
                ldy #DRAIN_ROLL
                jsr DrainBatteryDouble
                lda #SFX_ROLL
                jsr PlayMovementSound
MH_RollNoPlayer:lda #FR_ROLL
                jmp MH_AnimDone
MH_NoNewRoll:   lda temp3
                and #AMF_CLIMB
                beq MH_NoInitClimbDown
                lda actCtrl,x                   ;When holding fire can not initiate climbing
                and #JOY_FIRE
                bne MH_NoInitClimbDown
                jsr GetCharInfo                 ;Duck or climb?
                and #CI_CLIMB
                beq MH_NoInitClimbDown
                jmp MH_InitClimb
MH_NoInitClimbDown:
                lda temp3
                and #AMF_DUCK
                beq MH_NoDuck
                lda actF1,x
                cmp #FR_DUCK
                bcs MH_DuckAnim
                lda #$00
                sta actFd,x
                lda #FR_DUCK
                jmp MH_AnimDone
MH_DuckAnim:    lda #$01
                jsr AnimationDelay
                bcs MH_DuckAnimFrame
                rts
MH_DuckAnimFrame:
                lda actF1,x
                adc #$00
                cmp #FR_DUCK+2
                bcc MH_AnimDone
                lda #FR_DUCK+1
                bne MH_AnimDone
MH_NoDuck:      lda actF1,x                     ;If door enter/operate object animation,
                cmp #FR_ENTER                   ;hold it as long as joystick is held up
                bne MH_NoEnterAnim
                lda actMoveCtrl,x
                cmp #JOY_UP
                bne MH_StandAnim
                beq MH_AnimDone2
MH_NoEnterAnim: cmp #FR_DUCK
                bcc MH_StandOrWalk
MH_DuckStandUpAnim:
                lda #$01
                jsr AnimationDelay
                bcc MH_AnimDone2
                lda actF1,x
                sbc #$01
                cmp #FR_DUCK
                bcc MH_StandAnim
                bcs MH_AnimDone
MH_StandOrWalk: lda actMB,x
                and #MB_HITWALL
                bne MH_StandAnim
MH_WalkAnim:    lda actMoveCtrl,x
                and #JOY_LEFT|JOY_RIGHT
                beq MH_StandAnim
                lda actSX,x
                asl
                bcc MH_WalkAnimSpeedPos
                eor #$ff
                adc #$00
MH_WalkAnimSpeedPos:
                adc #$40
                adc actFd,x
                sta actFd,x
                bcc MH_AnimDone2
                lda actF1,x
                adc #$00
                cmp #FR_WALK+8
                bcc MH_NoWalkAnimWrap
                lda #FR_WALK
MH_NoWalkAnimWrap:
                cpx #ACTI_PLAYER
                bne MH_AnimDone
                pha
                and #$03
                cmp #$02
                bne MH_NoWalkFootstep
                jsr PlayFootstep
                lda #UPG_MOVEMENT
                ldy #DRAIN_WALK
                jsr DrainBatteryDouble          ;Drain battery at each footstep
MH_NoWalkFootstep:
                pla
MH_AnimDone:    sta actF1,x
                sta actF2,x
MH_AnimDone2:   rts
MH_StandAnim:   lda #$00                        ;0 = standing frame
                sta actFd,x
                beq MH_AnimDone

MH_InitClimb:   lda #$80
                sta actXL,x
                sta actFd,x
                lda actYL,x
                and #$e0
                sta actYL,x
                and #$30
                cmp #$20
                lda #FR_CLIMB
                adc #$00
                sta actF1,x
                sta actF2,x
                lda #$00
                sta actSX,x
                sta actSY,x
                jmp NoInterpolation

MH_InitSwim:    lda actSY,x
                bmi MH_SwimNoYSpeedMod          ;If falling down, reduce speed when hit water
                ldy #6
                jsr ModifyDamage                ;Hack: modifydamage used for multiplying Y-speed
                sta actSY,x
MH_SwimNoYSpeedMod:
                lda #FR_SWIM
                jmp MH_AnimDone

MH_Climbing:    jsr GetCharInfo
                sta temp1
                sta actGroundCharInfo,x         ;Store char info for AI, like walking physics does
                and #CI_WATER                   ;Store updated state of water bit
                beq MH_ClimbNotInWater          ;for climbing out of water
                lda #MB_INWATER
MH_ClimbNotInWater:
                sta actMB,x
                ldy #AL_CLIMBSPEED
                lda (actLo),y
                sta zpSrcLo
                lda actF1,x                     ;Reset frame in case attack ended
                sta actF2,x
                lda actMoveCtrl,x
                lsr
                bcc MH_NoClimbUp
                jmp MH_ClimbUp
MH_NoClimbUp:   lsr
                bcs MH_ClimbDown
                lda actMoveCtrl,x               ;Exit ladder?
                and #JOY_LEFT|JOY_RIGHT
                beq MH_ClimbDone
                lsr                             ;Left bit to direction
                lsr
                lsr
                ror
                sta actD,x
                lda temp1                       ;Check ground bit
                lsr
                bcs MH_ClimbExit
                lda actYL,x                     ;If half way a char, check also 1 char
                and #$20                        ;below
                beq MH_ClimbDone
                jsr GetCharInfo1Below
                lsr
                bcc MH_ClimbDone
MH_ClimbExitBelow:
                lda #8*8
                jsr MoveActorY
MH_ClimbExit:   lda actYL,x
                and #$c0
                sta actYL,x
                jsr MH_SetGrounded
                jsr NoInterpolation
                jmp MH_StandAnim

MH_ClimbDown:   lda temp1
                and #CI_CLIMB
                beq MH_ClimbDone
                ldy #4*8
                bne MH_ClimbCommon
MH_ClimbDone:   rts

MH_ClimbUp:     jsr GetCharInfo4Above
                sta temp8
                and #CI_OBSTACLE
                bne MH_ClimbUpNoJump
                lda actMoveCtrl,x               ;Check for exiting the ladder
                cmp actPrevCtrl,x               ;by jumping
                beq MH_ClimbUpNoJump
                and #JOY_LEFT|JOY_RIGHT
                beq MH_ClimbUpNoJump
                lda temp1                       ;If in the middle of an obstacle
                and #CI_OBSTACLE                ;block, can not exit by jump
                bne MH_ClimbUpNoJump
                lda #-2
                jsr GetCharInfoOffset
                and #CI_OBSTACLE
                bne MH_ClimbUpNoJump
                lda actMoveCtrl,x
                cmp #JOY_RIGHT
                jsr GetSignedHalfSpeed
                sta actSX,x
                sta actD,x
                jmp MH_StartJump
MH_ClimbUpNoJump:
                lda actYL,x
                and #$20
                bne MH_ClimbUpOk
                lda temp8
                and #CI_CLIMB
                beq MH_ClimbDone
MH_ClimbUpOk:   ldy #-4*8
MH_ClimbCommon: lda zpSrcLo                     ;Climbing speed
                clc
                adc actFd,x
                sta actFd,x
                bcc MH_ClimbDone
                lda #$01                        ;Add 1 or 3 depending on climbing dir
                cpy #$80
                bcc MH_ClimbAnimDown
                lda #$02                        ;C=1, add one less
MH_ClimbAnimDown:
                adc actF1,x
                sbc #FR_CLIMB-1                 ;Keep within climb frame range
                and #$03
                adc #FR_CLIMB-1
                sta actF1,x
                sta actF2,x
                lsr
                php
                tya
                jsr MoveActorY
                plp
                txa
                bne MH_ClimbNotPlayer
                bcc MH_ClimbNoSound
                jsr PlayFootstep
                lda #UPG_MOVEMENT
                ldy #DRAIN_CLIMB
                jsr DrainBatteryDouble
MH_ClimbNoSound:
MH_ClimbNotPlayer:
                jmp NoInterpolation

MH_Swimming:    ldy #AL_MOVESPEED
                lda (actLo),y
                lsr                             ;Swimming max speed = half of ground speed
                sta temp4
                iny
                lda (actLo),y
                sta temp5
                ldy actMoveCtrl,x
                cpy #JOY_LEFT
                bcc MH_SwimHorizDone
MH_SwimHorizLeftOrRight:
                lda #$00
                cpy #JOY_RIGHT
                bcs MH_SwimRight
                lda #$80
MH_SwimRight:   sta actD,x
                asl                             ;Direction to carry
                ldy temp4
                lda temp5
                jsr AccActorXNegOrPos
MH_SwimHorizDone:
                lda actMoveCtrl,x
                and #JOY_UP|JOY_DOWN
                beq MH_SwimVertDone
                lsr
                lda temp5
                ldy temp4
                jsr AccActorYNegOrPos
MH_SwimVertDone:lda actSY,x
                bne MH_NotStationary
                lda #-1                         ;If Y-speed stationary, rise up slowly
                sta actSY,x
MH_NotStationary:
                bpl MH_NotSwimmingUp            ;When going up, make sure there's water above
                lda #-2
                jsr GetCharInfoOffset
                tay
                and #CI_WATER
                bne MH_HasWaterAbove
                lda #$00
                sta actSY,x
                lda actMoveCtrl,x               ;If joystick held up, exit if ground above
                lsr
                bcc MH_NotExitingWater
                cmp #JOY_LEFT/2                 ;Check for exiting to left/right
                bcc MH_ExitWaterCheckAbove
                cmp #JOY_RIGHT/2
                lda #8*8
                ldy #3
                bcs MH_ExitWaterCheckRight
                lda #-8*8
                ldy #-3
MH_ExitWaterCheckRight:
                sta temp1
                lda #-2
                jsr GetCharInfoXYOffset
                lsr
                bcc MH_NotExitingWater
MH_GetOutOfWaterLoop:
                lda #-2                         ;Move actor until standing on ground
                jsr GetCharInfoOffset
                lsr
                bcs MH_ExitWaterCommon
                lda temp1
                jsr MoveActorX
                jmp MH_GetOutOfWaterLoop
MH_ExitWaterCheckAbove:
                tya
                lsr
                bcc MH_NotExitingWater
MH_ExitWaterCommon:
                lda #-16*8
                jsr MoveActorY
                lda actYL,x
                and #$c0
                sta actYL,x
                lda #SFX_JUMP
                jsr PlayMovementSound           ;Note: assumes that only the player will swim
                lda #MB_GROUNDED
                jsr MH_SetMoveBits              ;A=0 when returning, resets falling
                sta actSY,x
                jsr NoInterpolation
                lda #FR_DUCK+1
                jmp MH_AnimDone
MH_NotExitingWater:
MH_HasWaterAbove:
MH_NotSwimmingUp:
                lda #2
                sta temp4
                lda #-1                         ;Use middle of player for obstacle check
                ldy #CI_WATER
                jsr MoveFlyer
                lda #$03
                jsr AnimationDelay
                lda actF1,x
                adc #$00
                cmp #FR_SWIM+4
                bcc MH_SwimAnimDone
                lda #UPG_MOVEMENT
                ldy #DRAIN_SWIM
                jsr DrainBatteryDouble          ;Drain battery when the animation wraps
                lda #FR_SWIM                    ;Assumes only the player will swim
MH_SwimAnimDone:jmp MH_AnimDone

MH_SetGrounded: lda actMB,x
                ora #MB_GROUNDED
                bne MH_SetMoveBits
MH_ResetGrounded:
                lda actMB,x
                and #$ff-MB_GROUNDED
MH_SetMoveBits: sta actMB,x
MH_ResetFall:   lda #$00
                sta actFall,x
                sta actFallL,x
                rts

        ; Get half of actor's movement speed
        ;
        ; Parameters: X actor number, C=1 get positive speed, C=0 negative
        ; Returns: A speed
        ; Modifies: A,Y

GetSignedHalfSpeed:
                ldy #AL_MOVESPEED
                lda (actLo),y
                php
                lsr
                plp
                bcs GSHSDone
                eor #$ff
                adc #$01
GSHSDone:       rts

        ; Play footstep sound during player movement. No-op if music is on
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,Y

PlayFootstepCheckPlayer:
                txa
                bne PMS_NoSound
PlayFootstep:   lda #SFX_FOOTSTEP
PlayMovementSound:
                ldy PS_CurrentSong+1
                beq PMS_DoPlay
CS_NoFreeActor:
PMS_NoSound:    rts

        ; Create a water splash
        ;
        ; Parameters: X source actor
        ; Returns: -
        ; Modifies: A,Y

CreateSplash:   lda #ACTI_FIRSTEFFECT
                ldy #ACTI_LASTEFFECT
                jsr GetFreeActor
                bcc CS_NoFreeActor
                lda #ACT_WATERSPLASH
                jsr SpawnActor
                lda lvlWaterSplashColor         ;Color override
                sta actFlash,y
                lda actYL,y                     ;Align to char boundary
                and #$c0
                sta actYL,y
                lda #SFX_SPLASH
PMS_DoPlay:     jmp PlaySfx

        ; Drain battery charge, double if specified upgrade bit is on
        ;
        ; Parameters: A upgrade bitmask, Y amount of drain
        ; Returns: -
        ; Modifies: A

DrainBatteryDouble:
                and upgrade
                cmp #$01
                tya
                bcc DrainBattery
                asl

        ; Drain battery charge
        ;
        ; Parameters: A amount of drain
        ; Returns: -
        ; Modifies: A

DrainBattery:   lsr
DrainBatteryRound:
                adc #$00                        ;Round upward if reduced
                sta DB_Amount+1
                lda battery
                sec
DB_Amount:      sbc #$00
                bcs DB_Done
                dec battery+1
                bpl DB_Done
                lda #$00
                sta battery+1
DB_Done:        sta battery
                rts

        ; Add score
        ;
        ; Parameters: A score lowbyte, Y score highbyte
        ; Returns: -
        ; Modifies: A

AddScore:       clc
                adc score
                sta score
                tya
                adc score+1
                sta score+1
                bcc AS_Done
                inc score+2
SetPanelRedrawScore:
AS_Done:        lda #REDRAW_SCORE
                jmp SetPanelRedraw

        ; Humanoid character destroy routine
        ;
        ; Parameters: X actor index,Y damage source actor or $ff if none
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8

HumanDeath:     tya                             ;Check if has a damage source
                bmi HD_NoDamageSource
                lda actHp,y
                sta temp8
                lda actSX,y                     ;Check if final attack came from right or left
                bne HD_GotDir
                lda actXL,x
                sec
                sbc actXL,y
                lda actXH,x
                sbc actXH,y
HD_GotDir:      asl                             ;Direction to carry
                lda temp8
                ldy #DEATH_MAX_XSPEED
                jsr AccActorXNegOrPos
HD_NoDamageSource:
                lda actMB,x                     ;If in water, do not modify Y-speed
                bmi HD_NoYSpeed
                lda #DEATH_YSPEED
                sta actSY,x
                jsr MH_ResetGrounded
HD_NoYSpeed:    lda #SFX_DEATH
                jsr PlaySfx
                lda #FR_DIE
                sta actF1,x
                sta actF2,x
                lda #DEATH_DISAPPEAR_DELAY
                sta actTime,x
                lda #POS_NOTPERSISTENT          ;Bodies are supposed to eventually vanish, so mark as
                sta actLvlDataPos,x             ;nonpersistent if goes off the screen
                lda #$00
                sta actFd,x
                sta actHp,x
                sta actAIMode,x                ;Reset any ongoing AI

        ; Drop item from dead enemy
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8

DropItem:       lda #$02                        ;Retry counter
                sta temp7
DI_Retry:       ldy #AL_DROPITEMINDEX
                lda (actLo),y
                bpl DI_ItemNumber
                sta temp5
                jsr Random
                and #DROPTABLERANDOM-1
                adc temp5
                tay
                lda itemDropTable-$80,y
                beq DI_NoItem
                bpl DI_ItemNumber
                lda actWpn,x
DI_ItemNumber:  tay
                beq DI_NoItem
                sta temp5                       ;Item type to drop
                lda #$00
                sta temp8                       ;Capacity counter
                ldy #ACTI_FIRSTITEM             ;Count capacity on both ground and inventory, do not spawn
DI_CountGroundItems:                            ;if player can't pick up
                lda actT,y
                beq DI_CGINext
                lda actF1,y
                cmp temp5
                bne DI_CGINext
                lda actHp,y
                clc
                adc temp8
                bcs DI_Exceeded
                sta temp8
DI_CGINext:     iny
                cpy #ACTI_LASTITEM+1
                bcc DI_CountGroundItems
                ldy temp5
                jsr FindItem
                bcc DI_NotInInventory
                lda invCount-1,y
                clc
                adc temp8
                bcs DI_Exceeded
                sta temp8
DI_NotInInventory:
                lda temp8
                cmp itemMaxCount-1,y
                bcc DI_HasCapacity
DI_Exceeded:    dec temp7
                bne DI_Retry                    ;If player has no capacity, retry to drop something else
DI_NoItem:      rts                             ;(e.g. batteries or medkits)
DI_HasCapacity: lda #ACTI_FIRSTITEM
                ldy #ACTI_LASTITEM
                jsr GetFreeActor
                bcc DI_NoItem
                lda #ACT_ITEM
                jsr SpawnActor
                lda temp5
                stx temp6
                tax
                sta actF1,y
                lda #1
                cpx #ITEM_FIRST_IMPORTANT       ;Quest items always x1
                bcs DI_NoCount
                lda itemDefaultPickup-1,x
DI_NoCount:     sta actHp,y
                lda #ITEM_YSPEED
                sta actSY,y
                tya
                tax
                jsr InitActor
                lda #ITEM_SPAWN_OFFSET
                jsr MoveActorY
                lda temp5
                cmp #ITEM_FIRST_IMPORTANT
                ror
                ror
                and #ORG_GLOBAL
                jsr SetPersistence
                ldx temp6
                rts

        ; Create player actor and (re)load level
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

CreatePlayerActor:
                ldx #MAX_ACT-1                  ;Clear all actors when starting game
RCP_ClearActorLoop:
                jsr RemoveActor
                dex
                bpl RCP_ClearActorLoop
                jsr LoadLevel
                ldy #ACTI_PLAYER
                jsr GFA_Found
                ldx #6
                ldy #6*MAX_ACT
LoadPlayerActorVars:
                lda saveXL,x
                sta actXL+ACTI_PLAYER,y
                tya
                sbc #MAX_ACT                    ;C=1 here
                tay
                dex
                bpl LoadPlayerActorVars
                inx                             ;X=0
                jsr InitActor
                lda #REDRAW_ITEM+REDRAW_AMMO+REDRAW_SCORE
                sta panelUpdateFlags

        ; Apply upgrade effects
        ;
        ; Parameters: -
        ; Returns: X=0
        ; Modifies: A,X,Y,temp6-temp8

ApplyUpgrades:  lda upgrade
                sta temp6
                ldx #C_PLAYER_BOTTOM
                ldy #C_PLAYER_TOP
                and #UPG_MOVEMENT               ;Movement upgrade turns lower part armored
                beq AU_NoBottomArmor
                inx
AU_NoBottomArmor:
                lda temp6
                and #UPG_ARMOR|UPG_STRENGTH     ;Either strength or armor upgrade turns upper part armored
                beq AU_NoTopArmor
                iny
AU_NoTopArmor:  stx adPlayerBottomSprFile
                sty adPlayerTopSprFile
                lsr temp6                       ;Check movement
                ldx #0
                ldy #INITIAL_CLIMBSPEED
                bcc AU_NoMovement
                ldx #2
                ldy #INITIAL_CLIMBSPEED+12
AU_NoMovement:  txa
                clc
                adc #INITIAL_GROUNDACC
                sta plrGroundAcc
                txa
                adc #INITIAL_INAIRACC
                sta plrInAirAcc
                txa
                asl
                eor #$ff
                adc #1-INITIAL_JUMPSPEED
                sta plrJumpSpeed
                sty plrClimbSpeed
                lsr temp6                       ;Check strength
                ldy #NO_MODIFY
                bcc AU_NoStrength
                ldy #UPGRADE_ATTACK_MODIFY
AU_NoStrength:  sty AH_PlayerMeleeBonus+1
                lda #INITIAL_MAX_WEAPONS
                adc #$00                        ;Add one more weapon if have strength upgrade
                sta AI_MaxWeaponsCount+1        ;Todo: should this be two?
                ldx #itemDefaultMaxCount-itemMaxCount-1
AU_AmmoLoop:    lda itemDefaultMaxCount-1,x     ;Set carrying capacity for weapons/items
                cpy #NO_MODIFY                  ;except armor
                beq AU_NoAmmoIncrease
                lsr
                clc
                adc itemDefaultMaxCount-1,x
AU_NoAmmoIncrease:
                sta itemMaxCount-1,x
                dex
                bne AU_AmmoLoop
                lsr temp6                       ;Check firearms
                ldx #NO_MODIFY
                ldy #NO_MODIFY
                bcc AU_NoFirearms
                ldx #UPGRADE_ATTACK_MODIFY
                ldy #UPGRADE_RELOADTIME_MODIFY
AU_NoFirearms:  stx AH_PlayerFirearmBonus+1
                sty AH_PlayerReloadTimeMod+1
                lsr temp6                       ;Check subdermal armor for player damage
                lda #NO_MODIFY                  ;modifier
                bcc AU_NoArmor
                lda #UPGRADE_DAMAGE_MODIFY
AU_NoArmor:     ldx difficulty                  ;Finally modify with difficulty level
                ldy plrDmgModifyTbl,x
                jsr ModifyDamage
                sta plrDmgModify
                lsr temp6                       ;Check healing speed
                lda #INITIAL_HEALTIMER-1        ;Healing code has C=1 while adding, so subtract 1 here
                bcc AU_NoHealing
                lda #INITIAL_HEALTIMER*2-1
AU_NoHealing:   sta ULO_HealingRate+1
                lsr temp6                       ;Check battery drain reduce
                lda #$18                        ;CLC
                bcc AU_NoDrainReduce
                lda #$4a                        ;LSR
AU_NoDrainReduce:
                sta DrainBattery
                rts
