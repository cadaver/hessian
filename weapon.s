AIM_UP          = 0
AIM_DIAGONALUP  = 1
AIM_HORIZONTAL  = 2
AIM_DIAGONALDOWN = 3
AIM_DOWN        = 4
AIM_NONE        = $ff

WD_BITS         = 0
WD_MINAIM       = 1
WD_MAXAIM       = 2
WD_ATTACKDELAY  = 3
WD_BULLETTYPE   = 4
WD_DAMAGE       = 5
WD_DAMAGEMOD    = 6
WD_DURATION     = 7
WD_BULLETSPEED  = 8
WD_SPEEDTABLEOFFSET = 9
WD_SFX          = 10  
WD_BACKFR       = 11
WD_IDLEFR       = 12
WD_IDLEFRLEFT   = 13
WD_ATTACKFR     = 14
WD_ATTACKFRLEFT = 15
WD_PREPAREFR    = 16                            ;Melee weapons only
WD_PREPAREFRLEFT = 17
WD_RELOADDELAY  = 16                            ;Firearms only
WD_RELOADSFX    = 17
WD_RELOADDONESFX = 18
WD_LOCKANIMFRAME = 19

WDB_NONE        = 0
WDB_NOWEAPONSPRITE = 1
WDB_BULLETDIRFRAME = 2
WDB_THROW       = 4
WDB_MELEE       = 8
WDB_NOSKILLBONUS = 16
WDB_LOCKANIMATION = 32
WDB_FLICKERBULLET = 64
WDB_FIREFROMHIP = 128

NO_MODIFY       = 8

NOWEAPONFRAME   = $ff

RELOAD_FINISH_DELAY = 9                         ;Fixed delay before weapon can be fired after reloading

        ; Actor attack routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

AH_NoAttack:    lda actAttackD,x
                beq AH_SetIdleWeaponFrame
                bpl AH_DecrementDelay      ;Break incomplete melee attack
                lda #$01
                sta actAttackD,x
AH_DecrementDelay:
                dec actAttackD,x
AH_SetIdleWeaponFrame:
                lda actF1,x
                sta actF2,x
                cmp #FR_DIE
                bcs AH_NoWeaponFrame
                ldy #WD_BACKFR
                cmp #FR_ENTER
                bcs AH_BackWeaponFrame
                lda wpnBits                 ;Check for animation lock (for weapons with
                and #WDB_LOCKANIMATION      ;backpack)
                beq AH_NoLockAnimation
                ldy #WD_LOCKANIMFRAME
                lda (wpnLo),y
                sta actF2,x
AH_NoLockAnimation:
                ldy #WD_IDLEFR
AH_SetPrepareWeaponFrame:
                lda actD,x
                bpl AH_NoAttackRight
                iny
AH_NoAttackRight:
AH_BackWeaponFrame:
                lda wpnBits
                lsr
                bcs AH_NoWeaponFrame
                lda (wpnLo),y
                skip2
AH_NoWeaponFrame:
                lda #NOWEAPONFRAME
                sta actWpnF,x
                rts

MoveAndAttackHuman:
                jsr MoveHuman
AttackHuman:    ldy actWpn,x
                beq AH_NoWeaponFrame
                lda actF1,x                     ;No attacks/weapon if dead / rolling / swimming
                cmp #FR_DIE
                bcs AH_NoWeaponFrame
                lda wpnTblLo-1,y
                sta wpnLo
                lda wpnTblHi-1,y
                sta wpnHi
                ldy #WD_BITS
                lda (wpnLo),y
                sta wpnBits
                txa                             ;Ammo check only for player
                bne AH_NotPlayer
AH_AmmoCheck:   ldy itemIndex                   ;Check for ammo & reloading
                lda magazineSize
                bmi AH_AmmoCheckOK              ;Infinite (melee weapon)
AH_CheckReload: cmp invCount,y
                bcc AH_HasFullMagReserve
                lda invCount,y
AH_HasFullMagReserve:
                sta temp1                       ;Reload limit
                lda plrReload
                beq AH_NotReloading
                bmi AH_BeginReload
                cmp temp1
                lda actAttackD+ACTI_PLAYER
                bne AH_NoAttack2                ;While ongoing, keep weapon in down position
                bcs AH_ReloadComplete           ;Reload finished?
                lda actCtrl+ACTI_PLAYER
                cmp #JOY_FIRE
                bcc AH_ReloadNextShot           ;Interrupt shotgun reload by pressing fire
AH_ReloadComplete:
                lda #RELOAD_FINISH_DELAY
                sta actAttackD+ACTI_PLAYER
                lda #$00
                ldy #WD_RELOADDONESFX
                bne AH_PlayReloadSound
AH_NotReloading:lda invMag,y
                bne AH_AmmoCheckOK
AH_EmptyMagazine:
                lda invCount,y                  ;Initiate reloading if mag empty and reserve left
                beq AH_FirearmEmpty
                lda magazineSize                ;Check for magazineless weapon
                beq AH_AmmoCheckOK
AH_BeginReload: lda actAttackD+ACTI_PLAYER      ;Do not start reloading before attack delay
                bne AH_AmmoCheckOK              ;zero
AH_ReloadNextShot:
                lda invType,y                   ;Shotgun reloads one shot at a time
                cmp #ITEM_SHOTGUN               ;but reload can be interrupted
                bne AH_ReloadWholeMagazine
                lda invMag,y
                adc #$00
                cmp temp1
                bcc AH_NotExceeded
AH_ReloadWholeMagazine:
                lda temp1
AH_NotExceeded: sta invMag,y
                pha
                ldy #WD_RELOADDELAY
                lda (wpnLo),y
AH_ReloadDelayBonus:
                ldy #NO_MODIFY
                jsr ModifyDamage
                sta actAttackD+ACTI_PLAYER
                pla
                ldy #WD_RELOADSFX
AH_PlayReloadSound:
                sta plrReload
                lda (wpnLo),y
                jsr PlaySfx
                jsr SetPanelRedrawAmmo
AH_NoAttack2:   jmp AH_NoAttack
AH_FirearmEmpty:lda #$01                        ;If no bullets, set a constant attack delay to
                sta actAttackD+ACTI_PLAYER      ;prevent firing but allow brandishing empty weapon
AH_AmmoCheckOK:
AH_NotPlayer:   lda actCtrl,x
                cmp #JOY_FIRE
                bcc AH_NoAttack2
                and #JOY_LEFT|JOY_RIGHT         ;If left/right attack, turn actor
                beq AH_NoTurn2
                lsr
                lsr
                lsr
                ror
                sta actD,x
AH_NoTurn2:     lda actCtrl,x
AH_NoTurn:      and #JOY_UP|JOY_DOWN|JOY_LEFT|JOY_RIGHT
                tay
                lda attackTbl,y
                bmi AH_NoAttack2
                ldy #WD_MINAIM                  ;Check that aim direction is OK for weapon
                cmp (wpnLo),y                   ;in question
                bcc AH_NoAttack2
                iny
                cmp (wpnLo),y
                bcs AH_NoAttack2
AH_DirOk2:      sta temp2                       ;Final aim direction
                sta AH_FireDir+1
                clc
                ldy wpnBits                     ;Check fire-from-hip animation mode
                bpl AH_NormalAttack
                tay
                lda fromHipFrameTbl-1,y
                skip2
AH_NormalAttack:adc #FR_ATTACK
AH_StoreAttackFrame:
                sta actF2,x
                ldy #WD_ATTACKFR
                lda actD,x
                bpl AH_AimRight
                lda temp2
                adc #5
                sta AH_FireDir+1
                iny
AH_AimRight:    lda wpnBits
                lsr
                lda #NOWEAPONFRAME
                bcs AH_NoWeaponFrame2
                lda (wpnLo),y
                adc temp2
AH_NoWeaponFrame2:
                sta actWpnF,x
                lda actAttackD,x
                beq AH_CanFire
                dec actAttackD,x                ;Decrement delay / progress the melee animation
                bmi AH_MeleeAnimation
                lda wpnBits
                and #WDB_THROW|WDB_MELEE
                beq AH_CannotFire
                bne AH_MeleeIdle
AH_MeleeIdle:   jmp AH_SetIdleWeaponFrame
AH_MeleeStrike:
AH_CannotFire:  rts

AH_CanFire:     lda wpnBits                     ;Check for melee/throw weapon and play its
                and #WDB_THROW|WDB_MELEE        ;animation, else go directly to firing
                beq AH_SpawnBullet
AH_ThrownOrMelee:
                lda #$84                        ;Setup the melee animation counter
                sta actAttackD,x
AH_MeleePrepare:lda #FR_PREPARE                 ;Show prepare frame for hands & weapon
                ldy wpnBits
                cpy #WDB_MELEE
                adc #$00
                sta actF2,x
                ldy #WD_PREPAREFR
                jmp AH_SetPrepareWeaponFrame
AH_MeleeAnimation:
                lda actAttackD,x                ;Check for finishing animation
                cmp #$83
                bcs AH_MeleePrepare
                cmp #$82
                bcs AH_MeleeStrike              ;Show strike frame just before spawning bullet
                inc actAttackD,x                ;In case melee attack fails, stay in strike position

AH_SpawnBullet: lda actCtrl,x                   ;Require debounced input before actually firing
                cmp actPrevCtrl,x               ;to prevent erroneous attack direction
                bne AH_CannotFire
                jsr GetBulletOffset
                txa                             ;Check whether to use player or NPC bullet actor
                beq AH_IsPlayer                 ;indices
                lda #ACTI_FIRSTNPCBULLET
                ldy #ACTI_LASTNPCBULLET
                bne AH_IsNpc
AH_IsPlayer:    lda #ACTI_FIRSTPLRBULLET
                ldy #ACTI_LASTPLRBULLET
AH_IsNpc:       jsr GetFreeActor
                bcc AH_CannotFire
                sty tgtActIndex
                ldy #WD_BULLETTYPE
                lda (wpnLo),y
                ldy tgtActIndex
                jsr SpawnWithOffset
                lda wpnBits
                and #WDB_BULLETDIRFRAME
                beq AH_BulletFrameDone
                lda AH_FireDir+1
AH_BulletFrameDone:
                sta actF1,y
                ldy #WD_BULLETSPEED
                lda (wpnLo),y
                sta temp4
                iny
AH_FireDir:     lda #$00
                clc
                adc (wpnLo),y
                tay
                sty zpSrcLo
                lda bulletXSpdTbl,y
                ldy temp4
                ldx #temp1
                jsr MulU
                ldy zpSrcLo
                lda bulletYSpdTbl,y
                ldy temp4
                ldx #temp3
                jsr MulU
                lda zpSrcLo
                ldx tgtActIndex
                jsr GetCharInfo                 ;Check if spawned inside wall
                and #CI_OBSTACLE                ;and destroy immediately in that case
                bne AH_InsideWall
                lda temp1                       ;Set speed
                sta actSX,x
                lda temp3
                sta actSY,x
                jsr InitActor                   ;Set collision size
                ldy actIndex
                lda actFlags,y
                and #AF_GROUPBITS               ;Copy group from attacker
                sta actFlags,x
                lda #NOTARGET
                sta actAITarget,x               ;Reset target for homing bullets
                ldy #WD_DAMAGE                  ;Set duration and damage
                lda (wpnLo),y
                sta actHp,x
                sta temp8
                iny
                lda (wpnLo),y
                sta actBulletDmgMod-ACTI_FIRSTPLRBULLET,x ;Damage mod nonorganic / organic
                iny
                lda (wpnLo),y
                sta actTime,x
                lda wpnBits                     ;Use flickering for bullets?
                asl
                bpl AH_NoFlicker
                lda #COLOR_FLICKER
                sta actFlash,x
AH_NoFlicker:   ldx actIndex                    ;If player, decrement ammo and apply skill bonus
                bne AH_NoAmmoDecrement
                lda magazineSize
                bmi AH_PlayerMeleeBonus
                ldy itemIndex
                if AMMO_CHEAT=0
                jsr DecreaseAmmoOne
                endif
                lda wpnBits
                and #WDB_NOSKILLBONUS
                bne AH_NoPlayerBonus
AH_PlayerFirearmBonus:
                ldy #NO_MODIFY
                skip2
AH_PlayerMeleeBonus:
                ldy #NO_MODIFY
AH_PlayerBonusCommon:
                lda temp8
                jsr ModifyDamage
                ldy tgtActIndex
                sta actHp,y                     ;Set bullet damage
AH_NoPlayerBonus:
AH_NoAmmoDecrement:
                ldy #WD_ATTACKDELAY
                lda (wpnLo),y
                sta actAttackD,x
                ldy #WD_SFX
                lda (wpnLo),y
                jmp PlaySfx
AH_InsideWall:  jsr RemoveActor
                ldx actIndex
                rts

        ; Find spawn offset for bullet
        ;
        ; Parameters: X actor index
        ; Returns: temp1-temp2 X offset, temp3-temp4 Y offset
        ; Modifies: A,Y,loader temp regs

GetBulletOffset:ldy actT,x
                lda actDispTblLo-1,y            ;Get actor display structure address
                sta actLo
                lda actDispTblHi-1,y
                sta actHi
                lda #$00
                sta temp1
                sta temp2
                sta temp3
                sta temp4
                lda #MAX_SPR                    ;"Draw" the actor in a fake manner
                sta sprIndex                    ;to get the last connect-spot
                jsr DrawActorSub_NoColor
                lda temp1                       ;Multiply pixels back to map coordinates
                asl
                rol temp2
                asl
                rol temp2
                asl
                rol temp2
                sta temp1
                lda temp3
                asl
                rol temp4
                asl
                rol temp4
                asl
                rol temp4
                sta temp3
                ldx actIndex
                rts

        ; Modify damage
        ;
        ; Parameters: A damage Y multiplier (8 = unmodified)
        ; Returns: A modified damage
        ; Modifies: A,Y,loader temp vars

ModifyDamage:   cpy #NO_MODIFY                  ;Optimize the unmodified case
                beq MD_Done
                stx zpBitsLo
                ldx #zpSrcLo
                jsr MulU
                lda zpSrcLo
                lsr zpSrcHi                     ;Divide by 8
                ror
                lsr zpSrcHi
                ror
                lsr zpSrcHi
                ror
                bne MD_NotZero
                lda #$01                        ;Ensure at least 1 point damage
MD_NotZero:     ldx zpBitsLo
MD_Done:        rts
