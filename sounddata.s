SFX_THROW           = $00
SFX_PUNCH           = $01
SFX_MELEE           = $02
SFX_HEAVYMELEE      = $03
SFX_PISTOL          = $04
SFX_SHOTGUN         = $05
SFX_AUTORIFLE       = $06
SFX_SNIPERRIFLE     = $07
SFX_MINIGUN         = $08
SFX_FLAMETHROWER    = $09
SFX_LASER           = $0a
SFX_PLASMA          = $0b
SFX_EMP             = $0c
SFX_GRENADELAUNCHER = $0d
SFX_BAZOOKA         = $0e
SFX_DRONE           = $0f
SFX_RELOAD          = $10
SFX_COCKWEAPON      = $11
SFX_COCKSHOTGUN     = $12
SFX_RELOADFLAMER    = $13
SFX_RELOADBAZOOKA   = $14
SFX_POWERUP         = $15
SFX_SELECT          = $16
SFX_PICKUP          = $17
SFX_OBJECT          = $18
SFX_SPLASH          = $19
SFX_DAMAGE          = $1a
SFX_DEATH           = $1b
SFX_EXPLOSION       = $1c

        ; Music relocation tables

ntFixupTblLo:   dc.b <Play_SongTblP2
                dc.b <Play_SongTblP1
                dc.b <Play_SongTblP0
                dc.b <Play_PattTblHiM1
                dc.b <Play_PattTblLoM1
                dc.b <Play_CmdFiltM1
                dc.b <Play_CmdPulseM1
                dc.b <Play_CmdWaveM1
                dc.b <Play_CmdSRM1
                dc.b <Play_CmdADM1
                dc.b <Play_FiltSpdM1b
                dc.b <Play_FiltSpdM1a
                dc.b <Play_FiltTimeM1
                dc.b <Play_PulseSpdM1b
                dc.b <Play_PulseSpdM1a
                dc.b <Play_PulseTimeM1
                dc.b <Play_NoteP0
                dc.b <Play_NoteM1b
                dc.b <Play_NoteM1a
                dc.b <Play_WaveP0
                dc.b <Play_WaveM1

ntFixupTblHi:   dc.b >Play_SongTblP2
                dc.b >Play_SongTblP1
                dc.b >Play_SongTblP0
                dc.b >Play_PattTblHiM1
                dc.b >Play_PattTblLoM1
                dc.b >Play_CmdFiltM1
                dc.b >Play_CmdPulseM1
                dc.b >Play_CmdWaveM1
                dc.b >Play_CmdSRM1
                dc.b >Play_CmdADM1
                dc.b >Play_FiltSpdM1b
                dc.b >Play_FiltSpdM1a
                dc.b >Play_FiltTimeM1
                dc.b >Play_PulseSpdM1b
                dc.b >Play_PulseSpdM1a
                dc.b >Play_PulseTimeM1
                dc.b >Play_NoteP0
                dc.b >Play_NoteM1b
                dc.b >Play_NoteM1a
                dc.b >Play_WaveP0
                dc.b >Play_WaveM1

ntFixupTblAdd:  dc.b NT_ADDZERO+3
                dc.b NT_ADDZERO+2
                dc.b NT_ADDPATT+1
                dc.b NT_ADDPATT
                dc.b NT_ADDLEGATOCMD
                dc.b NT_ADDLEGATOCMD
                dc.b NT_ADDLEGATOCMD
                dc.b NT_ADDCMD
                dc.b NT_ADDCMD
                dc.b NT_ADDFILT
                dc.b NT_ADDZERO
                dc.b NT_ADDFILT
                dc.b NT_ADDPULSE
                dc.b NT_ADDZERO
                dc.b NT_ADDPULSE
                dc.b NT_ADDWAVE
                dc.b NT_ADDZERO+1
                dc.b NT_ADDZERO
                dc.b NT_ADDWAVE
                dc.b NT_ADDZERO+1
                dc.b NT_ADDZERO

        ; Sound effect data

sfxTblLo:       dc.b <sfxThrow
                dc.b <sfxPunch
                dc.b <sfxMelee
                dc.b <sfxHeavyMelee
                dc.b <sfxPistol
                dc.b <sfxShotgun
                dc.b <sfxAutoRifle
                dc.b <sfxSniperRifle
                dc.b <sfxMinigun
                dc.b <sfxFlamer
                dc.b <sfxLaser
                dc.b <sfxPlasma
                dc.b <sfxEMP
                dc.b <sfxLauncher
                dc.b <sfxBazooka
                dc.b <sfxDrone
                dc.b <sfxReload
                dc.b <sfxCockWeapon
                dc.b <sfxCockShotgun
                dc.b <sfxReloadFlamer
                dc.b <sfxReloadBazooka
                dc.b <sfxPowerup
                dc.b <sfxSelect
                dc.b <sfxPickup
                dc.b <sfxObject
                dc.b <sfxSplash
                dc.b <sfxDamage
                dc.b <sfxDeath
                dc.b <sfxExplosion

sfxTblHi:       dc.b >sfxThrow
                dc.b >sfxPunch
                dc.b >sfxMelee
                dc.b >sfxHeavyMelee
                dc.b >sfxPistol
                dc.b >sfxShotgun
                dc.b >sfxAutoRifle
                dc.b >sfxSniperRifle
                dc.b >sfxMinigun
                dc.b >sfxFlamer
                dc.b >sfxLaser
                dc.b >sfxPlasma
                dc.b >sfxEMP
                dc.b >sfxLauncher
                dc.b >sfxBazooka
                dc.b >sfxDrone
                dc.b >sfxReload
                dc.b >sfxCockWeapon
                dc.b >sfxCockShotgun
                dc.b >sfxReloadFlamer
                dc.b >sfxReloadBazooka
                dc.b >sfxPowerup
                dc.b >sfxSelect
                dc.b >sfxPickup
                dc.b >sfxObject
                dc.b >sfxSplash
                dc.b >sfxDamage
                dc.b >sfxDeath
                dc.b >sfxExplosion

sfxSelect:      include sfx/select.sfx
sfxPickup:      include sfx/pickup.sfx
sfxObject:      include sfx/object.sfx
sfxReloadFlamer:include sfx/reloadflamer.sfx
sfxReload:      include sfx/reload.sfx
sfxCockWeapon:  include sfx/cockfast.sfx
sfxCockShotgun: include sfx/cockshotgun.sfx
sfxPowerup:     include sfx/powerup.sfx
sfxPunch:       include sfx/punch.sfx
sfxMelee:       include sfx/melee.sfx
sfxHeavyMelee:  include sfx/heavymelee.sfx
sfxThrow:       include sfx/throw.sfx
sfxReloadBazooka:include sfx/reloadbazooka.sfx
sfxSplash:      include sfx/splash.sfx
sfxDamage:      include sfx/damage.sfx
sfxDrone:       include sfx/drone.sfx
sfxFlamer:      include sfx/flamer.sfx
sfxPistol:      include sfx/pistol.sfx
sfxAutoRifle:   include sfx/autorifle.sfx
sfxMinigun:     include sfx/minigun.sfx
sfxShotgun:     include sfx/shotgun.sfx
sfxLaser:       include sfx/laser.sfx
sfxPlasma:      include sfx/plasma.sfx
sfxLauncher:    include sfx/launcher.sfx
sfxSniperRifle: include sfx/sniperrifle.sfx
sfxBazooka:     include sfx/bazooka.sfx
sfxDeath:       include sfx/death.sfx
sfxEMP:         include sfx/emp.sfx
sfxExplosion:   include sfx/explosion.sfx
