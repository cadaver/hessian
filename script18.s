                include macros.s
                include mainsym.s

        ; Script 18, nether tunnel

                org scriptCodeStart

driveTime       = menuCounter
scrollOffset    = wpnBits

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
                sta tmSoundTime
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
                lda UA_ItemFlashCounter+1
                and #$01
                sta shakeScreen
                jsr TMR_Sound
                lda joystick
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
                jsr DriveTunnelMachine
                inc $d025                       ;Restore sprite multicolor
                lda #$32
                jmp ULO_EnterDoorDest           ;Enter the next zone

TMR_Sound:      inc tmSoundTime
                lda tmSoundTime
                cmp #3
                bcc TMR_NoSound
                lda #SFX_GENERATOR
                jsr PlaySfx
                lda #$00
                sta tmSoundTime
TMR_NoSound:    rts

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

        ; Drive tunnel machine -sequence

DriveTunnelMachine:
                jsr BlankScreen
                lda #$01                        ;Fixed position & screen number for redraw
                sta blockX
                lda #$03
                sta blockY
                lda #$aa
                sta mapX
                sta actXH+ACTI_PLAYER
                lda #$75
                sta mapY
                lda #$77
                sta actYH+ACTI_PLAYER
                jsr FindPlayerZone
                jsr RedrawScreen
                lda #$02                        ;Empty some chars of the machine to make it look nicer
                sta screen2+10*40+17
                sta screen2+16*40+15
                sta screen2+16*40+13
                sta screen2+16*40+21
                sta screen2+16*40+23
                lda #$00
                sta screen2+9*40+26            ;Make the end of the tunnel being dug slightly round
                sta screen2+16*40+26
                sta scrollOffset
                tax                             ;Clear charinfo so that scrap will not stick to the machine
DTM_ClearCharInfo:
                sta charInfo,x
                inx
                bne DTM_ClearCharInfo
                dex
                stx ECS_LoadedCharSet+1         ;Mark game charset destroyed
                stx actXH+ACTI_PLAYER           ;Move player out of view
                jsr SetZoneColors
                dec $d025                       ;Brown multicolor for the scrap sprites
                lda #6*25
                sta driveTime
DTM_Loop:
DTM_RedrawBG:   lda scrollOffset
                inc scrollOffset
                lsr
                sta temp1
                ldx #$00
DTM_RedrawLoop: lda screen2+$100,x
                beq DTM_RedrawSkip1
                jsr DTM_GetTunnelChar
                sta screen2+$100,x
                tay
                lda charColors,y
                sta colors+$100,x
DTM_RedrawSkip1:lda screen2+$200,x
                beq DTM_RedrawSkip2
                jsr DTM_GetTunnelChar
                sta screen2+$200,x
                tay
                lda charColors,y
                sta colors+$200,x
DTM_RedrawSkip2:inx
                bne DTM_RedrawLoop
                ldy chars+151*8
DTM_ScrollChar: lda chars+151*8+1,x             ;Rotating cutter animation
                sta chars+151*8,x
                inx
                cpx #7
                bcc DTM_ScrollChar
                sty chars+151*8+7
                jsr SL_CalcSprSub
                jsr DrawActors
                jsr FinishFrame
                ldx #ACTI_LASTNPC
DTM_MoveScrap:  lda actT,x
                beq DTM_MoveNext
                jsr BounceMotion
                lda actYH,x                     ;Remove scrap that falls on "floor"
                cmp #$7a
                bcc DTM_MoveNext
                lda #$00
                sta actT,x
DTM_MoveNext:   dex
                bne DTM_MoveScrap
                jsr InterpolateActors
                jsr FinishFrame
                jsr TMR_Sound
                jsr Random
                tay
                and #$03
                sta shakeScreen
                cpy #$40
                bcs DTM_NoSpawn
                jsr GetFreeNPC
                bcc DTM_NoSpawn
                lda #ACT_SCRAPMETAL
                sta actT,y
                jsr Random
                and #$7f
                sta actYL,y
                and #$03
                sta actF1,y
                lda #$b0
                sta actXH,y
                sta actXL,y
                lda #$79
                sta actYH,y
                lda #$0b
                sta actFlash,y
                jsr Random
                and #$07
                adc #-3*8
                sta actSX,y
                jsr Random
                and #$0f
                adc #-4*8
                sta actSY,y
DTM_NoSpawn:    dec driveTime
                beq DTM_Finish
                jmp DTM_Loop
DTM_Finish:     jsr BlankScreen
                ldy #8
DTM_ExplLoop:   lda #SFX_EXPLOSION
                jsr PlaySfx
                inc PSfx_LastSfx+1              ;Allow playing the same sound again
                jsr Random
                and #$07
                tax
                jsr DTM_DelayLoop
                dey
                bne DTM_ExplLoop
DTM_Delay:      jsr BlankScreen
                ldx #25
DTM_DelayLoop:  jsr WaitBottom
                dex
                bpl DTM_DelayLoop
                rts
DTM_GetTunnelChar:
                cmp #25
                bcs DTM_GTCDone
                txa
                adc temp1
                and #$1f
                tay
                lda rockTbl,y
DTM_GTCDone:    rts

        ; Tables & variables

tmArrowPosTbl:  dc.b 9,14
tmSoundTime:    dc.b 0
rockTbl:        dc.b 5,9,4,13,17,20,3,5,10,7,11,20,13,3,5,13
                dc.b 7,3,5,10,17,11,9,8,13,17,10,7,11,20,21,9

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
