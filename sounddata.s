SFX_PISTOL          = $00
SFX_EXPLOSION       = $01

sfxTblLo:       dc.b <sfxPistol
                dc.b <sfxExplosion

sfxTblHi:       dc.b >sfxPistol
                dc.b >sfxExplosion

        ; Sound effect data

sfxPistol:      include sfx/pistol.sfx
sfxExplosion:   include sfx/explosion.sfx
