ITEM_NONE       = 0
ITEM_FISTS      = 1
ITEM_KNIFE      = 2
ITEM_PISTOL     = 3
ITEM_SHOTGUN    = 4
ITEM_GRENADE    = 5
ITEM_MEDKIT     = 6

ITEM_FIRST_CONSUMABLE = ITEM_GRENADE
ITEM_FIRST_NONWEAPON = ITEM_MEDKIT

MAG_INFINITE = $ff

itemMaxCount:   dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0

itemDefaultMaxCount:
                dc.b 1
                dc.b 1
                dc.b 40
                dc.b 18
                dc.b 4
                dc.b 2

itemMaxCountAdd:dc.b 0
                dc.b 0
                dc.b 10
                dc.b 6
                dc.b 2
                dc.b 1

itemDefaultPickup:
                dc.b 1
                dc.b 1
                dc.b 10
                dc.b 6
                dc.b 2
                dc.b 1

itemMagazineSize:
                dc.b MAG_INFINITE
                dc.b MAG_INFINITE
                dc.b 10
                dc.b 6
                dc.b 0
                dc.b 0

itemNPCMinDist: dc.b 0
                dc.b 0
                dc.b 1
                dc.b 1
                dc.b 2

itemNPCMaxDist: dc.b 1
                dc.b 1
                dc.b 6
                dc.b 6
                dc.b 6

itemNPCAttackLength:
                dc.b -6/2                       ;Note: stored as negative
                dc.b -6/2
                dc.b -6/2
                dc.b -6/2
                dc.b -6/2

itemNPCAttackThreshold:
                dc.b $08
                dc.b $0c
                dc.b $20
                dc.b $30
                dc.b $40
