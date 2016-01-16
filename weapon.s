AIM_UP          = 0
AIM_DIAGONALUP  = 1
AIM_HORIZONTAL  = 2
AIM_DIAGONALDOWN = 3
AIM_DOWN        = 4
AIM_NONE        = $ff

AB_NONE         = 0
AB_UP           = 1
AB_DIAGONALUP   = 2
AB_HORIZONTAL   = 4
AB_DIAGONALDOWN = 8
AB_DOWN         = 16
AB_ALL          = $1f

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
WD_ATTACKFR     = 13
WD_PREPAREFR    = 14                            ;Melee weapons only
WD_RELOADDELAY  = 14                            ;Firearms only
WD_RELOADSFX    = 15
WD_RELOADDONESFX = 16
WD_LOCKANIMFRAME = 17

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
                bpl AH_DecrementDelay           ;Break incomplete melee attack
                lda #$01
                sta actAttackD,x
AH_DecrementDelay:
                dec actAttackD,x
AH_SetIdleWeaponFrame:
                lda actFlags,x                  ;"Humanoid" with no weapon: do not touch upper part frame
                bmi AH_NoWeaponFrame
                lda actF1,x
                sta actF2,x
                cmp #FR_DIE
                bcs AH_NoWeaponFrame
                ldy #WD_BACKFR
                cmp #FR_ENTER
                bcs AH_SetWeaponFrame
                lda wpnBits                     ;Check for animation lock (for weapons with backpack)
                and #WDB_LOCKANIMATION
                beq AH_NoLockAnimation
                ldy #WD_LOCKANIMFRAME
                lda (wpnLo),y
                sta actF2,x
AH_NoLockAnimation:
                ldy #WD_IDLEFR
AH_SetWeaponFrame:
                lda actFlags,x
                bmi AH_NoWeaponFrame
                lda wpnBits
                lsr
                bcs AH_NoWeaponFrame
                lda actD,x                      ;Check whether to show left or right frame
                asl
                lda (wpnLo),y
                bcc AH_WeaponFrameRight
                cpy #WD_BACKFR                  ;Back frame does not depend on direction
                beq AH_WeaponFrameRight
                eor #$80
AH_WeaponFrameRight:
                skip2
AH_NoWeaponFrame:
                lda #NOWEAPONFRAME
                sta actWpnF,x
                rts

MoveAndAttackHuman:
                jsr MoveHuman
AttackGeneric:
AttackHuman:    ldy actWpn,x
                beq AH_NoWeaponFrame
                lda wpnTblLo-1,y
                sta wpnLo
                lda wpnTblHi-1,y
                sta wpnHi
                lda actF1,x                     ;No attacks/weapon if dead / rolling / swimming
                cmp #FR_DIE
                bcs AH_NoAttack
                ldy #WD_BITS
                lda (wpnLo),y
                sta wpnBits
                txa                             ;Ammo check only for player
                bne AH_NotPlayer
AH_AmmoCheck:   jsr GetCurrentItemMagazineSize  ;Check ammo & reloading
                bcs AH_CheckReload              ;Firearm with magazine
                lda invCount-1,y
                beq AH_FirearmEmpty
                bne AH_AmmoCheckOK
AH_CheckReload: cmp invCount-1,y
                bcc AH_HasFullMagReserve
                lda invCount-1,y
AH_HasFullMagReserve:
                sta temp1                       ;Reload limit
                lda reload
                beq AH_NotReloading
                bmi AH_BeginReload
                cmp temp1
                lda actAttackD+ACTI_PLAYER
                bne AH_NoAttack2                ;While ongoing, keep weapon in down position
                bcs AH_ReloadComplete           ;Reload finished?
                lda menuMode                    ;Interrupt shotgun reload by pressing fire
                bne AH_ReloadNextShot           ;while not in inventory
                lda actCtrl+ACTI_PLAYER
                cmp #JOY_FIRE
                bcc AH_ReloadNextShot
AH_ReloadComplete:
                lda #RELOAD_FINISH_DELAY
                sta actAttackD+ACTI_PLAYER
                lda #$00
                ldy #WD_RELOADDONESFX
                bne AH_PlayReloadSound
AH_NotReloading:lda invMag-ITEM_FIRST_MAG,y
                bne AH_AmmoCheckOK
AH_EmptyMagazine:
                lda invCount-1,y                ;Initiate reloading if mag empty and reserve left
                beq AH_FirearmEmpty
AH_BeginReload: lda actAttackD+ACTI_PLAYER      ;Do not start reloading before attack delay
                bne AH_AmmoCheckOK              ;zero
AH_ReloadNextShot:
                cpy #ITEM_SHOTGUN               ;Shotgun reloads one shot at a time
                bne AH_ReloadWholeMagazine
                lda invMag-ITEM_FIRST_MAG,y
                adc #$00
                cmp temp1
                bcc AH_NotExceeded
AH_ReloadWholeMagazine:
                lda temp1
AH_NotExceeded: sta invMag-ITEM_FIRST_MAG,y
                pha
                ldy #WD_RELOADDELAY
                lda (wpnLo),y
AH_PlayerReloadTimeMod:
                ldy #8
                jsr ModifyDamage
                sta actAttackD+ACTI_PLAYER
                pla
                ldy #WD_RELOADSFX
AH_PlayReloadSound:
                sta reload
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
                ldy actFlags,x                  ;If integrated weapon, all directions are OK
                bmi AH_DirOk2
                ldy #WD_MINAIM                  ;Check that aim direction is OK for weapon
                cmp (wpnLo),y                   ;in question
                bcc AH_NoAttack2
                iny
                cmp (wpnLo),y
                bcs AH_NoAttack2
AH_DirOk2:      sta temp2                       ;Final aim direction
                sta AH_FireDir+1
                clc
                ldy actFlags,x                  ;Do not touch frame for integrated weapon two-part enemies (turret)
                bmi AH_SkipAttackFrame
                ldy wpnBits                     ;Check fire-from-hip animation mode
                bpl AH_NormalAttack
                tay
                lda fromHipFrameTbl-1,y
                skip2
AH_NormalAttack:adc #FR_ATTACK
                sta actF2,x
AH_SkipAttackFrame:
                ldy #WD_ATTACKFR
                lda actD,x
                bpl AH_AimRight
                lda temp2
                adc #5
                sta AH_FireDir+1
AH_AimRight:    jsr AH_SetWeaponFrame
                lda actWpn,x                    ;Extinguisher does not have directional frames
                cmp #ITEM_EXTINGUISHER
                beq AH_NoWeaponFrame2
                lda actWpnF,x
                cmp #NOWEAPONFRAME
                bcs AH_NoWeaponFrame2
                adc temp2
                sta actWpnF,x
AH_NoWeaponFrame2:
                lda actAttackD,x
                beq AH_CanFire
                dec actAttackD,x                ;Decrement delay / progress the melee animation
                bmi AH_MeleeAnimation
                lda wpnBits
                and #WDB_THROW|WDB_MELEE
                beq AH_CannotFire
                bne AH_MeleeIdle
AH_MeleeIdle:   jmp AH_SetIdleWeaponFrame

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
                jmp AH_SetWeaponFrame
AH_MeleeStrike:
AH_CannotFire:  rts
AH_MeleeAnimation:
                lda actAttackD,x                ;Check for finishing animation
                cmp #$83
                bcs AH_MeleePrepare
                cmp #$82
                bcs AH_MeleeStrike              ;Show strike frame just before spawning bullet
                inc actAttackD,x                ;In case melee attack fails, stay in strike position

AH_SpawnBullet: lda actFlags,x                  ;If enemy has integrated weapon, skip the next check
                sta AH_NoWeaponFlag+1
                bmi AH_GetBulletOffset
                ldy #1                          ;First check standing right next to a wall,
                lda actD,x                      ;because otherwise one can stick the gun through it
                bpl AH_SpawnRight
                ldy #-1
AH_SpawnRight:  lda #-3
                jsr GetCharInfoXYOffset
                and #CI_OBSTACLE
                bne AH_CannotFire
AH_GetBulletOffset:
                lda #$00
                sta temp1
                sta temp3
                lda #MAX_SPR                    ;"Draw" the actor in a fake manner
                sta sprIndex                    ;to get the last connect-spot
                jsr DrawActorSub_NoColor
                ldy #$00
                lda temp1                       ;Sign expand sprite offset, convert back
                bpl GBO_XPos                    ;to map coords
                dey
GBO_XPos:       sty temp2
                ldy #$00
                lda temp3
                bpl GBO_YPos
                dey
GBO_YPos:       sty temp4
                ldy #$03
GBO_ShiftLoop:  asl temp1                       ;Convert screen coords back to map coords
                rol temp2
                asl
                rol temp4
                dey
                bne GBO_ShiftLoop
                sta temp3
AttackCustomOffset:
                ldx actIndex                    ;Check whether to use player or NPC bullet actor
                beq AH_IsPlayer                 ;indices
                lda #ACTI_FIRSTNPCBULLET
                ldy #ACTI_LASTNPCBULLET
                bne AH_IsNpc
AH_IsPlayer:    lda actCtrl,x                   ;For player, require debounced input before firing
                cmp actPrevCtrl,x               ;to prevent erroneous attack direction
                bne AH_CannotFire
                lda #ACTI_FIRSTPLRBULLET
                ldy #ACTI_LASTPLRBULLET
AH_IsNpc:       jsr GetFreeActor
                bcc AH_CannotFire
                sty tgtActIndex
                ldy #WD_ATTACKDELAY             ;Set attack delay even if bullet spawn fails
                lda (wpnLo),y                   ;to spread out CPU use
                sta actAttackD,x
                iny                             ;Bullet type
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
                tax
                stx zpSrcLo
                lda temp4
                ldy bulletXSpdTbl,x
                ldx #temp1
                jsr MulU
                ldx zpSrcLo
                lda temp4
                ldy bulletYSpdTbl,x
                ldx #temp3
                jsr MulU
                lda zpSrcLo
                ldx tgtActIndex
                jsr GetCharInfo                 ;Check if spawned inside wall
                and #CI_OBSTACLE                ;and destroy immediately in that case
                beq AH_NotInsideWall
AH_InsideWall:  jsr RemoveActor
                ldx actIndex
                rts
AH_NotInsideWall:lda temp1                       ;Set speed
                sta actSX,x
                lda temp3
                sta actSY,x
                jsr InitActor                   ;Set collision size
AH_NoWeaponFlag:lda #$00                        ;If using integrated weapon, move bullet once
                bpl AH_SkipFirstMove            ;to get direction-dependent separation from the enemy
                lda temp1
                jsr MoveActorX
                lda temp3
                jsr MoveActorY
AH_SkipFirstMove:
                ldy actIndex
                lda actFlags,y
                and #AF_GROUPBITS               ;Copy group from attacker
                sta actFlags,x
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
AH_NoFlicker:   ldx actIndex                    ;If player, decrement ammo (unless melee weapon) and apply skill bonus
                bne AH_NoAmmoDecrement
                lda wpnBits
                and #WDB_MELEE
                bne AH_PlayerMeleeAttack
                ldy itemIndex
                if AMMO_CHEAT = 0
                jsr DecreaseAmmoOne
                endif
                lda wpnBits
                and #WDB_NOSKILLBONUS
                bne AH_NoPlayerBonus
AH_PlayerFirearmBonus:
                ldy #NO_MODIFY
                cpy #NO_MODIFY
                beq AH_NoPlayerBonus
                lda #DRAIN_ASSISTEDAIM          ;Assisted aiming (damage bonus) drains battery
                jsr DrainBattery
                jmp AH_PlayerBonusCommon
AH_PlayerMeleeAttack:
                lda #UPG_STRENGTH
                ldy #DRAIN_MELEE
                jsr DrainBatteryDouble
AH_PlayerMeleeBonus:
                ldy #NO_MODIFY
                cpy #NO_MODIFY
                beq AH_NoPlayerBonus
                dec actAttackD,x                ;When player has strength upgrade, slightly faster melee attacks
AH_PlayerBonusCommon:
                lda temp8
                jsr ModifyDamage
                ldy tgtActIndex
                sta actHp,y                     ;Set modified bullet damage
AH_NoPlayerBonus:
AH_NoAmmoDecrement:
                ldy #WD_SFX
                lda (wpnLo),y
                bmi AH_NoSound
                jmp PlaySfx

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
                ldx zpBitsLo
                lda zpSrcLo
                lsr zpSrcHi                     ;Divide by 8
                ror
                lsr zpSrcHi
                ror
                lsr zpSrcHi
                ror
                bne MD_Done
MD_EnsureOne:   lda #$01                        ;Ensure at least 1 point damage
AH_NoSound:
MD_Done:        rts

