ACT_NONE        = 0
ACT_PLAYER      = 1
ACT_ITEM        = 2
ACT_MELEEHIT    = 3
ACT_BULLET      = 4
ACT_SHOTGUNBULLET = 5
ACT_GRENADE     = 6
ACT_EXPLOSION   = 7
ACT_ENEMY       = 8

        ; Actor display data

adMeleeHit      = $0000                         ;Not displayed

actDispTblLo:   dc.b <adPlayer
                dc.b <adItem
                dc.b <adMeleeHit
                dc.b <adBullet
                dc.b <adShotgunBullet
                dc.b <adGrenade
                dc.b <adExplosion
                dc.b <adPlayer

actDispTblHi:   dc.b >adPlayer
                dc.b >adItem
                dc.b >adMeleeHit
                dc.b >adBullet
                dc.b >adShotgunBullet
                dc.b >adGrenade
                dc.b >adExplosion
                dc.b >adPlayer

adPlayer:       dc.b HUMANOID                   ;Number of sprites
                dc.b C_PLAYER                   ;Lower part spritefile number
                dc.b 40                         ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 28                         ;Lower part left frame add
                dc.b C_PLAYER                   ;Upper part spritefile number
                dc.b 0                          ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 35                         ;Upper part left frame add

adBullet:       dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 20                         ;Number of frames
                dc.b 9,10,11,12,13              ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 9,16,15,14,13
                dc.b 5,6,7,8,5
                dc.b 5,8,7,6,5

adShotgunBullet:dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 20                         ;Number of frames
                dc.b 9,10,11,12,13              ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 9,16,15,14,13
                dc.b 18,19,20,21

adItem:         dc.b ONESPRITE                  ;Number of sprites
                dc.b C_ITEM                     ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 3                          ;Number of frames
itemFrames:     dc.b 0,0,1,2,3,4,5              ;Frametable (first all frames of sprite1, then sprite2)

adGrenade:      dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 1                          ;Number of frames
                dc.b 17                         ;Frametable (first all frames of sprite1, then sprite2)

adExplosion:    dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 5                          ;Number of frames
                dc.b 0,1,2,3,4                  ;Frametable (first all frames of sprite1, then sprite2)

        ; Human actor upper part framenumbers

humanUpperFrTbl:dc.b 1,0,0,1,1,2,2,1,1,2,1,0,0,0,27,25,24,25,26,6,20,21,28,29,30,31,32,33,6,7,8,9,10,11,12
                dc.b 4,3,3,4,4,5,5,4,4,5,4,3,3,3,27,25,24,25,26,13,22,23,34,35,36,37,38,39,13,14,15,16,17,18,19

        ; Human actor lower part framenumbers

humanLowerFrTbl:dc.b 0,1,2,3,4,1,2,3,4,10,11,12,16,17,27,27,26,27,28,20,21,22,29,30,31,32,33,34
                dc.b 5,6,7,8,9,6,7,8,9,13,14,15,18,19,27,27,26,27,28,23,24,25,35,36,37,38,39,40

        ; Human Y-size reduce table based on animation

humanSizeReduceTbl:
                dc.b 1,2,1,0,1,2,1,0,1,2,0,1,6,12,1,2,1,2,0,0,0,18,18,18,18,18,18

        ; Item color flashing table

itemFlashTbl:   dc.b 10,7,1,7

        ; Player weapon damage bonus according to weapon skill

plrWeaponBonusTbl:
                dc.b 8,10,12,14

        ; Player reload time mod according to weapon skill

plrReloadBonusTbl:
                dc.b 8,6,5,4

        ; Player damage mod according to vitality skill

plrDamageModTbl:dc.b 8,7,6,5

        ; Player health recharge delay according to vitality skill

plrRechargeDelayTbl:
                dc.b -HEALTH_RECHARGE_DELAY
                dc.b -HEALTH_RECHARGE_DELAY+20
                dc.b -HEALTH_RECHARGE_DELAY+40
                dc.b -HEALTH_RECHARGE_DELAY+60
                
plrRechargeRateTbl:
                dc.b HEALTH_RECHARGE_RATE
                dc.b HEALTH_RECHARGE_RATE-3
                dc.b HEALTH_RECHARGE_RATE-6
                dc.b HEALTH_RECHARGE_RATE-9

        ; Actor logic data

actLogicTblLo:  dc.b <alPlayer
                dc.b <alItem
                dc.b <alMeleeHit
                dc.b <alBullet
                dc.b <alShotgunBullet
                dc.b <alGrenade
                dc.b <alExplosion
                dc.b <alEnemy

actLogicTblHi:  dc.b >alPlayer
                dc.b >alItem
                dc.b >alMeleeHit
                dc.b >alBullet
                dc.b >alShotgunBullet
                dc.b >alGrenade
                dc.b >alExplosion
                dc.b >alEnemy

alPlayer:       dc.w MovePlayer                 ;Update routine
                dc.w HumanDeath                 ;Destroy routine
                dc.b AF_ISHERO|AF_ISORGANIC|AF_NOREMOVECHECK ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 34                         ;Size up
                dc.b 0                          ;Size down
                dc.b HP_PLAYER                  ;Initial health
                dc.b 0                          ;Color override
                dc.b 0                          ;XP from kill
                dc.b $ff                        ;AI offense probability
                dc.b $ff                        ;AI defense probability
                dc.b AMF_JUMP|AMF_DUCK|AMF_CLIMB|AMF_ROLL|AMF_WALLFLIP ;Move flags
                dc.b 4*8                        ;Max. movement speed
playerGroundAcc:dc.b INITIAL_GROUNDACC          ;Ground movement acceleration
playerInAirAcc: dc.b INITIAL_INAIRACC           ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
playerGroundBrake:
                dc.b INITIAL_GROUNDBRAKE        ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)
playerJumpSpeed:dc.b -INITIAL_JUMPSPEED         ;Jump initial speed (negative)
playerClimbSpeed:
                dc.b INITIAL_CLIMBSPEED         ;Climbing speed
                dc.b 2*8                        ;Ladder jump / wallflip speed right
                dc.b -2*8                       ;Ladder jump / wallflip speed left

alItem:         dc.w MoveItem                   ;Update routine
                dc.w RemoveActor                ;Destroy routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 10                         ;Horizontal size
                dc.b 7                          ;Size up
                dc.b 0                          ;Size down

alMeleeHit:     dc.w MoveMeleeHit               ;Update routine
                dc.w RemoveActor                ;Destroy routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 4                          ;Horizontal size
                dc.b 4                          ;Size up
                dc.b 4                          ;Size down

alBullet:       dc.w MoveBulletMuzzleFlash      ;Update routine
                dc.w RemoveActor                ;Destroy routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 4                          ;Horizontal size
                dc.b 2                          ;Size up
                dc.b 2                          ;Size down

alShotgunBullet:dc.w MoveShotgunBullet          ;Update routine
                dc.w RemoveActor                ;Destroy routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 4                          ;Horizontal size
                dc.b 2                          ;Size up
                dc.b 2                          ;Size down

alGrenade:      dc.w MoveGrenade                ;Update routine
                dc.w ExplodeActor               ;Destroy routine
                dc.b AF_INITONLYSIZE            ;Actor flags
                dc.b 4                          ;Horizontal size
                dc.b 4                          ;Size up
                dc.b 4                          ;Size down

alExplosion:    dc.w MoveExplosion              ;Update routine
                dc.w RemoveActor                ;Destroy routine
                dc.b AF_INITONLYSIZE            ;Actor flags

alEnemy:        dc.w MoveAIHuman                ;Update routine
                dc.w HumanDeath                 ;Destroy routine
                dc.b AF_ISVILLAIN|AF_ISORGANIC  ;Actor flags
                dc.b 8                          ;Horizontal size
                dc.b 34                         ;Size up
                dc.b 0                          ;Size down
                dc.b 8                          ;Initial health
                dc.b 2                          ;Color override
                dc.b 50                         ;XP from kill
                dc.b $07                        ;AI offense accumulator
                dc.b $08                        ;AI defense probability
                dc.b AMF_JUMP|AMF_DUCK|AMF_CLIMB|AMF_ROLL|AMF_WALLFLIP ;Move caps
                dc.b 4*8                        ;Max. movement speed
                dc.b 6*8                        ;Terminal falling speed
                dc.b 8                          ;Ground movement acceleration
                dc.b 3                          ;In air movement acceleration
                dc.b 8                          ;Gravity acceleration
                dc.b 4                          ;Long jump gravity acceleration
                dc.b 6                          ;Ground braking
                dc.b -4                         ;Height in chars for headbump check (negative)
                dc.b -44                        ;Jump initial speed (negative)
                dc.b 96                         ;Climbing speed
                dc.b 2*8                        ;Ladder jump / wallflip speed right
                dc.b -2*8                       ;Ladder jump / wallflip speed left
