                include macros.s
                include mainsym.s

        ; Script 23, Construct bossfight + placeholder endings

                org scriptCodeStart

EYE_MOVE_TIME = 10
EYE_FIRE_TIME = 8
DROID_SPAWN_DELAY = 4*25

                org scriptCodeStart

                dc.w MoveEyePhase1
                dc.w MoveEyePhase2
                dc.w DestroyEye
                dc.w ConstructEnding
                dc.w Ending1
                dc.w Ending2
                dc.w Ending3

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
                jsr FadeMusic
                jsr ClearPanelText
                jsr BlankScreen
                lda #PLOT_DISRUPTCOMMS          ;Jormungandr already destroyed?
                jsr GetPlotBit                  ;If not, show interlude
                bne CE_NoInterlude
                lda #<EP_JORMUNGANDRINTERLUDE
                ldx #>EP_JORMUNGANDRINTERLUDE
                jmp ExecScript
CE_NoInterlude: lda #<EP_ENDING3
                ldx #>EP_ENDING3
                jmp ExecScript

        ; Ending 1: Jormungandr destroyed
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: Various

Ending1:        lda #$00
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
E1_InterludeLoop:
                jsr DrawActors
                jsr AddActors
                jsr FinishFrame
                jsr UpdateActors
                jsr FinishFrame
                inc interludeTime
                lda interludeTime
                cmp #100
                bcs E1_InterludeDone
                cmp #25
                bne E1_InterludeLoop
                lda #ACT_EYEINVISIBLE           ;Show the eye descending after some delay
                jsr FindActor
                jsr MEye_Show
                jmp E1_InterludeLoop
E1_InterludeDone:
                jsr SetupTextScreen
                lda #5
                sta temp2
                lda #0
                sta temp1
                lda #<txtEnding1
                ldx #>txtEnding1
                jsr PrintMultipleRows
DestructionEndingCommon:
                lda #<2500
                ldy #>2500
                jsr EndingBonus
                lda #MUSIC_ENDING1
EndingCommon:   ldx #$00                        ;Kill sound effects so the music will play properly
                stx ntChnSfx
                stx ntChnSfx+7
                stx ntChnSfx+14
                jsr PlaySong
                jsr StopScript
                lda score
                ldx score+1
                ldy score+2
                jsr ConvertToBCD24
                ldx #0
                lda temp8
                jsr EndingBCD
                lda temp7
                jsr EndingBCD
                lda temp6
                jsr EndingBCD
                ldx #txtTime-txtScore
                lda time
                jsr ConvertToBCD8
                lda temp6
                jsr StoreOneDigit
                inx
                lda time+1
                jsr ConvertToBCD8
                lda temp6
                jsr EndingBCD
                inx
                lda time+2
                jsr ConvertToBCD8
                lda temp6
                jsr EndingBCD
                lda #11
                sta temp2
                lda #9
                sta temp1
                lda #<txtFinalScore
                ldx #>txtFinalScore
                jsr PrintMultipleRows
                jsr WaitForExit
                jsr FadeMusicEnd
                jsr SetupTextScreen
                ldx #STACKSTART
                txs
                jmp UM_SaveGame

        ; Ending 2: Construct destroyed
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: Various

Ending2:        jsr SetupTextScreen
                lda #<2500
                ldy #>2500
                jsr EndingBonus
                lda #5
                sta temp2
                lda #0
                sta temp1
                lda #<txtEnding2
                ldx #>txtEnding2
                jsr PrintMultipleRows
                jmp DestructionEndingCommon

        ; Ending 3: both destroyed
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: Various

Ending3:        jsr SetupTextScreen
                lda #5
                sta temp2
                lda #0
                sta temp1
                lda #<txtEnding3
                ldx #>txtEnding3
                jsr PrintMultipleRows
                lda #<3750
                ldy #>3750
                jsr EndingBonus
                lda #MUSIC_ENDING2
                jmp EndingCommon

        ; Score/time subroutines

EndingBCD:      pha
                lsr
                lsr
                lsr
                lsr
                jsr StoreDigit
                pla
StoreOneDigit:  and #$0f
StoreDigit:     ora #$30
                sta txtScore,x
                inx
                rts

        ; Ending bonus subroutine

EndingBonus:    sta temp1
                sty temp2
                ldy saveDifficulty
                lda plrDmgModifyTbl,y
                lsr
                tax
EB_Loop:        lda temp1
                ldy temp2
                jsr AddScore
                dex
                bne EB_Loop
                rts

        ; Music fade subroutine

FadeMusic:      lda fastLoadMode
                beq FM_Done                     ;Using fallback loader, no fade as there already are screen-blanking pauses
FadeMusicEnd:   lda PS_CurrentSong+1
                beq FM_Done                     ;No fade if game music off
FM_Loop:        lda Play_MasterVol+1
                beq FM_Done
                dec Play_MasterVol+1
                ldx #$06
FM_Delay:       jsr WaitBottom
                dex
                bne FM_Delay
                beq FM_Loop
FM_Done:        rts

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

        ; Placeholder ending texts

                     ;0123456789012345678901234567890123456789
txtEnding1:     dc.b "  THE CONSTRUCT HACKS AUTOMATED SECOND",0
                dc.b "STRIKE SYSTEMS TO ATTACK RANDOM TARGETS.",0
                dc.b " RETALIATIONS FOLLOW. UNDER A BLACKENED",0
                dc.b "  SUN, A GRIM AGE OF SURVIVAL BEGINS..",0,0

                     ;0123456789012345678901234567890123456789
txtEnding2:     dc.b " JORMUNGANDR TRAVELS THE EARTH'S CRUST.",0
                dc.b "VOLCANIC ERUPTIONS BLACKEN THE SUN UNDER",0
                dc.b "HEAVY ASH CLOUDS. A GRIM AGE OF SURVIVAL",0
                dc.b " IN THE BITTER COLD IS ABOUT TO BEGIN..",0,0

                      ;0123456789012345678901234567890123456789
txtEnding3:     dc.b "  JORMUNGANDR AND CONSTRUCT ARE NO MORE",0
                dc.b "  MANKIND IS ONCE AGAIN FREE TO DESTROY",0
                dc.b "       ITSELF WITHOUT OUTSIDE AID",0,0

txtFinalScore:  dc.b " FINAL SCORE "
txtScore:       dc.b "0000000",0
                dc.b " ",0
                dc.b "  FINAL TIME "
txtTime:        dc.b "0:00:00",0
                dc.b " ",0
                dc.b "PRESS FIRE TO CONTINUE",0,0
                     ;0123456789012345678901

                checkscriptend