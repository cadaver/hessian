HUMAN_ITEM_SPAWN_OFFSET = -15*8
ITEM_SPAWN_YSPEED     = -3*8
MULTIEXPLOSION_DELAY = 2
SCRAP_DURATION = 40

        ; Common flying enemy movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveAccelerateFlyer:
                lda #$00
MFE_CustomCharInfo:
                sta temp6
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
MFE_NoVertAccel:ldy #AL_XMOVESPEED
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
                ldy #AL_XCHECKOFFSET            ;Horizontal obstacle check offset
                lda (actLo),y
                sta temp4
                iny
                lda (actLo),y                   ;Vertical obstacle check offset
                ldy actSY,x                     ;Reverse if going up
                bpl MFE_NoNegate
                clc
                eor #$ff
                adc #$01
MFE_NoNegate:   jsr MF_HasCharInfo
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
MFE_NoVertWall: rts

        ; Floating droid update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveDroid:      lda #$02
                tay
                jsr LoopingAnimation
                jsr MoveAccelerateFlyer
                jmp AttackGeneric

        ; Floating mine update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveFloatingMine:
                lda #3
                ldy #3
                jsr LoopingAnimation
                jsr MoveAccelerateFlyer
                jmp MineCommon

        ; Rolling mine update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveRollingMine:jsr MoveGeneric
                lda actMB,x                         ;If not grounded and hitting wall,
                cmp #MB_HITWALL                     ;climb up the wall
                bne MRM_NoClimb
                lda #10
                ldy #4*8
                jsr AccActorYNeg
MRM_NoClimb:    inc actFd,x
                lda actFd,x
                and #$01
                sta actF1,x
MineCommon:     ldy actAITarget,x
                bmi MC_NoCollision
                lda #DMG_ENEMYMINE
                jsr CollideAndDamageTarget
                bcc MC_NoCollision
                jmp DestroyActorNoSource

        ; CPU destroy (activate object at explosion)
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DestroyCPU:     jsr ExplodeActor
                ldy #MAX_LVLOBJ-1
DCPU_Search:    lda lvlObjX,y
                cmp actXH,x
                bne DCPU_SearchNext
                lda lvlObjY,y
                and #$7f
                cmp actYH,x
                beq DCPU_Found
DCPU_SearchNext:dey
                bpl DCPU_Search
MC_NoCollision: rts
DCPU_Found:     jmp ActivateObject

        ; Turn enemy into an explosion & drop item
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy_Ofs8:
                lda #-8*8
                jsr MoveActorYNoInterpolation
ExplodeEnemy:   jsr DropItem
                jmp ExplodeActor

        ; Generate 2 explosions at 8 pixel radius
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy2_8_Ofs6:
                lda #6*8
                skip2
ExplodeEnemy2_8_Ofs10:
                lda #-10*8
                jsr MoveActorYNoInterpolation
ExplodeEnemy2_8:lda #2
                ldy #$3f

        ; Turn enemy into a multiple explosion generator & drop item
        ;
        ; Parameters: X actor index, A number of explosions, Y radius
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemyMultiple:
                sta actTime,x
                tya
ExplodeEnemyMultiple_CustomRadius:
                sta actSX,x
                tya
                sta actSY,x
                jsr DropItem
                lda #ACT_EXPLOSIONGENERATOR
                jmp TransformBullet

        ; Generate 3 explosions at 8 pixel radius horizontally and 32 pixel radius
        ; vertically
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy3_Ofs24:
                lda #-15*8
                jsr MoveActorYNoInterpolation
                lda #3
                sta actTime,x
                lda #$3f
                ldy #$ff
                jsr ExplodeEnemyMultiple_CustomRadius
                lda #-8*8
                jmp MoveActorYNoInterpolation

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
                lda #ACTI_FIRSTNPC              ;Use any free actors
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc MEG_NoRoom                  ;If no room, simply explode self
                jsr SpawnActor                  ;Actor type undefined at this point, will be initialized below
                lda actSX,x
                sta temp1
                lda actSY,x
                sta temp2
                tya
                tax
                jsr ExplodeActor                ;Play explosion sound & init animation
                lda temp1
                jsr MEG_GetOffset
                jsr MoveActorX
                lda temp2
                jsr MEG_GetOffset
                jsr MoveActorY
                ldx actIndex
                dec actTime,x
                bne MEG_NotLastExplosion
                jmp RemoveActor
MEG_NoRoom:     jmp ExplodeActor
MEG_GetOffset:  sta temp3
                lsr
                sta temp4
                jsr Random
                and temp3
                sec
                sbc temp4
MEG_NotLastExplosion:
MEG_NoNewExplosion:
                rts

        ; Scrap metal movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveScrapMetal: jsr BounceMotion

        ; Flicker corpse, then remove.
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp regs

DeathFlickerAndRemove:
                dec actTime,x
                bmi DFAR_Remove
                lda actTime,x                   ;Flicker and eventually remove the corpse
                cmp #DEATH_FLICKER_DELAY
                bcs DFAR_Done
                lda #COLOR_FLICKER
                sta actFlash,x
DFAR_Done:      rts
DFAR_Remove:    jmp RemoveActor

        ; Initiate humanoid enemy or player death
        ;
        ; Parameters: X actor index,temp8 damage source actor or $ff if none
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8

HumanDeath:     txa
                bne HD_NotPlayer                ;Reset dialogue / interaction menu modes
                jsr StopScript                  ;if died during them
                lda menuMode
                cmp #MENU_DIALOGUE
                bcc HD_NotInMenu
                ldx #MENU_NONE
                jsr SetMenuMode
HD_NotInMenu:   ldx #ACTI_PLAYER
HD_NotPlayer:   lda #SFX_HUMANDEATH
                jsr PlaySfx
                lda actF1,x
                cmp #FR_SWIM
                bcc HD_NotSwimming
                jsr GetCharInfo1Below           ;If space below, prefer to move
                and #CI_OBSTACLE|CI_GROUND      ;as the dying frames have hotspot at bottom
                bne HD_SetFrame
                lda #8*8
                jsr MoveActorYNoInterpolation
                jmp HD_SetFrame
HD_NotSwimming: lda #DEATH_YSPEED
                sta actSY,x
                jsr MH_ResetGrounded
HD_SetFrame:    ldy temp8
                lda #FR_DIE
                sta actF1,x
                sta actF2,x
HD_Common:      tya                             ;Check if has a damage source
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
                lda #DEATH_DISAPPEAR_DELAY
                sta actTime,x
                lda #$00
                sta actFd,x
                lda #HUMAN_ITEM_SPAWN_OFFSET
                skip2

        ; Drop item from dead enemy
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8

DropItem:       lda #$00
                sta temp4
                lda #$03                        ;Retry counter
                sta temp7
                lda actT,x                      ;Exception: final room large droids drop nothing
                cmp #ACT_LARGEDROIDFINAL
                beq DI_NoItem
                ldy #AL_SIZEUP                  ;If enemy is going to drop parts, make their
                jsr Random                      ;count proportional to the enemy size + random add
                and #$0c
                clc
                adc (actLo),y
                iny
                adc (actLo),y
                lsr
                lsr
                sta itemDefaultPickup+ITEM_PARTS-1
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
                bmi DI_NoItem                   ;in which case no drop
                lda actWpn,x
DI_ItemNumber:  tay
                beq DI_NoItem
                sta temp5                       ;Item type to drop
                lda #$00                        ;X-speed
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
DI_HasCapacity: lda #$00
DI_SpawnItemWithSpeed:
                sta temp8
                lda #ACTI_FIRSTITEM
                ldy #ACTI_LASTITEM
                jsr GetFreeActor
                bcc DI_NoItem
                stx temp6
                lda #ACT_ITEM
                jsr SpawnActor
                lda temp5
                tax
                sta actF1,y
                lda #1
                cpx #ITEM_FIRST_IMPORTANT       ;Quest items always x1
                bcs DI_CountOK
                lda itemDefaultPickup-1,x
DI_CountOK:     sta actHp,y
                lda #ITEM_SPAWN_YSPEED
                sta actSY,y
                tya
                tax
                jsr InitActor
                lda temp8
                sta actSX,x
                lda temp4
                jsr MoveActorY
                lda temp5
                cmp #ITEM_FIRST_IMPORTANT
                lda levelNum
                bcc DI_NotImportant
                ora #ORG_GLOBAL
DI_NotImportant:sta actLvlDataOrg,x             ;Make item either persistent or temp persistent
                ldx temp6                       ;depending on importance
                rts
