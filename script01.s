                include macros.s
                include mainsym.s

RECYCLER_ITEM_FIRST = ITEM_PISTOL
RECYCLER_ITEM_LAST = ITEM_ARMOR
MAX_RECYCLER_ITEMS = 10
RECYCLER_MOVEDELAY = 8

        ; Script 1: common objects

                org scriptCodeStart

                dc.w UseHealthRecharger
                dc.w UseBatteryRecharger
                dc.w RechargerEffect
                dc.w EnterCode
                dc.w EnterCodeLoop
                dc.w Elevator
                dc.w ElevatorLoop
                dc.w TunnelReroute
                dc.w RecyclingStation
                dc.w DisconnectSubnet
                dc.w InstallFilter
                dc.w TunnelMachine
                dc.w TunnelMachineItems
                dc.w TunnelMachineRun

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
E_NoAccess:     lda #<txtElevatorLocked
                ldx #>txtElevatorLocked
                ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText
E_HasAccess:    stx elevatorIndex
                lda #$00
                sta elevatorTime
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
                sta elevatorSound
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

numberIndex     = menuCounter

EnterCode:      lda #0
                ldx #2
EC_Reset:       sta codeEntry,x
                dex
                bpl EC_Reset
                lda #<EP_ENTERCODELOOP
                ldx #>EP_ENTERCODELOOP
SetScriptAndInteraction:
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
                jsr OO_RequirementOK            ;Open the door. TODO: actually verify code
ECL_Finish:     jsr StopScript
                ldx #MENU_NONE
                jmp SetMenuMode

        ; Tunnel reroute after the machine has been used once
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

TunnelReroute:  lda #PLOT_WALLBREACHED
                jsr GetPlotBit
                beq TR_NotDone
                lda #$3d                        ;Change sidedoor destination to version
                sta lvlObjDL+$2a                ;of zone without machine + new enemies
TR_NotDone:     rts

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
                jsr GetFireClick
                bcs RS_Action
                lda recyclerSelection
                ldx recyclerListLength
                jsr RS_Control
                sta recyclerSelection
                bcs RS_Redraw
                lda keyType
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

        ; Subnet router script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

DisconnectSubnet:
                jsr AddQuestScore
                lda #<txtDisconnected
                ldx #>txtDisconnected
                ldy #REQUIREMENT_TEXT_DURATION
                jsr PrintPanelText
                lda lvlObjB+$4d
                bpl DS_NotBoth
                lda lvlObjB+$4e
                bpl DS_NotBoth
                lda #SFX_POWERUP
                jsr PlaySfx
                lda #PLOT_ELEVATOR1
                jmp SetPlotBit                  ;Todo: other stuff, more prominent effect
DS_NotBoth:     rts

        ; Surgery station script (TODO: remove and replace with proper story elements)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

InstallFilter:  ldy #ITEM_LUNGFILTER
                jsr FindItem
                bcc IF_NotFound
                jsr RemoveItem
                lda #SFX_POWERUP
                jsr PlaySfx
                lda upgrade
                ora #UPG_TOXINFILTER
                sta upgrade
IF_NotFound:    rts

        ; Tunnel machine script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

tmChoice        = menuCounter

TunnelMachine:  lda #PLOT_BATTERY
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
                ldx #MENU_NONE
                jmp SetMenuMode
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
                lda #PLOT_WALLBREACHED
                jsr SetPlotBit
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
                jsr AddQuestScore
                lda #SFX_POWERUP
                jmp PlaySfx

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
                dc.b 1                          ;EMP generator
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
                dc.b 20                         ;Sniper rifle
                dc.b 25                         ;Minigun
                dc.b 25                         ;Flamethrower
                dc.b 25                         ;Laser rifle
                dc.b 25                         ;Plasma gun
                dc.b 20                         ;EMP generator
                dc.b 25                         ;Grenade launcher
                dc.b 30                         ;Bazooka
                dc.b 0                          ;Extinguisher
                dc.b 25                         ;Grenade
                dc.b 30                         ;Mine
                dc.b 40                         ;Medikit
                dc.b 40                         ;Battery
                dc.b 50                         ;Armor

        ; Misc. tables

tmArrowPosTbl:  dc.b 9,14

        ; Variables

tmTime1:
elevatorIndex:  dc.b 0
tmTime2:
rechargerColor:
elevatorTime:   dc.b 0
elevatorSound:  dc.b 0

recyclerItemList:
                ds.b MAX_RECYCLER_ITEMS+1,0

        ; Messages

txtHealthRecharger:
                dc.b "HEALTH RESTORED",0
txtBatteryRecharger:
                dc.b "BATTERY RECHARGED",0
txtElevatorLocked:
                dc.b "ELEVATOR LOCKED",0
txtEnterCode:   dc.b "ENTER CODE",0
txtRecycler:    dc.b "PART RECYCLING STATION",0
txtExit:        dc.b "EXIT",0
txtCost:        dc.b "COST",0
txtDisconnected:dc.b "SUBNET ISOLATED",0
txtNoBattery:   dc.b "BATTERY DEAD",0
txtNoFuel:      dc.b "NO FUEL",0
txtBatteryInstalled:
                dc.b "BATTERY INSTALLED",0
txtRefueled:    dc.b "REFUELED",0
txtReady:       dc.b " STOP DRIVE",0
txtCount:       dc.b " "
txtDigits:      dc.b "000",0
txtArrow:       dc.b 62,0

                checkscriptend