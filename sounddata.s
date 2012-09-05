SFX_PISTOL          = $00
SFX_EXPLOSION       = $01
SFX_THROW           = $02

sfxTblLo:       dc.b <sfxPistol
                dc.b <sfxExplosion
                dc.b <sfxThrow

sfxTblHi:       dc.b >sfxPistol
                dc.b >sfxExplosion
                dc.b >sfxThrow

        ; Sound effect data

sfxThrow:       include sfx/throw.sfx
sfxPistol:      include sfx/pistol.sfx
sfxExplosion:   include sfx/explosion.sfx
