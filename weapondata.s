DMG_FISTS       = 4
DMG_FLAMETHROWER = 5
DMG_MINIGUN     = 5
DMG_KNIFE       = 6
DMG_NIGHTSTICK  = 6
DMG_BAT         = 7
DMG_AUTORIFLE   = 6
DMG_PISTOL      = 8
DMG_SONICWAVE   = 10
DMG_SHOTGUN     = 16                            ;Reduced by 3 per animation frame
DMG_LASER       = 14
DMG_PLASMA      = 18
DMG_SNIPERRIFLE = 20
DMG_LAUNCHERGRENADE = 32
DMG_GRENADE     = 40
DMG_DRONE       = 48
DMG_BAZOOKA     = 56
DMG_EMP         = 4                             ;4 damage for 8 frames = 32 total

DMGMOD_EQUAL    = $88                           ;Equal damage to nonorganic / organic
DMGMOD_NOORGANIC = $80                          ;No organic damage
DMGMOD_NONONORGANIC = $08                       ;No nonorganic damage
DMGMOD_NONORGANIC75 = $68                       ;Nonorganic receives 75% of damage
DMGMOD_NONORGANIC12 = $18                       ;Nonorganic receives 12% of damage

SPDTBL_NORMAL   = 0
SPDTBL_GRENADE  = 10
SPDTBL_LAUNCHER = 20

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
                dc.b 0,7,8,7,0                  ;Thrown grenade
                dc.b 0,-7,-8,-7,0
                dc.b 0,7,8,7,0                  ;Launcher grenade
                dc.b 0,-7,-8,-7,0

bulletYSpdTbl:  dc.b -8,-6,0,6,8                ;Normal bullets
                dc.b -8,-6,0,6,8
                dc.b -8,-7,-4,-1,0              ;Thrown grenade
                dc.b -8,-7,-4,-1,0
                dc.b -8,-7,-3,2,0
                dc.b -8,-7,-3,2,0

        ; Weapon data

wpnTblLo:       dc.b <wdFists
                dc.b <wdKnife
                dc.b <wdNightstick
                dc.b <wdBat
                dc.b <wdPistol
                dc.b <wdShotgun
                dc.b <wdAutoRifle
                dc.b <wdSniperRifle
                dc.b <wdMinigun
                dc.b <wdFlameThrower
                dc.b <wdSonicWaveGun
                dc.b <wdLaserRifle
                dc.b <wdPlasmaGun
                dc.b <wdEMPGenerator
                dc.b <wdGrenadeLauncher
                dc.b <wdBazooka
                dc.b <wdGrenade
                dc.b <wdHomingDrone

wpnTblHi:       dc.b >wdFists
                dc.b >wdKnife
                dc.b >wdNightstick
                dc.b >wdBat
                dc.b >wdPistol
                dc.b >wdShotgun
                dc.b >wdAutoRifle
                dc.b >wdSniperRifle
                dc.b >wdMinigun
                dc.b >wdFlameThrower
                dc.b >wdSonicWaveGun
                dc.b >wdLaserRifle
                dc.b >wdPlasmaGun
                dc.b >wdEMPGenerator
                dc.b >wdGrenadeLauncher
                dc.b >wdBazooka
                dc.b >wdGrenade
                dc.b >wdHomingDrone

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
                dc.b DMGMOD_NONORGANIC75        ;Damage modifier nonorganic/organic
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

wdNightstick:   dc.b WDB_MELEE                  ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN           ;Last aim direction
                dc.b 8                          ;Attack delay
                dc.b ACT_MELEEHIT               ;Bullet actor type
                dc.b DMG_NIGHTSTICK             ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 1                          ;Bullet time duration
                dc.b 1                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_MELEE                  ;Sound effect
                dc.b 69                         ;Idle weapon frame (right)
                dc.b 73                         ;Idle weapon frame (left)
                dc.b 73                         ;Prepare weapon frame (right)
                dc.b 69                         ;Prepare weapon frame (left)
                dc.b 70,70,71,72,72             ;Attack weapon frames (right)
                dc.b 74,74,75,76                ;Attack weapon frames (left)

wdBat:          dc.b WDB_MELEE                  ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN           ;Last aim direction
                dc.b 9                          ;Attack delay
                dc.b ACT_LARGEMELEEHIT          ;Bullet actor type
                dc.b DMG_BAT                    ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 1                          ;Bullet time duration
                dc.b 1                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_HEAVYMELEE             ;Sound effect
                dc.b 61                         ;Idle weapon frame (right)
                dc.b 65                         ;Idle weapon frame (left)
                dc.b 66                         ;Prepare weapon frame (right)
                dc.b 62                         ;Prepare weapon frame (left)
                dc.b 62,62,63,64,64             ;Attack weapon frames (right)
                dc.b 66,66,67,68                ;Attack weapon frames (left)

wdPistol:       dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN                   ;Last aim direction
                dc.b 7                          ;Attack delay
                dc.b ACT_BULLET                 ;Bullet actor type
                dc.b DMG_PISTOL                 ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 20                         ;Bullet time duration
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
                dc.b 11                         ;Attack delay
                dc.b ACT_SHOTGUNBULLET          ;Bullet actor type
                dc.b DMG_SHOTGUN                ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 11                         ;Bullet time duration
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
                dc.b 18                         ;Bullet time duration
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
                dc.b 14                         ;Attack delay
                dc.b ACT_RIFLEBULLET            ;Bullet actor type
                dc.b DMG_SNIPERRIFLE            ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 20                         ;Bullet time duration
                dc.b 15                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_SNIPERRIFLE            ;Sound effect
                dc.b 33                         ;Idle weapon frame (right)
                dc.b 38                         ;Idle weapon frame (left)
                dc.b 33                         ;Prepare weapon frame (right)
                dc.b 38                         ;Prepare weapon frame (left)
                dc.b 31,32,33,34,35             ;Attack weapon frames (right)
                dc.b 36,37,38,39,40             ;Attack weapon frames (left)
                dc.b 30                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKSHOTGUN            ;Reload finished sound

wdMinigun:      dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET|WDB_LOCKANIMATION|WDB_FIREFROMHIP ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN           ;Last aim direction
                dc.b 2                          ;Attack delay
                dc.b ACT_RIFLEBULLET            ;Bullet actor type
                dc.b DMG_MINIGUN                ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 14                         ;Bullet time duration
                dc.b 15                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_MINIGUN                ;Sound effect
                dc.b 42                         ;Idle weapon frame (right)
                dc.b 45                         ;Idle weapon frame (left)
                dc.b 42                         ;Prepare weapon frame (right)
                dc.b 45                         ;Prepare weapon frame (left)
                dc.b 41,41,42,43,43             ;Attack weapon frames (right)
                dc.b 44,44,45,46,46             ;Attack weapon frames (left)
                dc.b 30                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKWEAPON             ;Reload finished sound
                dc.b FR_WALK+2                  ;Lock animation upper body frame
                
wdFlameThrower: dc.b WDB_FLICKERBULLET|WDB_LOCKANIMATION|WDB_FIREFROMHIP|WDB_NOSKILLBONUS ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN           ;Last aim direction
                dc.b 2                          ;Attack delay
                dc.b ACT_FLAME                  ;Bullet actor type
                dc.b DMG_FLAMETHROWER           ;Bullet damage
                dc.b DMGMOD_NONORGANIC75        ;Damage modifier nonorganic/organic
                dc.b 15                         ;Bullet time duration
                dc.b 8                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_FLAMETHROWER           ;Sound effect
                dc.b 48                         ;Idle weapon frame (right)
                dc.b 51                         ;Idle weapon frame (left)
                dc.b 48                         ;Prepare weapon frame (right)
                dc.b 51                         ;Prepare weapon frame (left)
                dc.b 47,47,48,49,49             ;Attack weapon frames (right)
                dc.b 50,50,51,52,52             ;Attack weapon frames (left)
                dc.b 35                         ;Reload delay
                dc.b SFX_COCKWEAPON             ;Reload sound
                dc.b SFX_RELOADFLAMER           ;Reload finished sound
                dc.b FR_WALK+2                  ;Lock animation upper body frame

wdSonicWaveGun: dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN                   ;Last aim direction
                dc.b 6                          ;Attack delay
                dc.b ACT_SONICWAVE              ;Bullet actor type
                dc.b DMG_SONICWAVE              ;Bullet damage
                dc.b DMGMOD_NONORGANIC12        ;Damage modifier nonorganic/organic
                dc.b 20                         ;Bullet time duration
                dc.b 14                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_SONICWAVE              ;Sound effect
                dc.b 87                         ;Idle weapon frame (right)
                dc.b 92                         ;Idle weapon frame (left)
                dc.b 87                         ;Prepare weapon frame (right)
                dc.b 92                         ;Prepare weapon frame (left)
                dc.b 85,86,87,88,89             ;Attack weapon frames (right)
                dc.b 90,91,92,93,94             ;Attack weapon frames (left)
                dc.b 25                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_POWERUP                ;Reload finished sound

wdLaserRifle:   dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN                   ;Last aim direction
                dc.b 7                          ;Attack delay
                dc.b ACT_LASER                  ;Bullet actor type
                dc.b DMG_LASER                  ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 18                         ;Bullet time duration
                dc.b 15                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_LASER                  ;Sound effect
                dc.b 99                         ;Idle weapon frame (right)
                dc.b 104                        ;Idle weapon frame (left)
                dc.b 99                         ;Prepare weapon frame (right)
                dc.b 104                        ;Prepare weapon frame (left)
                dc.b 97,98,99,100,101           ;Attack weapon frames (right)
                dc.b 102,103,104,105,106        ;Attack weapon frames (left)
                dc.b 25                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_POWERUP                ;Reload finished sound

wdPlasmaGun:    dc.b WDB_FLICKERBULLET          ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN                   ;Last aim direction
                dc.b 8                          ;Attack delay
                dc.b ACT_PLASMA                 ;Bullet actor type
                dc.b DMG_PLASMA                 ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 21                         ;Bullet time duration
                dc.b 13                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_PLASMA                 ;Sound effect
                dc.b 109                        ;Idle weapon frame (right)
                dc.b 114                        ;Idle weapon frame (left)
                dc.b 109                        ;Prepare weapon frame (right)
                dc.b 114                        ;Prepare weapon frame (left)
                dc.b 107,108,109,110,111        ;Attack weapon frames (right)
                dc.b 112,113,114,115,116        ;Attack weapon frames (left)
                dc.b 25                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_POWERUP                ;Reload finished sound

wdEMPGenerator: dc.b WDB_NONE|WDB_NOSKILLBONUS|WDB_FLICKERBULLET  ;Weapon bits
                dc.b AIM_HORIZONTAL             ;First aim direction
                dc.b AIM_HORIZONTAL             ;Last aim direction
                dc.b 20                         ;Attack delay
                dc.b ACT_EMP                    ;Bullet actor type
                dc.b DMG_EMP                    ;Bullet damage
                dc.b DMGMOD_NOORGANIC           ;Damage modifier nonorganic/organic
                dc.b 8                          ;Bullet time duration
                dc.b 4                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_EMP                    ;Sound effect
                dc.b 95                         ;Idle weapon frame (right)
                dc.b 96                         ;Idle weapon frame (left)
                dc.b 95                         ;Prepare weapon frame (right)
                dc.b 96                         ;Prepare weapon frame (left)
                dc.b 95,95,95,95,95             ;Attack weapon frames (right)
                dc.b 96,96,96,96,96             ;Attack weapon frames (left)
                dc.b 25                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_POWERUP                ;Reload finished sound

wdGrenadeLauncher:
                dc.b WDB_NOSKILLBONUS           ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DIAGONALDOWN           ;Last aim direction
                dc.b 14                         ;Attack delay
                dc.b ACT_LAUNCHERGRENADE        ;Bullet actor type
                dc.b DMG_LAUNCHERGRENADE        ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 25                         ;Bullet time duration
                dc.b 7                          ;Bullet speed in pixels
                dc.b SPDTBL_LAUNCHER            ;Bullet speed table offset
                dc.b SFX_GRENADELAUNCHER        ;Sound effect
                dc.b 55                         ;Idle weapon frame (right)
                dc.b 59                         ;Idle weapon frame (left)
                dc.b 55                         ;Prepare weapon frame (right)
                dc.b 59                         ;Prepare weapon frame (left)
                dc.b 53,54,55,56,56             ;Attack weapon frames (right)
                dc.b 57,58,59,60,60             ;Attack weapon frames (left)
                dc.b 30                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKSHOTGUN            ;Reload finished sound

wdBazooka:      dc.b WDB_BULLETDIRFRAME|WDB_NOSKILLBONUS|WDB_LOCKANIMATION ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DIAGONALDOWN           ;Last aim direction
                dc.b 19                         ;Attack delay
                dc.b ACT_ROCKET                 ;Bullet actor type
                dc.b DMG_BAZOOKA                ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 25                         ;Bullet time duration
                dc.b 10                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_BAZOOKA                ;Sound effect
                dc.b 79                         ;Idle weapon frame (right)
                dc.b 83                         ;Idle weapon frame (left)
                dc.b 79                         ;Prepare weapon frame (right)
                dc.b 83                         ;Prepare weapon frame (left)
                dc.b 77,78,79,80,80             ;Attack weapon frames (right)
                dc.b 81,82,83,84,84             ;Attack weapon frames (left)
                dc.b 20                         ;Reload delay
                dc.b SFX_COCKSHOTGUN            ;Reload sound
                dc.b SFX_RELOADBAZOOKA          ;Reload finished sound
                dc.b FR_PREPARE+1               ;Lock animation upper body frame

wdGrenade:      dc.b WDB_NOWEAPONSPRITE|WDB_THROW|WDB_NOSKILLBONUS ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN           ;Last aim direction
                dc.b 20                         ;Attack delay
                dc.b ACT_GRENADE                ;Bullet actor type
                dc.b DMG_GRENADE                ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 30                         ;Bullet time duration
                dc.b 6                          ;Bullet speed in pixels
                dc.b SPDTBL_GRENADE             ;Bullet speed table offset
                dc.b SFX_THROW                  ;Sound effect

wdHomingDrone:  dc.b WDB_NOWEAPONSPRITE|WDB_THROW|WDB_NOSKILLBONUS ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN           ;Last aim direction
                dc.b 20                         ;Attack delay
                dc.b ACT_DRONE                  ;Bullet actor type
                dc.b DMG_DRONE                  ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 50                         ;Bullet time duration
                dc.b 4                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_DRONE                  ;Sound effect

fromHipFrameTbl:dc.b FR_WALK+4,FR_WALK+2,FR_WALK