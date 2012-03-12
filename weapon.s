        ; Humanoid character attack routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y

AttackHuman:    lda actF1,x
                cmp #FR_ROLL
                bcs AH_NoAttack
                lda actFireCtrl,x
                beq AH_NoAttack
                and #JOY_UP|JOY_DOWN|JOY_LEFT|JOY_RIGHT
                beq AH_NoAttack
                tay
                lda actD,x
                bpl AH_FacingRight
AH_FacingLeft:  lda leftAttackTbl-1,y
AH_Common:      tay
                clc
                adc #FR_ATTACK
                sta actF2,x
                lda wpnFrameTbl,y
                sta actWpnF,x
                rts
AH_FacingRight: lda rightAttackTbl-1,y
                jmp AH_Common

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
                rts

rightAttackTbl: dc.b 0                          ;Up
                dc.b 8                          ;Down
                dc.b 0                          ;Up+Down
                dc.b 5                          ;Left
                dc.b 3                          ;Left+Up
                dc.b 7                          ;Left+Down
                dc.b 3                          ;Left+Up+Down
                dc.b 4                          ;Right
                dc.b 2                          ;Right+Up
                dc.b 6                          ;Right+Down
                dc.b 2                          ;Right+Up+Down
                dc.b 4                          ;Right+Left
                dc.b 2                          ;Right+Left+Up
                dc.b 6                          ;Right+Left+Down
                dc.b 2                          ;Right+Left+Up+Down

leftAttackTbl:  dc.b 1                          ;Up
                dc.b 9                          ;Down
                dc.b 1                          ;Up+Down
                dc.b 5                          ;Left
                dc.b 3                          ;Left+Up
                dc.b 7                          ;Left+Down
                dc.b 3                          ;Left+Up+Down
                dc.b 4                          ;Right
                dc.b 2                          ;Right+Up
                dc.b 6                          ;Right+Down
                dc.b 2                          ;Right+Up+Down
                dc.b 5                          ;Right+Left
                dc.b 3                          ;Right+Left+Up
                dc.b 7                          ;Right+Left+Down
                dc.b 3                          ;Right+Left+Up+Down
                
wpnFrameTbl:    dc.b 0,0                        ;TODO: define per-weapon
                dc.b 1,2
                dc.b 3,4
                dc.b 5,6
                dc.b 7,7