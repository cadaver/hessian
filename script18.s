                include macros.s
                include mainsym.s

        ; Script 18, nether tunnel

                org scriptCodeStart

                dc.w TunnelMachine
                dc.w TunnelMachineItems
                dc.w TunnelMachineRun
                dc.w RadioJormungandr
                dc.w RadioJormungandrRun
                dc.w DestroyPlan
                dc.w MoveLargeTank
                dc.w MoveFireball
                dc.w RadioHackerWarning

        ; Tunnel machine script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

tmChoice        = menuCounter

TunnelMachine:  lda scriptF                     ;If the destroy plan script running,
                bne TM_Wait                     ;do not exec this script yet
                lda #PLOT_RIGTUNNELMACHINE
                jsr GetPlotBit
                bne TM_AlreadyRigged
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
                gettext txtReady
                jsr PrintPanelTextIndefinite
                jmp TMR_RedrawNoSound
TM_NoBattery:   gettext txtNoBattery
                bne TM_TextCommon
TM_NoFuel:      lda #1
                sta shakeScreen
                lda #SFX_GENERATOR
                jsr PlaySfx
                gettext txtNoFuel
TM_TextCommon:  ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText
TM_Wait:        rts
TM_AlreadyRigged:
                ldy lvlObjNum
                lda lvlObjB,y                   ;Note: this isn't stored to game state,
                and #$ff-OBJMODE_MANUAL         ;so after loading a save this line
                sta lvlObjB,y                   ;would be spoken again
                lda #$ff
                sta lvlObjNum
                gettext txtAlreadyRigged
                jsr PrintPanelTextIndefinite
                ldx #ACTI_PLAYER
                jsr SL_ExplicitActor
                tya
                tax
                lda #-8*8                       ;Move speech bubble slightly higher to
                jmp MoveActorY                  ;denote it comes from inside the machine

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
                jsr RemoveLevelActors
                ldy #$32
                ldx #ACTI_PLAYER
                jsr SetActorAtObject
                lda #<EP_SHOWCUTSCENE
                ldx #>EP_SHOWCUTSCENE
                ldy #CUTSCENE_TUNNELMACHINE
                jmp ExecScriptParam

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
                gettext txtBatteryInstalled
                bne TMI_Common
TMI_Fuel:       lda #PLOT_FUEL
                jsr SetPlotBit
                gettext txtRefueled
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
                gettext txtRadioJormungandr
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx

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
DP_Jeff:        lda #ACT_SCIENTIST3
                jsr FindLevelActor              ;Require old tunnels level to be sure (if player
                bcc DP_NoComment                ;is cheating, the surgery scene could be
                lda lvlActOrg,y                 ;skipped and this script would trigger in the
                cmp #$0f+ORG_GLOBAL             ;wrong place)
                bne DP_NoComment
                lda #<EP_DESTROYCOMMENT
                ldx #>EP_DESTROYCOMMENT
                sta actScriptEP+1
                stx actScriptF+1
DP_NoComment:   lda #ACT_HACKER
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
                ldx #>EP_HAZMAT
                sta actScriptEP+3
                stx actScriptF+3
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

        ; Radio message when entering Jormungandr's lair without biometric ID
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioHackerWarning:
                lda #ACT_HACKER                 ;Make sure Jeff is alive
                jsr FindLevelActor
                bcc RHW_NoActor
                ldy #ITEM_BIOMETRICID
                jsr FindItem
                bcs RHW_HasItem
                gettext txtRadioHackerWarning
                jmp RadioMsg
RHW_NoActor:
RHW_HasItem:    rts

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
                dc.b "EXPLOSIVES FROM THE RECYCLER, MAYBE I CAN DESTROY JORMUNGANDR JUST AS YOU TAKE OUT THE AI. "
                dc.b "A HAZMAT SUIT SHOULD ALLOW ME TO SURVIVE LONG ENOUGH. "
                dc.b "THE DOOR IN THE UPPER STORAGE LEADS BACK TO THE LAB. I'LL BE WAITING.",34,0

txtRadioJormungandr:
                dc.b 34,"GREETINGS SEMI-HUMAN. I AM JORMUNGANDR. I RESIDE BEYOND THE DEAD END IN FRONT OF YOU. "
                dc.b "TURN BACK NOW, THERE IS NOTHING YOU CAN GAIN BY PROCEEDING. WHEN I RECEIVE THE SIGNAL "
                dc.b "FROM MY MASTER, OR IF HE SHOULD FALL SILENT, I WILL TRAVEL THE CRUST AND MAKE THE EARTH BREATHE "
                dc.b "FIRE AND ASH, BRINGING THE POST-HUMAN AGE. AND SHOULD I FALL, HE WILL AVENGE ME.",34,0

txtRadioHackerWarning:
                dc.b 34,"IT'S JEFF. YOU MUST BE CLOSE NOW. THERE'S ONE THING I FOUND.. THE DEDICATED MILITARY NETWORK "
                dc.b "LINK IS ACTIVE, THOUGH ALL OTHER OUTSIDE LINES ARE DOWN. HAS TO BE THE AI. "
                dc.b "THE SCARIEST OPTION WOULD BE THAT IT HAS WORMED ITS WAY INTO "
                dc.b "NUCLEAR LAUNCH SYSTEMS OR SOMETHING. BUT NO. THEY'RE TOO WELL PROTECTED.",34,0

txtAlreadyRigged:
                dc.b 34,"I'M RIGGING THE EXPLOSIVES! YOU GO AHEAD TO THE AI!",34,0

                checkscriptend
