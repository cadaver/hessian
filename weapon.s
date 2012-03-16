        ; Humanoid character attack routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

AttackHuman:    lda actFireCtrl,x
                beq AH_NoAttack
                ldy actF1,x
                cpy #FR_ROLL
                bcs AH_NoAttack
                cpy #FR_DUCK
                bcs AH_TurnOk
                cpy #FR_STAND                   ;If left/right attack and not walking
                bne AH_NoTurn                   ;turn also actor direction
AH_TurnOk:      and #JOY_LEFT|JOY_RIGHT
                beq AH_NoTurn2
                lsr
                lsr
                lsr
                ror
                sta actD,x
AH_NoTurn2:     lda actFireCtrl,x
AH_NoTurn:      and #JOY_UP|JOY_DOWN|JOY_LEFT|JOY_RIGHT
                beq AH_NoAttack
                tay
                lda actD,x
                asl
                lda attackTbl-1,y               ;When aiming up/down, modify
                bpl AH_FrameOk                  ;frame based on direction
                and #$7f
                adc #$00
AH_FrameOk:     tay
                clc
                adc #FR_ATTACK
                sta actF2,x
                lda wpnFrameTbl,y
                sta actWpnF,x
                rts

AH_NoAttack:    ldy #$ff
                lda actF2,x
                cmp #FR_CLIMB
                bcs AH_WeaponFrameDone
                ldy #3                          ;TODO: define per-weapon
                lda actD,x
                bpl AH_WeaponFrameDone
                iny
AH_WeaponFrameDone:
                tya
                sta actWpnF,x
GBO_Fail:       rts

        ; Find spawn offset for bullet (humanoid actor)
        ;
        ; Parameters: X actor index
        ; Returns: C=1 success: temp1-temp2 X offset, temp3-temp4 Y offset, C=0 failure (sprites unloaded)
        ; Modifies: A,Y,loader temp regs

GetBulletOffset:lda #$00
                sta temp1
                sta temp3
                ldy actT,x
                lda actDispTblLo-1,y            ;Get actor display structure address
                sta zpBitsLo
                lda actDispTblHi-1,y
                sta zpBitsHi
                ldy #AD_SPRFILE
                lda (zpBitsLo),y
                tay
                clc
                lda fileHi,y
                beq GBO_Fail
                sta sprFileHi
                lda fileLo,y
                sta sprFileLo
                lda actF1,x
                ldy actD,x
                bpl GBO_Right
                ldy #ADH_LEFTFRADD              ;Add left frame offset if necessary
                adc (zpBitsLo),y
GBO_Right:      ldy #ADH_BASEINDEX
                adc (zpBitsLo),y
                tay
                lda humanLowerFrTbl,y           ;Take sprite frame from the frametable
                ldy #ADH_BASEFRAME
                adc (zpBitsLo),y
                jsr GBO_Sub
                ldy #ADH_SPRFILE2
                lda (zpBitsLo),y
                tay
                clc
                lda fileHi,y
                beq GBO_Fail
                sta sprFileHi
                lda fileLo,y
                sta sprFileLo
                lda actF2,x
                ldy actD,x
                bpl GBO_Right2
                ldy #ADH_LEFTFRADD2             ;Add left frame offset if necessary
                adc (zpBitsLo),y
GBO_Right2:     ldy #ADH_BASEINDEX2
                adc (zpBitsLo),y
                tay
                lda humanUpperFrTbl,y           ;Take sprite frame from the frametable
                ldy #ADH_BASEFRAME2
                adc (zpBitsLo),y
                jsr GBO_Sub
                lda actWpnF,x                   ;If no weapon frame, spawn projectile from the hand
                bmi GBO_NoWeapon
                ldy fileLo+C_WEAPON
                sty sprFileLo
                ldy fileHi+C_WEAPON
                sty sprFileHi
                jsr GBO_Sub
GBO_NoWeapon:   lda #$00
                asl temp1
                bcc GBO_XPos
                lda #$ff
GBO_XPos:       rol
                asl temp1
                rol
                asl temp1
                rol
                sta temp2
                lda #$00
                asl temp3
                bcc GBO_YPos
                lda #$ff
GBO_YPos:       rol
                asl temp3
                rol
                asl temp3
                rol
                sta temp4
                sec
                rts

GBO_Sub:        asl
                tay
                lda (sprFileLo),y
                sta frameLo
                iny
                lda (sprFileLo),y
                sta frameHi
                ldy #SPRH_HOTSPOTX
                lda temp1
                sec
                sbc (zpSrcLo),y
                iny
                clc
                adc (zpSrcLo),y
                sta temp1
                iny
                lda temp3
                sec
                sbc (zpSrcLo),y
                iny
                clc
                adc (zpSrcLo),y
                sta temp3
                rts
