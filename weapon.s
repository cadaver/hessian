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
WD_BULLETTIME   = 5
WD_BITS         = 6
WD_IDLEFR       = 7
WD_IDLEFRLEFT   = 8
WD_PREPAREFR    = 9
WD_PREPAREFRLEFT = 10
WD_ATTACKFR     = 11
WD_ATTACKFRLEFT = 16

WDB_NOWEAPONSPRITE = 1
WDB_MELEE       = 2
WDB_BULLETDIRFRAME = 4

WPN_NONE        = 0
WPN_PISTOL      = 1

        ; Humanoid character attack routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

AH_NoAttack:    lda actAttackD,x                ;When weapon not in firing
                bne AH_NoAttackDelay2           ;position, give 1 frame attack
                lda #1                          ;delay to reduce possibility of firing
                sta actAttackD,x                ;the initial bullet to undesired direction
AH_NoAttackDelay2:
                ldy actF2,x
                cpy #FR_CLIMB
                bcs AH_NoWeapon
                lda temp3
                lsr
                bcs AH_NoWeapon
                ldy #WD_IDLEFR
                lda actD,x
                bpl AH_NoAttackRight
                iny
AH_NoAttackRight:
                lda (wpnLo),y
                bpl AH_WeaponFrameDone
AH_NoWeapon:    lda #$ff                
AH_WeaponFrameDone:
                sta actWpnF,x
                rts

AttackHuman:    lda actAttackD,x
                sta temp2
                beq AH_NoAttackDelay
                dec actAttackD,x
AH_NoAttackDelay:
                ldy actWpn,x
                beq AH_NoWeapon
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
                bcs AH_NoWeaponFrame
                lda (wpnLo),y
AH_NoWeaponFrame:
                sta actWpnF,x
                lda temp2
                bne AH_NoNewBullet
                jsr GetBulletOffset
                bcc AH_NoNewBullet
                lda #ACTI_FIRSTPLRBULLET
                ldy #ACTI_LASTPLRBULLET
                jsr GetFreeActor
                bcc AH_NoNewBullet
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
                ldy temp1
                lda bulletXSpdTbl,y
                ldy temp4
                ldx #zpSrcLo
                jsr MulU
                ldy temp1
                lda bulletYSpdTbl,y
                ldy temp4
                ldx #zpDestLo
                jsr MulU
                lda zpSrcLo
                ldx temp2
                lda zpSrcLo
                sta actSX,x
                lda zpDestLo
                sta actSY,x
                ldy #WD_BULLETTIME
                lda (wpnLo),y
                sta actTime,x
                txa
                jsr GetFlashColorOverride
                sta actC,x
                ldx actIndex
                ldy #WD_ATTACKDELAY
                lda (wpnLo),y
                sta actAttackD,x
AH_NoNewBullet: rts

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
                sta sprFileHi
                lda fileLo,y
                sta sprFileLo
                pla
                asl
                tay
                lda (sprFileLo),y
                sta frameLo
                iny
                lda (sprFileLo),y
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
                

        ; Bullet update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveBullet:     jsr MoveProjectile
                and #CI_OBSTACLE
                bne MBlt_Explode
                dec actTime,x
                bne MBlt_NoRemove
                jmp RemoveActor
MBlt_Explode:   lda #$00
                sta actF1,x
                sta actFd,x
                sta actC,x                      ;Remove flashing
                lda #ACT_EXPLOSION
                sta actT,x
MBlt_NoRemove:  rts

        ; Explosion update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

MoveExplosion:  lda #1
                jsr AnimationDelay
                bcc MExpl_NoAnimation
                inc actF1,x
                lda actF1,x
                cmp #5
                bcc MExpl_NoRemove
                jmp RemoveActor
MExpl_NoAnimation:
MExpl_NoRemove: rts