menuRedrawTblLo:dc.b <UM_RedrawNone
                dc.b <UM_RedrawInventory
                dc.b <UM_RedrawPauseMenu
                dc.b <UM_RedrawDialogue

menuRedrawTblHi:dc.b >UM_RedrawNone
                dc.b >UM_RedrawInventory
                dc.b >UM_RedrawPauseMenu
                dc.b >UM_RedrawDialogue

menuUpdateTblLo:dc.b <UM_None
                dc.b <UM_Inventory
                dc.b <UM_PauseMenu
                dc.b <UM_Dialogue

menuUpdateTblHi:dc.b >UM_None
                dc.b >UM_Inventory
                dc.b >UM_PauseMenu
                dc.b >UM_Dialogue

healthFlashTbl: dc.b $0d,$0f,$09