WPN_NONE        = 0
WPN_PISTOL      = 1
WPN_GRENADE     = 2
WPN_LAST        = 2

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

bulletXSpdTbl:  dc.b 0,6,8,6,0                  ;Normal bullets
                dc.b 0,-6,-8,-6,0
                dc.b 0,7,8,7,0                  ;Grenades
                dc.b 0,-7,-8,-7,0

bulletYSpdTbl:  dc.b -8,-6,0,6,8                ;Normal bullets
                dc.b -8,-6,0,6,8
                dc.b -6,-6,-3,0,0               ;Grenades
                dc.b -6,-6,-3,0,0

        ; Weapon data pointers

wpnTblLo:       dc.b <wdPistol
                dc.b <wdGrenade

wpnTblHi:       dc.b >wdPistol
                dc.b >wdGrenade

        ; Weapon data

wdPistol:       dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN                   ;Last aim direction
                dc.b 6                          ;Attack delay
                dc.b ACT_BULLET                 ;Bullet actor type
                dc.b 12                         ;Bullet speed in pixels
                dc.b 0                          ;Bullet speed table offset
                dc.b 18                         ;Bullet time duration
                dc.b WDB_BULLETDIRFRAME|WDB_FLASHBULLET         ;Weapon bits
                dc.b SFX_PISTOL                 ;Sound effect
                dc.b 2                          ;Idle weapon frame (right)
                dc.b 6                          ;Idle weapon frame (left)
                dc.b 2                          ;Prepare weapon frame (right)
                dc.b 6                          ;Prepare weapon frame (left)
                dc.b 0,1,2,3,4                  ;Attack weapon frames (right)
                dc.b 0,5,6,7,4                  ;Attack weapon frames (right)

wdGrenade:      dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN           ;Last aim direction
                dc.b 15                         ;Attack delay
                dc.b ACT_GRENADE                ;Bullet actor type
                dc.b 6                          ;Bullet speed in pixels
                dc.b 10                         ;Bullet speed table offset
                dc.b 30                         ;Bullet time duration
                dc.b WDB_NOWEAPONSPRITE|WDB_MELEE ;Weapon bits
                dc.b SFX_THROW                  ;Sound effect
