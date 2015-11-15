MB_GROUNDED    = 1
MB_LANDED      = 2
MB_HITWALL     = 4
MB_HITWALLVERTICAL = 8
MB_HITCEILING  = 16
MB_STARTFALLING = 32
MB_INWATER      = 128

        ; Move actor and stop at obstacles
        ;
        ; Parameters: X actor index, A Y offset position for obstacles,
        ;             temp4 X offset position for obstacles, Y required charinfo (minus ground bit)
        ; Returns: A charinfo
        ; Modifies: A,Y,temp vars

MoveFlyer:      sta temp5
                sty temp6
                lda actMB,x                     ;Clear other bits except water
                and #MB_INWATER
                sta actMB,x
                lda actSX,x
                beq MF_XMoveOK
                bpl MF_NoNegate
                lda temp4                       ;Negate X check offset if moving left
                beq MF_NoNegate2
                eor #$ff
                sta temp4
                inc temp4
MF_NoNegate2:   lda actSX,x
MF_NoNegate:    jsr MoveActorX
                lda temp5
                ldy temp4
                jsr GetCharInfoXYOffset
                and #CI_OBSTACLE|CI_WATER
                cmp temp6
                beq MF_XMoveOK
                lda actMB,x
                ora #MB_HITWALL
                sta actMB,x
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
                lda actMB,x
                ora #MB_HITWALLVERTICAL
                sta actMB,x
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

FallingMotionCommon:
                lda #-1                         ;Ceiling check offset
                sta temp4
                lda #GRENADE_ACCEL
                ldy #GRENADE_MAX_YSPEED
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
                jsr GetCharInfo1Above           ;Charinfos above & at needed several times,
                sta temp7                       ;get them now
                and #CI_OBSTACLE
                bne MWG_HasWallHit
                lda temp5                       ;If grounded, do not check obstacle at feet
                lsr                             ;(would prevent going up slopes with obstacle below)
                bcs MWG_NoWallHit
                jsr GetCharInfoOptimizedAfter1Above
                sta temp8
                and #CI_OBSTACLE
                beq MWG_NoWallHit2
MWG_HasWallHit: lda actSX,x
                bmi MWG_WallHitLeft
MWG_WallHitRight:
                lda #-8*8
                jsr MoveActorX
                ora #$3f
                bne MWG_WallHitDone
MWG_WallHitLeft:lda #8*8
                jsr MoveActorX
                and #$c0
MWG_WallHitDone:sta actXL,x
                lda temp5
                ora #MB_HITWALL
                sta temp5
MWG_NoXMove:    jsr GetCharInfo1Above           ;Need to re-get the charinfos after modifying position
                sta temp7
MWG_NoWallHit:  jsr GetCharInfoOptimizedAfter1Above
                sta temp8
MWG_NoWallHit2: lda temp7
                ldy temp5
                bmi MWG_CheckLeaveWater
MWG_CheckEnterWater:
                and #CI_WATER
                beq MWG_NoLeaveWater
                jsr CreateSplash
                lda temp5
                ora #MB_INWATER
                bne MWG_CheckWaterStoreFlags
MWG_CheckLeaveWater:
                and #CI_WATER|CI_OBSTACLE|CI_GROUND ;Leaving water conclusive only if no ground/obstacles at feet
                bne MWG_NoLeaveWater
                lda temp5
                and #$ff-MB_INWATER
MWG_CheckWaterStoreFlags:
                sta temp5
                tay
MWG_NoLeaveWater:
                tya
                lsr
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
                bne MWG_StoreMB
MWG_NoCeiling:  rts

MWG_CheckLanding:
                lda temp8                       ;Charinfo at actor pos
                lsr                             ;Hit ground?
                bcc MWG_CheckCharCrossY         ;If not directly, check also possible char crossing
                rol
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
MWG_CheckCharCrossY:
                lda actYL,x
                and #$3f
                sec
                sbc actSY,x
                bcs MWG_NoLanding
MWG_CrossedChar:lda temp7                       ;Get char above
                lsr
                bcc MWG_NoLanding
                and #$70                        ;Char crossing is only important on slopes; skip on level ground
                beq MWG_NoLanding               ;(prevents a certain bug with obstacle+ground underneath it)
                lda #-8*8                       ;Move the actor 1 char up
                jsr MoveActorY
                lda temp7
                and #$e0
                sta temp6
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
                skip2
MWG_NoLanding:  lda temp5
MWG_StoreMB:    sta actMB,x
                rts

MWG_OnGround:   cpx #MAX_COMPLEXACT             ;Check for player/NPC wanting to go up stairs
                bcs MWG_PreferLevel
                lda actMoveCtrl,x
                lsr
                bcc MWG_PreferLevel
MWG_PreferUp:   lda temp7
                lsr
                bcs MWG_FinalizeGroundAbove
                lda temp8
                lsr
                bcs MWG_FinalizeGround
                jsr GetCharInfo1Below
                lsr
                bcs MWG_FinalizeGroundBelow
                bcc MWG_StartFalling
MWG_PreferLevel:lda temp8
                lsr
                bcs MWG_FinalizeGround
                jsr GetCharInfo1Below
                lsr
                bcs MWG_FinalizeGroundBelow
                lda temp7
                lsr
                bcs MWG_FinalizeGroundAbove
MWG_StartFalling:
                lda temp5                       ;If no ground anywhere, start falling
                and #$ff-MB_GROUNDED
                ora #MB_STARTFALLING
                bne MWG_StoreMB2
MWG_FinalizeGroundBelow:
                tay
                lda #8*8
                bne MWG_FinalizeGroundMove
MWG_FinalizeGroundAbove:
                tay
                lda #-8*8
MWG_FinalizeGroundMove:
                jsr MoveActorY
                tya
                sec
MWG_FinalizeGround:
                rol
                cpx #MAX_COMPLEXACT
                bcs MWG_DoNotSaveCharInfo
                sta actGroundCharInfo,x
MWG_DoNotSaveCharInfo:
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
MWG_StoreMB2:   sta actMB,x
                rts
