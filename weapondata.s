NOMODIFY        = $80

DMG_DROWNING    = 2+NOMODIFY
DMG_FISTS       = 4
DMG_FLAMETHROWER = 5
DMG_MINIGUN     = 6
DMG_KNIFE       = 6
DMG_NIGHTSTICK  = 6
DMG_AUTORIFLE   = 6
DMG_BAT         = 8
DMG_PISTOL      = 8
DMG_LASER       = 12
DMG_SHOTGUN     = 14                            ;Reduced by 2 per animation frame
DMG_PLASMA      = 16
DMG_SNIPERRIFLE = 20
DMG_LAUNCHERGRENADE = 40
DMG_GRENADE     = 40
DMG_ENEMYMINE   = 40
DMG_MINE        = 56
DMG_BAZOOKA     = 56
DMG_EMP         = 4+NOMODIFY                    ;4 damage for 8 frames = 32 total
DMG_FIRE        = 2+NOMODIFY
DMG_SMOKE       = 1+NOMODIFY
DMG_ANIMALBITE  = 4
DMG_SPIDER      = 1+NOMODIFY
DMG_FLY         = 1+NOMODIFY
DMG_ROCK        = 2+NOMODIFY
DMG_FIREBALL    = 2+NOMODIFY
DMG_STEAM       = 1+NOMODIFY
DMG_LARGESPIDER = 1+NOMODIFY
DMG_ACID        = 16

DMGMOD_EQUAL    = $88                           ;Equal damage to nonorganic / organic
DMGMOD_NOORGANIC = $80                          ;No organic damage
DMGMOD_NONONORGANIC = $08                       ;No nonorganic damage
DMGMOD_NONORGANIC75 = $78                       ;Nonorganic receives 75% of damage

SPDTBL_NORMAL   = 0
SPDTBL_GRENADE  = 9
SPDTBL_LAUNCHER = 18

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
                dc.b 8,8,8,0                    ;Thrown grenade
                dc.b 0,-8,-8,-8
                dc.b 0,7,8,7,0                  ;Launcher grenade
                dc.b 0,-7,-8,-7

bulletYSpdTbl:  dc.b -8,-6,0,6,8                ;Normal bullets
                dc.b -8,-6,0,6,8
                dc.b -7,-4,-1,0                 ;Thrown grenade
                dc.b 0,-7,-4,-1
                dc.b -8,-7,-3,2,0               ;Launcher grenade
                dc.b -8,-7,-3,2

fromHipFrameTbl:dc.b FR_WALK+4,FR_WALK+2,FR_WALK

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
                dc.b <wdLaserRifle
                dc.b <wdPlasmaGun
                dc.b <wdEMPGenerator
                dc.b <wdGrenadeLauncher
                dc.b <wdBazooka
                dc.b <wdExtinguisher
                dc.b <wdGrenade
                dc.b <wdMine
                dc.b <wdAnimalBite

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
                dc.b >wdLaserRifle
                dc.b >wdPlasmaGun
                dc.b >wdEMPGenerator
                dc.b >wdGrenadeLauncher
                dc.b >wdBazooka
                dc.b >wdExtinguisher
                dc.b >wdGrenade
                dc.b >wdMine
                dc.b >wdAnimalBite

wdFists:        dc.b WDB_NOWEAPONSPRITE|WDB_MELEE ;Weapon bits
                dc.b AIM_HORIZONTAL             ;First aim direction
                dc.b AIM_HORIZONTAL+1           ;First invalid aim direction
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
                dc.b AIM_HORIZONTAL+1           ;First invalid aim direction
                dc.b 7                          ;Attack delay
                dc.b ACT_MELEEHIT               ;Bullet actor type
                dc.b DMG_KNIFE                  ;Bullet damage
                dc.b DMGMOD_NONORGANIC75        ;Damage modifier nonorganic/organic
                dc.b 1                          ;Bullet time duration
                dc.b 1                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_MELEE                  ;Sound effect
                dc.b $ff                        ;Climbing weapon frame
                dc.b 5                          ;Idle weapon frame (right)
                dc.b 6-2                        ;Attack weapon frames (right)
                dc.b 6                          ;Prepare weapon frame (right)

wdNightstick:   dc.b WDB_MELEE                  ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN+1         ;First invalid aim direction
                dc.b 8                          ;Attack delay
                dc.b ACT_MELEEHIT               ;Bullet actor type
                dc.b DMG_NIGHTSTICK             ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 1                          ;Bullet time duration
                dc.b 1                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_MELEE                  ;Sound effect
                dc.b $ff                        ;Climbing weapon frame
                dc.b 36                         ;Idle weapon frame (right)
                dc.b 37-1                       ;Attack weapon frames (right)
                dc.b $80+36                     ;Prepare weapon frame (right)

wdBat:          dc.b WDB_MELEE                  ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN+1         ;First invalid aim direction
                dc.b 9                          ;Attack delay
                dc.b ACT_LARGEMELEEHIT          ;Bullet actor type
                dc.b DMG_BAT                    ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 1                          ;Bullet time duration
                dc.b 1                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_HEAVYMELEE             ;Sound effect
                dc.b $ff                        ;Climbing weapon frame
                dc.b 32                         ;Idle weapon frame (right)
                dc.b 33-1                       ;Attack weapon frames (right)
                dc.b $80+33                     ;Prepare weapon frame (right)

wdPistol:       dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET         ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN+1                 ;First invalid aim direction
                dc.b 7                          ;Attack delay
                dc.b ACT_BULLET                 ;Bullet actor type
                dc.b DMG_PISTOL                 ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 22                         ;Bullet time duration
                dc.b 12                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_PISTOL                 ;Sound effect
                dc.b $ff                        ;Climbing weapon frame
                dc.b 2                          ;Idle weapon frame (right)
                dc.b 0                          ;Attack weapon frames (right)
                dc.b 25                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKWEAPON             ;Reload finished sound

wdShotgun:      dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET         ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN+1                 ;First invalid aim direction
                dc.b 10                         ;Attack delay
                dc.b ACT_SHOTGUNBULLET          ;Bullet actor type
                dc.b DMG_SHOTGUN                ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 11                         ;Bullet time duration
                dc.b 13                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_SHOTGUN                ;Sound effect
                dc.b 8                          ;Climbing weapon frame
                dc.b 9                          ;Idle weapon frame (right)
                dc.b 7                          ;Attack weapon frames (right)
                dc.b 8                          ;Reload delay
                dc.b SFX_OBJECT                 ;Reload sound
                dc.b SFX_COCKSHOTGUN            ;Reload finished sound

wdAutoRifle:    dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET         ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN+1                 ;First invalid aim direction
                dc.b 3                          ;Attack delay
                dc.b ACT_RIFLEBULLET            ;Bullet actor type
                dc.b DMG_AUTORIFLE              ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 20                         ;Bullet time duration
                dc.b 13                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_AUTORIFLE              ;Sound effect
                dc.b 13                         ;Climbing weapon frame
                dc.b 14                         ;Idle weapon frame (right)
                dc.b 12                         ;Attack weapon frames (right)
                dc.b 30                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKWEAPON             ;Reload finished sound

wdSniperRifle:  dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET         ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN+1                 ;First invalid aim direction
                dc.b 13                         ;Attack delay
                dc.b ACT_RIFLEBULLET            ;Bullet actor type
                dc.b DMG_SNIPERRIFLE            ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 20                         ;Bullet time duration
                dc.b 14                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_SNIPERRIFLE            ;Sound effect
                dc.b 18                         ;Climbing weapon frame
                dc.b 19                         ;Idle weapon frame (right)
                dc.b 17                         ;Attack weapon frames (right)
                dc.b 35                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKSHOTGUN            ;Reload finished sound

wdMinigun:      dc.b WDB_BULLETDIRFRAME|WDB_LOCKANIMATION|WDB_FIREFROMHIP|WDB_FLICKERBULLET ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN+1         ;First invalid aim direction
                dc.b 2                          ;Attack delay
                dc.b ACT_RIFLEBULLET            ;Bullet actor type
                dc.b DMG_MINIGUN                ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 14                         ;Bullet time duration
                dc.b 15                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_MINIGUN                ;Sound effect
                dc.b 56                         ;Climbing weapon frame
                dc.b 23                         ;Idle weapon frame (right)
                dc.b 22-1                       ;Attack weapon frames (right)
                dc.b 0                          ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKWEAPON             ;Reload finished sound
                dc.b FR_WALK+2                  ;Lock animation upper body frame

wdFlameThrower: dc.b WDB_LOCKANIMATION|WDB_FIREFROMHIP|WDB_NOSKILLBONUS|WDB_FLICKERBULLET ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN+1         ;First invalid aim direction
                dc.b 2                          ;Attack delay
                dc.b ACT_FLAME                  ;Bullet actor type
                dc.b DMG_FLAMETHROWER           ;Bullet damage
                dc.b DMGMOD_NONORGANIC75        ;Damage modifier nonorganic/organic
                dc.b 15                         ;Bullet time duration
                dc.b 7                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_FLAMETHROWER           ;Sound effect
                dc.b 57                         ;Climbing weapon frame
                dc.b 26                         ;Idle weapon frame (right)
                dc.b 25-1                       ;Attack weapon frames (right)
                dc.b 35                         ;Reload delay
                dc.b SFX_COCKWEAPON             ;Reload sound
                dc.b SFX_RELOADFLAMER           ;Reload finished sound
                dc.b FR_WALK+2                  ;Lock animation upper body frame

wdLaserRifle:   dc.b WDB_BULLETDIRFRAME|WDB_FLICKERBULLET         ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN+1                 ;First invalid aim direction
                dc.b 6                          ;Attack delay
                dc.b ACT_LASER                  ;Bullet actor type
                dc.b DMG_LASER                  ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 18                         ;Bullet time duration
                dc.b 15                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_LASER                  ;Sound effect
                dc.b 47                         ;Climbing weapon frame
                dc.b 48                         ;Idle weapon frame (right)
                dc.b 46                         ;Attack weapon frames (right)
                dc.b 25                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_POWERUP                ;Reload finished sound

wdPlasmaGun:    dc.b WDB_FLICKERBULLET          ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DOWN+1                 ;First invalid aim direction
                dc.b 8                          ;Attack delay
                dc.b ACT_PLASMA                 ;Bullet actor type
                dc.b DMG_PLASMA                 ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 22                         ;Bullet time duration
                dc.b 12                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_PLASMA                 ;Sound effect
                dc.b 52                         ;Climbing weapon frame
                dc.b 53                         ;Idle weapon frame (right)
                dc.b 51                         ;Attack weapon frames (right)
                dc.b 30                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_POWERUP                ;Reload finished sound

wdEMPGenerator: dc.b WDB_NOSKILLBONUS|WDB_FLICKERBULLET           ;Weapon bits
                dc.b AIM_HORIZONTAL             ;First aim direction
                dc.b AIM_HORIZONTAL+1           ;First invalid aim direction
                dc.b 20                         ;Attack delay
                dc.b ACT_EMP                    ;Bullet actor type
                dc.b DMG_EMP                    ;Bullet damage
                dc.b DMGMOD_NOORGANIC           ;Damage modifier nonorganic/organic
                dc.b 8                          ;Bullet time duration
                dc.b 4                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_EMP                    ;Sound effect
                dc.b 52                         ;Climbing weapon frame
                dc.b 45                         ;Idle weapon frame (right)
                dc.b 45-2                       ;Attack weapon frames (right)
                dc.b 25                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_POWERUP                ;Reload finished sound

wdGrenadeLauncher:
                dc.b WDB_NOSKILLBONUS           ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DIAGONALDOWN+1         ;First invalid aim direction
                dc.b 14                         ;Attack delay
                dc.b ACT_LAUNCHERGRENADE        ;Bullet actor type
                dc.b DMG_LAUNCHERGRENADE        ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 30                         ;Bullet time duration
                dc.b 7                          ;Bullet speed in pixels
                dc.b SPDTBL_LAUNCHER            ;Bullet speed table offset
                dc.b SFX_GRENADELAUNCHER        ;Sound effect
                dc.b 29                         ;Climbing weapon frame
                dc.b 30                         ;Idle weapon frame (right)
                dc.b 28                         ;Attack weapon frames (right)
                dc.b 30                         ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKSHOTGUN            ;Reload finished sound

wdBazooka:      dc.b WDB_BULLETDIRFRAME|WDB_NOSKILLBONUS|WDB_LOCKANIMATION ;Weapon bits
                dc.b AIM_UP                     ;First aim direction
                dc.b AIM_DIAGONALDOWN+1         ;First invalid aim direction
                dc.b 19                         ;Attack delay
                dc.b ACT_ROCKET                 ;Bullet actor type
                dc.b DMG_BAZOOKA                ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 56                         ;Bullet time duration
                dc.b 10                         ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_BAZOOKA                ;Sound effect
                dc.b 41                         ;Climbing weapon frame
                dc.b 42                         ;Idle weapon frame (right)
                dc.b 40                         ;Attack weapon frames (right)
                dc.b 20                         ;Reload delay
                dc.b SFX_COCKSHOTGUN            ;Reload sound
                dc.b SFX_RELOADBAZOOKA          ;Reload finished sound
                dc.b FR_PREPARE+1               ;Lock animation upper body frame

wdExtinguisher: dc.b WDB_FIREFROMHIP|WDB_NOSKILLBONUS|WDB_FLICKERBULLET ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN+1         ;First invalid aim direction
                dc.b 2                          ;Attack delay
                dc.b ACT_POWDER                 ;Bullet actor type
                dc.b 0                          ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 15                         ;Bullet time duration
                dc.b 6                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_FLAMETHROWER           ;Sound effect
                dc.b NOWEAPONFRAME              ;Climbing weapon frame
                dc.b 58                         ;Idle weapon frame (right)
                dc.b 58                         ;Attack weapon frames (right)
                dc.b 0                          ;Reload delay
                dc.b SFX_RELOAD                 ;Reload sound
                dc.b SFX_COCKWEAPON             ;Reload finished sound

wdGrenade:      dc.b WDB_NOWEAPONSPRITE|WDB_THROW|WDB_NOSKILLBONUS ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DIAGONALDOWN+1         ;First invalid aim direction
                dc.b 20                         ;Attack delay
                dc.b ACT_GRENADE                ;Bullet actor type
                dc.b DMG_GRENADE                ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 30                         ;Bullet time duration
                dc.b 5                          ;Bullet speed in pixels
                dc.b SPDTBL_GRENADE             ;Bullet speed table offset
                dc.b SFX_THROW                  ;Sound effect

wdMine:         dc.b WDB_NOWEAPONSPRITE|WDB_THROW|WDB_NOSKILLBONUS ;Weapon bits
                dc.b AIM_DIAGONALUP             ;First aim direction
                dc.b AIM_DOWN+1                 ;First invalid aim direction
                dc.b 25                         ;Attack delay
                dc.b ACT_MINE                   ;Bullet actor type
                dc.b DMG_MINE                   ;Bullet damage
                dc.b DMGMOD_EQUAL               ;Damage modifier nonorganic/organic
                dc.b 79                         ;Bullet time duration
                dc.b 2                          ;Bullet speed in pixels
                dc.b SPDTBL_GRENADE             ;Bullet speed table offset
                dc.b SFX_MELEE                  ;Sound effect

wdAnimalBite:   dc.b WDB_NOWEAPONSPRITE|WDB_MELEE ;Weapon bits
                dc.b AIM_HORIZONTAL             ;First aim direction
                dc.b AIM_HORIZONTAL+1           ;First invalid aim direction
                dc.b 5                          ;Attack delay
                dc.b ACT_MELEEHIT               ;Bullet actor type
                dc.b DMG_ANIMALBITE             ;Bullet damage
                dc.b DMGMOD_NONONORGANIC        ;Damage modifier nonorganic/organic
                dc.b 1                          ;Bullet time duration
                dc.b 1                          ;Bullet speed in pixels
                dc.b SPDTBL_NORMAL              ;Bullet speed table offset
                dc.b SFX_NONE                   ;Sound effect
