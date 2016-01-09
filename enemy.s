HUMAN_ITEM_SPAWN_OFFSET = -15*8
ITEM_SPAWN_YSPEED     = -3*8
MULTIEXPLOSION_DELAY = 2
SCRAP_DURATION = 40

FR_DEADRATAIR = 12
FR_DEADRATGROUND = 13
FR_DEADSPIDERAIR = 3
FR_DEADSPIDERGROUND = 4
FR_DEADFLY = 2
FR_DEADBATGROUND = 6
FR_DEADWALKERAIR = 12
FR_DEADWALKERGROUND = 13

TURRET_ANIMDELAY = 2

        ; Common flying enemy movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveAccelerateFlyer:
                lda #$00
MFE_CustomCharInfo:
                sta temp6
                ldy #AL_YMOVESPEED
                lda (actLo),y
                sta temp4                       ;Vertical max. speed
                lda actMoveCtrl,x
                and #JOY_UP|JOY_DOWN
                beq MFE_NoVertAccel
                cmp #JOY_UP
                beq MFE_AccelUp                 ;C=1 accelerate up (negative)
                clc
MFE_AccelUp:    iny
                lda (actLo),y                   ;Vertical acceleration
                ldy temp4
                jsr AccActorYNegOrPos
MFE_NoVertAccel:ldy #AL_XMOVESPEED
                lda (actLo),y
                sta temp4                       ;Horizontal max. speed
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
                ldy #AL_XCHECKOFFSET            ;Horizontal obstacle check offset
                lda (actLo),y
                sta temp4
                iny
                lda (actLo),y                   ;Vertical obstacle check offset
                ldy actSY,x                     ;Reverse if going up
                bpl MFE_NoNegate
                clc
                eor #$ff
                adc #$01
MFE_NoNegate:   jsr MF_HasCharInfo
                ldy actAIHelp,x                 ;Zero speed and reverse dir if requested
                lda actMB,x
                and #MB_HITWALL
                beq MFE_NoHorizWall
                lda #$00
                sta actSX,x
                tya
                beq MFE_NoHorizTurn
                lda #JOY_LEFT|JOY_RIGHT
                jsr MFE_Reverse
MFE_NoHorizTurn:
MFE_NoHorizWall:lda actMB,x
                and #MB_HITWALLVERTICAL
                beq MFE_NoVertWall
                lda #$00
                sta actSY,x
                tya
                beq MFE_NoVertTurn
                lda #JOY_UP|JOY_DOWN
MFE_Reverse:    eor actMoveCtrl,x
                sta actMoveCtrl,x
MFE_NoVertTurn:
MC_NoCollision:
MFE_NoVertWall: rts

        ; Floating droid update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveDroid:      lda #$02
                tay
                jsr LoopingAnimation
                jsr MoveAccelerateFlyer
                jmp AttackGeneric

        ; Floating mine update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveFloatingMine:
                lda #3
                ldy #3
                jsr LoopingAnimation
                jsr MoveAccelerateFlyer
                jmp MineCommon

        ; Rolling mine update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveRollingMine:jsr MoveGeneric
                lda actMB,x                         ;If not grounded and hitting wall,
                cmp #MB_HITWALL                     ;climb up the wall
                bne MRM_NoClimb
                lda #10
                ldy #4*8
                jsr AccActorYNeg
MRM_NoClimb:    inc actFd,x
                lda actFd,x
                and #$01
                sta actF1,x
MineCommon:     ldy #ACTI_PLAYER                    ;To avoid bugs, only ever collide with player
                bmi MC_NoCollision
                lda #DMG_ENEMYMINE
                jsr CollideAndDamageTarget
                bcc MC_NoCollision
                jmp DestroyActorNoSource

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

        ; Flying craft destroy routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DestroyFlyingCraft:
                stx DFC_RestX+1                 ;Spawn one explosion when starts to fall
                lda #ACTI_FIRSTNPC              ;Use any free actors
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc DFC_NoRoom
                jsr SpawnActor                  ;Actor type undefined at this point, will be initialized below
                tya
                tax
                jsr ExplodeActor                ;Play explosion sound & init animation
DFC_RestX:      ldx #$00
DFC_NoRoom:     rts

        ; Walking robot update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveWalker:     jsr MoveGeneric
MFC_CanAttack:  jmp AttackGeneric

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
                lda actMB,x
                and #MB_HITWALL|MB_HITWALLVERTICAL
                bne MF_SetNewControls
                dec actTime,x
                bpl MF_NoNewControls
MF_SetNewControls:
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
                jsr GetCharInfo
                and #CI_OBSTACLE
                bne MR_InitRemove               ;Remove on init if inside wall (used to cache the first rock in caves)
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
DestroyRock:    lda #SFX_SHOTGUN
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
                lda #$00
                jsr MR_RandomizeSmallerRock
                ldx temp6
MR_NoCollision:
MR_NoSpawn:     rts
RemoveRock:     lda #-4*8
                jsr MoveActorYNoInterpolation
                lda #COLOR_FLICKER
                sta actFlash,x
MR_InitRemove:  lda #ACT_SMOKETRAIL
                jmp TransformActor
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
                sbc #5*8+8
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
                jmp TransformActor

        ; Rat death
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A

RatDeath:       lda #FR_DEADRATAIR
RD_Common:      pha
                jsr AnimalDeathCommon
                pla
RD_SetFrameAndSpeed:
                sta actF1,x
                lda #-28
                sta actSY,x
                jmp MH_ResetGrounded

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
BatDeath:
AnimalDeathCommon:
                jsr HD_Common
                lda actSX,x                     ;Reduce the impulse from weapon
                jsr Asr8
                sta actSX,x
                lda #SFX_ANIMALDEATH
                jmp PlaySfx

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
MRT_NoTrigger:  rts

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

        ; CPU destroy (activate object at explosion)
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DestroyCPU:     jsr ExplodeActor
                ldy #MAX_LVLOBJ-1
DCPU_Search:    lda lvlObjX,y
                cmp actXH,x
                bne DCPU_SearchNext
                lda lvlObjY,y
                and #$7f
                cmp actYH,x
                beq DCPU_Found
DCPU_SearchNext:dey
                bpl DCPU_Search
                rts
DCPU_Found:     jmp ActivateObject

        ; Turn enemy into an explosion & drop item
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy_Ofs8:
                lda #-8*8
                jsr MoveActorYNoInterpolation
ExplodeEnemy:   jsr DropItem
                jmp ExplodeActor

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
ExplodeEnemy2_8:lda #2
                ldy #$3f

        ; Turn enemy into a multiple explosion generator & drop item
        ;
        ; Parameters: X actor index, A number of explosions, Y radius
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemyMultiple:
                sta actTime,x
                tya
ExplodeEnemyMultiple_CustomRadius:
                sta actSX,x
                tya
                sta actSY,x
                jsr DropItem
                lda #ACT_EXPLOSIONGENERATOR
                jmp TransformBullet

        ; Generate 3 explosions at 8 pixel radius horizontally and 32 pixel radius
        ; vertically
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy3_Ofs24:
                lda #-15*8
                jsr MoveActorYNoInterpolation
                lda #3
                sta actTime,x
                lda #$3f
                ldy #$ff
                jsr ExplodeEnemyMultiple_CustomRadius
                lda #-8*8
                jmp MoveActorYNoInterpolation

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
                ldy #$7f
                jmp ExplodeEnemyMultiple_CustomRadius

        ; Generate 4 explosions at 32 pixel radius and spawn 3 pieces of scrap metal
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy4_Ofs15:
                lda #-15*8
                jsr MoveActorYNoInterpolation
                lda #4
                ldy #$ff
                jsr ExplodeEnemyMultiple
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

        ; Generate 4 explosions at 15 pixel radius horizontally, rising
        ; vertically
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy4_Rising:
                lda #-8*8
                jsr MoveActorYNoInterpolation
                lda #4
                ldy #$7f
                jsr ExplodeEnemyMultiple
                lda #ACT_EXPLOSIONGENERATORRISING
                jmp TransformActor

        ; Rising explosion generator
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveExplosionGeneratorRising:
                lda #-4*8
                jsr MoveActorY

        ; Explosion generator update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveExplosionGenerator:
                dec actFd,x
                bpl MEG_NoNewExplosion
                lda #MULTIEXPLOSION_DELAY
                sta actFd,x
                lda #ACTI_FIRSTNPC              ;Use any free actors
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc MEG_NoRoom                  ;If no room, simply explode self
                jsr SpawnActor                  ;Actor type undefined at this point, will be initialized below
                lda actSX,x
                sta temp1
                lda actSY,x
                sta temp2
                tya
                tax
                jsr ExplodeActor                ;Play explosion sound & init animation
                lda temp1
                jsr MEG_GetOffset
                jsr MoveActorX
                lda temp2
                jsr MEG_GetOffset
                jsr MoveActorY
                ldx actIndex
                dec actTime,x
                bne MEG_NotLastExplosion
                jmp RemoveActor
MEG_NoRoom:     jmp ExplodeActor
MEG_GetOffset:  sta temp3
                lsr
                sta temp4
                jsr Random
                and temp3
                sec
                sbc temp4
MEG_NotLastExplosion:
MEG_NoNewExplosion:
                rts

        ; Scrap metal movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveScrapMetal: jsr BounceMotion

        ; Flicker corpse, then remove.
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp regs

DeathFlickerAndRemove:
                dec actTime,x
                bmi DFAR_Remove
                lda actTime,x                   ;Flicker and eventually remove the corpse
                cmp #DEATH_FLICKER_DELAY
                bcs DFAR_Done
                lda #COLOR_FLICKER
                sta actFlash,x
DFAR_Done:      rts
DFAR_Remove:    jmp RemoveActor

        ; Initiate humanoid enemy or player death
        ;
        ; Parameters: X actor index,temp8 damage source actor or $ff if none
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8

HumanDeath:     txa
                bne HD_NotPlayer                ;Reset dialogue / interaction menu modes
                jsr StopScript                  ;if died during them
                lda menuMode
                cmp #MENU_DIALOGUE
                bcc HD_NotInMenu
                ldx #MENU_NONE
                jsr SetMenuMode
HD_NotInMenu:   ldx #ACTI_PLAYER
HD_NotPlayer:   lda #SFX_HUMANDEATH
                jsr PlaySfx
                lda actF1,x
                cmp #FR_SWIM
                bcc HD_NotSwimming
                jsr GetCharInfo1Below           ;If space below, prefer to move
                and #CI_OBSTACLE|CI_GROUND      ;as the dying frames have hotspot at bottom
                bne HD_SetFrame
                lda #8*8
                jsr MoveActorYNoInterpolation
                jmp HD_SetFrame
HD_NotSwimming: lda #DEATH_YSPEED
                sta actSY,x
                jsr MH_ResetGrounded
HD_SetFrame:    ldy temp8
                lda #FR_DIE
                sta actF1,x
                sta actF2,x
HD_Common:      tya                             ;Check if has a damage source
                bmi HD_NoDamageSource
                lda actHp,y
                sta temp8
                lda actSX,y                     ;Check if final attack came from right or left
                bne HD_GotDir
                lda actXL,x
                sec
                sbc actXL,y
                lda actXH,x
                sbc actXH,y
HD_GotDir:      asl                             ;Direction to carry
                lda temp8
                ldy #DEATH_MAX_XSPEED
                jsr AccActorXNegOrPos
HD_NoDamageSource:
                lda #DEATH_DISAPPEAR_DELAY
                sta actTime,x
                lda #$00
                sta actFd,x
                lda #HUMAN_ITEM_SPAWN_OFFSET
                skip2

        ; Drop item from dead enemy
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8

DropItem:       lda #$00
                sta temp4
                lda actT,x                      ;Exception: final room large droids drop nothing
                cmp #ACT_LARGEDROIDFINAL        ;(avoid duplicating actor logic structure)
                beq DI_NoItem
                jsr Random                      ;Common random number
                sta temp6
                ldy #AL_DROPITEMTYPE
                lda (actLo),y
                beq DI_NoItem
                bpl DI_ItemNumber               ;Direct item number?
                sta temp5
                lsr temp5                       ;Medkit?
                bcc DI_NoMedkit
                lda #ITEM_MEDKIT
                ldy #1
                jsr DropLowProbability
DI_NoMedkit:    lsr temp5                       ;Battery?
                bcc DI_NoBattery
                lda #ITEM_BATTERY
                ldy #1
                jsr DropLowProbability
DI_NoBattery:   lsr temp5                       ;Armor?
                bcc DI_NoArmor
                lda #ITEM_ARMOR
                ldy #50
                jsr DropLowProbability
DI_NoArmor:     lsr temp5                       ;Weapon?
                bcc DI_NoWeapon
                lda actWpn,x
                jsr CountItem
                bcc DI_DropCountedItem          ;OK if can pick up
DI_NoWeapon:    lsr temp5                       ;Parts?
                bcc DI_NoItem
                lda #ITEM_PARTS
                jsr CountItem
                lda temp3                       ;If already 2 or more parts onscreen,
                cmp #2                          ;do not drop more
                bcs DI_NoItem
                lda temp6
                cmp #PARTS_DROP_PROBABILITY
                bcs DI_NoItem
                and #$0c
                ldy #AL_SIZEHORIZ               ;If enemy is going to drop parts, make their
                clc                             ;count proportional to the enemy size + random add
                adc (actLo),y
                lsr
                lsr
                sta itemDefaultPickup+ITEM_PARTS-1
                bpl DI_DropCountedItem
DI_NoItem:      rts

        ; Common code for dropping item that has a low probability (medkit, battery, armor)
        ; Does not return if drop OK

DropLowProbability:
                sty DLP_Cmp+1
                jsr CountItem
DLP_Cmp:        cmp #$00
                bcs DI_NoItem
                lda temp6
                cmp #MEDKIT_DROP_PROBABILITY
                bcs DI_NoItem
                pla
                pla
DI_DropCountedItem:
                lda temp7

        ; Drop explicit item

DI_ItemNumber:  tay
                sta temp5                       ;Item type to drop
                lda #$00                        ;X-speed
DI_SpawnItemWithSpeed:
                sta temp8
                lda #ACTI_FIRSTITEM
                ldy #ACTI_LASTITEM
                jsr GetFreeActor
                bcc DI_NoItem
                stx temp6
                lda #ACT_ITEM
                jsr SpawnActor
                lda temp5
                tax
                sta actF1,y
                lda #1
                cpx #ITEM_FIRST_IMPORTANT       ;Quest items always x1
                bcs DI_CountOK
                lda itemDefaultPickup-1,x
DI_CountOK:     sta actHp,y
                lda #ITEM_SPAWN_YSPEED
                sta actSY,y
                tya
                tax
                jsr InitActor
                lda temp8
                sta actSX,x
                stx temp8
                lda temp4
                jsr MoveActorY
                lda temp5
                cmp #ITEM_FIRST_IMPORTANT
                lda levelNum
                bcc DI_NotImportant
                ora #ORG_GLOBAL
DI_NotImportant:sta actLvlDataOrg,x             ;Make item either persistent or temp persistent
                ldx temp6                       ;depending on importance
                rts

        ; Subroutine to count item (type in A) on ground + inventory. Return total in A,
        ; count of ground items of matching type in temp3 and C=1 if cannot pick up more

CountItem:      sta temp7
                lda #$00
                sta temp3
                sta temp8                       ;Total counter
                ldy #ACTI_FIRSTITEM
DI_CountGroundItems:
                lda actT,y                      ;Occasionally (explosions etc.) item actors
                cmp #ACT_ITEM                   ;may be reused for other purposes
                bne DI_CGINext
                lda actF1,y
                cmp temp7
                bne DI_CGINext
                inc temp3
                lda actHp,y
                clc
                adc temp8
                bcs DI_Exceeded
                sta temp8
DI_CGINext:     iny
                cpy #ACTI_LASTITEM+1
                bcc DI_CountGroundItems
                ldy temp7
                jsr FindItem
                bcc DI_NotInInventory
                lda invCount-1,y
                clc
                adc temp8
                bcs DI_Exceeded
                sta temp8
DI_NotInInventory:
                lda temp8
                cmp itemMaxCount-1,y
                rts
DI_Exceeded:    lda #$ff
DLP_NoItem:     rts

        ; Persistent NPC move logic. Branch off to script code according to game state
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8

MovePersistentNPC:
                jsr MoveAndAttackHuman
                lda menuMode
                bne MPNPC_InDialogue
                ldy actT,x
                ldx actScript-ACT_SCIENTIST2,y
                beq MPNPC_NoScript
                lda actEP-ACT_SCIENTIST2,y
                jsr ExecScript
MPNPC_NoScript: ldx actIndex
MPNPC_InDialogue:
                rts
