PANEL_TEXT_SIZE = 22
MENU_DELAY      = 12
MENU_PAUSEDELAY = 37
MENU_MOVEDELAY  = 3

INDEFINITE_TEXT_DURATION = $7f
INVENTORY_TEXT_DURATION = 50
XP_TEXT_DURATION = 50

REDRAW_ITEM     = $01
REDRAW_AMMO     = $02

MENU_NONE       = 0
MENU_INVENTORY  = 1
MENU_SKILLDISPLAY = 2
MENU_LEVELUPMSG = 3
MENU_LEVELUPCHOICE = 4
MENU_PAUSE      = 5

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
                cmp displayedHealth
                beq UP_HealthDone
                bcs UP_IncrementHealth
UP_DecrementHealth:
                dec displayedHealth
                skip2
UP_IncrementHealth:
                inc displayedHealth
UP_RedrawHealth:ldx #$00
                lda displayedHealth
                lsr
                lsr
                beq UP_NoWholeChars
                sta zpSrcLo
                lda #$10
UP_WholeCharsLoop:
                sta screen1+SCROLLROWS*40+41,x
                inx
                cpx zpSrcLo
                bcc UP_WholeCharsLoop
UP_NoWholeChars:lda displayedHealth
                and #$03
                beq UP_NoHalfChar
                clc
                adc #$0c
                sta screen1+SCROLLROWS*40+41,x
                inx
UP_NoHalfChar:  lda #$20
                bne UP_EmptyCharsCmp
UP_EmptyCharsLoop:
                sta screen1+SCROLLROWS*40+41,x
                inx
UP_EmptyCharsCmp:
                cpx #HP_PLAYER/8
                bcc UP_EmptyCharsLoop
UP_HealthDone:  lda panelUpdateFlags
                lsr
                bcc UP_SkipWeapon
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
                ldx #$00
                jsr UP_DrawSlice
                lsr zpBitBuf
                inx
                jsr UP_DrawSlice
UP_SkipWeapon:  lda panelUpdateFlags
                and #REDRAW_AMMO
                beq UP_SkipAmmo
                ldy itemIndex
                ldx invType,y
                lda itemMagazineSize-1,x
                sta temp4
                beq UP_Consumable
                bmi UP_MeleeWeapon
UP_Firearm:     lda invMag,y                    ;Print rounds in magazine
                bmi UP_Reloading
                jsr ConvertToBCD8
                lda temp7
                ldx #35
                jsr PrintBCDDigits
                lda #"/"
                jsr PrintPanelChar
                ldy itemIndex
                lda invCount,y                  ;Get ammo in reserve
                sec
                sbc invMag,y
                ldy temp4
                ldx #temp7
                jsr DivU                        ;Divide by magazine size, add one
                cmp #$01                        ;if there's a remainder
                lda temp7
                adc #$00
                cmp #$0a                        ;More than 9 can not be printed, clamp
                bcc UP_MagCountOK
                lda #$09
UP_MagCountOK:  ora #$30
                sta screen1+SCROLLROWS*40+40+38
                bne UP_SkipAmmo
UP_Consumable:  lda invType,y                   ;Draw the X for real consumables, but
                cmp #ITEM_FIRST_CONSUMABLE      ;not for weapons such as the minigun
                bcs UP_TrueConsumable           ;that don't have magazines
                lda #32
                skip2
UP_TrueConsumable:
                lda #42
                sta screen1+SCROLLROWS*40+40+35
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
                sta screen1+SCROLLROWS*40+40+35,x
                dey
                dex
                bpl UP_MeleeWeaponLoop
UP_SkipAmmo:    lda #$00
                sta panelUpdateFlags
                lda textTime
                beq UP_TextDone
                cmp #INDEFINITE_TEXT_DURATION*2
                bcs UP_TextDone
                dec textTime
                beq UP_UpdateText
UP_TextDone:    rts
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
                lda #$00
                sta zpSrcLo
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
                txa
                clc
                adc zpSrcLo
                sta UP_WordCmp+1
                cmp textRightMargin
                beq UP_WordCmp
                bcc UP_WordCmp
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
UP_WordCmp:     cpx #$00
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
                ora #$07
                sta zpDestLo
UP_DrawSliceLoop:
                lda zpBitBuf
                and #$01
                beq UP_EmptySlice
                lda (zpSrcLo),y
                iny
UP_EmptySlice:  sta textChars+35*8,x
                inx
                cpx zpDestLo
                bcc UP_DrawSliceLoop
                rts

        ; Clear the panel text
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X

ClearPanelText: ldx #$00
                ldy #$00

        ; Print text to panel, possibly multi-line
        ;
        ; Parameters: A,X text address, Y delay in game logic frames (25 = 1 sec)
        ; Returns: -
        ; Modifies: A

PrintPanelText: sty textDelay
                sta textLo
                stx textHi
                jmp UP_UpdateText

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

        ; Update menu system (inventory) in the panel. Also handle XP messages and leveling up
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

SetMenuMode:    stx menuMode
                lda #$00
                sta menuCounter
SMM_Redraw:     lda menuRedrawTblLo,x
                sta SMM_RedrawJump+1
                lda menuRedrawTblHi,x
                sta SMM_RedrawJump+2
                lda #SFX_SELECT
                cpx #MENU_LEVELUPMSG
                bne SMM_SoundOK
                lda #SFX_POWERUP
SMM_SoundOK:    jsr PlaySfx
SMM_RedrawJump: jmp $0000

        ; Menu logic routines

        ; None

UM_PrintXP:     jmp PrintXPMessage

UM_None:        ldx #MENU_PAUSE
                lda actT+ACTI_PLAYER            ;If vanished after death, forcibly enter pause menu
                beq SetMenuMode
                lda keyType
                cmp #KEY_RUNSTOP
                beq SetMenuMode
                ldx #MENU_LEVELUPMSG
                lda lastReceivedXP              ;If XP received, show XP message now
                bne UM_PrintXP
                lda textTime
                bne UM_NoLevelUp
                lda levelUp                     ;Check for pending levelup: begin if no other
                bne SetMenuMode                 ;messages being displayed
UM_NoLevelUp:   ldx #MENU_INVENTORY             ;Check for entering inventory by holding firebutton;
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
                if ITEM_CHEAT>0
                cmp #KEY_Z
                beq UM_PrevItem
                cmp #KEY_X
                beq UM_NextItem
                endif
UM_ControlDone: rts
UM_Heal:        lda #ITEM_MEDKIT
                jsr FindItem
                bcc UM_ControlDone
UM_Reload:      jmp UseItem

        ; Inventory
        
UM_Inventory:   ldx #MENU_SKILLDISPLAY          ;Check for entering skill display screen
                lda joystick
                cmp #JOY_FIRE+JOY_UP
                beq SetMenuMode2
                ldx #MENU_NONE                  ;Check for exiting inventory or waiting for
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
                ldy itemIndex
                adc invType,y
                sta invType,y
                tax
                lda itemDefaultMaxCount-1,x
                sta invCount,y
                lda #$00
                sta invMag,y
                jmp SetPanelRedrawItemAmmo
                endif

RedrawInventory:ldx #MENU_INVENTORY
                skip2
RedrawMenu:     ldx menuMode
                jmp SMM_Redraw
SetMenuMode2:   jmp SetMenuMode

        ; Skill display

UM_SkillDisplay:ldx #MENU_NONE                  ;Exit either into inventory (fire held)
                lda joystick                    ;or to NONE mode (fire released)
                cmp #JOY_FIRE
                bcc SetMenuMode2
                inx
                cmp #JOY_FIRE+JOY_UP
                beq UM_SkillDisplayDone
                jsr SetMenuMode                 ;When returning to inventory, do not
                dec menuCounter                 ;allow to enter pausemenu anymore until
UM_SkillDisplayDone:                            ;fire released
                rts

        ; Levelup text
        
UM_LevelUpMsg:  ldx #MENU_LEVELUPCHOICE
                lda textTime
                beq SetMenuMode2
                jsr GetFireClick                ;Speed up levelup text by pressing fire
                bcc UM_LUNoFire
                lda #$01
                sta textTime
UM_LUNoFire:    rts

        ; Levelup choice

UM_LevelUpChoice:
                ldy menuCounter
                jsr GetFireClick
                bcs UM_LUFinish
                jsr MenuControl
                lsr
                bcs UM_LUMoveLeft
                lsr
                bcs UM_LUMoveRight
UM_LUMoveDone:  rts
UM_LUMoveLeft:  tya
                beq UM_LUMoveDone
                dec menuCounter
                bpl RedrawMenu
UM_LUMoveRight: lda improveList+1,y
                bmi UM_LUMoveDone
                inc menuCounter
                bpl RedrawMenu
UM_LUFinish:    ldx improveList,y
                inc plrSkills,x
                lda #SFX_POWERUP
                jsr PlaySfx
                jsr ApplySkills
                txa                             ;Hack: give 0 XP now to correctly process several
                jsr GiveXP                      ;levelups in a row
UM_PauseMenuExit:
                ldx #MENU_NONE
                beq SetMenuMode2

        ; Pause menu

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
                cmp #KEY_RUNSTOP
                bne UM_PauseMenuNoExit
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
                lda #<EP_TITLE                  ;Execute titlescreen in "save" mode
                ldy #>EP_TITLE
                ldx #$01
                inc ES_LoadedScriptFile+1       ;Always reload title script
                jmp ExecScript

UM_ResumeOrRetry:
                jsr UM_PauseMenuExit
                lda actHp+ACTI_PLAYER
                bne UM_PauseMenuDone
                jmp RestartCheckpoint

        ; Menu redraw routines

        ; None

UM_RedrawNone:  jmp ClearPanelText

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
                lda #21
UM_NoLeftArrow: sta screen1+SCROLLROWS*40+40+8
                lda #$20
                cpy #$00
                beq UM_NoRightArrow
                lda #22
UM_NoRightArrow:sta screen1+SCROLLROWS*40+40+31
                jmp SetPanelRedrawItemAmmo      ;Redraw item & ammo next time panel is updated

        ; Levelup skill select

UM_RedrawLevelUpChoice:
                inc textLeftMargin
                ldx menuCounter
                ldy improveList,x
                sty temp1
                lda skillNameLo,y
                ldx skillNameHi,y
                ldy #INDEFINITE_TEXT_DURATION
                jsr PrintPanelText
                ldx temp1
                lda plrSkills,x
                ldx zpBitsLo
                inx
                clc
                adc #$31
                pha
                jsr PrintPanelChar
                lda #"-"
                jsr PrintPanelChar
                lda #">"
                jsr PrintPanelChar
                pla
                adc #1
                jsr PrintPanelChar
                ldx menuCounter
                ldy improveList+1,x
                bpl UM_RedrawCommon
                ldy #$00
                bpl UM_RedrawCommon

        ; Levelup message. Also actually levels up the player character

UM_RedrawLevelUpMsg:
                inc xpLevel
                ldx #<xpLo
                ldy #<xpLimitLo
                jsr Sub16
                lda xpLevel
                cmp #MAX_LEVEL
                bcc LU_NotMaxLevel
                lda #<999
                sta xpLimitLo
                lda #>999
                sta xpLimitHi
                bne LU_XPLimitDone
LU_NotMaxLevel: lda #NEXT_XPLIMIT
                ldx #<xpLimitLo
                jsr Add8
LU_XPLimitDone: lda #HP_PLAYER
                sta actHp+ACTI_PLAYER           ;Fill health when leveled up
                lda #$20
                ldx #2
LU_ClearLevelText:
                sta txtLevelUpLevel,x
                dex
                bpl LU_ClearLevelText
                lda xpLevel
                jsr ConvertToBCD8
                ldx #80
                jsr PrintBCDDigitsNoZeroes
LU_CopyLevelText:
                lda screen1+23*40-1,x
                sta txtLevelUpLevel-81,x
                dex
                cpx #81
                bcs LU_CopyLevelText
                lda #<txtLevelUp
                ldx #>txtLevelUp
                ldy #XP_TEXT_DURATION
                jsr PrintPanelText
                ldx #$00
                ldy #$00
                sty levelUp                     ;Reset pending levelup flag
LU_BuildSkillList:
                lda plrSkills,y                 ;Build list of skills that can be improved
                cmp #MAX_SKILL
                bcs LU_AtMaximum
                tya
                sta improveList,x
                inx
LU_AtMaximum:   iny
                cpy #NUM_SKILLS
                bcc LU_BuildSkillList
                lda #$ff
                sta improveList,x               ;Endmark
                rts

        ; Show XP & skills

UM_RedrawSkillDisplay:
                lda #<txtSkillDisplay
                ldx #>txtSkillDisplay
                ldy #INDEFINITE_TEXT_DURATION
                jsr PrintPanelText
                ldx #11
                jsr PXPM_XPLevel
                ldx #31
                ldy #NUM_SKILLS-1
UM_SkillLoop:   lda plrSkills,y
                clc
                adc #17
                sta screen1+SCROLLROWS*40+40,x
                lda #$0d
                sta colors+SCROLLROWS*40+40,x
                dex
                dex
                dey
                bpl UM_SkillLoop
                rts

        ; Pause menu

UM_RedrawPauseMenu:
                lda #<txtPauseResume
                ldx #>txtPauseResume
                ldy actHp+ACTI_PLAYER
                bne UM_PauseTextOK
                lda #<txtPauseRetry
                ldx #>txtPauseRetry
UM_PauseTextOK: ldy #INDEFINITE_TEXT_DURATION
                jsr PrintPanelText
                lda #<txtPauseSave
                ldx #>txtPauseSave
                jsr ContinuePanelText
                ldy #1
UM_PauseMenuArrowLoop:
                ldx pauseMenuArrowPosTbl,y
                lda #$20
                cpy menuCounter
                bne UM_PauseMenuSpace
                lda #22
UM_PauseMenuSpace:
                sta screen1+SCROLLROWS*40+40,x
                dey
                bpl UM_PauseMenuArrowLoop
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

        ; Print message of received XP
        ;
        ; Parameters: A XP amount
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,loader temp vars

PrintXPMessage: jsr ConvertToBCD8
                jsr ClearPanelText
                lda #XP_TEXT_DURATION*2
                sta textTime
                lda #$00
                sta lastReceivedXP
                ldx textLeftMargin
                lda #"+"
                jsr PrintPanelChar
                jsr Print3BCDDigitsNoZeroes
                inx
                ldy #$00
PXPM_Text:      lda txtXP,y
                jsr PrintPanelChar
                iny
                cpy #$07
                bcc PXPM_Text
PXPM_XPLevel:   lda xpLevel
                jsr ConvertToBCD8
                jsr PrintBCDDigitsNoZeroes
                inx
                lda xpLo
                ldy xpHi
                jsr ConvertToBCD16
                jsr Print3BCDDigits
                lda #"/"
                jsr PrintPanelChar
                lda xpLimitLo
                ldy xpLimitHi
                jsr ConvertToBCD16
                jmp Print3BCDDigits

        ; Convert a 8-bit value to BCD
        ;
        ; Parameters: A value
        ; Returns: temp7-temp8 BCD value
        ; Modifies: A,Y,temp5-temp8

ConvertToBCD8:  sta temp6
                ldy #$08
CTB_Common:     lda #$00
                sta temp7
                sta temp8
                sed
CTB_Loop:       asl temp5
                rol temp6
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

        ; Convert a 16-bit value to BCD (max. 4 digits)
        ;
        ; Parameters: A,Y value
        ; Returns: temp7-temp8 BCD value
        ; Modifies: A,Y,temp5-temp8

ConvertToBCD16: sta temp5
                sty temp6
                ldy #$10
                bne CTB_Common

        ; Print a 3-digit BCD value to panel
        ;
        ; Parameters: temp7-temp8 value, X position
        ; Returns: X position incremented
        ; Modifies: A

Print3BCDDigits:lda temp8
PBCD_3DigitsOK: jsr PrintBCDDigit
                lda temp7

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
                sta screen1+SCROLLROWS*40+40,x
                inx
                pla
PrintBCDDigit:  and #$0f
                ora #$30
PrintPanelChar: sta screen1+SCROLLROWS*40+40,x
                lda #$01
                sta colors+SCROLLROWS*40+40,x
                inx
CL_Done:        rts

        ; Print a 3-digit BCD value to panel without leading zeroes
        ;
        ; Parameters: temp7-temp8 value, X position
        ; Returns: X position incremented
        ; Modifies: A

Print3BCDDigitsNoZeroes:
                lda temp8
                bne PBCD_3DigitsOK

        ; Print a 2-digit BCD value to panel without leading zeroes
        ;
        ; Parameters: temp7-temp8 value, X position
        ; Returns: X position incremented
        ; Modifies: A

PrintBCDDigitsNoZeroes:
                lda temp7
                cmp #$10
                bcs PrintBCDDigits
                bcc PrintBCDDigit
