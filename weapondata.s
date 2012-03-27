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

wpnFrameTbl:    dc.b 0,0                        ;TODO: define per-weapon
                dc.b 1,2
                dc.b 3,4
                dc.b 5,6
                dc.b 7,7

bulletFrameTbl: dc.b 0,0
                dc.b 1,3
                dc.b 2,2
                dc.b 3,1
                dc.b 0,0
              
bulletXSpdTbl:  dc.b 0,0
                dc.b 56,-56
                dc.b 80,-80
                dc.b 56,-56
                dc.b 0,0

bulletYSpdTbl:  dc.b -80,-80
                dc.b -56,-56
                dc.b 0,0
                dc.b 56,56
                dc.b 80,80
                
        ; Weapon data pointers

wpnTblLo:       dc.b <wdPistol

wpnTblHi:       dc.b >wdPistol

        ; Weapon data

wdPistol:       dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN                   ;Last aim direction
                dc.b ACT_BULLET                 ;Bullet actor type
                dc.b 6                          ;Attack delay