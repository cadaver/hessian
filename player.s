FR_STAND        = 0
FR_WALK         = 1
FR_JUMP         = 9
FR_ROLL         = 12
FR_DUCK         = 18
FR_CLIMB        = 20

        ; Player update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MP_ClimbUp:     lda joystick                    ;Check for exiting the ladder
                cmp prevJoy                     ;by jumping
                beq MP_ClimbUpNoJump
                and #JOY_LEFT|JOY_RIGHT
                beq MP_ClimbUpNoJump
                cmp #JOY_RIGHT
                lda #2*8
                bcs MP_ClimbUpJumpRight
                lda #-2*8
MP_ClimbUpJumpRight:
                sta actSX,x
                sta actD,x
                jmp MP_StartJump
MP_ClimbUpNoJump:
                lda actYL,x
                and #$20
                bne MP_ClimbUpOk
                lda #-4
                jsr GetCharInfoOffset
                and #CI_CLIMB
                beq MP_ClimbDone
MP_ClimbUpOk:   ldy #-4*8
MP_ClimbCommon: lda #$60                        ;Climbing speed
                clc
                adc actFd,x
                sta actFd,x
                bcc MP_ClimbDone
                lda #$01                        ;Run the animation either forward
                cpy #$80                        ;or backward depending on climbing dir
                bcc MP_ClimbAnimDown
                lda #$ff
MP_ClimbAnimDown:
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

MP_Climbing:    lda joystick
                lsr
                bcs MP_ClimbUp
                lsr
                bcs MP_ClimbDown
                lda joystick
                and #JOY_LEFT|JOY_RIGHT         ;Exit ladder?
                beq MP_ClimbDone
                jsr GetCharInfo                 ;Check ground bit
                lsr
                bcc MP_ClimbDone
                lda actYL,x
                and #$c0
                sta actYL,x
                jsr NoInterpolation
                jmp MP_StandAnim
MP_ClimbDone:   rts

MP_ClimbDown:   jsr GetCharInfo
                and #CI_CLIMB
                beq MP_ClimbDone
                ldy #4*8
                bne MP_ClimbCommon

MovePlayer:     lda actMoveFlags,x
                sta temp1
                lda #$00                        ;Roll flag
                sta temp5
                lda actF1,x                     ;Check if climbing
                cmp #FR_CLIMB
                bcs MP_Climbing
                lda actF1,x                     ;If rolling, automatically accelerate
                cmp #FR_ROLL                    ;to facing direction
                bcc MP_NoRoll
                cmp #FR_DUCK
                bcs MP_NoRoll
                inc temp5
                lda actD,x
                bmi MP_AccLeft
                bpl MP_AccRight
MP_NoRoll:      cmp #FR_DUCK+1
                lda joystick                    ;Check turning / X-acceleration / braking
                and #JOY_LEFT
                beq MP_NotLeft
                lda #$80
                sta actD,x
                bcs MP_Brake                    ;If ducking, brake
MP_AccLeft:     lda temp1
                lsr                             ;Faster acceleration when on ground
                lda #-8
                bcs MP_OnGroundAccL
                lda #-3
MP_OnGroundAccL:ldy #-4*8
                jsr AccActorX
                jmp MP_NoBraking
MP_NotLeft:     lda joystick
                and #JOY_RIGHT
                beq MP_NotRight
                lda #$00
                sta actD,x
                bcs MP_Brake                    ;If ducking, brake
MP_AccRight:    lda temp1
                lsr                             ;Faster acceleration when on ground
                lda #8
                bcs MP_OnGroundAccR
                lda #3
MP_OnGroundAccR:ldy #4*8
                jsr AccActorX
                jmp MP_NoBraking
MP_NotRight:    lda temp1                       ;No braking when jumping
                lsr
                bcc MP_NoBraking
MP_Brake:       lda #8                          ;When grounded and not moving, brake X-speed
                jsr BrakeActorX
MP_NoBraking:   lda temp1
                and #AMF_HITWALL|AMF_LANDED     ;If hit wall (and did not land simultaneously), reset X-speed
                cmp #AMF_HITWALL
                bne MP_NoHitWall
                lda temp1                       ;Check for wallflip (push joystick up & opposite to wall)
                lsr
                bcs MP_NoWallFlip
                lda actSY,x                     ;Must not have started descending yet
                bpl MP_NoWallFlip
                lda #JOY_UP|JOY_RIGHT
                ldy actSX,x
                beq MP_NoWallFlip
                bmi MP_WallFlipRight
                lda #JOY_UP|JOY_LEFT
MP_WallFlipRight:
                cmp joystick
                bne MP_NoWallFlip
                ldy #4*8
                cmp #JOY_UP|JOY_RIGHT
                beq MP_WallFlipRight2
                ldy #-4*8
MP_WallFlipRight2:
                tya
                sta actSX,x
                bne MP_StartJump
MP_NoWallFlip:  lda #$00
                sta actSX,x
MP_NoHitWall:   lda temp1
                lsr                             ;Grounded bit to C
                and #AMF_HITCEILING/2
                beq MP_NoHeadBump
                lda #$00                        ;If head bumped, reset Y-speed
                sta actSY,x
MP_NoHeadBump:  bcc MP_NoNewJump
                lda joystick                    ;If on ground, can initiate a jump
                and #JOY_UP                     ;except if in the middle of a roll
                beq MP_NoNewJump
                lda temp5
                bne MP_NoNewJump
                lda #-4                         ;Jump or climb?
                jsr GetCharInfoOffset
                and #CI_CLIMB
                beq MP_NoInitClimbUp
                jmp MP_InitClimb
MP_NoInitClimbUp:                
                lda prevJoy
                and #JOY_UP
                bne MP_NoNewJump
                lda #-4                         ;Jump or climb?
                jsr GetCharInfoOffset
                and #CI_CLIMB
                beq MP_StartJump
                jmp MP_InitClimb
MP_StartJump:   lda #-6*8+4
                sta actSY,x
                lda #$00                        ;Reset grounded flag manually for immediate
                sta actMoveFlags,x              ;jump physics
MP_NoNewJump:   lda #-4                         ;Actor height for ceiling check
                sta temp1
                ldy #8                          ;Make jump longer by holding joystick up
                lda actSY,x                     ;as long as still has upward velocity
                bpl MP_NoLongJump
                lda joystick
                and #JOY_UP
                beq MP_NoLongJump
                ldy #4
MP_NoLongJump:  tya
                ldy #6*8
                jsr MoveWithGravity             ;Actually move & check collisions
                lda temp5
                bne MP_RollAnim
                lda actMoveFlags,x              ;If not grounded, play jump animation
                lsr
                bcs MP_GroundAnim
                lda actSY,x                     ;Check for grabbing a ladder while
                bpl MP_GrabLadderOk             ;in midair
                cmp #-2*8                       ;Can not grab while still going up fast
                bcc MP_JumpAnim
MP_GrabLadderOk:lda joystick
                and #JOY_UP
                beq MP_JumpAnim
                lda #-4
                jsr GetCharInfoOffset
                and #CI_CLIMB
                beq MP_JumpAnim
                jmp MP_InitClimb
MP_JumpAnim:    ldy #FR_JUMP+1
                lda actSY,x
                bpl MP_JumpAnimDown
MP_JumpAnimUp:  cmp #-1*8
                bcs MP_JumpAnimDone
                dey
                bcc MP_JumpAnimDone
MP_JumpAnimDown:cmp #2*8
                bcc MP_JumpAnimDone
                iny
MP_JumpAnimDone:tya
                jmp MP_AnimDone
MP_RollAnim:    lda #$01
                jsr AnimationDelay
                bcc MP_AnimDone2Jump
                lda actF1,x
                adc #$00
                cmp #FR_DUCK                    ;Transition from roll to low duck
                bcc MP_RollAnimDone
                lda actMoveFlags,x              ;If rolling and falling, transition
                lsr                             ;to jump instead
                bcs MP_RollToDuck
MP_RollToJump:  lda #FR_JUMP+2
                bne MP_RollAnimDone
MP_RollToDuck:  lda #FR_DUCK+1
MP_RollAnimDone:
                jmp MP_AnimDone
MP_GroundAnim:  lda joystick
                and #JOY_DOWN
                beq MP_NoDuck
MP_NewDuckOrRoll:
                lda actF1,x
                cmp #FR_ROLL
                bcs MP_NoNewRoll
                lda joystick                    ;To initiate a roll, must push the
                cmp prevJoy                     ;joystick diagonally while standing
                beq MP_NoNewRoll                ;or walking
                and #JOY_LEFT|JOY_RIGHT
                beq MP_NoNewRoll
MP_StartRoll:   lda #$00
                sta actFd,x
                lda #FR_ROLL
                bne MP_AnimDone
MP_NoNewRoll:   jsr GetCharInfo                 ;Duck or climb?
                and #CI_CLIMB
                beq MP_NoInitClimbDown
                jmp MP_InitClimb
MP_NoInitClimbDown:
                lda actF1,x
                cmp #FR_DUCK
                bcs MP_DuckAnim
                lda #$00
                sta actFd,x
                lda #FR_DUCK
                bne MP_AnimDone
MP_DuckAnim:    lda #$01
                jsr AnimationDelay
MP_AnimDone2Jump:
                bcc MP_AnimDone2
                lda actF1,x
                adc #$00
                cmp #FR_DUCK+2
                bcc MP_AnimDone
                lda #FR_DUCK+1
                bne MP_AnimDone
MP_NoDuck:      lda actF1,x
                cmp #FR_DUCK
                bcc MP_StandOrWalk
MP_DuckStandUpAnim:
                lda #$01
                jsr AnimationDelay
                bcc MP_AnimDone2
                lda actF1,x
                sbc #$01
                cmp #FR_DUCK
                bcc MP_StandAnim
                bcs MP_AnimDone
MP_StandOrWalk: lda actMoveFlags,x
                and #AMF_HITWALL
                bne MP_StandAnim
MP_WalkAnim:    lda joystick
                and #JOY_LEFT|JOY_RIGHT
                beq MP_StandAnim
                lda #$01
                jsr AnimationDelay
                bcc MP_AnimDone2
                lda actF1,x
                adc #$00
                cmp #FR_WALK+8
                bcc MP_AnimDone
                lda #FR_WALK
                bcs MP_AnimDone
MP_StandAnim:   lda #$00
                sta actFd,x
                lda #FR_STAND
MP_AnimDone:    sta actF1,x
                sta actF2,x
MP_AnimDone2:   rts

MP_InitClimb:   lda #$80
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