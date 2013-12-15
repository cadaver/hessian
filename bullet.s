GRENADE_DMG_RADIUS = 32
GRENADE_MAX_YSPEED = 6*8
GRENADE_ACCEL   = 4

DRONE_IDLE_ACCEL = 4
DRONE_ATTACK_ACCEL = 6
DRONE_MAXSPEED = 4*8

        ; Smoketrail update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveSmokeTrail: ldy #2
                SKIP2

        ; Small water splash update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveSmallSplash:ldy #3
                SKIP2

        ; Explosion / large water splash update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveWaterSplash:
MoveExplosion:  ldy #5
AnimateAndRemoveDelay1:
                lda #1
AnimateAndRemove:
                sty temp8
                jsr AnimationDelay
                bcc MExpl_NoAnimation
                inc actF1,x
                lda actF1,x
                cmp temp8
                bcs MMH_Remove
MExpl_NoAnimation:
MRckt_Done:
MExpl_NoRemove: rts

        ; Melee hit update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveMeleeHit:   jsr CheckBulletCollisionsApplyDamage
MMH_Remove:     jmp RemoveActor

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

        ; Bullet update routine with muzzle flash as first frame
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveBulletMuzzleFlash:
                lda actF1,x
                cmp #$0a
                bcs MoveBullet
                adc #$0a
MBltMF_Common:  sta actF1,x
                jsr MoveBullet
                jmp NoInterpolation             ;Prevent muzzle flash from interpolating

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
                inc actFd,x
                lda #$0a
                bne MBltMF_Common
MBlt_Remove:    jmp RemoveActor
MSBlt_Cloud:    lda #$02
                jsr AnimationDelay
                bcc MSBlt_NoAnim
                lda actSizeH,x                  ;C=1, increase size by 2
                adc #$01
                sta actSizeH,x
                sta actSizeU,x
                sta actSizeD,x
                lda actHp,x
                sbc #$02                        ;C=0, decrease damage by 3
                sta actHp,x
                inc actF1,x
MSBlt_NoAnim:   

        ; Bullet update routine. Check collisions, then move
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveBullet:     jsr CheckBulletCollisionsApplyDamage
                dec actTime,x
                bmi MBlt_Remove

        ; Move actor in a straight line and return charinfo from final position.
        ; If hit water, transform into a splash
        ; If hit an obstacle, call the destruct routine
        ; Note: do not JSR into this, but jump at the end of bullet move routine
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,Y,temp vars

MoveProjectile: lda actSX,x
                jsr MoveActorX
                lda actSY,x
                jsr MoveActorY
                jsr GetCharInfo
                tay
                and #CI_WATER|CI_OBSTACLE
                beq MProj_Done
                cpy #CI_WATER
                beq MProj_HitWater
MProj_HitObstacle:
                ldy #NODAMAGESRC                ;Destroy actor without specific damage source
                jmp DestroyActor
MProj_Done:     tya
                rts
MProj_HitWater: lda #-1                         ;If water 1 already char above, move upward
                jsr GetCharInfoOffset           ;(bullets may move faster than 8 pixels/frame)
                and #CI_WATER
                beq MProj_NoWaterAbove
                lda #-8*8
                jsr MoveActorY
MProj_NoWaterAbove:
                lda actYL,x
                and #$c0
                sta actYL,x
                lda actSX,x
                jsr Asr8
                jsr MoveActorXNeg               ;Move actor halfway back in X-dir
                jsr NoInterpolation
                lda actT,x
                cmp #ACT_SONICWAVE
                bcs MProj_LargeSplash
                lda #ACT_SMALLSPLASH
                bne MProj_SplashOK
MProj_LargeSplash:
                lda #SFX_SPLASH
                jsr PlaySfx
                lda #ACT_WATERSPLASH
MProj_SplashOK: jsr TransformBullet
                lda lvlWaterSplashColor
                sta actC,x
                rts

        ; Rocket update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MRckt_Remove:   jmp RemoveActor
MoveRocket:     lda actTime,x
                lsr
                bcc MRckt_NoSmoke
                lda #ACTI_FIRSTEFFECT
                ldy #ACTI_LASTEFFECT
                jsr GetFreeActor
                bcc MRckt_NoSmoke
                lda #ACT_SMOKETRAIL
                jsr SpawnActor
                tya
                jsr GetFlickerColorOverride
                sta actC,y
MRckt_NoSmoke:  sec
                jsr CheckBulletCollisions
                bcs ExplodeGrenade
                dec actTime,x
                bmi MRckt_Remove
                jmp MoveProjectile

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
                sec
                jsr CheckBulletCollisions
                bcs ExplodeGrenade
                dec actTime,x
                bmi ExplodeGrenade
                lda #-1                         ;Ceiling check offset
                sta temp4
                lda #GRENADE_ACCEL
                ldy #GRENADE_MAX_YSPEED
                jsr MoveWithGravity
                tay
                and #MB_INWATER
                bne MGrn_HitWater
                tya
                and #MB_HITWALL|MB_HITCEILING|MB_LANDED
                bne ExplodeGrenade              ;Explode on any wall/ground contact
                rts

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
                jsr RadiusDamage                ;grenade

        ; Turn an actor into an explosion
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A

ExplodeActor:   lda #SFX_EXPLOSION
                jsr PlaySfx
                lda #ACT_EXPLOSION
TransformBullet:sta actT,x
                lda #$00
                sta actF1,x
                sta actFd,x
                sta actC,x                      ;Remove flashing
                rts

        ; Grenade update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MGrn_HitWater:  jmp RemoveActor                 ;MoveWithGravity already created splash, just remove
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
                tay
                and #MB_INWATER
                bne MGrn_HitWater
                tya
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
MEMP_NoAnim:
MGrn_Done:      rts

        ; EMP blast update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveEMP:        lda actTime,x                   ;TODO: should possibly not manipulate
                cmp #$01                        ;background colors directly
                bcc MEMP_ColorDone
                beq MEMP_Restore
                lda #$01
                sta Irq1_Bg1+1
                sta Irq1_Bg2+1
                sta Irq1_Bg3+1
                sta actTime,x
                bne MEMP_ColorDone
MEMP_Restore:   jsr SetZoneColors
MEMP_ColorDone: jsr RadiusDamage
                lda actSX,x
                jsr MoveActorX
                lda #1
                jsr AnimationDelay
                bcc MEMP_NoAnim
                inc actF1,x
                lda actF1,x
                cmp #$04
                bcc MEMP_NoAnim
                jmp RemoveActor

        ; Plasma update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MovePlasma:     lda #$02
                jsr AnimationDelay
                bcc MPls_NoAnim
                lda actF1,x
                adc #$00
                cmp #$03
                bcc MPls_AnimDone
                lda #$00
MPls_AnimDone:  sta actF1,x
MPls_NoAnim:    jmp MoveBullet

        ; Drone update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveDrone:      lda actFd,x
                inc actFd,x
                lsr
                lsr
                and #$03
                sta actF1,x
                jsr FindTarget
                ldy actAITarget,x
                bmi MDrn_Idle
MDrn_HasTarget: lda actSizeU,y
                asl
                adc actSizeU,y
                bcs MDrn_MaxSize
                asl
                bcc MDrn_NoMaxSize
MDrn_MaxSize:   lda #$ff
MDrn_NoMaxSize: clc                             ;Offset Y-check location by 3/4 of
                adc actYL,x                     ;target's up size, up to 32 pixels
                sta temp1
                lda actYH,x
                adc #$00
                sta temp2
                lda actYL,y
                sec
                sbc temp1
                lda actYH,y
                sbc temp2
                sta temp7
                bpl MDrn_YDistPos
                eor #$ff
MDrn_YDistPos:  sta temp8
                jsr GetActorXDistance
                lda temp5
                asl                             ;Horizontal direction to carry
                lda #DRONE_ATTACK_ACCEL
                ldy #DRONE_MAXSPEED
                jsr AccActorXNegOrPos
                lda temp7
                asl                             ;Vertical direction to carry
                lda #DRONE_ATTACK_ACCEL
                bne MDrn_AccCommon
MDrn_Idle:      ldy actF1,x
                iny
                tya
                and #$02                        ;Oscillate between down/up acceleration
                lsr
                lsr
                lda #DRONE_IDLE_ACCEL
MDrn_AccCommon: ldy #DRONE_MAXSPEED
                jsr AccActorYNegOrPos
                jsr CheckBulletCollisionsApplyDamage
                dec actTime,x
                bmi MDrn_Expire
                lda #$00
                sta temp4
                ldy #$00
                jmp MoveFlyer
MDrn_Expire:    jmp ExplodeActor                ;Explode harmlessly

        ; Check bullet collisions and optionally apply damage
        ;
        ; Parameters: X bullet actor index, C=0 apply damage and remove bullet
        ;             (will not return if collided), C=1 only report collision
        ; Returns: C=1 if collided, Y target actor
        ; Modifies: A,Y,tgtActIndex,temp variables

CheckBulletCollisionsApplyDamage:
                clc
CheckBulletCollisions:
                ror temp7
                lda #<targetList
                sta CBC_GetNextTarget+1
CBC_GetNextTarget:
                ldy targetList
                bmi CBC_Done
                inc CBC_GetNextTarget+1
                lda actFlags,x
                eor actFlags,y
                and #AF_GROUPBITS
                beq CBC_GetNextTarget           ;Must not be in the same group
                jsr CheckActorCollision
                bcc CBC_GetNextTarget
CBC_HasCollision:
                lda temp7
                bmi CBC_ReportOnly
                sty tgtActIndex
                jsr ModifyTargetDamage
                tay
                beq CBC_NoDamage
                jsr DamageTargetActor
CBC_NoDamage:   ldx actIndex
                ldy #NODAMAGESRC                ;Destroy bullet with no damage source
                pla
                pla
                jmp DestroyActor
CBC_Done:       clc
CBC_ReportOnly: rts

        ; Give radius damage to all NPC actors. Prior to calling, expand the
        ; collision size of the source actor as necessary
        ;
        ; Parameters: X source actor index (must also be in actIndex)
        ; Returns: -
        ; Modifies: A,Y,tgtActIndex,possibly other temp registers

RadiusDamage:   ldy #ACTI_LASTNPC
RD_Loop:        lda actT,y
                beq RD_Next
                lda actFlags,y
                and #AF_GROUPBITS
                beq RD_Next                     ;Skip bystander (none) group
                jsr CheckActorCollision
                bcc RD_Next
                sty tgtActIndex
                jsr ModifyTargetDamage
                tay
                beq RD_SkipDamage
                jsr DamageTargetActor
RD_SkipDamage:  ldx actIndex
                ldy tgtActIndex
RD_Next:        dey
                bpl RD_Loop
                rts

