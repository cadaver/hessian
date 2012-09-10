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

        ; Melee hit update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveMeleeHit:   dec actTime,x
                bmi MBlt_Remove
                jmp CheckBulletCollisions

        ; Bullet update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MBlt_Remove:    jmp RemoveActor
MoveBullet:     dec actTime,x
                bmi MBlt_Remove
                jsr MoveProjectile
                and #CI_OBSTACLE
                bne MBlt_Remove

        ; Check bullet collisions
        ;
        ; Parameters: X bullet actor index
        ; Returns: -
        ; Modifies: A,Y,temp variables

CheckBulletCollisions:
                lda actGrp,x
                bmi CBC_CheckHeroes
CBC_CheckVillains:
                lda #<villainList
                sta CBC_GetNextVillain+1
CBC_GetNextVillain:
                ldy villainList
                bmi CBC_Done
                inc CBC_GetNextVillain+1
                jsr CheckActorCollision
                bcc CBC_GetNextVillain
CBC_HasCollision:
                lda actHp,x                     ;Damage target and destroy bullet
                bmi CBC_RadiusDamage
                pha                             ;(bullet's damage value stored as its health)
                tya
                tax
                pla
                jsr DamageActor
                ldx actIndex
                jmp DestroyActor
CBC_RadiusDamage:
                and #$7f
                jsr RadiusDamage
                jmp DestroyActor

CBC_CheckHeroes:lda #<heroList
                sta CBC_GetNextHero+1
CBC_GetNextHero:ldy heroList
                bmi CBC_Done
                inc CBC_GetNextHero+1
                jsr CheckActorCollision
                bcc CBC_GetNextHero
                bcs CBC_HasCollision

        ; Explode grenade and do radius damage
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A

ExplodeGrenade: lda actHp,x
                and #$7f
                ldy #$ff
                jsr RadiusDamage

        ; Turn an actor into an explosion
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A

ExplodeActor:   lda #$00
                sta actF1,x
                sta actFd,x
                sta actC,x                      ;Remove flashing
                lda #ACT_EXPLOSION
                sta actT,x
                lda #SFX_EXPLOSION
                jmp PlaySfx

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
CBC_Done:
MExpl_NoAnimation:
MExpl_NoRemove: rts

        ; Grenade update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveGrenade:    dec actTime,x
                bmi ExplodeGrenade
                lda #$00                        ;Grenade never stays grounded
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
                beq MGrn_CheckCollisions
                lda actSX,x
                jsr Asr8
MGrn_StoreNewXSpeed:
                sta actSX,x
MGrn_CheckCollisions:
                jmp CheckBulletCollisions

        ; Give radius damage up to 2 blocks away (both heroes & villains)
        ;
        ; Parameters: X source actor index (must also be in actIndex), A damage amount, 
        ;             Y direct hit target actor index ($ff if none)
        ; Returns: -
        ; Modifies: A,Y,temp1,temp2,temp5-temp8,possibly other temp registers
        
RD_HalfDamage:  tya
                tax
                lda temp1
                lsr
                bpl RD_DamageCommon

RadiusDamage:   sta temp1
                sty temp2
                ldy #ACTI_LASTNPC
RD_Loop:        lda actT,y
                beq RD_Next
                lda actHp,y
                beq RD_Next
RD_DirectHitCmp:cpy temp2
                beq RD_FullDamage
                jsr GetActorDistance
                lda temp7                       ;If Y-distance >0 decrement it by one
                beq RD_NoYAdjust                ;because enemies/player have height
                bmi RD_NoYAdjust
                dec temp8
RD_NoYAdjust:   lda temp6                       ;Take the greater of X & Y distance
                cmp temp8
                bcs RD_XDistGreater
                lda temp8
RD_XDistGreater:cmp #$01
                beq RD_HalfDamage
                bcs RD_Next
RD_FullDamage:  tya
                tax
                lda temp1
RD_DamageCommon:sty temp3
                jsr DamageActor
                ldx actIndex
                ldy temp3
RD_Next:        dey
                bpl RD_Loop
                rts



