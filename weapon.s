AIM_UP          = 0
AIM_DIAGONALUP  = 1
AIM_HORIZONTAL  = 2
AIM_DIAGONALDOWN = 3
AIM_DOWN        = 4
AIM_NONE        = $ff

WD_MINAIM       = 0
WD_MAXAIM       = 1
WD_ATTACKDELAY  = 2
WD_BULLETTYPE   = 3
WD_BULLETSPEED  = 4
WD_SPEEDTABLEOFFSET = 5
WD_BULLETTIME   = 6
WD_BITS         = 7
WD_SFX          = 8
WD_IDLEFR       = 9
WD_IDLEFRLEFT   = 10
WD_PREPAREFR    = 11
WD_PREPAREFRLEFT = 12
WD_ATTACKFR     = 13
WD_ATTACKFRLEFT = 18

WDB_NONE        = 0
WDB_NOWEAPONSPRITE = 1
WDB_BULLETDIRFRAME = 2
WDB_FLASHBULLET = 4
WDB_THROW       = 8
WDB_MELEE       = 16

        ; Humanoid character attack routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

AH_NoAttack:    lda temp2                       ;When weapon not in firing
                bmi AH_BreakMeleeAttack         ;position, give 1 frame attack
                bne AH_NoAttackDelay2           ;delay to reduce possibility of firing
AH_BreakMeleeAttack:                            ;the initial bullet to undesired direction.
                lda #$01                        ;Also break unfinished melee attack
                sta actAttackD,x
AH_NoAttackDelay2:
AH_SetIdleWeaponFrame:
                ldy actF2,x
                cpy #FR_CLIMB
                bcs AH_NoWeaponFrame
                ldy #WD_IDLEFR
AH_SetPrepareWeaponFrame:
                lda temp3
                lsr
                bcs AH_NoWeaponFrame
                lda actD,x
                bpl AH_NoAttackRight
                iny
AH_NoAttackRight:
                lda (wpnLo),y
                bpl AH_WeaponFrameDone
AH_NoWeaponFrame:
                lda #$ff
AH_WeaponFrameDone:
                sta actWpnF,x
                rts

AttackHuman:    lda actAttackD,x
                sta temp2
                beq AH_NoAttackDelay
                dec actAttackD,x
AH_NoAttackDelay:
                ldy actWpn,x
                beq AH_NoWeaponFrame
                lda wpnTblLo-1,y
                sta wpnLo
                lda wpnTblHi-1,y
                sta wpnHi
                ldy #WD_BITS
                lda (wpnLo),y
                sta temp3
                lda actCtrl,x
                cmp #JOY_FIRE
                bcc AH_NoAttack
                ldy actF1,x
                cpy #FR_ROLL
                bcs AH_NoAttack
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
                bmi AH_NoAttack
                ldy #WD_MINAIM                  ;Check that aim direction is OK for weapon
                cmp (wpnLo),y                   ;in question
                bcc AH_NoAttack
                ldy #WD_MAXAIM
                cmp (wpnLo),y
                beq AH_AimOk
                bcs AH_NoAttack
AH_AimOk:       pha
                clc
                adc #FR_ATTACK
                sta actF2,x
                pla
                ldy actD,x
                bpl AH_AimRight
                adc #5
AH_AimRight:    sta temp1
                adc #WD_ATTACKFR
                tay
                lda temp3
                lsr
                lda #$ff
                bcs AH_NoWeaponFrame2
                lda (wpnLo),y
AH_NoWeaponFrame2:
                sta actWpnF,x
                ldy temp2
                beq AH_CanFire
                bmi AH_CanFire
                lda temp3
                and #WDB_THROW|WDB_MELEE
                beq AH_CannotFire
AH_MeleeIdle:   lda actF1,x                     ;When melee weapon is waiting for next strike,  
                sta actF2,x                     ;put hands in idle position
                jmp AH_SetIdleWeaponFrame
AH_MeleeDelay:
AH_CannotFire:  rts

AH_CanFire:     lda temp3                       ;Check for melee/throw weapon and play its
                and #WDB_THROW|WDB_MELEE        ;animation, else go directly to firing
                beq AH_SpawnBullet
                dey
                cpy #$fc                        ;Check for finishing animation, or reaching
                bcc AH_MeleeIdle                ;"failed to attack" state in which the idle
                beq AH_SpawnBullet               ;hand position is shown
                tya
                sta actAttackD,x
                cpy #$fe
                bcc AH_MeleeDelay
                lda #FR_PREPARE                 ;Set prepare frame for hands & weapon
                ldy temp3
                cpy #WDB_MELEE
                adc #$00
                sta actF2,x
                ldy #WD_PREPAREFR
                jmp AH_SetPrepareWeaponFrame

AH_SpawnBullet: jsr GetBulletOffset
                bcc AH_CannotFire
                txa                             ;Check whether to use player or NPC bullet actor
                bne AH_IsPlayer                 ;indices
                lda #ACTI_FIRSTNPCBULLET
                ldy #ACTI_LASTNPCBULLET
                bne AH_IsNpc
AH_IsPlayer:    lda #ACTI_FIRSTPLRBULLET
                ldy #ACTI_LASTPLRBULLET
AH_IsNpc:       jsr GetFreeActor
                bcc AH_CannotFire
                sty temp2
                ldy #WD_BULLETTYPE
                lda (wpnLo),y
                ldy temp2
                jsr SpawnWithOffset
                lda temp3
                and #WDB_BULLETDIRFRAME
                beq AH_BulletFrameDone
                lda temp1
AH_BulletFrameDone:
                sta actF1,y
                ldy #WD_BULLETSPEED
                lda (wpnLo),y
                sta temp4
                iny
                lda temp1
                clc
                adc (wpnLo),y
                tay
                sty AH_SpdTblOffset+1
                lda bulletXSpdTbl,y
                ldy temp4
                ldx #temp5
                jsr MulU
AH_SpdTblOffset:ldy #$00
                lda bulletYSpdTbl,y
                ldy temp4
                ldx #temp7
                jsr MulU
                lda zpSrcLo
                ldx temp2
                jsr GetCharInfo                 ;Check if spawned inside wall
                and #CI_OBSTACLE                ;and destroy immediately in that case
                bne AH_InsideWall
                lda temp5
                sta actSX,x
                lda temp7
                sta actSY,x
                ldy #WD_BULLETTIME
                lda (wpnLo),y
                sta actTime,x
                lda temp3
                and #WDB_FLASHBULLET
                beq AH_NoBulletFlash
                txa
                jsr GetFlashColorOverride
                sta actC,x
AH_NoBulletFlash:
                ldx actIndex
                ldy #WD_ATTACKDELAY
                lda (wpnLo),y
                sta actAttackD,x
                ldy #WD_SFX
                lda (wpnLo),y
                jmp PlaySfx
AH_InsideWall:  jsr RemoveActor
                ldx actIndex
                rts
                
        ; Find spawn offset for bullet (humanoid actor)
        ;
        ; Parameters: X actor index
        ; Returns: C=1 success (temp5-temp6 X offset, temp7-temp8 Y offset), C=0 failure (sprites unloaded)
        ; Modifies: A,Y,loader temp regs

GetBulletOffset:lda #$00
                sta temp5
                sta temp7
                ldy actT,x
                lda actDispTblLo-1,y            ;Get actor display structure address
                sta actLo
                lda actDispTblHi-1,y
                sta actHi
                clc
                jsr DA_GetHumanFrames
                ldy #AD_SPRFILE
                lda (actLo),y
                tay
                lda DA_HumanFrame1+1
                jsr GBO_Sub
                ldy #ADH_SPRFILE2
                lda (actLo),y
                tay
                lda DA_HumanFrame2+1
                jsr GBO_Sub
                lda actWpnF,x                   ;If no weapon frame, spawn projectile from the hand
                bmi GBO_NoWeapon
                ldy #C_WEAPON
                jsr GBO_Sub
GBO_NoWeapon:   lda #$00
                asl temp5
                bcc GBO_XPos
                lda #$ff
GBO_XPos:       rol
                asl temp5
                rol
                asl temp5
                rol
                sta temp6
                lda #$00
                asl temp7
                bcc GBO_YPos
                lda #$ff
GBO_YPos:       rol
                asl temp7
                rol
                asl temp7
                rol
                sta temp8
                sec
                rts

GBO_Sub:        pha
                lda fileHi,y
                beq GBO_Fail
                sta zpSrcHi
                lda fileLo,y
                sta zpSrcLo
                pla
                asl
                tay
                lda (zpSrcLo),y
                sta frameLo
                iny
                lda (zpSrcLo),y
                sta frameHi
                ldy #SPRH_HOTSPOTX
                lda temp5
                sec
                sbc (frameLo),y
                iny
                clc
                adc (frameLo),y
                sta temp5
                iny
                lda temp7
                sec
                sbc (frameLo),y
                iny
                clc
                adc (frameLo),y
                sta temp7
                rts

GBO_Fail:       pla
                pla
                pla
                clc
                rts
