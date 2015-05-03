ITEM_HEIGHT     = -1
ITEM_ACCEL      = 4
ITEM_YSPEED     = -24
ITEM_MAX_YSPEED = 6*8

ITEM_SPAWN_OFFSET = -15*8

INITIAL_MAX_WEAPONS = 3

USEITEM_ATTACK_DELAY = 5                        ;Attack delay after using an item

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

        ; Find item from inventory
        ;
        ; Parameters: A item type
        ; Returns: C=1 if found (index in Y), C=0 not found (first free index in Y)
        ; Modifies: A,Y,zpSrcLo

FindItem:       sta zpSrcLo
                ldy #$ff
FI_Loop:        iny
                lda invType,y
                clc
                beq FI_NotFound
                cmp zpSrcLo
                bne FI_Loop
FI_NotFound:    rts

        ; Add item to inventory. If too many weapons, swap with current
        ;
        ; Parameters: A item type, X ammo amount
        ; Returns: C=1 successful, C=0 failed (no room), zpBitsLo dropped item (0=none),
        ;          zpBitsHi dropped ammo count
        ; Modifies: A,X,Y,loader temp vars
        
AddItem:        stx zpSrcHi
                ldx #$00
                stx zpBitsLo                    ;Assume: don't have to drop an existing weapon
                jsr FindItem
                bcc AI_NewItem
AI_HasItem:     tax
                lda invCount,y                  ;Check for maximum ammo
                cmp itemMaxCount-1,x
                bcc AI_HasRoomForAmmo
                clc                             ;Maximum ammo already, fail pickup
                rts
AI_HasRoomForAmmo:
                adc zpSrcHi
                cmp itemMaxCount-1,x
                bcc AI_AmmoNotExceeded
                lda itemMaxCount-1,x
AI_AmmoNotExceeded:
                sta invCount,y
                jmp AI_Success
AI_NewItem:     tya                             ;If first item, always stored to slot 0 (and no swap check)
                beq AI_StoreItem
                lda zpSrcLo                     ;If a weapon, check if limit exceeded
                cmp #ITEM_FIRST_CONSUMABLE
                bcs AI_NoWeaponLimit
                ldy #$00
                ldx #$00
AI_CheckWeapons:lda invType,y
                beq AI_CheckWeaponsDone
                cmp #ITEM_FIRST_CONSUMABLE
                bcs AI_NotAWeapon
                inx
AI_NotAWeapon:  iny
                bne AI_CheckWeapons
AI_CheckWeaponsDone:
AI_MaxWeaponsCount:
                cpx #INITIAL_MAX_WEAPONS
                bcc AI_NoWeaponLimit
                ldy itemIndex                   ;If weapon limit exceeded, check if current
                bne AI_NotUsingFists            ;weapon can be swapped. If fists selected, swap
                inc itemIndex                   ;with first droppable weapon
                iny
AI_NotUsingFists:
                lda invType,y
                cmp #ITEM_FIRST_CONSUMABLE
                bcc AI_CanBeSwapped
                clc
AI_CannotBeSwapped:
                rts                             ;Weapon not selected, nothing to swap with, fail pickup
AI_CanBeSwapped:sta zpBitsLo
                lda invCount,y
                sta zpBitsHi
                jsr RemoveItemByIndex
AI_NoWeaponLimit:
                ldy #$00
AI_FindPosLoop: lda invType,y                   ;Find proper position for new item (item types in sorted order)
                beq AI_PosFound
                cmp zpSrcLo
                bcs AI_PosFound
                iny
                bne AI_FindPosLoop
AI_PosFound:    sty zpBitBuf
                ldx #MAX_INVENTORYITEMS-2       ;TODO: will bug when inventory is full
AI_MakeRoomLoop:lda invType,x                   ;Shift items to make room
                sta invType+1,x
                lda invCount,x
                sta invCount+1,x
                lda invMag,x
                sta invMag+1,x
                cpx itemIndex                   ;Change selection if selected item was shifted
                bne AI_NotSelected
                inc itemIndex
AI_NotSelected: cpx zpBitBuf
                beq AI_StoreItem
                dex
                bpl AI_MakeRoomLoop
AI_StoreItem:   lda zpSrcLo
                sta invType,y
                lda zpSrcHi
                sta invCount,y
                lda #$00
                sta invMag,y
                lda zpBitsLo                    ;If swapped a weapon, select the new weapon now
                beq AI_Success
                sty itemIndex
AI_Success:     
RI_Success:     sec
SetPanelRedrawItemAmmo:
                lda #REDRAW_ITEM+REDRAW_AMMO
                SKIP2
SetPanelRedrawAmmo:
                lda #REDRAW_AMMO
SetPanelRedraw: ora panelUpdateFlags
                sta panelUpdateFlags
RI_NotFound:    rts

        ; Remove item from inventory
        ;
        ; Parameters: A item type
        ; Returns: C=1 if found and removed
        ; Modifies: A,Y,zpSrcLo

RemoveItem:     jsr FindItem
                bcc RI_NotFound
RemoveItemByIndex:
                cpy itemIndex                   ;If current item removed, or removed item is
                beq RI_MoveSelection            ;earlier in inventory, shift selection back
                bcs RI_ShiftLoop
RI_MoveSelection:
                dec itemIndex
RI_ShiftLoop:   lda invCount+1,y                ;Shift items to remove the hole left by dropped item
                sta invCount,y
                lda invMag+1,y
                sta invMag,y
                lda invType+1,y
                sta invType,y
                beq RI_Done
                iny
                bne RI_ShiftLoop
RI_Done:        inc UM_ForceRefresh+1           ;If inventory open, force it to refresh
                jmp RI_Success

        ; Decrease ammo in inventory
        ;
        ; Parameters: A ammo amount, Y inventory index
        ; Returns: -
        ; Modifies: A,Y,zpSrcLo

DecreaseAmmoOne:lda #$01
DecreaseAmmo:   sta zpSrcLo
                sec
                lda invMag,y                    ;Decrease ammo in magazine as well
                beq DA_NoAmmoInMag
                sbc zpSrcLo                     ;Is assumed not to overflow negatively, as
                sta invMag,y                    ;when item has a magazine it is decreased
DA_NoAmmoInMag: lda invCount,y                  ;only by one
                sbc zpSrcLo
                bcs DA_NotNegative
                lda #$00
DA_NotNegative: sta invCount,y
                bne SetPanelRedrawAmmo
                lda invType,y
                cmp #ITEM_FIRST_CONSUMABLE      ;If it's a consumable item, remove when ammo
                bcc SetPanelRedrawAmmo          ;goes to zero
                jmp RemoveItemByIndex

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
                lda #ITEM_HEIGHT                ;Actor height for ceiling check
                sta temp4
                lda #ITEM_ACCEL
                ldy #ITEM_MAX_YSPEED
                jsr MoveWithGravity             ;Move & check collisions
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

        ; Use an inventory item
        ;
        ; Parameters: Y inventory index
        ; Returns: -
        ; Modifies: A,X,Y,temp vars
        
UseItem:        lda actHp+ACTI_PLAYER           ;Can't use/reload after dying
                beq UI_Dead
                lda invType,y
                cmp #ITEM_FIRST_NONWEAPON
                bcc UI_Reload
                cmp #ITEM_MEDKIT
                beq UseMedKit
                cmp #ITEM_BATTERY
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
UI_Reload:      lda plrReload
                bne UI_DontReload
                lda actF1+ACTI_PLAYER           ;No reload if dead or swimming
                cmp #FR_DIE
                bcs UI_DontReload
                ldx invType,y                   ;Do not reload if already full magazine
                lda invMag,y                    ;or already reloading
                cmp itemMagazineSize-1,x
                bcs UI_DontReload
                cmp invCount,y
                bcs UI_DontReload
                dec plrReload
UI_DontReload:  rts