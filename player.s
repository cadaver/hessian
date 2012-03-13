FR_STAND        = 0
FR_WALK         = 1
FR_JUMP         = 9
FR_DUCK         = 12
FR_CLIMB        = 14
FR_ROLL         = 18
FR_ATTACK       = 24

        ; Player update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MovePlayer:     lda actMoveCtrl,x
                sta actPrevMoveCtrl,x
                lda joystick
                cmp #JOY_FIRE
                bcs MP_FirePressed
                sta actMoveCtrl,x
                lda #$00
MP_FirePressed: sta actFireCtrl,x
                jsr MoveHuman
                jmp AttackHuman

        ; Humanoid character move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MH_ClimbUp:     jsr GetCharInfo4Above
                sta temp1
                and #CI_OBSTACLE
                bne MH_ClimbUpNoJump
                lda actMoveCtrl,x               ;Check for exiting the ladder
                cmp actPrevMoveCtrl,x           ;by jumping
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
MH_ClimbCommon: lda #$00                        ;Climbing speed
                clc
                adc actFd,x
                sta actFd,x
                bcc MH_ClimbDone
                lda #$01                        ;Run the animation either forward
                cpy #$80                        ;or backward depending on climbing dir
                bcc MH_ClimbAnimDown
                lda #$ff
MH_ClimbAnimDown:
                clc
                adc actF1,x
                and #$03                        ;Note: works only as long as FR_CLIMB
                clc                             ;is divisible by 4
                adc #FR_CLIMB
                sta actF1,x
                sta actF2,x
                tya
                jsr MoveActorY
                jmp NoInterpolation

MH_ClimbDown:   jsr GetCharInfo
                and #CI_CLIMB
                beq MH_ClimbDone
                ldy #4*8
                bne MH_ClimbCommon

MH_ClimbDone:   rts

MH_Climbing:    ldy #AL_CLIMBSPEED
                lda (actLo),y
                sta MH_ClimbCommon+1
                lda actF1,x                     ;Reset frame in case attack ended
                sta actF2,x
                lda actMoveCtrl,x
                lsr
                bcc MH_NoClimbUp
                jmp MH_ClimbUp
MH_NoClimbUp:   lsr
                bcs MH_ClimbDown
                lda actMoveCtrl,x
                and #JOY_LEFT|JOY_RIGHT         ;Exit ladder?
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

MoveHuman:      lda actMoveFlags,x
                sta temp1
                lda #$00                        ;Roll flag
                sta temp5
                ldy #AL_MOVECAPS
                lda (actLo),y
                sta temp6                       ;Movement capabilities
                lda actF1,x                     ;Check if climbing
                cmp #FR_CLIMB
                bcc MH_NoRoll
                cmp #FR_ROLL                    ;If rolling, automatically accelerate
                bcc MH_Climbing                 ;to facing direction
                inc temp5
                lda actD,x
                bmi MH_AccLeft
                bpl MH_AccRight
MH_NoRoll:      cmp #FR_DUCK+1
                lda actMoveCtrl,x               ;Check turning / X-acceleration / braking
                and #JOY_LEFT
                beq MH_NotLeft
                lda #$80
                sta actD,x
                bcs MH_Brake                    ;If ducking, brake
MH_AccLeft:     lda temp1
                lsr                             ;Faster acceleration when on ground
                lda #AL_GROUNDACCEL
                bcs MH_OnGroundAccL
                lda #AL_INAIRACCEL
MH_OnGroundAccL:ldy #AL_MOVESPEED
                jsr GetActorParametersAY
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
                lda #AL_GROUNDACCEL
                bcs MH_OnGroundAccR
                lda #AL_INAIRACCEL
MH_OnGroundAccR:ldy #AL_MOVESPEED
                jsr GetActorParametersAY
                jsr AccActorX
                jmp MH_NoBraking
MH_NotRight:    lda temp1                       ;No braking when jumping
                lsr
                bcc MH_NoBraking
MH_Brake:       ldy #AL_BRAKING                 ;When grounded and not moving, brake X-speed
                lda (actLo),y
                jsr BrakeActorX
MH_NoBraking:   lda temp1
                and #AMF_HITWALL|AMF_LANDED     ;If hit wall (and did not land simultaneously), reset X-speed
                cmp #AMF_HITWALL
                bne MH_NoHitWall
                lda temp6
                and #AMC_WALLFLIP
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
                and #AMF_HITCEILING/2
                beq MH_NoHeadBump
                lda #$00                        ;If head bumped, reset Y-speed
                sta actSY,x
MH_NoHeadBump:  bcc MH_NoNewJump
                lda actMoveCtrl,x               ;If on ground, can initiate a jump
                and #JOY_UP                     ;except if in the middle of a roll
                beq MH_NoNewJump
                lda temp5
                bne MH_NoNewJump
                lda temp6
                and #AMC_CLIMB
                beq MH_NoInitClimbUp
                lda actFireCtrl,x               ;When holding fire can not initiate climbing
                bne MH_NoInitClimbUp
                jsr GetCharInfo4Above           ;Jump or climb?
                and #CI_CLIMB
                beq MH_NoInitClimbUp
                jmp MH_InitClimb
MH_NoInitClimbUp:          
                lda temp6
                and #AMC_JUMP
                beq MH_NoNewJump
                lda actPrevMoveCtrl,x
                and #JOY_UP
                bne MH_NoNewJump
MH_StartJump:   ldy #AL_JUMPSPEED
                lda (actLo),y
                sta actSY,x
                lda #$00                        ;Reset grounded flag manually for immediate
                sta actMoveFlags,x              ;jump physics
MH_NoNewJump:   ldy #AL_HEIGHT                  ;Actor height for ceiling check
                lda (actLo),y
                sta temp1
                ldy #AL_JUMPACCEL               ;Make jump longer by holding joystick up
                lda actSY,x                     ;as long as still has upward velocity
                bpl MH_NoLongJump
                lda actMoveCtrl,x
                and #JOY_UP
                beq MH_NoLongJump
                ldy #AL_LONGJUMPACCEL
MH_NoLongJump:  tya
                ldy #AL_FALLSPEED
                jsr GetActorParametersAY
                jsr MoveWithGravity             ;Actually move & check collisions
                sta temp1                       ;Updated move flags to temp1
                lsr
                lda temp5                       ;If rolling, continue roll animation
                bne MH_RollAnim
                bcs MH_GroundAnim
                lda actSY,x                     ;Check for grabbing a ladder while
                bpl MH_GrabLadderOk             ;in midair
                cmp #-2*8                       ;Can not grab while still going up fast
                bcc MH_JumpAnim
MH_GrabLadderOk:lda actMoveCtrl,x
                and #JOY_UP
                beq MH_JumpAnim
                lda temp6
                and #AMC_CLIMB
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
MH_RollAnim:    lda #$01
                jsr AnimationDelay
                bcc MH_AnimDone2Jump
                lda actF1,x
                adc #$00
                cmp #FR_ROLL+6                  ;Transition from roll to low duck
                bcc MH_RollAnimDone
                lda temp1                       ;If rolling and falling, transition
                lsr                             ;to jump instead
                bcs MH_RollToDuck
MH_RollToJump:  lda #FR_JUMP+2
                bne MH_RollAnimDone
MH_RollToDuck:  lda #FR_DUCK+1
MH_RollAnimDone:jmp MH_AnimDone
MH_GroundAnim:  lda actMoveCtrl,x
                and #JOY_DOWN
                beq MH_NoDuck
MH_NewDuckOrRoll:
                lda actF1,x
                cmp #FR_DUCK
                bcs MH_NoNewRoll
                lda temp6
                and #AMC_ROLL
                beq MH_NoNewRoll
                lda actMoveCtrl,x               ;To initiate a roll, must push the
                cmp actPrevMoveCtrl,x           ;joystick diagonally while standing
                beq MH_NoNewRoll                ;or walking
                and #JOY_LEFT|JOY_RIGHT
                beq MH_NoNewRoll
MH_StartRoll:   lda #$00
                sta actFd,x
                lda #FR_ROLL
                jmp MH_AnimDone
MH_NoNewRoll:   lda temp6
                and #AMC_CLIMB
                beq MH_NoInitClimbDown
                lda actFireCtrl,x               ;When holding fire can not initiate climbing
                bne MH_NoInitClimbDown
                jsr GetCharInfo                 ;Duck or climb?
                and #CI_CLIMB
                beq MH_NoInitClimbDown
                jmp MH_InitClimb
MH_NoInitClimbDown:
                lda temp6
                and #AMC_DUCK
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
MH_AnimDone2Jump:
                bcc MH_AnimDone2
                lda actF1,x
                adc #$00
                cmp #FR_DUCK+2
                bcc MH_AnimDone
                lda #FR_DUCK+1
                bne MH_AnimDone
MH_NoDuck:      lda actF1,x
                cmp #FR_DUCK
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
                and #AMF_HITWALL
                bne MH_StandAnim
MH_WalkAnim:    lda actMoveCtrl,x
                and #JOY_LEFT|JOY_RIGHT
                beq MH_StandAnim
                ldy #AL_MOVEANIMDELAY
                lda (actLo),y
                jsr AnimationDelay
                bcc MH_AnimDone2
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
                lda actYL,x
                and #$c0
                sta actYL,x
                lda #FR_CLIMB
                sta actF1,x
                sta actF2,x
                lda #$80
                sta actFd,x
                lda #$00
                sta actSX,x
                sta actSY,x
                jmp NoInterpolation

        ; Bullet update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveBullet:     jsr MoveProjectile
                and #CI_OBSTACLE
                bne MBlt_Explode
                dec actTime,x
                bne MBlt_NoRemove
                jmp RemoveActor
MBlt_Explode:   lda #$00
                sta actF1,x
                sta actFd,x
                sta actC,x                      ;Remove flashing
                lda #ACT_EXPLOSION
                sta actT,x
MBlt_NoRemove:  rts

        ; Explosion update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveExplosion:  lda #1
                jsr AnimationDelay
                bcc MExpl_NoAnimation
                inc actF1,x
                lda actF1,x
                cmp #5
                bcc MExpl_NoRemove
                jmp RemoveActor
MExpl_NoAnimation:
MExpl_NoRemove: rts

        ; Scroll screen around the player actor
        ;
        ; Parameters: -
        ; Returns: scrollSX,scrollSY new scrolling speed
        ; Modifies: A,X,Y,temp1-temp2

ScrollPlayer:   ldx #ACTI_PLAYER
                jsr GetActorCharCoords
                sta temp1
                sty temp2
                ldx #0
                ldy #0
                lda temp1
                cmp #SCRCENTER_X-3
                bcs SP_NotLeft1
                dex
SP_NotLeft1:    cmp #SCRCENTER_X-1
                bcs SP_NotLeft2
                dex
SP_NotLeft2:    cmp #SCRCENTER_X+2
                bcc SP_NotRight1
                inx
SP_NotRight1:   cmp #SCRCENTER_X+4
                bcc SP_NotRight2
                inx
SP_NotRight2:   lda temp2
                cmp #SCRCENTER_Y-3
                bcs SP_NotUp1
                dey
SP_NotUp1:      cmp #SCRCENTER_Y-1
                bcs SP_NotUp2
                dey
SP_NotUp2:      cmp #SCRCENTER_Y+2
                bcc SP_NotDown1
                iny
SP_NotDown1:    cmp #SCRCENTER_Y+4
                bcc SP_NotDown2
                iny
SP_NotDown2:    stx scrollSX
                sty scrollSY
                rts