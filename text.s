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
                dc.b <txtSonicWaveGun
                dc.b <txtLaserRifle
                dc.b <txtPlasmaGun
                dc.b <txtEMPGenerator
                dc.b <txtGrenadeLauncher
                dc.b <txtBazooka
                dc.b <txtGrenade
                dc.b <txtHomingDrone
                dc.b <txtMedKit
                dc.b <txtCredits


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
                dc.b >txtSonicWaveGun
                dc.b >txtLaserRifle
                dc.b >txtPlasmaGun
                dc.b >txtEMPGenerator
                dc.b >txtGrenadeLauncher
                dc.b >txtBazooka
                dc.b >txtGrenade
                dc.b >txtHomingDrone
                dc.b >txtMedKit
                dc.b >txtCredits


txtFists:       dc.b "FISTS",0
txtKnife:       dc.b "KNIFE",0
txtNightstick:  dc.b "NIGHTSTICK",0
txtBat:         dc.b "BAT",0
txtPistol:      dc.b "PISTOL",0
txtShotgun:     dc.b "SHOTGUN",0
txtAutoRifle:   dc.b "AUTO RIFLE",0
txtSniperRifle: dc.b "SNIPER RIFLE",0
txtMinigun:     dc.b "MINIGUN",0
txtFlameThrower:dc.b "FLAMETHROWER",0
txtSonicWaveGun:dc.b "SONIC WAVE GUN",0
txtLaserRifle:  dc.b "LASER RIFLE",0
txtPlasmaGun:   dc.b "PLASMA GUN",0
txtEMPGenerator:dc.b "EMP GENERATOR",0
txtGrenadeLauncher:dc.b "GRENADE LAUNCHER",0
txtBazooka:     dc.b "BAZOOKA",0
txtGrenade:     dc.b "GRENADES",0
txtHomingDrone: dc.b "HOMING DRONE",0
txtMedKit:      dc.b "MEDKIT",0
txtCredits:     dc.b "CREDITS",0

        ; Skill names

skillNameLo:    dc.b <txtAgility
                dc.b <txtCarrying
                dc.b <txtFirearms
                dc.b <txtMelee
                dc.b <txtVitality

skillNameHi:    dc.b >txtAgility
                dc.b >txtCarrying
                dc.b >txtFirearms
                dc.b >txtMelee
                dc.b >txtVitality

txtAgility:     dc.b "AGILITY",0
txtCarrying:    dc.b "CARRYING",0
txtFirearms:    dc.b "FIREARMS",0
txtMelee:       dc.b "MELEE",0
txtVitality:    dc.b "VITALITY",0

        ; Game messages

txtPickedUp:    dc.b "GOT ",0
txtRequired:    dc.b "NEED ",0
txtInf:         dc.b "*INF"
txtLoad:        dc.b "LOAD"
txtXP:          dc.b "XP, "
txtSkillDisplay:dc.b "LV.           A C F M V",0
txtLevelUp:     dc.b "LEVELED UP TO LV."
txtLevelUpLevel:dc.b "    PICK SKILL TO IMPROVE",0
txtPauseResume: dc.b " RESUME GAME",0
txtPauseRetry:  dc.b " CONTINUE   ",0
txtPauseSave:   dc.b "  SAVE&EXIT",0

        ; System messages

txtFlipDisk:    dc.b "FLIP DISK & PRESS FIRE",0
txtDiskError:   dc.b "IO ERROR, FIRE TO RETRY",0
