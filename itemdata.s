ITEM_NONE       = 0
ITEM_FISTS      = 1
ITEM_KNIFE      = 2
ITEM_PISTOL     = 3
ITEM_GRENADE    = 4
ITEM_MEDKIT     = 5

ITEM_FIRST_CONSUMABLE = ITEM_GRENADE
ITEM_FIRST_NONWEAPON = ITEM_MEDKIT

itemNameLo:     dc.b <txtFists
                dc.b <txtKnife
                dc.b <txtPistol
                dc.b <txtGrenade
                dc.b <txtFirstAidKit

itemNameHi:     dc.b >txtFists
                dc.b >txtKnife
                dc.b >txtPistol
                dc.b >txtGrenade
                dc.b >txtFirstAidKit

itemMaxCount:   dc.b 1
                dc.b 1
                dc.b 100
                dc.b 10
                dc.b 2

itemDefaultPickup:
                dc.b 1
                dc.b 1
                dc.b 12
                dc.b 2
                dc.b 1

itemMagazineSize:
                dc.b $ff
                dc.b $ff
                dc.b 12
                dc.b 0
                dc.b 0
                
itemNPCMinDist: dc.b 0
                dc.b 0
                dc.b 1
                dc.b 2

itemNPCMaxDist: dc.b 1
                dc.b 1
                dc.b 6
                dc.b 6

itemNPCAttackLength:
                dc.b 6/2
                dc.b 6/2
                dc.b 6/2
                dc.b 6/2

