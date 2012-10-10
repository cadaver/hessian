menuUpdateTblLo:dc.b <UM_None
                dc.b <UM_Inventory
                dc.b <UM_SkillDisplay
                dc.b <UM_LevelUpMsg
                dc.b <UM_LevelUpChoice
                dc.b <UM_PauseMenu

menuUpdateTblHi:dc.b >UM_None
                dc.b >UM_Inventory
                dc.b >UM_SkillDisplay
                dc.b >UM_LevelUpMsg
                dc.b >UM_LevelUpChoice
                dc.b >UM_PauseMenu
                
menuRedrawTblLo:dc.b <UM_RedrawNone
                dc.b <UM_RedrawInventory
                dc.b <UM_RedrawSkillDisplay
                dc.b <UM_RedrawLevelUpMsg
                dc.b <UM_RedrawLevelUpChoice
                dc.b <UM_RedrawPauseMenu

menuRedrawTblHi:dc.b >UM_RedrawNone
                dc.b >UM_RedrawInventory
                dc.b >UM_RedrawSkillDisplay
                dc.b >UM_RedrawLevelUpMsg
                dc.b >UM_RedrawLevelUpChoice
                dc.b >UM_RedrawPauseMenu

pauseMenuArrowPosTbl:
                dc.b 8,21

