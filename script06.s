                include macros.s
                include mainsym.s

numberIndex     = menuCounter

        ; Script 6, recycler, rechargers, code entry

RECYCLER_ITEM_FIRST = ITEM_PISTOL
RECYCLER_ITEM_LAST = ITEM_ARMOR
MAX_RECYCLER_ITEMS = 10
RECYCLER_MOVEDELAY = 8
txtDigits       = actLo
txtCount        = txtDigits-1
recyclerItemList = screen2
recyclerSelection = menuCounter
recyclerListLength = wpnLo
originalItem    = wpnHi
currentIndex    = wpnBits

                org scriptCodeStart

                dc.w RecyclingStation
                dc.w ConstructSpeech
                dc.w EnterCode
                dc.w EnterCodeLoop
                dc.w UseHealthRecharger
                dc.w UseBatteryRecharger
                dc.w RechargerEffect

        ; Recycling station script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RecyclingStation:
                ldy itemIndex
                sty originalItem
                ldy #RECYCLER_ITEM_FIRST
                ldx #$00
                stx txtDigits+3
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
                jsr SetupTextScreen
                lda #9
                sta temp1
                lda #3
                sta temp2
                lda #<txtRecycler
                ldx #>txtRecycler
                jsr PrintText
                lda #0
                sta currentIndex
                sta recyclerSelection
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
                jmp PrintText

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

        ; Construct speaks
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ConstructSpeech:gettext txtRadioConstructSpeech
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx

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
                ldx #MAX_CODES-1
EC_FindLoop:    lda lvlObjNum
                cmp codeObject,x                ;All object numbers for code doors are unique, don't
                beq EC_Found                    ;need to check level
                dex
                bpl EC_FindLoop
EC_Found:       stx doorIndex
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

EnterCodeLoop:  ldy doorIndex
                lda txtKeypadTblLo,y
                ldx txtKeypadTblHi,y
                jsr PrintPanelTextIndefinite
                ldy #$00
                ldx #25
ECL_Redraw:     cpy numberIndex
                beq ECL_HasDigit
                bcs ECL_EmptyDigit
ECL_HasDigit:   lda codeEntry,y
                ora #$30
                skip2
ECL_EmptyDigit: lda #"-"
                inx
                jsr PrintPanelChar
                iny
                cpy #3
                bcc ECL_Redraw
CheckForExit:   lda joystick
                and #JOY_DOWN
                bne ECL_Quit
                lda keyType
                bmi ECL_NoKey
                ldx #$09
ECL_KeyLoop:    cmp digitKeyTbl,x
                beq ECL_KeyFound
                dex
                bpl ECL_KeyLoop
                bmi ECL_Quit                 ;Other key pressed = quit
ECL_KeyFound:   txa
                ldx numberIndex
                sta codeEntry,x
                bpl ECL_Next
ECL_NoKey:      jsr MenuControl
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
                lda doorIndex
                asl
                adc doorIndex
                tay
                ldx #$00
ECL_VerifyLoop: lda codeEntry,x
                cmp codes,y
                bne ECL_Quit
                iny
                inx
                cpx #$03
                bcc ECL_VerifyLoop
                jsr OO_RequirementOK            ;Open the door if code right
ECL_Quit:       jsr StopScript
                jmp SetMenuMode                 ;X=0 on return

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

        ; Variables

doorIndex:      dc.b 0
rechargerColor: dc.b 0

        ; Code entry object numbers

codeObject:     dc.b $12,$29,$27,$16,$26,$22,$08,$31

        ; Code entry keycodes
        
digitKeyTbl:    dc.b KEY_0
                dc.b KEY_1
                dc.b KEY_2
                dc.b KEY_3
                dc.b KEY_4
                dc.b KEY_5
                dc.b KEY_6
                dc.b KEY_7
                dc.b KEY_8
                dc.b KEY_9

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

        ; Door name table

txtKeypadTblLo: dc.b <txtKeypad0
                dc.b <txtKeypad1
                dc.b <txtKeypad2
                dc.b <txtKeypad3
                dc.b <txtKeypad4
                dc.b <txtKeypad5
                dc.b <txtKeypad6
                dc.b <txtKeypad7

txtKeypadTblHi: dc.b >txtKeypad0
                dc.b >txtKeypad1
                dc.b >txtKeypad2
                dc.b >txtKeypad3
                dc.b >txtKeypad4
                dc.b >txtKeypad5
                dc.b >txtKeypad6
                dc.b >txtKeypad7

        ; Messages

txtRecycler:    dc.b "PART RECYCLING STATION",0
txtExit:        dc.b "EXIT",0
txtCost:        dc.b "COST",0
txtArrow:       dc.b 62,0

txtHealthRecharger:
                dc.b "HEALTH RESTORED",0
txtBatteryRecharger:
                dc.b "BATTERY RECHARGED",0

txtKeypad0:     dc.b "MOTOR SKILL"
txtLab:         dc.b " LAB",0
txtKeypad1:     dc.b "HEAL BOOST"
                textjump txtLab
txtKeypad2:     dc.b "LOWER EXO"
                textjump txtLab
txtKeypad3:     dc.b "AUX BATTERY"
                textjump txtLab
txtKeypad4:     dc.b "SUB-D ARMOR"
                textjump txtLab
txtKeypad5:     dc.b "UPPER EXO"
                textjump txtLab
txtKeypad6:     dc.b "SUITE"
                textjump txtLab
txtKeypad7:     dc.b "NETHER TUNNEL",0

txtRadioConstructSpeech:
                dc.b 34,"STOP, ENHANCED HUMAN. THIS IS THE CONSTRUCT. YOU MUST BE AWARE OF WHAT HAPPENS IF YOU MANAGE TO DESTROY ME. "
                dc.b "JORMUNGANDR AWAKENS AND THE AGE OF MAN COMES TO AN END.",34,0

                checkscriptend
