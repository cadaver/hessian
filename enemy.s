        ; Flying enemy update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveFlyingEnemy:lda #FR_JUMP                    ;Set jump frame (todo: remove/replace)
                sta actF1,x
                sta actF2,x
                jsr MoveAccelerateFlyer
                jmp AttackHuman

MoveAccelerateFlyer:
                ldy #AL_XMOVESPEED
                lda (actLo),y
                sta temp4                       ;Horizontal max. speed
                lda actMoveCtrl,x
                and #JOY_LEFT|JOY_RIGHT
                beq MFE_NoHorizAccel
                and #JOY_LEFT
                beq MFE_TurnRight
                lda #$80
MFE_TurnRight:  sta actD,x
                asl                             ;Direction to carry
                iny
                lda (actLo),y                   ;Horizontal acceleration
                ldy temp4
                jsr AccActorXNegOrPos
MFE_NoHorizAccel:
                ldy #AL_YMOVESPEED
                lda (actLo),y
                sta temp4                       ;Vertical max. speed
                lda actMoveCtrl,x
                and #JOY_UP|JOY_DOWN
                beq MFE_NoVertAccel
                cmp #JOY_UP
                beq MFE_AccelUp                 ;C=1 accelerate up (negative)
                clc
MFE_AccelUp:    iny
                lda (actLo),y                   ;Vertical acceleration
                ldy temp4
                jsr AccActorYNegOrPos
MFE_NoVertAccel:ldy #AL_XCHECKOFFSET            ;Horizontal obstacle check offset
                lda (actLo),y
                sta temp4
                iny
                lda (actLo),y                   ;Vertical obstacle check offset
                ldy #$00                        ;Require charinfo free of obstacles
                jsr MoveFlyer
                ldy actAIHelp,x                 ;Zero speed and reverse dir if requested
                lda actMB,x
                and #MB_HITWALL
                beq MFE_NoHorizWall
                lda #$00
                sta actSX,x
                tya
                beq MFE_NoHorizTurn
                lda actMoveCtrl,x
                eor #JOY_LEFT|JOY_RIGHT
                sta actMoveCtrl,x
MFE_NoHorizTurn:
MFE_NoHorizWall:lda actMB,x
                and #MB_HITWALLVERTICAL
                beq MFE_NoVertWall
                lda #$00
                sta actSY,x
                tya
                beq MFE_NoVertTurn
                lda actMoveCtrl,x
                eor #JOY_UP|JOY_DOWN
                sta actMoveCtrl,x
MFE_NoVertTurn:
MFE_NoVertWall: rts

        ; Turn enemy into an explosion & drop item
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy:   lda #-16*8                      ;Todo: position adjust or multi-enemies
                jsr MoveActorY
                jsr DropItem
                jmp ExplodeActor

        ; Initiate humanoid enemy or player death
        ;
        ; Parameters: X actor index,Y damage source actor or $ff if none
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8

HumanDeath:     tya                             ;Check if has a damage source
                bmi HD_NoDamageSource
                lda actHp,y
                sta temp8
                lda actSX,y                     ;Check if final attack came from right or left
                bne HD_GotDir
                lda actXL,x
                sec
                sbc actXL,y
                lda actXH,x
                sbc actXH,y
HD_GotDir:      asl                             ;Direction to carry
                lda temp8
                ldy #DEATH_MAX_XSPEED
                jsr AccActorXNegOrPos
HD_NoDamageSource:
                lda actMB,x                     ;If in water, do not modify Y-speed
                bmi HD_NoYSpeed
                lda #DEATH_YSPEED
                sta actSY,x
                jsr MH_ResetGrounded
HD_NoYSpeed:    lda #SFX_DEATH
                jsr PlaySfx
                lda #FR_DIE
                sta actF1,x
                sta actF2,x
                lda #DEATH_DISAPPEAR_DELAY
                sta actTime,x
                lda #POS_NOTPERSISTENT          ;Bodies are supposed to eventually vanish, so mark as
                sta actLvlDataPos,x             ;nonpersistent if goes off the screen
                lda #$00
                sta actFd,x
                sta actHp,x
                sta actAIMode,x                ;Reset any ongoing AI

        ; Drop item from dead enemy
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8

DropItem:       lda #$02                        ;Retry counter
                sta temp7
DI_Retry:       ldy #AL_DROPITEMINDEX
                lda (actLo),y
                bpl DI_ItemNumber
                sta temp5
                jsr Random
                and #DROPTABLERANDOM-1
                adc temp5
                tay
                lda itemDropTable-$80,y
                beq DI_NoItem
                bpl DI_ItemNumber
                lda actWpn,x
DI_ItemNumber:  tay
                beq DI_NoItem
                sta temp5                       ;Item type to drop
                lda #$00
                sta temp8                       ;Capacity counter
                ldy #ACTI_FIRSTITEM             ;Count capacity on both ground and inventory, do not spawn
DI_CountGroundItems:                            ;if player can't pick up
                lda actT,y
                beq DI_CGINext
                lda actF1,y
                cmp temp5
                bne DI_CGINext
                lda actHp,y
                clc
                adc temp8
                bcs DI_Exceeded
                sta temp8
DI_CGINext:     iny
                cpy #ACTI_LASTITEM+1
                bcc DI_CountGroundItems
                ldy temp5
                jsr FindItem
                bcc DI_NotInInventory
                lda invCount-1,y
                clc
                adc temp8
                bcs DI_Exceeded
                sta temp8
DI_NotInInventory:
                lda temp8
                cmp itemMaxCount-1,y
                bcc DI_HasCapacity
DI_Exceeded:    dec temp7
                bne DI_Retry                    ;If player has no capacity, retry to drop something else
DI_NoItem:      rts                             ;(e.g. batteries or medkits)
DI_HasCapacity: lda #ACTI_FIRSTITEM
                ldy #ACTI_LASTITEM
                jsr GetFreeActor
                bcc DI_NoItem
                lda #ACT_ITEM
                jsr SpawnActor
                lda temp5
                stx temp6
                tax
                sta actF1,y
                lda #1
                cpx #ITEM_FIRST_IMPORTANT       ;Quest items always x1
                bcs DI_NoCount
                lda itemDefaultPickup-1,x
DI_NoCount:     sta actHp,y
                lda #ITEM_YSPEED
                sta actSY,y
                tya
                tax
                jsr InitActor
                lda #ITEM_SPAWN_OFFSET
                jsr MoveActorY
                lda temp5
                cmp #ITEM_FIRST_IMPORTANT
                ror
                ror                             ;Carry to bit 6
                and #ORG_GLOBAL
                jsr SetPersistence
                ldx temp6
                rts