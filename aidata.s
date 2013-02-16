        ; AI jumptable

aiJumpTblLo:    dc.b <AI_Sniper
                dc.b <AI_Thug

aiJumpTblHi:    dc.b >AI_Sniper
                dc.b >AI_Thug

targetListAndTbl:
                dc.b 0                          ;1 potential targets
                dc.b 1                          ;2 potential targets
                dc.b 3                          ;3 potential targets
                dc.b 3                          ;4 potential targets
                dc.b 7                          ;5 potential targets
                dc.b 7                          ;6 potential targets

        ; Item drop table

ITEM_OWNWEAPON = 0
DROP_WEAPON = $80
DROP_WEAPONMEDKIT = $81
DROP_WEAPONMEDKITCREDITS = $82

itemDropTable:  dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_MEDKIT
                dc.b ITEM_CREDITS
