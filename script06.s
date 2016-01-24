                include macros.s
                include mainsym.s

elevatorSound   = toxinDelay

        ; Script 6, elevators + NPC following code

                org scriptCodeStart

                dc.w Elevator
                dc.w ElevatorLoop
                dc.w RadioUpperLabsElevator
                dc.w RadioServicePass
                dc.w EscortScientistsRefresh
                dc.w EscortScientistsZone
                dc.w HackerFollow
                dc.w HackerFollowZone

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
                lda lvlObjB+$2b                 ;No message if wall already opened with the laser
                bmi E_NoRadioMsg
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
                
        ; Radio speech for upper labs elevator
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioUpperLabsElevator:
                lda textTime
                cmp #35
                bcs RULE_Wait
                ldy #ITEM_AMPLIFIER
                jsr FindItem
                bcs RULE_HasAmplifier
                lda #<EP_RADIOSECURITYPASS
                ldx #>EP_RADIOSECURITYPASS
                jsr SetScript
                gettext txtRadioElevatorLocked
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx
RSP_HasItem:
ESS_WaitUntilClose:
RULE_Wait:      rts
RULE_HasAmplifier:
                jsr StopScript
                gettext txtRadioElevatorLockedHasAmplifier
                jmp RadioMsg

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
                gettext txtRadioServicePass
                jmp SpeakLine

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
ESR_HasGoal:    lda #<EP_RADIOFINDFILTER
                ldx #>EP_RADIOFINDFILTER
                jsr SetZoneScript
                lda #<EP_ESCORTSCIENTISTSFINISH
                ldx #>EP_ESCORTSCIENTISTSFINISH
                sta actScriptEP
                stx actScriptF
                sta actScriptEP+1
                stx actScriptF+1
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
                ldx #>EP_HACKERFOLLOWFINISH
                sta actScriptEP+2
                stx actScriptF+2
HFZ_LevelFail:  jmp StopZoneScript              ;No zone script

        ; Variables

elevatorIndex:  dc.b 0
elevatorTime:   dc.b 0

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

        ; Messages

txtElevatorLocked:
                dc.b "ELEVATOR "
                textjump txtLocked

txtRadioElevatorLocked:
                dc.b 34,"AMOS HERE AGAIN. YOU NEED A WAY AROUND. "
                dc.b "THE LASER IN THE BASEMENT MIGHT CUT THROUGH THE WALL, IF ITS POWER IS BOOSTED. "
                dc.b "OUR IT SPECIALIST JEFF COULD HAVE IDEAS. HE'S GOT A PRIVATE HIDEOUT "
                dc.b "IN THE SERVICE TUNNELS. JUST WATCH OUT, HE'S A BIT STRANGE.",34,0

txtRadioServicePass:
                dc.b 34,"SEARCH THE ENTRANCE OFFICES FOR THE SERVICE PASS.",34,0

txtRadioElevatorLockedHasAmplifier:
                dc.b 34,"AMOS HERE. TRY USING THE AMPLIFIER YOU GOT ON THE LASER. BOOSTED, IT MIGHT BREACH THE WALL.",34,0

                checkscriptend
