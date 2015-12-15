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

TURRET_ANIMDELAY = 2

RECYCLER_ITEM_FIRST = ITEM_PISTOL
RECYCLER_ITEM_LAST = ITEM_ARMOR

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
                dc.w MoveRockTrap
                dc.w MoveSpiderWalker
                dc.w MoveLargeTank
                dc.w MoveHighWalker
                dc.w UseHealthRecharger
                dc.w UseBatteryRecharger
                dc.w RechargerEffect
                dc.w RecyclingStation
                dc.w RecyclingStationLoop
                dc.w Elevator
                dc.w ElevatorLoop
                dc.w EnterCode
                dc.w EnterCodeLoop

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
                jmp TransformActor

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
UHR_Full:
UBR_Full:
                rts

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
                lsr
                bcs RE_Restore
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

recyclerItem    = menuCounter

RecyclingStation:
                ldy #ITEM_PARTS
                jsr FindItem
                bcc RS_NoParts
                lda #$00                        ;Init alternating parts/item display
                sta recyclerDisplay
                lda #<EP_RECYCLINGSTATIONLOOP
                ldx #>EP_RECYCLINGSTATIONLOOP
                jsr SetScriptAndInteraction
                ldy #RECYCLER_ITEM_FIRST-1
                jsr RS_GotoNextItem
                sty recyclerItem
                jmp RS_Redraw
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
                inc recyclerDisplay
                ldy itemIndex
                sty RSL_RestoreItem+1
                ldy #ITEM_PARTS
                lda recyclerDisplay
                asl
                asl
                bpl RSL_ShowParts
                ldy recyclerItem
RSL_ShowParts:  sty itemIndex
                jsr SetPanelRedrawItemAmmo
                jsr UP_RedrawItemAmmoScore      ;Forcibly redraw item/ammo
RSL_RestoreItem:ldy #$00
                sty itemIndex
                jsr CheckForExit
                bne RSL_Exit
                jsr MenuControl                 ;Check for selecting items
                ldy recyclerItem
                lsr
                bcs RSL_MoveLeft
                lsr
                bcs RSL_MoveRight
                jsr GetFireClick
                bcs RSL_Buy
RSL_NoObject:
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
RSL_Buy:        lda recyclerCostTbl-RECYCLER_ITEM_FIRST,y
                sta temp1
                lda invCount+ITEM_PARTS-1
                cmp #NO_ITEM_COUNT
                beq RSL_BuyFail
                cmp temp1
                bcc RSL_BuyFail
                tya
                ldx recyclerCountTbl-RECYCLER_ITEM_FIRST,y
                jsr AddItem
                bcc RSL_BuyFail
                ldy #ITEM_PARTS
                lda temp1
                jsr DecreaseAmmo
                lda #$00                        ;Do not redraw parts count now,
                sta panelUpdateFlags            ;rather redraw manually
                lda #$20                        ;Show the bought item
                sta recyclerDisplay
                lda #SFX_EMP
                skip2
RSL_BuyFail:    lda #SFX_DAMAGE
                jmp PlaySfx
RSL_Exit:       jsr SetPanelRedrawItemAmmo
RSL_ExitCommon: jsr StopScript
                ldx #MENU_NONE
                jmp SetMenuMode

CheckForExit:   lda joystick
                and #JOY_DOWN
                bne CFE_Exit
                lda keyPress
                eor #$ff
CFE_Exit:       rts

        ; Redraw current item in recycler

RS_Redraw:      inc textLeftMargin
                lda recyclerItem
                jsr GetItemName
                jsr PrintPanelTextIndefinite
                dec textLeftMargin
                ldy recyclerItem
                lda recyclerCountTbl-RECYCLER_ITEM_FIRST,y
                jsr ConvertToBCD8
                ldx #27
                jsr Print3BCDDigits
                ldx #27
RS_ZeroLoop:    lda panelScreen+PANELROW*40,x
                cmp #$30
                bne RS_NonZeroFound
                lda #" "
                jsr PrintPanelChar
                bne RS_ZeroLoop
RS_NonZeroFound:dex
                lda #"+"
                jsr RS_RedrawSub
                pha
                jsr RS_GotoPrevItem
                pla
                bcc RS_NoLeftArrow
                lda #60
RS_NoLeftArrow: ldx #9
                jsr RS_RedrawSub
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
                jsr ConvertToBCD8
                jmp PrintBCDDigitsLSB

RS_RedrawSub:   jsr PrintPanelChar
                lda #$20
                ldy recyclerItem
                rts

        ; Go to next/prev item that can receive ammo from recycler
        ; Return C=1 if valid (index in Y)

RS_GotoNextItem:
                iny
                cpy #RECYCLER_ITEM_LAST+1
                bcs RS_GotoNextFail
                jsr RS_GotoCommon
                beq RS_GotoNextItem
RS_GotoPrevFound:
RS_GotoNextFound:
                sec
                rts
RS_GotoPrevFail:
RS_GotoNextFail:clc
                rts

RS_GotoPrevItem:dey
                cpy #RECYCLER_ITEM_FIRST
                bcc RS_GotoPrevFail
                jsr RS_GotoCommon
                beq RS_GotoPrevItem
                bne RS_GotoPrevFound

RS_GotoCommon:  lda recyclerCountTbl-RECYCLER_ITEM_FIRST,y ;Check that can receive ammo
                beq RS_GotoCommonDone
                lda #NO_ITEM_COUNT-1            ;Is it a weapon that exists in inventory?
                cmp invCount-1,y
                bcs RS_GotoCommonDone
                cpy #ITEM_FIRST_CONSUMABLE      ;Consumables can always be selected
                bcs RS_GotoCommonDone
                lda #$00                        ;Need to check next
RS_GotoCommonDone:
                rts

        ; Enter elevator script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Elevator:       ldx #3
                lda levelNum
E_FindLoop:     cmp elevatorSrcLevel,x
                beq E_Found
                dex
                bpl E_FindLoop
E_Found:        lda elevatorPlotBit,x
                jsr GetPlotBit
                bne E_HasAccess
E_NoAccess:     lda #<txtElevatorLocked
                ldx #>txtElevatorLocked
                ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText
E_HasAccess:    stx elevatorIndex
                lda #$00
                sta elevatorTime
                lda #<EP_ELEVATORLOOP
                ldx #>EP_ELEVATORLOOP
                jsr SetScript
                ldy lvlObjNum
                iny
                tya
E_EnterDoor:    jmp ULO_EnterDoorDest

        ; Enter elevator loop
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ElevatorLoop:   ldx elevatorIndex
                lda elevatorTime
                bne EL_NotFirstFrame
                sta charInfo-1                  ;Reset elevator speed
EL_NotFirstFrame:
                lda charInfo-1                  ;Accelerate until full speed
                cmp elevatorSpeed,x
                beq EL_HasFullSpeed
                clc
                adc elevatorAcc,x
                sta charInfo-1
EL_HasFullSpeed:inc elevatorTime
                bmi EL_Exit
                rts
EL_Exit:        jsr StopScript
                ldx elevatorIndex
                lda elevatorDestLevel,x
                jsr ChangeLevel
                ldx elevatorIndex
                lda elevatorDestObject,x
                bpl E_EnterDoor

        ; Enter keypad code script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

numberIndex     = menuCounter

EnterCode:      lda #0
                ldx #2
EC_Reset:       sta codeEntry,x
                dex
                bpl EC_Reset
                lda #<EP_ENTERCODELOOP
                ldx #>EP_ENTERCODELOOP
SetScriptAndInteraction:
                jsr SetScript
                ldx #MENU_INTERACTION
                jmp SetMenuMode

        ; Enter keypad code interaction loop
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EnterCodeLoop:  lda lvlObjNum                   ;Abort if slid off the object
                bmi ECL_Finish
                lda #<txtEnterCode
                ldx #>txtEnterCode
                jsr PrintPanelTextIndefinite
                ldy #$00
                ldx #20
ECL_Redraw:     cpy numberIndex
                beq ECL_HasDigit
                bcs ECL_EmptyDigit
ECL_HasDigit:   lda codeEntry,y
                ora #$30
                skip2
ECL_EmptyDigit: lda #"-"
                jsr PrintPanelChar
                inx
                iny
                cpy #3
                bcc ECL_Redraw
                jsr CheckForExit
                bne ECL_Finish
                jsr MenuControl
                ldx numberIndex
                lsr
                bcs ECL_MoveLeft
                lsr
                bcs ECL_MoveRight
                jsr GetFireClick
                bcs ECL_Next
ECL_Done:       rts
ECL_MoveLeft:   lda #$fe                        ;C=1
                skip2
ECL_MoveRight:  lda #$00                        ;C=1
                adc codeEntry,x
                bmi ECL_OverNeg
                cmp #10
                bcc ECL_NotOver
                lda #0
                skip2
ECL_OverNeg:    lda #9
ECL_NotOver:    sta codeEntry,x
ECL_Sound:      lda #SFX_SELECT
                jmp PlaySfx
ECL_Next:       jsr ECL_Sound
                inx
                stx numberIndex
                cpx #3
                bcc ECL_Done
                jsr VerifyCodeEntry             ;Opens the door if right code
ECL_Finish:     jmp RSL_ExitCommon

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
                dc.b 15                         ;Auto rifle
                dc.b 5                          ;Sniper rifle
                dc.b 25                         ;Minigun
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
                dc.b 100                        ;Armor

recyclerCostTbl:
                dc.b 10                         ;Pistol
                dc.b 15                         ;Shotgun
                dc.b 20                         ;Auto rifle
                dc.b 25                         ;Sniper rifle
                dc.b 30                         ;Minigun
                dc.b 30                         ;Flamethrower
                dc.b 35                         ;Laser rifle
                dc.b 40                         ;Plasma gun
                dc.b 35                         ;EMP generator
                dc.b 40                         ;Grenade launcher
                dc.b 50                         ;Bazooka
                dc.b 0                          ;Extinguisher
                dc.b 35                         ;Grenade
                dc.b 45                         ;Mine
                dc.b 50                         ;Medikit
                dc.b 50                         ;Battery
                dc.b 75                         ;Armor

        ; Elevator tables
        
elevatorSrcLevel:
                dc.b $06,$08,$0a,$0b
elevatorDestLevel:
                dc.b $08,$06,$0b,$0a
elevatorDestObject:
                dc.b $43,$3f,$0f,$39
elevatorPlotBit:
                dc.b PLOT_ELEVATOR1,PLOT_ELEVATOR1,PLOT_ELEVATOR2,PLOT_ELEVATOR2
elevatorSpeed:  dc.b 32,-32,-64,64
elevatorAcc:    dc.b 2,-2,-4,4

        ; Variables

rechargerColor:
elevatorIndex:  dc.b 0
recyclerDisplay:
elevatorTime:   dc.b 0

        ; Messages

txtHealthRecharger:
                dc.b "HEALTH RESTORED",0
txtBatteryRecharger:
                dc.b "BATTERY RECHARGED",0
txtNoParts:     dc.b "NO PARTS TO RECYCLE",0
txtCost:        dc.b "COST ",0
txtElevatorLocked:
                dc.b "ELEVATOR OFFLINE",0
txtEnterCode:   dc.b "ENTER CODE",0

                checkscriptend