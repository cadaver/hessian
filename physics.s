        ; Move actor in a straight line and return charinfo from final position
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,X,Y,temp vars

MoveProjectile: lda actSX,x
                jsr MoveActorX
                lda actSY,x
                jsr MoveActorY
                jmp GetCharInfoActor

        ; Move actor with gravity and ground/wall collisions. Does not modify horizontal velocity
        ; Note: unlike MW1-4, solid walls with ground on top should have the obstacle-bit set
        ; also on the ground. Otherwise it's possible to clip through by moving diagonally across
        ; a char boundary
        ;
        ; Parameters: X actor index, A gravity acceleration (should be positive), Y speed limit,
        ;             temp1 vertical char offset (negative) for ceiling check
        ; Returns: A bit 0 = is on ground, A bit 1 = hit side wall, A bit 7 = hit ceiling
        ; Modifies: A,X,Y,temp regs

MoveWithGravity:jsr AccMoveActorY               ;First do Y-move
                lda actSY,x                     ;Going up or down?
                bmi MWG_GoingUp
MWG_GoingDown:  jsr GetCharInfoActor            ;Get charinfo at actor pos
                and #CI_GROUND                  ;Hit ground? Todo: slope and stairs checks
                beq MWG_InAir
MWG_OnGround:   lda actYL,x                     ;Align actor Y-coord on the ground
                and #$c0
                sta actYL,x
                lda #$00                        ;Reset vertical velocity to zero
                sta actSY,x
                lda actXL,x                     ;Store X pos so it can be restored when hitting wall
                sta temp3
                lda actXH,x
                sta temp4
                lda actSX,x
                beq MWG_OnGroundDone
                jsr MoveActorX
                jsr SetCharInfoPosActor
                lda #-1                         ;Check for wall collision one char up
                jsr MoveCharInfoPosY
                jsr GetCharInfo
                and #CI_OBSTACLE
                beq MWG_OnGroundDone
                lda temp3                       ;Hit wall, restore previous position
                sta actXL,x
                lda temp4
                sta actXH,x
                lda #$03                        ;Side wall + on ground
                rts
MWG_OnGroundDone:
                lda #$01                        ;On ground, did not hit wall
                rts

MWG_InAir:      lda #$00
MWG_InAirReturnValue:
                sta temp2
                lda actXL,x                     ;Store X pos so it can be restored when hitting wall
                sta temp3
                lda actXH,x
                sta temp4
                lda actSX,x
                beq MWG_InAirDone
MWG_InAirRight: jsr MoveActorX
                jsr GetCharInfoActor
                and #CI_OBSTACLE
                beq MWG_InAirDone
                lda temp3                       ;Hit wall, restore previous position
                sta actXL,x
                lda temp4
                sta actXH,x
                lda #$02                        ;Side wall + in air
                ora temp2
                rts
MWG_InAirDone:  lda temp2                       ;In air, no wall collision
                rts

MWG_GoingUp:    jsr SetCharInfoPosActor         ;When going up, check ceiling collision
                lda temp1
                jsr MoveCharInfoPosY
                jsr GetCharInfo
                and #CI_OBSTACLE
                beq MWG_InAir
MWG_CeilingHit: lda #$80
                bne MWG_InAirReturnValue
