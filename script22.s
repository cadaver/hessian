                include macros.s
                include mainsym.s

        ; Script 22, second cave + Constuct bossfight

                org scriptCodeStart

EYE_MOVE_TIME = 10
EYE_FIRE_TIME = 8
DROID_SPAWN_DELAY = 4*25

                dc.w InstallLaptop
                dc.w InstallLaptopWork
                dc.w InstallLaptopFinish
                dc.w MoveEyePhase1
                dc.w MoveEyePhase2
                dc.w DestroyEye
                dc.w ConstructEnding
                dc.w ConstructInterlude

        ; Install laptop script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

InstallLaptop:  ldy #ITEM_LAPTOP
                jsr FindItem
                bcc IL_NoItem
                lda #ACT_HACKER                 ;Check for executing both of the plans: if Jeff is already
                jsr FindLevelActor              ;in hazmat suit, this plan is not available
                bcc IL_NoItem
                lda actMB+ACTI_PLAYER
                lsr
                bcc IL_NoItem                   ;Wait until not jumping
                ldy #ITEM_LAPTOP
                jsr RemoveItem
                jsr AddQuestScore
                lda #PLOT_DISRUPTCOMMS
                jsr SetPlotBit
                lda #<EP_HACKERFINAL
                ldx #>EP_HACKERFINAL
                sta actScriptEP+2
                stx actScriptF+2
                lda #$00
                tax
                sta temp4
                lda #ITEM_LAPTOP
                jsr DI_ItemNumber
                ldx temp8
                lda #$80
                sta actXL,x                     ;Always center of block
                lda #$00
                sta actSY,x                     ;No speed
                lda #<EP_INSTALLLAPTOPWORK
                ldx #>EP_INSTALLLAPTOPWORK
                jsr SetScript
                gettext txtInstallStart
                jsr RadioMsg
                lda #JOY_DOWN                   ;Crouch to place the laptop
                sta actMoveCtrl+ACTI_PLAYER
IL_NoItem:      rts

        ; Install laptop in-progress script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

InstallLaptopWork:
                lda textTime
                bne IL_NoItem                   ;Wait until text finished
                inc scriptVariable
                lda scriptVariable
                cmp #75                         ;Some delay
                bcc IL_NoItem
                jsr StopScript
                lda #PLOT_OLDTUNNELSLAB2        ;Jeff in lab?
                jsr GetPlotBit
                bne ILW_VariationB
ILW_VariationA: gettext txtSignalUnknown
                jmp RadioMsg
ILW_VariationB: gettext txtSignalKnown
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx

        ; Install laptop finish (while climbing to exit)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various
        
InstallLaptopFinish:
                lda #PLOT_DISRUPTCOMMS
                jsr GetPlotBit
                beq ILF_NotYet                  ;May visit here without laptop
                gettext txtInstallFinish
                jmp RadioMsg
ILF_NotYet:     ldy lvlObjNum
                jmp InactivateObject

        ; Eye (Construct) boss phase 1
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveEyePhase1:  lda actT+ACTI_PLAYER            ;No action in the ending interlude (no player)
                beq MEye_Wait2
                ldy #C_SMALLROBOTS              ;Ensure droid sprites are loaded to avoid pause later
                jsr EnsureSpriteFile
                lda lvlObjB+$1e                 ;Close door immediately once player moves or fires
                bpl MEye_DoorDone
                lda actXL+ACTI_PLAYER
                cmp #$c0
                bcs MEye_CloseDoor
                lda actAttackD+ACTI_PLAYER
                bne MEye_CloseDoor
MEye_Wait2:     rts
MEye_CloseDoor: lda #MUSIC_ASSAULT+1
                jsr PlaySong
                ldy #$1e
                jsr InactivateObject
                ldx actIndex
MEye_DoorDone:  lda #$01
                sta ULO_NoAirFlag+1             ;Cause air to be sucked away during battle
                lda #ACT_SUPERCPU               ;Wait until all CPUs destroyed
                jsr FindActor
                ldx actIndex
                bcs MEye_HasCPUs
MEye_GotoPhase2:lda numSpawned                  ;Wait until all droids from phase1 destroyed
                cmp #2
                bcs MEye_Wait
MEye_Show:      inc actT,x                      ;Move to visible eye stage
                lda #5                          ;Descend animation
                sta actF1,x
                jmp InitActor

MEye_HasCPUs:   lda #1
MEye_SpawnDroid:cmp numSpawned
                bcc MEye_Wait
                jsr GetFreeNPC
                bcc MEye_Wait
                lda actTime,x
                bne MEye_DecSpawnDelay
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
MEye_ResetSpawnDelay:
                lda #DROID_SPAWN_DELAY
                skip2
MEye_DecSpawnDelay:
                sbc #$01                        ;C=1 here
                sta actTime,x
MEye_Wait:      rts

        ; Eye (Construct) boss phase 2
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveEyePhase2:  lda actHp,x
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
                bcc MEye_Wait
                lda #2                          ;Start from center frame
                sta actF1,x
                lda #$00                        ;Reset droid spawn delay (spawn one immediately)
                sta actTime,x
                ldy actXH+ACTI_PLAYER           ;If player is right from center, shoot to right first
                cpy #$41
                bcs MEye_FireRightFirst
                lda #$04
MEye_FireRightFirst:
                sta actFallL,x
                lda #EYE_MOVE_TIME*2            ;Some delay before firing initially
                sta actFall,X
MEye_Turret:    lda actT+ACTI_PLAYER            ;No firing in the ending interlude (no player)
                beq MEye_NoPlayer
                dec actFall,x                   ;Read firing controls from table with delay
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
MEye_Destroy:   lda #$00
                sta ULO_NoAirFlag+1             ;Restore oxygen now
                jsr Random
                pha
                and #$03
                sta shakeScreen
                pla
                and #$7f
                clc
                adc actFall,x
                sta actFall,x
                bcc MEye_NoExplosion
                jsr GetAnyFreeActor
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
MEye_NoPlayer:  rts
MEye_NoExplosion:
                jsr SetZoneColors
                inc actTime,x
                bpl MEye_NoExplosionFinish
                lda #<EP_CONSTRUCTENDING
                ldx #>EP_CONSTRUCTENDING
                jsr SetScript
                ldx actIndex
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
CE_Wait:        rts

        ; Ending after Construct is destroyed
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ConstructEnding:lda #ACT_EXPLOSION              ;Wait for final explosion to vanish
                jsr FindActor
                bcs CE_Wait
                jsr FadeSong
                jsr ClearPanelText
                jsr BlankScreen
                lda #PLOT_DISRUPTCOMMS          ;Jormungandr already destroyed?
                jsr GetPlotBit                  ;If not, show interlude
                bne CE_NoInterlude
                lda #<EP_JORMUNGANDRINTERLUDE
                ldx #>EP_JORMUNGANDRINTERLUDE
                jmp ExecScript
CE_NoInterlude: lda #<EP_ENDSEQUENCE
                ldx #>EP_ENDSEQUENCE
                ldy #$02                        ;Ending 3
                jmp ExecScriptParam

        ; Construct interlude
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: Various

ConstructInterlude:
                lda #$00
                sta actT+ACTI_PLAYER
                sta blockX
                sta blockY
                ldx #$3c
                stx mapX
                stx actXH+ACTI_PLAYER
                ldy #$31
                sty mapY
                sty actYH+ACTI_PLAYER
                lda #13
                jsr ChangeLevel
                jsr FindPlayerZone
                jsr RedrawAndAddActors
                jsr SL_NewMapPos
                lda #$00
                sta interludeTime
                jsr PlaySong
CI_Loop:        jsr DrawActors
                jsr FinishFrame
                jsr UpdateActors
                jsr FinishFrame
                inc interludeTime
                lda interludeTime
                cmp #100
                bcs CI_Done
                cmp #25
                bne CI_Loop
                lda #ACT_EYEINVISIBLE           ;Show the eye descending after some delay
                jsr FindActor
                jsr MEye_Show
                jmp CI_Loop
CI_Done:        jsr BlankScreen
                lda #<EP_ENDSEQUENCE
                ldx #>EP_ENDSEQUENCE
                ldy #$00                        ;Ending 1
                jmp ExecScriptParam

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

        ; Variables
        
interludeTime:  dc.b 0

        ; Messages

txtInstallStart:dc.b 34,"JEFF HERE. THIS MUST BE THE AI'S LINK. LET'S GET TO WORK.",34,0

txtSignalUnknown:
                dc.b 34,"WHAT? THIS ISN'T THE MILITARY LINE, BUT TRAFFIC BETWEEN TWO ENTITIES. WAIT A MINUTE.. JORMUNGANDR. "
                dc.b "IT'S SOME KIND OF FAILSAFE PROTOCOL. FAIL-DEADLY, I MEAN. IF EITHER END FALLS SILENT, SOMETHING BAD HAPPENS. "
                dc.b "I'LL SEE WHAT I CAN DO AND GET BACK TO YOU.",34,0

txtSignalKnown: dc.b 34,"I'M GETTING BI-DIRECTIONAL TRAFFIC, JUST LIKE I IMAGINED. THIS IS THE REVENGE PROTOCOL. "
                dc.b "WILL BEGIN DECODING IT NOW. BACK IN A MINUTE.",34,0

txtInstallFinish:
                dc.b 34,"JEFF AGAIN. MANAGED TO IDENTIFY A SEQUENCE WHICH I CAN REPLAY ENDLESSLY. "
                dc.b "WE'LL SEE HOW IT GOES WHEN YOU TAKE OUT JORMUNGANDR. DO NOT, I REPEAT DO NOT ATTACK THE AI FIRST. ITS SEQUENCE "
                dc.b "MUTATES CONSTANTLY, WHICH I CAN'T SPOOF.",34,0

                checkscriptend
