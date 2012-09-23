SFX_PISTOL          = $00
SFX_EXPLOSION       = $01
SFX_THROW           = $02
SFX_MELEE           = $03
SFX_PUNCH           = $04
SFX_RELOAD          = $05
SFX_POWERUP         = $06
SFX_PICKUP          = $07

sfxTblLo:       dc.b <sfxPistol
                dc.b <sfxExplosion
                dc.b <sfxThrow
                dc.b <sfxMelee
                dc.b <sfxPunch
                dc.b <sfxReload
                dc.b <sfxPowerup
                dc.b <sfxPickup


sfxTblHi:       dc.b >sfxPistol
                dc.b >sfxExplosion
                dc.b >sfxThrow
                dc.b >sfxMelee
                dc.b >sfxPunch
                dc.b >sfxReload
                dc.b >sfxPowerup
                dc.b >sfxPickup

        ; Sound effect data

sfxPickup:      include sfx/pickup.sfx
sfxReload:      include sfx/reload.sfx
sfxPowerup:     include sfx/powerup.sfx
sfxPunch:       include sfx/punch.sfx
sfxMelee:       include sfx/melee.sfx
sfxThrow:       include sfx/throw.sfx
sfxPistol:      include sfx/pistol.sfx
sfxExplosion:   include sfx/explosion.sfx
