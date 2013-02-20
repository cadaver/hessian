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

DROP_WEAPONCREDITS = $80
DROP_WEAPON = $81
DROP_WEAPONMEDKIT = $82
DROP_WEAPONMEDKITCREDITS = $84
DROPTABLERANDOM = 8                             ;Pick random choice from 8 consecutive indices

itemDropTable:  dc.b ITEM_CREDITS
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_MEDKIT
                dc.b ITEM_CREDITS
                dc.b ITEM_CREDITS
