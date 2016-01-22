                include macros.s
                include mainsym.s

        ; Script 5, Bio-Dome + other late game scripts

                org scriptCodeStart

                dc.w MoveSecurityChief
                dc.w DestroySecurityChief
                dc.w SecurityChiefSpeech
                dc.w EnterBioDome
                dc.w BioDomeEnding
                dc.w InstallLaptop
                dc.w InstallLaptopWork
                dc.w InstallLaptopFinish
                dc.w HackerFollowFinish
                dc.w EnterLab
                dc.w HackerEnterLab
                dc.w LabComputer
                dc.w GiveLaptop2
                dc.w ScientistEnterLab
                dc.w Hazmat
                dc.w HazmatLeave
                dc.w DestroyComment
                dc.w HackerFinal
                dc.w TunnelMachine
                dc.w TunnelMachineItems
                dc.w TunnelMachineRun
                dc.w RadioJormungandr
                dc.w RadioJormungandrRun
                dc.w DestroyPlan
                dc.w MoveLargeTank
                dc.w MoveFireball

        ; Security chief move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveSecurityChief:
                ldy #C_SECURITYCHIEF
                jsr EnsureSpriteFile
                lda menuMode                    ;Wait for dialogue
                bne MSC_Wait
                lda lvlObjB+$17                 ;Wait if trigger not activated
                bpl MSC_Wait
                lda actF1,x
                cmp #FR_DIE
                bcs MSC_Dead
                lda actHp,x                     ;Set health for battle
                bne MSC_HasHealth
                lda #HP_SECURITYCHIEF
                sta actHp,x
MSC_HasHealth:  cmp #HP_SECURITYCHIEF/2         ;Switch to grenade launcher at half health
                bcs MSC_NoWeaponChange
                lda actTime,x
                bmi MSC_NoWeaponChange
                lda actAttackD,x
                bne MSC_NoWeaponChange
                lda #ITEM_GRENADELAUNCHER
                sta actWpn,x
MSC_NoWeaponChange:
                lda #MUSIC_THRONE+1             ;Play the bossfight music
                jsr PlaySong
                ldx actIndex
MSC_Dead:
MSC_Move:       jmp MoveAndAttackHuman
MSC_Wait:       lda #$00
                sta actHp,x                     ;Make a nontarget until speech over
                sta actCtrl,x
                sta actMoveCtrl,x
                beq MSC_Move

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

EnsureSpriteFile:
                lda fileHi,y
                bne ESF_InMemory
                jmp LoadSpriteFile

        ; Trigger script when entering Bio-Dome
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EnterBioDome:   lda #PLOT_ELEVATOR2             ;Travelled too far while the comms disruption was going on?
                jsr GetPlotBit
                bne EBD_TriggerEnding
                lda #ACT_HACKER
                jsr FindLevelActor
                bcc EBD_Skip
                sty temp1
                lda lvlActOrg,y                 ;Check Jeff's location
                cmp #$0f+ORG_GLOBAL             ;In old tunnels (=safe)?
                beq EBD_Skip
                cmp #$04+ORG_GLOBAL             ;In hideout? If not, abandoned and killed offscreen
                bne EBD_DieAbandoned
                lda #PLOT_HIDEOUTAMBUSH         ;Hideout is unsafe if ambush unresolved
                jsr GetPlotBit
                bne EBD_DieAmbush
ESF_InMemory:
EBD_Skip:       rts
EBD_DieAmbush:  jsr EBD_KillHackerCommon
                gettext TEXT_RADIOAMBUSHFAIL
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx

EBD_DieAbandoned:
                jsr EBD_KillHackerCommon
                gettext TEXT_RADIOABANDONED
                jmp RadioMsg
EBD_KillHackerCommon:
                ldy temp1
                lda #ACT_NONE
                sta lvlActT,y                   ;Just remove from gameworld
EBD_AlreadyTriggered:
                rts
EBD_TriggerEnding:
                lda scriptF
                bne EBD_AlreadyTriggered
                lda #<EP_BIODOMEENDING
                ldx #>EP_BIODOMEENDING
                jsr SetScript
                gettext TEXT_RADIOTRIGGEREND
                jmp RadioMsg

        ; Biodome trigger ending
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BioDomeEnding:  lda textTime                    ;Wait until radio message text has been read
                bne EBD_AlreadyTriggered
                lda #<EP_ENDING1
                ldx #>EP_ENDING1
                jmp ExecScript

        ; Security chief speech
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

SecurityChiefSpeech:
                ldy #ACT_SECURITYCHIEF
                gettext TEXT_SECURITYCHIEF
                jmp SpeakLine

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
                jsr RemoveItem
                jsr AddQuestScore
                lda #PLOT_DISRUPTCOMMS
                jsr SetPlotBit
                lda #<EP_HACKERFINAL
                sta actScriptEP+2
                lda #>EP_HACKERFINAL
                sta actScriptF+2
                lda #$00
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
                gettext TEXT_RADIOINSTALLLAPTOP
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
ILW_VariationA: gettext TEXT_RADIOSIGNALUNKNOWN
                jmp RadioMsg
ILW_VariationB: gettext TEXT_RADIOSIGNALKNOWN
                jmp RadioMsg

        ; Install laptop finish (while climbing to exit)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various
        
InstallLaptopFinish:
                lda #PLOT_DISRUPTCOMMS
                jsr SetPlotBit
                beq ILF_NotYet                  ;May visit here without laptop
                gettext TEXT_RADIOINSTALLLAPTOPFINISH
                jmp RadioMsg
ILF_NotYet:     ldy lvlObjNum
                jmp InactivateObject

        ; Finish escorting Jeff to old tunnels
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerFollowFinish:
                ldx actIndex
                lda actXH,x
                cmp #$04
                bcc HFF_Run
                lda #AIMODE_TURNTO
                sta actAIMode,x
                lda actSX,x                     ;Wait for stop so that speech bubble isn't off
                bne HFF_Wait
                gettext TEXT_ENTEROLDTUNNELS
HFF_SpeakAndStopScript:
                ldy #$00
                sty actScriptF+2                ;Stop script for now
                ldy #ACT_HACKER
                jmp SpeakLine
HFF_Run:        lda #AIMODE_IDLE
                sta actAIMode,x
                lda #JOY_RIGHT
                sta actMoveCtrl,x
HFF_Wait:
EL_NoActors:    rts

        ; Enter old tunnels lab
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EnterLab:       lda lvlObjB+$0c                 ;If player closed door from inside, no-one can enter
                bpl EL_NoActors

                lda #ACT_SCIENTIST3
                jsr FindActor                   ;Skip if already onscreen
                bcs EL_NoActor1
                lda #ACT_SCIENTIST3
                jsr FindLevelActor
                bcc EL_NoActor1
                lda lvlActOrg,y
                cmp #$0f+ORG_GLOBAL
                bne EL_NoActor1
                lda lvlActX,y
                cmp #$5a
                bcs EL_NoActor1                 ;Already in lab or in the shaft?
                lda #$6e
                sta lvlActX,y
                lda #$4c
                sta lvlActY,y
                lda #$10+AIMODE_IDLE
                sta lvlActF,y
                lda #<EP_SCIENTISTENTERLAB
                sta actScriptEP+1
                lda #>EP_SCIENTISTENTERLAB
                sta actScriptF+1
                lda #PLOT_OLDTUNNELSLAB1
                jsr SetPlotBit

EL_NoActor1:    lda #ACT_HACKER
                jsr FindActor                   ;Skip if already onscreen
                bcs EL_NoActor2
                lda #ACT_HACKER
                jsr FindLevelActor
                bcc EL_NoActor2
                lda lvlActOrg,y
                cmp #$0f+ORG_GLOBAL
                bne EL_NoActor2
                lda lvlActX,y
                cmp #$5a
                bcs EL_NoActor2                 ;Already in lab or in the shaft?
                lda #$6e
                sta lvlActX,y
                lda #$4c
                sta lvlActY,y
                lda #$00+AIMODE_IDLE
                sta lvlActF,y
                lda #<EP_HACKERENTERLAB
                sta actScriptEP+2
                lda #>EP_HACKERENTERLAB
                sta actScriptF+2
                lda #PLOT_OLDTUNNELSLAB2
                jsr SetPlotBit
EL_NoActor2:
HEL_Wait:       rts

        ; Jeff in lab
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerEnterLab: ldx actIndex
                lda actXH,x
                cmp #$70
                bcs HEL_Done
                jmp HFF_Run
HEL_Done:       lda #AIMODE_TURNTO
                sta actAIMode,x
                lda actSX,x
                bne HEL_Wait
                gettext TEXT_ENTERLAB
                jmp HFF_SpeakAndStopScript

        ; Lab computer
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

LabComputer:    lda #ACT_HACKER
                jsr FindLevelActor
                bcc LC_NoActor
                lda lvlActOrg,y
                cmp #$0f+ORG_GLOBAL
                bne LC_NoActor
                lda lvlActX,y
                cmp #$70
                bne LC_NoActor
                lda #$88
                sta lvlActX,y
                lda #$48
                sta lvlActY,y
                lda #$10+AIMODE_TURNTO
                sta lvlActF,y
                lda #<EP_GIVELAPTOP2
                sta actScriptEP+2
                lda #>EP_GIVELAPTOP2
                sta actScriptF+2
                lda #$00
                sta scriptVariable
LC_NoActor:     jsr SetupTextScreen
                lda #0
                sta temp1
                sta temp2
                gettext TEXT_LABCOMPUTER
                jsr PrintMultipleRows
                jsr WaitForExit
                jmp CenterPlayer

        ; Jeff gives laptop after reading apocalyptic note
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

GiveLaptop2:    lda scriptVariable
                bne GiveLaptop2b
                inc scriptVariable
                gettext TEXT_GIVELAPTOP
                ldy #ACT_HACKER
                jmp SpeakLine
GiveLaptop2b:   lda #SFX_PICKUP
                jsr PlaySfx
                lda #ITEM_LAPTOP
                ldx #1
                jsr AddItem
                lda #0
                sta actScriptF+2
SEL_Wait:       rts

        ; Linda in lab
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ScientistEnterLab:
                ldx actIndex
                lda actXH,x
                cmp #$71
                bcs SEL_Done
                jmp HFF_Run
SEL_Done:       lda #AIMODE_TURNTO
                sta actAIMode,x
                lda actSX,x
                bne SEL_Wait
                gettext TEXT_ENTERLAB2
                ldy #$00
                sty actScriptF+1                ;Stop script for now
                ldy #ACT_SCIENTIST3
                jmp SpeakLine

        ; Hazmat NPC (Jeff or Linda)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Hazmat:         lda actXH+ACTI_PLAYER           ;Wait until player close enough
                cmp #$63
                bcs H_Wait
                jsr AddQuestScore
                lda #PLOT_RIGTUNNELMACHINE
                jsr SetPlotBit
                lda #$00
                sta actScriptF+3                ;Stop actor script, but use a continuous script to walk away
                lda #<EP_HAZMATLEAVE
                ldx #>EP_HAZMATLEAVE
                jsr SetScript
                ldy #ACT_HAZMAT
                gettext TEXT_HAZMAT
                jmp SpeakLine
HL_NoExit:
HL_Wait:
H_Wait:         rts

        ; Hazmat NPC walks off screen
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HazmatLeave:    lda #ACT_HAZMAT
                jsr FindActor
                bcc HL_NotOnScreen
                lda textTime
                bne HL_Wait
                lda #AIMODE_IDLE
                sta actAIMode,x
                lda #JOY_RIGHT
                sta actMoveCtrl,x
                lda actXH,x
                cmp #$63
                bcc HL_NoExit
                lda actXL,x
                cmp #$f8
                bcc HL_NoExit
                jsr RemoveActor                 ;Remove without being put back to leveldata = disappear
                jmp StopScript
HL_NotOnScreen: lda #ACT_HAZMAT
                jsr FindLevelActor
                bcc HL_NoLevelActor
                lda #ACT_NONE                   ;Disappear from the game world
                sta lvlActT,y
HL_NoLevelActor:jmp StopScript

        ; Linda comments the destroy plan
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

DestroyComment: lda #$00
                sta actScriptF+1                ;Stop actor script after line
                ldy #ACT_SCIENTIST3
                gettext TEXT_DESTROYCOMMENT
                jmp SpeakLine

        ; Jeff interaction if return to lab after installing laptop
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerFinal:    lda actXH+ACTI_PLAYER
                cmp #$84
                bcc HF_TooFar
                jsr AddQuestScore
                lda #$00
                sta actScriptF+2
                gettext TEXT_HACKERFINAL
                ldy #ACT_HACKER
                jmp SpeakLine
TM_Wait:
HF_TooFar:      rts

        ; Tunnel machine script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

tmChoice        = menuCounter

TunnelMachine:  lda scriptF                     ;If the destroy plan script running,
                bne TM_Wait                     ;do not exec this script yet
                lda #PLOT_BATTERY
                jsr GetPlotBit
                beq TM_NoBattery
                lda #PLOT_FUEL
                jsr GetPlotBit
                beq TM_NoFuel
                lda #$00
                sta tmTime1
                sta tmTime2
                sta tmChoice
                lda #<EP_TUNNELMACHINERUN
                ldx #>EP_TUNNELMACHINERUN
                jsr SetScript
                ldx #MENU_INTERACTION
                jsr SetMenuMode
                lda #<txtReady
                ldx #>txtReady
                jsr PrintPanelTextIndefinite
                jmp TMR_RedrawNoSound
TM_NoBattery:   lda #<txtNoBattery
                ldx #>txtNoBattery
                bne TM_TextCommon
TM_NoFuel:      lda #1
                sta shakeScreen
                lda #SFX_GENERATOR
                jsr PlaySfx
                lda #<txtNoFuel
                ldx #>txtNoFuel
TM_TextCommon:  ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText

        ; Tunnel machine decision runloop
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

TunnelMachineRun:
                inc tmTime1
                lda tmTime1
                and #$01
                sta shakeScreen
                inc tmTime2
                lda tmTime2
                cmp #3
                bcc TMR_NoSound
                lda #$00
                sta tmTime2
                lda #SFX_GENERATOR
                jsr PlaySfx
TMR_NoSound:    lda joystick
                and #JOY_DOWN
                bne TMR_Finish
                lda keyType
                bpl TMR_Finish
                jsr GetFireClick
                bcs TMR_Decision
                jsr MenuControl
                ldy tmChoice
                lsr
                bcs TMR_MoveLeft
                lsr
                bcs TMR_MoveRight
TMR_NoMove:     rts
TMR_MoveLeft:   tya
                beq TMR_NoMove
                dey
                sty tmChoice
TMR_Redraw:     lda #SFX_SELECT
                jsr PlaySfx
TMR_RedrawNoSound:
                ldy #$00
TMR_RedrawLoop: ldx tmArrowPosTbl,y
                lda #$20
                cpy tmChoice
                bne TMR_NoArrow
                lda #62
TMR_NoArrow:    jsr PrintPanelChar
                iny
                cpy #2
                bcc TMR_RedrawLoop
                rts
TMR_MoveRight:  tya
                bne TMR_NoMove
                iny
                sty tmChoice
                bne TMR_Redraw
TMR_Decision:   lda tmChoice
                bne TMR_Drive
TMR_Finish:     jsr StopScript
                jmp SetMenuMode                 ;X=0 on return
TMR_Drive:      jsr AddQuestScore
                jsr TMR_Finish
                lda #$00
                sta tmTime1                     ;TODO: replace with cutscene
                jsr BlankScreen
TMR_BreakWallLoop:
                jsr WaitBottom
                jsr Random
                cmp #$40
                bcs TMR_BreakWallNoSound
                lda #$00
                sta PSfx_LastSfx+1
                lda #SFX_EXPLOSION
                jsr PlaySfx
TMR_BreakWallNoSound:
                inc tmTime1
                bpl TMR_BreakWallLoop
                lda #$32
                jmp ULO_EnterDoorDest

        ; Tunnel machine item installation script routines
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

TunnelMachineItems:
                lda itemIndex
                cmp #ITEM_TRUCKBATTERY
                bne TMI_Fuel
TMI_Battery:    lda #PLOT_BATTERY
                jsr SetPlotBit
                lda #<txtBatteryInstalled
                ldx #>txtBatteryInstalled
                bne TMI_Common
TMI_Fuel:       lda #PLOT_FUEL
                jsr SetPlotBit
                lda #<txtRefueled
                ldx #>txtRefueled
TMI_Common:     jsr TM_TextCommon
                ldy itemIndex
                jsr RemoveItem
                lda #$00
                sta UM_ForceRefresh+1
                jsr AddQuestScore
                lda #SFX_POWERUP
                jsr PlaySfx
                lda plotBits
                and #$20+$40+$80                ;If laptop in place, the destroy plan
                cmp #$20+$40                    ;is not necessary
                bne TMI_NoPlan
                lda plotBits+1                  ;Any NPCs in lab?
                and #$10+$20
                beq TMI_NoPlan
                lda #<EP_DESTROYPLAN
                ldx #>EP_DESTROYPLAN
                jmp SetScript
TMI_NoPlan:     rts

        ; Jormungandr speaks
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioJormungandr:
                lda #<EP_RADIOJORMUNGANDRRUN
                ldx #>EP_RADIOJORMUNGANDRRUN
                jsr SetScript
                gettext TEXT_RADIOJORMUNGANDR
                jmp RadioMsg

        ; Jormungandr speaks, running script (screen shake)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioJormungandrRun:
                lda menuMode
                beq RJR_Stop
                jsr Random
                and #$01
                sta shakeScreen
DP_Wait:        rts
RJR_Stop:       jmp StopScript

        ; Radio message for simultaneous destruction
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

DestroyPlan:    lda textTime                    ;Wait until the fuel/battery message gone
                bne DP_Wait
                jsr StopScript
                lda plotBits+1
                and #$20
                bne DP_Jeff
DP_Linda:       lda #ACT_SCIENTIST3
                jsr DP_SetPosCommon
                lda #<txtRadioDestroyLinda
                ldx #>txtRadioDestroyLinda
                jmp RadioMsg
DP_Jeff:        lda #<EP_DESTROYCOMMENT
                sta actScriptEP+1
                lda #>EP_DESTROYCOMMENT
                sta actScriptF+1
                lda #ACT_HACKER
                jsr DP_SetPosCommon
                lda #<txtRadioDestroyJeff
                ldx #>txtRadioDestroyJeff
                jmp RadioMsg
DP_SetPosCommon:
                jsr FindLevelActor
                lda #ACT_HAZMAT
                sta lvlActT,y
                lda #$61
                sta lvlActX,y
                lda #$55
                sta lvlActY,y
                lda #$10+AIMODE_TURNTO
                sta lvlActF,y
                lda #$0f+ORG_GLOBAL
                sta lvlActOrg,y
                lda #<EP_HAZMAT
                sta actScriptEP+3
                lda #>EP_HAZMAT
                sta actScriptF+3
                ldy lvlDataActBitsStart+$0f
                lda lvlStateBits,y              ;Remove the hazmat item
                and #$fe
                sta lvlStateBits,y
                rts

        ; Large tank update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveLargeTank:  ldy #C_LARGETANK
                jsr EnsureSpriteFile
                jsr MoveGeneric                   ;Use human movement for physics
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

        ; Fireball movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveFireball:   ldy #C_HIGHWALKER
                jsr EnsureSpriteFile
                lda actTime,x                   ;Randomize X-speed on first frame
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

        ; Tables & variables

tmArrowPosTbl:  dc.b 9,14
tmTime1:        dc.b 0
tmTime2:        dc.b 0

        ; Messages

txtNoBattery:   dc.b "BATTERY DEAD",0
txtNoFuel:      dc.b "NO FUEL",0
txtBatteryInstalled:
                dc.b "NEW BATTERY INSTALLED",0
txtRefueled:    dc.b "REFUELED",0
txtReady:       dc.b " STOP DRIVE",0

txtRadioDestroyJeff:
                dc.b 34,"JEFF HERE. "
                textjump txtRadioDestroyCommon

txtRadioDestroyLinda:
                dc.b 34,"IT'S LINDA. "

txtRadioDestroyCommon:
                dc.b "DON'T START THE MACHINE YET. IF I LOAD IT WITH "
                dc.b "EXPLOSIVES FROM THE RECYCLER, MAYBE I CAN DESTROY JORMUNGANDR AS YOU DEAL WITH THE AI. "
                dc.b "A HAZMAT SUIT SHOULD ALLOW ME TO SURVIVE LONG ENOUGH. "
                dc.b "THE DOOR IN THE UPPER STORAGE LEADS BACK HERE. I'LL BE WAITING.",34,0

                checkscriptend