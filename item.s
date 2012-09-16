ITEM_HEIGHT     = -1
ITEM_ACCEL      = 4
ITEM_YSPEED     = -4*8
ITEM_MAX_YSPEED = 6*8
ITEM_SPAWN_OFFSET = -16*8

MAX_INVENTORYITEMS = 16

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
CP_HasCollision:tya
                tax
                jsr RemoveActor                 ;TODO add to inventory
                lda actF1,x
                sta CP_ItemType+1
                lda #<txtPickedUp
                ldx #>txtPickedUp
                ldy #INVENTORY_TEXT_DURATION
                jsr ShowPanelText
CP_ItemType:    ldy #$00
                lda itemNameLo,y
                ldx itemNameHi,y
                ldy #INVENTORY_TEXT_DURATION
                jsr ContinueText
                ldx actIndex
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