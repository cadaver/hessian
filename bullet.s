GRENADE_DMG_RADIUS = 48
GRENADE_MAX_YSPEED = 6*8
GRENADE_ACCEL   = 4

        ; Shotgun bullet update routine. Expands collision and reduces damage as the
        ; bullet moves
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveShotgunBullet:
                lda actF1,x
                cmp #$0a
                bcs MSBlt_Cloud
                lda actFd,x
                beq MBltMF_FirstFrame
                lda #$0a
                bne MBltMF_Common
MSBlt_Cloud:    cmp #$0d
                bcs MSBlt_NoAnim
                lda #$02
                jsr AnimationDelay
                bcc MSBlt_NoAnim
                lda actSizeH,x                  ;C=1, increase size by 2
                adc #$01
                sta actSizeH,x
                sta actSizeU,x
                sta actSizeD,x
                dec actHp,x
                inc actF1,x
MSBlt_NoAnim:   jmp MoveBullet

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
MBltMF_Common:  sta actF1,x
                jsr MoveBullet
                jmp NoInterpolation             ;No interpolation on second frame
                                                ;to prevent flash from appearing in different
                                                ;position dependent on flashing order

        ; Flame update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveFlame:      lda #3
                jsr AnimationDelay
                bcc MoveBullet
                lda actF1,x
                cmp #$03
                bcs MoveBullet
                inc actF1,x
                bcc MoveBullet

        ; Melee hit update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveMeleeHit:   dec actTime,x
                bmi MBlt_Remove
                jmp CheckBulletCollisionsApplyDamage

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

CheckBulletCollisionsApplyDamage:
                clc

        ; Check bullet collisions
        ;
        ; Parameters: X bullet actor index, C=0 apply damage C=1 report collisions only
        ; Returns: C=1 if collided (report mode)
        ; Modifies: A,Y,tgtActIndex,temp variables

CheckBulletCollisions:
                ror temp8
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
                lda temp8
                bmi CBC_ReportOnly
                sty tgtActIndex
                lda actAuxData,x                ;Damage modifier
                sta temp7
                lda actHp,x                     ;Amount of damage
                sta temp8
                ldx tgtActIndex
                lda actGrp,x                    ;Check if target is organic
                and #AF_ISORGANIC
                beq CBC_NonOrganic
CBC_Organic:    lda temp7
                and #$0f
                bpl CBC_Common
CBC_NonOrganic: lda temp7
                lsr
                lsr
                lsr
                lsr
CBC_Common:     tay
                lda temp8
                jsr ModifyDamage
                tay
                beq CBC_NoDamage
                ldy actIndex
                jsr DamageActor
CBC_NoDamage:   ldx actIndex
                ldy #$ff                        ;Destroy bullet without damage source
                jmp DestroyActor
CBC_Done:       clc
CBC_ReportOnly: rts

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

ExplodeGrenade: lda #2                          ;If there's ground (obstacle) below the grenade,
                jsr GetCharInfoOffset           ;reduce blast radius in down direction, otherwise
                lsr                             ;it is equal size
                lsr
                lda #GRENADE_DMG_RADIUS
                bcc EGrn_FullDamageBelow
                lsr
                lsr
EGrn_FullDamageBelow:
                sta actSizeD,x
                lda #GRENADE_DMG_RADIUS         ;Expand grenade collision size for radius damage
                sta actSizeH,x
                sta actSizeU,x
                lda #$00                        ;Clear the X-speed so that possible death impulse
                sta actSX,x                     ;only depends on enemy's relative location to the
                lda actHp,x                     ;grenade
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
MExpl_NoAnimation:
MExpl_NoRemove: rts

        ; Grenade launcher grenade update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveLauncherGrenade:
                lda #$02
                jsr AnimationDelay
                bcc MLG_NoAnimation
                lda actF1,x
                adc #$00
                cmp #$03
                bcc MLG_AnimNotOver
                lda #$00
MLG_AnimNotOver:sta actF1,x
MLG_NoAnimation:
                sec                             ;Explode if touches enemy
                jsr CheckBulletCollisions
                bcs ExplodeGrenade

        ; Grenade update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveGrenade:    dec actTime,x
                bmi ExplodeGrenade
                lda #$00                        ;Grenade never stays grounded
                sta actMB,x
                lda actSY,x                     ;Store original Y-speed for bounce
                sta temp1
                lda #-1                         ;Ceiling check offset
                sta temp4
                lda #GRENADE_ACCEL
                ldy #GRENADE_MAX_YSPEED
                jsr MoveWithGravity
                lsr
                bcc MGrn_NoBounce
                lda temp1                       ;Bounce: negate and halve velocity
                jsr Negate8Asr8
                sta actSY,x
                lda #8                          ;Brake X-speed with each bounce
                jsr BrakeActorX
MGrn_NoBounce:  lda actMB,x
                and #MB_HITWALL|MB_HITCEILING
                cmp #MB_HITWALL
                bne MGrn_NoHitWall
                lda actSX,x
                jsr Negate8Asr8
                jmp MGrn_StoreNewXSpeed
MGrn_NoHitWall: and #MB_HITCEILING              ;Halve X-speed when hit ceiling
                beq MGrn_Done
                lda actSX,x
                jsr Asr8
MGrn_StoreNewXSpeed:
                sta actSX,x
MGrn_Done:      rts



        ; Give radius damage to both heroes & villains. Prior to calling, expand the
        ; collision size of the source actor as necessary
        ;
        ; Parameters: X source actor index (must also be in actIndex), A damage amount
        ; Returns: -
        ; Modifies: A,Y,tgtActIndex,possibly other temp registers

RadiusDamage:   sta RD_Damage+1
                ldy #ACTI_LASTNPC
RD_Loop:        lda actT,y
                beq RD_Next
                lda actHp,y
                beq RD_Next
                lda actGrp,y
                and #AF_ISHERO|AF_ISVILLAIN
                beq RD_Next
                jsr CheckActorCollision
                bcc RD_Next
                sty tgtActIndex
RD_Damage:      lda #$00
                ldx tgtActIndex
                ldy actIndex
                jsr DamageActor
                ldx actIndex
                ldy tgtActIndex
RD_Next:        dey
                bpl RD_Loop
                rts

