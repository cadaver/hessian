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
SFX_SONICWAVE       = $0a
SFX_LASER           = $0b
SFX_PLASMA          = $0c
SFX_EMP             = $0d
SFX_GRENADELAUNCHER = $0e
SFX_BAZOOKA         = $0f
SFX_RELOAD          = $10
SFX_COCKWEAPON      = $11
SFX_COCKSHOTGUN     = $12
SFX_RELOADFLAMER    = $13
SFX_RELOADBAZOOKA   = $14
SFX_POWERUP         = $15
SFX_SELECT          = $16
SFX_PICKUP          = $17
SFX_DAMAGE          = $18
SFX_DEATH           = $19
SFX_EXPLOSION       = $1a

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

        ; Frequency table

ntFreqTbl:      dc.w $022d,$024e,$0271,$0296,$02be,$02e8
                dc.w $0314,$0343,$0374,$03a9,$03e1,$041c
                dc.w $045a,$049c,$04e2,$052d,$057c,$05cf
                dc.w $0628,$0685,$06e8,$0752,$07c1,$0837
                dc.w $08b4,$0939,$09c5,$0a5a,$0af7,$0b9e
                dc.w $0c4f,$0d0a,$0dd1,$0ea3,$0f82,$106e
                dc.w $1168,$1271,$138a,$14b3,$15ee,$173c
                dc.w $189e,$1a15,$1ba2,$1d46,$1f04,$20dc
                dc.w $22d0,$24e2,$2714,$2967,$2bdd,$2e79
                dc.w $313c,$3429,$3744,$3a8d,$3e08,$41b8
                dc.w $45a1,$49c5,$4e28,$52cd,$57ba,$5cf1
                dc.w $6278,$6853,$6e87,$751a,$7c10,$8371
                dc.w $8b42,$9389,$9c4f,$a59b,$af74,$b9e2
                dc.w $c4f0,$d0a6,$dd0e,$ea33,$f820,$ffff

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
                dc.b <sfxSonicWave
                dc.b <sfxLaser
                dc.b <sfxPlasma
                dc.b <sfxEMP
                dc.b <sfxLauncher
                dc.b <sfxBazooka
                dc.b <sfxReload
                dc.b <sfxCockWeapon
                dc.b <sfxCockShotgun
                dc.b <sfxReloadFlamer
                dc.b <sfxReloadBazooka
                dc.b <sfxPowerup
                dc.b <sfxSelect
                dc.b <sfxPickup
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
                dc.b >sfxSonicWave
                dc.b >sfxLaser
                dc.b >sfxPlasma
                dc.b >sfxEMP
                dc.b >sfxLauncher
                dc.b >sfxBazooka
                dc.b >sfxReload
                dc.b >sfxCockWeapon
                dc.b >sfxCockShotgun
                dc.b >sfxReloadFlamer
                dc.b >sfxReloadBazooka
                dc.b >sfxPowerup
                dc.b >sfxSelect
                dc.b >sfxPickup
                dc.b >sfxDamage
                dc.b >sfxDeath
                dc.b >sfxExplosion

sfxSelect:      include sfx/select.sfx
sfxPickup:      include sfx/pickup.sfx
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
sfxDamage:      include sfx/damage.sfx
sfxFlamer:      include sfx/flamer.sfx
sfxPistol:      include sfx/pistol.sfx
sfxAutoRifle:   include sfx/autorifle.sfx
sfxMinigun:     include sfx/minigun.sfx
sfxShotgun:     include sfx/shotgun.sfx
sfxLaser:       include sfx/laser.sfx
sfxPlasma:      include sfx/plasma.sfx
sfxSonicWave:   include sfx/sonicwave.sfx
sfxLauncher:    include sfx/launcher.sfx
sfxSniperRifle: include sfx/sniperrifle.sfx
sfxBazooka:     include sfx/bazooka.sfx
sfxDeath:       include sfx/death.sfx
sfxEMP:         include sfx/emp.sfx
sfxExplosion:   include sfx/explosion.sfx
