FR_STAND        = 0
FR_WALK         = 1
FR_JUMP         = 9
FR_DUCK         = 12
FR_ENTER        = 14
FR_CLIMB        = 15
FR_DIE          = 19
FR_ROLL         = 22
FR_PREPARE      = 28
FR_ATTACK       = 30

HEALTH_RECHARGE_DELAY = 75
HEALTH_RECHARGE_RATE = 25

DEATH_DISAPPEAR_DELAY = 75
DEATH_FLICKER_DELAY = 25
DEATH_HEIGHT    = -3                            ;Ceiling check height for dead bodies
DEATH_YSPEED    = -5*8
DEATH_MAX_XSPEED = 6*8
DEATH_ACCEL     = 6
DEATH_BRAKING   = 6

HUMAN_MAX_YSPEED = 6*8

DAMAGING_FALL_DISTANCE = 4

FIRST_XPLIMIT   = 100
NEXT_XPLIMIT    = 50
MAX_LEVEL       = 16
MAX_SKILL       = 3
NUM_SKILLS      = 5

INITIAL_GROUNDACC = 6
INITIAL_INAIRACC = 2
INITIAL_GROUNDBRAKE = 6
INITIAL_JUMPSPEED = 42
INITIAL_CLIMBSPEED = 84

HP_PLAYER       = 24

LVLOBJSEARCH    = 24

        ; Player update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MP_CheckPickupSub:
                ldy #ACTI_FIRSTITEM
MP_CheckPickupSub2:
                lda actT,y
                beq MP_CPSNoItem
                jsr CheckActorCollision
                bcs MP_CPSHasItem
MP_CPSNoItem:   iny
                cpy #ACTI_LASTITEM+1
                bcc MP_CPSNoItemNoWrap
                ldy #ACTI_FIRSTITEM
                clc
MP_CPSNoItemNoWrap:
                sty MP_CheckPickupSub+1
MP_CPSHasItem:  rts

MovePlayer:     lda actCtrl+ACTI_PLAYER         ;Get new controls
                sta actPrevCtrl+ACTI_PLAYER
                lda joystick
                sta actCtrl+ACTI_PLAYER
                cmp #JOY_FIRE
                bcc MP_NewMoveCtrl
                and #$0f                        ;When fire held down, eliminate the opposite
                tay                             ;directions from the previous move control
                lda moveCtrlAndTbl,y
                ldy actF1+ACTI_PLAYER           ;If holding a duck, keep the down direction
                cpy #FR_DUCK                    ;regardless of joystick position
                beq MP_Ducked
                cpy #FR_DUCK+1
                bne MP_NotDucked
MP_Ducked:      ora #JOY_DOWN
MP_NotDucked:   and actMoveCtrl+ACTI_PLAYER
MP_NewMoveCtrl: sta actMoveCtrl+ACTI_PLAYER

MP_CheckHealth: lda actHp+ACTI_PLAYER           ;Restore health if not dead and not at
                bne MP_NotDead                  ;full health
                jmp MP_PlayerMove
MP_NotDead:     cmp #HP_PLAYER
                bcs MP_CheckPickup
                lda healthRecharge
                adc #$01
MP_HealthRechargeRate:
                cmp #HEALTH_RECHARGE_RATE
                bne MP_NoRecharge
                inc actHp+ACTI_PLAYER
                lda #$00
MP_NoRecharge:  sta healthRecharge

MP_CheckPickup: jsr MP_CheckPickupSub           ;Check for item pickup / name display
                bcs MP_HasItem
                jsr MP_CheckPickupSub2
                bcs MP_HasItem
                lda displayedItemName           ;If no items, clear existing item name
                beq MP_CheckObject              ;text
                jsr ClearPanelText
                jmp MP_CheckObject
MP_HasItem:     lda textTime                    ;Make sure to not overwrite other game
                bne MP_SkipItemName             ;messages
                lda actF1,y
                cmp displayedItemName           ;Do not reprint same item name
                beq MP_SkipItemName
                pha
                jsr GetItemName
                ldy #$00
                jsr PrintPanelText
                pla
                sta displayedItemName
MP_SkipItemName:lda actCtrl+ACTI_PLAYER
                cmp #JOY_DOWN
                bne MP_CheckObject
                lda actFd+ACTI_PLAYER           ;If ducking, try picking up the item
                beq MP_CheckObject
                lda actF1+ACTI_PLAYER
                cmp #FR_DUCK
                bne MP_CheckObject
                ldy MP_CheckPickupSub+1
                jsr TryPickup

MP_CheckObject: lda actXH+ACTI_PLAYER
                sta MPCO_CmpX+1
                ldy actYH+ACTI_PLAYER
                dey
                sty MPCO_SubY+1
MPCO_Start:     ldx #$00
MPCO_Loop:      lda lvlObjX,x
MPCO_CmpX:      cmp #$00
                bne MPCO_Next
                lda lvlObjY,x
                and #$7f
MPCO_SubY:      sbc #$00
                cmp #$02                        ;Above or at object
                bcc MPCO_Found
MPCO_Next:      inx
MPCO_EndCmp:    cpx #LVLOBJSEARCH
                bcc MPCO_Loop
                cpx #MAX_LVLOBJ
                bcc MPCO_NotOver
                ldx #$ff
                stx lvlObjNum                   ;No object found
                inx
                clc
MPCO_NotOver:   stx MPCO_Start+1
                txa
                adc #LVLOBJSEARCH
                sta MPCO_EndCmp+1
                bpl MPCO_Done
MPCO_Found:     stx lvlObjNum
MPCO_Done:

MP_SetWeapon:   ldy itemIndex                   ;Set player weapon from inventory
                ldx invType,y
                lda itemMagazineSize-1,x        ;Mag size needed for weapon routines,
                sta magazineSize                ;cache it now
                cpx #ITEM_FIRST_NONWEAPON
                bcc MP_WeaponOK
MP_NoWeapon:    lda actCtrl+ACTI_PLAYER         ;If not holding a weapon, check
                cmp actPrevCtrl+ACTI_PLAYER     ;for item use
                beq MP_NoItemUse
                cmp #JOY_DOWN+JOY_FIRE
                bne MP_NoItemUse
                jsr UseItem
MP_NoItemUse:   ldx #WPN_NONE
MP_WeaponOK:    stx actWpn+ACTI_PLAYER
                ldx actIndex

MP_PlayerMove:  jsr MoveHuman
                jmp AttackHuman

        ; Humanoid character move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MH_DeathGrounded:
                lda #DEATH_BRAKING
                jsr BrakeActorX
                lda #FR_DIE+2
MH_DeathSetFrame:
                sta actF1,x
                sta actF2,x
                bcc MH_DeathDone
MH_DeathCheckRemove:
                dec actTime,x
                bmi MH_DeathRemove
                lda actTime,x
                cmp #DEATH_FLICKER_DELAY
                bne MH_DeathDone
                jsr GetFlickerColorOverride
                ora actC,x
                sta actC,x
MH_DeathDone:   rts
MH_DeathRemove: jmp RemoveActor
MH_DeathAnim:   lda #DEATH_HEIGHT               ;Actor height for ceiling check
                sta temp4
                lda #DEATH_ACCEL
                ldy #HUMAN_MAX_YSPEED
                jsr MoveWithGravity             ;Actually move & check collisions
                lsr
                bcs MH_DeathGrounded
                lda #FR_DIE
                ldy actSY,x
                bmi MH_DeathSetFrame
                lda #FR_DIE+1
                bne MH_DeathSetFrame

MoveHuman:      lda actHp,x
                beq MH_DeathAnim
                lda actD,x
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
                lda actMB,x                     ;Movement state bits
                sta temp1
                lsr                             ;Check after fall-effects (forced duck, damage)
                bcc MH_NoFallCheck
                ldy actFall,x
                beq MH_NoFallCheck
                and #MB_LANDED/2                ;Falling damage applied right after landing
                beq MH_NoFallDamage
                tya
                sbc #DAMAGING_FALL_DISTANCE
                bcc MH_NoFallDamage
                beq MH_NoFallDamage
                sta temp8
                asl
                adc temp8
                ldy #$ff
                jsr DamageActor
MH_NoFallDamage:dec actFall,x
                lda #$00
                sta actMoveCtrl,x
MH_NoFallCheck: lda actF1,x                     ;Check special movement states
                cmp #FR_CLIMB
                bcc MH_NotClimbing
                cmp #FR_ROLL
                bcs MH_Rolling
                jmp MH_Climbing
MH_Rolling:     inc temp2
                lda actD,x
                bmi MH_AccLeft
                bpl MH_AccRight
MH_NotClimbing: cmp #FR_DUCK+1
                lda actMoveCtrl,x               ;Check turning / X-acceleration / braking
                and #JOY_LEFT
                beq MH_NotLeft
                lda #$80
                sta actD,x
                bcs MH_Brake                    ;If ducking, brake
MH_AccLeft:     lda temp1
                lsr                             ;Faster acceleration when on ground
                ldy #AL_GROUNDACCEL
                bcs MH_OnGroundAccL
                ldy #AL_INAIRACCEL
MH_OnGroundAccL:lda (actLo),y
                ldy temp4
                jsr AccActorXNeg
                jmp MH_NoBraking
MH_NotLeft:     lda actMoveCtrl,x
                and #JOY_RIGHT
                beq MH_NotRight
                lda #$00
                sta actD,x
                bcs MH_Brake                    ;If ducking, brake
MH_AccRight:    lda temp1
                lsr                             ;Faster acceleration when on ground
                ldy #AL_GROUNDACCEL
                bcs MH_OnGroundAccR
                ldy #AL_INAIRACCEL
MH_OnGroundAccR:lda (actLo),y
                ldy temp4
                jsr AccActorX
                jmp MH_NoBraking
MH_NotRight:    lda temp1                       ;No braking when jumping
                lsr
                bcc MH_NoBraking
MH_Brake:       ldy #AL_BRAKING                 ;When grounded and not moving, brake X-speed
                lda (actLo),y
                jsr BrakeActorX
MH_NoBraking:   lda temp1
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
                ldy #AL_HALFSPEEDRIGHT
                cmp #JOY_UP|JOY_RIGHT
                beq MH_WallFlipRight2
                ldy #AL_HALFSPEEDLEFT
MH_WallFlipRight2:
                lda (actLo),y
                sta actSX,x
                bne MH_StartJump
MH_NoWallFlip:  lda #$00
                sta actSX,x
MH_NoHitWall:   lda temp1
                lsr                             ;Grounded bit to C
                and #MB_HITCEILING/2
                bne MH_NoNewJump
                bcc MH_NoNewJump
                lda actCtrl,x                   ;When holding fire can not initiate jump
                and #JOY_FIRE                   ;or grab a ladder
                bne MH_NoNewJump
                lda actMoveCtrl,x               ;If on ground, can initiate a jump
                and #JOY_UP                     ;except if in the middle of a roll
                beq MH_NoNewJump
                lda temp2
                bne MH_NoNewJump
                txa                             ;If player, check for operating level objects
                bne MH_NoOperate
                ldy lvlObjNum
                bmi MH_NoOperate
                lda lvlObjB,y
                and #OBJ_MODEBITS
                cmp #OBJMODE_MANUAL
                bcc MH_NoOperate
                lda actMoveCtrl,x
                cmp #JOY_UP
                bne MH_NoOperate
                cmp actPrevCtrl,x
                beq MH_NoOperate
                jsr OperateObject
                jmp MH_NoNewJump
MH_NoOperate:   lda temp3
                and #AMF_CLIMB
                beq MH_NoInitClimbUp
                jsr GetCharInfo4Above           ;Jump or climb?
                and #CI_CLIMB
                beq MH_NoInitClimbUp
                jmp MH_InitClimb
MH_NoInitClimbUp:
                lda temp3
                and #AMF_JUMP
                beq MH_NoNewJump
                lda actPrevCtrl,x
                and #JOY_UP
                bne MH_NoNewJump
MH_StartJump:   ldy #AL_JUMPSPEED
                lda (actLo),y
                sta actSY,x
                lda #$00                        ;Reset grounded bit manually for immediate
                sta actMB,x                     ;jump physics
                sta actFall,x
                sta actFallL,x
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
                sta temp1                       ;Updated move flags to temp1
                cmp #MB_STARTFALLING
                bcc MH_NoFallStart
                lda #$00
                sta actFall,x
                sta actFallL,x
                lda actAIHelp,x                 ;Check AI autojumping or autoturning
                cmp #AIH_AUTOJUMPLEDGE          ;when falling
                bcs MH_AutoJump
                and #AIH_AUTOTURNLEDGE
                beq MH_NoAutoJump
                lda actSX,x
                eor #$ff
                adc #$00
                jsr MoveActorX                  ;Back off from the ledge
                lda #MB_GROUNDED
                sta actMB,x                     ;Force grounded status
                sta temp1
                sec
                bne MH_DoAutoTurn
MH_AutoJump:    ldy #AL_JUMPSPEED
                lda (actLo),y
                sta actSY,x
MH_NoAutoJump:  lda temp1
MH_NoFallStart: lsr                             ;Grounded bit to carry
                and #MB_HITWALL/2
                beq MH_NoAutoTurn
                lda actAIHelp,x                 ;Check AI autoturning
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
                bne MH_RollAnim
                bcs MH_GroundAnim
                lda temp3                       ;Check for increasing fall distance
                and #AMF_NOFALLDAMAGE
                bne MH_NoIncFall
                lda actSY,x
                bmi MH_NoIncFall
                asl
                adc actFallL,x
                sta actFallL,x
                bcc MH_NoIncFall
                inc actFall,x
MH_NoIncFall:   lda actSY,x                     ;Check for grabbing a ladder while
                bpl MH_GrabLadderOK             ;in midair
                cmp #-2*8
                bcc MH_JumpAnim
MH_GrabLadderOK:lda actMoveCtrl,x
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
MH_AnimDone3:   rts
MH_RollAnim:    lda #$01
                jsr AnimationDelay
                bcc MH_AnimDone3
                lda actF1,x
                adc #$00
                cmp #FR_ROLL+6                  ;Transition from roll to low duck
                bcc MH_RollAnimDone
                lda temp1                       ;If rolling and falling, transition
                lsr                             ;to jump instead
                bcs MH_RollToDuck
MH_RollToJump:  lda #FR_JUMP+2
                skip2
MH_RollToDuck:  lda #FR_DUCK+1
MH_RollAnimDone:jmp MH_AnimDone
MH_GroundAnim:  lda actFall,x                   ;Forced duck after falling
                bne MH_NoInitClimbDown
                lda actMoveCtrl,x
                and #JOY_DOWN
                beq MH_NoDuck
MH_NewDuckOrRoll:
                lda temp3
                and #AMF_ROLL
                beq MH_NoNewRoll
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
                lda #FR_ROLL
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
                bne MH_AnimDone
MH_DuckAnim:    lda #$01
                jsr AnimationDelay
                bcc MH_AnimDone2
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
                lda actFd,x                     ;Increment door entry delay
                beq MH_AnimDone2
                inc actFd,x
                bne MH_AnimDone2
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
MH_StandOrWalk: lda temp1
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
                lda actF1,x
                adc #$00
                cmp #FR_WALK+8
                bcc MH_AnimDone
                lda #FR_WALK
                bcs MH_AnimDone
MH_StandAnim:   lda #$00
                sta actFd,x
                lda #FR_STAND
MH_AnimDone:    sta actF1,x
                sta actF2,x
MH_AnimDone2:   rts

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

MH_Climbing:    ldy #AL_CLIMBSPEED
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
                jsr GetCharInfo                 ;Check ground bit
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
                jsr NoInterpolation
                jmp MH_StandAnim

MH_ClimbDown:   jsr GetCharInfo
                and #CI_CLIMB
                beq MH_ClimbDone
                ldy #4*8
                bne MH_ClimbCommon
MH_ClimbDone:   rts

MH_ClimbUp:     jsr GetCharInfo4Above
                sta temp1
                and #CI_OBSTACLE
                bne MH_ClimbUpNoJump
                lda actMoveCtrl,x               ;Check for exiting the ladder
                cmp actPrevCtrl,x               ;by jumping
                beq MH_ClimbUpNoJump
                and #JOY_LEFT|JOY_RIGHT
                beq MH_ClimbUpNoJump
                jsr GetCharInfo                 ;If in the middle of an obstacle
                and #CI_OBSTACLE                ;block, can not exit by jump
                bne MH_ClimbUpNoJump
                lda #-2
                jsr GetCharInfoOffset
                and #CI_OBSTACLE
                bne MH_ClimbUpNoJump
                lda actMoveCtrl,x
                cmp #JOY_RIGHT
                ldy #AL_HALFSPEEDRIGHT
                bcs MH_ClimbUpJumpRight
                ldy #AL_HALFSPEEDLEFT
MH_ClimbUpJumpRight:
                lda (actLo),y
                sta actSX,x
                sta actD,x
                jmp MH_StartJump
MH_ClimbUpNoJump:
                lda actYL,x
                and #$20
                bne MH_ClimbUpOk
                lda temp1
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
                tya
                jsr MoveActorY
                jmp NoInterpolation

        ; Humanoid character destroy routine
        ;
        ; Parameters: X actor index,Y damage source actor or $ff if none
        ; Returns: -
        ; Modifies: A,temp3-temp8

HumanDeath:     lda #SFX_DEATH
                jsr PlaySfx
                lda #FR_DIE
                sta actF1,x
                sta actF2,x
                lda #DEATH_DISAPPEAR_DELAY
                sta actTime,x
                lda #DEATH_YSPEED
                sta actSY,x
                lda #$00
                sta actMB,x                     ;Not grounded anymore
                sta actAIMode,x                 ;Reset any ongoing AI
                stx temp3
                sty temp4
                txa                             ;Player dropping weapon is unnecessary
                beq HD_NoItem
                lda actWpn,x                    ;Check if should spawn the weapon item
                beq HD_NoItem                   ;TODO: spawn other items like medkits or
                lda #ACTI_FIRSTITEM             ;quest items if necessary
                ldy #ACTI_LASTITEM
                jsr GetFreeActor
                bcc HD_NoItem                   ;TODO: if item is important, it needs to be
                lda #$00                        ;stored directly to leveldata if no room
                sta temp5
                sta temp6
                sta actLvlOrg,y                 ;Set leveldata origin. TODO: use a "last found empty spot"
                                                ;variable to optimize returning the actor to leveldata
                lda #<ITEM_SPAWN_OFFSET
                sta temp7
                lda #>ITEM_SPAWN_OFFSET
                sta temp8
                lda #ACT_ITEM
                jsr SpawnWithOffset
                lda actWpn,x
                tax
                sta actF1,y
                lda itemDefaultPickup-1,x
                sta actHp,y
                lda #ITEM_YSPEED
                sta actSY,y
                tya
                tax
                jsr InitActor
                ldx temp3
HD_NoItem:      ldy temp4                      ;Check if has a damage source
                bmi HD_NoDamageSource
                lda actHp,y
                asl
                sta temp8
                lda actSX,y                    ;Check if final attack came from right or left
                bmi HD_LeftImpulse
                bne HD_RightImpulse
                lda actXL,x
                sec
                sbc actXL,y
                lda actXH,x
                sbc actXH,y
                bmi HD_LeftImpulse
HD_RightImpulse:lda temp8
                ldy #DEATH_MAX_XSPEED
                jmp AccActorX
HD_LeftImpulse: lda temp8
                ldy #DEATH_MAX_XSPEED
                jmp AccActorXNeg
HD_NoDamageSource:
                rts

        ; Init player XP level, skills and inventory
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X

InitPlayer:     lda #0                          ;TODO: move to loadable script code. This does
                ldx #NUM_SKILLS-1               ;not need to be memory-resident all the time
IP_XPSkillLoop: sta xpLo,x
                sta plrSkills,x
                dex
                bpl IP_XPSkillLoop
                stx lvlObjNum                   ;No levelobject found
                ldx #MAX_INVENTORYITEMS-1
IP_InvLoop:     sta invType,x
                sta invCount,x
                sta invMag,x
                dex
                bpl IP_InvLoop
                sta itemIndex
                sta lastReceivedXP
                sta levelUp
                lda #<FIRST_XPLIMIT
                sta xpLimitLo
                lda #1
                sta xpLevel
                sta invType                     ;1 = fists
                jsr SetPanelRedrawItemAmmo

        ; Apply skill effects
        ;
        ; Parameters: -
        ; Returns: X=0
        ; Modifies: A,X,Y

ApplySkills:

        ; Agility: acceleration, jump height, climbing speed

                ldx plrAgility
                txa
                clc
                adc #INITIAL_GROUNDACC
                sta playerGroundAcc
                txa
                adc #INITIAL_INAIRACC
                sta playerInAirAcc
                txa
                asl
                adc plrAgility
                asl
                adc #INITIAL_CLIMBSPEED
                sta playerClimbSpeed
                txa
                asl
                eor #$ff
                adc #1-INITIAL_JUMPSPEED
                sta playerJumpSpeed

        ; Firearms: damage bonus and faster reloading

                ldx plrFirearms
                lda plrWeaponBonusTbl,x
                sta AH_PlayerFirearmBonus+1
                lda plrReloadBonusTbl,x
                sta AH_ReloadDelayBonus+1

        ; Melee: damage bonus

                ldx plrMelee
                lda plrWeaponBonusTbl,x
                sta AH_PlayerMeleeBonus+1

        ; Vitality: damage reduction, faster health recharge

                ldx plrVitality
                lda plrDamageModTbl,x
                sta DA_PlayerDamageMod+1
                lda plrRechargeDelayTbl,x
                sta DA_HealthRechargeDelay+1
                lda plrRechargeRateTbl,x
                sta MP_HealthRechargeRate+1

        ; Carrying: more weapons in inventory and higher ammo limit

                lda plrCarrying
                adc #INITIAL_MAX_WEAPONS
                sta AI_MaxWeaponsCount+1
                ldx #itemDefaultMaxCount - itemMaxCount
AS_AmmoLoop:    lda itemMaxCountAdd-1,x
                ldy plrCarrying
                stx temp1
                ldx #<temp2
                jsr MulU
                ldx temp1
                lda itemDefaultMaxCount-1,x
                clc
                adc temp2
                sta itemMaxCount-1,x
                dex
                bne AS_AmmoLoop
                rts

        ; Give experience points to player, check for leveling
        ;
        ; Parameters: A XP amount
        ; Returns: -
        ; Modifies: A,loader temp vars

GiveXP:         pha
                stx zpSrcLo
                sty zpSrcHi
                ldx #<xpLo
                jsr Add8
                pla
                clc
                adc lastReceivedXP
                bcs GXP_TooMuchXP               ;If last received XP overflows,
                sta lastReceivedXP              ;disregard the latest addition
GXP_TooMuchXP:  ldy #<xpLimitLo                 ;(should not happen)
                jsr Cmp16
                bcc GXP_Done
                lda xpLevel
                cmp #MAX_LEVEL
                bcc GXP_NoMaxLevel
                lda xpLimitLo                   ;Clamp XP on last level
                sta xpLo
                lda xpLimitHi
                sta xpHi
                bne GXP_Done
GXP_NoMaxLevel: sta levelUp                     ;Mark pending levelup
GXP_Done:       jmp PSnd_Done                   ;Hack: PlaySound ends similarly
                ;ldx zpSrcLo
                ;ldy zpSrcHi
                ;rts
