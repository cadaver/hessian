ACT_NONE        = 0
ACT_PLAYER      = 1
ACT_MONSTER1    = 2
ACT_MONSTER2    = 3
ACT_EXPLOSION   = 4

        ; Actors' display data pointers

actDispTblLo:   dc.b <adPlayer
                dc.b <adMonster1
                dc.b <adMonster2
                dc.b <adExplosion

actDispTblHi:   dc.b >adPlayer
                dc.b >adMonster1
                dc.b >adMonster2
                dc.b >adExplosion

adMonster1:     dc.b FOURSPRITE                 ;Number of sprites
                dc.b C_FIRSTSPR                 ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 1                          ;Number of frames
                dc.b 2,3,4,5                    ;Frametable (first all frames of sprite1, then sprite2)

adMonster2:     dc.b FOURSPRITE                 ;Number of sprites
                dc.b C_FIRSTSPR                 ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 1                          ;Number of frames
                dc.b 8,9,7,6                    ;Frametable (first all frames of sprite1, then sprite2)

adPlayer:       dc.b HUMANOID                   ;Number of sprites
                dc.b C_FIRSTSPR                 ;Lower part spritefile number
                dc.b 0                          ;Lower part left frame add
                dc.b 0                          ;Lower part base index into the frametable
                dc.b C_FIRSTSPR                 ;Upper part spritefile number
                dc.b 0                          ;Upper part left frame add
                dc.b 0                          ;Upper part base index into the frametable

adExplosion:    dc.b ONESPRITE                  ;Number of sprites
                dc.b C_FIRSTSPR                 ;Spritefile number
                dc.b 0                          ;Left frame add
                dc.b 1                          ;Number of frames
                dc.b 10,11,12,13,14             ;Frametable (first all frames of sprite1, then sprite2)

        ; Human actor lower part framenumbers

humanLowerFrTbl:dc.b 1

        ; Human actor upper part framenumbers

humanUpperFrTbl:dc.b 0

