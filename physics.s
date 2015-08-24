MB_GROUNDED    = 1
MB_INWATER      = 2
MB_LANDED      = 4
MB_HITWALL     = 8
MB_HITCEILING  = 16
MB_STARTFALLING = 32

        ; Move actor and stop at obstacles
        ;
        ; Parameters: X actor index, A Y offset position for obstacles,
        ;             temp4 X offset position for obstacles, Y required charinfo (minus ground bit)
        ; Returns: A charinfo
        ; Modifies: A,Y,temp vars

MoveFlyer:      sta temp5
                sty temp6
                lda actSX,x
                beq MF_XMoveOK
                bpl MF_NoNegate
                lda temp4                       ;Negate X check offset if moving left
                beq MF_NoNegate2
                eor #$ff
                clc
                adc #$01
                sta temp4
MF_NoNegate2:   lda actSX,x
MF_NoNegate:    jsr MoveActorX
                lda temp5
                ldy temp4
                jsr GetCharInfoXYOffset
                and #CI_OBSTACLE|CI_WATER
                cmp temp6
                beq MF_XMoveOK
                lda actSX,x
                jsr MoveActorXNeg
                lda #$00
                sta actSX,x
MF_XMoveOK:     lda actSY,x
                jsr MoveActorY
                lda temp5
                jsr GetCharInfoOffset
                sta temp8
                and #CI_OBSTACLE|CI_WATER
                cmp temp6
                beq MF_YMoveOK
                lda actSY,x
                jsr MoveActorYNeg
                lda #$00
                sta actSY,x
MF_YMoveOK:     lda temp8
                rts

        ; Move actor with gravity and ground/wall collisions. Does not modify horizontal velocity
        ;
        ; Parameters: X actor index, A gravity acceleration (should be positive), Y Y-speed limit,
        ;             temp4 vertical char offset (negative) for ceiling check
        ; Returns: actMB updated, also returned in A
        ; Modifies: A,Y,temp5-temp8

MoveWithGravity:sta temp6
                lda actMB,x                     ;Only retain the grounded & water flags
                and #MB_GROUNDED|MB_INWATER
                sta temp5
                lsr
                bcs MWG_NoYMove                 ;If not grounded, move in Y-dir first
                lda temp6
                jsr AccActorYNoClc
                jsr MoveActorY
MWG_NoYMove:    lda actSX,x                     ;Have X-speed?
                beq MWG_NoXMove
                jsr MoveActorX
MWG_NoXMove:    jsr GetCharInfo1Above           ;If grounded, only check wall 1 char higher
                tay                             ;If in air, check both at feet & 1 char higher
                and #CI_OBSTACLE
                bne MWG_HasWallHit
                lda temp5
                lsr
                bcs MWG_NoWallHit2
                jsr GetCharInfo
                tay
                and #CI_OBSTACLE
                beq MWG_NoWallHit
MWG_HasWallHit: lda actSX,x                     ;If hit wall, back out & set flag
                beq MWG_WallHitDone
                bmi MWG_WallHitLeft
MWG_WallHitRight:
                lda #-8*8
                jsr MoveActorX
                ora #$3f
                bne MWG_WallHitDone2
MWG_WallHitLeft:lda #8*8
                jsr MoveActorX
                and #$c0
MWG_WallHitDone2:
                sta actXL,x
MWG_WallHitDone:lda temp5
                ora #MB_HITWALL
                sta temp5
MWG_NoWallHit:  lda temp5                       ;Check enter/leave water
                lsr
MWG_NoWallHit2: and #MB_INWATER/2
                bne MWG_CheckLeaveWater
MWG_CheckEnterWater:
                tya
                and #CI_WATER
                beq MWG_NoLeaveWater
                php
                jsr CreateSplash
                plp
                lda temp5
                ora #MB_INWATER
                bne MWG_StoreFlags
MWG_CheckLeaveWater:
                tya
                and #CI_WATER|CI_OBSTACLE|CI_GROUND ;Leaving water conclusive only if no ground/obstacles at feet
                bne MWG_NoLeaveWater
                lda temp5
                and #$ff-MB_INWATER
MWG_StoreFlags: sta temp5
MWG_NoLeaveWater:
                bcc MWG_InAir
                jmp MWG_OnGround

MWG_InAir:      lda actSY,x                     ;Check landing or ceiling hit?
                bpl MWG_CheckLanding
MWG_CheckCeiling:
                lda temp4
                jsr GetCharInfoOffset
                and #CI_OBSTACLE
                beq MWG_NoCeiling
                lda #$00                        ;If hit ceiling, reset Y-speed
                sta actSY,x
                lda temp5
                ora #MB_HITCEILING
                sta actMB,x
                rts
MWG_NoCeiling:  lda actSX,x
                beq MWG_NoLanding               ;If abs. X-speed is higher than abs. Y-speed
                bmi MWG_XSpeedNeg               ;while going up, there is possibility
                eor #$ff                        ;of clipping through a slope. Check landing
                clc                             ;to prevent that
                adc #$01
MWG_XSpeedNeg:  cmp actSY,x
                bcs MWG_NoLanding
                jsr GetCharInfo
                tay
                lsr
                bcc MWG_NoLanding
                tya
                and #$e0
                beq MWG_NoLanding               ;If no slope, can't be a landing
                sta temp6
                cmp #$80                        ;Slope 4 = stairs, land regardless of direction
                beq MWG_HitGround2
                eor actSX,x                     ;If it's a diagonal slope, verify that X-speed
                bpl MWG_HitGround2              ;is actually against it
MWG_NoLanding:  lda temp5
                sta actMB,x
                rts

MWG_CheckLanding:
                jsr GetCharInfo                 ;Get charinfo at actor pos
                tay
                lsr                             ;Hit ground?
                bcc MWG_NoLanding
                ;bcc MWG_CheckCharCrossY         ;If not directly, check also possible char crossing
                tya
                ldy #$00
                and #$e0                        ;Get the slopebits
                beq MWG_HitGround               ;Optimization for slope0 (most common)
                sta temp6
                lda actXL,x
                lsr
                and #$1c
                ora temp6
                lsr
                lsr
                tay
                lda actYL,x
                and #$3f
                cmp slopeTbl,y
                bcs MWG_HitGround
                adc actSY,x                     ;Check if we would hit the slope next frame
                cmp slopeTbl,y                  ;(must land also in that case, because next frame
                bcs MWG_HitGround               ;we also move in X-dir and possibly clip through)
                bcc MWG_NoLanding
;MWG_CheckCharCrossY:
;                lda actYL,x
;                and #$3f
;                sec
;                sbc actSY,x
;                bcs MWG_NoLanding
;MWG_CrossedChar:jsr GetCharInfo1Above           ;Get char above
;                tay
;                lsr
;                bcc MWG_NoLanding
;                lda #-8*8                       ;Move the actor 1 char up
;                jsr MoveActorY
;                tya
;                ldy #$00
;                and #$e0                        ;Get slopebits again, optimize for slope0
;                beq MWG_HitGround
;                sta temp6
MWG_HitGround2: lda actXL,x
                lsr
                and #$1c
                ora temp6
                lsr
                lsr
                tay
MWG_HitGround:  lda #$00
                sta actSY,x                     ;Reset vertical velocity to zero
                lda actYL,x
                and #$c0
                ora slopeTbl,y
                sta actYL,x                     ;Align actor to slope
                lda temp5
                ora #MB_GROUNDED|MB_LANDED
                sta actMB,x
                rts

MWG_OnGround:   cpx #MAX_COMPLEXACT
                bcs MWG_PreferLevel
                lda actMoveCtrl,x
                and #JOY_UP
                beq MWG_PreferLevel
MWG_PreferUp:   jsr GetCharInfo1Above           ;Check first above if joystick held up
                tay
                lsr
                bcs MWG_FinalizeGroundAbove
MWG_PreferLevel:jsr GetCharInfo                 ;Then level
                tay
                lsr
                bcs MWG_FinalizeGround
                jsr GetCharInfo1Below           ;Then below
                tay
                lsr
                bcs MWG_FinalizeGroundBelow
                jsr GetCharInfo1Above           ;Finally above
                tay                             ;(note: if player is holding up and is
                lsr                             ;about to fall, above will be checked twice,
                bcs MWG_FinalizeGroundAbove     ;but it's just a one frame CPU hit)
MWG_StartFalling:
                lda temp5                       ;If no ground anywhere, start falling
                and #$ff-MB_GROUNDED
                ora #MB_STARTFALLING
                sta actMB,x
                rts
MWG_FinalizeGroundBelow:
                lda #8*8
                jsr MoveActorY
                jmp MWG_FinalizeGround
MWG_FinalizeGroundAbove:
                lda #-8*8
                jsr MoveActorY
MWG_FinalizeGround:
                tya
                ldy #$00                        ;Get slopebits, optimize for slope0
                and #$e0
                beq MWG_OnGroundDone
                sta temp6
                lda actXL,x
                lsr
                and #$1c
                ora temp6
                lsr
                lsr
                tay
MWG_OnGroundDone:
                lda actYL,x
                and #$c0
                ora slopeTbl,y
                sta actYL,x
                lda temp5
                sta actMB,x
                rts
