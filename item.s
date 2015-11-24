INITIAL_MAX_WEAPONS = 4                         ;3 + fists

USEITEM_ATTACK_DELAY = 5                        ;Attack delay after using an item

MAG_INFINITE    = $ff
NO_ITEM_COUNT   = $ff

        ; Item update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveItem:       lda actMB,x                     ;Skip movement if grounded and stationary
                lsr
                bcs MoveItem_Done
                lda actSY,x                     ;Store original Y-speed for bounce
                sta temp1
                jsr FallingMotionCommon         ;Move & check collisions
                lsr
                bcc MoveItem_Done
                lda temp1                       ;Bounce: negate and halve velocity
                jsr Negate8Asr8
                beq MoveItem_Done               ;If velocity left, clear the grounded
                sta actSY,x                     ;flag
                lda #$00
                sta actMB,x
MoveItem_Done:
FlashActor:     lda #$01
                sta actFlash,x
                rts

        ; Object marker update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveObjectMarker:
MObjMarker_Cmp: cpx #$00                        ;Remove old objectmarker
                bne MObjMarker_Remove
                lda lvlObjNum                   ;Remove if no object
                bmi MObjMarker_Remove
                jmp FlashActor
MObjMarker_Remove:
                jmp RemoveActor

        ; Try picking up an item
        ;
        ; Parameters: Y item actor index
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

TryPickup:      sty temp1                       ;Item actor number
                lda actF1,y
                sta temp2                       ;Item type
                ldx actHp,y
                jsr AddItem
                bcc TP_PickupFail
TP_PickupSuccess:
                ldx temp1
                lda zpBitsLo                    ;Was the item swapped?
                beq TP_NoSwap
                sta actF1,x                     ;Store type/ammo after swap
                lda zpBitsHi
                sta actHp,x
                lda levelNum                    ;After swapping, the item has become temporary
                sta actLvlDataOrg,x             ;and is now disconnected from the leveldata
                jmp TP_PrintItemName
TP_NoSwap:      jsr RemoveActor                 ;If not swapped, remove
TP_PrintItemName:
                lda #<txtPickedUp
                ldx #>txtPickedUp
                ldy #INVENTORY_TEXT_DURATION
                jsr PrintPanelText
                lda temp2
                jsr GetItemName
                jsr ContinuePanelText
                lda #SFX_PICKUP
                jmp PlaySfx

        ; Get name of item
        ;
        ; Parameters: A item type
        ; Returns: A,X pointer to item name text
        ; Modifies: A,X,Y

GetItemName:    tay
                lda itemNameLo-1,y
                ldx itemNameHi-1,y
TP_PickupFail:  rts

        ; Find item from inventory (verify that has other than "none" count)
        ;
        ; Parameters: Y item type
        ; Returns: C=1 found, C=0 not found
        ; Modifies: Y

FindItem:       lda #NO_ITEM_COUNT-1
                cmp invCount-1,y
                rts

        ; Return weapon's magazine size
        ;
        ; Parameters: Y item type
        ; Returns: A=$00 & C=0 consumable or weapon with single ammo reserve
        ;          A=$ff & C=0 infinite (melee weapon)
        ;          A=$01-$7f & C=1 firearm with magazine
        ; Modifies: -

GetCurrentItemMagazineSize:
                ldy itemIndex
GetMagazineSize:lda #$00
                cpy #ITEM_LAST_MAG+1
                bcs GMS_Fail
                lda itemMagazineSize-1,y
                bmi GMS_Fail
                cmp #$01
                rts

        ; Select next item in inventory
        ;
        ; Parameters: -
        ; Returns: Y index, C=1 itemIndex updated, C=0 already at end
        ; Modifies: A,Y

SelectNextItem: ldy itemIndex
                cpy lastItemIndex
                bcs SNI_Fail
SNI_Loop:       iny
                jsr FindItem
                bcc SNI_Loop
SPI_Done:       sty itemIndex
                rts

        ; Select previous item in inventory
        ;
        ; Parameters: -
        ; Returns: Y index, C=1 itemIndex updated, C=0 already at beginning
        ; Modifies: A,Y

SelectPreviousItem:
                ldy itemIndex
SPI_Fast:       cpy #ITEM_FISTS
                beq SPI_Fail
SPI_Loop:       dey
                jsr FindItem
                bcc SPI_Loop
                bcs SPI_Done

        ; Add item to inventory. If too many weapons, swap with current
        ;
        ; Parameters: A item type, X ammo amount
        ; Returns: C=1 successful, C=0 failed (no room), zpBitsLo dropped item (0=none),
        ;          zpBitsHi dropped ammo count
        ; Modifies: A,X,Y,loader temp vars

AddItem:        sta zpSrcLo
                stx zpSrcHi
                ldx #$00
                stx zpBitsLo                    ;Assume: don't have to drop an existing weapon
                tay
                jsr FindItem
                bcc AI_NewItem
AI_HasItem:     cpy #ITEM_FIRST_IMPORTANT       ;Quest items don't need checking, always x1
                lda #1
                bcs AI_AmmoNotExceeded
                lda invCount-1,y                ;Check for maximum ammo
                cmp itemMaxCount-1,y
                bcc AI_HasRoomForAmmo
SNI_Fail:
SPI_Fail:
GMS_Fail:
AI_Fail:        clc                             ;Maximum ammo already, fail pickup
                rts
AI_HasRoomForAmmo:
                adc zpSrcHi
                cmp itemMaxCount-1,y
                bcc AI_AmmoNotExceeded
                lda itemMaxCount-1,y
AI_AmmoNotExceeded:
                sta invCount-1,y
                jmp AI_Success
AI_NewItem:     cpy #ITEM_FIRST_CONSUMABLE      ;If picking up a weapon, check limit now
                bcs AI_NoWeaponLimit
                ldx #$00
                ldy #ITEM_FIRST_NONWEAPON-1
AI_CheckWeapons:jsr FindItem
                bcc AI_CheckWeaponsNext
                inx
AI_CheckWeaponsNext:
                dey
                bne AI_CheckWeapons
AI_MaxWeaponsCount:
                cpx #INITIAL_MAX_WEAPONS
                bcc AI_NoWeaponLimit
                ldy itemIndex                   ;Swap with current weapon. If fists selected,
                cpy #ITEM_FISTS                 ;select first droppable weapon first
                bne AI_NotUsingFists
                jsr SelectNextItem              ;New index to Y
AI_NotUsingFists:
                cpy #ITEM_FIRST_CONSUMABLE
                bcc AI_CanBeSwapped
AI_CannotBeSwapped:
                clc                             ;If a consumable or quest item selected, cannot swap
                rts
AI_CanBeSwapped:sty zpBitsLo
                lda invCount-1,y
                sta zpBitsHi
                jsr RemoveItem
                lda zpSrcLo                     ;In case of swapping select the new item
                sta itemIndex
AI_NoWeaponLimit:
                ldy zpSrcLo
                lda zpSrcHi
                sta invCount-1,y
                cpy lastItemIndex
                bcc AI_NoNewLastItem
                sty lastItemIndex
AI_NoNewLastItem:
                jsr GetMagazineSize
                bcc AI_Success
                lda #$00                        ;If is a weapon with magazine, start with it empty
                sta invMag-ITEM_FIRST_MAG,y
AI_Success:     sec
SetPanelRedrawItemAmmo:
                lda #REDRAW_ITEM+REDRAW_AMMO
                SKIP2
SetPanelRedrawAmmo:
                lda #REDRAW_AMMO
SetPanelRedraw: ora panelUpdateFlags
                sta panelUpdateFlags
RI_NotFound:    rts

        ; Decrease ammo in inventory
        ;
        ; Parameters: A ammo amount, Y item type
        ; Returns: -
        ; Modifies: A,Y,zpSrcLo

DecreaseAmmoOne:lda #$01
DecreaseAmmo:   sta zpSrcLo
                jsr GetMagazineSize
                bcc DA_NoAmmoInMag
                lda invMag-ITEM_FIRST_MAG,y     ;Decrease ammo in magazine as well
                ;beq DA_NoAmmoInMag
                sbc zpSrcLo                     ;Is assumed not to overflow negatively, as
                sta invMag-ITEM_FIRST_MAG,y     ;when item has a magazine it is decreased
DA_NoAmmoInMag: lda invCount-1,y                ;only by one, and weapon code should not
                sec                             ;allow to fire empty weapon
                sbc zpSrcLo
                bcs DA_NotNegative
                lda #$00
DA_NotNegative: sta invCount-1,y
                bne SetPanelRedrawAmmo
                cpy #ITEM_FIRST_CONSUMABLE      ;If it's a consumable item, remove when ammo
                bcc SetPanelRedrawAmmo          ;goes to zero

        ; Remove item from inventory
        ;
        ; Parameters: Y item type (should never be fists)
        ; Returns: Y new item index after removal
        ; Modifies: A,Y

RemoveItem:     lda #NO_ITEM_COUNT
                sta invCount-1,y
                sty RI_Cmp+1
                cpy lastItemIndex
                bne RI_NotLast
RI_FindPrevious:dey
                jsr FindItem
                bcc RI_FindPrevious
                sty lastItemIndex
RI_NotLast:     ldy itemIndex                ;If selected item removed, switch
RI_Cmp:         cpy #$00                     ;selection backward
                bne SetPanelRedrawItemAmmo
                jsr SPI_Fast
                bcs SetPanelRedrawItemAmmo

        ; Use an inventory item
        ;
        ; Parameters: Y item type
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

UseItem:        lda actHp+ACTI_PLAYER           ;Can't use/reload after dying
                beq UI_Dead
                cpy #ITEM_FIRST_NONWEAPON
                bcc UI_Reload
                cpy #ITEM_MEDKIT
                beq UseMedKit
                cpy #ITEM_BATTERY
                beq UseBattery
UI_Dead:
UB_FullBattery:
UMK_FullHealth: rts
UseBattery:     lda battery+1
                cmp #MAX_BATTERY
                bcs UB_FullBattery
                adc #MAX_BATTERY/2
                cmp #MAX_BATTERY
                bcc UB_NotOver
                lda #$00
                sta battery
                lda #MAX_BATTERY
UB_NotOver:     sta battery+1
                bne UMK_PlaySound
UseMedKit:      lda #HP_PLAYER
                cmp actHp+ACTI_PLAYER
                beq UMK_FullHealth
                sta actHp+ACTI_PLAYER
UMK_PlaySound:  lda #SFX_POWERUP
                jsr PlaySfx
UI_ReduceAmmo:  lda #USEITEM_ATTACK_DELAY       ;In case the item is removed, give an
                sta actAttackD+ACTI_PLAYER      ;attack delay to prevent accidental
                jmp DecreaseAmmoOne             ;fire if a weapon becomes selected next
UI_Reload:      jsr GetMagazineSize
                bcc UI_DontReload
                lda reload                      ;No reload if already reloading
                bne UI_DontReload
                lda actF1+ACTI_PLAYER           ;No reload if dead or swimming
                cmp #FR_DIE
                bcs UI_DontReload
                lda invMag-ITEM_FIRST_MAG,y     ;No reload if magazine already full or no reserve
                cmp itemMagazineSize-1,y
                bcs UI_DontReload
                cmp invCount-1,y
                bcs UI_DontReload
                dec reload
UI_DontReload:  rts
