PANEL_TEXT_SIZE = 22
MENU_DELAY      = 17
MENU_MOVEDELAY  = 3

INDEFINITE_TEXT_DURATION = $7f
INVENTORY_TEXT_DURATION = 50

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
                cmp #SCRCENTER_X-3
                bcs SP_NotLeft1
                dex
SP_NotLeft1:    cmp #SCRCENTER_X-1
                bcs SP_NotLeft2
                dex
SP_NotLeft2:    cmp #SCRCENTER_X+2
                bcc SP_NotRight1
                inx
SP_NotRight1:   cmp #SCRCENTER_X+4
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
                lsr zpBitBuf
                inx
                jsr UP_DrawSlice
UP_SkipWeapon:  lda panelUpdateFlags
                and #REDRAW_AMMO
                beq UP_SkipAmmo
                ldy itemIndex
                ldx invType,y
                lda itemMagazineSize-1,x
                sta temp5
                beq UP_Consumable
                bmi UP_MeleeWeapon
UP_Firearm:     lda invMag,y                    ;Print rounds in magazine
                bmi UP_Reloading
                jsr ConvertToBCD8
                lda temp7
                ldx #35
                jsr PrintBCDDigits
                lda #"/"
                sta screen1+SCROLLROWS*40+40+37
                ldy itemIndex
                lda invCount,y                  ;Get ammo in reserve
                sec
                sbc invMag,y
                ldy temp5
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
                lda temp8
                jsr PrintBCDDigit
                lda temp7
                jsr PrintBCDDigits
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
                lda #$20
UP_ClearLoop:   sta screen1+SCROLLROWS*40+40,x
                inx
                cpx textRightMargin
                bcc UP_ClearLoop
UP_PrintTextDone:
                rts
UP_WordLoop:    lda (textLo),y
                sta screen1+SCROLLROWS*40+40,x
                inx
                iny
UP_WordCmp:     cpx #$00
                bcc UP_WordLoop
UP_SpaceLoop:   lda (textLo),y
                beq UP_EndLine
                cmp #$20
                bne UP_SpaceLoopDone
                cpx textRightMargin
                bcs UP_SpaceSkip
                sta screen1+SCROLLROWS*40+40,x
                inx
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
UP_EmptySlice:  sta textChars+17*8,x
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

        ; Update menu system (inventory) in the panel
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,loader temp vars

UpdateMenu:     ldx menuCounter
                lda actHp+ACTI_PLAYER           ;Close inventory if dead
                beq UM_Close
                lda joystick
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
                lda keyType                     ;Can also use Z & X keys to select items
                cmp #KEY_Z
                bne UM_NotPreviousKey
                jmp UM_MoveLeft
UM_NotPreviousKey:
                cmp #KEY_X
                bne UM_NotNextKey
                jmp UM_MoveRight
UM_NotNextKey:  cmp #KEY_R                      ;Use R to reload
                bne UM_NotReloadKey
                jmp UM_Reload
UM_NotReloadKey:rts
UM_Inactivate:  ldx #$ff
                bne UM_StoreCounter

UM_Close:       cpx #MENU_DELAY
                bcc UM_WasNotOpen
                jsr ClearPanelText
UM_WasNotOpen:  ldx #$00
                beq UM_StoreCounter

UM_Open:        stx menuCounter
                lda #$00
                sta menuMoveDelay
                beq UM_Refresh

UM_IsActive:    
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
UM_Reload:      ldx invType,y                   ;Do not reload if already full magazine
                lda invMag,y                    ;or already reloading
                bmi UM_NoReload
                cmp itemMagazineSize-1,x
                bcs UM_NoReload
                cmp invCount,y
                bcs UM_NoReload
                lda #$00                        ;Initiate reload by zeroing magazine
                sta invMag,y
UM_NoReload:    rts

UM_Refresh:     lda #$00
                sta UM_ForceRefresh+1
                inc textLeftMargin
                dec textRightMargin
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
                dec textLeftMargin
                inc textRightMargin
                lda #$20
                ldx itemIndex
                beq UM_NoLeftArrow
                lda #20
UM_NoLeftArrow: sta screen1+SCROLLROWS*40+40+9
                lda #$20
                ldy invType+1,x
                beq UM_NoRightArrow
                lda #21
UM_NoRightArrow:sta screen1+SCROLLROWS*40+40+30
                lda #SFX_SELECT
                jsr PlaySfx
                jmp SetPanelRedrawItemAmmo      ;Redraw item & ammo next time panel is updated

        ; Convert a 8-bit value to BCD
        ;
        ; Parameters: A value
        ; Returns: temp7-temp8 BCD value
        ; Modifies: A,Y,temp6-temp8

ConvertToBCD8:  sta temp6
                lda #$00
                sta temp7
                sta temp8
                ldy #$08
                sed
CTB8_Loop:      asl temp6
                lda temp7
                adc temp7
                sta temp7
                lda temp8
                adc temp8
                sta temp8
                dey
                bne CTB8_Loop
                cld
                rts
    
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
                sta screen1+SCROLLROWS*40+40,x
                inx
                rts
