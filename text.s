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
                dc.b <txtParts
                dc.b <txtAmplifier
                dc.b <txtTruckBattery
                dc.b <txtFuelCan
                dc.b <txtLungFilter
                dc.b <txtWarehousePass
                dc.b <txtItPass
                dc.b <txtServicePass
                dc.b <txtSecurityPass
                dc.b <txtSciencePass
                dc.b <txtLv2ItPass
                dc.b <txtLv2SecurityPass
                dc.b <txtSuitePass
                dc.b <txtServerVaultPass
                dc.b <txtOldTunnelsPass
                dc.b <txtBiometricId
                dc.b <txtCommGear
                dc.b <txtLaptop
                dc.b <txtHazmatSuit

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
                dc.b >txtParts
                dc.b >txtAmplifier
                dc.b >txtTruckBattery
                dc.b >txtFuelCan
                dc.b >txtLungFilter
                dc.b >txtWarehousePass
                dc.b >txtItPass
                dc.b >txtServicePass
                dc.b >txtSecurityPass
                dc.b >txtSciencePass
                dc.b >txtLv2ItPass
                dc.b >txtLv2SecurityPass
                dc.b >txtSuitePass
                dc.b >txtServerVaultPass
                dc.b >txtOldTunnelsPass
                dc.b >txtBiometricId
                dc.b >txtCommGear
                dc.b >txtLaptop
                dc.b >txtHazmatSuit

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
txtFlameThrower:dc.b "FLAMETHROW"
                textjump txtEr
txtLaserRifle:  dc.b "LASER"
                textjump txtRifle
txtPlasmaGun:   dc.b "PLASMA "
                textjump txtGun
txtEMPGenerator:dc.b "EMP GENERATOR",0
txtGrenadeLauncher:dc.b "GRENADE LAUNC"
txtHer:         dc.b "H"
txtEr:          dc.b "ER",0
txtBazooka:     dc.b "BAZOOKA",0
txtExtinguisher:dc.b "FIRE EXTINGUIS"
                textjump txtHer
txtGrenade:     dc.b "GRENADES",0
txtMine:        dc.b "SMART MINE",0
txtMedKit:      dc.b "MEDK"
txtIt:          dc.b "IT",0
txtBattery:     dc.b "BATTERY",0
txtArmor:       dc.b "ARMOR",0
txtParts:       dc.b "PARTS",0
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
txtOldTunnelsPass:dc.b "OLD TUNNELS"
                textjump txtPass
txtBiometricId: dc.b "BIOMETRIC ID",0
txtAmplifier:   dc.b "SIGNAL AMPLIFI"
                textjump txtEr
txtTruckBattery:dc.b "TRUCK "
                textjump txtBattery
txtFuelCan:     dc.b "FUEL CAN",0
txtLungFilter:  dc.b "LUNG FILT"
                textjump txtEr
txtLaptop:      dc.b "LAPTOP",0
txtCommGear:    dc.b "RADIO & EYECAM",0
txtHazmatSuit:  dc.b "HAZMAT SU"
                textjump txtIt

        ; Game messages

txtPickedUp:    dc.b "GOT ",0
txtRequired:    dc.b "NEED ",0
txtInf:         dc.b "*INF"
txtLoad:        dc.b "LOAD"
txtPause:       dc.b " RESUME RETRY SAVE&END",0
txtLocked:      dc.b "LOCKED",0

        ; System messages

txtDiskError:   dc.b "IO ERROR FIRE TO RETRY",0
