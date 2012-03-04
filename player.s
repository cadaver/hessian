FR_STAND        = 0
FR_WALK         = 1
FR_JUMP         = 9

        ; Player update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MovePlayer:     lda actMoveFlags,x
                sta temp1
                lsr                             ;Grounded bit to C
                lda joystick                    ;X-acceleration: faster when grounded
                and #JOY_LEFT
                beq MP_NotLeft
                lda #$80
                sta actD,x
                lda #-8
                bcs MP_OnGroundAccL
                lda #-2
MP_OnGroundAccL:ldy #-4*8
                jsr AccActorX
                jmp MP_NoBraking
MP_NotLeft:     lda joystick
                and #JOY_RIGHT
                beq MP_NotRight
                lda #$00
                sta actD,x
                lda #8
                bcs MP_OnGroundAccR
                lda #2
MP_OnGroundAccR:ldy #4*8
                jsr AccActorX
                jmp MP_NoBraking
MP_NotRight:    bcc MP_NoBraking
                lda #8                          ;When grounded and not moving, brake X-speed
                jsr BrakeActorX
MP_NoBraking:   lda temp1
                and #AMF_HITWALL|AMF_LANDED     ;If hit wall (and did not land simultaneously), reset X-speed
                cmp #AMF_HITWALL
                bne MP_NoHitWall
                lda #$00
                sta actSX,x
MP_NoHitWall:   lda temp1
                lsr                             ;Grounded bit to C
                and #AMF_HITCEILING/2
                beq MP_NoHeadBump
                lda #$00                        ;If head bumped, reset Y-speed
                sta actSY,x
MP_NoHeadBump:  bcc MP_NoNewJump
                lda joystick                    ;If on ground, can initiate a jump
                and #JOY_UP
                beq MP_NoNewJump
                lda prevJoy
                and #JOY_UP
                bne MP_NoNewJump
MP_Jump:        lda #-6*8
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
                lda actMoveFlags,x              ;If not grounded, play jump animation
                lsr
                bcs MP_GroundAnim
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
                bpl MP_AnimDone
MP_GroundAnim:  lda actMoveFlags,x
                and #AMF_HITWALL
                bne MP_StandAnim
MP_WalkAnim:    lda actSX,x
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
MP_AnimDone2:   lda joystick                    ;Shooting
                and #JOY_FIRE
                beq MP_NoFire
                lda prevJoy
                and #JOY_FIRE
                bne MP_NoFire
                lda #ACTI_FIRSTPLRBULLET
                ldy #ACTI_LASTPLRBULLET
                jsr GetFreeActor
                bcc MP_NoFire
                lda actXL,x                     ;Todo: refactor the spawn coord copy into a subroutine
                sta actXL,y                     ;if used a lot
                lda actXH,x
                sta actXH,y
                lda actYL,x
                sec
                sbc #$c0
                sta actYL,y
                lda actYH,x
                sbc #$00
                sta actYH,y
                lda #20
                sta actTime,y
                lda #ACT_BULLET
                sta actT,y
                tya
                jsr GetFlashColorOverride
                sta actC,y
                lda actD,x                       ;Copy direction
                sta actD,y
                bmi MP_FireLeft
MP_FireRight:   lda #12*8                        ;Set bullet X-speed
                sta actSX,y
                bne MP_NoFire
MP_FireLeft:    lda #-12*8
                sta actSX,y
MP_NoFire:      rts

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