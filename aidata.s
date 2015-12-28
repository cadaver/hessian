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

spawnListAndTbl:dc.b $01                        ;0: entries 0-1 (first courtyard)
                dc.b $03                        ;1: entries 1-4 (entrance)
                dc.b $03                        ;2: entries 4-7 (service tunnels)

spawnListAddTbl:dc.b $00                        ;0: entries 0-1 (first courtyard)
                dc.b $01                        ;1: entries 1-4 (entrance)
                dc.b $04                        ;2: entries 4-7 (service tunnels)

        ; Spawn list entries

spawnTypeTbl:   dc.b ACT_SMALLWALKER            ;0
                dc.b ACT_SMALLDROID             ;1
                dc.b ACT_COMBATROBOT            ;2
                dc.b ACT_COMBATROBOT            ;3
                dc.b ACT_COMBATROBOT            ;4
                dc.b ACT_RAT                    ;5
                dc.b ACT_SMALLDROID             ;6
                dc.b ACT_COMBATROBOT            ;7

spawnPlotTbl:   dc.b NOPLOTBIT                  ;0
                dc.b NOPLOTBIT                  ;1
                dc.b NOPLOTBIT                  ;2
                dc.b NOPLOTBIT                  ;3
                dc.b NOPLOTBIT                  ;4
                dc.b NOPLOTBIT                  ;5
                dc.b NOPLOTBIT                  ;6
                dc.b NOPLOTBIT                  ;7

spawnWpnTbl:    dc.b ITEM_AUTORIFLE             ;0
                dc.b ITEM_PISTOL|SPAWN_AIR      ;1
                dc.b ITEM_NIGHTSTICK            ;2
                dc.b ITEM_PISTOL                ;3
                dc.b ITEM_SHOTGUN               ;4
                dc.b ITEM_ANIMALBITE            ;5
                dc.b ITEM_MINIGUN|SPAWN_AIR     ;6
                dc.b ITEM_AUTORIFLE             ;7
