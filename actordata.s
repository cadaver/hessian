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

humanUpperFrTbl:dc.b 2,0,0,2,2,4,4,2,2,4,2,0,0,0,17,16,17,18,19,21,23,25,27,29,6,7,8,9,10,11,12,13,14,15
                dc.b 3,1,1,3,3,5,5,3,3,5,3,1,1,1,17,16,17,18,20,22,24,26,28,30,6,7,8,9,10,11,12,13,14,15

        ; Human actor lower part framenumbers

humanLowerFrTbl:dc.b 0,2,4,6,8,2,4,6,8,10,12,14,16,18,21,20,21,22,23,25,27,29,31,33
                dc.b 1,3,5,7,9,3,5,7,9,11,13,15,17,19,21,20,21,22,24,26,28,30,32,34

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

