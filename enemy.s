HUMAN_ITEM_SPAWN_OFFSET = -15*8
ITEM_SPAWN_YSPEED     = -3*8
MULTIEXPLOSION_DELAY = 3
TURRET_ANIMDELAY = 2

        ; Turn enemy into an explosion & drop item
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy_Ofs8:
                lda #-8*8
                jsr MoveActorYNoInterpolation
ExplodeEnemy:   lda #$00
                jsr DropItem
                jmp ExplodeActor

        ; Generate 2 explosions at 8 pixel radius
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp vars

ExplodeEnemy2_8_OfsD6:
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
                sta actSX,x
                tya
                sta actSY,x
                lda #ACT_EXPLOSIONGENERATOR
                jsr TransformBullet
                jmp DropItem                    ;A=0 on return

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
MEG_NoRoom:     jmp ExplodeActor
MEG_NotLastExplosion:
MEG_NoNewExplosion:
                rts
MEG_GetOffset:  jsr Random
                and temp1
                sec
                sbc temp2
                rts

        ; Initiate humanoid enemy or player death
        ;
        ; Parameters: X actor index,temp8 damage source actor or $ff if none
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8

HumanDeath:     lda #SFX_HUMANDEATH
                jsr PlaySfx
                lda actF1,x
                cmp #FR_SWIM
                bcc HD_NotSwimming
                jsr GetCharInfo1Below           ;If space below, prefer to move
                and #CI_OBSTACLE|CI_GROUND      ;as the dying frames have hotspot at bottom
                bne HD_SetFrame
                lda #8*8
                jsr MoveActorY
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
                jsr SetNotPersistent           ;Mark body nonpersistent in case goes off screen
                lda #$00
                sta actFd,x
                sta actAIMode,x                ;Reset any ongoing AI
                lda #HUMAN_ITEM_SPAWN_OFFSET

        ; Drop item from dead enemy
        ;
        ; Parameters: A Vertical offset X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8

DropItem:       sta temp4
                lda #$03                        ;Retry counter
                sta temp7
                ldy #AL_SIZEHORIZ               ;If enemy is going to drop parts, make their
                jsr Random                      ;count proportional to the enemy size + random add
                and #$0c
                clc
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
                bcs DI_CountOK
                lda itemDefaultPickup-1,x
DI_CountOK:     sta actHp,y
                lda #ITEM_SPAWN_YSPEED
                sta actSY,y
                tya
                tax
                jsr InitActor
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

        ; Flicker corpse, then remove. Will not return when removes the actor
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
DFAR_Remove:    pla
                pla
                jmp RemoveActor