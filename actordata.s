        ; Human Y-size reduce table based on animation

humanSizeReduceTbl:
                dc.b 1,2,1,0,1,2,1,0,1,2,2,1,6,12,1,0,1,0,1,0,0,0,18,18,18,18,18,18,19,19,19,19

        ; Human actor upper part framenumbers

humanUpperFrTbl:dc.b 1,0,0,1,1,2,2,1,1,2,1,0,0,0,15,13,12,13,14,3,10,11,16,17,18,19,20,21,22,23,24,23,3,4,5,6,7,8,9
                dc.b $80+1,$80+0,$80+0,$80+1,$80+1,$80+2,$80+2,$80+1,$80+1,$80+2,$80+1,$80+0,$80+0,$80+0,15,13,12,13,14,$80+3,$80+10,$80+11,$80+16,$80+17,$80+18,$80+19,$80+20,$80+21,$80+22,$80+23,$80+24,$80+23,$80+3,$80+4,$80+5,$80+6,$80+7,$80+8,$80+9
        ; Tank turret
                dc.b 0,1,2,3
                dc.b $80+0,$80+1,$80+2,$80+3

        ; Human actor lower part framenumbers

humanLowerFrTbl:dc.b $80+0,$80+1,$80+2,$80+3,$80+4,$80+1,$80+2,$80+3,$80+4,$80+5,$80+6,$80+7,$80+8,$80+9,14,14,13,14,15,$80+10,$80+11,$80+12,$80+16,$80+17,$80+18,$80+19,$80+20,$80+21,$80+22,$80+23,$80+24,$80+23
                dc.b 0,1,2,3,4,1,2,3,4,5,6,7,8,9,14,14,13,14,15,10,11,12,16,17,18,19,20,21,22,23,24,23
        ; Tank tracks
                dc.b 2,1,0
                dc.b $80+2,$80+1,$80+0

        ; Turret firing ctrl + frame table

turretFrameTbl:
tankTurretOfs:  dc.b JOY_LEFT|JOY_DOWN|JOY_FIRE,0
                dc.b JOY_RIGHT|JOY_DOWN|JOY_FIRE,0
                dc.b JOY_LEFT|JOY_FIRE,1
                dc.b JOY_RIGHT|JOY_FIRE,1
                dc.b JOY_LEFT|JOY_UP|JOY_FIRE,2
                dc.b JOY_RIGHT|JOY_UP|JOY_FIRE,2
                dc.b JOY_UP|JOY_FIRE,3
                dc.b 0
ceilingTurretOfs:
                dc.b JOY_RIGHT|JOY_FIRE,0
                dc.b JOY_RIGHT|JOY_DOWN|JOY_FIRE,1
                dc.b JOY_DOWN|JOY_FIRE,2
                dc.b JOY_LEFT|JOY_DOWN|JOY_FIRE,3
                dc.b JOY_LEFT|JOY_FIRE,4
                dc.b 0

        ; Actor display data

adMeleeHit      = $0000                         ;Invisible
adLargeMeleeHit = $0000
adExplosionGenerator = $0000
adRockTrap      = $0000
adEyeInvisible  = $0000
adJormungandr   = $0000
adGenerator     = $0000

actDispTblLo:   dc.b <adPlayer
                dc.b <adItem
                dc.b <adMeleeHit
                dc.b <adLargeMeleeHit
                dc.b <adSmokeTrail
                dc.b <adBullet
                dc.b <adShotgunBullet
                dc.b <adRifleBullet
                dc.b <adFlame
                dc.b <adEMP
                dc.b <adLaser
                dc.b <adPlasma
                dc.b <adLauncherGrenade
                dc.b <adGrenade
                dc.b <adRocket
                dc.b <adMine
                dc.b <adExplosion
                dc.b <adSmokeTrail
                dc.b <adWaterSplash
                dc.b <adSmallSplash
                dc.b <adObjectMarker
                dc.b <adSpeechBubble
                dc.b <adExplosionGenerator
                dc.b <adSmallDroid
                dc.b <adLargeDroid
                dc.b <adExplosionGenerator
                dc.b <adFlyingCraft
                dc.b <adSmallWalker
                dc.b <adSmallTank
                dc.b <adFloatingMine
                dc.b <adRollingMine
                dc.b <adCeilingTurret
                dc.b <adFire
                dc.b <adSmokeCloud
                dc.b <adRat
                dc.b <adSpider
                dc.b <adFly
                dc.b <adBat
                dc.b <adFish
                dc.b <adRock
                dc.b <adFireball
                dc.b <adSteam
                dc.b <adOrganicWalker
                dc.b <adGuard
                dc.b <adHeavyGuard
                dc.b <adLightGuard
                dc.b <adCombatRobot
                dc.b <adCombatRobot
                dc.b <adLargeWalker
                dc.b <adScrapMetal
                dc.b <adRockTrap
                dc.b <adCpu
                dc.b <adCpu
                dc.b <adEyeInvisible
                dc.b <adEye
                dc.b <adJormungandr
                dc.b <adLargeTank
                dc.b <adHighWalker
                dc.b <adGenerator
                dc.b <adSecurityChief
                dc.b <adRotorDrone
                dc.b <adLargeSpider
                dc.b <adAcid
                dc.b <adSpiderChunk
                dc.b <adGuard
                dc.b <adThroneChief
                dc.b <adSmallWalker
                dc.b <adScientist1
                dc.b <adScientist2
                dc.b <adScientist3
                dc.b <adHacker
                dc.b <adHazmat
                dc.b <adCombatRobot
                dc.b <adEndingSprites
                dc.b <adRotorDrone

actDispTblHi:   dc.b >adPlayer
                dc.b >adItem
                dc.b >adMeleeHit
                dc.b >adLargeMeleeHit
                dc.b >adSmokeTrail
                dc.b >adBullet
                dc.b >adShotgunBullet
                dc.b >adRifleBullet
                dc.b >adFlame
                dc.b >adEMP
                dc.b >adLaser
                dc.b >adPlasma
                dc.b >adLauncherGrenade
                dc.b >adGrenade
                dc.b >adRocket
                dc.b >adMine
                dc.b >adExplosion
                dc.b >adSmokeTrail
                dc.b >adWaterSplash
                dc.b >adSmallSplash
                dc.b >adObjectMarker
                dc.b >adSpeechBubble
                dc.b >adExplosionGenerator
                dc.b >adSmallDroid
                dc.b >adLargeDroid
                dc.b >adExplosionGenerator
                dc.b >adFlyingCraft
                dc.b >adSmallWalker
                dc.b >adSmallTank
                dc.b >adFloatingMine
                dc.b >adRollingMine
                dc.b >adCeilingTurret
                dc.b >adFire
                dc.b >adSmokeCloud
                dc.b >adRat
                dc.b >adSpider
                dc.b >adFly
                dc.b >adBat
                dc.b >adFish
                dc.b >adRock
                dc.b >adFireball
                dc.b >adSteam
                dc.b >adOrganicWalker
                dc.b >adGuard
                dc.b >adHeavyGuard
                dc.b >adLightGuard
                dc.b >adCombatRobot
                dc.b >adCombatRobot
                dc.b >adLargeWalker
                dc.b >adScrapMetal
                dc.b >adRockTrap
                dc.b >adCpu
                dc.b >adCpu
                dc.b >adEyeInvisible
                dc.b >adEye
                dc.b >adJormungandr
                dc.b >adLargeTank
                dc.b >adHighWalker
                dc.b >adGenerator
                dc.b >adSecurityChief
                dc.b >adRotorDrone
                dc.b >adLargeSpider
                dc.b >adAcid
                dc.b >adSpiderChunk
                dc.b >adGuard
                dc.b >adThroneChief
                dc.b >adSmallWalker
                dc.b >adScientist1
                dc.b >adScientist2
                dc.b >adScientist3
                dc.b >adHacker
                dc.b >adHazmat
                dc.b >adCombatRobot
                dc.b >adEndingSprites
                dc.b >adRotorDrone

adPlayer:       dc.b HUMANOID                   ;Number of sprites
adPlayerBottomSprFile:
                dc.b C_PLAYER_BOTTOM            ;Lower part spritefile number
                dc.b 0                          ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 32                         ;Lower part left frame add
adPlayerTopSprFile:
                dc.b C_PLAYER_TOP               ;Upper part spritefile number
                dc.b 0                          ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 39                         ;Upper part left frame add

adItem:         dc.b ONESPRITE                  ;Number of sprites
                dc.b C_ITEM                     ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 38                         ;Number of frames
itemFrames:     dc.b 0,0,1,2,3,4,5,6,7,8,9,10   ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 11,12,13,14,22,15,16,17,18
                dc.b 19,23,24,25,26,29,20,20,20,20,20,20,20,20,20,20,21
                dc.b 28,30,27

adBullet:       dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 20                         ;Number of frames
                dc.b 8,9,10,11,12               ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 8,$80+9,$80+10,$80+11,12
                dc.b 5,6,7,$80+6,5
                dc.b 5,$80+6,7,6,5

adShotgunBullet:dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 14                         ;Number of frames
                dc.b 8,9,10,11,12               ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 8,$80+9,$80+10,$80+11,12
                dc.b 14,15,16,17

adRifleBullet:  dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 20                         ;Number of frames
                dc.b 18,19,20,21,22             ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 18,$80+19,$80+20,$80+21,22
                dc.b 5,6,7,$80+6,5
                dc.b 5,$80+6,7,6,5

adFlame:        dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 23                         ;Base spritenumber

adEMP:          dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 37                         ;Base spritenumber

adLaser:        dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 12                         ;Number of frames
                dc.b 41,42,43,$80+42,41         ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 41,$80+42,43,42,41
                dc.b 61,$80+61

adPlasma:       dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 44                         ;Base spritenumber

adLauncherGrenade:
                dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 27                         ;Base spritenumber

adGrenade:      dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 13                         ;Base spritenumber

adRocket:       dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 10                         ;Number of frames
                dc.b 30,31,32,33,34             ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 30,$80+31,$80+32,$80+33,34

adMine:         dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 55                         ;Base spritenumber

adExplosion:    dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Base spritenumber

adSmokeTrail:   dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 35                         ;Base spritenumber

adWaterSplash:  dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 45                         ;Base spritenumber

adSmallSplash:  dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 50                         ;Base spritenumber

adObjectMarker: dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 53                         ;Base spritenumber

adSpeechBubble: dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 54                         ;Base spritenumber

adSmallDroid:   dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_SMALLROBOTS              ;Spritefile number
                dc.b 0                          ;Base spritenumber

adLargeDroid:   dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_SMALLROBOTS              ;Spritefile number
                dc.b 3                          ;Base spritenumber

adFlyingCraft:  dc.b ONESPRITE                  ;Number of sprites
                dc.b C_SMALLROBOTS              ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 5                          ;Number of frames
                dc.b $80+6,$80+7,8,7,6

adSmallWalker:  dc.b ONESPRITE                  ;Number of sprites
                dc.b C_MEDIUMROBOTS             ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 12                         ;Number of frames
                dc.b 1,0,1,2,1,0,1,2,1,3,3,1

adSmallTank:    dc.b HUMANOID                   ;Number of sprites
                dc.b C_MEDIUMROBOTS             ;Lower part spritefile number
                dc.b 4                          ;Lower part base spritenumber
                dc.b 64                         ;Lower part base index into the frametable
                dc.b 3                          ;Lower part left frame add
                dc.b C_MEDIUMROBOTS             ;Upper part spritefile number
                dc.b 7                          ;Upper part base spritenumber
                dc.b 78                         ;Upper part base index into the frametable
                dc.b 4                          ;Upper part left frame add

adFloatingMine: dc.b ONESPRITE                  ;Number of sprites
                dc.b C_HAZARDS2                 ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 4                          ;Number of frames
                dc.b 3,4,5,4

adRollingMine:  dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_HAZARDS2                 ;Spritefile number
                dc.b 6                          ;Base spritenumber

adCeilingTurret:dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_SMALLROBOTS              ;Spritefile number
                dc.b 9                          ;Base spritenumber

adFire:         dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_HAZARDS                  ;Spritefile number
                dc.b 0                          ;Base spritenumber

adSmokeCloud:   dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_HAZARDS                  ;Spritefile number
                dc.b 4                          ;Base spritenumber

adRat:          dc.b ONESPRITE                  ;Number of sprites
                dc.b C_HAZARDS                  ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 14                         ;Number of frames
                dc.b 13,12,13,14,13,12,13,14,13,15,15,15,16,17

adSpider:       dc.b ONESPRITE                  ;Number of sprites
                dc.b C_ANIMALS                  ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 5                          ;Number of frames
                dc.b 5,6,7,8,9

adFly:          dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_ANIMALS                  ;Spritefile number
                dc.b 17                         ;Base spritenumber

adBat:          dc.b ONESPRITE                  ;Number of sprites
                dc.b C_ANIMALS                  ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 7                          ;Number of frames
                dc.b 0,1,2,3,2,1,4

adFish:         dc.b ONESPRITE                  ;Number of sprites
                dc.b C_ANIMALS                  ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 4                          ;Number of frames
                dc.b 10,11

adRock:         dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_HAZARDS2                 ;Spritefile number
                dc.b 0                          ;Base spritenumber

adFireball:     dc.b ONESPRITE                  ;Number of sprites
                dc.b C_HIGHWALKER               ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 4                          ;Number of frames
                dc.b 10,11,12,11

adSteam:        dc.b ONESPRITE                  ;Number of sprites
                dc.b C_HAZARDS                  ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 3                          ;Number of frames
                dc.b 8,9,10,11

adOrganicWalker:dc.b ONESPRITE                  ;Number of sprites
                dc.b C_ANIMALS                  ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 14                         ;Number of frames
                dc.b 13,12,13,14,13,12,13,14,13,15,15,13,12,16

adGuard:        dc.b HUMANOID                   ;Number of sprites
                dc.b C_GUARD                    ;Lower part spritefile number
                dc.b 15                         ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 32                         ;Lower part left frame add
                dc.b C_GUARD                    ;Upper part spritefile number
                dc.b 0                          ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 39                         ;Upper part left frame add

adHeavyGuard:   dc.b HUMANOID                   ;Number of sprites
                dc.b C_HEAVYGUARD               ;Lower part spritefile number
                dc.b 15                         ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 32                         ;Lower part left frame add
                dc.b C_HEAVYGUARD               ;Upper part spritefile number
                dc.b 0                          ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 39                         ;Upper part left frame add

adLightGuard:   dc.b HUMANOID                   ;Number of sprites
                dc.b C_GUARD                    ;Lower part spritefile number
                dc.b 15                         ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 32                         ;Lower part left frame add
                dc.b C_GUARD                    ;Upper part spritefile number
                dc.b 31                         ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 39                         ;Upper part left frame add

adCombatRobot:  dc.b HUMANOID                   ;Number of sprites
                dc.b C_COMBATROBOT              ;Lower part spritefile number
                dc.b 15                         ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 32                         ;Lower part left frame add
                dc.b C_COMBATROBOT              ;Upper part spritefile number
                dc.b 0                          ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 39                         ;Upper part left frame add

adLargeWalker:  dc.b FOURSPRITE                 ;Number of sprites
                dc.b C_LARGEWALKER              ;Spritefile number
                dc.b 4                          ;Left frame add
                dc.b 8                          ;Number of frames
                dc.b 0,1,2,1,$80+0,$80+1,$80+2,$80+1
                dc.b 3,4,5,4,$80+3,$80+4,$80+5,$80+4
                dc.b 6,6,6,6,$80+6,$80+6,$80+6,$80+6
                dc.b 7,8,9,8,$80+7,$80+8,$80+9,$80+8

adScrapMetal:   dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 57                         ;Base spritenumber

adCpu:          dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_SERVER                   ;Spritefile number
                dc.b 0                          ;Base spritenumber

adEye:          dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_SERVER                   ;Spritefile number
                dc.b 1                          ;Base spritenumber

adLargeTank:    dc.b FOURSPRITE                 ;Number of sprites
                dc.b C_LARGETANK                ;Spritefile number
                dc.b 4                          ;Left frame add
                dc.b 8                          ;Number of frames
                dc.b 2,1,0,8,$80+0,$80+2,$80+1,$80+8
                dc.b 5,4,3,9,$80+3,$80+5,$80+4,$80+9
                dc.b 6,6,6,10,$80+6,$80+6,$80+6,$80+10
                dc.b 7,7,7,11,$80+7,$80+7,$80+7,$80+11

adHighWalker:   dc.b THREESPRITE                ;Number of sprites
                dc.b C_HIGHWALKER               ;Spritefile number
                dc.b 4                          ;Left frame add
                dc.b 8                          ;Number of frames
                dc.b 6,7,8,9,$80+6,$80+7,$80+8,$80+9
                dc.b 2,3,4,5,$80+2,$80+3,$80+4,$80+5
                dc.b 0,0,1,1,$80+0,$80+0,$80+1,$80+1

adSecurityChief:dc.b HUMANOID                   ;Number of sprites
                dc.b C_HEAVYGUARD               ;Lower part spritefile number
                dc.b 15                         ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 32                         ;Lower part left frame add
                dc.b C_SECURITYCHIEF            ;Upper part spritefile number
                dc.b 0                          ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 39                         ;Upper part left frame add

adRotorDrone:   dc.b TWOSPRITE                  ;Number of sprites
                dc.b C_ROTORDRONE               ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 1                          ;Number of frames
adRotorDroneFrames:
                dc.b 0
                dc.b 2

adLargeSpider:  dc.b FIVESPRITE                 ;Number of sprites
                dc.b C_LARGESPIDER              ;Spritefile number
                dc.b 4                          ;Left frame add
                dc.b 8                          ;Number of frames
                dc.b 7,10,13,13,$80+10,$80+7,$80+13,$80+13
                dc.b 6,9,12,12,$80+9,$80+6,$80+12,$80+12
                dc.b 0,2,4,4,$80+2,$80+0,$80+4,$80+4
                dc.b 1,3,5,5,$80+3,$80+1,$80+5,$80+5
                dc.b 8,11,14,15,$80+11,$80+8,$80+14,$80+15

adAcid:         dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_LARGESPIDER              ;Spritefile number
                dc.b 16                         ;Base spritenumber

adSpiderChunk:  dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_LARGESPIDER              ;Spritefile number
                dc.b 20                         ;Base spritenumber

adThroneChief:  dc.b TWOSPRITE                  ;Number of sprites
                dc.b C_GUARD                    ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 1                          ;Number of frames
                dc.b 44
                dc.b 43

adScientist1:   dc.b HUMANOID                   ;Number of sprites
                dc.b C_SCIENTIST                ;Lower part spritefile number
                dc.b 16                         ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 32                         ;Lower part left frame add
                dc.b C_SCIENTIST                ;Upper part spritefile number
                dc.b 0                          ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 39                         ;Upper part left frame add

adScientist2:   dc.b HUMANOID                   ;Number of sprites
                dc.b C_SCIENTIST                ;Lower part spritefile number
                dc.b 16                         ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 32                         ;Lower part left frame add
                dc.b C_SCIENTIST                ;Upper part spritefile number
                dc.b 4                          ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 39                         ;Upper part left frame add

adScientist3:   dc.b HUMANOID                   ;Number of sprites
                dc.b C_SCIENTIST                ;Lower part spritefile number
                dc.b 16                         ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 32                         ;Lower part left frame add
                dc.b C_SCIENTIST                ;Upper part spritefile number
                dc.b 29                         ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 39                         ;Upper part left frame add

adHacker:       dc.b HUMANOID                   ;Number of sprites
                dc.b C_HACKER                   ;Lower part spritefile number
                dc.b 15                         ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 32                         ;Lower part left frame add
                dc.b C_HACKER                   ;Upper part spritefile number
                dc.b 0                          ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 39                         ;Upper part left frame add

adHazmat:       dc.b HUMANOID                   ;Number of sprites
                dc.b C_HAZMAT                   ;Lower part spritefile number
                dc.b 3                          ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 32                         ;Lower part left frame add
                dc.b C_HAZMAT                   ;Upper part spritefile number
                dc.b 0                          ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 39                         ;Upper part left frame add

adEndingSprites:dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_ENDING                   ;Spritefile number
                dc.b 0                          ;Base spritenumber

        ; Actor logic data

actLogicTblLo:  dc.b <alPlayer
                dc.b <alItem
                dc.b <alMeleeHit
                dc.b <alLargeMeleeHit
                dc.b <alPowder
                dc.b <alBullet
                dc.b <alShotgunBullet
                dc.b <alBullet
                dc.b <alFlame
                dc.b <alEMP
                dc.b <alLaser
                dc.b <alPlasma
                dc.b <alLauncherGrenade
                dc.b <alGrenade
                dc.b <alRocket
                dc.b <alMine
                dc.b <alExplosion
                dc.b <alSmokeTrail
                dc.b <alWaterSplash
                dc.b <alSmallSplash
                dc.b <alObjectMarker
                dc.b <alSpeechBubble
                dc.b <alExplosionGenerator
                dc.b <alSmallDroid
                dc.b <alLargeDroid
                dc.b <alExplosionGeneratorRising
                dc.b <alFlyingCraft
                dc.b <alSmallWalker
                dc.b <alSmallTank
                dc.b <alFloatingMine
                dc.b <alRollingMine
                dc.b <alCeilingTurret
                dc.b <alFire
                dc.b <alSmokeCloud
                dc.b <alRat
                dc.b <alSpider
                dc.b <alFly
                dc.b <alBat
                dc.b <alFish
                dc.b <alRock
                dc.b <alFireball
                dc.b <alSteam
                dc.b <alOrganicWalker
                dc.b <alGuard
                dc.b <alHeavyGuard
                dc.b <alLightGuard
                dc.b <alCombatRobot
                dc.b <alCombatRobotFast
                dc.b <alLargeWalker
                dc.b <alScrapMetal
                dc.b <alRockTrap
                dc.b <alCpu
                dc.b <alSuperCpu
                dc.b <alEyeInvisible
                dc.b <alEye
                dc.b <alJormungandr
                dc.b <alLargeTank
                dc.b <alHighWalker
                dc.b <alGenerator
                dc.b <alSecurityChief
                dc.b <alRotorDrone
                dc.b <alLargeSpider
                dc.b <alAcid
                dc.b <alScrapMetal
                dc.b <alArmorer
                dc.b <alDoNothing
                dc.b <alMediumWalker
                dc.b <alScientist1
                dc.b <alScientist23
                dc.b <alScientist23
                dc.b <alHacker
                dc.b <alScientist23
                dc.b <alCombatRobotSaboteur
                dc.b <alDoNothing
                dc.b <alDoNothing

actLogicTblHi:  dc.b >alPlayer
                dc.b >alItem
                dc.b >alMeleeHit
                dc.b >alLargeMeleeHit
                dc.b >alPowder
                dc.b >alBullet
                dc.b >alShotgunBullet
                dc.b >alBullet
                dc.b >alFlame
                dc.b >alEMP
                dc.b >alLaser
                dc.b >alPlasma
                dc.b >alLauncherGrenade
                dc.b >alGrenade
                dc.b >alRocket
                dc.b >alMine
                dc.b >alExplosion
                dc.b >alSmokeTrail
                dc.b >alWaterSplash
                dc.b >alSmallSplash
                dc.b >alObjectMarker
                dc.b >alSpeechBubble
                dc.b >alExplosionGenerator
                dc.b >alSmallDroid
                dc.b >alLargeDroid
                dc.b >alExplosionGeneratorRising
                dc.b >alFlyingCraft
                dc.b >alSmallWalker
                dc.b >alSmallTank
                dc.b >alFloatingMine
                dc.b >alRollingMine
                dc.b >alCeilingTurret
                dc.b >alFire
                dc.b >alSmokeCloud
                dc.b >alRat
                dc.b >alSpider
                dc.b >alFly
                dc.b >alBat
                dc.b >alFish
                dc.b >alRock
                dc.b >alFireball
                dc.b >alSteam
                dc.b >alOrganicWalker
                dc.b >alGuard
                dc.b >alHeavyGuard
                dc.b >alLightGuard
                dc.b >alCombatRobot
                dc.b >alCombatRobotFast
                dc.b >alLargeWalker
                dc.b >alScrapMetal
                dc.b >alRockTrap
                dc.b >alCpu
                dc.b >alSuperCpu
                dc.b >alEyeInvisible
                dc.b >alEye
                dc.b >alJormungandr
                dc.b >alLargeTank
                dc.b >alHighWalker
                dc.b >alGenerator
                dc.b >alSecurityChief
                dc.b >alRotorDrone
                dc.b >alLargeSpider
                dc.b >alAcid
                dc.b >alScrapMetal
                dc.b >alArmorer
                dc.b >alDoNothing
                dc.b >alMediumWalker
                dc.b >alScientist1
                dc.b >alScientist23
                dc.b >alScientist23
                dc.b >alHacker
                dc.b >alScientist23
                dc.b >alCombatRobotSaboteur
                dc.b >alDoNothing
                dc.b >alDoNothing

alPlayer:       dc.w MovePlayer                 ;Update routine
                dc.b GRP_HEROES|AF_ORGANIC|AF_NOREMOVECHECK|AF_INITONLYSIZE ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 34                         ;Size up
                dc.b 0                          ;Size down
                dc.w HumanDeath                 ;Destroy routine
                dc.b HP_PLAYER                  ;Initial health
plrDmgModify:   dc.b NO_MODIFY                  ;Damage modifier
                dc.w 0                          ;Score from kill
                dc.b AIMODE_IDLE                ;AI mode when spawned randomly
                dc.b ITEM_NONE                  ;Itemdrop type or item override
                dc.b $ff                        ;AI offense random AND-value
                dc.b $ff                        ;AI defense probability
                dc.b $ff                        ;Attack directions
                dc.b AMF_JUMP|AMF_DUCK|AMF_CLIMB|AMF_ROLL|AMF_WALLFLIP|AMF_FALLDAMAGE ;Move flags
                dc.b 4*8                        ;Max. movement speed
plrGroundAcc:   dc.b INITIAL_GROUNDACC          ;Ground movement acceleration
plrInAirAcc:    dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
plrGroundBrake:dc.b INITIAL_GROUNDBRAKE+1       ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)
plrJumpSpeed:   dc.b -INITIAL_JUMPSPEED         ;Jump initial speed (negative)
plrClimbSpeed:  dc.b INITIAL_CLIMBSPEED         ;Climbing speed

alItem:         dc.w MoveItem                   ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 7                          ;Size up
                dc.b 0                          ;Size down

alMeleeHit:     dc.w MoveMeleeHit               ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 4                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 3                          ;Size down

alLargeMeleeHit:dc.w MoveMeleeHit               ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 7                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 3                          ;Size down

alPowder:       dc.w MovePowder                 ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 1                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 3                          ;Size down

alBullet:       dc.w MoveBulletMuzzleFlash      ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 2                          ;Horizontal size
                dc.b 1                          ;Size up
                dc.b 1                          ;Size down

alShotgunBullet:dc.w MoveShotgunBullet          ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 3                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 3                          ;Size down

alFlame:        dc.w MoveFlame                  ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 5                          ;Horizontal size
                dc.b 5                          ;Size up
                dc.b 3                          ;Size down

alEMP:          dc.w MoveEMP                    ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 128                        ;Horizontal size
                dc.b 128                        ;Size up
                dc.b 128                        ;Size down

alLaser:        dc.w MoveBullet                 ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 3                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 3                          ;Size down

alPlasma:       dc.w MoveBullet                 ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 6                          ;Horizontal size
                dc.b 5                          ;Size up
                dc.b 5                          ;Size down

alLauncherGrenade:
                dc.w MoveLauncherGrenade        ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 3                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 3                          ;Size down

alGrenade:      dc.w MoveGrenade                ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 3                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 3                          ;Size down

alRocket:       dc.w MoveRocket                 ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 4                          ;Horizontal size
                dc.b 2                          ;Size up
                dc.b 2                          ;Size down

alMine:         dc.w MoveMine                   ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 4                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 0                          ;Size down

alWaterSplash:
alExplosion:    dc.w MoveExplosion              ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags

alSmokeTrail:   dc.w MoveSmokeTrail             ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags

alSmallSplash:  dc.w MoveSmallSplash            ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags

alObjectMarker: dc.w MoveObjectMarker           ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags

alSpeechBubble: dc.w MoveSpeechBubble           ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags

alExplosionGenerator:
                dc.w MoveExplosionGenerator     ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags

alSmallDroid:   dc.w MoveDroid                  ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 6                          ;Horizontal size
                dc.b 6                          ;Size up
                dc.b 6                          ;Size down
                dc.w ExplodeEnemy               ;Destroy routine
                dc.b HP_SMALLDROID              ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 25                         ;Score from kill
                dc.b AIMODE_FLYER               ;AI mode when spawned randomly
                dc.b DROP_BATTERY|DROP_PARTS    ;Itemdrop type or item override
                dc.b $09                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_ALL                     ;Attack directions
                dc.b 3*8                        ;Horiz max movement speed
                dc.b 1                          ;Horiz acceleration
                dc.b 2*8-2                      ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 0                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alLargeDroid:   dc.w MoveDroid                  ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON|AF_NOREMOVECHECK ;Actor flags
                dc.b 9                          ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 8                          ;Size down
                dc.w ExplodeEnemy2_8            ;Destroy routine
                dc.b HP_LARGEDROID              ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 75                         ;Score from kill
                dc.b AIMODE_FLYER               ;AI mode when spawned randomly
                dc.b DROP_BATTERY|DROP_PARTS    ;Itemdrop type or item override
                dc.b $0b                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_ALL                     ;Attack directions
                dc.b 4*8                        ;Horiz max movement speed
                dc.b 2                          ;Horiz acceleration
                dc.b 2*8                        ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 0                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alFlyingCraft:  dc.w MoveFlyingCraft            ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 11                         ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 7                          ;Size down
                dc.w DestroyFlyingCraft         ;Destroy routine
                dc.b HP_FLYINGCRAFT             ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 65                         ;Score from kill
                dc.b AIMODE_FLYER               ;AI mode when spawned randomly
                dc.b DROP_BATTERY|DROP_PARTS    ;Itemdrop type or item override
                dc.b $0f                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL|AB_DIAGONALDOWN ;Attack directions
                dc.b 5*8                        ;Horiz max movement speed
                dc.b 3                          ;Horiz acceleration
                dc.b 2*8                        ;Vert max movement speed
                dc.b 2                          ;Vert acceleration
                dc.b 1                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alSmallWalker:  dc.w MoveWalker                 ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 12                         ;Horizontal size
                dc.b 21                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy2_8_Ofs10      ;Destroy routine
                dc.b HP_SMALLWALKER             ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 45                         ;Score from kill
                dc.b AIMODE_MOVER               ;AI mode when spawned randomly
                dc.b DROP_BATTERY|DROP_PARTS    ;Itemdrop type or item override
                dc.b $07                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL              ;Attack directions
                dc.b AMF_JUMP                   ;Move flags
                dc.b 3*8                        ;Max. movement speed
                dc.b 6                          ;Ground movement acceleration
                dc.b 2                          ;In air movement acceleration
                dc.b 6                          ;Gravity acceleration
                dc.b 6                          ;Long jump gravity acceleration
                dc.b 8                          ;Ground braking
                dc.b -3                         ;Height in chars for headbump check (negative)
                dc.b -6*8                       ;Jump initial speed (negative)

alSmallTank:    dc.w MoveTank                   ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 12                         ;Horizontal size
                dc.b 22                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy2_8_Ofs10      ;Destroy routine
                dc.b HP_SMALLTANK               ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 75                         ;Score from kill
                dc.b AIMODE_BERZERK             ;AI mode when spawned randomly
                dc.b DROP_BATTERY|DROP_PARTS    ;Itemdrop type or item override
                dc.b $07                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL|AB_DIAGONALUP|AB_UP ;Attack directions
                dc.b AMF_CUSTOMANIMATION ;Move flags
                dc.b 3*8+4                      ;Max. movement speed
                dc.b 4                          ;Ground movement acceleration
                dc.b 0                          ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 8                          ;Long jump gravity acceleration
                dc.b 4                          ;Ground braking
                dc.b -3                         ;Height in chars for headbump check (negative)

alFloatingMine: dc.w MoveFloatingMine           ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 6                          ;Horizontal size
                dc.b 5                          ;Size up
                dc.b 5                          ;Size down
                dc.w ExplodeEnemy               ;Destroy routine
                dc.b HP_FLOATINGMINE            ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 25                         ;Score from kill
                dc.b AIMODE_FLYER               ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $00                        ;AI offense AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_NONE                    ;Attack directions
                dc.b 2*8                        ;Horiz max movement speed
                dc.b 1                          ;Horiz acceleration
                dc.b 1*8+2                      ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 0                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alRollingMine:  dc.w MoveRollingMine            ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 15                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy_Ofs8          ;Destroy routine
                dc.b HP_ROLLINGMINE             ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 50                         ;Score from kill
                dc.b AIMODE_BERZERK             ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $08                        ;AI offense AND-value
                dc.b $05                        ;AI defense probability
                dc.b AB_HORIZONTAL              ;Attack directions
                dc.b AMF_JUMP|AMF_CUSTOMANIMATION ;Move flags
                dc.b 4*8-4                      ;Max. movement speed
                dc.b 3                          ;Ground movement acceleration
                dc.b 3                          ;In air movement acceleration
                dc.b 6                          ;Gravity acceleration
                dc.b 6                          ;Long jump gravity acceleration
                dc.b 0                          ;Ground braking
                dc.b -2                         ;Height in chars for headbump check (negative)
                dc.b -5*8                       ;Jump initial speed (negative)

alCeilingTurret:dc.w MoveTurret                 ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 1                          ;Size up
                dc.b 13                         ;Size down
                dc.w ExplodeEnemy2_8_Ofs6       ;Destroy routine
                dc.b HP_CEILINGTURRET           ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 150                        ;Score from kill
                dc.b AIMODE_FLYER               ;AI mode when spawned randomly
                dc.b DROP_BATTERY|DROP_PARTS    ;Itemdrop type or item override
                dc.b $17                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL|AB_DIAGONALDOWN|AB_DOWN ;Attack directions

alFire:         dc.w MoveFire                   ;Update routine
                dc.b GRP_ENEMIES|AF_INITONLYSIZE|AF_NOWEAPON ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 20                         ;Size up
                dc.b 1                          ;Size down
                dc.w DestroyFire                ;Destroy routine
                dc.b 0                          ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 150                        ;Score from kill

alSmokeCloud:   dc.w MoveSmokeCloud              ;Update routine
                dc.b GRP_ENEMIES|AF_INITONLYSIZE ;Actor flags
                dc.b 10                         ;Horizontal size
                dc.b 6                          ;Size up
                dc.b 0                          ;Size down

alRat:          dc.w MoveRat                    ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON|AF_ORGANIC    ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 2                          ;Size down
                dc.w RatDeath                   ;Destroy routine
                dc.b HP_RAT                     ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 10                         ;Score from kill
                dc.b AIMODE_ANIMAL              ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $07                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL              ;Attack directions
                dc.b AMF_JUMP                   ;Move flags
                dc.b 3*8                        ;Max. movement speed
                dc.b 8                          ;Ground movement acceleration
                dc.b 1                          ;In air movement acceleration
                dc.b 6                          ;Gravity acceleration
                dc.b 6                          ;Long jump gravity acceleration
                dc.b 3                          ;Ground braking
                dc.b -1                         ;Height in chars for headbump check (negative)
                dc.b -4*8                       ;Jump initial speed (negative)

alSpider:       dc.w USESCRIPT|EP_MOVESPIDER    ;Update routine
                dc.b GRP_ANIMALS|AF_NOWEAPON|AF_ORGANIC    ;Actor flags
                dc.b 10                         ;Horizontal size
                dc.b 10                         ;Size up
                dc.b 0                          ;Size down
                dc.w SpiderDeath                ;Destroy routine
                dc.b HP_SPIDER                  ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 20                         ;Score from kill
                dc.b AIMODE_FREEMOVE            ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $00                        ;AI offense AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_NONE                    ;Attack directions
                dc.b AMF_CUSTOMANIMATION        ;Move flags
                dc.b 2*8                        ;Max. movement speed
                dc.b 8                          ;Ground movement acceleration
                dc.b 0                          ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 8                          ;Long jump gravity acceleration
                dc.b 8                          ;Ground braking
                dc.b -2                         ;Height in chars for headbump check (negative)

alFly:          dc.w MoveFly                    ;Update routine
                dc.b GRP_ANIMALS|AF_NOWEAPON|AF_ORGANIC    ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 5                          ;Size up
                dc.b 3                          ;Size down
                dc.w FlyDeath                   ;Destroy routine
                dc.b HP_FLY                     ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 25                         ;Score from kill
                dc.b AIMODE_IDLE                ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $00                        ;AI offense AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_NONE                    ;Attack directions
                dc.b 4*8                        ;Horiz max movement speed
                dc.b 8                          ;Horiz acceleration
                dc.b 2*8                        ;Vert max movement speed
                dc.b 8                          ;Vert acceleration
                dc.b 1                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alBat:          dc.w USESCRIPT|EP_MOVEBAT       ;Update routine
                dc.b GRP_ANIMALS|AF_NOWEAPON|AF_ORGANIC    ;Actor flags
                dc.b 7                          ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 2                          ;Size down
                dc.w BatDeath                   ;Destroy routine
                dc.b HP_BAT                     ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 15                         ;Score from kill
                dc.b AIMODE_FLYERFREEMOVE       ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $00                        ;AI offense AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_NONE                    ;Attack directions
                dc.b 3*8+2                      ;Horiz max movement speed
                dc.b 6                          ;Horiz acceleration
                dc.b 3*8                        ;Vert max movement speed
                dc.b 3                          ;Vert acceleration
                dc.b 0                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alFish:         dc.w MoveFish                   ;Update routine
                dc.b GRP_ANIMALS|AF_NOWEAPON|AF_ORGANIC    ;Actor flags
                dc.b 2                          ;Horizontal size
                dc.b 2                          ;Size up
                dc.b 3                          ;Size down
                dc.w RemoveActor                ;Destroy routine
                dc.b 0                          ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 0                          ;Score from kill
                dc.b AIMODE_FISH                ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $1f                        ;AI offense AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_HORIZONTAL              ;Attack directions
                dc.b 2*8-1                      ;Horiz max movement speed
                dc.b 2                          ;Horiz acceleration
                dc.b 6                          ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 1                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alRock:         dc.w MoveRock                   ;Update routine
                dc.b GRP_ANIMALS                ;Actor flags
                dc.b 10                         ;Horizontal size
                dc.b 20                         ;Size up
                dc.b 0                          ;Size down
                dc.w DestroyRock                ;Destroy routin
                dc.b HP_ROCK                    ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 20                         ;Score from kill
                dc.b AIMODE_IDLE                ;AI mode when spawned randomly

alFireball:     dc.w USESCRIPT|EP_MOVEFIREBALL  ;Update routine
                dc.b GRP_ANIMALS                ;Actor flags
                dc.b 6                          ;Horizontal size
                dc.b 6                          ;Size up
                dc.b 6                          ;Size down
                dc.w RemoveActor                ;Destroy routine
                dc.b 0                          ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 0                          ;Score from kill
                dc.b AIMODE_IDLE                ;AI mode when spawned randomly

alSteam:        dc.w MoveSteam                  ;Update routine
                dc.b GRP_ANIMALS                ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 0                          ;Size down
                dc.w RemoveActor                ;Destroy routine
                dc.b 0                          ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 0                          ;Score from kill

alOrganicWalker:dc.w MoveOrganicWalker          ;Update routine
                dc.b GRP_ANIMALS|AF_NOWEAPON|AF_ORGANIC ;Actor flags
                dc.b 12                         ;Horizontal size
                dc.b 21                         ;Size up
                dc.b 0                          ;Size down
                dc.w OrganicWalkerDeath         ;Destroy routine
                dc.b HP_ORGANICWALKER           ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 75                         ;Score from kill
                dc.b AIMODE_BERZERK             ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $07                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL|AB_DIAGONALUP|AB_DIAGONALDOWN ;Attack directions
                dc.b AMF_JUMP                   ;Move flags
                dc.b 4*8-4                      ;Max. movement speed
                dc.b 8                          ;Ground movement acceleration
                dc.b 2                          ;In air movement acceleration
                dc.b 6                          ;Gravity acceleration
                dc.b 6                          ;Long jump gravity acceleration
                dc.b 8                          ;Ground braking
                dc.b -3                         ;Height in chars for headbump check (negative)
                dc.b -6*8                       ;Jump initial speed (negative)

alGuard:        dc.w MoveAndAttackHuman         ;Update routine
                dc.b GRP_ENEMIES|AF_ORGANIC     ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 35                         ;Size up
                dc.b 0                          ;Size down
                dc.w HumanDeath                 ;Destroy routine
                dc.b HP_GUARD                   ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 85                         ;Score from kill
                dc.b AIMODE_GUARD               ;AI mode when spawned randomly
                dc.b DROP_WEAPON|DROP_MEDKIT|DROP_ARMOR ;Itemdrop type or item override
                dc.b $17                        ;AI offense random AND-value
                dc.b $38                        ;AI defense probability
                dc.b AB_ALL                     ;Attack directions
                dc.b AMF_CLIMB|AMF_FALLDAMAGE|AMF_DUCK ;Move flags
                dc.b 3*8+2                      ;Max. movement speed
                dc.b INITIAL_GROUNDACC          ;Ground movement acceleration
                dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
                dc.b INITIAL_GROUNDBRAKE         ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)
                dc.b -INITIAL_JUMPSPEED         ;Jump initial speed (negative)
                dc.b INITIAL_CLIMBSPEED         ;Climbing speed

alHeavyGuard:   dc.w MoveAndAttackHuman         ;Update routine
                dc.b GRP_ENEMIES|AF_ORGANIC     ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 35                         ;Size up
                dc.b 0                          ;Size down
                dc.w HumanDeath                 ;Destroy routine
                dc.b HP_HEAVYGUARD              ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 100                        ;Score from kill
                dc.b AIMODE_MOVER               ;AI mode when spawned randomly
                dc.b DROP_WEAPON|DROP_MEDKIT|DROP_BATTERY|DROP_ARMOR ;Itemdrop type or item override
                dc.b $17                        ;AI offense random AND-value
                dc.b $20                        ;AI defense probability
                dc.b AB_ALL                     ;Attack directions
                dc.b AMF_JUMP|AMF_CLIMB|AMF_FALLDAMAGE|AMF_DUCK ;Move flags
                dc.b 3*8+2                      ;Max. movement speed
                dc.b INITIAL_GROUNDACC-2        ;Ground movement acceleration
                dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
                dc.b INITIAL_GROUNDBRAKE        ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)
                dc.b -INITIAL_JUMPSPEED         ;Jump initial speed (negative)
                dc.b INITIAL_CLIMBSPEED-2       ;Climbing speed

alLightGuard:   dc.w MoveAndAttackHuman         ;Update routine
                dc.b GRP_ENEMIES|AF_ORGANIC     ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 35                         ;Size up
                dc.b 0                          ;Size down
                dc.w HumanDeath                 ;Destroy routine
                dc.b HP_LIGHTGUARD              ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 75                         ;Score from kill
                dc.b AIMODE_GUARD               ;AI mode when spawned randomly
                dc.b DROP_WEAPON|DROP_MEDKIT    ;Itemdrop type or item override
                dc.b $13                        ;AI offense random AND-value
                dc.b $40                        ;AI defense probability
                dc.b AB_ALL                     ;Attack directions
                dc.b AMF_FALLDAMAGE|AMF_DUCK    ;Move flags
                dc.b 3*8+4                      ;Max. movement speed
                dc.b INITIAL_GROUNDACC          ;Ground movement acceleration
                dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
                dc.b INITIAL_GROUNDBRAKE         ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)

alCombatRobot:  dc.w MoveAndAttackHuman         ;Update routine
                dc.b GRP_ENEMIES                ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 36                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy3_Ofs24        ;Destroy routine
                dc.b HP_COMBATROBOT             ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 65                         ;Score from kill
                dc.b AIMODE_MOVER               ;AI mode when spawned randomly
                dc.b DROP_WEAPON|DROP_BATTERY   ;Itemdrop type or item override
                dc.b $0f                        ;AI offense random AND-value
                dc.b $18                        ;AI defense probability
                dc.b AB_ALL                     ;Attack directions
                dc.b AMF_JUMP|AMF_CLIMB|AMF_FALLDAMAGE|AMF_DUCK ;Move flags
                dc.b 3*8                        ;Max. movement speed
                dc.b INITIAL_GROUNDACC          ;Ground movement acceleration
                dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
                dc.b INITIAL_GROUNDBRAKE        ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)
                dc.b -INITIAL_JUMPSPEED         ;Jump initial speed (negative)
                dc.b INITIAL_CLIMBSPEED+2       ;Climbing speed

alCombatRobotFast:
                dc.w MoveAndAttackHuman         ;Update routine
                dc.b GRP_ENEMIES                ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 36                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy3_Ofs24        ;Destroy routine
                dc.b HP_COMBATROBOT             ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 125                        ;Score from kill
                dc.b AIMODE_BERZERK             ;AI mode when spawned randomly
                dc.b DROP_WEAPON|DROP_BATTERY   ;Itemdrop type or item override
                dc.b $13                        ;AI offense random AND-value
                dc.b $20                        ;AI defense probability
                dc.b AB_ALL                     ;Attack directions
                dc.b AMF_JUMP|AMF_CLIMB|AMF_FALLDAMAGE|AMF_DUCK ;Move flags
                dc.b 4*8+2                      ;Max. movement speed
                dc.b INITIAL_GROUNDACC          ;Ground movement acceleration
                dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
                dc.b INITIAL_GROUNDBRAKE        ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)
                dc.b -INITIAL_JUMPSPEED-8       ;Jump initial speed (negative)
                dc.b INITIAL_CLIMBSPEED+4       ;Climbing speed

alLargeWalker:  dc.w MoveLargeWalker            ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 24                         ;Horizontal size
                dc.b 42                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy4_Ofs15        ;Destroy routine
                dc.b HP_LARGEWALKER             ;Initial health
                dc.b MOD_HEAVYROBOT             ;Damage modifier
                dc.w 250                        ;Score from kill
                dc.b AIMODE_MOVER               ;AI mode when spawned randomly
                dc.b DROP_BATTERY|DROP_PARTS    ;Itemdrop type or item override
                dc.b $13                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL              ;Attack directions
                dc.b AMF_CUSTOMANIMATION        ;Move flags
                dc.b 2*8                        ;Max. movement speed
                dc.b 8                          ;Ground movement acceleration
                dc.b 2                          ;In air movement acceleration
                dc.b 6                          ;Gravity acceleration
                dc.b 6                          ;Long jump gravity acceleration
                dc.b 8                          ;Ground braking
                dc.b -5                         ;Height in chars for headbump check (negative)

alScrapMetal:   dc.w MoveScrapMetal             ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags

alRockTrap:     dc.w MoveRockTrap               ;Update routine
                dc.b GRP_ANIMALS                ;Actor flags
                dc.b 0                          ;Horizontal size
                dc.b 0                          ;Size up
                dc.b 0                          ;Size down
                dc.w RemoveActor                ;Destroy routine
                dc.b 0                          ;Initial health

alCpu:          dc.w FlashActor_CheckDamageFlash ;Update routine
                dc.b GRP_ENEMIES                ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 8                          ;Size down
                dc.w DestroyCPU                 ;Destroy routine
                dc.b HP_CPU                     ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 500                        ;Score from kill

alSuperCpu:     dc.w FlashActor_CheckDamageFlash ;Update routine
                dc.b GRP_ENEMIES|AF_ORGANIC     ;Actor flags (hack: protect against easy victory with EMP)
                dc.b 8                          ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 8                          ;Size down
                dc.w DestroyCPU                 ;Destroy routine
                dc.b HP_SUPERCPU                ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 500                        ;Score from kill

alEyeInvisible: dc.w USESCRIPT|EP_MOVEEYESTAGE1 ;Update routine
                dc.b GRP_ENEMIES|AF_NOREMOVECHECK|AF_ORGANIC ;Actor flags
                dc.b 0                          ;Horizontal size
                dc.b 0                          ;Size up
                dc.b 0                          ;Size down
                dc.w RemoveActor                ;Destroy routine
                dc.b 0                          ;Initial health

alEye:          dc.w USESCRIPT|EP_MOVEEYESTAGE2 ;Update routine
                dc.b GRP_ENEMIES|AF_NOREMOVECHECK|AF_NOWEAPON ;Actor flags
                dc.b 12                         ;Horizontal size
                dc.b 0                          ;Size up
                dc.b 0                          ;Size down
                dc.w USESCRIPT|EP_DESTROYEYE    ;Destroy routine
                dc.b HP_EYE                     ;Initial health
                dc.b MOD_BOSS                   ;Damage modifier
                dc.w 2500                       ;Score from kill

alJormungandr:  dc.w USESCRIPT|EP_MOVEJORMUNGANDR ;Update routine
                dc.b GRP_ENEMIES|AF_NOREMOVECHECK|AF_NOWEAPON|AF_ORGANIC ;Actor flags
                dc.b 56                         ;Horizontal size
                dc.b 30                         ;Size up
                dc.b 35                         ;Size down
                dc.w DoNothing                  ;Destroy routine
                dc.b 0                          ;Initial health
                dc.b MOD_BOSS                   ;Damage modifier
                dc.w 2500                       ;Score from kill

alLargeTank:    dc.w USESCRIPT|EP_MOVELARGETANK ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 24                         ;Horizontal size
                dc.b 41                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy4_Ofs15        ;Destroy routine
                dc.b HP_LARGETANK               ;Initial health
                dc.b MOD_HEAVYROBOT             ;Damage modifier
                dc.w 300                        ;Score from kill
                dc.b AIMODE_BERZERK             ;AI mode when spawned randomly
                dc.b DROP_BATTERY|DROP_PARTS    ;Itemdrop type or item override
                dc.b $0f                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL              ;Attack directions
                dc.b AMF_CUSTOMANIMATION ;Move flags
                dc.b 3*8                        ;Max. movement speed
                dc.b 3                          ;Ground movement acceleration
                dc.b 0                          ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 8                          ;Long jump gravity acceleration
                dc.b 3                          ;Ground braking
                dc.b -5                         ;Height in chars for headbump check (negative)

alHighWalker:   dc.w MoveHighWalker             ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 12                         ;Horizontal size
                dc.b 59                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy4_Rising       ;Destroy routine
                dc.b HP_HIGHWALKER              ;Initial health
                dc.b MOD_HEAVYROBOT             ;Damage modifier
                dc.w 175                        ;Score from kill
                dc.b AIMODE_BERZERK             ;AI mode when spawned randomly
                dc.b DROP_BATTERY|DROP_PARTS    ;Itemdrop type or item override
                dc.b $1f                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL              ;Attack directions
                dc.b AMF_CUSTOMANIMATION        ;Move flags
                dc.b 1*8+4                      ;Max. movement speed
                dc.b 4                          ;Ground movement acceleration
                dc.b 2                          ;In air movement acceleration
                dc.b 6                          ;Gravity acceleration
                dc.b 6                          ;Long jump gravity acceleration
                dc.b 4                          ;Ground braking
                dc.b -7                         ;Height in chars for headbump check (negative)

alExplosionGeneratorRising:
                dc.w MoveExplosionGeneratorRising ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags

alSecurityChief:dc.w USESCRIPT|EP_MOVESECURITYCHIEF ;Update routine
                dc.b GRP_ENEMIES|AF_ORGANIC|AF_NOREMOVECHECK ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 35                         ;Size up
                dc.b 0                          ;Size down
                dc.w USESCRIPT|EP_DESTROYSECURITYCHIEF ;Destroy routine
                dc.b HP_SECURITYCHIEF           ;Initial health
                dc.b MOD_BOSS                   ;Damage modifier
                dc.w 2000                       ;Score from kill
                dc.b AIMODE_BERZERK             ;AI mode when spawned randomly
                dc.b ITEM_VAULTPASS             ;Itemdrop type or item override
                dc.b $17                        ;AI offense random AND-value
                dc.b $20                        ;AI defense probability
                dc.b AB_ALL                     ;Attack directions
                dc.b AMF_DUCK                   ;Move flags
                dc.b 4*8+4                      ;Max. movement speed
                dc.b INITIAL_GROUNDACC-2        ;Ground movement acceleration
                dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 6                          ;Gravity acceleration
                dc.b 6                          ;Long jump gravity acceleration
                dc.b INITIAL_GROUNDBRAKE        ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)
                ;dc.b -INITIAL_JUMPSPEED-2       ;Jump initial speed (negative)

alRotorDrone:   dc.w USESCRIPT|EP_MOVEROTORDRONE ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON|AF_NOREMOVECHECK ;Actor flags
                dc.b 20                         ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 5                          ;Size down
                dc.w USESCRIPT|EP_DESTROYROTORDRONE ;Destroy routine
                dc.b HP_ROTORDRONE              ;Initial health
                dc.b MOD_BOSS                   ;Damage modifier
                dc.w 1000                       ;Score from kill
                dc.b AIMODE_FLYER               ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $1f                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL|AB_DIAGONALDOWN|AB_DOWN ;Attack directions
                dc.b 3*8                        ;Horiz max movement speed
                dc.b 1                          ;Horiz acceleration
                dc.b 1*8+2                      ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 2                          ;Horiz obstacle check offset
                dc.b 2                          ;Vert obstacle check offset

alLargeSpider:  dc.w USESCRIPT|EP_MOVELARGESPIDER ;Update routine
                dc.b GRP_ANIMALS|AF_NOWEAPON|AF_ORGANIC|AF_NOREMOVECHECK    ;Actor flags
                dc.b 28                         ;Horizontal size
                dc.b 26                         ;Size up
                dc.b 0                          ;Size down
                dc.w DoNothing                  ;Destroy routine
                dc.b HP_LARGESPIDER             ;Initial health
                dc.b MOD_BOSS                   ;Damage modifier
                dc.w 1500                       ;Score from kill
                dc.b AIMODE_IDLE                ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $00                        ;AI offense AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_NONE                    ;Attack directions
                dc.b AMF_CUSTOMANIMATION        ;Move flags
                dc.b 2*8                        ;Max. movement speed
                dc.b 8                          ;Ground movement acceleration
                dc.b 0                          ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 8                          ;Long jump gravity acceleration
                dc.b 8                          ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)

alAcid:         dc.w USESCRIPT|EP_MOVEACID      ;Update routine
                dc.b AF_ORGANIC|AF_NOREMOVECHECK|AF_INITONLYSIZE ;Actor flags
                dc.b 4                          ;Horizontal size
                dc.b 7                          ;Size up
                dc.b 0                          ;Size down

alArmorer:      dc.w MoveAndAttackHuman         ;Update routine
                dc.b GRP_ENEMIES|AF_ORGANIC     ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 35                         ;Size up
                dc.b 0                          ;Size down
                dc.w HumanDeath                 ;Destroy routine
                dc.b HP_ARMORER                 ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 250                        ;Score from kill
                dc.b AIMODE_MOVER               ;AI mode when spawned randomly
                dc.b DROP_WEAPON                ;Itemdrop type or item override
                dc.b $1f                        ;AI offense random AND-value
                dc.b $50                        ;AI defense probability
                dc.b AB_ALL                     ;Attack directions
                dc.b AMF_FALLDAMAGE|AMF_DUCK ;Move flags
                dc.b 3*8                        ;Max. movement speed
                dc.b INITIAL_GROUNDACC          ;Ground movement acceleration
                dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
                dc.b INITIAL_GROUNDBRAKE        ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)

alGenerator:    dc.w MoveGenerator              ;Update routine
                dc.b AF_NOREMOVECHECK           ;Actor flags
                dc.b 0                          ;Horizontal size
                dc.b 0                          ;Size up
                dc.b 0                          ;Size down
                dc.w RemoveActor                ;Destroy routine
                dc.b 0                          ;Initial health

alDoNothing:    dc.w DoNothing                  ;Update routine
                dc.b AF_INITONLYSIZE|AF_NOREMOVECHECK            ;Actor flags
                
alMediumWalker: dc.w MoveWalker                 ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 12                         ;Horizontal size
                dc.b 21                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy2_8_Ofs10      ;Destroy routine
                dc.b HP_MEDIUMWALKER            ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 85                         ;Score from kill
                dc.b AIMODE_BERZERK             ;AI mode when spawned randomly
                dc.b DROP_BATTERY|DROP_PARTS    ;Itemdrop type or item override
                dc.b $07                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL              ;Attack directions
                dc.b AMF_JUMP                   ;Move flags
                dc.b 3*8+4                      ;Max. movement speed
                dc.b 6                          ;Ground movement acceleration
                dc.b 2                          ;In air movement acceleration
                dc.b 6                          ;Gravity acceleration
                dc.b 6                          ;Long jump gravity acceleration
                dc.b 8                          ;Ground braking
                dc.b -3                         ;Height in chars for headbump check (negative)
                dc.b -6*8                       ;Jump initial speed (negative)

alScientist1:   dc.w USESCRIPT|EP_SCIENTIST1    ;Update routine
                dc.b GRP_HEROES|AF_ORGANIC      ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 35                         ;Size up
                dc.b 0                          ;Size down
                dc.w HumanDeath                 ;Destroy routine
                dc.b HP_SCIENTIST1              ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 0                          ;Score from kill
                dc.b AIMODE_IDLE                ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $00                        ;AI offense random AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_NONE                    ;Attack directions
                dc.b AMF_DUCK                   ;Move flags
                dc.b 3*8                        ;Max. movement speed
                dc.b INITIAL_GROUNDACC          ;Ground movement acceleration
                dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
                dc.b INITIAL_GROUNDBRAKE        ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)

alScientist23:  dc.w MovePersistentNPC          ;Update routine
                dc.b GRP_HEROES|AF_ORGANIC      ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 35                         ;Size up
                dc.b 0                          ;Size down
                dc.w HumanDeath                 ;Destroy routine
                dc.b HP_NONCOMBATANT            ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 0                          ;Score from kill
                dc.b AIMODE_IDLE                ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $3f                        ;AI offense random AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_NONE                    ;Attack directions
                dc.b AMF_DUCK                   ;Move flags
                dc.b 4*8                        ;Max. movement speed
                dc.b INITIAL_GROUNDACC          ;Ground movement acceleration
                dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
                dc.b INITIAL_GROUNDBRAKE        ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)

alHacker:       dc.w MovePersistentNPC          ;Update routine
                dc.b GRP_HEROES|AF_ORGANIC      ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 35                         ;Size up
                dc.b 0                          ;Size down
                dc.w HumanDeath                 ;Destroy routine
                dc.b HP_NONCOMBATANT            ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 0                          ;Score from kill
                dc.b AIMODE_IDLE                ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
                dc.b $3f                        ;AI offense random AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_NONE                    ;Attack directions
                dc.b AMF_DUCK|AMF_CLIMB|AMF_JUMP         ;Move flags
                dc.b 4*8                        ;Max. movement speed
                dc.b INITIAL_GROUNDACC          ;Ground movement acceleration
                dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
                dc.b INITIAL_GROUNDBRAKE         ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)
                dc.b -INITIAL_JUMPSPEED         ;Jump initial speed (negative)
                dc.b INITIAL_CLIMBSPEED         ;Climbing speed

alCombatRobotSaboteur:
                dc.w USESCRIPT|EP_COMBATROBOTSABOTEUR ;Update routine
                dc.b GRP_ENEMIES                ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 36                         ;Size up
                dc.b 0                          ;Size down
                dc.w USESCRIPT|EP_DESTROYCOMBATROBOTSABOTEUR ;Destroy routine
                dc.b HP_COMBATROBOT             ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 500                        ;Score from kill
                dc.b AIMODE_IDLE                ;AI mode when spawned randomly
                dc.b DROP_NOTHING               ;Itemdrop type or item override
