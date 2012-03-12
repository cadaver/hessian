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
                cpy #FR_CLIMB
                bcs AH_TurnOk
                cpy #FR_STAND                   ;If left/right attack and standing/climbing
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
                rts

attackTbl:      dc.b 0+$80                      ;Up
                dc.b 8+$80                      ;Down
                dc.b 8+$80                      ;Up+Down
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

wpnFrameTbl:    dc.b 0,0                        ;TODO: define per-weapon
                dc.b 1,2
                dc.b 3,4
                dc.b 5,6
                dc.b 7,7