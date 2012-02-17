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
                ldy actSX,x                     ;Have X-speed?
                beq MWG_NoWall
                lda actXL,x                     ;Store old X-pos in case we hit a wall
                sta temp3
                lda actXH,x
                sta temp4
                tya
                jsr MoveActorX
                lda temp2                       ;If grounded, check wall 1 char higher
                bne MWG_GroundedWallCheck
MWG_InAirWallCheck:
                jsr GetCharInfo
                jmp MWG_WallCheckDone
MWG_GroundedWallCheck:
                lda #-1
                jsr GetCharInfoOffset
MWG_WallCheckDone:
                and #CI_OBSTACLE
                beq MWG_NoWall
                lda temp3                       ;If hit wall, restore X-pos & set flag
                sta actXL,x
                lda temp4
                sta actXH,x
                lda temp2
                ora #AMF_HITWALL
                sta temp2
MWG_NoWall:     lda temp2                       ;Do in air or grounded movement?
                lsr
                bcc MWG_InAir
                jmp MWG_OnGround

MWG_InAir:      lda temp5
                ldy temp6
                jsr AccMoveActorY
                lda actSY,x                     ;Check landing or ceiling hit?
                bpl MWG_CheckLanding
MWG_CheckCeiling:
                lda temp1
                jsr GetCharInfoOffset
                and #CI_OBSTACLE
                beq MWG_NoCeiling
                lda temp2
                ora #AMF_HITCEILING
                sta actMoveFlags,x
                rts
MWG_NoLanding:
MWG_NoCeiling:  lda temp2
                sta actMoveFlags,x
                rts

MWG_CheckLanding:
                jsr GetCharInfo                 ;Get charinfo at actor pos
                sta temp1
                lsr                             ;Hit ground?
                bcc MWG_CheckCharCross          ;If not directly, check also possible char crossing
                ldy #$00
                lda temp1                       ;Get the slopebits
                and #$e0
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
MWG_CheckCharCross:
                lda actYL,x
                and #$3f
                sec
                sbc actSY,x
                bcs MWG_NoLanding
                lda #-1                         ;Get char above
                jsr GetCharInfoOffset
                sta temp1
                lsr
                bcc MWG_NoLanding
                lda #-8*8                       ;Move the actor 1 char up
                jsr MoveActorY
                ldy #$00
                lda temp1                       ;Get slopebits again, optimize for slope0
                and #$e0
                beq MWG_HitGround
                sta temp3
                lda actXL,x
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
                sta temp1                       ;crossed a char vertically while on a slope, so may need
                lsr                             ;to adjust position either up or down, or the ground might
                bcs MWG_FinalizeGround          ;actually have disintegrated)
                lda #1                          ;Check below
                jsr GetCharInfoOffset
                sta temp1
                lsr
                bcs MWG_FinalizeGroundBelow     ;Todo: allow intention to prefer either up or down
                lda #-1                         ;direction (for stairs junctions)
                jsr GetCharInfoOffset
                sta temp1
                lsr
                bcs MWG_FinalizeGroundAbove
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
                ldy #$00
                lda temp1                       ;Get slopebits, optimize for slope0
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
