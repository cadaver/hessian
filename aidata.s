ITEM_OWNWEAPON = 0
DROP_WEAPONMEDKIT = $80
DROP_WEAPON     = $81
DROP_WEAPONBATTERY = $82
DROP_WEAPONBATTERYMEDKIT = $83
DROP_WEAPONBATTERYMEDKITHIGHPROB = $84
DROPTABLERANDOM = 16                             ;Pick random choice from 16 consecutive indices

        ; Enemy random item drops

itemDropTable:  dc.b ITEM_MEDKIT
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_OWNWEAPON
                dc.b ITEM_BATTERY
                dc.b ITEM_MEDKIT
                dc.b ITEM_MEDKIT

        ; AI jumptable

aiJumpTblLo:    dc.b <AI_Idle
                dc.b <AI_TurnTo
                dc.b <AI_Follow
                dc.b <AI_Sniper
                dc.b <AI_Mover
                dc.b <AI_Guard

aiJumpTblHi:    dc.b >AI_Idle
                dc.b >AI_TurnTo
                dc.b >AI_Follow
                dc.b >AI_Sniper
                dc.b >AI_Mover
                dc.b >AI_Guard

        ; Spawn list entry selection tables

spawnListAndTbl:dc.b $00                        ;0: entry 0

spawnListAddTbl:dc.b $00                        ;0: entry 0

        ; Spawn list entries

spawnTypeTbl:   dc.b ACT_TESTENEMY              ;0

spawnPlotTbl:   dc.b NOPLOTBIT                  ;0

spawnWpnTbl:    dc.b ITEM_PISTOL            ;0
