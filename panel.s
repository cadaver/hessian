PANEL_TEXT_SIZE = 22
MENU_DELAY      = 12
MENU_PAUSEDELAY = 36
MENU_MOVEDELAY  = 3

INDEFINITE_TEXT_DURATION = $7f
INVENTORY_TEXT_DURATION = 50

REDRAW_ITEM     = $01
REDRAW_AMMO     = $02
REDRAW_SCORE    = $04

MENU_NONE       = 0
MENU_INVENTORY  = 1
MENU_PAUSE      = 2
MENU_DIALOGUE   = 3

HEALTHBAR_LENGTH = 7

        ; Subroutine to animate & draw a health bar
        ;
        ; Parameters: A value to display, X healthbar index (0 = health, 1 = battery), Y position
        ; Returns: -
        ; Modifies: A,X,Y,temp1-temp2

DrawHealthBar:  cmp displayedHealth,x
                beq DHB_Done
                bcc DHB_Decrement
DHB_Increment:  inc displayedHealth,x
                skip2
DHB_Decrement:  dec displayedHealth,x
                lda healthBarPosTbl,x           ;Start position
                tay
                clc
                adc #HEALTHBAR_LENGTH           ;End position
                sta temp2
                lda displayedHealth,x
                lsr
                lsr
                clc
                adc healthBarPosTbl,x
                sta temp1                       ;Whole chars end position
                lda #109
DHB_WholeCharsLoop:
                cpy temp1
                bcs DHB_WholeCharsDone
                sta panelScreen+24*40,y
                iny
                bne DHB_WholeCharsLoop
DHB_WholeCharsDone:
                lda displayedHealth,x
                and #$03
                beq DHB_NoHalfChar
                adc #104                        ;C=1
                sta panelScreen+24*40,y
                iny
DHB_NoHalfChar: lda #61
DHB_EmptyCharsLoop:
                cpy temp2
                bcs DHB_Done
                sta panelScreen+24*40,y
                iny
                bne DHB_EmptyCharsLoop
DHB_Done:       rts

        ; Finish frame. Update frame and update score panel
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

UpdatePanel:    lda actHp+ACTI_PLAYER
                lsr
                ldx #$00
                jsr DrawHealthBar
                lda battery+1
                lsr
                adc #$00                        ;Round upward
                ldx #$01
                jsr DrawHealthBar
                if SHOW_BATTERY > 0
                ldx #4
                lda battery+1
                jsr PrintHexByte
                lda battery
                jsr PrintHexByte
                endif
                lsr panelUpdateFlags
                bcc UP_SkipWeapon
                ldx #91
                stx panelScreen+23*40+32
                inx
                stx panelScreen+23*40+33
                inx
                stx panelScreen+23*40+34
                lda #$08
                sta colors+23*40+32
                sta colors+23*40+33
                sta colors+23*40+34
                ldy itemIndex
                ldx invType,y
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
                sta zpBitBuf                    ;Slice bitmask
                ldy #SPRH_DATA
                ldx #$01
                jsr UP_DrawSlice
                lsr zpBitBuf
                inx
                jsr UP_DrawSlice
                lsr zpBitBuf
                inx
                jsr UP_DrawSlice
UP_SkipWeapon:  lsr panelUpdateFlags
                bcc UP_SkipAmmo
                ldy itemIndex
                ldx invType,y
                lda itemMagazineSize-1,x
                sta temp2
                beq UP_Consumable
                bmi UP_MeleeWeapon
UP_Firearm:     lda plrReload
                bne UP_Reloading
                lda invMag,y                    ;Print rounds in magazine
                jsr ConvertToBCD8
                lda temp6
                ldx #35
                jsr PrintBCDDigits
                lda #"/"
                jsr PrintPanelChar
                ldy itemIndex
                lda invCount,y                  ;Get ammo in reserve
                sec
                sbc invMag,y
                ldy temp2
                ldx #temp7
                jsr DivU                        ;Divide by magazine size, add one
                cmp #$01                        ;if there's a remainder
                lda temp7
                adc #$00
                cmp #$0a                        ;More than 9 can not be printed, clamp
                bcc UP_MagCountOK
                lda #$09
UP_MagCountOK:  ora #$30
                sta panelScreen+23*40+38
                bne UP_SkipAmmo
UP_Consumable:  lda invType,y                   ;Draw the X for real consumables, but
                cmp #ITEM_FIRST_CONSUMABLE      ;not for weapons such as the minigun
                bcs UP_IsConsumable             ;that don't have magazines
                lda #32
                skip2
UP_IsConsumable:lda #42
                sta panelScreen+23*40+35
                lda invCount,y
                jsr ConvertToBCD8
                ldx #36
                jsr Print3BCDDigits
                jmp UP_SkipAmmo
UP_Reloading:   ldy #$07
                skip2
UP_MeleeWeapon: ldy #$03
                ldx #$03
UP_MeleeWeaponLoop:
                lda txtInf,y
                sta panelScreen+23*40+35,x
                dey
                dex
                bpl UP_MeleeWeaponLoop
UP_SkipAmmo:    lsr panelUpdateFlags
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
                lda temp6
                jsr PrintBCDDigits
                lda #"0"                        ;The final 0 is fixed, ie. score is internally stored
                jsr PrintPanelChar              ;as divided by 10
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

UM_RedrawNone:
ClearPanelText: ldx #$00
                ldy #$00
                beq PrintPanelText

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
                lda textRightMargin
                cmp zpSrcLo
                bcs UP_WordCmp
UP_EndLine:     stx zpBitsLo
                tya
                ldx #textLo
                jsr Add8
                ldx zpBitsLo
                cpx textRightMargin
                bcs UP_PrintTextDone
UP_ClearEndOfLine:
UP_ClearLoop:   lda #$20
                jsr PrintPanelChar
                cpx textRightMargin
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
                cmp #$20
                bne UP_SpaceLoopDone
                cpx textRightMargin
                bcs UP_SpaceSkip
                jsr PrintPanelChar
UP_SpaceSkip:   iny
                bne UP_SpaceLoop
UP_SpaceLoopDone:
                cpx textRightMargin
                bcc UP_PrintTextLoop
                bcs UP_EndLine

UP_DrawSlice:   txa
                clc
                adc #$07
                sta zpDestLo
UP_DrawSliceLoop:
                lda zpBitBuf
                and #$01
                beq UP_EmptySlice
                lda (zpSrcLo),y
                iny
UP_EmptySlice:  sta textChars+91*8,x
                inx
                cpx zpDestLo
                bcc UP_DrawSliceLoop
                rts

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
                jmp UP_ContinueText

        ; Update menu system (inventory / pause / dialogue) in the panel.
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
SetMenuMode:    stx menuMode
                lda #$00
                sta menuCounter
SMM_Redraw:     lda menuRedrawTblLo,x
                sta SMM_RedrawJump+1
                lda menuRedrawTblHi,x
                sta SMM_RedrawJump+2
                lda #SFX_SELECT
                jsr PlaySfx
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
                cmp #KEY_M
                beq UM_Medkit
                cmp #KEY_B
                beq UM_Battery
                if ITEM_CHEAT>0
                cmp #KEY_Z
                beq UM_PrevItem
                cmp #KEY_X
                beq UM_NextItem
                endif
UM_ControlDone: rts
UM_Medkit:      lda #ITEM_MEDKIT
                skip2
UM_Battery:     lda #ITEM_BATTERY
                jsr FindItem
                bcc UM_ControlDone
UM_Reload:      jmp UseItem

        ; Inventory
        
UM_Inventory:   ldx #MENU_NONE                  ;Check for exiting inventory or waiting for
                lda joystick
                ldy #$ff                        ;pause menu
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
                ldy itemIndex
                jsr MenuControl                 ;Check for selecting items
                lsr
                bcs UM_MoveLeft
                lsr
                bcs UM_MoveRight
                lda joystick
                cmp #JOY_FIRE+JOY_DOWN          ;Check for reloading weapon
                bne UM_MoveDone
                cmp prevJoy
                bne UM_Reload
UM_MoveDone:    rts

UM_MoveRight:   lda invType+1,y
                beq UM_MoveDone
                inc itemIndex
                bpl RedrawInventory             ;Redraw the inventory explicitly, as items
UM_MoveLeft:    tya                             ;can also be selected in NONE mode with keys
                beq UM_MoveDone
                dec itemIndex
                bpl RedrawInventory
                if ITEM_CHEAT>0
UM_PrevItem:    lda #$ff
                skip2
UM_NextItem:    lda #$01
                clc
                adc invType+1
                sta invType+1
                tax
                lda itemDefaultMaxCount-1,x
                sta invCount+1
                lda #$00
                sta invMag+1
                lda #$01
                sta itemIndex
                jmp SetPanelRedrawItemAmmo
                endif

RedrawInventory:ldx #MENU_INVENTORY
                skip2
RedrawMenu:     ldx menuMode
                jmp SMM_Redraw
SetMenuMode2:   jmp SetMenuMode

        ; Dialogue

UM_Dialogue:    ldx #MENU_NONE
                lda textTime
                beq SetMenuMode2
                jsr GetFireClick                ;Speed up levelup text by pressing fire
                bcc UM_LUNoFire
                lda #$01
                sta textTime
UM_LUNoFire:    rts

        ; Pause menu

UM_PauseMenuExit:
                ldx #MENU_NONE
                beq SetMenuMode2
UM_PauseMenuLeft:
                tya
                beq UM_PauseMenuDone
                dec menuCounter
                bpl RedrawMenu
UM_PauseMenuRight:
                tya
                bne UM_PauseMenuDone
                inc menuCounter
                bpl RedrawMenu

UM_PauseMenu:   ldy menuCounter
                jsr GetFireClick
                bcs UM_PauseMenuAction
                lda keyType
                bmi UM_PauseMenuNoExit
                lda actT+ACTI_PLAYER            ;If no player actor anymore, can not exit but must choose
                bne UM_PauseMenuExit
UM_PauseMenuNoExit:
                jsr MenuControl
                lsr
                bcs UM_PauseMenuLeft
                lsr
                bcs UM_PauseMenuRight
UM_PauseMenuDone:
                rts
UM_PauseMenuAction:
                tya
                beq UM_ResumeOrRetry
                sta ES_LoadedScriptFile+1       ;Always reload title script (A!=0)
                lda #<EP_TITLE                  ;Execute titlescreen in "save" mode
                ldx #>EP_TITLE                  ;(parameter 1)
                ldy #$01
                jmp ExecScriptParam

UM_ResumeOrRetry:
                jsr UM_PauseMenuExit
                lda actHp+ACTI_PLAYER
                bne UM_PauseMenuDone
                jmp RestartCheckpoint

        ; Menu redraw routines

        ; Inventory

UM_RedrawInventory:
                lda #$00
                sta UM_ForceRefresh+1
                inc textLeftMargin
                ldx itemIndex
                lda invType,x
                jsr GetItemName
                ldy menuMode                    ;When using keys to select item,
                bne UM_RedrawActive             ;only show the text for a short time
                ldy #INVENTORY_TEXT_DURATION
                skip2
UM_RedrawActive:ldy #INDEFINITE_TEXT_DURATION
                jsr PrintPanelText
                ldx itemIndex
                ldy invType+1,x
UM_RedrawCommon:
                dec textLeftMargin
UM_DrawSelectionArrows:
                lda #$20
                cpx #$00
                beq UM_NoLeftArrow
                lda #60
UM_NoLeftArrow: sta panelScreen+23*40+9
                lda #$20
                cpy #$00
                beq UM_NoRightArrow
                lda #62
UM_NoRightArrow:sta panelScreen+23*40+30
                jmp SetPanelRedrawItemAmmo      ;Redraw item & ammo next time panel is updated

        ; Pause menu

UM_RedrawPauseMenu:
                lda #<txtPauseResume
                ldx #>txtPauseResume
                ldy actHp+ACTI_PLAYER
                bne UM_PauseTextOK
                lda #<txtPauseRetry
                ldx #>txtPauseRetry
UM_PauseTextOK: jsr PrintPanelTextIndefinite
                lda #21
                sta zpBitsLo
                lda #<txtPauseSave
                ldx #>txtPauseSave
                jsr ContinuePanelText
                ldy #1
UM_PauseMenuArrowLoop:
                ldx pauseMenuArrowPosTbl,y
                lda #$20
                cpy menuCounter
                bne UM_PauseMenuSpace
                lda #62
UM_PauseMenuSpace:
                sta panelScreen+23*40,x
                dey
                bpl UM_PauseMenuArrowLoop
UM_RedrawDialogue:
                rts

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
PBCD_3DigitsOK: jsr PrintBCDDigit
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
                sta panelScreen+23*40,x
                inx
                pla
PrintBCDDigit:  and #$0f
                ora #$30
PrintPanelChar: sta panelScreen+23*40,x
                lda #$01
                sta colors+23*40,x
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
