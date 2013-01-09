DMG_FISTS       = 2
DMG_KNIFE       = 3
DMG_PISTOL      = 4
DMG_AUTORIFLE   = 4
DMG_SHOTGUN     = 9
DMG_SNIPERRIFLE = 12
DMG_GRENADE     = 16

DMG_BULLETSTAYS = $80                           ;Bullet does not disappear after damage
                                                ;(flamethrower etc.)
DMGMOD_EQUAL    = $88                           ;Equal damage to nonorganic / organic
DMGMOD_NOORGANIC = $80                          ;No organic damage
DMGMOD_NONONORGANIC = $08                       ;No nonorganic damage

SPDTBL_NORMAL   = 0
SPDTBL_GRENADE  = 10

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
                dc.b 0,8,8,8,0                  ;Grenades
                dc.b 0,-8,-8,-8,0

bulletYSpdTbl:  dc.b -8,-6,0,6,8                ;Normal bullets
                dc.b -8,-6,0,6,8
                dc.b -8,-7,-4,-1,0              ;Grenades
                dc.b -8,-7,-4,-1,0

        ; Weapon data

wpnTblLo:       dc.b <wdFists
                dc.b <wdKnife
                dc.b <wdPistol
                dc.b <wdShotgun
                dc.b <wdAutoRifle
                dc.b <wdSniperRifle
                dc.b <wdGrenade

wpnTblHi:       dc.b >wdFists
                dc.b >wdKnife
                dc.b >wdPistol
                dc.b >wdShotgun
                dc.b >wdAutoRifle
                dc.b >wdSniperRifle
                dc.b >wdGrenade

wdFists:        dc.b WDB_NOWEAPONSPRITE|WDB_MELEE ;Weapon bits
                dc.b AIM_HORIZONTAL             ;First aim direction
                dc.b AIM_HORIZONTAL             ;Last aim direction
                dc.b 5                          ;Attack delay
                dc.b ACT_MELEEHIT               ;Bullet actor type
                dc.b DMG_FISTS                  ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 1                          ;Bullet time duration
                dc.b 1                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_PUNCH                  ;Sound effect

wdKnife:        dc.b WDB_MELEE                  ;Weapon bits
                dc.b AIM_HORIZONTAL             ;First aim direction
                dc.b AIM_HORIZONTAL             ;Last aim direction
                dc.b 7                          ;Attack delay
                dc.b ACT_MELEEHIT               ;Bullet actor type
                dc.b DMG_KNIFE                  ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 1                          ;Bullet time duration
                dc.b 1                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_MELEE                  ;Sound effect
                dc.b 8                          ;Idle weapon frame (right)
                dc.b 8                          ;Idle weapon frame (left)
                dc.b 9                          ;Prepare weapon frame (right)
                dc.b 10                         ;Prepare weapon frame (left)
                dc.b 9,9,9,9,9                  ;Attack weapon frames (right)
                dc.b 10,10,10                   ;Attack weapon frames (left)

wdPistol:       dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN                   ;Last aim direction
                dc.b 7                          ;Attack delay
                dc.b ACT_BULLET                 ;Bullet actor type
                dc.b DMG_PISTOL                 ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 16                         ;Bullet time duration
                dc.b 12                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_PISTOL                 ;Sound effect
                dc.b 2                          ;Idle weapon frame (right)
                dc.b 6                          ;Idle weapon frame (left)
                dc.b 2                          ;Prepare weapon frame (right)
                dc.b 6                          ;Prepare weapon frame (left)
                dc.b 0,1,2,3,4                  ;Attack weapon frames (right)
                dc.b 0,5,6,7,4                  ;Attack weapon frames (left)
                dc.b 25                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKWEAPON             ;Reload finished sound

wdShotgun:      dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN                   ;Last aim direction
                dc.b 12                         ;Attack delay
                dc.b ACT_SHOTGUNBULLET          ;Bullet actor type
                dc.b DMG_SHOTGUN                ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 9                          ;Bullet time duration
                dc.b 14                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_SHOTGUN                ;Sound effect
                dc.b 13                         ;Idle weapon frame (right)
                dc.b 18                         ;Idle weapon frame (left)
                dc.b 13                         ;Prepare weapon frame (right)
                dc.b 18                         ;Prepare weapon frame (left)
                dc.b 11,12,13,14,15             ;Attack weapon frames (right)
                dc.b 16,17,18,19,20             ;Attack weapon frames (left)
                dc.b 30                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKSHOTGUN            ;Reload finished sound

wdAutoRifle:    dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN                   ;Last aim direction
                dc.b 3                          ;Attack delay
                dc.b ACT_RIFLEBULLET            ;Bullet actor type
                dc.b DMG_AUTORIFLE              ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 15                         ;Bullet time duration
                dc.b 14                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_AUTORIFLE              ;Sound effect
                dc.b 23                         ;Idle weapon frame (right)
                dc.b 28                         ;Idle weapon frame (left)
                dc.b 23                         ;Prepare weapon frame (right)
                dc.b 28                         ;Prepare weapon frame (left)
                dc.b 21,22,23,24,25             ;Attack weapon frames (right)
                dc.b 26,27,28,29,30             ;Attack weapon frames (left)
                dc.b 30                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKWEAPON             ;Reload finished sound

wdSniperRifle:  dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN                   ;Last aim direction
                dc.b 15                         ;Attack delay
                dc.b ACT_RIFLEBULLET            ;Bullet actor type
                dc.b DMG_SNIPERRIFLE            ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 18                         ;Bullet time duration
                dc.b 15                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_SNIPERRIFLE            ;Sound effect
                dc.b 33                         ;Idle weapon frame (right)
                dc.b 38                         ;Idle weapon frame (left)
                dc.b 33                         ;Prepare weapon frame (right)
                dc.b 38                         ;Prepare weapon frame (left)
                dc.b 31,32,33,34,35             ;Attack weapon frames (right)
                dc.b 36,37,38,39,40             ;Attack weapon frames (left)
                dc.b 35                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKWEAPON             ;Reload finished sound

wdGrenade:      dc.b WDB_NOWEAPONSPRITE|WDB_THROW ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN           ;Last aim direction
                dc.b 15                         ;Attack delay
                dc.b ACT_GRENADE                ;Bullet actor type
                dc.b DMG_GRENADE                ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 30                         ;Bullet time duration
                dc.b 6                          ;Bullet speed in pixels
                dc.b SPDTBL_GRENADE             ;Bullet speed table offset
                dc.b SFX_THROW                  ;Sound effect
