        ; AI jumptable

aiJumpTblLo:    dc.b <AI_Idle
                dc.b <AI_TurnTo
                dc.b <AI_Follow
                dc.b <AI_Sniper

aiJumpTblHi:    dc.b >AI_Idle
                dc.b >AI_TurnTo
                dc.b >AI_Follow
                dc.b >AI_Sniper

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
