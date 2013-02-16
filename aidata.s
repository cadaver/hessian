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
