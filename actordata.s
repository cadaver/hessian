ACT_NONE        = 0
ACT_PLAYER      = 1
ACT_ITEM        = 2
ACT_MELEEHIT    = 3
ACT_LARGEMELEEHIT = 4
ACT_POWDER      = 5
ACT_BULLET      = 6
ACT_SHOTGUNBULLET = 7
ACT_RIFLEBULLET = 8
ACT_FLAME       = 9
ACT_EMP         = 10
ACT_LASER       = 11
ACT_PLASMA      = 12
ACT_LAUNCHERGRENADE = 13
ACT_GRENADE     = 14
ACT_ROCKET      = 15
ACT_MINE        = 16
ACT_EXPLOSION   = 17
ACT_SMOKETRAIL  = 18
ACT_WATERSPLASH = 19
ACT_SMALLSPLASH = 20
ACT_OBJECTMARKER = 21
ACT_SPEECHBUBBLE = 22
ACT_EXPLOSIONGENERATOR = 23
ACT_SMALLDROID  = 24
ACT_LARGEDROID  = 25
ACT_LARGEDROIDSUPER = 26
ACT_FLYINGCRAFT = 27
ACT_SMALLWALKER = 28
ACT_SMALLTANK   = 29
ACT_FLOATINGMINE = 30
ACT_ROLLINGMINE = 31
ACT_CEILINGTURRET = 32
ACT_FIRE        = 33
ACT_SMOKECLOUD  = 34
ACT_RAT         = 35
ACT_SPIDER      = 36
ACT_FLY         = 37
ACT_BAT         = 38
ACT_FISH        = 39
ACT_ROCK        = 40
ACT_FIREBALL    = 41

HP_PLAYER       = 56
HP_RAT          = 4
HP_FLY          = 4
HP_BAT          = 4
HP_SPIDER       = 6
HP_FLOATINGMINE = 7
HP_ROLLINGMINE  = 7
HP_SMALLDROID   = 8
HP_ROCK         = 10
HP_FLYINGCRAFT  = 13
HP_LARGEDROID   = 14
HP_SMALLWALKER  = 16
HP_SMALLTANK    = 18
HP_LARGEDROIDSUPER = 20
HP_CEILINGTURRET = 24

        ; Difficulty mod for damage on player

plrDmgModifyTbl:dc.b 6,8,12

        ; Human Y-size reduce table based on animation

humanSizeReduceTbl:
                dc.b 1,2,1,0,1,2,1,0,1,2,2,1,6,12,1,0,1,0,1,0,0,0,18,18,18,18,18,18,19,19,19,19

        ; Human actor upper part framenumbers

humanUpperFrTbl:dc.b 1,0,0,1,1,2,2,1,1,2,1,0,0,0,15,13,12,13,14,3,10,11,16,17,18,19,20,21,22,23,24,23,3,4,5,6,7,8,9
                dc.b $80+1,$80+0,$80+0,$80+1,$80+1,$80+2,$80+2,$80+1,$80+1,$80+2,$80+1,$80+0,$80+0,$80+0,15,13,12,13,14,$80+3,$80+10,$80+11,$80+16,$80+17,$80+18,$80+19,$80+20,$80+21,$80+22,$80+23,$80+24,$80+23,$80+3,$80+4,$80+5,$80+6,$80+7,$80+8,$80+9
        ; Tank turret
                dc.b 0,1,2
                dc.b $80+0,$80+1,$80+2

        ; Human actor lower part framenumbers

humanLowerFrTbl:dc.b $80+0,$80+1,$80+2,$80+3,$80+4,$80+1,$80+2,$80+3,$80+4,$80+5,$80+6,$80+7,$80+8,$80+9,14,14,13,14,15,$80+10,$80+11,$80+12,$80+16,$80+17,$80+18,$80+19,$80+20,$80+21,$80+22,$80+23,$80+24,$80+23
                dc.b 0,1,2,3,4,1,2,3,4,5,6,7,8,9,14,14,13,14,15,10,11,12,16,17,18,19,20,21,22,23,24,23
        ; Tank tracks
                dc.b 2,1,0
                dc.b $80+2,$80+1,$80+0

        ; Actor display data

adMeleeHit      = $0000                         ;Invisible
adLargeMeleeHit = $0000
adExplosionGenerator = $0000

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
                dc.b <adLargeDroid
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
                dc.b >adLargeDroid
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
                dc.b 19                         ;Number of frames
itemFrames:     dc.b 0,0,1,2,3,4,5,6,7,8,9,10   ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 11,12,13,14,22,15,16,17,18
                dc.b 19,23,20,20,20,20,20,20,20,20,20,21

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
                dc.b 10                         ;Number of frames
                dc.b 41,42,43,$80+42,41         ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 41,$80+42,43,42,41

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
                dc.b C_DROID                    ;Spritefile number
                dc.b 0                          ;Base spritenumber

adLargeDroid:   dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_DROID                    ;Spritefile number
                dc.b 3                          ;Base spritenumber

adFlyingCraft:  dc.b ONESPRITE                  ;Number of sprites
                dc.b C_FLYER                    ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 5                          ;Number of frames
                dc.b $80+0,$80+1,2,1,0

adSmallWalker:  dc.b ONESPRITE                  ;Number of sprites
                dc.b C_SMALLWALKER              ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 12                         ;Number of frames
                dc.b 1,0,1,2,1,0,1,2,1,3,3,1

adSmallTank:    dc.b HUMANOID                   ;Number of sprites
                dc.b C_SMALLTANK                ;Lower part spritefile number
                dc.b 0                          ;Lower part base spritenumber
                dc.b 64                         ;Lower part base index into the frametable
                dc.b 3                          ;Lower part left frame add
                dc.b C_SMALLTANK                ;Upper part spritefile number
                dc.b 3                          ;Upper part base spritenumber
                dc.b 78                         ;Upper part base index into the frametable
                dc.b 3                          ;Upper part left frame add

adFloatingMine: dc.b ONESPRITE                  ;Number of sprites
                dc.b C_MINE                     ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 4                          ;Number of frames
                dc.b 0,1,2,1

adRollingMine:  dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_MINE                     ;Spritefile number
                dc.b 3                          ;Base spritenumber

adCeilingTurret:dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_TURRET                   ;Spritefile number
                dc.b 0                          ;Base spritenumber

adFire:         dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_FIRE                     ;Spritefile number
                dc.b 0                          ;Base spritenumber

adSmokeCloud:   dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_FIRE                     ;Spritefile number
                dc.b 4                          ;Base spritenumber

adRat:          dc.b ONESPRITE                  ;Number of sprites
                dc.b C_RAT                      ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 14                         ;Number of frames
                dc.b 1,0,1,2,1,0,1,2,1,3,3,3,4,5

adSpider:       dc.b ONESPRITE                  ;Number of sprites
                dc.b C_SPIDER                   ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 5                          ;Number of frames
                dc.b 0,1,2,3,4

adFly:          dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_TURRET                   ;Spritefile number
                dc.b 5                          ;Base spritenumber

adBat:          dc.b ONESPRITE                  ;Number of sprites
                dc.b C_RAT                      ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 7                          ;Number of frames
                dc.b 6,7,8,9,8,7,10

adFish:         dc.b ONESPRITE                  ;Number of sprites
                dc.b C_SPIDER                   ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 4                          ;Number of frames
                dc.b 5,6

adRock:         dc.b ONESPRITEDIRECT            ;Number of sprites
                dc.b C_ROCK                     ;Spritefile number
                dc.b 0                          ;Base spritenumber

adFireball:     dc.b ONESPRITE                  ;Number of sprites
                dc.b C_ROCK                     ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 4                          ;Number of frames
                dc.b 3,4,5,4

adSteam:        dc.b ONESPRITE                  ;Number of sprites
                dc.b C_FIRE                     ;Spritefile number
                dc.b LEFTFRAME_FLIP             ;Left frame add
                dc.b 4                          ;Number of frames
                dc.b 8,9,10,11

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
                dc.b <alLargeDroidSuper
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
                dc.b >alLargeDroidSuper
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
                dc.b ITEM_NONE                  ;Itemdrop table index or item override
                dc.b $ff                        ;AI offense random AND-value
                dc.b $ff                        ;AI defense probability
                dc.b $ff                        ;Attack directions
                dc.b AMF_JUMP|AMF_DUCK|AMF_CLIMB|AMF_ROLL|AMF_WALLFLIP ;Move flags
                dc.b 4*8                        ;Max. movement speed
plrGroundAcc:   dc.b INITIAL_GROUNDACC          ;Ground movement acceleration
plrInAirAcc:    dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
plrGroundBrake:dc.b INITIAL_GROUNDBRAKE         ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)
plrJumpSpeed:   dc.b -INITIAL_JUMPSPEED         ;Jump initial speed (negative)
plrClimbSpeed:  dc.b INITIAL_CLIMBSPEED         ;Climbing speed

alItem:         dc.w MoveItem                   ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 10                         ;Horizontal size
                dc.b 7                          ;Size up
                dc.b 0                          ;Size down

alMeleeHit:     dc.w MoveMeleeHit               ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 4                          ;Horizontal size
                dc.b 4                          ;Size up
                dc.b 4                          ;Size down

alLargeMeleeHit:dc.w MoveMeleeHit               ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 7                          ;Horizontal size
                dc.b 4                          ;Size up
                dc.b 4                          ;Size down

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
                dc.b 6                          ;Size up
                dc.b 6                          ;Size down

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

alSmallDroid:   dc.w USESCRIPT|EP_MOVEDROID     ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 6                          ;Horizontal size
                dc.b 6                          ;Size up
                dc.b 6                          ;Size down
                dc.w ExplodeEnemy               ;Destroy routine
                dc.b HP_SMALLDROID              ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 25                         ;Score from kill
                dc.b AIMODE_FLYER               ;AI mode when spawned randomly
                dc.b DROP_WEAPONBATTERYPARTS    ;Itemdrop table index or item override
                dc.b $05                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_ALL                     ;Attack directions
                dc.b 4*8                        ;Horiz max movement speed
                dc.b 3                          ;Horiz acceleration
                dc.b 2*8                        ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 0                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alLargeDroid:   dc.w USESCRIPT|EP_MOVEDROID     ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 9                          ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 8                          ;Size down
                dc.w ExplodeEnemy2_8            ;Destroy routine
                dc.b HP_LARGEDROID              ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 50                         ;Score from kill
                dc.b AIMODE_FLYER               ;AI mode when spawned randomly
                dc.b DROP_WEAPONBATTERYPARTS    ;Itemdrop table index or item override
                dc.b $05                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_ALL                     ;Attack directions
                dc.b 3*8                        ;Horiz max movement speed
                dc.b 2                          ;Horiz acceleration
                dc.b 3*4                        ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 0                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alLargeDroidSuper:
                dc.w USESCRIPT|EP_MOVEDROID     ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 9                          ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 8                          ;Size down
                dc.w ExplodeEnemy2_8            ;Destroy routine
                dc.b HP_LARGEDROIDSUPER         ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 75                         ;Score from kill
                dc.b AIMODE_FLYER               ;AI mode when spawned randomly
                dc.b DROP_WEAPON                ;Itemdrop table index or item override
                dc.b $05                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_ALL                     ;Attack directions
                dc.b 4*8                        ;Horiz max movement speed
                dc.b 3                          ;Horiz acceleration
                dc.b 2*8                        ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 0                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alFlyingCraft:  dc.w USESCRIPT|EP_MOVEFLYINGCRAFT ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 11                         ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 7                          ;Size down
                dc.w DoNothing                  ;Destroy routine (destroy handled by move routine)
                dc.b HP_FLYINGCRAFT             ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 65                         ;Score from kill
                dc.b AIMODE_FLYER               ;AI mode when spawned randomly
                dc.b DROP_WEAPONBATTERYPARTS    ;Itemdrop table index or item override
                dc.b $06                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL|AB_DIAGONALDOWN ;Attack directions
                dc.b 5*8                        ;Horiz max movement speed
                dc.b 3                          ;Horiz acceleration
                dc.b 2*8                        ;Vert max movement speed
                dc.b 2                          ;Vert acceleration
                dc.b 1                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alSmallWalker:  dc.w USESCRIPT|EP_MOVEWALKER    ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 12                         ;Horizontal size
                dc.b 21                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy2_8_Ofs10      ;Destroy routine
                dc.b HP_SMALLWALKER             ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 45                         ;Score from kill
                dc.b AIMODE_MOVER               ;AI mode when spawned randomly
                dc.b DROP_WEAPONBATTERYPARTS    ;Itemdrop table index or item override
                dc.b $05                        ;AI offense AND-value
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

alSmallTank:    dc.w USESCRIPT|EP_MOVETANK      ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 12                         ;Horizontal size
                dc.b 22                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy2_8_Ofs10      ;Destroy routine
                dc.b HP_SMALLTANK               ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 50                         ;Score from kill
                dc.b AIMODE_BERZERK             ;AI mode when spawned randomly
                dc.b DROP_WEAPONBATTERYPARTS    ;Itemdrop table index or item override
                dc.b $06                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL|AB_DIAGONALUP|AB_UP ;Attack directions
                dc.b AMF_NOFALLDAMAGE|AMF_CUSTOMANIMATION ;Move flags
                dc.b 3*8+4                      ;Max. movement speed
                dc.b 4                          ;Ground movement acceleration
                dc.b 0                          ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 8                          ;Long jump gravity acceleration
                dc.b 4                          ;Ground braking
                dc.b -3                         ;Height in chars for headbump check (negative)

alFloatingMine: dc.w USESCRIPT|EP_MOVEFLOATINGMINE ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 6                          ;Horizontal size
                dc.b 5                          ;Size up
                dc.b 5                          ;Size down
                dc.w ExplodeEnemy               ;Destroy routine
                dc.b HP_FLOATINGMINE            ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 25                         ;Score from kill
                dc.b AIMODE_FLYER               ;AI mode when spawned randomly
                dc.b DROP_WEAPON                ;Itemdrop table index or item override
                dc.b $00                        ;AI offense AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_NONE                    ;Attack directions
                dc.b 2*8                        ;Horiz max movement speed
                dc.b 1                          ;Horiz acceleration
                dc.b 1*8+2                      ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 0                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alRollingMine:  dc.w USESCRIPT|EP_MOVEROLLINGMINE ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 15                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy_Ofs8          ;Destroy routine
                dc.b HP_ROLLINGMINE             ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 30                         ;Score from kill
                dc.b AIMODE_BERZERK             ;AI mode when spawned randomly
                dc.b DROP_WEAPON                ;Itemdrop table index or item override
                dc.b $08                        ;AI offense AND-value
                dc.b $05                        ;AI defense probability
                dc.b AB_HORIZONTAL              ;Attack directions
                dc.b AMF_JUMP|AMF_NOFALLDAMAGE|AMF_CUSTOMANIMATION ;Move flags
                dc.b 4*8-4                      ;Max. movement speed
                dc.b 3                          ;Ground movement acceleration
                dc.b 3                          ;In air movement acceleration
                dc.b 6                          ;Gravity acceleration
                dc.b 6                          ;Long jump gravity acceleration
                dc.b 0                          ;Ground braking
                dc.b -2                         ;Height in chars for headbump check (negative)
                dc.b -5*8                       ;Jump initial speed (negative)

alCeilingTurret:dc.w USESCRIPT|EP_MOVETURRET    ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON    ;Actor flags
                dc.b 6                          ;Horizontal size
                dc.b 0                          ;Size up
                dc.b 12                         ;Size down
                dc.w ExplodeEnemy2_8_OfsD6      ;Destroy routine
                dc.b HP_CEILINGTURRET           ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 150                        ;Score from kill
                dc.b AIMODE_FLYER               ;AI mode when spawned randomly
                dc.b DROP_WEAPONBATTERYPARTS    ;Itemdrop table index or item override
                dc.b $1f                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AB_HORIZONTAL|AB_DIAGONALDOWN|AB_DOWN ;Attack directions

alFire:         dc.w USESCRIPT|EP_MOVEFIRE      ;Update routine
                dc.b GRP_ANIMALS|AF_INITONLYSIZE|AF_NOWEAPON ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 20                         ;Size up
                dc.b 1                          ;Size down
                dc.w DoNothing                  ;Destroy routine (handled by move routine)
                dc.b 0                          ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 100                        ;Score from kill
                dc.b AIMODE_IDLE                ;AI mode when spawned randomly

alSmokeCloud:   dc.w USESCRIPT|EP_MOVESMOKECLOUD ;Update routine
                dc.b GRP_ANIMALS|AF_INITONLYSIZE ;Actor flags
                dc.b 10                         ;Horizontal size
                dc.b 6                          ;Size up
                dc.b 0                          ;Size down

alRat:          dc.w USESCRIPT|EP_MOVERAT       ;Update routine
                dc.b GRP_ANIMALS|AF_NOWEAPON|AF_ORGANIC    ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 2                          ;Size down
                dc.w RatDeath                   ;Destroy routine
                dc.b HP_RAT                     ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 10                         ;Score from kill
                dc.b AIMODE_ANIMAL              ;AI mode when spawned randomly
                dc.b DROP_WEAPON                ;Itemdrop table index or item override
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
                dc.b DROP_WEAPON                ;Itemdrop table index or item override
                dc.b $00                        ;AI offense AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_NONE                    ;Attack directions
                dc.b AMF_NOFALLDAMAGE|AMF_CUSTOMANIMATION ;Move flags
                dc.b 2*8                        ;Max. movement speed
                dc.b 8                          ;Ground movement acceleration
                dc.b 0                          ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 8                          ;Long jump gravity acceleration
                dc.b 8                          ;Ground braking
                dc.b -2                         ;Height in chars for headbump check (negative)

alFly:          dc.w USESCRIPT|EP_MOVEFLY       ;Update routine
                dc.b GRP_ANIMALS|AF_NOWEAPON|AF_ORGANIC    ;Actor flags
                dc.b 10                         ;Horizontal size
                dc.b 5                          ;Size up
                dc.b 3                          ;Size down
                dc.w FlyDeath                   ;Destroy routine
                dc.b HP_FLY                     ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 15                         ;Score from kill
                dc.b AIMODE_IDLE                ;AI mode when spawned randomly
                dc.b DROP_WEAPON                ;Itemdrop table index or item override
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
                dc.b DROP_WEAPON                ;Itemdrop table index or item override
                dc.b $00                        ;AI offense AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_NONE                    ;Attack directions
                dc.b 3*8+2                      ;Horiz max movement speed
                dc.b 6                          ;Horiz acceleration
                dc.b 3*8                        ;Vert max movement speed
                dc.b 3                          ;Vert acceleration
                dc.b 0                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alFish:         dc.w USESCRIPT|EP_MOVEFISH      ;Update routine
                dc.b GRP_ANIMALS|AF_NOWEAPON|AF_ORGANIC    ;Actor flags
                dc.b 2                          ;Horizontal size
                dc.b 1                          ;Size up
                dc.b 3                          ;Size down
                dc.w RemoveActor                ;Destroy routine
                dc.b 0                          ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 0                          ;Score from kill
                dc.b AIMODE_FISH                ;AI mode when spawned randomly
                dc.b DROP_WEAPON                ;Itemdrop table index or item override
                dc.b $1f                        ;AI offense AND-value
                dc.b $00                        ;AI defense probability
                dc.b AB_HORIZONTAL              ;Attack directions
                dc.b 2*8-1                      ;Horiz max movement speed
                dc.b 2                          ;Horiz acceleration
                dc.b 6                          ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 1                          ;Horiz obstacle check offset
                dc.b 1                          ;Vert obstacle check offset

alRock:         dc.w USESCRIPT|EP_MOVEROCK      ;Update routine
                dc.b GRP_ANIMALS                ;Actor flags
                dc.b 10                         ;Horizontal size
                dc.b 20                         ;Size up
                dc.b 0                          ;Size down
                dc.w DoNothing                  ;Destroy routine (destroy handled by move routine)
                dc.b HP_ROCK                    ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 10                         ;Score from kill
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

alSteam:        dc.w USESCRIPT|EP_MOVESTEAM     ;Update routine
                dc.b GRP_ANIMALS                ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 8                          ;Size up
                dc.b 0                          ;Size down
                dc.w RemoveActor                ;Destroy routine
                dc.b 0                          ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 0                          ;Score from kill
                dc.b AIMODE_IDLE                ;AI mode when spawned randomly