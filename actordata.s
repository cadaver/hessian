ACT_NONE        = 0
ACT_PLAYER      = 1
ACT_ITEM        = 2
ACT_MELEEHIT    = 3
ACT_BULLET      = 4
ACT_GRENADE     = 5
ACT_EXPLOSION   = 6
ACT_INACTIVEPLAYER = 7

HP_PLAYER       = 28

        ; Actors' display data pointers

adMeleeHit      = $0000                         ;Not displayed

actDispTblLo:   dc.b <adPlayer
                dc.b <adItem
                dc.b <adMeleeHit
                dc.b <adBullet
                dc.b <adGrenade
                dc.b <adExplosion
                dc.b <adPlayer

actDispTblHi:   dc.b >adPlayer
                dc.b >adItem
                dc.b >adMeleeHit
                dc.b >adBullet
                dc.b >adGrenade
                dc.b >adExplosion
                dc.b >adPlayer

adPlayer:       dc.b HUMANOID                   ;Number of sprites
                dc.b C_PLAYER                   ;Lower part spritefile number
                dc.b 39                         ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 27                         ;Lower part left frame add
                dc.b C_PLAYER                   ;Upper part spritefile number
                dc.b 0                          ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 34                         ;Upper part left frame add

adBullet:       dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 20                         ;Number of frames
                dc.b 9,10,11,12,13              ;Frametable (first all frames of sprite1, then sprite2)
                dc.b 9,16,15,14,13
                dc.b 5,6,7,8,5
                dc.b 5,8,7,6,5

adItem:         dc.b ONESPRITE                  ;Number of sprites
                dc.b C_WEAPON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 3                          ;Number of frames
itemFrames:     dc.b 11,11,12,13                ;Frametable (first all frames of sprite1, then sprite2)

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

humanUpperFrTbl:dc.b 1,0,0,1,1,2,2,1,1,2,1,0,0,0,25,24,25,26,6,20,21,27,28,29,30,31,32,6,7,8,9,10,11,12
                dc.b 4,3,3,4,4,5,5,4,4,5,4,3,3,3,25,24,25,26,13,22,23,33,34,35,36,37,38,13,14,15,16,17,18,19

        ; Human actor lower part framenumbers

humanLowerFrTbl:dc.b 0,1,2,3,4,1,2,3,4,10,11,12,16,17,27,26,27,28,20,21,22,29,30,31,32,33,34
                dc.b 5,6,7,8,9,6,7,8,9,13,14,15,18,19,27,26,27,28,23,24,25,35,36,37,38,39,40

        ; Human Y-size reduce table based on animation

humanSizeReduceTbl:
                dc.b 1,2,1,0,1,2,1,0,1,2,0,1,6,12,1,2,1,2,0,0,0,12,16,16,16,16,12

        ; Item color flashing table

itemFlashTbl:   dc.b 10,7,1,7

        ; Actors' logic data pointers

actLogicTblLo:  dc.b <alPlayer
                dc.b <alItem
                dc.b <alMeleeHit
                dc.b <alBullet
                dc.b <alGrenade
                dc.b <alExplosion
                dc.b <alInactivePlayer

actLogicTblHi:  dc.b >alPlayer
                dc.b >alItem
                dc.b >alMeleeHit
                dc.b >alBullet
                dc.b >alGrenade
                dc.b >alExplosion
                dc.b >alInactivePlayer

alPlayer:       dc.w MovePlayer                 ;Update routine
                dc.w HumanDeath                 ;Destroy routine
                dc.b 8                          ;Horizontal size
                dc.b 34                         ;Size up
                dc.b 0                          ;Size down
                dc.b HP_PLAYER                  ;Initial health
                dc.b AMC_JUMP|AMC_DUCK|AMC_CLIMB|AMC_ROLL|AMC_WALLFLIP ;Move caps
                dc.b 4*8                        ;Max. movement speed
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

alItem:         dc.w MoveItem                   ;Update routine
                dc.w RemoveActor                ;Destroy routine
                dc.b 8                          ;Horizontal size
                dc.b 7                          ;Size up
                dc.b 0                          ;Size down

alMeleeHit:     dc.w MoveMeleeHit               ;Update routine
                dc.w RemoveActor                ;Destroy routine
                dc.b 4                          ;Horizontal size
                dc.b 4                          ;Size up
                dc.b 4                          ;Size down

alBullet:       dc.w MoveBulletMuzzleFlash      ;Update routine
                dc.w RemoveActor                ;Destroy routine
                dc.b 4                          ;Horizontal size
                dc.b 4                          ;Size up
                dc.b 4                          ;Size down

alGrenade:      dc.w MoveGrenade                ;Update routine
                dc.w ExplodeActor               ;Destroy routine
                dc.b 4                          ;Horizontal size
                dc.b 4                          ;Size up
                dc.b 4                          ;Size down

alExplosion:    dc.w MoveExplosion              ;Update routine

alInactivePlayer:
                dc.w MoveAndAttackHuman         ;Update routine
                dc.w HumanDeath                 ;Destroy routine
                dc.b 8                          ;Horizontal size
                dc.b 34                         ;Size up
                dc.b 0                          ;Size down
                dc.b HP_PLAYER                  ;Initial health
                dc.b AMC_JUMP|AMC_DUCK|AMC_CLIMB|AMC_ROLL|AMC_WALLFLIP ;Move caps
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

