MB_GROUNDED    = 1
MB_INWATER      = 2
MB_LANDED      = 4
MB_HITWALL     = 8
MB_HITCEILING  = 16
MB_STARTFALLING = 32

WATER_XBRAKING  = 3
WATER_YBRAKING  = 5

        ; Move actor in a straight line and return charinfo from final position
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,Y,temp vars

MoveProjectile: lda actSX,x
                jsr MoveActorX
                lda actSY,x
                jsr MoveActorY
                jmp GetCharInfo

        ; Move actor and stop at obstacles
        ;
        ; Parameters: X actor index, A offset position for side obstacles, Y obstacle bits
        ; Returns: A charinfo
        ; Modifies: A,Y,temp vars

MoveFlyer:      sta temp5
                sty temp6
                lda actSX,x
                beq MF_XMoveOK
                jsr MoveActorX
                lda temp5
                jsr GetCharInfoOffset
                and temp6
                beq MF_XMoveOK
                lda actSX,x
                jsr MoveActorXNeg
                lda #$00
                sta actSX,x
MF_XMoveOK:     lda actSY,x
                jsr MoveActorY
                jsr GetCharInfo
                sta temp8
                and temp6
                beq MF_YMoveOK
                lda actSY,x
                jmp MoveActorYNeg
                lda #$00
                sta actSY,x
MF_YMoveOK:     lda temp8
                rts

        ; Move actor with gravity and ground/wall collisions,
        ; float in water and create splash when first hitting water
        ;
        ; Parameters: X actor index, A gravity acceleration (should be positive), Y speed limit,
        ;             temp4 vertical char offset (negative) for ceiling check
        ; Returns: actMB updated, also returned in A
        ; Modifies: A,Y,temp4-temp8

MoveWithGravityAndFloat:
                pha
                lda actMB,x
                sta MWGF_OldFlags+1             ;Store old flags
                pla
                jsr MoveWithGravity
                and #MB_INWATER
                beq MWGF_NoWater
MWGF_OldFlags:  lda #$00
                and #MB_INWATER
                bne MWGF_NoSplash
                lda actSY,x
                bmi MWGF_NoSplash
                jsr CreateSplash
MWGF_NoSplash:  lda #WATER_XBRAKING
                jsr BrakeActorX
                lda #WATER_YBRAKING
                jsr BrakeActorY
MWGF_NoWater:   lda actMB,x
                rts

        ; Move actor with gravity and ground/wall collisions. Does not modify horizontal velocity
        ;
        ; Parameters: X actor index, A gravity acceleration (should be positive), Y speed limit,
        ;             temp4 vertical char offset (negative) for ceiling check
        ; Returns: actMB updated, also returned in A
        ; Modifies: A,Y,temp5-temp8

MoveWithGravity:sta temp6
                lda actMB,x                     ;Only retain the grounded & water flag
                and #MB_GROUNDED|MB_INWATER
                sta temp5
                lsr
                bcs MWG_NoYMove                 ;If not grounded, move in Y-dir first
                sty temp7
                lda actSY,x                     ;Add Y-acceleration (simplified version of
                clc                             ;AccActorY)
                adc temp6
                bmi MWG_NoYSpeedLimit           ;If speed still negative, can not have
                cmp temp7                       ;reached terminal velocity yet
                bcc MWG_NoYSpeedLimit
                lda temp7
MWG_NoYSpeedLimit:
                sta actSY,x
                jsr MoveActorY
MWG_NoYMove:    lda actSX,x                     ;Have X-speed?
                beq MWG_NoXMove
                jsr MoveActorX
                lda temp5                       ;If grounded, check wall 1 char higher
                bne MWG_GroundedWallCheck
MWG_InAirWallCheck:
                jsr GetCharInfo
                jmp MWG_WallCheckDone
MWG_GroundedWallCheck:
                jsr GetCharInfo1Above
MWG_WallCheckDone:
                and #CI_OBSTACLE
                beq MWG_NoWallHit
                lda actSX,x                     ;If hit wall, back out & set flag
                bmi MWG_HitWallLeft
MWG_HitWallRight:
                lda actXL,x
                ora #$3f
                sec
                sbc #$40
                sta actXL,x
                bcs MWG_HitWallDone
                dec actXH,x
                bcc MWG_HitWallDone
MWG_HitWallLeft:lda actXL,x
                and #$c0
                clc
                adc #$40
                sta actXL,x
                bcc MWG_HitWallDone
                inc actXH,x
MWG_HitWallDone:lda temp5
                ora #MB_HITWALL
                sta temp5
MWG_NoWallHit:
MWG_NoXMove:    lda temp5                       ;Do in air or grounded collision checks?
                lsr
                bcc MWG_InAir
                jmp MWG_OnGround

MWG_InAir:      lda actSY,x                     ;Check landing or ceiling hit?
                bpl MWG_CheckLanding
MWG_CheckCeiling:
                jsr GetCharInfo
                and #CI_WATER
                beq MWG_NoWater2
                lda temp5
                ora #MB_INWATER
                sta temp5
MWG_NoWater2:   lda temp4
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
                sta temp6
                beq MWG_HitGround2
                eor actSX,x                     ;If it's a diagonal slope, verify that X-speed
                bpl MWG_HitGround2              ;is actually against it
MWG_NoLanding:  lda temp5
                sta actMB,x
                rts

MWG_CheckLanding:
                jsr GetCharInfo                 ;Get charinfo at actor pos
                tay
                and #CI_WATER
                beq MWG_NotInWater
                lda temp5
                ora #MB_INWATER
                sta temp5
MWG_NotInWater: tya
                lsr                             ;Hit ground?
                bcc MWG_CheckCharCrossY         ;If not directly, check also possible char crossing
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
MWG_CheckCharCrossY:
                lda actYL,x
                and #$3f
                sec
                sbc actSY,x
                bcs MWG_NoLanding
MWG_CrossedChar:jsr GetCharInfo1Above           ;Get char above
                tay
                lsr
                bcc MWG_NoLanding
                lda #-8*8                       ;Move the actor 1 char up
                jsr MoveActorY
                tya
                ldy #$00
                and #$e0                        ;Get slopebits again, optimize for slope0
                beq MWG_HitGround
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
                sta actMB,x
                rts

MWG_OnGround:   jsr GetCharInfo                 ;Check that we still have ground under feet (may have
                tay                             ;crossed a char vertically while on a slope, so may need
                lsr                             ;to adjust position either up or down, or the ground might
                bcs MWG_FinalizeGround          ;actually have disintegrated)
                jsr GetCharInfo1Above           ;Check first above
                tay
                lsr
                bcs MWG_FinalizeGroundAbove
                jsr GetCharInfo1Below           ;Then below
                tay
                lsr
                bcs MWG_FinalizeGroundBelow
                lda temp5                       ;Start falling
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
