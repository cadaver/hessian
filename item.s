ITEM_HEIGHT     = -1
ITEM_ACCEL      = 4
ITEM_YSPEED     = -4*8
ITEM_MAX_YSPEED = 6*8
ITEM_SPAWN_OFFSET = -16*8

MAX_INVENTORYITEMS = 16
MAX_WEAPONS     = 3                             ;TODO: make dynamic

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
                cpx #MAX_WEAPONS
                bcc AI_NoWeaponLimit
                ldy itemIndex                   ;If weapon limit exceeded, check if current
                lda invType,y                   ;weapon can be swapped
                cmp #ITEM_FISTS+1
                bcc AI_CannotBeSwapped
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
                lda zpBitsLo                    ;If swapped a weapon, select the new weapon now
                beq AI_Success
                sty itemIndex
AI_Success:     
RI_Success:     
SetPanelRedrawItemAmmo:
                lda #REDRAW_ITEM+REDRAW_AMMO
                sta panelUpdateFlags
                sec
RI_NotFound:    rts

        ; Remove item from inventory
        ;
        ; Parameters: A item type
        ; Returns: C=1 if found and removed
        ; Modifies: A,Y,zpSrcLo

RemoveItem:     jsr FindItem
                bcc RI_NotFound
RemoveItemByIndex:
                cpy itemIndex
                bcs RI_ShiftLoop
                dec itemIndex                   ;Change selection if selected item was shifted
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
                ldy itemIndex                   ;If current index points past inventory end,
                beq RI_Success                  ;change selection back
                lda invType,y
                bne RI_Success
                dec itemIndex
                jmp RI_Success

        ; Decrease ammo in inventory
        ;
        ; Parameters: A ammo amount, Y inventory index
        ; Returns: -
        ; Modifies: A,Y,zpSrcLo

DecreaseAmmo:   sta zpSrcLo
                lda invMag,y                    ;Decrease ammo in magazine as well
                beq DA_NoAmmoInMag
                sec
                sbc zpSrcLo
                bcs DA_MagNotNegative
                lda #$00
DA_MagNotNegative:
                sta invMag,y
DA_NoAmmoInMag: lda invCount,y
                sec
                sbc zpSrcLo
                bcs DA_NotNegative
                lda #$00
DA_NotNegative: sta invCount,y
                bne DA_DecreaseDone
                sty zpSrcLo
                lda invType,y
                tay
                lda itemMagazineSize-1,y        ;If it's a consumable item, remove when ammo
                bne DA_DecreaseDone             ;goes to zero
                ldy itemIndex
                jmp RemoveItemByIndex
SetPanelRedrawAmmo:
DA_DecreaseDone:lda panelUpdateFlags
                ora #REDRAW_AMMO
                sta panelUpdateFlags
                rts

        ; Item update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveItem:       lda #$00
                sta actC,x
                lda actMoveFlags,x              ;Skip movement if grounded and stationary
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
                sta actMoveFlags,x
MoveItem_Done:  rts

        ; Use an inventory item
        ;
        ; Parameters: Y inventory index
        ; Returns: -
        ; Modifies: A,X,Y,temp vars
        
UseItem:        lda invType,y
                cmp #ITEM_MEDKIT
                beq UseMedKit
UMK_FullHealth: rts
UseMedKit:      lda actHp+ACTI_PLAYER
                cmp #HP_PLAYER
                bcs UMK_FullHealth
                lda #HP_PLAYER
                sta actHp+ACTI_PLAYER
                lda #SFX_POWERUP
                jsr PlaySfx
UI_ReduceAmmo:  lda #USEITEM_ATTACK_DELAY       ;In case the item is removed, give an
                sta actAttackD+ACTI_PLAYER      ;attack delay to prevent accidental
                lda #$01                        ;fire when a weapon becomes selected
                jmp DecreaseAmmo