                include macros.s
                include mainsym.s

        ; Script 3, mid-game and lower labs interactions
        
                org scriptCodeStart

                dc.w RadioLowerLabs
                dc.w HackerAmbush
                dc.w GiveLaptop
                dc.w DisconnectSubnet
                dc.w ServerRoomComputer
                dc.w MoveScientists
                dc.w RadioConstruct
                dc.w ThroneChief
                dc.w FindFilter
                dc.w BeginAmbush
                dc.w RadioConstruct2
                dc.w BeginSurgery
                dc.w BeginSurgery2
                dc.w AfterSurgery
                dc.w AfterSurgeryRun
                dc.w AfterSurgeryZone
                dc.w AfterSurgeryNoAir
                dc.w AfterSurgeryFollow
                dc.w AfterSurgeryNoAirDie
                dc.w AfterSurgeryNoAirRadio
                dc.w ReachOldTunnels

        ; Radio speech shortly after entering lower labs
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioLowerLabs: gettext TEXT_ENTERLOWERLABS
                jmp RadioMsg

        ; Hacker ambush NPC script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerAmbush:   ldx actIndex
                lda actF1,x
                cmp #FR_DIE
                bcs HA_Dying
                cmp #FR_DUCK+1
                beq HA_DieAgain
                lda actHp,x                     ;Set health (invincible by default)
                bne HA_HealthSet
                lda #HP_HACKER
                sta actHp,x
HA_HealthSet:   lda #ACT_HIGHWALKER
                jsr FindActor
                bcc HA_EnemyDestroyed
                lda actIndex
                ldy actHp,x
                cpy #HP_HIGHWALKER
                bcs HA_NotDamaged
                lda #ACTI_PLAYER                ;Attack player once damaged, Jeff otherwise
HA_NotDamaged:  sta actAITarget,x
                ldx actIndex
                lda actXH,x                     ;Continue running if already left
                cmp #$17
                bcc HA_Run
                lda actHp,x
                cmp #HP_HACKER
                bcs HA_Wait                     ;Wait until hit once, then run
HA_Run:         lda #JOY_LEFT
HA_SetControls: sta actMoveCtrl,x
                lda #AIMODE_IDLE
                sta actAIMode,x
HA_Wait:        rts
HA_Dying:       lda #DEATH_DISAPPEAR_DELAY      ;Keep resetting the time
                sta actTime,x
                lda #ACT_HIGHWALKER
                jsr FindActor
                bcs HA_Wait                     ;Wait until enemy gone
                ldx actIndex
                ldy #ACTI_PLAYER
                jsr GetActorDistance
                lda temp6                       ;Wait until player close
                cmp #$04
                bcs HA_Wait
                lda temp5
                sta actD,x
                inc actHp,x
                lda #FR_DUCK+1
                sta actF1,x
                sta actF2,x
                lda #JOY_DOWN
                jsr HA_SetControls
                ldy #ACT_HACKER
                gettext TEXT_AMBUSHFAIL
                jmp SpeakLine
HA_DieAgain:    lda #FR_DIE+2
                sta actF1,x
                sta actF2,x
                dec actHp,x
HA_StopScript:  lda #$00                        ;Stop actor script exec
                sta actScriptF+2
                rts
HA_EnemyDestroyed:
                lda #PLOT_HIDEOUTAMBUSH
                jsr ClearPlotBit
                ldx actIndex
                lda #HP_NONCOMBATANT
                sta actHp,x                     ;Make sure to not allow damage now
                lda #AIMODE_TURNTO
                sta actAIMode,x
                ldy #ACTI_PLAYER
                jsr GetActorDistance
                lda temp6                       ;Wait until close
                cmp #$02
                bcs HA_Wait
                jsr AddQuestScore
                lda #<EP_GIVELAPTOP
                sta actScriptEP+2
                gettext TEXT_AMBUSHSUCCESS
HA_SpeakCommon: ldy #ACT_HACKER
                jmp SpeakLine

        ; Give laptop script (end of ambush)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various
        
GiveLaptop:     lda #$00
                sta actScriptF+2                ;Stop script exec now
                lda #PLOT_HIDEOUTOPEN
                jsr ClearPlotBit                ;Hideout will be closed from now on
                lda #SFX_PICKUP
                jsr PlaySfx
                lda #ITEM_LAPTOP
                ldx #1
                jsr AddItem
                gettext TEXT_AMBUSHLAPTOP
                jmp HA_SpeakCommon

        ; Subnet router script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

DisconnectSubnet:
                jsr AddQuestScore
                lda #SFX_POWERUP
                jsr PlaySfx
                lda #<txtDisconnected
                ldx #>txtDisconnected
                ldy #REQUIREMENT_TEXT_DURATION
                jsr PrintPanelText
                lda lvlObjB+$4d
                bpl DS_NotBoth
                lda lvlObjB+$4e
                bpl DS_NotBoth
                lda codes+MAX_CODES*3-1         ;Make nether tunnel entry possible
                and #$7f
                sta codes+MAX_CODES*3-1
                lda #PLOT_ELEVATOR1
                jmp SetPlotBit
DS_NotBoth:     rts

        ; Server room computer script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ServerRoomComputer:
                if SKIP_PLOT > 0
                lda #$80
                sta lvlObjB+$4d
                sta lvlObjB+$4e
                jsr DisconnectSubnet
                endif
                jsr SetupTextScreen
                lda #0
                sta temp1
                sta temp2
                lda #<txtMasterRouter
                ldx #>txtMasterRouter
                jsr PrintMultipleRows
                lda #10
                sta temp1
                lda #2
                sta temp2
                lda lvlObjB+$4d
                jsr PrintSubnetText
                inc temp2
                lda lvlObjB+$4e
                jsr PrintSubnetText
                ldy #0
                sty temp1
                ldy #5
                sty temp2
                lda #PLOT_ELEVATOR1
                jsr GetPlotBit
                beq SRC_SecurityOn
SRC_SecurityOff:
                lda #<txtProtocolOff
                ldx #>txtProtocolOff
                bne SRC_Common
SRC_SecurityOn:
                lda #<txtProtocolOn
                ldx #>txtProtocolOn
SRC_Common:     jsr PrintMultipleRows
                lda codes+MAX_CODES*3-1
                bmi SRC_NoCode
SRC_ShowCode:   ldx #2
                ldy #4
SRC_CodeLoop:   lda codes+MAX_CODES*3-3,x
                ora #$30
                sta screen1+7*40+26,y
                dey
                dey
                dex
                bpl SRC_CodeLoop
                lda #PLOT_MOVESCIENTISTS
                jsr GetPlotBit
                bne SRC_AlreadyMoved
                lda #<EP_MOVESCIENTISTS
                ldx #>EP_MOVESCIENTISTS
                jsr SetScript
SRC_AlreadyMoved:
SRC_WaitExitCommon:
                jsr WaitForExit
                jmp CenterPlayer
SRC_NoCode:     lda #26
                sta temp1
                lda #7
                sta temp2
                lda #<txtNA
                ldx #>txtNA
                jsr PrintText
                jmp SRC_WaitExitCommon

PrintSubnetText:bmi PST_Isolated
                lda #<txtConnected
                ldx #>txtConnected
                jmp PrintText
PST_Isolated:   lda #<txtIsolated
                ldx #>txtIsolated
                jmp PrintText

        ; Move scientists script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

MoveScientists: jsr StopScript
                jsr AddQuestScore
                lda #PLOT_MOVESCIENTISTS
                jsr SetPlotBit
                ldy lvlDataActBitsStart+$06
                lda lvlStateBits+2,y            ;Forcibly remove the enemies from the
                and #$ff-$04-$08                ;upper labs recycler room (enemy ID's
                sta lvlStateBits+2,y            ;12,13,2c, must not change)
                lda lvlStateBits+5,y
                and #$ff-$10
                sta lvlStateBits+5,y
                lda #ACT_SCIENTIST2             ;Then move the persistent NPCs
                jsr FindLevelActor
                lda #$37
                jsr MoveScientistSub
                lda #ACT_SCIENTIST3
                jsr FindLevelActor
                lda #$36
                jsr MoveScientistSub
                lda #<EP_ESCORTSCIENTISTSSTART
                sta actScriptEP
                lda #>EP_ESCORTSCIENTISTSSTART
                sta actScriptF
                if SKIP_PLOT > 0
                lda #PLOT_ESCORTCOMPLETE
                jsr SetPlotBit
                lda #<EP_FINDFILTER
                ldx #>EP_FINDFILTER
                jmp ExecScript
                endif
                gettext TEXT_RADIOMOVESCIENTISTS
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx

MoveScientistSub:
                sta lvlActX,y
                lda #$13
                sta lvlActY,y
                lda #$20+AIMODE_TURNTO
                sta lvlActF,y
                lda #$06+ORG_GLOBAL
                sta lvlActOrg,y
                rts

        ; Radio briefing on Construct
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioConstruct: lda #PLOT_MOVESCIENTISTS
                jsr GetPlotBit
                beq HP_TryAgain
                lda #<EP_HACKER3                ;Advance Jeff script now
                sta actScriptEP+2
                lda #>EP_HACKER3
                sta actScriptF+2
                gettext TEXT_RADIOCONSTRUCT
                jmp RadioMsg
HP_TryAgain:    ldy lvlObjNum
                jmp InactivateObject

        ; Throne chief corpse
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ThroneChief:    lda #ITEM_BIOMETRICID           ;Todo: cutscene
                sta temp2
                ldx #1
                jsr AddItem
                jsr TP_PrintItemName
SetupAmbush:    lda #<EP_BEGINAMBUSH            ;On next zone transition
                ldx #>EP_BEGINAMBUSH
                jmp SetZoneScript

        ; Find filter script. Also move scientists to final positions before surgery
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

FindFilter:     jsr StopZoneScript
                lda #ACT_SCIENTIST3
                jsr FindLevelActor
                lda #$3f
                ldx #$30+AIMODE_TURNTO
                jsr MoveScientistSub2
                lda #ACT_SCIENTIST2
                jsr FindLevelActor
                lda #$42
                ldx #$00+AIMODE_TURNTO
                jsr MoveScientistSub2
                lda #<EP_BEGINSURGERY
                sta actScriptEP
                lda #>EP_BEGINSURGERY
                sta actScriptF
                jsr SetupAmbush
                gettext TEXT_RADIOFINDFILTER
                jmp RadioMsg
MoveScientistSub2:
                sta lvlActX,y                   ;Set also Y & level so that this can be used as shortcut in testing
                lda #$56
                sta lvlActY,y
                txa
                sta lvlActF,y
                lda #$08+ORG_GLOBAL
                sta lvlActOrg,y
BA_Skip:        rts

        ; Begin hideout ambush
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BeginAmbush:    jsr StopZoneScript
                lda #PLOT_ELEVATOR1             ;No action until elevator fixed and has the biometric ID
                jsr GetPlotBit
                beq BA_Skip
                ldy #ITEM_BIOMETRICID
                jsr FindItem
                bcc BA_Skip
                lda #PLOT_HIDEOUTOPEN           ;Already resolved?
                jsr GetPlotBit
                beq BA_Skip
                lda #PLOT_HIDEOUTAMBUSH         ;Already happening?
                jsr GetPlotBit
                bne BA_Skip
                lda #ACT_HACKER                 ;Check that Jeff is in hideout
                jsr FindLevelActor
                lda lvlActOrg,y
                cmp #$04+ORG_GLOBAL
                bne BA_Skip
                lda #PLOT_HIDEOUTAMBUSH
                jsr SetPlotBit
                ldy lvlDataActBitsStart+$04     ;Enable ambush enemies now
                lda lvlStateBits+2,y
                ora #$c0
                sta lvlStateBits+2,y
                lda lvlStateBits+3,y
                ora #$03
                sta lvlStateBits+3,y
                lda #<EP_HACKERAMBUSH
                sta actScriptEP+2
                lda #>EP_HACKERAMBUSH
                sta actScriptF+2
                lda #<EP_RADIOCONSTRUCT2
                ldx #>EP_RADIOCONSTRUCT2
                jmp SetScript

        ; Radio briefing on Construct, part 2 (when ambush begins)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioConstruct2:jsr StopScript
                gettext TEXT_RADIOCONSTRUCT2
                jmp RadioMsg

        ; Begin surgery script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BeginSurgery:   ldy #ITEM_LUNGFILTER
                jsr FindItem
                bcc BS_NoFilter
                lda actXH+ACTI_PLAYER
                cmp #$44
                bcs BS_NoFilter
                jsr AddQuestScore
                lda #<EP_BEGINSURGERY2
                sta actScriptEP
                lda #$00
                sta scriptVariable
                ldy #ACT_SCIENTIST2
                gettext TEXT_BEGINSURGERY1
                jmp SpeakLine

        ; Begin surgery script, part 2
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BeginSurgery2:  lda actXH+ACTI_PLAYER
                cmp #$41
                bcs BS2_NotYet
                lda actMB+ACTI_PLAYER
                lsr
                bcc BS2_NotYet
                lda scriptVariable
                asl
                tay
                lda bs2JumpTbl,y
                sta BS2_Jump+1
                lda bs2JumpTbl+1,y
                sta BS2_Jump+2
BS2_Jump:       jmp BS2_1

BS2_1:          inc scriptVariable
                ldy #ACT_SCIENTIST2
                gettext TEXT_BEGINSURGERY2
                jmp SpeakLine

BS2_2:          lda #$00                    ;Disabled controls during the delay to simplify scripting
                sta joystick
                lda #ACT_SCIENTIST3
                jsr FindActor
                lda #AIMODE_IDLE
                sta actAIMode,x
                lda #$80
                sta actD,x
                inc actTime,x
                lda actTime,x
                cmp #25
                bcc BS2_2Wait
                lda #$00
                sta actTime,x
                inc scriptVariable
BS2_NotYet:
BS_NoFilter:
BS2_2Wait:      rts

BS2_3:          inc scriptVariable
                lda #ACT_SCIENTIST3
                jsr FindActor
                lda #AIMODE_TURNTO
                sta actAIMode,x
                lda #ITEM_EMPGENERATOR
                sta actWpn,x
                lda #SFX_OBJECT
                jsr PlaySfx
                ldy #ACT_SCIENTIST3
                gettext TEXT_BEGINSURGERY3
                jmp SpeakLine

BS2_4:          jsr BlankScreen
                lda #<EP_AFTERSURGERY
                sta actScriptEP+1
                lda #>EP_AFTERSURGERY
                sta actScriptF+1
                lda #0
                sta actScriptF
                lda #<EP_AFTERSURGERYRUN
                ldx #>EP_AFTERSURGERYRUN
                jsr SetScript
                lda #50
                sta scriptVariable
BS2_Delay:      jsr WaitBottom
                dec scriptVariable
                bne BS2_Delay
                jmp CenterPlayer

bs2JumpTbl:     dc.w BS2_1
                dc.w BS2_2
                dc.w BS2_3
                dc.w BS2_4

        ; After surgery ambush
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgery:   lda scriptVariable
                asl
                tay
                lda asJumpTbl,y
                sta AS_Jump+1
                lda asJumpTbl+1,y
                sta AS_Jump+2
AS_Jump:        jmp $0000

AS_1:           jsr AfterSurgeryRun             ;Ensure player position right when the screen turns on
                ldy #ITEM_LUNGFILTER
                jsr RemoveItem
                lda upgrade
                ora #UPG_TOXINFILTER
                sta upgrade                     ;Has the filter upgrade now
                lda #HP_PLAYER                  ;Always full HP + at least minimal battery, as there will
                sta actHp+ACTI_PLAYER           ;be battery drain
                lda battery+1
                cmp #LOW_BATTERY
                bcs AS_1BatteryOK
                lda #LOW_BATTERY
                sta battery+1
AS_1BatteryOK:  jsr AddQuestScore
                inc scriptVariable
                ldy #ACT_SCIENTIST2
                gettext TEXT_AFTERSURGERY1
                jmp SpeakLine

AS_2:           jsr Random
                and #$01
                sta shakeScreen
                jsr Random
                cmp #$10
                bcs AS_2NoExplosion
                jsr HeavyShake
AS_2NoExplosion:lda #ACT_SCIENTIST3
                jsr FindActor
                inc actTime,x
                lda actTime,x
                cmp #50
                bcc AS_2Wait
                inc scriptVariable
AS_2Wait:       rts

HeavyShake:     lda #$02
                sta shakeScreen
                lda #SFX_EXPLOSION
                jmp PlaySfx

AS_3:           inc scriptVariable
                ldy #ACT_SCIENTIST3
                gettext TEXT_AFTERSURGERY2
                jmp SpeakLine

AS_4:           lda #ACT_HIGHWALKER
                jsr FindLevelActor
                lda lvlActY,y                   ;Unhide waiting enemy now
                and #$7f
                sta lvlActY,y
                jsr GetLevelActorIndex
                lda #$38
                sta lvlActX,y
                lda #$3c
                sta lvlActY,y
                lda #ACT_COMBATROBOTSABOTEUR
                sta lvlActT,y
                lda #$10+AIMODE_IDLE
                sta lvlActF,y
                lda #$00
                sta lvlActWpn,y
                lda #$08+ORG_GLOBAL
                sta lvlActOrg,y                 ;Create saboteur enemy
                inc scriptVariable
                lda #ACT_SCIENTIST2
                jsr FindActor
                lda #AIMODE_IDLE
                sta actAIMode,x
                lda #$00
                sta actMoveCtrl,x
                sta actTime,x
                sta actD,x
                lda #HP_SCIENTIST2              ;Make possible to die
                sta actHp,x
                lda #MUSIC_MYSTERY+1
                jsr PlaySong
                jmp HeavyShake                  ;One more shake + explosion as walker appears

AS_5:           lda #ACT_HIGHWALKER
                jsr FindActor
                bcc AS_5Wait
                lda actXH,x
                pha
                lda #ACT_SCIENTIST2
                jsr FindActor
                pla
                ldy actHp,x
                beq AS_5Dead
                cmp #$46
                bcs AS_5Shake
                inc actTime,x
                lda actTime,x
                cmp #8
                bcc AS_5RunRight
                bcs AS_5RunLeft
AS_5Shake:      lda AA_ItemFlashCounter+1       ;Shake screen until walker visibly onscreen
                asl
                and #$02
                sta shakeScreen
                rts
AS_5RunRight:   lda #JOY_RIGHT
                skip2
AS_5RunLeft:    lda #JOY_LEFT
                sta actMoveCtrl,x
                rts
AS_5Dead:       lda #75                         ;Make the corpse stay slightly longer
                sta actTime,x
                lda #ACT_SCIENTIST3
                jsr FindActor                   ;Linda uses EMP to destroy (2 shots needed)
                lda #AIMODE_SNIPER
                sta actAIMode,x
                inc scriptVariable
AS_6Wait:
AS_5Wait:       rts

AS_6:           lda #ACT_HIGHWALKER
                jsr FindActor
                bcs AS_6Wait
                lda #ACT_EXPLOSIONGENERATORRISING
                jsr FindActor
                bcs AS_6Wait
                inc scriptVariable
                ldy #ACT_SCIENTIST3
                gettext TEXT_AFTERSURGERY3
                jmp SpeakLine

AS_7:           ldx #ACTI_PLAYER                ;Player regains control
                lda #-9*8
                jsr MoveActorX
                lda #8*8
                jsr MoveActorY
                jsr NoInterpolation
                jsr StopScript
                lda #FR_STAND
                sta actF1+ACTI_PLAYER
                sta actF2+ACTI_PLAYER
                inc scriptVariable
AS_8Wait:       rts

AS_8:           lda actXH+ACTI_PLAYER
                cmp #$40
                beq AS_8Wait
                lda #<EP_AFTERSURGERYFOLLOW   ;Change to following script
                sta actScriptEP+1
                ldy #ACT_SCIENTIST3
                gettext TEXT_AFTERSURGERY4
                jmp SpeakLine

asJumpTbl:      dc.w AS_1
                dc.w AS_2
                dc.w AS_3
                dc.w AS_4
                dc.w AS_5
                dc.w AS_6
                dc.w AS_7
                dc.w AS_8

        ; After surgery continuous script, keep player in place
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgeryRun:lda joystick
                and #JOY_FIRE                   ;Fire must be possible to advance dialogue
                sta joystick
                lda #$00
                sta actXL+ACTI_PLAYER
                sta actD+ACTI_PLAYER
                sta actSY+ACTI_PLAYER
                lda #FR_DIE+2
                sta actF1+ACTI_PLAYER
                sta actF2+ACTI_PLAYER
                lda #$58
                sta actYL+ACTI_PLAYER
                lda #$41
                sta actXH+ACTI_PLAYER
                lda #$55
                sta actYH+ACTI_PLAYER
ASZ_AlreadySet: rts

        ; After surgery zone script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgeryZone:
                lda levelNum
                cmp #$0f                        ;Reached old tunnels?
                beq ASZ_Survived
                cmp #$08
                bne ASZ_Stop
                lda #ACT_SCIENTIST3
                jsr TransportNPCToPlayer
                lda #PLOT_LOWERLABSNOAIR
                jsr GetPlotBit
                bne ASZ_AlreadySet
                lda #$00
                sta UA_SpawnDelay+1             ;Wait a bit before next dialogue, ensure
                lda #<EP_AFTERSURGERYNOAIR      ;no enemy spawn in the meanwhile
                sta actScriptEP+1
                if SKIP_PLOT > 0
                lda #PLOT_ELEVATOR1
                jsr SetPlotBit
                endif
                lda #PLOT_LOWERLABSNOAIR
                jmp SetPlotBit
ASZ_Survived:   jsr AddQuestScore
                lda #ACT_SCIENTIST3             ;Todo: continue story from here
                jsr TransportNPCToPlayer
                lda #<EP_REACHOLDTUNNELS
                sta actScriptEP+1
                lda #>EP_REACHOLDTUNNELS
                sta actScriptF+1
ASZ_Stop:       jmp StopZoneScript              ;No zone script for now

        ; After surgery follow script (refresh follow mode & zone script)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgeryFollow:
                ldx actIndex
                lda oxygen              ;Die if run out of oxygen,
                beq ASF_Die             ;or if player goes to nether tunnel entrance
                lda actXH+ACTI_PLAYER   ;or to the corridor (avoid elevator script load thrashing)
                clc
                adc actYH+ACTI_PLAYER
                cmp #$6e+$54
                bcs ASF_Die
                cmp #$4a+$42
                bcc ASF_Die
                lda actMB,x             ;Do not follow again until landed
                lsr
                bcc ASF_NoFollow
                lda actXH,x             ;Scripted jump to access the old tunnels
                cmp #$65
                bne ASF_NoJump
                lda actYH,x
                cmp #$4a
                bne ASF_NoJump
                lda actSX,x
                bmi ASF_NoJump
                lda #AIMODE_IDLE
                sta actAIMode,x
                lda #JOY_RIGHT|JOY_UP  ;Jump as far as possible
                sta actMoveCtrl,x
                lda #-6*8+4
                sta actSY,x
                jmp MH_JumpNoPlayer
ASF_NoJump:     lda #AIMODE_FOLLOW
                sta actAIMode,x
                lda #ACTI_PLAYER
                sta actAITarget,x
ASF_NoFollow:   lda #<EP_AFTERSURGERYZONE
                ldx #>EP_AFTERSURGERYZONE
                jmp SetZoneScript
ASF_Die:        ldx actIndex
                lda #AIMODE_IDLE
                sta actAIMode,x
                lda #JOY_DOWN
                sta actMoveCtrl,x
                lda #75
                sta actTime,x
                lda actSX,x                 ;Wait for zero X-speed for the speech bubble
                bne ASF_DieWait
                jsr StopZoneScript
                lda #<EP_AFTERSURGERYNOAIRDIE
                sta actScriptEP+1
ASF_DieTellCode:gettext TEXT_NOAIRCODE
                sta zpSrcLo
                stx zpSrcHi
                ldy #$02
ASF_DTCLoop:    lda codes+MAX_CODES*3-3,y
                if SKIP_PLOT > 0
                and #$7f
                sta codes+MAX_CODES*3-3,y   ;Unscramble code forcibly now (for testing)
                endif
                ora #$30
                sta (zpSrcLo),y
                dey
                bpl ASF_DTCLoop
                ldx actIndex                ;Drop EMP generator now
                lda #ITEM_NONE
                sta actWpn,x
                lda #-15*8
                sta temp4
                lda #ITEM_EMPGENERATOR
                jsr DI_ItemNumber
                ldy #ACT_SCIENTIST3
                gettext TEXT_NOAIRDIE
                jmp SpeakLine
ASF_DieWait:    rts

        ; After surgery "no air" dialogue
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgeryNoAir:
                ldx actIndex                    ;Stay in place until dialogue
                lda #AIMODE_TURNTO              ;so that speech bubble doesn't levitate
                sta actAIMode,x
                lda oxygen                      ;Let player notice first
                cmp #MAX_OXYGEN-5
                bcs ASNA_Wait
                lda #ACT_HACKER
                jsr FindLevelActor
                bcc ASNA_JeffDead
                lda #<EP_AFTERSURGERYNOAIRRADIO ;Radio transmission if Jeff alive
                skip2
ASNA_JeffDead:  lda #<EP_AFTERSURGERYFOLLOW     ;Restore follow script again
                sta actScriptEP+1
                ldy #ACT_SCIENTIST3
                gettext TEXT_NOAIR
                jmp SpeakLine
ASNAD_NotRemoved:
ASNA_Wait:      rts

        ; NPC death when running out of oxygen
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgeryNoAirDie:
                ldx actIndex
                jsr SetNotPersistent
                lda #JOY_DOWN
                sta actMoveCtrl,x
                jmp DeathFlickerAndRemove

        ; Jeff's radio transmission about the air shortage
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgeryNoAirRadio:
                lda #<EP_AFTERSURGERYFOLLOW
                sta actScriptEP+1
                gettext TEXT_RADIONOAIR
                jmp RadioMsg

        ; Escaped to old tunnels
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ReachOldTunnels:
                ldx actIndex
                lda actXH,x
                cmp #$03
                bcc ROT_Run
                lda #AIMODE_TURNTO
                sta actAIMode,x
                lda actSX,x                     ;Wait for stop so that speech bubble isn't off
                bne ROT_Wait
                gettext TEXT_NOAIRSUCCESS
ROT_SpeakAndStopScript:
                ldy #$00
                sty actScriptF+1                ;Stop script for now
                ldy #ACT_SCIENTIST3
                jmp SpeakLine
ROT_Run:        lda #AIMODE_IDLE
                sta actAIMode,x
                lda #JOY_RIGHT
                sta actMoveCtrl,x
ROT_Wait:       rts

        ; Messages

txtDisconnected:dc.b "SUBNET "
txtIsolated:    dc.b "ISOLATED",0

txtMasterRouter:dc.b "LOWER LABS MASTER ROUTER STATION",0
                dc.b " ",0
                dc.b "SUBNET 1:",0
                dc.b "SUBNET 2:",0
                dc.b " ",0
                dc.b " ",0
                dc.b " ",0
                dc.b "NETHER TUNNEL ENTRY CODE:",0,0

txtConnected:   dc.b "CONNECTED",0
txtProtocolOn:  dc.b "CONSTRUCT SECURITY PROTOCOL ENGAGED",0
                dc.b "ELEVATOR LOCKED DOWN",0,0

txtProtocolOff: dc.b "SECURITY PROTOCOL OFF",0
                dc.b "ELEVATOR UNLOCKED",0,
txtNA:          dc.b "N/A",0

                checkscriptend

