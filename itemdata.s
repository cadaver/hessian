ITEM_NONE       = 0
ITEM_FISTS      = 1
ITEM_KNIFE      = 2
ITEM_NIGHTSTICK = 3
ITEM_BAT        = 4
ITEM_PISTOL     = 5
ITEM_SHOTGUN    = 6
ITEM_AUTORIFLE  = 7
ITEM_SNIPERRIFLE = 8
ITEM_MINIGUN    = 9
ITEM_FLAMETHROWER = 10
ITEM_LASERRIFLE = 11
ITEM_PLASMAGUN  = 12
ITEM_EMPGENERATOR = 13
ITEM_GRENADELAUNCHER = 14
ITEM_BAZOOKA    = 15
ITEM_EXTINGUISHER = 16
ITEM_GRENADE    = 17
ITEM_MINE       = 18
ITEM_ANIMALBITE = 19 ;Not an actual item, but "weapon" used by animal enemies
ITEM_MEDKIT     = 19
ITEM_BATTERY    = 20
ITEM_ARMOR      = 21
ITEM_PARTS      = 22
ITEM_WAREHOUSEPASS = 23
ITEM_ITPASS = 24
ITEM_SERVICEPASS = 25
ITEM_SECURITYPASS = 26
ITEM_SCIENCEPASS = 27
ITEM_LV2ITPASS = 28
ITEM_LV2SECURITYPASS = 29
ITEM_SUITEPASS = 30
ITEM_VAULTPASS = 31
ITEM_OLDTUNNELSPASS = 32
ITEM_BIOMETRICID = 33

ITEM_OWNWEAPON  = $80
ITEM_FIRST_CONSUMABLE = ITEM_GRENADE
ITEM_FIRST_NONWEAPON = ITEM_MEDKIT
ITEM_FIRST_IMPORTANT = ITEM_WAREHOUSEPASS
ITEM_FIRST      = ITEM_FISTS
ITEM_LAST       = ITEM_BIOMETRICID
ITEM_FIRST_MAG  = ITEM_PISTOL
ITEM_LAST_MAG   = ITEM_BAZOOKA

DROP_WEAPONMEDKITARMOR = $80
DROP_WEAPONMEDKIT = $81
DROP_WEAPON     = $82
DROP_WEAPONBATTERY = $83
DROP_WEAPONBATTERYPARTS = $89
DROPTABLERANDOM = 16                             ;Pick random choice from 16 consecutive indices

itemDropTable:  dc.b ITEM_ARMOR
                dc.b ITEM_MEDKIT
                ds.b 16,ITEM_OWNWEAPON
                dc.b ITEM_BATTERY
                ds.b 6,ITEM_PARTS

itemMaxCount:   dc.b 0                          ;Fists
                dc.b 0                          ;Knife
                dc.b 0                          ;Nightstick
                dc.b 0                          ;Bat
                dc.b 0                          ;Pistol
                dc.b 0                          ;Shotgun
                dc.b 0                          ;Auto rifle
                dc.b 0                          ;Sniper rifle
                dc.b 0                          ;Minigun
                dc.b 0                          ;Flamethrower
                dc.b 0                          ;Laser rifle
                dc.b 0                          ;Plasma gun
                dc.b 0                          ;EMP generator
                dc.b 0                          ;Grenade launcher
                dc.b 0                          ;Bazooka
                dc.b 0                          ;Extinguisher
                dc.b 0                          ;Grenade
                dc.b 0                          ;Mine
                dc.b 0                          ;Medikit
                dc.b 0                          ;Battery
                dc.b 100                        ;Armor
                dc.b 250                        ;Parts

itemDefaultMaxCount:
                dc.b 1                          ;Fists
                dc.b 1                          ;Knife
                dc.b 1                          ;Nightstick
                dc.b 1                          ;Bat
                dc.b 60                         ;Pistol
                dc.b 40                         ;Shotgun
                dc.b 120                        ;Auto rifle
                dc.b 20                         ;Sniper rifle
                dc.b 100                        ;Minigun
                dc.b 120                        ;Flamethrower
                dc.b 60                         ;Laser rifle
                dc.b 40                         ;Plasma gun
                dc.b 8                          ;EMP generator
                dc.b 6                          ;Grenade launcher
                dc.b 4                          ;Bazooka
                dc.b 100                        ;Extinguisher
                dc.b 5                          ;Grenade
                dc.b 3                          ;Mine
                dc.b 2                          ;Medikit
                dc.b 2                          ;Battery

itemDefaultPickup:
                dc.b 1                          ;Fists
                dc.b 1                          ;Knife
                dc.b 1                          ;Nightstick
                dc.b 1                          ;Bat
                dc.b 5                          ;Pistol
                dc.b 4                          ;Shotgun
                dc.b 10                         ;Auto rifle
                dc.b 3                          ;Sniper rifle
                dc.b 50                         ;Minigun
                dc.b 30                         ;Flamethrower
                dc.b 7                          ;Laser rifle
                dc.b 5                          ;Plasma gun
                dc.b 4                          ;EMP generator
                dc.b 3                          ;Grenade launcher
                dc.b 2                          ;Bazooka
                dc.b 100                        ;Extinguisher
                dc.b 2                          ;Grenade
                dc.b 2                          ;Mine
                dc.b 1                          ;Medikit
                dc.b 1                          ;Battery
                dc.b 100                        ;Armor
                dc.b 1                          ;Parts

itemMagazineSize:
                dc.b MAG_INFINITE               ;Fists
                dc.b MAG_INFINITE               ;Knife
                dc.b MAG_INFINITE               ;Nightstick
                dc.b MAG_INFINITE               ;Bat
                dc.b 10                         ;Pistol
                dc.b 8                          ;Shotgun
                dc.b 30                         ;Auto rifle
                dc.b 5                          ;Sniper rifle
                dc.b 0                          ;Minigun
                dc.b 60                         ;Flamethrower
                dc.b 15                         ;Laser rifle
                dc.b 10                         ;Plasma gun
                dc.b 4                          ;EMP generator
                dc.b 3                          ;Grenade launcher
                dc.b 1                          ;Bazooka

                dc.b 0                          ;None weapon for mine AI
itemNPCMinDist: dc.b 0                          ;Fists (not used by NPCs)
                dc.b 0                          ;Knife
                dc.b 0                          ;Nightstick
                dc.b 0                          ;Bat
                dc.b 1                          ;Pistol
                dc.b 1                          ;Shotgun
                dc.b 1                          ;Auto rifle
                dc.b 1                          ;Sniper rifle
                dc.b 1                          ;Minigun
                dc.b 1                          ;Flamethrower
                dc.b 1                          ;Laser rifle
                dc.b 1                          ;Plasma gun
                dc.b 1                          ;EMP generator (not used by NPCs)
                dc.b 2                          ;Grenade launcher
                dc.b 3                          ;Bazooka
                dc.b 2                          ;Extinguisher (not an actual weapon, not used by NPCs)
                dc.b 2                          ;Grenade
                dc.b 2                          ;Mine (not used by NPCs)
                dc.b 0                          ;Animal bite

                dc.b 3                          ;None weapon for mine AI
itemNPCMaxDist: dc.b 1                          ;Fists (not used by NPCs)
                dc.b 1                          ;Knife
                dc.b 1                          ;Nightstick
                dc.b 1                          ;Bat
                dc.b 4                          ;Pistol
                dc.b 4                          ;Shotgun
                dc.b 4                          ;Auto rifle
                dc.b 7                          ;Sniper rifle
                dc.b 4                          ;Minigun
                dc.b 4                          ;Flamethrower
                dc.b 5                          ;Laser rifle
                dc.b 5                          ;Plasma gun
                dc.b 5                          ;EMP generator (not used by NPCs)
                dc.b 5                          ;Grenade launcher
                dc.b 7                          ;Bazooka
                dc.b 3                          ;Extinguisher (not an actual weapon, not used by NPCs)
                dc.b 6                          ;Grenade
                dc.b 2                          ;Mine (not used by NPCs)
                dc.b 1                          ;Animal bite

itemNPCAttackLength:                            ;Note: stored as negative
                dc.b -5                         ;Fists (not used by NPCs)
                dc.b -5                         ;Knife
                dc.b -6                         ;Nightstick
                dc.b -7                         ;Bat
                dc.b -6                         ;Pistol
                dc.b -9                         ;Shotgun
                dc.b -7                         ;Auto rifle (2 shots)
                dc.b -10                        ;Sniper rifle
                dc.b -7                         ;Minigun (3 shots)
                dc.b -7                         ;Flamethrower (3 shots)
                dc.b -6                         ;Laser rifle
                dc.b -7                         ;Plasma gun
                dc.b -7                         ;EMP generator (not used by NPCs)
                dc.b -10                        ;Grenade launcher
                dc.b -10                        ;Bazooka
                dc.b -10                        ;Extinguisher (not an actual weapon, not used by NPCs)
                dc.b -4                         ;Grenade
                dc.b -4                         ;Mine (not used by NPCs)
                dc.b -5                         ;Animal bite

itemNPCAttackThreshold:
                dc.b $20                        ;Fists (not used by NPCs)
                dc.b $20                        ;Knife
                dc.b $28                        ;Nightstick
                dc.b $30                        ;Bat
                dc.b $40                        ;Pistol
                dc.b $60                        ;Shotgun
                dc.b $50                        ;Auto rifle
                dc.b $70                        ;Sniper rifle
                dc.b $58                        ;Minigun
                dc.b $58                        ;Flamethrower
                dc.b $48                        ;Laser rifle
                dc.b $58                        ;Plasma gun
                dc.b $7f                        ;EMP generator (not used by NPCs)
                dc.b $7f                        ;Grenade launcher
                dc.b $7f                        ;Bazooka
                dc.b $7f                        ;Extinguisher (not an actual weapon, not used by NPCs)
                dc.b $7f                        ;Grenade
                dc.b $7f                        ;Mine (not used by NPCs)
                dc.b $20                        ;Animal bite
