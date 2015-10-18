        ; Flying enemy update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveFlyingEnemy:jsr MoveAccelerateFlyer
                jmp AttackHuman

MoveAccelerateFlyer:
                lda #FR_JUMP                    ;Set jump frame (todo: remove/replace)
                sta actF1,x
                sta actF2,x
                ldy #AL_MOVESPEED
                lda (actLo),y
                sta temp4                       ;Max. speed
                lda actMoveCtrl,x
                and #JOY_LEFT|JOY_RIGHT
                beq MFE_NoHorizAccel
                and #JOY_LEFT
                beq MFE_TurnRight
                lda #$80
MFE_TurnRight:  sta actD,x
                asl                             ;Direction to carry
                iny
                lda (actLo),y                   ;Horizontal acceleration
                ldy temp4
                jsr AccActorXNegOrPos
MFE_NoHorizAccel:
                lda actMoveCtrl,x
                and #JOY_UP|JOY_DOWN
                beq MFE_NoVertAccel
                cmp #JOY_UP
                beq MFE_AccelUp                 ;C=1 accelerate up (negative)
                clc
MFE_AccelUp:    ldy #AL_VERTACCEL
                lda (actLo),y                   ;Vertical acceleration
                ldy temp4
                jsr AccActorYNegOrPos
MFE_NoVertAccel:ldy #AL_XCHECKOFFSET            ;Horizontal obstacle check offset
                lda (actLo),y
                sta temp4
                iny
                lda (actLo),y                   ;Vertical obstacle check offset
                ldy #0
                jsr MoveFlyer
                lda actMB,x
                tay
                and #MB_HITWALL
                beq MFE_NoHorizWall
                lda #$00
                sta actSX,x                     ;Stop speed if hit wall
MFE_NoHorizWall:tya
                and #MB_HITWALLVERTICAL
                beq MFE_NoVertWall
                lda #$00
                sta actSY,x
MFE_NoVertWall: rts


