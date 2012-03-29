        ; Weapon/attack tables

attackTbl:      dc.b AIM_NONE                   ;None
                dc.b AIM_UP                     ;Up
                dc.b AIM_DOWN                   ;Down
                dc.b AIM_NONE                   ;Up+Down
                dc.b AIM_HORIZONTAL             ;Left
                dc.b AIM_DIAGONALUP             ;Left+Up
                dc.b AIM_DIAGONALDOWN           ;Left+Down
                dc.b AIM_NONE                   ;Left+Up+Down
                dc.b AIM_HORIZONTAL             ;Right
                dc.b AIM_DIAGONALUP             ;Right+Up
                dc.b AIM_DIAGONALDOWN           ;Right+Down
                dc.b AIM_NONE                   ;Right+Up+Down
                dc.b AIM_NONE                   ;Right+Left
                dc.b AIM_NONE                   ;Right+Left+Up
                dc.b AIM_NONE                   ;Right+Left+Down
                dc.b AIM_NONE                   ;Right+Left+Up+Down

bulletXSpdTbl:  dc.b 0,6,8,6,0
                dc.b 0,-6,-8,-6,0
                
bulletYSpdTbl:  dc.b -8,-6,0,6,8
                dc.b -8,-6,0,6,8

        ; Weapon data pointers

wpnTblLo:       dc.b <wdPistol

wpnTblHi:       dc.b >wdPistol

        ; Weapon data

wdPistol:       dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN                   ;Last aim direction
                dc.b 6                          ;Attack delay
                dc.b ACT_BULLET                 ;Bullet actor type
                dc.b 10                         ;Bullet speed in pixels
                dc.b 20                         ;Bullet time duration
                dc.b WDB_BULLETDIRFRAME         ;Weapon bits
                dc.b 2                          ;Idle weapon frame (right)
                dc.b 6                          ;Idle weapon frame (left)
                dc.b 2                          ;Prepare weapon frame (right)
                dc.b 6                          ;Prepare weapon frame (left)
                dc.b 0,1,2,3,4                  ;Attack weapon frames (right)
                dc.b 0,5,6,7,4                  ;Attack weapon frames (right)
