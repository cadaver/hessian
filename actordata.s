ACT_NONE        = 0
ACT_PLAYER      = 1
ACT_BULLET      = 2
ACT_EXPLOSION   = 3

        ; Actors' display data pointers

actDispTblLo:   dc.b <adPlayer
                dc.b <adBullet
                dc.b <adExplosion

actDispTblHi:   dc.b >adPlayer
                dc.b >adBullet
                dc.b >adExplosion

adPlayer:       dc.b HUMANOID                   ;Number of sprites
                dc.b C_PLAYER                   ;Lower part spritefile number
                dc.b 31                         ;Lower part base spritenumber
                dc.b 0                          ;Lower part base index into the frametable
                dc.b 24                         ;Lower part left frame add
                dc.b C_PLAYER                   ;Upper part spritefile number
                dc.b 0                          ;Upper part base spritenumber
                dc.b 0                          ;Upper part base index into the frametable
                dc.b 34                         ;Upper part left frame add

adBullet:       dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 1                          ;Number of frames
                dc.b 0                          ;Frametable (first all frames of sprite1, then sprite2)

adExplosion:    dc.b ONESPRITE                  ;Number of sprites
                dc.b C_COMMON                   ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 5                          ;Number of frames
                dc.b 1,2,3,4,5                  ;Frametable (first all frames of sprite1, then sprite2)

        ; Human actor upper part framenumbers

humanUpperFrTbl:dc.b 1,0,0,1,1,2,2,1,1,2,1,0,0,0,17,16,17,18,19,20,21,22,23,24,6,11,7,12,8,13,9,14,10,15
                dc.b 4,3,3,4,4,5,5,4,4,5,4,3,3,3,17,16,17,18,25,26,27,28,29,30,6,11,7,12,8,13,9,14,10,15

        ; Human actor lower part framenumbers

humanLowerFrTbl:dc.b 0,1,2,3,4,1,2,3,4,10,11,12,16,17,21,20,21,22,23,24,25,26,27,28
                dc.b 5,6,7,8,9,6,7,8,9,13,14,15,18,19,21,20,21,22,29,30,31,32,33,34

        ; Actors' logic data pointers

actLogicTblLo:  dc.b <alPlayer
                dc.b <alBullet
                dc.b <alExplosion

actLogicTblHi:  dc.b >alPlayer
                dc.b >alBullet
                dc.b >alExplosion

alPlayer:       dc.w MovePlayer                 ;Update routine

alBullet:       dc.w MoveBullet                 ;Update routine

alExplosion:    dc.w MoveExplosion              ;Update routine

