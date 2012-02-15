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
                dc.b C_FIRSTSPR                 ;Lower part spritefile number
                dc.b 1                          ;Lower part left frame add
                dc.b 0                          ;Lower part base index into the frametable
                dc.b C_FIRSTSPR                 ;Upper part spritefile number
                dc.b 1                          ;Upper part left frame add
                dc.b 0                          ;Upper part base index into the frametable

adBullet:       dc.b ONESPRITE                  ;Number of sprites
                dc.b C_FIRSTSPR                 ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 1                          ;Number of frames
                dc.b 4                          ;Frametable (first all frames of sprite1, then sprite2)

adExplosion:    dc.b ONESPRITE                  ;Number of sprites
                dc.b C_FIRSTSPR                 ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 5                          ;Number of frames
                dc.b 10,11,12,13,14             ;Frametable (first all frames of sprite1, then sprite2)

        ; Human actor lower part framenumbers

humanLowerFrTbl:dc.b 1,3

        ; Human actor upper part framenumbers

humanUpperFrTbl:dc.b 0,2

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

