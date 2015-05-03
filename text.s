        ; Item names

itemNameLo:     dc.b <txtFists
                dc.b <txtKnife
                dc.b <txtNightstick
                dc.b <txtBat
                dc.b <txtPistol
                dc.b <txtShotgun
                dc.b <txtAutoRifle
                dc.b <txtSniperRifle
                dc.b <txtMinigun
                dc.b <txtFlameThrower
                dc.b <txtLaserRifle
                dc.b <txtPlasmaGun
                dc.b <txtEMPGenerator
                dc.b <txtGrenadeLauncher
                dc.b <txtBazooka
                dc.b <txtGrenade
                dc.b <txtHomingDrone
                dc.b <txtMedKit
                dc.b <txtBattery

itemNameHi:     dc.b >txtFists
                dc.b >txtKnife
                dc.b >txtNightstick
                dc.b >txtBat
                dc.b >txtPistol
                dc.b >txtShotgun
                dc.b >txtAutoRifle
                dc.b >txtSniperRifle
                dc.b >txtMinigun
                dc.b >txtFlameThrower
                dc.b >txtLaserRifle
                dc.b >txtPlasmaGun
                dc.b >txtEMPGenerator
                dc.b >txtGrenadeLauncher
                dc.b >txtBazooka
                dc.b >txtGrenade
                dc.b >txtHomingDrone
                dc.b >txtMedKit
                dc.b >txtBattery

txtFists:       dc.b "FISTS",0
txtKnife:       dc.b "COMBAT KNIFE",0
txtNightstick:  dc.b "NIGHTSTICK",0
txtBat:         dc.b "BAT",0
txtPistol:      dc.b "PISTOL",0
txtShotgun:     dc.b "SHOTGUN",0
txtAutoRifle:   dc.b "AUTO RIFLE",0
txtSniperRifle: dc.b "SNIPER RIFLE",0
txtMinigun:     dc.b "MINIGUN",0
txtFlameThrower:dc.b "FLAMETHROWER",0
txtLaserRifle:  dc.b "LASER RIFLE",0
txtPlasmaGun:   dc.b "PLASMA GUN",0
txtEMPGenerator:dc.b "EMP GENERATOR",0
txtGrenadeLauncher:dc.b "GRENADE LAUNCHER",0
txtBazooka:     dc.b "BAZOOKA",0
txtGrenade:     dc.b "GRENADES",0
txtHomingDrone: dc.b "HOMING DRONE",0
txtMedKit:      dc.b "MEDKIT",0
txtBattery:     dc.b "BATTERY",0

        ; Game messages

txtPickedUp:    dc.b "GOT ",0
txtRequired:    dc.b "NEED ",0
txtInf:         dc.b "*INF"
txtLoad:        dc.b "LOAD"
txtPauseResume: dc.b " RESUME",0
txtPauseRetry:  dc.b " RETRY",0
txtPauseSave:   dc.b "SAVE&EXIT",0

        ; System messages

                if MULTISIDE > 0
txtFlipDisk:    dc.b "FLIP DISK & PRESS FIRE",0
                endif
txtDiskError:   dc.b "IO ERROR, FIRE TO RETRY",0
