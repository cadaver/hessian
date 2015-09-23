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