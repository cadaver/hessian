PANEL_TEXT_SIZE = 22
MENU_DELAY      = 20
MENU_MOVEDELAY  = 3

INDEFINITE_TEXT_DURATION = $7f
INVENTORY_TEXT_DURATION = 50

REDRAW_ITEM     = $01
REDRAW_AMMO     = $02

        ; Update scorepanel each frame (health, text display, weapon, ammo)
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
                lda itemFrames-1,x
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
                bcc UP_ClipCountOK
                lda #$09
UP_ClipCountOK: ora #$30
                sta screen1+SCROLLROWS*40+40+38
                bne UP_SkipAmmo
UP_Consumable:  lda #42
                sta screen1+SCROLLROWS*40+40+35
                lda invCount,y
                jsr ConvertToBCD8
                lda temp8
                ldx #36
                jsr PrintBCDDigit
                lda temp7
                jmp PrintBCDDigits
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
UP_UpdateText:  ldx textLeftMargin
UP_ContinueText:ldy #$00
                lda textHi
                beq UP_ClearEndOfLine
                lda (textLo),y
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

        ; Print text to panel, possibly multi-line
        ;
        ; Parameters: A,X text address, Y delay in game logic frames (25 = 1 sec)
        ; Returns: -
        ; Modifies: A
        
PrintPanelText: sty textDelay
SetTextPtr:     sta textLo
                stx textHi
                jmp UP_UpdateText

        ; Print continued panel text. Should be called immediately after printing
        ; the beginning part.
        ;
        ; Parameters: A,X text address, Y delay in game logic frames (25 = 1 sec)
        ; Returns: -
        ; Modifies: A
        
ContinuePanelText:   
                sty textDelay
                sta textLo
                stx textHi
                ldx zpBitsLo
                jmp UP_ContinueText

        ; Clear the panel text
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X

ClearPanelText: ldx #$00
                beq SetTextPtr

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
UM_KeyControl:  ldx keyType                     ;Can also use Z & X keys to select items
                cpx #KEY_Z
                bne UM_NotPreviousKey
                lda #JOY_FIRE+JOY_LEFT
                bne UM_NoMoveDelay
UM_NotPreviousKey:
                cpx #KEY_X
                bne UM_NotNextKey
                lda #JOY_FIRE+JOY_RIGHT
                bne UM_NoMoveDelay
UM_NotNextKey:  cpx #KEY_R                      ;Use R to reload
                bne UM_NotReloadKey
                lda #JOY_FIRE+JOY_DOWN
                bne UM_NoMoveDelay
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
UM_Refresh:     inc textLeftMargin
                dec textRightMargin
                ldx itemIndex
                ldy invType,x
                lda itemNameLo-1,y
                ldx itemNameHi-1,y
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
                jmp SetPanelRedrawItemAmmo      ;Redraw item & ammo next time panel is updated

UM_IsActive:    ldy menuMoveDelay
                beq UM_NoMoveDelay
                dec menuMoveDelay
                rts
UM_NoMoveDelay: ldy itemIndex
                cmp #JOY_FIRE+JOY_LEFT
                bne UM_NoMoveLeft
                cpy #$00
                beq UM_NoMoveLeft
                dec itemIndex
UM_MoveCommon:  lda #MENU_MOVEDELAY
                sta menuMoveDelay
                lda joystick                    ;If joystick held, use smaller move delay
                cmp prevJoy
                bne UM_NoDelayReduce
                dec menuMoveDelay
UM_NoDelayReduce:
                jmp UM_Refresh
UM_NoMoveLeft:  cmp #JOY_FIRE+JOY_RIGHT
                bne UM_NoMoveRight
                lda invType+1,y
                beq UM_NoMoveRight
                inc itemIndex
                bne UM_MoveCommon
UM_NoMoveRight: cmp #JOY_FIRE+JOY_DOWN
                bne UM_NoReload
                ldx invType,y                   ;Do not reload if already full magazine
                lda invMag,y                    ;or already reloading
                bmi UM_NoReload
                cmp itemMagazineSize-1,x
                bcs UM_NoReload
                cmp invCount,y
                bcs UM_NoReload
                lda #$00                        ;Initiate reload by zeroing magazine
                sta invMag,y
UM_NoReload:    rts

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
