PANEL_TEXT_SIZE = 22
MENU_DELAY      = 13
MENU_MOVEDELAY  = 3

INDEFINITE_TEXT_DURATION = $7f
INVENTORY_TEXT_DURATION = 50
XP_TEXT_DURATION = 100

REDRAW_ITEM     = $01
REDRAW_AMMO     = $02

        ; Finish frame. Scroll player, update frame and update score panel
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,loader temp vars

FinishFrame:    

        ; Scroll screen around player actor, then update frame
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp1-temp6
        
ScrollPlayer:   lda actT+ACTI_PLAYER            ;Skip if player actor does not exist
                beq SP_Skip
                ldx #ACTI_PLAYER
                jsr GetActorCharCoords
                cmp #SCRCENTER_X-2
                bcs SP_NotLeft1
                dex
SP_NotLeft1:    cmp #SCRCENTER_X
                bcs SP_NotLeft2
                dex
SP_NotLeft2:    cmp #SCRCENTER_X+1
                bcc SP_NotRight1
                inx
SP_NotRight1:   cmp #SCRCENTER_X+3
                bcc SP_NotRight2
                inx
SP_NotRight2:   stx scrollSX
                ldx #$00
                cpy #SCRCENTER_Y-3
                bcs SP_NotUp1
                dex
SP_NotUp1:      cpy #SCRCENTER_Y-1
                bcs SP_NotUp2
                dex
SP_NotUp2:      cpy #SCRCENTER_Y+2
                bcc SP_NotDown1
                inx
SP_NotDown1:    cpy #SCRCENTER_Y+4
                bcc SP_NotDown2
                inx
SP_NotDown2:    stx scrollSY
SP_Skip:        
                jsr UpdateFrame

        ; Update scorepanel (health, text display, weapon, ammo)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,loader temp vars

UpdatePanel:    lda actHp+ACTI_PLAYER
                cmp displayedHealth
                beq UP_HealthDone
                bcs UP_IncrementHealth
UP_DecrementHealth:
                dec displayedHealth
                bpl UP_RedrawHealth
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
                cpx #HP_PLAYER/4
                bcc UP_EmptyCharsLoop
UP_HealthDone:  lda panelUpdateFlags
                lsr
                bcc UP_SkipWeapon
                ldy itemIndex
                ldx invType,y
                lda itemFrames,x
                asl
                tay
                lda fileLo+C_WEAPON
                sta zpBitsLo
                lda fileHi+C_WEAPON
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
UP_Consumable:  lda #42
                sta screen1+SCROLLROWS*40+40+35
                lda invCount,y
                jsr ConvertToBCD8
                ldx #36
                jsr Print3BCDDigits
                jmp UP_SkipAmmo
UP_Reloading:   ldy #$07
                bne UP_Reloading2
UP_MeleeWeapon: ldy #$03
UP_Reloading2:  ldx #$03
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
UP_EmptySlice:  sta textChars+23*8,x
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

UM_LUFinish:    ldx improveList,y
                inc plrSkills,x
                lda #SFX_POWERUP
                jsr PlaySfx
                jsr ClearPanelText
                jsr ApplySkills
                lda #$00                        ;Hack: give 0 XP now to correctly process several
                jmp GiveXP                      ;levelups in a row

UM_LevelUp:     cmp #$fe
                beq UM_LUChoice
                lda textTime
                bne UM_LUTextInProgress
                dec levelUp                     ;When text display finished, start the choice loop
                sta skillChoice
                sta menuMoveDelay
                jmp UM_Refresh
UM_LUTextInProgress:
                jsr GetFireClick                ;Speed up levelup text by pressing fire
                bcc UM_LUNoFire
                lda #$01
                sta textTime
UM_LUNoFire:
UM_LUMoveDone:  rts
UM_LUChoice:    ldy skillChoice
                jsr GetFireClick
                bcs UM_LUFinish
                lda menuMoveDelay
                beq UM_LUNoMoveDelay
                dec menuMoveDelay
                rts
UM_LUNoMoveDelay:
                lda joystick
                cmp #JOY_FIRE
                bcs UM_LUMoveDone
                cmp #JOY_RIGHT
                bcc UM_LUNoMoveRight
UM_LUMoveRight: lda improveList+1,y
                bmi UM_LUMoveDone
                inc skillChoice
UM_LUMoveCommon:jmp UM_MoveCommon
UM_LUNoMoveRight:
                cmp #JOY_LEFT
                bcc UM_LUMoveDone
UM_LUMoveLeft:  tya
                beq UM_LUMoveDone
                dec skillChoice
                bpl UM_LUMoveCommon

UpdateMenu:     ldx menuCounter
                lda actHp+ACTI_PLAYER           ;If dead, close inventory, do not process leveling
                beq UM_Close
                lda levelUp                     ;Check if levelup already in progress
                bmi UM_LevelUp
                cpx #MENU_DELAY
                beq UM_NoXPMessage              ;If inventory open, no XP messages
                lda lastReceivedXP
                bne UM_PrintXP
                lda levelUp                     ;Check for pending levelup: begin if
                beq UM_NoXPMessage              ;no other messages displayed
                lda textTime
                bne UM_NoXPMessage
                jmp BeginLevelUp
UM_PrintXP:     jsr PrintXPMessage
                ldx menuCounter
UM_NoXPMessage: lda joystick
                cmp #JOY_FIRE
                bcc UM_Close
                cpx #MENU_DELAY
                beq UM_IsActive
                bcs UM_KeyControl
                cmp #JOY_FIRE
                bne UM_Inactivate
                inx
                cpx #MENU_DELAY
                bcs UM_Open
UM_StoreCounter:stx menuCounter
                lda actHp+ACTI_PLAYER
                beq UM_NotReloadKey
UM_KeyControl:  ldy itemIndex
                lda keyType                     ;Can also use , & . keys to select items
                cmp #KEY_COMMA
                bne UM_NotPreviousKey
                jmp UM_MoveLeft
UM_NotPreviousKey:
                cmp #KEY_COLON
                bne UM_NotNextKey
                jmp UM_MoveRight
UM_NotNextKey:  cmp #KEY_R                      ;Use R to reload
                bne UM_NotReloadKey
                jmp UM_Reload
UM_NotReloadKey:rts
UM_Inactivate:  ldx #$ff
                bne UM_StoreCounter

UM_Close:       cpx #MENU_DELAY
                bne UM_WasNotOpen
                jsr ClearPanelText
UM_WasNotOpen:  ldx #$00
                beq UM_StoreCounter

UM_Open:        stx menuCounter
                lda #$00
                sta menuMoveDelay
                beq UM_Refresh

UM_IsActive:    cmp #JOY_FIRE+JOY_UP            ;If fire+up held, show XP and skills
                bne UM_ForceRefresh
                cmp prevJoy
                beq UM_IsShowingSkills
                jmp UM_ShowSkills
UM_ForceRefresh:ldy #$00                        ;Check for forced refresh (when inventory
                bne UM_Refresh                  ;modified while open)
                ldy menuMoveDelay
                beq UM_NoMoveDelay
                dec menuMoveDelay
                rts
UM_NoMoveDelay: ldy itemIndex
                cmp #JOY_FIRE+JOY_RIGHT
                bcc UM_NoMoveRight
UM_MoveRight:   lda invType+1,y
                beq UM_NoMoveRight
                inc itemIndex
UM_MoveCommon:  ldy #MENU_MOVEDELAY
                lda joystick                    ;If joystick held, use smaller move delay
                cmp prevJoy
                bne UM_NoDelayReduce
                dey
UM_NoDelayReduce:
                sty menuMoveDelay
                bne UM_Refresh
UM_NoMoveRight: cmp #JOY_FIRE+JOY_LEFT
                bcc UM_NoMoveLeft
UM_MoveLeft:    cpy #$00
                beq UM_NoMoveLeft
                dec itemIndex
                bpl UM_MoveCommon
UM_NoMoveLeft:  cmp #JOY_FIRE+JOY_DOWN
                bne UM_NoReload
                cmp prevJoy
                beq UM_NoReload
UM_Reload:      ldx invType,y                   ;Do not reload if already full magazine
                lda invMag,y                    ;or already reloading
                bmi UM_NoReload
                cmp itemMagazineSize-1,x
                bcs UM_NoReload
                cmp invCount,y
                bcs UM_NoReload
                lda #$00                        ;Initiate reload by zeroing magazine
                sta invMag,y
UM_IsShowingSkills:
UM_NoReload:    rts

UM_Refresh:     lda #$00
                sta UM_ForceRefresh+1
                inc textLeftMargin
                lda levelUp
                bne UM_RefreshSkillChoice
                ldx itemIndex
                lda invType,x
                jsr GetItemName
                ldy menuCounter                 ;When using keys to select item,
                cpy #MENU_DELAY                 ;only show the text for a short time
                beq UM_RefreshActive
                ldy #INVENTORY_TEXT_DURATION
                bne UM_RefreshInactive
UM_RefreshActive:
                ldy #INDEFINITE_TEXT_DURATION
UM_RefreshInactive:
                jsr PrintPanelText
                ldx itemIndex
                ldy invType+1,x
UM_RefreshCommon:
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
UM_RefreshSound:lda #SFX_SELECT
                jsr PlaySfx
                jmp SetPanelRedrawItemAmmo      ;Redraw item & ammo next time panel is updated

UM_RefreshSkillChoice:
                ldx skillChoice
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
                ldx skillChoice
                ldy improveList+1,x
                bpl UM_RefreshCommon
                ldy #$00
                bpl UM_RefreshCommon

UM_ShowSkills:  sta UM_ForceRefresh+1           ;Restore normal view when joystick
                lda #<txtSkillDisplay           ;released
                ldx #>txtSkillDisplay
                ldy #INDEFINITE_TEXT_DURATION
                jsr PrintPanelText
                ldx #11
                jsr PXPM_XPLevel
                ldx #23
                ldy #0
UM_SkillLoop:   lda plrSkills,y
                clc
                adc #17
                sta screen1+SCROLLROWS*40+40,x
                lda #$0d
                sta colors+SCROLLROWS*40+40,x
                inx
                inx
                iny
                cpy #NUM_SKILLS
                bcc UM_SkillLoop
                bcs UM_RefreshSound

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
                rts

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
