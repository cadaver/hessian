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
                ldy #$ff
                lda actF2,x
                cmp #FR_CLIMB
                bcs AH_WeaponFrameDone
                ldy #3                          ;TODO: define weapon frame per-weapon
                lda actD,x
                bpl AH_WeaponFrameDone
                iny
AH_WeaponFrameDone:
                tya
                sta actWpnF,x
                rts

AttackHuman:    lda actAttackD,x
                sta temp2
                beq AH_NoAttackDelay
                dec actAttackD,x
AH_NoAttackDelay:
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
                pha
                clc
                adc #FR_ATTACK
                sta actF2,x
                lda actD,x
                rol
                pla
                rol
                sta temp1
                tay
                lda wpnFrameTbl,y
                sta actWpnF,x
                lda temp2
                bne AH_NoNewBullet
                jsr GetBulletOffset
                bcc AH_NoNewBullet
                lda #ACTI_FIRSTPLRBULLET
                ldy #ACTI_LASTPLRBULLET
                jsr GetFreeActor
                bcc AH_NoNewBullet
                lda #ACT_BULLET
                jsr SpawnWithOffset
                ldx temp1                       ;TODO: define bullet parameters
                lda bulletFrameTbl,x            ;per weapon
                sta actF1,y
                lda bulletXSpdTbl,x
                sta actSX,y
                lda bulletYSpdTbl,x
                sta actSY,y
                lda #20
                sta actTime,y
                tya
                jsr GetFlashColorOverride
                sta actC,y
                ldx actIndex
                lda #6                          ;TODO: define attack delay per-weapon
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