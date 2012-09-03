        ; Sound effect data

sfxTblLo:       dc.b <sfxPistol
                dc.b <sfxExplosion

sfxTblHi:       dc.b >sfxPistol
                dc.b >sfxExplosion

sfxPistol:      include sfx/pistol.sfx
sfxExplosion:   include sfx/explosion.sfx
