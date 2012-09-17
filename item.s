ITEM_HEIGHT     = -1
ITEM_ACCEL      = 4
ITEM_YSPEED     = -4*8
ITEM_MAX_YSPEED = 6*8
ITEM_SPAWN_OFFSET = -16*8

MAX_INVENTORYITEMS = 16

MAX_WEAPONS     = 2                             ;TODO: make dynamic

INVENTORY_TEXT_DURATION = 50

        ; Item pickup check
        ;
        ; Parameters: X player actor index (0)
        ; Returns: -
        ; Modifies: A,Y,temp vars
        
CheckPickup:    ldy #ACTI_FIRSTITEM
CP_Loop:        lda actT,y
                cmp #ACT_ITEM
                bne CP_Next
                jsr CheckActorCollision
                bcs CP_HasCollision
CP_Next:        iny
                cpy #ACTI_LASTITEM+1
                bcc CP_Loop
                rts
CP_HasCollision:sty temp1                       ;Item actor number
                lda actF1,y
                clc
                adc #$01
                sta temp2                       ;Item type
                ldx actHp,y
                jsr AddItem
                bcc CP_PickupFail
CP_PickupSuccess:
                ldx temp1
                lda zpBitsLo                    ;Was the item swapped?
                beq CP_NoSwap
                sec
                sbc #$01
                sta actF1,x                     ;Store type/ammo after swap
                lda zpBitsHi
                sta actHp,x
                jmp CP_PrintItemName
CP_NoSwap:      jsr RemoveActor                 ;If not swapped, remove
CP_PrintItemName:
                lda #<txtPickedUp
                ldx #>txtPickedUp
                ldy #INVENTORY_TEXT_DURATION
                jsr PrintPanelText
                ldy temp2
                lda itemNameLo-1,y
                ldx itemNameHi-1,y
                ldy #INVENTORY_TEXT_DURATION
                jsr ContinuePanelText
                jsr RefreshPlayerWeapon
CP_PickupFail:  ldx actIndex
                rts

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
                sec                             ;Successful pickup
                rts
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
                bpl AI_CheckWeapons
AI_CheckWeaponsDone:
                cpx #MAX_WEAPONS
                bcc AI_NoWeaponLimit
                ldy itemIndex                   ;If weapon limit exceeded, check if current
                lda invType,y                   ;weapon can be swapped
                cmp #ITEM_FIRST_CONSUMABLE
                bcc AI_CanBeSwapped             ;TODO: when fists weapon exists, assure they can never be dropped
                clc
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
                bpl AI_FindPosLoop
AI_PosFound:    sty zpBitBuf
                ldx #MAX_INVENTORYITEMS-2       ;TODO: will bug when inventory is full
AI_MakeRoomLoop:lda invType,x                   ;Shift items to make room
                sta invType+1,x
                lda invCount,x
                sta invCount+1,x
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
                beq AI_DidNotDrop
                sty itemIndex
RI_ShiftDone:
AI_DidNotDrop:  sec                             ;Successful pickup
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
                lda invType+1,y
                sta invType,y
                beq RI_ShiftDone
                iny
                bpl RI_ShiftLoop

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