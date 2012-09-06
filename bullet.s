        ; Bullet update routine with muzzle flash as first frame
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MBltMF_FirstFrame:
                inc actFd,x
                rts

MoveBulletMuzzleFlash:
                lda actFd,x                     ;First frame: just show the muzzle flash
                beq MBltMF_FirstFrame           ;and do not move
                lda actF1,x
                cmp #$0a
                bcs MoveBullet
                adc #$0a
                sta actF1,x
                jsr MoveBullet
                jmp NoInterpolation             ;No interpolation on second frame
                                                ;to prevent flash from appearing in different
                                                ;position dependent on flashing order

        ; Bullet update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveBullet:     jsr MoveProjectile
                and #CI_OBSTACLE
                bne MBlt_Remove
                
        ; Mele hit update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveMeleeHit:   dec actTime,x
                bne MBlt_NoRemove
MBlt_Remove:    jmp RemoveActor
MBlt_Explode:   lda #$00
                sta actF1,x
                sta actFd,x
                sta actC,x                      ;Remove flashing
                lda #ACT_EXPLOSION
                sta actT,x
                lda #SFX_EXPLOSION
                jmp PlaySfx
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

        ; Grenade update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveGrenade:    lda #$00                        ;Grenade never stays grounded
                sta actMoveFlags,x
                lda actSY,x                     ;Store original Y-speed for bounce
                sta temp1
                lda #-1                         ;Ceiling check offset
                sta temp4
                lda #4
                ldy #-3*8
                jsr MoveWithGravity
                lsr
                bcc MGrn_NoBounce
                lda temp1                       ;Bounce: negate and halve velocity
                jsr Negate8Asr8
                sta actSY,x
                lda #8                          ;Brake X-speed with each bounce
                jsr BrakeActorX
MGrn_NoBounce:  lda actMoveFlags,x
                and #AMF_HITWALL|AMF_HITCEILING
                cmp #AMF_HITWALL
                bne MGrn_NoHitWall
                lda actSX,x
                jsr Negate8Asr8
                jmp MGrn_StoreNewXSpeed
MGrn_NoHitWall: and #AMF_HITCEILING             ;Halve X-speed when hit ceiling
                beq MGrn_DecrementTime
                lda actSX,x
                jsr Asr8
MGrn_StoreNewXSpeed:
                sta actSX,x
MGrn_DecrementTime: 
                dec actTime,x
                beq MBlt_Explode
                bne MBlt_NoRemove
