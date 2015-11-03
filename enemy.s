HUMAN_ITEM_SPAWN_OFFSET = -15*8
ITEM_SPAWN_YSPEED     = -3*8
MULTIEXPLOSION_DELAY = 3

        ; Flying enemy movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

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
                lda #JOY_LEFT|JOY_RIGHT
                jsr MFE_Reverse
MFE_NoHorizTurn:
MFE_NoHorizWall:lda actMB,x
                and #MB_HITWALLVERTICAL
                beq MFE_NoVertWall
                lda #$00
                sta actSY,x
                tya
                beq MFE_NoVertTurn
                lda #JOY_UP|JOY_DOWN
MFE_Reverse:    eor actMoveCtrl,x
                sta actMoveCtrl,x
MFE_NoVertTurn:
MFE_NoVertWall:
MFC_ContinueFall:
DestroyFlyingCraft:
                rts

        ; Flying craft update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveFlyingCraft:lda actHp,x
                beq MFC_Fall
                jsr MoveAccelerateFlyer
                lda actSX,x
                clc
                adc #2*8+4
                bpl MFC_FrameOK1
                lda #0
MFC_FrameOK1:   lsr
                lsr
                lsr
                cmp #5
                bcc MFC_FrameOK2
                lda #4
MFC_FrameOK2:   sta actF1,x
                cmp #2                          ;Cannot fire when no speed (middle frame)
                bne MFC_CanAttack
                rts
MFC_Fall:       jsr FallingMotionCommon
                tay
                beq MFC_ContinueFall
                jmp ExplodeEnemy2_8             ;Drop item & explode at any collision

        ; Floating droid update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveDroid:      lda #$02
                ldy #$02
                jsr OneShotAnimation
                bcc MD_AnimDone
                lda #$00
                sta actF1,x
MD_AnimDone:    jsr MoveAccelerateFlyer
MFC_CanAttack:  jmp AttackGeneric

        ; Generate 2 explosions at 8 pixel radius
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy2_8:lda #2
                ldy #$3f

        ; Turn enemy into a multiple explosion generator & drop item
        ;
        ; Parameters: X actor index, A number of explosions, Y radius
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemyMultiple:
                sta actSX,x
                tya
                sta actSY,x
                lda #ACT_EXPLOSIONGENERATOR
                jsr TransformBullet
                lda #$00
                jmp DropItem

        ; Explosion generator update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveExplosionGenerator:
                dec actFd,x
                bpl MEG_NoNewExplosion
                lda #MULTIEXPLOSION_DELAY
                sta actFd,x
                lda #ACTI_FIRSTEFFECT
                ldy #ACTI_LASTEFFECT
                jsr GetFreeActor
                bcc MEG_NoRoom                  ;If no room, simply explode self
                jsr SpawnActor                  ;Actor type undefined at this point, will be initialized below
                lda actSY,x
                sta temp1
                lsr
                sta temp2
                tya
                tax
                jsr ExplodeActor                ;Play explosion sound & init animation
                jsr MEG_GetOffset
                jsr MoveActorX
                jsr MEG_GetOffset
                jsr MoveActorY
                ldx actIndex
                dec actSX,x
                bne MEG_NotLastExplosion
                jmp RemoveActor
MEG_NotLastExplosion:
MEG_NoNewExplosion:
                rts

MEG_GetOffset:  jsr Random
                and temp1
                sec
                sbc temp2
                rts

        ; Turn enemy into an explosion & drop item
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy:   lda #$00
                jsr DropItem
MEG_NoRoom:     jmp ExplodeActor

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
                lda #HUMAN_ITEM_SPAWN_OFFSET

        ; Drop item from dead enemy
        ;
        ; Parameters: A Vertical offset X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8

DropItem:       sta temp4
                lda #$02                        ;Retry counter
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
                lda actFlags,x                  ;Check if enemy has weapon "integrated"
                asl                             ;in which case no drop
                bmi DI_NoItem
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
                jsr Random                      ;Randomize amount of parts dropped (1-3)
                and #$03
                bne DI_PartsCountOK
                lda #$01
DI_PartsCountOK:sta itemDefaultPickup+ITEM_PARTS-1
                lda itemDefaultPickup-1,x
DI_NoCount:     sta actHp,y
                lda #ITEM_SPAWN_YSPEED
                sta actSY,y
                tya
                tax
                jsr InitActor
                lda temp4
                jsr MoveActorY
                lda temp5
                cmp #ITEM_FIRST_IMPORTANT
                ror
                ror                             ;Carry to bit 6
                and #ORG_GLOBAL
                jsr SetPersistence
                ldx temp6
                rts