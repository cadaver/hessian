                include macros.s
                include mainsym.s

        ; Script 1, loadable enemy movement routines + data, and common objects (rechargers)

FR_DEADRATAIR = 12
FR_DEADRATGROUND = 13
FR_DEADSPIDERAIR = 3
FR_DEADSPIDERGROUND = 4
FR_DEADFLY = 2
FR_DEADBATGROUND = 6
FR_DEADWALKERAIR = 12
FR_DEADWALKERGROUND = 13

SCRAP_DURATION = 40

TURRET_ANIMDELAY = 2

RECYCLER_ITEM_FIRST = ITEM_PISTOL
RECYCLER_ITEM_LAST = ITEM_BATTERY

                org scriptCodeStart

                dc.w MoveFlyingCraft
                dc.w MoveWalker
                dc.w MoveTank
                dc.w MoveFloatingMine
                dc.w MoveTurret
                dc.w MoveFire
                dc.w MoveSmokeCloud
                dc.w MoveRat
                dc.w MoveSpider
                dc.w MoveFly
                dc.w MoveBat
                dc.w MoveFish
                dc.w MoveRock
                dc.w MoveFireball
                dc.w MoveSteam
                dc.w MoveOrganicWalker
                dc.w DestroyFire
                dc.w RatDeath
                dc.w SpiderDeath
                dc.w FlyDeath
                dc.w BatDeath
                dc.w DestroyRock
                dc.w OrganicWalkerDeath
                dc.w MoveLargeWalker
                dc.w ExplodeEnemy2_8_Ofs6
                dc.w ExplodeEnemy2_8_Ofs10
                dc.w ExplodeEnemy3_Ofs15
                dc.w ExplodeEnemy4_Ofs15
                dc.w MoveScrapMetal
                dc.w MoveRockTrap
                dc.w MoveSpiderWalker
                dc.w ExplodeEnemy2_Ofs15
                dc.w MoveLargeTank
                dc.w MoveHighWalker
                dc.w ExplodeEnemy4_Rising
                dc.w MoveExplosionGeneratorRising
                dc.w UseHealthRecharger
                dc.w UseBatteryRecharger
                dc.w RechargerEffect
                dc.w RecyclingStation
                dc.w RecyclingStationLoop

        ; Flying craft update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveFlyingCraft:lda actHp,x
                beq MFC_Fall
                jsr MoveAccelerateFlyer
                lda actSX,x
                clc
                adc #2*8+4
                bpl MFC_FrameOK1
                lda #0
MFC_FrameOK1:   lsr
                lsr
                lsr
                cmp #5
                bcc MFC_FrameOK2
                lda #4
MFC_FrameOK2:   sta actF1,x
                cmp #2                          ;Cannot fire when no speed (middle frame)
                bne MFC_CanAttack
MFC_ContinueFall:
                rts
MFC_Fall:       jsr FallingMotionCommon
                tay
                beq MFC_ContinueFall
                jmp ExplodeEnemy2_8             ;Drop item & explode at any collision
MFC_CanAttack:  jmp AttackGeneric

        ; Walking robot update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveWalker:     jsr MoveGeneric
                jmp AttackGeneric

        ; Tank update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveTank:       jsr MoveGeneric                   ;Use human movement for physics
                ldy #tankTurretOfs-turretFrameTbl
                lda #1
                jsr AnimateTurret
                jsr AttackGeneric
                jsr GetAbsXSpeed
                clc
                adc actFd,x
                cmp #$30
                bcc MT_NoWrap
                sbc #$30
MT_NoWrap:      sta actFd,x
                lsr
                lsr
                lsr
                lsr
                sta actF1,x
                ldy #AL_SIZEUP                      ;Modify size up based on turret direction
                lda (actLo),y
                ldy actF2,x
                clc
                adc tankSizeAddTbl,y
                sta actSizeU,x
MFM_NoExplosion:rts

GetAbsXSpeed:   lda actSX,x                       ;Tracks animation from absolute speed
                bpl GAXS_Pos
                clc
                eor #$ff
                adc #$01
GAXS_Pos:       rts

        ; Floating mine update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveFloatingMine:
                lda #$03
                ldy #$03
                jsr LoopingAnimation
                jsr MoveAccelerateFlyer
                jmp MineCommon

        ; Ceiling turret update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveTurret:     lda actF2,x
                ldy actFd,x                         ;Start from middle frame
                bne MT_NoInit
                inc actFd,x
                lda #2
                sta actF2,x
MT_NoInit:      ldy #ceilingTurretOfs-turretFrameTbl
                jsr AnimateTurret
                lda actF2,x
                sta actF1,x                         ;Ceiling turret uses only 1-part animation, so copy to frame1
                jmp AttackGeneric

        ; Fire movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveFire:       lda actTime,x                   ;Restore oxygen level if not extinguished
                beq MF_FullOxygen               ;completely, destroy if depleted enough
                cmp #EXTINGUISH_THRESHOLD
                bcs MF_Destroy
                dec actTime,x
                bcc MF_Flash
MF_FullOxygen:  sta actFlash,x                  ;Stop flickering at full oxygen
MF_Flash:       lda #DMG_FIRE
                jsr CollideAndDamagePlayer
                lda #2
                ldy #3
                jsr LoopingAnimation
                lda actF1,x
                ora actFd,x
                bne MF_NoSpawn
                lda #ACTI_FIRSTEFFECT
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc MF_NoSpawn
                lda #ACT_SMOKECLOUD
                jsr SpawnActor
                tya
                tax
                jsr InitActor                   ;Set collision size
                lda #-15*8
                jsr MoveActorY
                lda #COLOR_FLICKER
                sta actFlash,x
                ldx actIndex
MSC_NoRemove:
MF_NoSpawn:     rts
MF_Destroy:     ldy #ACTI_FIRSTPLRBULLET        ;Make sure player receives score
                jmp DestroyActor

        ; Smokecloud movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveSmokeCloud: lda upgrade
                bmi MSC_NoSmokeDamage           ;If filter installed, no damage
                lda #DMG_SMOKE
                jsr CollideAndDamagePlayer
MSC_NoSmokeDamage:
                lda #-12
                jsr MoveActorY
                lda #4
                ldy #3
                jsr OneShotAnimation
                bcc MSC_NoRemove
                jmp RemoveActor

        ; Rat movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveRat:        lda #FR_DEADRATGROUND
                sta temp1
                lda actHp,x
                beq MR_Dead
                jsr MoveGeneric
                jmp AttackGeneric
MR_Dead:        jsr DeadAnimalMotion
                bcs MR_DeadGrounded
                rts
MR_DeadGrounded:lda #$00
                sta actSX,x                     ;Instant braking
                lda temp1
                sta actF1,x
                rts

        ; Spider movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars
        
MoveSpider:     lda #FR_DEADSPIDERGROUND
                sta temp1
                lda actHp,x
                beq MR_Dead
                jsr MoveGeneric
                lda #2
                ldy #2
                jsr LoopingAnimation
MS_Damage:      lda actFd,x
                lsr
                bcs MS_NoDamage                 ;Touch damage only each third frame
                lda #DMG_SPIDER
                jmp CollideAndDamagePlayer
MS_NoDamage:    rts

        ; Fly movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveFly:        lda actHp,x
                beq MF_Dead
                dec actTime,x
                bpl MF_NoNewControls
                jsr Random
                and #$03
                tay
                lda flyerDirTbl,y
                sta actMoveCtrl,x
                jsr Random
                and #$1f
                sta actTime,x
MF_NoNewControls:
                jsr MoveAccelerateFlyer
                inc actFd,x
                lda actFd,x
                and #$01
                sta actF1,x
                jmp MS_Damage                   ;Use same damage code as spider
MF_Dead:        lda #2
                ldy #FR_DEADFLY+1
                jmp OneShotAnimateAndRemove

        ; Bat movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MB_Dead:        lda #FR_DEADBATGROUND
                sta temp1
                jmp MR_Dead
MoveBat:        lda actHp,x
                beq MB_Dead
                lda #2                          ;Wings flapping acceleration up
                cmp actF1,x                     ;or gravity acceleration down,
                bcc MB_Gravity                  ;depending on frame
                lda actMoveCtrl,x
                and #JOY_UP
                bne MB_StrongFlap
                lda #2
                skip2
MB_StrongFlap:  lda #7
                bne MB_Accel
MB_Gravity:     lda #2
MB_Accel:       ldy #2*8
                jsr AccActorYNegOrPos
                lda #$00
                sta temp6
                jsr MFE_NoVertAccel             ;Left/right acceleration & move
                lda #2
                ldy #FR_DEADBATGROUND-1
MB_BatCommon:   jsr LoopingAnimation
                ldy #ACTI_PLAYER
                jsr GetActorDistance
                lda temp5                       ;No damage after has flown past player
                eor actD,x                      ;Otherwise use same damage code as spider
                bmi MB_NoDamage
                jmp MS_Damage
MB_NoDamage:    rts

        ; Fish movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveFish:       lda #CI_WATER
                jsr MFE_CustomCharInfo
                lda #2
                ldy #1
                bne MB_BatCommon

        ; Rock movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveRock:       lda actTime,x                   ;Randomize X-speed on first frame
                bne MR_HasRandomSpeed
                inc actTime,x
                jsr Random
                and #$0f
                sec
                sbc #$08
                sta actSX,x
MR_HasRandomSpeed:
                ldy actF1,x                     ;Set size according to frame
                lda rockSizeTbl,y
                sta actSizeH,x
                asl
                sta actSizeU,x
                lda rockDamageTbl,y
                beq MR_NoDamage
                jsr CollideAndDamagePlayer
MR_NoDamage:    jsr BounceMotion
                bcc MR_NoCollision
DestroyRock:    lda #SFX_DAMAGE
                jsr PlaySfx
                inc actF1,x
                lda actF1,x
                cmp #3
                bcs RemoveRock
                lda #-2*8
                jsr MR_RandomizeSmallerRock
                lda #ACTI_FIRSTNPC
                ldy #ACTI_LASTNPC
                jsr GetFreeActor
                bcc MR_NoSpawn
                lda #ACT_ROCK
                jsr SpawnActor
                lda actF1,x
                sta actF1,y
                stx temp6
                tya
                tax
                jsr InitActor
                jsr SetNotPersistent
                lda #$00
                jsr MR_RandomizeSmallerRock
                ldx temp6
MR_NoCollision:
MR_NoSpawn:     rts
RemoveRock:     lda #-4*8
                jsr MoveActorYNoInterpolation
                lda #COLOR_FLICKER
                sta actFlash,x
                lda #ACT_SMOKETRAIL
                jmp TransformBullet
MR_RandomizeSmallerRock:
                sta temp1
                jsr Random
                and #$0f
                clc
                adc temp1
                sta actSX,x
                lda #-4*8
                sta actSY,x
                lda #$00                        ;Reset ground flag
                sta actMB,x
                lda #HP_ROCK                    ;Reset hitpoints if was destroyed
                sta actHp,x
                rts

        ; Fireball movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveFireball:   lda actTime,x                   ;Randomize X-speed on first frame
                bne MFB_HasRandomSpeed          ;and set upward motion
                inc actTime,x
                jsr Random
                and #$0f
                sec
                sbc #$08
                sta actSX,x
                jsr Random
                and #$0f
                sec
                sbc #6*8
                sta actSY,x
                lda #SFX_GRENADELAUNCHER
                jsr PlaySfx
MFB_HasRandomSpeed:
                lda #DMG_FIREBALL
                jsr CollideAndDamagePlayer
                lda #1
                ldy #3
                jsr LoopingAnimation
                lda #GRENADE_ACCEL-2
                ldy #GRENADE_MAX_YSPEED
                jsr AccActorY
                lda actSX,x
                jsr MoveActorX
                lda actSY,x
                jmp MoveActorY
                rts

        ; Steam movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveSteam:      lda #COLOR_FLICKER
                sta actFlash,x
                inc actTime,x
                bmi MS_Invisible
                lda #1
                ldy #2
                jsr LoopingAnimation
                lda #DMG_STEAM
                jmp CollideAndDamagePlayer
MS_Invisible:   lda #3
                sta actF1,x
                rts

        ; Organic walker movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveOrganicWalker:
                lda actHp,x
                beq MOW_Dead
                jsr MoveGeneric
                jmp AttackGeneric
MOW_Dead:       lda #FR_DEADWALKERGROUND
                sta temp1
                jmp MR_Dead

        ; Fire destruction (transform into smoke)
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DestroyFire:    lda #ACT_SMOKECLOUD
                jmp TransformBullet

        ; Rat death
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A

RatDeath:       lda #FR_DEADRATAIR
RD_Common:      pha
                jsr HD_Common
                lda #SFX_ANIMALDEATH
                jsr PlaySfx
                pla
RD_SetFrameAndSpeed:
                sta actF1,x
                lda #-28
                sta actSY,x
                rts

        ; Spider death
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A

SpiderDeath:    lda #FR_DEADSPIDERAIR
                bne RD_Common

        ; Fly / bat death
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A

FlyDeath:       lda #FR_DEADFLY
                sta actF1,x
BatDeath:       lda #SFX_ANIMALDEATH
                jsr PlaySfx
                jmp HD_Common

        ; Organic walker death
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A

OrganicWalkerDeath:
                jsr HumanDeath
                lda #FR_DEADWALKERAIR
                bne RD_SetFrameAndSpeed

        ; Large walker movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveLargeWalker:jsr MoveGeneric
                jsr GetAbsXSpeed
                clc
                adc actFd,x
                sta actFd,x
                rol
                rol
                rol
                and #$03
                sta actF1,x
                and #$01
                bne MLW_NoShake                 ;Shake screen when transitioning to 0 or 2 frame
                ldy actFallL,x
                beq MLW_NoShake
                inc shakeScreen
MLW_NoShake:    sta actFallL,x
                jmp AttackGeneric

        ; Scrap metal movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveScrapMetal: jsr DeathFlickerAndRemove
                lda actSY,x                     ;Store original Y-speed for bounce
                sta temp1
                jsr BounceMotion
                bcc MSM_NoBounce
                lda actSX,x
                jsr Asr8
                sta actSX,x
                lda temp1
                jsr Negate8Asr8
                sta actSY,x
                lda #$00                        ;Clear grounded flag
                sta actMB,x
MRT_NoTrigger:
MSM_NoBounce:   rts
MSM_Remove:     jmp RemoveActor

        ; Rock trap movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveRockTrap:   lda actYH,x                     ;Trigger when player is below
                cmp actYH+ACTI_PLAYER
                bcs MRT_NoTrigger
                lda actXH+ACTI_PLAYER
                adc #$02                        ;C=0 (next sbc will subtract one too much)
                sbc actXH,x
                cmp #$03                        ;Trigger when X block distance is between -1 and +1
                bcs MRT_NoTrigger
                lda #ACT_ROCK
                sta actT,x
                jsr SetNotPersistent            ;Disappear after triggering once
                jmp InitActor

        ; Generate 2 explosions at 8 pixel radius
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy2_8_Ofs6:
                lda #6*8
                skip2
ExplodeEnemy2_8_Ofs10:
                lda #-10*8
                jsr MoveActorYNoInterpolation
                jmp ExplodeEnemy2_8

        ; Generate 3 explosions at 8 pixel radius horizontally and 32 pixel radius
        ; vertically
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy3_Ofs15:
                lda #-15*8
                jsr MoveActorYNoInterpolation
                lda #3
                sta actTime,x
                lda #$3f
                sta actSX,x
                lda #$ff
                sta actSY,x
                jmp ExplodeEnemyMultipleCommon

        ; Generate 4 explosions at 32 pixel radius and spawn pieces of scrap metal
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy4_Ofs15:
                lda #-15*8
                jsr MoveActorYNoInterpolation
                lda #4
                sta actTime,x
                lda #$ff
                sta actSX,x
                sta actSY,x
                jsr ExplodeEnemyMultipleCommon  ;Note: item is dropped first before
                lda #-2*8-8
                sta temp7                       ;Initial base X-speed
                jsr Random
                sta temp8                       ;Initial shape
EE_ScrapMetalLoop:
                lda #ACTI_FIRSTNPC              ;Use any free actors
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc EE_ScrapMetalDone
                lda #ACT_SCRAPMETAL
                jsr SpawnActor
                jsr Random
                and #$0f                        ;Randomize upward + sideways speed
                clc
                adc #-7*8
                sta actSY,y
                jsr Random
                and #$0f
                clc
                adc temp7
                sta actSX,y
                inc temp8
                lda temp8
                and #$03
                sta actF1,y
                lda #SCRAP_DURATION
                sta actTime,y
                lda temp7
                bpl EE_ScrapMetalDone
                clc
                adc #2*8
                sta temp7
                bne EE_ScrapMetalLoop
EE_ScrapMetalDone:
                rts

        ; Spiderwalker update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveSpiderWalker:
                jsr MoveGeneric                   ;Use human movement for physics
                lda actMoveCtrl,x
                and #JOY_LEFT|JOY_RIGHT
                beq MSW_AnimDone                  ;0 = walk frame
                lda actSX,x
                beq MSW_AnimDone
                asl
                bcc MSW_WalkAnimSpeedPos
                eor #$ff
                adc #$00
MSW_WalkAnimSpeedPos:
                adc #$40
                adc actFd,x
                sta actFd,x
                bcc MSW_AnimDone2
                lda actF1,x
                adc #$00
                and #$03
MSW_AnimDone:   sta actF1,x
MSW_AnimDone2:  ldy #tankTurretOfs-turretFrameTbl
                lda #1
                jsr AnimateTurret
                jmp AttackGeneric

        ; Generate 2 explosions at 8 pixel radius horizontally and 15 pixel radius
        ; vertically
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy2_Ofs15:
                lda #-15*8
                jsr MoveActorYNoInterpolation
                lda #2
                sta actTime,x
                lda #$3f
                sta actSX,x
                lda #$7f
                sta actSY,x
                jmp ExplodeEnemyMultipleCommon

        ; Large tank update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveLargeTank:  jsr MoveGeneric                   ;Use human movement for physics
                jsr AttackGeneric
                lda actSX,x                       ;Then overwrite animation
                beq MLT_NoCenterFrame
                eor actD,x                        ;If direction & speed don't agree, show the
                bmi MLT_CenterFrame               ;center frame (turning)
MLT_NoCenterFrame:
                jsr GetAbsXSpeed
                clc
                adc actFd,x
                cmp #$60
                bcc MLT_NoWrap
                sbc #$60
MLT_NoWrap:     sta actFd,x
                lsr
                lsr
                lsr
                lsr
                lsr
                skip2
MLT_CenterFrame:lda #3
                sta actF1,x
                rts

        ; High walker movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveHighWalker: jsr MoveGeneric
                lda actSX,x
                beq MHW_NoSpeed
                inc actFd,x
MHW_NoSpeed:    lda actFd,x
                lsr
                lsr
                and #$03
                sta actF1,x
                lda #$ff
                sta tgtActIndex
                jsr AttackGeneric
                ldy tgtActIndex                 ;Did attack?
                bmi MHW_NoAttack
                lda actT,y
                cmp #ACT_LASER
                bne MHW_NoLaser
                lda actSX,y                     ;Use a special 22.5 degree angle frame
                asl
                lda #10
                adc #$00
                sta actF1,y
MHW_NoLaser:    lda actSY,y                     ;Set 22.5 angle downward speed for bullet
                bne MHW_SpeedYOK
                lda actSX,y
                bpl MHW_SpeedXPos
                clc
                eor #$ff
                adc #$01
MHW_SpeedXPos:  lsr
                sta actSY,y
MHW_SpeedYOK:
MHW_NoAttack:   rts

        ; Generate 4 explosions at 15 pixel radius horizontally, rising
        ; vertically
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy4_Rising:
                lda #-12*8
                jsr MoveActorYNoInterpolation
                lda #4
                ldy #$7f
                jsr ExplodeEnemyMultiple
                lda #ACT_EXPLOSIONGENERATORRISING
                sta actT,x
                rts

        ; Rising explosion generator
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveExplosionGeneratorRising:
                jsr MoveExplosionGenerator
                lda #-4*8
                jmp MoveActorY

        ; Turret animation routine
        ;
        ; Parameters: X actor index, A default frame, Y turret frame table start index
        ; Returns: Frame in actF2
        ; Modifies: A,Y,temp1-temp8,loader temp vars

AnimateTurret:  sta AT_Default+1
AT_Loop:        lda turretFrameTbl,y
                beq AT_Default
                cmp actCtrl,x
                beq AT_Found
                iny
                iny
                bne AT_Loop
AT_Found:       lda turretFrameTbl+1,y
                skip2
AT_Default:     lda #$00
AT_FrameDone:   cmp actF2,x
                beq AT_NoAnim
                ldy actAttackD,x
                bne AT_NoAnim
                bcc AT_AnimDown
AT_AnimUp:      inc actF2,x
                bne AT_AnimCommon
AT_AnimDown:    dec actF2,x
AT_AnimCommon:  lda #TURRET_ANIMDELAY
                sta actAttackD,x
                lda actTime,x
                bpl AT_NoOngoingAttack
                sec
                sbc #TURRET_ANIMDELAY
                sta actTime,x                       ;Restore time to the AI attack counter,
AT_NoOngoingAttack:                                 ;since time was lost animating
AT_NoAnim:      rts

        ; Common dead animal falling motion
        ;
        ; Parameters: X actor index
        ; Returns: C Grounded status
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DeadAnimalMotion:
                jsr DeathFlickerAndRemove
                jsr FallingMotionCommon
                bpl DAM_NoWater
                pha
                lda #WATER_XBRAKING
                jsr BrakeActorX
                lda #WATER_YBRAKING*2
                jsr BrakeActorY
                pla
DAM_NoWater:    and #MB_HITWALL
                beq DAM_NoWallHit
                lda #$00
                sta actSX,x
DAM_NoWallHit:  lda actMB,x
                lsr
                rts

        ; Common bounce motion subroutine. Speed is halved on side wall collisions
        ;
        ; Parameters: X actor index
        ; Returns: C grounded status
        ; Modifies: A,Y,temp1-temp8,loader temp vars

BounceMotion:   jsr FallingMotionCommon
                lsr
                and #MB_HITWALL/2
                beq BM_NoHitWall
                php
                lda actSX,x
                jsr Negate8Asr8
                sta actSX,x
                plp
UHR_Full:
UBR_Full:
BM_NoHitWall:   rts

        ; Health recharger script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

UseHealthRecharger:
                lda actHp+ACTI_PLAYER
                cmp #HP_PLAYER
                bcs UHR_Full
                lda #HP_PLAYER
                sta actHp+ACTI_PLAYER
                lda #<txtHealthRecharger
                ldx #>txtHealthRecharger
Recharger_Common:
                ldy #REQUIREMENT_TEXT_DURATION
                jsr PrintPanelText
                lda #SFX_EMP
                jsr PlaySfx
                lda #$00
                sta rechargerColor
                lda #<EP_RECHARGEREFFECT
                ldx #>EP_RECHARGEREFFECT
                jmp SetScript

        ; Battery recharger script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

UseBatteryRecharger:
                lda battery+1
                cmp #MAX_BATTERY
                bcs UBR_Full
                lda #$00
                sta battery
                lda #MAX_BATTERY
                sta battery+1
                lda #<txtBatteryRecharger
                ldx #>txtBatteryRecharger
                bne Recharger_Common

        ; Recharger color effect script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RechargerEffect:
                lda rechargerColor
                inc rechargerColor
                cmp #$04
                bcs RE_End
                and #$01
                bne RE_Restore
                lda Irq1_Bg3+1
                sta Irq1_Bg1+1
                lda #$01
                sta Irq1_Bg3+1
                rts
RE_Restore:     jmp SetZoneColors
RE_End:         jmp StopScript

        ; Recycling station script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RecyclingStation:
                lda itemIndex
                sta RSL_RestoreItem+1
                ldy #ITEM_PARTS
                jsr FindItem
                bcc RS_NoParts
                sty itemIndex
                jsr SetPanelRedrawItemAmmo      ;Display parts left during interaction
                ldy #RECYCLER_ITEM_FIRST-1
                jsr RS_GotoNextItem
                sty recyclerItem
                jsr RS_Redraw
                lda #FR_ENTER                   ;Hack to get player into the standing frame
                sta actF1+ACTI_PLAYER
                sta actF2+ACTI_PLAYER
                ldx #ACTI_PLAYER
                jsr AttackHuman                 ;Set correct weapon frame
                lda #<EP_RECYCLINGSTATIONLOOP
                ldx #>EP_RECYCLINGSTATIONLOOP
                jsr SetScript
                ldx #MENU_INTERACTION
                jmp SetMenuMode
RS_NoParts:     lda #<txtNoParts
                ldx #>txtNoParts
                ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText

        ; Recycling station interaction loop
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RecyclingStationLoop:
                lda joystick
                and #JOY_DOWN
                bne RSL_Exit
                lda keyPress
                bpl RSL_Exit
                jsr MenuControl                 ;Check for selecting items
                ldy recyclerItem
                lsr
                bcs RSL_MoveLeft
                lsr
                bcs RSL_MoveRight
                jsr GetFireClick
                bcs RSL_Buy
RSL_MoveFail:   rts
RSL_MoveLeft:   jsr RS_GotoPrevItem
                bcc RSL_MoveFail
RSL_MoveCommon: sty recyclerItem
                lda #SFX_SELECT
                jsr PlaySfx
                jmp RS_Redraw
RSL_MoveRight:  jsr RS_GotoNextItem
                bcc RSL_MoveFail
                bcs RSL_MoveCommon
RSL_Buy:        rts
RSL_Exit:       jsr StopScript
RSL_RestoreItem:ldy #$00
                sty itemIndex
                ldx #MENU_NONE
                jsr SetMenuMode
                jsr SetPanelRedrawItemAmmo
                jmp SetPanelRedrawScore

        ; Redraw current item in recycler

RS_Redraw:      jsr ClearPanelText
                inc textLeftMargin
                lda recyclerItem
                jsr GetItemName
                jsr PrintPanelTextIndefinite
                dec textLeftMargin
                ldx #27
                lda #"+"
                jsr PrintPanelChar
                ldy recyclerItem
                lda recyclerCountTbl-RECYCLER_ITEM_FIRST,y
                jsr RS_ConvertAndPrint
                lda #$20
                ldy recyclerItem
                pha
                jsr RS_GotoPrevItem
                pla
                bcc RS_NoLeftArrow
                lda #60
RS_NoLeftArrow: ldx #9
                jsr PrintPanelChar
                lda #$20
                ldy recyclerItem
                pha
                jsr RS_GotoNextItem
                pla
                bcc RS_NoRightArrow
                lda #62
RS_NoRightArrow:ldx #30
                jsr PrintPanelChar
                ldx #1
                ldy #$00
RS_PrintCost:   lda txtCost,y
                beq RS_PrintCostDone
                jsr PrintPanelChar
                iny
                bne RS_PrintCost
RS_PrintCostDone:
                ldy recyclerItem
                lda recyclerCostTbl-RECYCLER_ITEM_FIRST,y
RS_ConvertAndPrint:
                jsr ConvertToBCD8
                jmp PrintBCDDigitsLSB

        ; Go to next item that can receive ammo from recycler
        ; Return C=1 if valid (index in Y)

RS_GotoNextItem:
                iny
                cpy #RECYCLER_ITEM_LAST+1
                bcs RS_GotoNextFail
                lda recyclerCountTbl-RECYCLER_ITEM_FIRST,y ;Check that can receive ammo
                beq RS_GotoNextItem
                lda invCount-1,y
                cmp #NO_ITEM_COUNT
                bcc RS_GotoNextFound
                cpy #ITEM_FIRST_CONSUMABLE      ;Consumables can always be selected
                bcs RS_GotoNextFound
                bcc RS_GotoNextItem
RS_GotoPrevFound:
RS_GotoNextFound:
                sec
                rts
RS_GotoPrevFail:
RS_GotoNextFail:clc
                rts

        ; Go to previous item that can receive ammo from recycler
        ; Return C=1 if valid (index in Y)

RS_GotoPrevItem:dey
                cpy #RECYCLER_ITEM_FIRST
                bcc RS_GotoPrevFail
                lda recyclerCountTbl-RECYCLER_ITEM_FIRST,y ;Check that can receive ammo
                beq RS_GotoPrevItem
                lda invCount-1,y
                cmp #NO_ITEM_COUNT
                bcc RS_GotoPrevFound
                cpy #ITEM_FIRST_CONSUMABLE
                bcs RS_GotoPrevFound
                bcc RS_GotoPrevItem

        ; Tank Y-size addition table (based on turret direction)

tankSizeAddTbl: dc.b 2,0,6,8

        ; Rock size table

rockSizeTbl:    dc.b 9,7,5

        ; Rock damage table

rockDamageTbl:  dc.b DMG_ROCK,DMG_ROCK-1,0

        ; Turret firing ctrl + frame table

turretFrameTbl:
tankTurretOfs:  dc.b JOY_LEFT|JOY_DOWN|JOY_FIRE,0
                dc.b JOY_RIGHT|JOY_DOWN|JOY_FIRE,0
                dc.b JOY_LEFT|JOY_FIRE,1
                dc.b JOY_RIGHT|JOY_FIRE,1
                dc.b JOY_LEFT|JOY_UP|JOY_FIRE,2
                dc.b JOY_RIGHT|JOY_UP|JOY_FIRE,2
                dc.b JOY_UP|JOY_FIRE,3
                dc.b 0
ceilingTurretOfs:
                dc.b JOY_RIGHT|JOY_FIRE,0
                dc.b JOY_RIGHT|JOY_DOWN|JOY_FIRE,1
                dc.b JOY_DOWN|JOY_FIRE,2
                dc.b JOY_LEFT|JOY_DOWN|JOY_FIRE,3
                dc.b JOY_LEFT|JOY_FIRE,4
                dc.b 0

        ; Recycler tables

recyclerCountTbl:
                dc.b 10                         ;Pistol
                dc.b 8                          ;Shotgun
                dc.b 30                         ;Auto rifle
                dc.b 5                          ;Sniper rifle
                dc.b 50                         ;Minigun
                dc.b 30                         ;Flamethrower
                dc.b 15                         ;Laser rifle
                dc.b 10                         ;Plasma gun
                dc.b 2                          ;EMP generator
                dc.b 1                          ;Grenade launcher
                dc.b 1                          ;Bazooka
                dc.b 0                          ;Extinguisher
                dc.b 1                          ;Grenade
                dc.b 1                          ;Mine
                dc.b 1                          ;Medikit
                dc.b 1                          ;Battery

recyclerCostTbl:
                dc.b 15                         ;Pistol
                dc.b 25                         ;Shotgun
                dc.b 40                         ;Auto rifle
                dc.b 25                         ;Sniper rifle
                dc.b 75                         ;Minigun
                dc.b 35                         ;Flamethrower
                dc.b 45                         ;Laser rifle
                dc.b 40                         ;Plasma gun
                dc.b 50                         ;EMP generator
                dc.b 40                         ;Grenade launcher
                dc.b 60                         ;Bazooka
                dc.b 0                          ;Extinguisher
                dc.b 40                         ;Grenade
                dc.b 50                         ;Mine
                dc.b 75                         ;Medikit
                dc.b 75                         ;Battery

        ; Variables

rechargerColor: dc.b 0
recyclerItem:   dc.b 0

        ; Messages

txtHealthRecharger:
                dc.b "HEALTH RESTORED",0
txtBatteryRecharger:
                dc.b "BATTERY RECHARGED",0
txtNoParts:     dc.b "NO PARTS TO RECYCLE",0
txtCost:        dc.b "COST ",0

                checkscriptend