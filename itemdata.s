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
ITEM_GRENADE    = 16
ITEM_MINE       = 17
ITEM_MEDKIT     = 18
ITEM_BATTERY    = 19

ITEM_FIRST_FIREARM = ITEM_PISTOL
ITEM_FIRST_CONSUMABLE = ITEM_GRENADE
ITEM_FIRST_NONWEAPON = ITEM_MEDKIT
ITEM_FIRST_IMPORTANT = ITEM_BATTERY+1

MAG_INFINITE = $ff

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
                dc.b 0                          ;Grenade
                dc.b 0                          ;Mine
                dc.b 0                          ;Medikit
                dc.b 0                          ;Battery

itemDefaultMaxCount:
                dc.b 1                          ;Fists
                dc.b 1                          ;Knife
                dc.b 1                          ;Nightstick
                dc.b 1                          ;Bat
                dc.b 50                         ;Pistol
                dc.b 32                         ;Shotgun
                dc.b 90                         ;Auto rifle
                dc.b 15                         ;Sniper rifle
                dc.b 100                        ;Minigun
                dc.b 90                         ;Flamethrower
                dc.b 45                         ;Laser rifle
                dc.b 30                         ;Plasma gun
                dc.b 8                          ;EMP generator
                dc.b 6                          ;Grenade launcher
                dc.b 4                          ;Bazooka
                dc.b 5                          ;Grenade
                dc.b 3                          ;Mine
                dc.b 2                          ;Medikit
                dc.b 2                          ;Battery

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
                dc.b 0                          ;Grenade
                dc.b 0                          ;Mine
                dc.b 0                          ;Medikit
                dc.b 0                          ;Battery

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
                dc.b 2                          ;Grenade launcher
                dc.b 2                          ;Bazooka
                dc.b 2                          ;Grenade
                dc.b 2                          ;Mine
                dc.b 1                          ;Medikit
                dc.b 1                          ;Battery

itemNPCMinDist: dc.b 0                          ;Fists
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
                dc.b 2                          ;Grenade
                dc.b 2                          ;Mine (not used by NPCs)

itemNPCMaxDist: dc.b 1                          ;Fists
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
                dc.b 6                          ;Grenade
                dc.b 2                          ;Mine (not used by NPCs)

itemNPCAttackLength:                            ;Note: stored as negative
                dc.b -6/2                       ;Fists
                dc.b -6/2                       ;Knife
                dc.b -6/2                       ;Nightstick
                dc.b -6/2                       ;Bat
                dc.b -6/2                       ;Pistol
                dc.b -6/2                       ;Shotgun
                dc.b -10/2                      ;Auto rifle
                dc.b -6/2                       ;Sniper rifle
                dc.b -10/2                      ;Minigun
                dc.b -10/2                      ;Flamethrower
                dc.b -10/2                      ;Laser rifle
                dc.b -6/2                       ;Plasma gun
                dc.b -6/2                       ;EMP generator (not used by NPCs)
                dc.b -6/2                       ;Grenade launcher
                dc.b -6/2                       ;Bazooka
                dc.b -6/2                       ;Grenade
                dc.b -6/2                       ;Mine (not used by NPCs)

itemNPCAttackThreshold:
                dc.b $08                        ;Fists
                dc.b $0c                        ;Knife
                dc.b $0e                        ;Nightstick
                dc.b $10                        ;Bat
                dc.b $20                        ;Pistol
                dc.b $30                        ;Shotgun
                dc.b $20                        ;Auto rifle
                dc.b $38                        ;Sniper rifle
                dc.b $30                        ;Minigun
                dc.b $30                        ;Flamethrower
                dc.b $20                        ;Laser rifle
                dc.b $28                        ;Plasma gun
                dc.b $20                        ;EMP generator (not used by NPCs)
                dc.b $40                        ;Grenade launcher
                dc.b $50                        ;Bazooka
                dc.b $40                        ;Grenade
                dc.b $40                        ;Mine (not used by NPCs)
