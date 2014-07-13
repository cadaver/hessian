        ; AI jumptable

aiJumpTblLo:    dc.b <AI_Idle
                dc.b <AI_TurnTo
                dc.b <AI_Follow
                dc.b <AI_Sniper

aiJumpTblHi:    dc.b >AI_Idle
                dc.b >AI_TurnTo
                dc.b >AI_Follow
                dc.b >AI_Sniper

routeCtrlTbl:   dc.b JOY_UP
                dc.b JOY_DOWN
                dc.b JOY_LEFT
                dc.b JOY_RIGHT