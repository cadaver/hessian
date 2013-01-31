GRENADE_DMG_RADIUS = 32
GRENADE_MAX_YSPEED = 6*8
GRENADE_ACCEL   = 4

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
                lda actFlags,x
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
                lda temp7
                bmi CBC_ReportOnly
                sty tgtActIndex
                jsr ModifyTargetDamage
                tay
                beq CBC_NoDamage
                ldx tgtActIndex
                ldy actIndex
                jsr DamageActor
CBC_NoDamage:   ldx actIndex
                ldy #$ff                        ;Destroy bullet with no damage source
                pla
                pla
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

        ; Give radius damage to both heroes & villains. Prior to calling, expand the
        ; collision size of the source actor as necessary
        ;
        ; Parameters: X source actor index (must also be in actIndex)
        ; Returns: -
        ; Modifies: A,Y,tgtActIndex,possibly other temp registers

RadiusDamage:   ldy #ACTI_LASTNPC
RD_Loop:        lda actT,y
                beq RD_Next
                lda actHp,y
                beq RD_Next
                lda actFlags,y
                and #AF_ISHERO|AF_ISVILLAIN
                beq RD_Next
                jsr CheckActorCollision
                bcc RD_Next
                sty tgtActIndex
                jsr ModifyTargetDamage
                tay
                beq RD_SkipDamage
                ldx tgtActIndex
                ldy actIndex
                jsr DamageActor
RD_SkipDamage:  ldx actIndex
                ldy tgtActIndex
RD_Next:        dey
                bpl RD_Loop
                rts

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
MSBlt_NoAnim:   jmp MoveBullet

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

MoveMeleeHit:   jsr CheckBulletCollisionsApplyDamage
MBlt_Remove:    jmp RemoveActor

        ; Bullet update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveBullet:     jsr CheckBulletCollisionsApplyDamage
                dec actTime,x
                bmi MBlt_Remove
                jsr MoveProjectile
                and #CI_OBSTACLE
                bne MBlt_Remove
                rts

        ; Smoketrail update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveSmokeTrail: lda #1
                ldy #2
                bne AnimateAndRemove

        ; Explosion update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveExplosion:  lda #1
                ldy #5
AnimateAndRemove:
                sty temp8
                jsr AnimationDelay
                bcc MExpl_NoAnimation
                inc actF1,x
                lda actF1,x
                cmp temp8
                bne MExpl_NoRemove
                jmp RemoveActor
MExpl_NoAnimation:
MExpl_NoRemove: rts

        ; Rocket update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

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
                jsr MoveProjectile
                and #CI_OBSTACLE
                bne ExplodeGrenade
MRckt_CheckEnemyCollisions:
                rts
MRckt_Remove:   jmp RemoveActor

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
                dec actTime,x
                bmi ExplodeGrenade
                lda #-1                         ;Ceiling check offset
                sta temp4
                lda #GRENADE_ACCEL
                ldy #GRENADE_MAX_YSPEED
                jsr MoveWithGravity
                tay
                beq MRckt_CheckEnemyCollisions
                bne ExplodeGrenade              ;Explode on any wall/ground contact

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

ExplodeActor:   lda #$00
                sta actF1,x
                sta actFd,x
                sta actC,x                      ;Remove flashing
                lda #ACT_EXPLOSION
                sta actT,x
                lda #SFX_EXPLOSION
                jmp PlaySfx

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
                jsr MoveProjectile
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
