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
                dc.b <txtExtinguisher
                dc.b <txtGrenade
                dc.b <txtMine
                dc.b <txtMedKit
                dc.b <txtBattery
                dc.b <txtArmor
                dc.b <txtWarehousePass
                dc.b <txtItPass
                dc.b <txtServicePass
                dc.b <txtSecurityPass
                dc.b <txtSciencePass
                dc.b <txtLv2ItPass
                dc.b <txtLv2SecurityPass
                dc.b <txtSuitePass
                dc.b <txtServerVaultPass
                dc.b <txtBiometricId

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
                dc.b >txtExtinguisher
                dc.b >txtGrenade
                dc.b >txtMine
                dc.b >txtMedKit
                dc.b >txtBattery
                dc.b >txtArmor
                dc.b >txtWarehousePass
                dc.b >txtItPass
                dc.b >txtServicePass
                dc.b >txtSecurityPass
                dc.b >txtSciencePass
                dc.b >txtLv2ItPass
                dc.b >txtLv2SecurityPass
                dc.b >txtSuitePass
                dc.b >txtServerVaultPass
                dc.b >txtBiometricId

txtFists:       dc.b "FISTS",0
txtKnife:       dc.b "COMBAT KNIFE",0
txtNightstick:  dc.b "NIGHTSTICK",0
txtBat:         dc.b "BAT",0
txtPistol:      dc.b "PISTOL",0
txtShotgun:     dc.b "SHOT"
txtGun:         dc.b "GUN",0
txtAutoRifle:   dc.b "AUTO"
txtRifle:       dc.b " RIFLE",0
txtSniperRifle: dc.b "SNIPER"
                textjump txtRifle
txtMinigun:     dc.b "MINI"
                textjump txtGun
txtFlameThrower:dc.b "FLAMETHROWER",0
txtLaserRifle:  dc.b "LASER"
                textjump txtRifle
txtPlasmaGun:   dc.b "PLASMA "
                textjump txtGun
txtEMPGenerator:dc.b "EMP GENERATOR",0
txtGrenadeLauncher:dc.b "GRENADE LAUNC"
txtHer:         dc.b "HER",0
txtBazooka:     dc.b "BAZOOKA",0
txtExtinguisher:dc.b "FIRE EXTINGUIS"
                textjump txtHer
txtGrenade:     dc.b "GRENADES",0
txtMine:        dc.b "SMART MINE",0
txtMedKit:      dc.b "MEDKIT",0
txtBattery:     dc.b "BATTERY",0
txtArmor:       dc.b "ARMOR",0
txtWarehousePass:dc.b "WAREHOUSE"
txtPass:        dc.b " PASS",0
txtItPass:      dc.b "IT"
                textjump txtPass
txtServicePass: dc.b "SERVICE"
                textjump txtPass
txtSecurityPass:dc.b "SECURITY"
                textjump txtPass
txtSciencePass: dc.b "SCIENCE"
                textjump txtPass
txtLv2ItPass:   dc.b "LV2 "
                textjump txtItPass
txtLv2SecurityPass:dc.b "LV2 "
                textjump txtSecurityPass
txtSuitePass:dc.b "THRONE SUITE"
                textjump txtPass
txtServerVaultPass:dc.b "SERVER VAULT"
                textjump txtPass
txtBiometricId: dc.b "BIOMETRIC ID",0

        ; Game messages

txtPickedUp:    dc.b "GOT ",0
txtRequired:    dc.b "NEED ",0
txtInf:         dc.b "*INF"
txtLoad:        dc.b "LOAD"
txtPause:       dc.b " RESUME RETRY SAVE&END",0

        ; System messages

                if MULTISIDE > 0
txtFlipDisk:    dc.b "FLIP DISK & PRESS FIRE",0
                endif
txtDiskError:   dc.b "IO ERROR FIRE TO RETRY",0
