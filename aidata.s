        ; AI jumptable

aiJumpTblLo:    dc.b <AI_TurnTo
                dc.b <AI_Follow
                dc.b <AI_Sniper
                dc.b <AI_Mover
                dc.b <AI_Guard
                dc.b <AI_Berzerk
                dc.b <AI_Flyer
                dc.b <AI_Animal
                dc.b <AI_FreeMoveWithTurn
                dc.b <AI_FlyerIdle
                dc.b <AI_Fish

aiJumpTblHi:    dc.b >AI_TurnTo
                dc.b >AI_Follow
                dc.b >AI_Sniper
                dc.b >AI_Mover
                dc.b >AI_Guard
                dc.b >AI_Berzerk
                dc.b >AI_Flyer
                dc.b >AI_Animal
                dc.b >AI_FreeMoveWithTurn
                dc.b >AI_FlyerIdle
                dc.b >AI_Fish

flyerDirTbl:    dc.b JOY_RIGHT|JOY_UP
                dc.b JOY_LEFT|JOY_UP
                dc.b JOY_RIGHT|JOY_DOWN
                dc.b JOY_LEFT|JOY_DOWN

        ; Spawn list entry selection tables

spawnListAndTbl:dc.b $01                        ;0: entry 0

spawnListAddTbl:dc.b $00                        ;0: entry 0

        ; Spawn list entries

spawnTypeTbl:   dc.b ACT_GUARD                  ;0
                dc.b ACT_HEAVYGUARD             ;1

spawnPlotTbl:   dc.b NOPLOTBIT                  ;0
                dc.b NOPLOTBIT                  ;1

spawnWpnTbl:    dc.b ITEM_SHOTGUN               ;0
                dc.b ITEM_AUTORIFLE             ;0
