                include macros.s
                include mainsym.s

        ; Script 3, Construct + other boss fights

EYE_MOVE_TIME = 10
EYE_FIRE_TIME = 8
DROID_SPAWN_DELAY = 4*25

                org scriptCodeStart

                dc.w MoveEyePhase1
                dc.w MoveEyePhase2
                dc.w DestroyEye
                dc.w MoveSecurityChief
                dc.w DestroySecurityChief
                dc.w MoveRotorDrone
                dc.w DestroyRotorDrone
                dc.w HideoutDoor
                dc.w Hacker
                dc.w Hacker2

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
                bcc MEye_DoorOpen
MEye_CloseDoor: ldy #$1e
                jsr InactivateObject
                ldx actIndex
MEye_DoorDone:  inc ULO_NoAirFlag+1             ;Cause air to be sucked away during battle
MEye_DoorOpen:  lda #DROID_SPAWN_DELAY
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
                lda #ACTI_FIRSTNPC
                ldy #ACTI_LASTNPC
                jsr GetFreeActor
                bcc MEye_Done
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
                inc ULO_NoAirFlag+1             ;Cause air to be sucked away during battle
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
                and #$3f
                clc
                adc #$10
                adc actTime,x
                sta actTime,x
                bcc MRD_NoExplosion
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

        ; Hacker script routine (initial scene in the hideout)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Hacker:         lda actXH+ACTI_PLAYER
                cmp #$1c
                bcs H_NotClose                  ;Wait until close
                jsr AddQuestScore
H_Random:       jsr Random
                and #$03
                beq H_Random
                clc
                adc #$36                        ;Randomize between 75%, 85%, 95%
                sta txtPercent
                lda #<EP_HACKER2
                sta actScriptEP+2               ;Set 2nd script
                ldy #ACT_HACKER
                lda #<txtHacker
                ldx #>txtHacker
                jmp SpeakLine
H_NoItem:
H_NotClose:     rts

        ; Hacker script routine 2 (when picking up the amp)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Hacker2:        ldy #ITEM_AMPLIFIER
                jsr FindItem
                bcc H_NoItem
                lda actF1+ACTI_PLAYER           ;Wait until player is standing again
                cmp #FR_DUCK
                bcs H_NoItem
                lda #$00                        ;No more scripts for now
                sta actScriptF+2
                ldy #ACT_HACKER
                lda #<txtHacker2
                ldx #>txtHacker2
                jmp SpeakLine

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

        ; Messages

txtHideoutLocked:dc.b "LOCKED",0
txtHacker:      dc.b 34,"HEY. YOU MUST BE KIM. THE SCIENTISTS TOLD YOU MIGHT BE COMING. "
                dc.b "I'M JEFF. SORRY ABOUT THAT SENTRY DRONE, HAD TO MAKE SURE YOU'RE NOT A MACHINE. "
                dc.b "I'D ESTIMATE YOUR FIGHTING STYLE AS "
txtPercent:     dc.b "95% HUMAN. YOU CAME FOR THAT SIGNAL AMP FOR THE LASER, RIGHT? "
                dc.b "NEVER TESTED IT SO CAN'T BE SURE WHAT HAPPENS WHEN YOU PLUG IT IN. OH, FEEL FREE TO USE THE RECYCLER "
                dc.b "AT THE BACK IF YOU NEED. BUT DON'T TOUCH ANYTHING ELSE.",34,0

txtHacker2:     dc.b 34,"IT'S A MESSED UP SITUATION ALL RIGHT. BUT I WASN'T THAT SURPRISED. "
                dc.b "WITH WHAT WE'RE DOING, IT WAS BOUND TO HAPPEN SOONER OR LATER.",34,0

                checkscriptend

