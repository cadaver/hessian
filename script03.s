                include macros.s
                include mainsym.s

        ; Script 3, Construct + other boss fights, recycling station

EYE_MOVE_TIME = 10
EYE_FIRE_TIME = 8
DROID_SPAWN_DELAY = 4*25

CHUNK_DURATION = 40

RECYCLER_ITEM_FIRST = ITEM_PISTOL
RECYCLER_ITEM_LAST = ITEM_ARMOR
MAX_RECYCLER_ITEMS = 10
RECYCLER_MOVEDELAY = 8

                org scriptCodeStart

                dc.w MoveEyePhase1
                dc.w MoveEyePhase2
                dc.w DestroyEye
                dc.w MoveSecurityChief
                dc.w DestroySecurityChief
                dc.w MoveRotorDrone
                dc.w DestroyRotorDrone
                dc.w MoveLargeSpider
                dc.w OpenWall
                dc.w MoveAcid
                dc.w RecyclingStation
                dc.w HideoutDoor

        ; Eye (Construct) boss phase 1
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveEyePhase1:  lda lvlObjB+$1e                 ;Close door immediately once player moves or fires
                bpl MEye_DoorDone
                lda actXL+ACTI_PLAYER
                bpl MEye_CloseDoor
                cmp #$88
                bcs MEye_CloseDoor
                lda actF2+ACTI_PLAYER
                cmp #FR_PREPARE
                bcc MEye_DoorDone
MEye_CloseDoor: ldy #$1e
                jsr InactivateObject
                ldx actIndex
MEye_DoorDone:  lda #DROID_SPAWN_DELAY
                sta MEye_SpawnDelay+1
                lda #ACT_SUPERCPU               ;Wait until all CPUs destroyed
                jsr FindActor
                ldx actIndex
                bcs MEye_HasCPUs
MEye_GotoPhase2:lda numSpawned                  ;Wait until all droids from phase1 destroyed
                cmp #2
                bcs MEye_WaitDroids
                inc actT,x                      ;Move to visible eye stage
                jsr InitActor
                lda #5                          ;Descend animation
                sta actF1,x
                jmp InitActor

MEye_HasCPUs:   lda #1
MEye_SpawnDroid:cmp numSpawned
                bcc MEye_Done
                lda #ACTI_FIRSTNPC              ;Use any free slots for droids,
                ldy #ACTI_LASTNPC               ;meaning the battle becomes more insane
                jsr GetFreeActor                ;as more CPUs are destroyed
                bcc MEye_Done                   ;(up to 2)
                lda actTime,x
                bne MEye_DoSpawnDelay
                tya
                tax
                jsr Random                      ;Randomize location from 4 possible
                and #$03
                tay
                lda droidSpawnXH,y
                sta actXH,x
                lda #$80
                sta actXL,x
                lda droidSpawnYH,y
                sta actYH,x
                lda droidSpawnYL,y
                sta actYL,x
                lda droidSpawnCtrl,y
                sta actMoveCtrl,x
                lda #ACT_LARGEDROID
                sta actT,x
                lda #AIMODE_FLYER
                sta actAIMode,x
                lda #ITEM_LASERRIFLE
                sta actWpn,x
                jsr InitActor
                jsr NoInterpolation             ;If explosion is immediately reused on same frame,
                ldx actIndex                    ;prevent artifacts
MEye_SpawnDelay:lda #DROID_SPAWN_DELAY
                sta actTime,x
MEye_WaitDroids:
MEye_Done:      rts
MEye_DoSpawnDelay:
                dec actTime,x
                rts

        ; Eye (Construct) boss phase 2
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveEyePhase2:  lda #DROID_SPAWN_DELAY-25
                sta MEye_SpawnDelay+1
                lda actHp,x
                beq MEye_Destroy
                lda actF1,x
                cmp #5
                bcc MEye_Turret
MEye_Descend:   sbc #4
                sta actSizeD,x                  ;Set collision size based on frame,
                lda #HP_EYE                     ;keep resetting health to full until fully descended
                sta actHp,x
                lda actFd,x
                bne MEye_NoSound
                lda #SFX_RELOADBAZOOKA
                jsr PlaySfx
MEye_NoSound:   ldy #14
                lda #2
                jsr OneShotAnimation
                bcc MEye_Done
                lda #2                          ;Start from center frame
                sta actF1,x
                lda #$00                        ;Reset droid spawn delay
                sta actTime,x
                ldy actXH+ACTI_PLAYER           ;If player is right from center, shoot to right first
                cpy #$41
                bcs MEye_FireRightFirst
                lda #$04
MEye_FireRightFirst:
                sta actFallL,x
                lda #EYE_MOVE_TIME*2            ;Some delay before firing initially
                sta actFall,X
MEye_Turret:    dec actFall,x                   ;Read firing controls from table with delay
                bmi MEye_NextMove
                lda actFall,x
                cmp #EYE_FIRE_TIME
                bcs MEye_Animate
                lda #$00
                beq MEye_StoreCtrl
MEye_NextMove:  lda actFallL,x
                inc actFallL,x
                and #$07
                tay
                lda #EYE_MOVE_TIME
                sta actFall,x
                lda eyeFrameTbl,y
                sta actF1,x
                lda eyeCtrlTbl,y
MEye_StoreCtrl: sta actCtrl,x
MEye_Animate:   jsr AttackGeneric
                lda #2
                jmp MEye_SpawnDroid             ;Continue to spawn droids, now 2 at a time
MEye_Destroy:   jsr Random
                pha
                and #$03
                sta shakeScreen
                pla
                and #$7f
                clc
                adc actFall,x
                sta actFall,x
                bcc MEye_NoExplosion
                lda #ACTI_FIRSTNPC              ;Use any free actors for explosions
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc MEye_NoExplosion
                lda #$01
                sta Irq1_Bg3+1
                jsr Random
                sta actXL,y
                and #$07
                clc
                adc #$3d
                sta actXH,y
                jsr Random
                sta actYL,y
                and #$07
                tax
                lda explYTbl,x
                sta actYH,y
                tya
                tax
                jsr ExplodeActor                ;Play explosion sound & init animation
                ldx actIndex
                rts
MEye_NoExplosion:
                jsr SetZoneColors
                inc actTime,x
                bpl MEye_NoExplosionFinish
                lda #4*8
                jsr MoveActorYNoInterpolation
                jmp ExplodeActor                ;Finally explode self
MEye_NoExplosionFinish:
                rts

        ; Eye destroy routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DestroyEye:     lda #COLOR_FLICKER
                sta actFlash,x
                lda #$00                        ;Final explosion counter
                sta actTime,x
                stx DE_RestX+1
                ldx #ACTI_LASTNPC
DE_DestroyDroids:
                lda actT,x
                cmp #ACT_LARGEDROID
                bne DE_Skip
                jsr DestroyActorNoSource
DE_Skip:        dex
                bne DE_DestroyDroids
DE_RestX:       ldx #$00
                rts

        ; Security chief move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveSecurityChief:
                lda actHp,x
                beq MSC_Dead
                cmp #HP_SECURITYCHIEF/2         ;Switch to grenade launcher at half health
                bcs MSC_NoWeaponChange
                lda actTime,x
                bmi MSC_NoWeaponChange
                lda actAttackD,x
                bne MSC_NoWeaponChange
                lda #ITEM_GRENADELAUNCHER
                sta actWpn,x
MSC_NoWeaponChange:
                lda #MUSIC_THRONE+1             ;If alive, play the bossfight music
                jsr PlaySong
                ldx actIndex
MSC_Dead:       jmp MoveAndAttackHuman

        ; Security chief destroy routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DestroySecurityChief:
                stx temp6
                lda #MUSIC_THRONE               ;Back to regular song
                jsr PlaySong
                ldx temp6
                jsr HumanDeath
                lda #ITEM_MINIGUN
                sta temp5
                lda #-2*8                       ;Drop also both weapons in addition
                jsr DI_SpawnItemWithSpeed       ;to the keycard
                sta temp3
                lda #ITEM_GRENADELAUNCHER
                sta temp5
                lda #2*8
                jmp DI_SpawnItemWithSpeed

        ; Rotor drone boss move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveRotorDrone: lda actHp,x
                beq MRD_Fall
                lda #MUSIC_MAINTENANCE+1        ;If alive, play the bossfight music
                jsr PlaySong
                ldx actIndex
                lda #-1                         ;Stay higher than normal flyers
                sta actFall,x
                lda actCtrl,x
                and #JOY_FIRE
                beq MRD_NotFiring
                lda actCtrl,x                   ;Convert horizontal firing to diagonal down
                ora #JOY_DOWN
                sta actCtrl,x
MRD_NotFiring:  lda actYH,x                     ;Prevent going outside zone
                cmp limitU
                bcs MRD_NoLimitU
                lda actMoveCtrl,x
                and #$ff-JOY_UP
                ora #JOY_DOWN
                sta actMoveCtrl,x
                bne MRD_ControlsOK
MRD_NoLimitU:   adc #$00
                cmp limitD
                bne MRD_ControlsOK
                lda actMoveCtrl,x
                and #$ff-JOY_DOWN
                ora #JOY_UP
                sta actMoveCtrl,x
MRD_ControlsOK: jsr MoveAccelerateFlyer
                lda #$00
                ldy actSX,x
                bmi MRD_SpeedNeg
MRD_SpeedPos:   cpy #1*8
                bcc MRD_FrameOK
                lda #$08
                bne MRD_FrameOK
MRD_SpeedNeg:   cpy #-1*8+1
                bcs MRD_FrameOK
                lda #$04
MRD_FrameOK:    sta temp1
                inc actFd,x
                lda actFd,x
                and #$01
                ora temp1
                sta adRotorDroneFrames
                ora #$02
                sta adRotorDroneFrames+1
                jmp AttackGeneric
MRD_Fall:       jsr Random
                and #$01
                sta shakeScreen
                jsr FallingMotionCommon
                tay
                beq MRD_ContinueFall
                lda #MUSIC_MAINTENANCE          ;Back to the normal music
                jsr PlaySong
                ldx actIndex
                jmp ExplodeEnemy2_8             ;Drop item & explode at any collision
MRD_ContinueFall:
                jsr Random                      ;Spawn explosions randomly while falling
                cmp #$30
                bcs MRD_NoExplosion
                lda #ACTI_FIRSTNPC              ;Use any free actors
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc MRD_NoExplosion
                jsr SpawnActor                  ;Actor type undefined at this point, will be initialized below
                tya
                tax
                jsr ExplodeActor
                ldx actIndex
MRD_NoExplosion:
                rts

        ; Rotor drone boss destroy routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DestroyRotorDrone:
                lda #-2*8                       ;Give upward speed so that the fall lasts longer
                sta actSY,x
                lda #PLOT_ROTORDRONE
                jmp SetPlotBit

        ; Large spider boss move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveLargeSpider:lda actHp,x
                bne MLS_Alive
MLS_Dying:      lda actXH,x                     ;Reached the wall?
                cmp #$3d
                bne MLS_DyingNoWall
                lda actXL,x
                cmp #$60
                bcs MLS_DyingNoWall
                jmp MLS_Explode
MLS_DyingNoWall:lda #<EP_OPENWALL               ;Wall script runs until spider no longer exists, then activates the wall object
                ldx #>EP_OPENWALL
                jsr SetScript
                ldx actIndex
                inc actTime,x
                lda actTime,x
                and #$01
                beq MLS_DyingNoFlash
                lda #$0c
MLS_DyingNoFlash:
                sta actFlash,x
                jsr Random
                pha
                and #$01
                sta shakeScreen
                pla                             ;Spawn explosions randomly while retreating
                cmp #$20
                bcs MLS_NoDyingExplosion
                lda #ACTI_FIRSTNPC              ;Use any free actors
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc MLS_NoDyingExplosion
                jsr SpawnActor                  ;Actor type undefined at this point, will be initialized below
                tya
                tax
                jsr ExplodeActor
                jsr Random
                jsr MoveActorX
                dec actYH,x
                jsr Random
                sta actYL,x
                ldx actIndex
MLS_NoDyingExplosion:
                lda #JOY_LEFT
                bne MLS_ForcedMoveImmediate

MLS_Alive:      lda #MUSIC_CAVES+1
                jsr PlaySong
                ldx actIndex
MLS_Decision:   lda actXH,x                     ;Move forward when about to hit the left wall
                cmp #$3d
                bne MLS_NotAtWall
                lda #JOY_RIGHT
MLS_ForcedMoveImmediate:
                pha
                lda #$00                        ;After forced move, make next random decision
                sta actTime,x                   ;immediately
                pla
                bne MLS_StoreMove
MLS_NotAtWall:  cmp #$3e                        ;Do not perform retreat when almost at the wall
                beq MLS_NotTooClose             ;(too easy to exploit)
                ldy #ACTI_PLAYER
                lda actHp,y                     ;If already dead, no need
                beq MLS_NotTooClose
                jsr GetActorDistance            ;Get X-distance to player
                lda temp6
                bne MLS_NotTooClose             ;If too close, retreat
                lda actD+ACTI_PLAYER
                asl
                lda #JOY_LEFT
                bcc MLS_ForcedMoveImmediate
                asl
                bne MLS_ForcedMoveImmediate
MLS_NotTooClose:dec actTime,x
                bpl MLS_Move
                lda actAttackD+ACTI_PLAYER      ;If player is attacking now, always attack
                beq MLS_NoForcedAttack          ;as the next decision
                lda #$03
                bne MLS_ForcedMove
MLS_NoForcedAttack:
                jsr Random
                and #$03
MLS_ForcedMove: tay
                jsr Random
                and spiderDelayAndTbl,y
                clc
                adc #$10
                sta actTime,x
                lda spiderMoveTbl,y
MLS_StoreMove:  sta actMoveCtrl,x
MLS_Move:       jsr MoveGeneric
                lda actXL+ACTI_PLAYER
                cmp actXL,x
                lda actXH+ACTI_PLAYER           ;Override direction: always face player
                sbc actXH,x
                sta actD,x
                lda actSX,x
                jsr Asr8
                clc
                adc actFd,x
                bpl MLS_NotOverNeg
                clc
                adc #$60
MLS_NotOverNeg: cmp #$60
                bcc MLS_NotOverPos
                sbc #$60
MLS_NotOverPos: sta actFd,x
                lsr
                lsr
                lsr
                lsr
                lsr
                sta actF1,x
                lda actMoveCtrl,x               ;About to launch acid?
                cmp #JOY_FIRE
                bne MLS_NoAttack
                lda #2
                sta actF1,x
                lda #$40                        ;Reset walking animation after attack
                sta actFd,x
                lda actTime,x
                cmp #8
                bcs MLS_NoAttack
                cmp #4
                bcc MLS_NoAttack
                php
                inc actF1,x
                plp
                bne MLS_NoAttack

MLS_Attack:     lda #ACTI_FIRSTNPCBULLET
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc MLS_NoAttack
                lda #SFX_SHOTGUN
                jsr PlaySfx
                lda #<(-9*8)
                sta temp3
                lda #>(-9*8)
                sta temp4
                lda actD,x
                bmi MLS_AttackLeft
MLS_AttackRight:lda #<28*8
                sta temp1
                lda #>28*8
                sta temp2
                lda #ACT_ACID
                jsr SpawnWithOffset
                tya
                tax
                jsr InitActor
                lda #6*8+4
                sta actSX,x
                lda actXH,x
                sec
                sbc actXH+ACTI_PLAYER           ;Player is on the right -> negative
MLS_AttackCommon:
                asl
                asl
                adc #-3*8-2
                sta actSY,x
                ldx actIndex
MLS_NoAttack:   rts

MLS_AttackLeft: lda #<(-28*8)
                sta temp1
                lda #>(-28*8)
                sta temp2
                lda #ACT_ACID
                jsr SpawnWithOffset
                tya
                tax
                jsr InitActor
                lda #-6*8-4
                sta actSX,x
                lda actXH+ACTI_PLAYER
                sec
                sbc actXH,x                    ;Player is on the left -> negative
                jmp MLS_AttackCommon

MLS_Explode:    lda #MUSIC_CAVES
                jsr PlaySong
                ldx actIndex
                lda #-15*8
                jsr MoveActorYNoInterpolation
                lda #6
                ldy #$ff
                jsr ExplodeEnemyMultiple
                lda #-2*8-8
                sta temp7                       ;Initial base X-speed
                lda #0
                sta temp8                       ;Initial shape
MLS_ChunkLoop:  lda #ACTI_FIRSTNPC              ;Use any free actors
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc MLS_ChunkDone
                lda #ACT_SPIDERCHUNK
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
                lda temp8
                sta actF1,y
                inc temp8
                lda #CHUNK_DURATION
                sta actTime,y
                lda temp7
                bpl MLS_ChunkDone
                clc
                adc #2*8
                sta temp7
                bne MLS_ChunkLoop
MLS_ChunkDone:  rts

        ; Script routine for opening the wall after spider death
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

OpenWall:       lda #ACT_LARGESPIDER            ;Run either when the spider has exploded, or player exits the zone
                jsr FindActor
                bcs OW_HasSpider
                ldy #7
                jsr ActivateObject
                jmp StopScript
MA_NotDone:
OW_HasSpider:   rts

        ; Acid move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveAcid:       lda actHp+ACTI_PLAYER
                beq MA_NoPlayerCollision
                lda #DMG_ACID
                jsr CollideAndDamagePlayer
                bcs MA_StartPlayerSplash
MA_NoPlayerCollision:
                jsr FallingMotionCommon
                tay                             ;Any collision -> splash
                bne MA_StartSplash
                lda #1
                ldy #3
                jmp LoopingAnimation
MA_StartSplash: lda #ACT_WATERSPLASH
                jsr TransformActor
MA_SplashCommon:jsr NoInterpolation
                lda #13
                sta actFlash,x
                lda #SFX_SPLASH
                jmp PlaySfx
MA_StartPlayerSplash:
                lda #ACT_EXPLOSION
                jsr TransformActor
                lda #-4*8
                jsr MoveActorY
                lda #2
                sta actF1,x
                bne MA_SplashCommon

        ; Recycling station script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

recyclerSelection = menuCounter
recyclerListLength = wpnLo
originalItem    = wpnHi
currentIndex    = wpnBits

RecyclingStation:
                ldy itemIndex
                sty originalItem
                ldy #RECYCLER_ITEM_FIRST
                ldx #$00
RS_FindItems:   cpy #ITEM_FIRST_CONSUMABLE
                bcs RS_ItemOK
                jsr FindItem                    ;For weapons, check that is currently held in inventory
                bcc RS_NextItem                 ;(recycler only "sells" ammo, not weapons)
RS_ItemOK:      lda recyclerCountTbl-RECYCLER_ITEM_FIRST,y
                beq RS_NextItem
                tya
                sta recyclerItemList,x
                inx                             ;If using "all items" cheat, the list could be exceeded
                cpx #MAX_RECYCLER_ITEMS         ;Simply cut it in this case
                bcs RS_ListDone
RS_NextItem:    iny
                cpy #RECYCLER_ITEM_LAST+1
                bcc RS_FindItems
RS_ListDone:    lda #$ff
                sta recyclerItemList,x          ;Write endmark
                sta menuMoveDelay               ;Disable controls until joystick centered
                stx recyclerListLength
                jsr BlankScreen
                lda #$02
                sta screen                      ;Set text screen mode
                lda #$0f
                sta scrollX
                ldx #$00
                stx recyclerSelection
                stx SL_CSSScrollY+1
                stx Irq1_Bg1+1
RS_ClearScreenLoop:lda #$20
                sta screen1,x
                sta screen1+$100,x
                sta screen1+$200,x
                sta screen1+SCROLLROWS*40-$100,x
                lda #$01
                sta colors,x
                sta colors+$100,x
                sta colors+$200,x
                sta colors+SCROLLROWS*40-$100,x
                inx
                bne RS_ClearScreenLoop
                lda #9
                sta temp1
                lda #3
                sta temp2
                lda #<txtRecycler
                ldx #>txtRecycler
                jsr PrintText
                lda #0
                sta currentIndex
                lda #5
                sta temp2
RS_PrintItemsLoop:
                lda #10
                sta temp1
                ldx currentIndex
                lda recyclerItemList,x
                bmi RS_PrintExit
                jsr GetItemName
                jsr PrintText
                lda #26
                sta temp1
                ldx currentIndex
                ldy recyclerItemList,x
                lda recyclerCountTbl-RECYCLER_ITEM_FIRST,y
                jsr ConvertDigits
                ldx #0
RS_FindNonZero: lda txtDigits,x
                cmp #$30
                bne RS_FindNonZeroFound
                lda #$20
                sta txtDigits,x
                sta txtDigits-1,x
                inx
                bne RS_FindNonZero
RS_FindNonZeroFound:
                lda #"+"
                sta txtDigits-1,x
                lda #<txtCount
                ldx #>txtCount
                jsr PrintText
                inc temp2
                inc currentIndex
                bne RS_PrintItemsLoop
RS_PrintExit:   lda #<txtExit
                ldx #>txtExit
                jsr PrintText
                lda #9
                sta temp1
                lda #17
                sta temp2
                lda #<txtParts
                ldx #>txtParts
                jsr PrintText
                lda #23
                sta temp1
                lda #<txtCost
                ldx #>txtCost
                jsr PrintText
RS_Redraw:      lda #$20
RS_ArrowLastPos:sta screen1
                lda #8
                sta temp1
                lda recyclerSelection
                clc
                adc #5
                sta temp2
                lda #<txtArrow
                ldx #>txtArrow
                jsr PrintText
                lda zpDestLo
                sta RS_ArrowLastPos+1
                lda zpDestHi
                sta RS_ArrowLastPos+2
                lda #15
                sta temp1
                lda #17
                sta temp2
                lda invCount+ITEM_PARTS-1
                cmp #NO_ITEM_COUNT
                adc #$00
                sta RS_NumParts+1
                jsr Print3Digits
                lda #28
                sta temp1
                lda #$00
                sta reload                      ;Cancel any reloading so that ammo can be shown
                ldx recyclerSelection
                ldy recyclerItemList,x
                bmi RS_ZeroCost
                sty itemIndex
                jsr SetPanelRedrawItemAmmo
                lda recyclerCostTbl-RECYCLER_ITEM_FIRST,y
RS_ZeroCost:    jsr Print3Digits
RS_ControlLoop: jsr FinishFrame
                jsr GetControls
                lda recyclerSelection
                ldx recyclerListLength
                jsr RS_Control
                sta recyclerSelection
                bcs RS_Redraw
                jsr GetFireClick
                bcs RS_Action
                lda keyPress
                bmi RS_ControlLoop
RS_Exit:        ldy originalItem
                sty itemIndex
                jsr SetPanelRedrawItemAmmo
                ldy lvlObjNum                   ;Allow immediate re-entry
                jsr InactivateObject
                jmp CenterPlayer
RS_Action:      lda recyclerSelection
                cmp recyclerListLength
                bne RS_Buy
                lda #SFX_SELECT
                jsr PlaySfx
                jmp RS_Exit
RS_Buy:         ldy itemIndex
RS_NumParts:    lda #$00
                cmp recyclerCostTbl-RECYCLER_ITEM_FIRST,y
                bcc RS_BuyFail
                lda recyclerCountTbl-RECYCLER_ITEM_FIRST,y
                tax
                tya
                jsr AddItem
                bcc RS_BuyFail
                ldy itemIndex
                lda recyclerCostTbl-RECYCLER_ITEM_FIRST,y
                ldy #ITEM_PARTS
                jsr DecreaseAmmo
                lda #SFX_EMP
                jsr PlaySfx
                jmp RS_Redraw
RS_BuyFail:     lda #SFX_DAMAGE
                jsr PlaySfx
                jmp RS_ControlLoop

        ; Print 8-bit number in A

Print3Digits:   jsr ConvertDigits
                lda #<txtDigits
                ldx #>txtDigits

        ; Print null-terminated text, with textjump support for item names

PrintText:      sta zpSrcLo
                stx zpSrcHi
                ldy temp2
                lda #40
                ldx #zpDestLo
                jsr MulU
                lda temp1
                jsr Add8
                lda zpDestHi
                ora #>screen1
                sta zpDestHi
                ldy #$00
PT_Loop:        lda (zpSrcLo),y
                bmi PT_Jump
                beq PT_Done
                sta (zpDestLo),y
                iny
                bne PT_Loop
PT_Done:        rts
PT_Jump:        sty PT_Sub+1
                pha
                iny
                lda (zpSrcLo),y
                dey
                sec
PT_Sub:         sbc #$00
                sta zpSrcLo
                pla
                and #$7f
                sbc #$00
                sta zpSrcHi
                bpl PT_Loop

        ; Convert 3 digits to a printable string

ConvertDigits:  jsr ConvertToBCD8
                ldx #$00
                lda temp7
                jsr StoreDigit
                lda temp6
                pha
                lsr
                lsr
                lsr
                lsr
                jsr StoreDigit
                pla
StoreDigit:     and #$0f
                ora #$30
                sta txtDigits,x
                inx
                rts

        ; Recycler menu control

RS_Control:     tay
                stx temp6
                ldx menuMoveDelay
                beq RSC_NoDelay
                bpl RSC_Decrement
RSC_InitialDelay:ldx joystick
                bne RSC_ContinueDelay
                stx menuMoveDelay
RSC_ContinueDelay:
                rts
RSC_Decrement:  dec menuMoveDelay
                rts
RSC_NoDelay:    lda joystick
                lsr
                bcc RSC_NotUp
                dey
                bpl RSC_HasMove
                ldy temp6
RSC_HasMove:    lda #SFX_SELECT
                jsr PlaySfx
                ldx #RECYCLER_MOVEDELAY
                lda joystick
                cmp prevJoy
                bne RSC_NormalDelay
                dex
                dex
                dex
RSC_NormalDelay:stx menuMoveDelay
                sec
                tya
                rts
RSC_NoMove:     clc
                tya
                rts
RSC_NotUp:      lsr
                bcc RSC_NoMove
                iny
                cpy temp6
                bcc RSC_HasMove
                beq RSC_HasMove
                ldy #$00
                beq RSC_HasMove

        ; Hideout door script routine (check that rotordrone is destroyed)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HideoutDoor:    lda #SFX_OBJECT
                jsr PlaySfx
                lda #PLOT_ROTORDRONE
                jsr GetPlotBit
                beq HD_Offline
                ldy lvlObjNum
                jmp ToggleObject
HD_Offline:     lda #<txtHideoutLocked
                ldx #>txtHideoutLocked
                ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText

        ; Final server room droid spawn positions

droidSpawnXH:   dc.b $3e,$43,$3e,$43
droidSpawnYH:   dc.b $30,$30,$37,$37
droidSpawnYL:   dc.b $00,$00,$ff,$ff
droidSpawnCtrl: dc.b JOY_DOWN|JOY_RIGHT,JOY_DOWN|JOY_LEFT,JOY_UP|JOY_RIGHT,JOY_UP|JOY_LEFT

        ; Eye firing pattern

eyeCtrlTbl:     dc.b JOY_DOWN|JOY_FIRE
                dc.b JOY_RIGHT|JOY_DOWN|JOY_FIRE
                dc.b JOY_RIGHT|JOY_FIRE
                dc.b JOY_RIGHT|JOY_DOWN|JOY_FIRE
                dc.b JOY_DOWN|JOY_FIRE
                dc.b JOY_LEFT|JOY_DOWN|JOY_FIRE
                dc.b JOY_LEFT|JOY_FIRE
                dc.b JOY_LEFT|JOY_DOWN|JOY_FIRE

eyeFrameTbl:    dc.b 2,1,0,1,2,3,4,3

        ; Final explosion Y-positions

explYTbl:       dc.b $31,$32,$33,$34,$35,$36,$33,$34

        ; Large spider move table

spiderMoveTbl:  dc.b JOY_LEFT,JOY_RIGHT,JOY_FIRE,JOY_FIRE
spiderDelayAndTbl:
                dc.b $1f,$1f,$07,$07

        ; Recycler tables

recyclerCountTbl:
                dc.b 10                         ;Pistol
                dc.b 8                          ;Shotgun
                dc.b 30                         ;Auto rifle
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
                dc.b 25                         ;Minigun
                dc.b 25                         ;Flamethrower
                dc.b 30                         ;Laser rifle
                dc.b 30                         ;Plasma gun
                dc.b 35                         ;EMP generator
                dc.b 35                         ;Grenade launcher
                dc.b 40                         ;Bazooka
                dc.b 0                          ;Extinguisher
                dc.b 30                         ;Grenade
                dc.b 40                         ;Mine
                dc.b 50                         ;Medikit
                dc.b 50                         ;Battery
                dc.b 75                         ;Armor

recyclerItemList:
                ds.b MAX_RECYCLER_ITEMS+1,0

txtRecycler:    dc.b "PART RECYCLING STATION",0
txtExit:        dc.b "EXIT",0
txtCost:        dc.b "COST",0
txtCount:       dc.b " "
txtDigits:      dc.b "000",0
txtArrow:       dc.b 62,0
txtHideoutLocked:dc.b "LOCKED",0

                checkscriptend

