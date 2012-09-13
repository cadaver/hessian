ITEM_HEIGHT     = -1
ITEM_ACCEL      = 4
ITEM_YSPEED     = -4*8
ITEM_MAX_YSPEED = 6*8
ITEM_SPAWN_OFFSET = -16*8

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