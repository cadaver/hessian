PANEL_TEXT_SIZE = 22
MENU_DELAY      = 16
MENU_PAUSEDELAY = 36
MENU_MOVEDELAY  = 3

INDEFINITE_TEXT_DURATION = $7f
INVENTORY_TEXT_DURATION = 25
ARMOR_TEXT_DURATION = 37
REQUIREMENT_TEXT_DURATION = 50

REDRAW_ITEM     = $01
REDRAW_AMMO     = $02
REDRAW_SCORE    = $04

MENU_NONE       = 0
MENU_INVENTORY  = 1
MENU_DIALOGUE   = 2
MENU_INTERACTION = 3
MENU_PAUSE      = 4

HEALTHBAR_LENGTH = 7

TEXTRIGHTMARGIN = 31

        ; Subroutine to animate & draw a health bar
        ;
        ; Parameters: A value to display, X healthbar index (0 = health, 1 = battery)
        ; Returns: -
        ; Modifies: A,Y,temp1-temp2

DrawHealthBar:  ldy healthBarPosTbl,x
                cmp displayedHealth,x
                beq DHB_Done
                bcc DHB_Decrement
DHB_Increment:  inc displayedHealth,x
                skip2
DHB_Decrement:  dec displayedHealth,x
                tya                             ;Start position
                clc
DHB_Length:     adc #HEALTHBAR_LENGTH           ;End position
                sta temp2
                lda displayedHealth,x
                lsr
                lsr
                clc
                adc healthBarPosTbl,x
                sta temp1                       ;Whole chars end position
DHB_WholeCharsLoop:
                cpy temp1
                bcs DHB_WholeCharsDone
                lda #126
                jsr DHB_Sub
                bne DHB_WholeCharsLoop
DHB_WholeCharsDone:
                lda displayedHealth,x
                and #$03
                beq DHB_EmptyCharsLoop
                adc #121                       ;C=1
                jsr DHB_Sub
DHB_EmptyCharsLoop:
                cpy temp2
                bcs DHB_Done
                lda #122
                jsr DHB_Sub
                bne DHB_EmptyCharsLoop
DHB_Done:       rts
DHB_Sub:        sta panelScreen+PANELROW*40,y
                iny
                rts

        ; Finish frame. Update frame and score panel
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,loader temp vars

FinishFrame:    jsr UpdateFrame

        ; Update scorepanel (health, text display, weapon, ammo)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,loader temp vars,temp vars

UpdatePanel:    lda menuMode
                cmp #MENU_PAUSE                 ;Increment game clock, except when paused
                beq UP_SkipTime
                ldx #$03
UP_IncreaseTime:
                inc time,x                      ;time+3 = frames
                lda time,x                      ;time = hours
                cmp timeMaxTbl,x
                bcc UP_SkipTime
                lda #$00
                sta time,x
                dex
                bne UP_IncreaseTime
UP_SkipTime:    ldx #$00
                lda actHp+ACTI_PLAYER
                lsr
                jsr DrawHealthBar
                lda battery+1
                lsr
                adc #$00                        ;Round upward
                inx
                jsr DrawHealthBar
                lda armorMsgTime                ;Armor meter requested?
                bne UP_ArmorMsg
                lda oxygen                      ;Show oxygen meter if less than maximum
                lsr
                cmp #MAX_OXYGEN/2
                bcc UP_ShowOxygen
                bcs UP_ClearOxygen
UP_ArmorMsg:    dec armorMsgTime
                lda invCount+ITEM_ARMOR-1
                bpl UP_HasArmor
                lda #$00
UP_HasArmor:    cmp #100                        ;If picked up a full armor while message
                bcs UP_ClearOxygen              ;was displayed, show nothing
                ldy #"A"
                skip2
UP_ShowOxygen:  ldy #"O"
                sty temp1
                jsr ConvertToBCD8
                ldx #58
                lda temp1
                jsr PrintPanelChar
                jsr PrintBCDDigitsLSB
                lda #"%"
                jsr PrintPanelChar
                bne UP_SkipHealth
UP_ClearOxygen: lda #32
                cmp panelScreen+PANELROW*40+58
                beq UP_SkipHealth
                ldx #3
UP_ClearOxygenLoop:
                sta panelScreen+PANELROW*40+58,x
                dex
                bpl UP_ClearOxygenLoop
UP_SkipHealth:  if SHOW_BATTERY > 0
                ldx #1
                lda battery+1
                jsr PrintHexByte
                lda battery
                jsr PrintHexByte
                endif
UP_RedrawItemAmmoScore:
                lsr panelUpdateFlags
                bcc UP_SkipWeapon
                ldx #$02
                ldy #93
UP_DrawItemLoop:tya                             ;Draw the item image
                sta panelScreen+PANELROW*40+32,x
                lda #$08
                sta colors+PANELROW*40+32,x
                dey
                dex
                bpl UP_DrawItemLoop
                ldx itemIndex
                lda itemFrames,x
                asl
                tay
                lda fileLo+C_ITEM
                sta zpBitsLo
                lda fileHi+C_ITEM
                sta zpBitsHi
                lda (zpBitsLo),y
                sta zpSrcLo
                iny
                lda (zpBitsLo),y
                sta zpSrcHi
                ldy #SPRH_MASK
                lda (zpSrcLo),y
                sta zpBitBuf                        ;Slice bitmask
                ldy #SPRH_DATA
                ldx #$00
UP_DrawSlice:   txa
                ora #$07
                sta zpDestLo
UP_DrawSliceLoop:
                inx
                lda zpBitBuf
                and #$01
                beq UP_EmptySlice
                lda (zpSrcLo),y
                iny
UP_EmptySlice:  sta textChars+91*8,x
                cpx zpDestLo
                bcc UP_DrawSliceLoop
                inx
                lsr zpBitBuf
                cpx #$18
                bne UP_DrawSlice
UP_SkipWeapon:  lsr panelUpdateFlags
                bcc UP_SkipAmmo
                jsr GetCurrentItemMagazineSize
                bcc UP_NotFirearm
UP_Firearm:     sta temp2
                lda reload
                bne UP_Reloading
                lda invMag-ITEM_FIRST_MAG,y     ;Print rounds in magazine
                jsr ConvertToBCD8
                ldx #35
                jsr PrintBCDDigitsLSB
                lda #"/"
                jsr PrintPanelChar
                ldy itemIndex
                lda invCount-1,y                ;Get ammo in reserve
                sec
                sbc invMag-ITEM_FIRST_MAG,y
                ldy temp2
                ldx #temp7
                jsr DivU                        ;Divide by magazine size, add one
                cmp #$01                        ;if there's a remainder
                lda temp7
                adc #$00
                ;cmp #$0a                        ;More than 9 can not be printed, clamp
                ;bcc UP_MagCountOK
                ;lda #$09
UP_MagCountOK:  ora #$30
                sta panelScreen+PANELROW*40+38
                bne UP_SkipAmmo
UP_NotFirearm:  cmp #MAG_INFINITE
                beq UP_MeleeWeapon
UP_Consumable:  tya
                ldx #35
                cmp #ITEM_ARMOR
                php
                beq UP_IsArmor
                cmp #ITEM_FIRST_CONSUMABLE      ;Draw X only for real consumables, not for the minigun
                bcs UP_IsConsumable
                lda #32
                skip2
UP_IsConsumable:lda #42
                jsr PrintPanelChar
UP_IsArmor:     lda invCount-1,y
                cmp #NO_ITEM_COUNT              ;In case of the recycler station we may be displaying
                adc #$00                        ;a nonexisting item (count=$ff). Turn that to 0
                jsr ConvertToBCD8
                jsr Print3BCDDigits
                plp
                bne UP_NotArmor
                lda #"%"
                jsr PrintPanelChar
UP_NotArmor:    jmp UP_SkipAmmo
UP_Reloading:   ldy #$07
                skip2
UP_MeleeWeapon: ldy #$03
                ldx #$03
UP_MeleeWeaponLoop:
                lda txtInf,y
                sta panelScreen+PANELROW*40+35,x
                dey
                dex
                bpl UP_MeleeWeaponLoop
UP_SkipAmmo:    lsr panelUpdateFlags
                if SHOW_FREE_MEMORY == 0 && SHOW_BATTERY == 0
                bcc UP_SkipScore
                lda score
                ldx score+1
                ldy score+2
                jsr ConvertToBCD24
                ldx #1
                lda temp8
                jsr PrintBCDDigits
                lda temp7
                jsr PrintBCDDigits
                jsr PrintBCDDigitsLSB
                lda #"0"                        ;The final 0 is fixed, ie. score is internally stored
                jsr PrintPanelChar              ;as divided by 10
                endif
UP_SkipScore:   lda textTime
                beq UP_TextDone
                cmp #INDEFINITE_TEXT_DURATION*2
                bcs UP_TextDone
                dec textTime
                beq UP_UpdateText
UP_TextDone:    rts

        ; Clear the panel text
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X

UM_RedrawNone:  lda #REDRAW_SCORE
                jsr SetPanelRedraw
ClearPanelText: ldx #$00
                ldy #$00
                beq PrintPanelText

        ; Print continued panel text. Should be called immediately after printing
        ; the beginning part.
        ;
        ; Parameters: A,X text address
        ; Returns: -
        ; Modifies: A

ContinuePanelText:
                sta textLo
                stx textHi
                ldx zpBitsLo
                bpl UP_ContinueText

        ; Print text to panel, possibly multi-line
        ;
        ; Parameters: A,X text address, Y delay in game logic frames (25 = 1 sec)
        ; Returns: -
        ; Modifies: A,zpSrcLo,zpSrcHi,zpBitsLo,zpBitBuf

PrintPanelTextIndefinite:
                ldy #INDEFINITE_TEXT_DURATION
PrintPanelText: sty textDelay
                sta textLo
                stx textHi

UP_UpdateText:  lda #$00
                sta displayedItemName
                ldx textLeftMargin
UP_ContinueText:ldy #$00
                lda textHi
                beq UP_NoLine
                lda (textLo),y
                bne UP_BeginLine
UP_NoLine:      sta textTime
                beq UP_ClearEndOfLine
UP_BeginLine:   lda textDelay
                asl
                sta textTime
UP_PrintTextLoop:
                sty zpSrcHi
                stx zpSrcLo
UP_ScanWordLoop:lda (textLo),y
                beq UP_ScanWordDone
                bmi UP_ScanWordDone
                cmp #$20
                beq UP_ScanWordDone
                cmp #"-"
                beq UP_ScanWordDone2
                inc zpSrcLo
                iny
                bne UP_ScanWordLoop
UP_ScanWordDone2:
                inc zpSrcLo
UP_ScanWordDone:ldy zpSrcHi
                lda #TEXTRIGHTMARGIN
                cmp zpSrcLo
                bcs UP_WordCmp
UP_EndLine:     stx zpBitsLo
                tya
                ldx #textLo
                jsr Add8
                ldx zpBitsLo
                cpx #TEXTRIGHTMARGIN
                bcs UP_PrintTextDone
UP_ClearEndOfLine:
UP_ClearLoop:   lda #$20
                jsr PrintPanelChar
                cpx #TEXTRIGHTMARGIN
                bcc UP_ClearLoop
UP_PrintTextDone:
                rts
UP_WordLoop:    lda (textLo),y
                jsr PrintPanelChar
                iny
UP_WordCmp:     cpx zpSrcLo
                bcc UP_WordLoop
UP_SpaceLoop:   lda (textLo),y
                beq UP_EndLine
                bmi UP_TextJump
                cmp #$20
                bne UP_SpaceLoopDone
                cpx #TEXTRIGHTMARGIN
                bcs UP_SpaceSkip
                jsr PrintPanelChar
UP_SpaceSkip:   iny
                bne UP_SpaceLoop
UP_SpaceLoopDone:
                cpx #TEXTRIGHTMARGIN
                bcc UP_PrintTextLoop
                bcs UP_EndLine
UP_TextJump:    pha
                iny
                lda (textLo),y
                sta textLo
                pla
                and #$7f
                sta textHi
                ldy #$00
                beq UP_PrintTextLoop

        ; Update menu system (inventory / pause / dialogue) in the panel
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,loader temp vars

UpdateMenu:     ldx menuMode
                lda menuUpdateTblLo,x
                sta UM_UpdateJump+1
                lda menuUpdateTblHi,x
                sta UM_UpdateJump+2
UM_UpdateJump:  jmp $0000

        ; Switch menu mode and redraw the menu display
        ;
        ; Parameters: X new menu mode
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,loader temp vars

SetGameOverMenu:lda fastLoadMode                ;In Kernal loading mode, do not load the tune
                beq SkipGameOverMusic           ;as it would blank the screen and take a long time
                lda #MUSIC_GAMEOVER
                jsr PlaySong
SkipGameOverMusic:
                ldx #MENU_PAUSE
                lda #$01                        ;Start from the "retry" choice
                skip2
SetMenuMode:    lda #$00
                sta menuCounter
                stx menuMode
SMM_Redraw:     lda menuRedrawTblLo,x
                sta SMM_RedrawJump+1
                lda menuRedrawTblHi,x
                sta SMM_RedrawJump+2
SMM_RedrawJump: jmp $0000

        ; Menu logic routines

        ; None

UM_None:        lda actT+ACTI_PLAYER            ;If vanished after death, forcibly enter pause menu
                beq SetGameOverMenu
                ldx #MENU_PAUSE
                lda keyType                     ;Enter pause menu manually by pressing RUN/STOP
                cmp #KEY_RUNSTOP
                beq SetMenuMode
                ldx #MENU_INVENTORY             ;Check for entering inventory by holding firebutton;
                ldy #$ff                        ;if a direction simultaneously held, halt the
                lda joystick                    ;counter until fire released
                cmp #JOY_FIRE
                bcc UM_NoFire
                bne UM_StoreCounter
                ldy menuCounter
                bmi UM_NoCounter
UM_NoFire:      iny
                cpy #MENU_DELAY
                beq SetMenuMode
UM_StoreCounter:sty menuCounter
UM_NoCounter:   ldy itemIndex
                lda keyType
                cmp #KEY_COMMA
                beq UM_MoveLeft
                cmp #KEY_COLON
                beq UM_MoveRight
                cmp #KEY_R
                beq UM_Reload
                cmp #KEY_H
                beq UM_Heal
                cmp #KEY_B
                beq UM_Battery
                if DROP_ITEM_TEST > 0
                cmp #KEY_D
                beq UM_DropItem
                endif
UM_ControlDone: rts
UM_Heal:        ldy #ITEM_MEDKIT
                skip2
UM_Battery:     ldy #ITEM_BATTERY
                jsr FindItem
                bcc UM_ControlDone
UM_Reload:      jmp UseItem

        ; Inventory

UM_Inventory:   ldx #MENU_NONE                  ;Check for exiting inventory or waiting for
                lda joystick                    ;pause menu
                ldy #$ff
                cmp #JOY_FIRE
                bcc SetMenuMode2
                bne UM_StoreCounter2
                ldy menuCounter
                bmi UM_NoCounter2
                ldx #MENU_PAUSE
                iny
                cpy #MENU_PAUSEDELAY
                beq SetMenuMode2
UM_StoreCounter2:
                sty menuCounter
UM_NoCounter2:
UM_ForceRefresh:lda #$00                        ;Check for forced refresh (when inventory
                bne RedrawMenu                  ;modified while open)
                jsr MenuControl                 ;Check for selecting items
                lsr
                bcs UM_MoveLeft
                lsr
                bcs UM_MoveRight
                lda joystick
                cmp #JOY_FIRE+JOY_DOWN          ;Check for reloading weapon
                bne UM_MoveDone
                ldy itemIndex
                cmp prevJoy
                bne UM_Reload
UM_MoveDone:    rts

                if DROP_ITEM_TEST > 0
UM_DropItem:    lda itemIndex
                sta temp5
                ldx #ACTI_PLAYER
                jmp DI_HasCapacity
                endif

UM_MoveLeft:    jsr SelectPreviousItem
                jmp UM_MoveCommon
UM_MoveRight:   jsr SelectNextItem
UM_MoveCommon:  bcc UM_MoveDone

RedrawInventory:ldx #MENU_INVENTORY
                skip2
RedrawMenu:     ldx menuMode
                jmp SMM_Redraw
SetMenuMode2:   jmp SetMenuMode

        ; Dialogue

UM_Dialogue:    ldx #MENU_NONE
                lda textTime
                beq SetMenuMode2
                lda keyType
                bpl UM_DNext
                jsr GetFireClick                ;Skip to next text line by pressing fire or by keypress
                bcc UM_DNoFire
UM_DNext:       lda #$01
                sta textTime
UM_Interaction:
UM_DNoFire:     rts

        ; Pause menu

UM_PauseMenu:   lda keyType
                bmi UM_PauseMenuNoKey
                ldy #$00
                beq UM_PauseMenuAction
UM_PauseMenuNoKey:
                ldy menuCounter
                jsr GetFireClick
                bcs UM_PauseMenuAction
                jsr MenuControl
                lsr
                bcs UM_PauseMenuLeft
                lsr
                bcs UM_PauseMenuRight
UM_PauseMenuDone:
                rts
UM_PauseMenuAction:
                lda #SFX_SELECT
                jsr PlaySfx
                dey
                bmi UM_PauseMenuExit
                php
                jsr UM_PauseMenuClear
                plp
                beq UM_Retry
UM_SaveGame:    lda #<EP_TITLE                  ;Execute titlescreen in "save" mode
                ldx #>EP_TITLE                  ;(parameter 1)
                ldy #$01
                sty ES_LoadedScriptFile+1       ;Always reload title script
                jmp ExecScriptParam
UM_Retry:       lda #RCP_CONTINUETIME
                jmp RestartCheckpoint

UM_PauseMenuLeft:
                tya
                beq UM_PauseMenuDone
                dec menuCounter
                bpl RedrawMenu
UM_PauseMenuRight:
                cpy #$02
                beq UM_PauseMenuDone
                inc menuCounter
                bpl RedrawMenu
UM_PauseMenuExit:
                lda actT+ACTI_PLAYER            ;If player actor already vanished after death, can't exit/resume
                beq UM_PauseMenuDone
UM_PauseMenuClear:
                jsr SetPanelRedrawItemAmmo      ;Erase the time display when exiting pause menu
                ldx #MENU_NONE
                beq SetMenuMode2

        ; Menu redraw routines

        ; Inventory

UM_RedrawInventory:
                lda #SFX_SELECT
                jsr PlaySfx
                lda #$00
                sta UM_ForceRefresh+1
                inc textLeftMargin
                lda itemIndex
                jsr GetItemName
                ldy menuMode                    ;When using keys to select item,
                bne UM_RedrawActive             ;only show the text for a short time
                ldy #INVENTORY_TEXT_DURATION
                skip2
UM_RedrawActive:ldy #INDEFINITE_TEXT_DURATION
                jsr PrintPanelText
UM_RedrawCommon:
                dec textLeftMargin
UM_DrawSelectionArrows:
                ldy itemIndex
                lda #$20
                cpy #ITEM_FISTS
                beq UM_NoLeftArrow
                lda #60
UM_NoLeftArrow: ldx #9
                jsr PrintPanelChar
                lda #$20
                cpy lastItemIndex
                beq UM_NoRightArrow
                lda #62
UM_NoRightArrow:ldx #30
                jsr PrintPanelChar
                jmp SetPanelRedrawItemAmmo      ;Redraw item & ammo next time panel is updated

        ; Pause menu

UM_RedrawPauseMenu:
                lda #SFX_SELECT
                jsr PlaySfx
                lda actT+ACTI_PLAYER            ;Player actor exists?
                beq UM_PauseDead
                if SHOW_FREE_MEMORY = 0
                lda #$00
                sta panelUpdateFlags
                lda time                        ;Print game time over the weapon/ammo display if alive
                jsr ConvertToBCD8
                ldx #32
                lda temp6
                jsr PrintBCDDigit
                lda time+1
                jsr PrintTimeSub
                lda time+2
                jsr PrintTimeSub
                endif
UM_PauseDead:   lda #<txtPause
                ldx #>txtPause
                jsr PrintPanelTextIndefinite
                ldy #2
UM_PauseMenuArrowLoop:
                ldx pauseMenuArrowPosTbl,y
                lda #$20
                cpy menuCounter
                bne UM_PauseMenuSpace
                lda #62
UM_PauseMenuSpace:
                sta panelScreen+PANELROW*40,x
                dey
                bpl UM_PauseMenuArrowLoop
UM_RedrawInteraction:
UM_RedrawDialogue:
                rts

PrintTimeSub:   pha
                lda #":"
                jsr PrintPanelChar
                pla
                jsr ConvertToBCD8
                jmp PrintBCDDigitsLSB

        ; Check for joystick left/right movement in menu, taking movement delay into account
        ;
        ; Parameters: -
        ; Returns: A=0 no movement, 1=left, 2=right
        ; Modifies: A,X

MenuControl:    lda menuMoveDelay
                beq MC_NoDelay
                dec menuMoveDelay
                lda #$00
MC_NoMove:      rts
MC_NoDelay:     lda joystick
                and #JOY_LEFT+JOY_RIGHT
                beq MC_NoMove
                pha
                ldx #MENU_MOVEDELAY
                lda joystick
                cmp prevJoy
                bne MC_NormalDelay
                dex
MC_NormalDelay: stx menuMoveDelay
                pla
                lsr
                lsr
                rts

        ; Print a 3-digit BCD value to panel
        ;
        ; Parameters: temp6-temp7 value, X position
        ; Returns: X position incremented
        ; Modifies: A
             
Print3BCDDigits:lda temp7
                jsr PrintBCDDigit
PrintBCDDigitsLSB:
                lda temp6

        ; Print a BCD value to panel
        ;
        ; Parameters: A value, X position
        ; Returns: X position incremented
        ; Modifies: A

PrintBCDDigits: pha
                lsr
                lsr
                lsr
                lsr
                ora #$30
                jsr PrintPanelChar
                pla
PrintBCDDigit:  and #$0f
                ora #$30
PrintPanelChar: sta panelScreen+PANELROW*40,x
                lda #$01
                sta colors+PANELROW*40,x
                inx
                rts

        ; Convert a 8-bit value to BCD
        ;
        ; Parameters: A value
        ; Returns: temp6-temp8 BCD value
        ; Modifies: A,Y,temp3-temp8

ConvertToBCD8:  sta temp5
                ldy #$08
CTB_Common:     lda #$00
                sta temp6
                sta temp7
                sta temp8
                sed
CTB_Loop:       asl temp3
                rol temp4
                rol temp5
                lda temp6
                adc temp6
                sta temp6
                lda temp7
                adc temp7
                sta temp7
                lda temp8
                adc temp8
                sta temp8
                dey
                bne CTB_Loop
                cld
                rts

        ; Convert a 16-bit value to BCD
        ;
        ; Parameters: A,Y value
        ; Returns: temp6-temp8 BCD value
        ; Modifies: A,Y,temp3-temp8

ConvertToBCD16: sta temp4
                sty temp5
                ldy #$10
                bne CTB_Common

        ; Convert a 24-bit value to BCD
        ;
        ; Parameters: A,X,Y value
        ; Returns: temp6-temp8 BCD value
        ; Modifies: A,Y,temp3-temp8

ConvertToBCD24: sta temp3
                stx temp4
                sty temp5
                ldy #$18
                bne CTB_Common

        ; Print null-terminated text on the text screen, with textjump support
        ;
        ; Parameters: A,X text pointer, temp1,temp2 column/row
        ; Returns: zpSrcLo-Hi incremented textpointer
        ; Modifies: A,X,Y,zpSrcLo-Hi,zpDestLo-Hi

PrintText:      sta zpSrcLo
                stx zpSrcHi
PT_Continue:    ldy temp2
                jsr GetRowAddress
                lda temp1
                jsr Add8
PT_Back:        ldy #$00
PT_Loop:        lda (zpSrcLo),y
                bmi PT_Jump
                beq PT_Done
                sta (zpDestLo),y
                iny
                bne PT_Loop
PT_Done:        iny
                tya
                ldx #zpSrcLo
                jmp Add8
PT_Jump:        pha
                tya
                ldx #zpDestLo
                jsr Add8
                iny
                lda (zpSrcLo),y
                sta zpSrcLo
                pla
                and #$7f
                sta zpSrcHi
                bpl PT_Back

        ; Get address of text row on screen 1
        ;
        ; Parameters: Y row
        ; Returns: zpDestLo-zpDestHi address
        ; Modifies: A,X,Y

GetRowAddress:  lda #40
                ldx #zpDestLo
                jsr MulU
                lda zpDestHi
                ora #>screen1
                sta zpDestHi
                rts

        ; Setup text screen
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X

SetupTextScreen:jsr BlankScreen
                lda #$02
                sta screen                      ;Set text screen mode
                lda #$0f
                sta scrollX
                ldx #$00
                stx SL_CSSScrollY+1
                stx Irq1_Bg1+1
STS_ClearScreenLoop:lda #$20
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
                bne STS_ClearScreenLoop
                rts

        ; Wait for exit from a fullscreen computer display either by pressing fire or key
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: Various

WaitForExit:    jsr FinishFrame
                jsr GetControls
                jsr GetFireClick
                bcs WFE_Done
                lda keyType
                bmi WaitForExit
WFE_Done:       rts

        ; Print multiple text rows
        ;
        ; Parameters: A,X text pointer, temp1,temp2 column/row
        ; Returns: zpSrcLo-Hi incremented textpointer
        ; Modifies: A,X,Y,zpSrcLo-Hi,zpDestLo-Hi

PrintMultipleRows:
                sta zpSrcLo
                stx zpSrcHi
PMR_Loop:       jsr PT_Continue
                inc temp2
                ldy #$00
                lda (zpSrcLo),y
                bne PMR_Loop
                rts
