ACT_NONE        = 0
ACT_PLAYER      = 1
ACT_ITEM        = 2
ACT_MELEEHIT    = 3
ACT_LARGEMELEEHIT = 4
ACT_BULLET      = 5
ACT_SHOTGUNBULLET = 6
ACT_RIFLEBULLET = 7
ACT_FLAME       = 8
ACT_EMP         = 9
ACT_LASER       = 10
ACT_PLASMA      = 11
ACT_LAUNCHERGRENADE = 12
ACT_GRENADE     = 13
ACT_ROCKET      = 14
ACT_MINE        = 15
ACT_EXPLOSION   = 16
ACT_SMOKETRAIL  = 17
ACT_POWDER      = 18
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

HP_PLAYER       = 56
HP_SMALLDROID   = 8
HP_FLYINGCRAFT  = 13
HP_LARGEDROID   = 14
HP_SMALLWALKER  = 16
HP_LARGEDROIDSUPER = 20

        ; Difficulty mod for damage on player

plrDmgModifyTbl:dc.b 6,8,12

        ; Human Y-size reduce table based on animation

humanSizeReduceTbl:
                dc.b 1,2,1,0,1,2,1,0,1,2,0,1,6,12,1,0,1,0,1,0,0,0,18,18,18,18,18,18,10,10,10,10

        ; Human actor upper part framenumbers

humanUpperFrTbl:dc.b 1,0,0,1,1,2,2,1,1,2,1,0,0,0,15,13,12,13,14,3,10,11,16,17,18,19,20,21,22,23,24,23,3,4,5,6,7,8,9
                dc.b $80+1,$80+0,$80+0,$80+1,$80+1,$80+2,$80+2,$80+1,$80+1,$80+2,$80+1,$80+0,$80+0,$80+0,15,13,12,13,14,$80+3,$80+10,$80+11,$80+16,$80+17,$80+18,$80+19,$80+20,$80+21,$80+22,$80+23,$80+24,$80+23,$80+3,$80+4,$80+5,$80+6,$80+7,$80+8,$80+9

        ; Human actor lower part framenumbers

humanLowerFrTbl:dc.b $80+0,$80+1,$80+2,$80+3,$80+4,$80+1,$80+2,$80+3,$80+4,$80+5,$80+6,$80+7,$80+8,$80+9,14,14,13,14,15,$80+10,$80+11,$80+12,$80+16,$80+17,$80+18,$80+19,$80+20,$80+21,$80+22,$80+23,$80+24,$80+23
                dc.b 0,1,2,3,4,1,2,3,4,5,6,7,8,9,14,14,13,14,15,10,11,12,16,17,18,19,20,21,22,23,24,23

        ; Actor display data

adMeleeHit      = $0000                         ;Invisible
adLargeMeleeHit = $0000
adExplosionGenerator = $0000

actDispTblLo:   dc.b <adPlayer
                dc.b <adItem
                dc.b <adMeleeHit
                dc.b <adLargeMeleeHit
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

actDispTblHi:   dc.b >adPlayer
                dc.b >adItem
                dc.b >adMeleeHit
                dc.b >adLargeMeleeHit
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

adFlame:        dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 4                          ;Number of frames
                dc.b 23,24,25,26                ;Frametable (first all frames of sprite1, then sprite2)

adEMP:          dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 10                         ;Number of frames
                dc.b 37,38,39,40                ;Frametable (first all frames of sprite1, then sprite2)

adLaser:        dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 10                         ;Number of frames
                dc.b 41,42,43,$80+42,41         ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 41,$80+42,43,42,41

adPlasma:       dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 1                          ;Number of frames
                dc.b 44                         ;Frametable (first all frames of sprite1, then sprite2)

adLauncherGrenade:
                dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 3                          ;Number of frames
                dc.b 27,28,29                   ;Frametable (first all frames of sprite1, then sprite2)

adGrenade:      dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 1                          ;Number of frames
                dc.b 13                         ;Frametable (first all frames of sprite1, then sprite2)

adRocket:       dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 10                         ;Number of frames
                dc.b 30,31,32,33,34             ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 30,$80+31,$80+32,$80+33,34

adMine:         dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 2                          ;Number of frames
                dc.b 55,56                      ;Frametable (first all frames of sprite1, then sprite2)

adExplosion:    dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 5                          ;Number of frames
                dc.b 0,1,2,3,4                  ;Frametable (first all frames of sprite1, then sprite2)

adSmokeTrail:   dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 2                          ;Number of frames
                dc.b 35,36                      ;Frametable (first all frames of sprite1, then sprite2)

adWaterSplash:  dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 5                          ;Number of frames
                dc.b 45,46,47,48,49             ;Frametable (first all frames of sprite1, then sprite2)

adSmallSplash:  dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 3                          ;Number of frames
                dc.b 50,51,52                   ;Frametable (first all frames of sprite1, then sprite2)

adObjectMarker: dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 1                          ;Number of frames
                dc.b 53

adSpeechBubble: dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 1                          ;Number of frames
                dc.b 54

adSmallDroid:   dc.b ONESPRITE                  ;Number of sprites
                dc.b C_SMALLROBOT               ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 3                          ;Number of frames
                dc.b 0,1,2

adLargeDroid:   dc.b ONESPRITE                  ;Number of sprites
                dc.b C_SMALLROBOT               ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 3                          ;Number of frames
                dc.b 3,4,5

adFlyingCraft:  dc.b ONESPRITE                  ;Number of sprites
                dc.b C_SMALLROBOT               ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 5                          ;Number of frames
                dc.b $80+6,$80+7,8,7,6

adSmallWalker:  dc.b ONESPRITE                  ;Number of sprites
                dc.b C_SMALLROBOT               ;Spritefile number
                dc.b 12                         ;Left frame add
                dc.b 24                         ;Number of frames
                dc.b 10,9,10,11,10,9,10,11,10,12,12,10
                dc.b $80+10,$80+9,$80+10,$80+11,$80+10,$80+9,$80+10,$80+11,$80+10,$80+12,$80+12,$80+10

        ; Actor logic data

actLogicTblLo:  dc.b <alPlayer
                dc.b <alItem
                dc.b <alMeleeHit
                dc.b <alLargeMeleeHit
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
                dc.b <alPowder
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

actLogicTblHi:  dc.b >alPlayer
                dc.b >alItem
                dc.b >alMeleeHit
                dc.b >alLargeMeleeHit
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
                dc.b >alPowder
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

alPlayer:       dc.w MoveAndAttackHuman         ;Update routine
                dc.b GRP_HEROES|AF_ISORGANIC|AF_NOREMOVECHECK|AF_INITONLYSIZE ;Actor flags
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
                dc.w RemoveActor                ;Destroy routine

alLargeMeleeHit:dc.w MoveMeleeHit               ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 6                          ;Horizontal size
                dc.b 4                          ;Size up
                dc.b 4                          ;Size down
                dc.w RemoveActor                ;Destroy routine

alBullet:       dc.w MoveBulletMuzzleFlash      ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 2                          ;Horizontal size
                dc.b 1                          ;Size up
                dc.b 1                          ;Size down
                dc.w RemoveActor                ;Destroy routine

alShotgunBullet:dc.w MoveShotgunBullet          ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 3                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 3                          ;Size down
                dc.w RemoveActor                ;Destroy routine

alFlame:        dc.w MoveFlame                  ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 5                          ;Horizontal size
                dc.b 5                          ;Size up
                dc.b 3                          ;Size down
                dc.w RemoveActor                ;Destroy routine

alEMP:          dc.w MoveEMP                    ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 128                        ;Horizontal size
                dc.b 128                        ;Size up
                dc.b 128                        ;Size down
                dc.w RemoveActor                ;Destroy routine

alLaser:        dc.w MoveBullet                 ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 3                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 3                          ;Size down
                dc.w RemoveActor                ;Destroy routine

alPlasma:       dc.w MoveBullet                 ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 6                          ;Horizontal size
                dc.b 6                          ;Size up
                dc.b 6                          ;Size down
                dc.w RemoveActor                ;Destroy routine

alLauncherGrenade:
                dc.w MoveLauncherGrenade        ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 3                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 3                          ;Size down
                dc.w ExplodeGrenade             ;Destroy routine

alGrenade:      dc.w MoveGrenade                ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 3                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 3                          ;Size down
                dc.w ExplodeGrenade             ;Destroy routine

alRocket:       dc.w MoveRocket                 ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 4                          ;Horizontal size
                dc.b 2                          ;Size up
                dc.b 2                          ;Size down
                dc.w ExplodeGrenade             ;Destroy routine

alMine:         dc.w MoveMine                   ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 4                          ;Horizontal size
                dc.b 3                          ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeGrenade             ;Destroy routine

alWaterSplash:
alExplosion:    dc.w MoveExplosion              ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags

alSmokeTrail:   dc.w MoveSmokeTrail             ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags

alPowder:       dc.w MovePowder                 ;Update routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 5                          ;Horizontal size
                dc.b 5                          ;Size up
                dc.b 5                          ;Size down
                dc.w RemoveActor                ;Destroy routine

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
                dc.b DROP_WEAPONBATTERYPARTS    ;Itemdrop table index or item override
                dc.b $05                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b 4*8                        ;Horiz max movement speed
                dc.b 3                          ;Horiz acceleration
                dc.b 2*8                        ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 0                          ;Horiz obstacle check offset
                dc.b 0                          ;Vert obstacle check offset

alLargeDroid:   dc.w MoveDroid                  ;Update routine
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
                dc.b 3*8                        ;Horiz max movement speed
                dc.b 2                          ;Horiz acceleration
                dc.b 3*4                        ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 0                          ;Horiz obstacle check offset
                dc.b 0                          ;Vert obstacle check offset

alLargeDroidSuper:
                dc.w MoveDroid                  ;Update routine
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
                dc.b 4*8                        ;Horiz max movement speed
                dc.b 3                          ;Horiz acceleration
                dc.b 2*8                        ;Vert max movement speed
                dc.b 1                          ;Vert acceleration
                dc.b 0                          ;Horiz obstacle check offset
                dc.b 0                          ;Vert obstacle check offset

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
                dc.b DROP_WEAPONBATTERYPARTS    ;Itemdrop table index or item override
                dc.b $06                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b 5*8                        ;Horiz max movement speed
                dc.b 3                          ;Horiz acceleration
                dc.b 2*8                        ;Vert max movement speed
                dc.b 2                          ;Vert acceleration
                dc.b 1                          ;Horiz obstacle check offset
                dc.b 0                          ;Vert obstacle check offset
                
alSmallWalker:  dc.w MoveWalker                 ;Update routine
                dc.b GRP_ENEMIES|AF_NOWEAPON|AF_HORIZATTACKONLY ;Actor flags
                dc.b 12                         ;Horizontal size
                dc.b 21                         ;Size up
                dc.b 0                          ;Size down
                dc.w ExplodeEnemy2_8_Ofs10      ;Destroy routine
                dc.b HP_SMALLWALKER             ;Initial health
                dc.b NO_MODIFY                  ;Damage modifier
                dc.w 35                         ;Score from kill
                dc.b AIMODE_MOVER               ;AI mode when spawned randomly
                dc.b DROP_WEAPONBATTERYPARTS    ;Itemdrop table index or item override
                dc.b $05                        ;AI offense AND-value
                dc.b $10                        ;AI defense probability
                dc.b AMF_JUMP                   ;Move flags
                dc.b 3*8                        ;Max. movement speed
                dc.b 6                          ;Ground movement acceleration
                dc.b 2                          ;In air movement acceleration
                dc.b 6                          ;Gravity acceleration
                dc.b 6                          ;Long jump gravity acceleration
                dc.b 8                          ;Ground braking
                dc.b -3                         ;Height in chars for headbump check (negative)
                dc.b -6*8                       ;Jump initial speed (negative)