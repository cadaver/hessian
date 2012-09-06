SFX_PISTOL          = $00
SFX_EXPLOSION       = $01
SFX_THROW           = $02
SFX_MELEE           = $03

sfxTblLo:       dc.b <sfxPistol
                dc.b <sfxExplosion
                dc.b <sfxThrow
                dc.b <sfxMelee

sfxTblHi:       dc.b >sfxPistol
                dc.b >sfxExplosion
                dc.b >sfxThrow
                dc.b >sfxMelee

        ; Sound effect data

sfxMelee:       include sfx/melee.sfx
sfxThrow:       include sfx/throw.sfx
sfxPistol:      include sfx/pistol.sfx
sfxExplosion:   include sfx/explosion.sfx
