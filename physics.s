AMF_GROUNDED    = 1
AMF_LANDED      = 2
AMF_HITWALL     = 4
AMF_HITCEILING  = 8

        ; Move actor in a straight line and return charinfo from final position
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,X,Y,temp vars

MoveProjectile: lda actSX,x
                jsr MoveActorX
                lda actSY,x
                jsr MoveActorY
                jmp GetCharInfo

        ; Move actor with gravity and ground/wall collisions. Does not modify horizontal velocity
        ;
        ;
        ; Parameters: X actor index, A gravity acceleration (should be positive), Y speed limit,
        ;             temp1 vertical char offset (negative) for ceiling check
        ; Returns: actMoveFlags updated
        ; Modifies: A,X,Y,temp regs

MoveWithGravity:sta temp5
                sty temp6
                lda actMoveFlags,x              ;Only retain the grounded flag
                and #AMF_GROUNDED
                sta temp2
                lda actSX,x                     ;Have X-speed?
                beq MWG_NoWall
                jsr MoveActorX
                lda temp2                       ;If grounded, check wall 1 char higher
                bne MWG_GroundedWallCheck
MWG_InAirWallCheck:
                jsr GetCharInfo
                jmp MWG_WallCheckDone
MWG_GroundedWallCheck:
                jsr GetCharInfo1Above
MWG_WallCheckDone:
                and #CI_OBSTACLE
                beq MWG_NoWall
                lda actSX,x                     ;If hit wall, restore X-pos & set flag
                eor #$ff
                clc
                adc #$01
                jsr MoveActorX
                lda temp2
                ora #AMF_HITWALL
                sta temp2
MWG_NoWall:     lda temp2                       ;Do in air or grounded movement?
                lsr
                bcc MWG_InAir
                jmp MWG_OnGround

MWG_InAir:      lda temp5
                ldy temp6
                jsr AccActorY
                lda actSY,x                     ;Check landing or ceiling hit?
                bpl MWG_CheckLanding
MWG_CheckCeiling:
                jsr MoveActorY
                lda temp1
                jsr GetCharInfoOffset
                and #CI_OBSTACLE
                beq MWG_NoCeiling
                lda temp2
                ora #AMF_HITCEILING
                sta actMoveFlags,x
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
                and #$e0
                beq MWG_NoLanding               ;Check that it's an actual diagonal slope
                sta temp3                       ;and that the X-speed is against the slope
                eor actSX,x
                bpl MWG_HitGround2
MWG_NoLanding:  lda temp2
                sta actMoveFlags,x
                rts

MWG_CheckLanding:
                jsr MoveActorY
                jsr GetCharInfo                 ;Get charinfo at actor pos
                tay
                lsr                             ;Hit ground?
                bcc MWG_CheckCharCrossY         ;If not directly, check also possible char crossing
                tya
                ldy #$00
                and #$e0                        ;Get the slopebits
                beq MWG_HitGround               ;Optimization for slope0 (most common)
                sta temp3
                lda actXL,x
                lsr
                and #$1c
                ora temp3
                lsr
                lsr
                tay
                lda actYL,x
                and #$3f
                cmp slopeTbl,y
                bcs MWG_HitGround
                adc actSY,x                     ;Check if we would hit the slope next frame
                cmp slopeTbl,y
                bcs MWG_HitGround
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
                sta temp3
MWG_HitGround2: lda actXL,x
                lsr
                and #$1c
                ora temp3
                lsr
                lsr
                tay
MWG_HitGround:  lda #$00
                sta actSY,x                     ;Reset vertical velocity to zero
                lda actYL,x
                and #$c0
                ora slopeTbl,y
                sta actYL,x                     ;Align actor to slope
                lda temp2
                ora #AMF_GROUNDED|AMF_LANDED
                sta actMoveFlags,x
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
                lda temp2                       ;Start falling
                and #$ff-AMF_GROUNDED           ;Todo: may give sharper initial acceleration here
                sta actMoveFlags,x              ;if falling feels too smooth
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
                sta temp3
                lda actXL,x
                lsr
                and #$1c
                ora temp3
                lsr
                lsr
                tay
MWG_OnGroundDone:
                lda actYL,x
                and #$c0
                ora slopeTbl,y
                sta actYL,x
                lda temp2
                sta actMoveFlags,x
                rts
