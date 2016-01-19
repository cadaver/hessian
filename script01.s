                include macros.s
                include mainsym.s

numberIndex     = menuCounter
elevatorSound   = toxinDelay

        ; Script 1: common objects

                org scriptCodeStart

                dc.w UseHealthRecharger
                dc.w UseBatteryRecharger
                dc.w RechargerEffect
                dc.w EnterCode
                dc.w EnterCodeLoop
                dc.w Elevator
                dc.w ElevatorLoop
                dc.w RadioUpperLabsElevator
                dc.w RadioServicePass
                dc.w EscortScientistsStart
                dc.w EscortScientistsRefresh
                dc.w EscortScientistsZone
                dc.w EscortScientistsFinish
                dc.w HackerFollow
                dc.w HackerFollowZone
                dc.w RadioSecurityCenter
                dc.w CombatRobotSaboteur
                dc.w DestroyCombatRobotSaboteur

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
UHR_Full:
UBR_Full:       rts

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
E_NoAccess:     txa                             ;Only show message for the upper labs elevator, and only once
                bne E_NoRadioMsg
                lda #PLOT_ELEVATORMSG
                jsr GetPlotBit
                bne E_NoRadioMsg
                lda #PLOT_ELEVATORMSG
                jsr SetPlotBit
                lda #<EP_RADIOUPPERLABSELEVATOR ;Set a timed script, exec when text cleared
                ldx #>EP_RADIOUPPERLABSELEVATOR
                jsr SetScript
E_NoRadioMsg:   lda #<txtElevatorLocked
                ldx #>txtElevatorLocked
                ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText
E_HasAccess:    stx elevatorIndex
                lda #$00
                sta elevatorTime
                sta elevatorSound
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
                inc elevatorSound
                lda elevatorSound
                cmp #$03
                bcc EL_NoSound
                lda #SFX_GENERATOR
                jsr PlaySfx
                lda #$00
                sta elevatorSound
EL_NoSound:     lda charInfo-1                  ;Accelerate until full speed
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

EnterCode:      lda #0
                ldx #2
EC_Reset:       sta codeEntry,x
                dex
                bpl EC_Reset
                lda #<EP_ENTERCODELOOP
                ldx #>EP_ENTERCODELOOP
                jsr SetScript
                ldx #MENU_INTERACTION
                jmp SetMenuMode

        ; Enter keypad code interaction loop
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EnterCodeLoop:  lda #<txtEnterCode
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
CheckForExit:   lda joystick
                and #JOY_DOWN
                bne ECL_Finish
                lda keyType
                bpl ECL_Finish
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
                ldx #MAX_CODES-1
ECL_Verify:     lda lvlObjNum
                cmp codeObject,x                ;All object numbers for code doors are unique, don't
                beq ECL_VerifyFound             ;need to check level
                dex
                bpl ECL_Verify                  ;This should never exit the loop
ECL_VerifyFound:txa
                sta temp1
                asl
                adc temp1
                tay
                ldx #$00
ECL_VerifyLoop: lda codeEntry,x
                cmp codes,y
                bne ECL_Finish
                iny
                inx
                cpx #$03
                bcc ECL_VerifyLoop
                jsr OO_RequirementOK            ;Open the door if code right
ECL_Finish:     jsr StopScript
                jmp SetMenuMode                 ;X=0 on return

        ; Radio speech for upper labs elevator
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioUpperLabsElevator:
                lda textTime
                cmp #35
                bcs RULE_Wait
                lda #<EP_RADIOSECURITYPASS
                ldx #>EP_RADIOSECURITYPASS
                jsr SetScript
                lda #<txtRadioUpperLabsElevator
                ldx #>txtRadioUpperLabsElevator
RadioSpeechCommon:
                pha
                lda #SFX_RADIO
                jsr PlaySfx
                pla
                ldy #ACT_PLAYER
                jmp SpeakLine
RSP_HasItem:
RULE_Wait:      rts

        ; Speech end part (search for service pass, if necessary)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioServicePass:
                lda textTime
                bne RULE_Wait
                jsr StopScript
                ldy #ITEM_SERVICEPASS
                jsr FindItem
                bcs RSP_HasItem
                ldy #ACT_PLAYER
                lda #<txtRadioServicePass
                ldx #>txtRadioServicePass
                jmp SpeakLine

        ; Start escort scientists sequence
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EscortScientistsStart:
                ldx actIndex
                lda actXH,x
                sec
                sbc actXH+ACTI_PLAYER
                cmp #$04
                bcs ESS_WaitUntilClose
                jsr AddQuestScore
                ldy #ACT_SCIENTIST2
                lda #<txtEscortBegin
                ldx #>txtEscortBegin
                jsr SpeakLine
                lda #<EP_ESCORTSCIENTISTSREFRESH
                sta actScriptEP
                sta actScriptEP+1
                lda #>EP_ESCORTSCIENTISTSREFRESH
                sta actScriptF
                sta actScriptF+1
ESS_WaitUntilClose:
                rts

        ; Refresh escort scientists sequence (ensure they follow)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EscortScientistsRefresh:
                lda #<EP_ESCORTSCIENTISTSZONE   ;Set zone script which keeps the scientists
                ldx #>EP_ESCORTSCIENTISTSZONE   ;warping to player
                jsr SetZoneScript
                ldx actIndex
                lda #AIMODE_FOLLOW
                sta actAIMode,x
                lda actT,x
                cmp #ACT_SCIENTIST3
                beq ESR_FollowPlayer
                lda #ACT_SCIENTIST3
                jsr FindActor
                bcc ESR_NoActor
                txa
                ldx actIndex
ESR_StoreTarget:sta actAITarget,x
ESR_InDialogue:
ESR_NoActor:    rts
ESR_FollowPlayer:
                lda actYH,x                     ;Check for reaching the operation room
                cmp #$56
                bne ESR_NoGoal
                lda actXH,x
                cmp #$4f
                beq ESR_HasGoal
ESR_NoGoal:     lda #ACTI_PLAYER
                beq ESR_StoreTarget
ESR_HasGoal:    lda #<EP_FINDFILTER
                ldx #>EP_FINDFILTER
                jsr SetZoneScript
                lda #<EP_ESCORTSCIENTISTSFINISH
                sta actScriptEP
                sta actScriptEP+1
                lda actScriptF+2
                bne ESR_SkipJeffScript
                lda #<EP_HACKER4                ;Reset Jeff script now that old tunnels trip is possible again
                sta actScriptEP+2               ;but not if player didn't visit him in the meanwhile
                lda #>EP_HACKER4
                sta actScriptF+2
ESR_SkipJeffScript:
                jsr AddQuestScore
                lda #PLOT_ESCORTCOMPLETE
                jmp SetPlotBit

        ; Escort scientists zone change (warp to player)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EscortScientistsZone:
                lda ECS_LoadedCharSet+1
                cmp #$07
                beq ESZ_LevelFail               ;Do not go inside upgrade research labs
                lda levelNum
                cmp #$06
                beq ESZ_LevelOk
                cmp #$08
                bne ESZ_LevelFail
                lda actXH+ACTI_PLAYER
                cmp #$1e                        ;Check X range in lower labs, don't allow going to the left side (wrong direction)
                bcc ESZ_LevelFail               ;or far right (contains acid and nether tunnels entry)
                cmp #$5a
                bcc ESZ_LevelOk
ESZ_LevelFail:  jmp StopZoneScript              ;Ventured outside valid levels for following, stop
ESZ_LevelOk:    lda #ACT_SCIENTIST2
                jsr TransportNPCToPlayer
                lda #ACT_SCIENTIST3
                jmp TransportNPCToPlayer

        ; Escort scientists sequence finish
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EscortScientistsFinish:
                ldx actIndex
                ldy actT,x
                lda npcBrakeTbl-ACT_FIRSTPERSISTENTNPC,y
                jsr BrakeActorX  ;Move at slightly different speed to not look stupid
                lda actXH,x
                cmp npcStopPos-ACT_FIRSTPERSISTENTNPC,y
                bcc ESF_Stop
                lda #JOY_LEFT
                sta actMoveCtrl,x
                lda #AIMODE_IDLE
                beq ESF_StoreMode
ESF_Stop:       cpy #ACT_SCIENTIST3
                bne ESF_NoDialogue
                lda actSX,x
                bne ESF_NoDialogue
                lda #$00                        ;Stop actor script exec for now
                sta actScriptF
                sta actScriptF+1
                ldy #ACT_SCIENTIST2
                lda #<txtEscortFinish
                ldx #>txtEscortFinish
                jmp SpeakLine
ESF_NoDialogue: lda #AIMODE_TURNTO
ESF_StoreMode:  sta actAIMode,x
                rts

        ; To old tunnels follow script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HF_Climbing:    jmp HF_NoJump
HackerFollow:   ldx actIndex
                lda actF1,x             ;Climbing = normal following
                cmp #FR_CLIMB
                bcs HF_Climbing
                lda actMB,x             ;Do not follow again until landed
                lsr
                bcs HF_NotInAir
                lda actSY,x
                bpl HF_Landing
                jmp HF_NoFollow
HF_Landing:     lda actMoveCtrl,x       ;Clear jump control when landing
                and #$7f-JOY_UP
                bpl HF_StoreMoveCtrl
HF_NotInAir:    lda ECS_LoadedCharSet+1 ;Try to jump over pits in service tunnels
                cmp #$05
                bne HF_NoChasmJump

                ldy actYH,x             ;Get block from current position
                lda mapTblLo,y
                sta zpDestLo
                lda mapTblHi,y
                sta zpDestHi
                ldy actXH,x
                lda (zpDestLo),y

                cmp #109
                beq HF_ChasmRight
                cmp #156
                beq HF_ChasmRight
                cmp #110
                beq HF_ChasmLeft
                cmp #157
                bne HF_NoJump
HF_ChasmLeft:   lda actSX,x
                bpl HF_NoJump
                cmp #-2*8
                bcs HF_NoJump
                lda actXL,x
                bmi HF_NoJump
                bpl HF_DoJump
HF_ChasmRight:  lda actSX,x
                bmi HF_NoJump
                cmp #2*8
                bcc HF_NoJump
                lda actXL,x
                bpl HF_NoJump
                bmi HF_DoJump
HF_NoChasmJump: lda levelNum
                cmp #$08
                bne HF_NoJump
                lda actXH,x             ;Scripted jump to access the old tunnels
                cmp #$65                ;(in level8)
                bne HF_NoJump
                lda actYH,x
                cmp #$4a
                bne HF_NoJump
                lda actSX,x
                bmi HF_NoJump
HF_DoJump:      lda actMoveCtrl,x
                ora #JOY_UP  ;Jump as far as possible
HF_StoreMoveCtrl:
                sta actMoveCtrl,x
                lda #AIMODE_IDLE
                sta actAIMode,x
                rts
HF_NoJump:      lda #ACT_FIRE           ;If standing next to a fire, put it out
                jsr FindActor
                bcc HF_NoFire
                txa
                tay
                ldx actIndex
                lda actYH,y
                cmp actYH,x
                bne HF_NoFire
                lda actXH,y
                sbc actXH,x             ;C=1
                cmp #$01
                beq HF_FireRight
                cmp #$ff
                bne HF_NoFire
HF_FireLeft:    lda actXL,x
                bmi HF_NoFire           ;Must be standing at block left edge
                lda #JOY_FIRE|JOY_DOWN|JOY_LEFT
HF_FireCommon:  pha
                lda #ITEM_EXTINGUISHER
                sta actWpn,x
                pla
                sta actCtrl,x
                lda #$00
                beq HF_StoreMoveCtrl
HF_FireRight:   lda actXL,x             ;Must be standing at block right edge
                bpl HF_NoFire
                lda #JOY_FIRE|JOY_DOWN|JOY_RIGHT
                bne HF_FireCommon
HF_NoFire:      ldx actIndex
                lda #AIMODE_FOLLOW
                sta actAIMode,x
                lda #ACTI_PLAYER
                sta actAITarget,x
                lda #$00
                sta actWpn,x
                sta actCtrl,x
HF_NoFollow:    lda #<EP_HACKERFOLLOWZONE
                ldx #>EP_HACKERFOLLOWZONE
                jmp SetZoneScript

        ; To old tunnels follow zone script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerFollowZone:
                lda levelNum
                cmp #$0f                        ;Success condition
                beq HFZ_Finished
                cmp #$0a                        ;Do not go to nether tunnel
                beq HFZ_LevelFail
                lsr
                bcc HFZ_LevelOK
                cmp #$02                        ;Do go to odd-numbered levels 5,7,9,11 (caves, security centers, 2nd courtyard)
                bcs HFZ_LevelFail
HFZ_LevelOK:    lda #ACT_HACKER
                jmp TransportNPCToPlayer
HFZ_Finished:   jsr HFZ_LevelOK
                jsr AddQuestScore
                lda #<EP_HACKERFOLLOWFINISH
                sta actScriptEP+2
                lda #>EP_HACKERFOLLOWFINISH
                sta actScriptF+2
HFZ_LevelFail:  jmp StopZoneScript              ;No zone script

        ; Radio speech when entering security center
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioSecurityCenter:
                lda #PLOT_ELEVATOR1             ;If lower labs already visited/completed, skip this
                jsr GetPlotBit
                bne RSC_Skip
                lda #<txtRadioSecurityCenter
                ldx #>txtRadioSecurityCenter
                jmp RadioSpeechCommon
RSC_Skip:       rts

        ; Saboteur robot
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

CombatRobotSaboteur:
                lda #FR_ATTACK+3
                sta actF2,x
                lda #FR_STAND
                sta actF1,x
                jsr Random
                and #$08
                sta temp1
                lda actXL,x
                and #$f0
                ora temp1
                sta actXL,x
                jsr Random
                and #$1f
                clc
                adc actTime,x
                sta actTime,x
                bcc CRS_NoEffect
                lda #ACTI_FIRSTNPCBULLET
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc CRS_NoEffect
                lda #ACT_EMP
                jsr SpawnActor
                tya
                tax
                lda #8*8
                jsr MoveActorX
                lda #8*8
                jsr MoveActorY
                dec actYH,x
                lda #COLOR_FLICKER
                sta actFlash,x
                lda #8
                sta actTime,x
                lda #0
                sta actBulletDmgMod-ACTI_FIRSTPLRBULLET,x ;Make sure the EMP doesn't do actual damage to anyone
                ldx actIndex
CRS_NoEffect:   rts

        ; Saboteur robot death
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

DestroyCombatRobotSaboteur:
                lda #PLOT_LOWERLABSNOAIR        ;Make lower labs safe again
                jsr ClearPlotBit
                lda #$00
                sta ULO_NoAirFlag+1
                stx temp6
                lda #MUSIC_MYSTERY              ;Restore original music
                jsr PlaySong
                ldx temp6
                jmp ExplodeEnemy3_Ofs24

        ; Elevator tables

elevatorSrcLevel:
                dc.b $06,$08,$0a,$0b
elevatorDestLevel:
                dc.b $08,$06,$0b,$0a
elevatorDestObject:
                dc.b $43,$3e,$0f,$39
elevatorPlotBit:
                dc.b PLOT_ELEVATOR1,PLOT_ELEVATOR1,PLOT_ELEVATOR2,PLOT_ELEVATOR2
elevatorSpeed:  dc.b 48,-48,-64,64
elevatorAcc:    dc.b 2,-2,-2,2

        ; Code entry tables

codeObject:     dc.b $12,$29,$27,$16,$26,$22,$08,$31

npcStopPos:     dc.b $4e,$4d
npcBrakeTbl:    dc.b 4,0

        ; Variables

elevatorIndex:  dc.b 0
elevatorTime:   dc.b 0
rechargerColor: dc.b 0

        ; Messages

txtHealthRecharger:
                dc.b "HEALTH RESTORED",0
txtBatteryRecharger:
                dc.b "BATTERY RECHARGED",0
txtElevatorLocked:
                dc.b "ELEVATOR "
                textjump txtLocked
txtEnterCode:   dc.b "ENTER CODE",0

txtRadioUpperLabsElevator:
                dc.b 34,"AMOS HERE AGAIN. YOU NEED A WAY AROUND. "
                dc.b "THE LASER IN THE BASEMENT MIGHT CUT THROUGH THE WALL IF ITS POWER IS BOOSTED. "
                dc.b "OUR IT SPECIALIST JEFF COULD HAVE IDEAS. HE'S GOT A PRIVATE HIDEOUT "
                dc.b "IN THE SERVICE TUNNELS. JUST WATCH OUT, HE'S A BIT STRANGE.",34,0
txtRadioServicePass:
                dc.b 34,"SEARCH THE ENTRANCE OFFICES FOR THE SERVICE PASS.",34,0
txtEscortBegin: dc.b 34,"THERE YOU ARE. THE PLAN IS THIS: YOU'LL NEED A LUNG FILTER TO SURVIVE THE TUNNELS. THE OPERATING ROOM IS ON THE LOWER LABS "
                dc.b "RIGHT SIDE, AT THE VERY BOTTOM. LEAD THE WAY.",34,0
txtEscortFinish:dc.b 34,"WE'D NEVER HAVE MADE IT ALONE. NOW WE NEED TO SET UP. WE'LL CALL YOU WHEN IT'S TIME.",34,0
txtRadioSecurityCenter:
                dc.b 34,"AMOS HERE. GOOD THINKING, THE ARMORY SHOULD HOLD POWERFUL WEAPONRY. STAY ALERT THOUGH, "
                dc.b "ANY GUARDS INSIDE MAY THINK YOU'VE GONE ROGUE. OR THE WORSE POSSIBILITY, THAT THEY'RE SOMEHOW "
                dc.b "COMPLICIT.",34,0

                checkscriptend