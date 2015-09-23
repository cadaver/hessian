ITEM_OWNWEAPON = 0
DROP_WEAPONMEDKIT = $80
DROP_WEAPON     = $81
DROP_WEAPONBATTERY = $82
DROP_WEAPONBATTERYMEDKIT = $83
DROP_WEAPONBATTERYMEDKITHIGHPROB = $84
DROPTABLERANDOM = 16                             ;Pick random choice from 16 consecutive indices

        ; AI jumptable

aiJumpTblLo:    dc.b <AI_Idle
                dc.b <AI_TurnTo
                dc.b <AI_Follow
                dc.b <AI_Sniper
                dc.b <AI_Mover

aiJumpTblHi:    dc.b >AI_Idle
                dc.b >AI_TurnTo
                dc.b >AI_Follow
                dc.b >AI_Sniper
                dc.b >AI_Mover

        ; Spawn list parameters

spawnListAndTbl:dc.b $00                        ;Entry 0

spawnListAddTbl:dc.b $00                        ;Entry 0

spawnTypeTbl:   dc.b ACT_TESTENEMY              ;0

spawnPlotTbl:   dc.b NOPLOTBIT                  ;0

spawnWpnTbl:    dc.b ITEM_AUTORIFLE             ;0

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