        ; This file is programmatically generated from leveldata (countobj utility)

                include levelactors.s

        ; Check for size exceeded. The game start script does not handle
        ; more than 255 bytes for the bitareas

                if LVLDATAACTTOTALSIZE > 255
                    err
                endif

                if LVLOBJTOTALSIZE > 255
                    err
                endif

        ; Player/world state

playerStateStart:
invType:        ds.b MAX_INVENTORYITEMS,0
invCount:       ds.b MAX_INVENTORYITEMS,0
invMag:         ds.b MAX_INVENTORYITEMS,0
plrSkills:
        ; TODO: refactor with binary updates
plrAgility:     dc.b 0
plrCarrying:    dc.b 0
plrFirearms:    dc.b 0
plrMelee:       dc.b 0
plrVitality:    dc.b 0
plrReload:      dc.b 0
plrAppearance:  dc.b 0
scriptF:        dc.b $ff
scriptEP:       dc.b 0
plotBits:       ds.b MAX_PLOTBITS/8,0
atType:         ds.b MAX_ACTORTRIGGERS+1,0
atScriptF:      ds.b MAX_ACTORTRIGGERS,0
atScriptEP:     ds.b MAX_ACTORTRIGGERS,0
atMask:         ds.b MAX_ACTORTRIGGERS,0
lvlDataActBits: ds.b LVLDATAACTTOTALSIZE,0
lvlObjBits:     ds.b LVLOBJTOTALSIZE,0
                if OPTIMIZE_SAVE>0
playerStateEnd:
                endif
lvlActX:        ds.b MAX_LVLACT,0
lvlActY:        ds.b MAX_LVLACT,0
lvlActF:        ds.b MAX_LVLACT,0
lvlActT:        ds.b MAX_LVLACT,0
lvlActWpn:      ds.b MAX_LVLACT,0
lvlActOrg:      ds.b MAX_LVLACT,0
                if OPTIMIZE_SAVE=0
playerStateEnd:
                endif

        ; In-memory checkpoint save

saveStateStart:
saveLvlName:    ds.b 16,0
saveStateZP:    ds.b playerStateZPEnd - playerStateZPStart,0
saveState:      ds.b playerStateEnd - playerStateStart,0
                if OPTIMIZE_SAVE>0
saveLvlActX:    ds.b MAX_GLOBALACT,0
saveLvlActY:    ds.b MAX_GLOBALACT,0
saveLvlActF:    ds.b MAX_GLOBALACT,0
saveLvlActT:    ds.b MAX_GLOBALACT,0
saveLvlActWpn:  ds.b MAX_GLOBALACT,0
saveLvlActOrg:  ds.b MAX_GLOBALACT,0
                endif
saveXL:         dc.b 0
saveXH:         dc.b 0
saveYL:         dc.b 0
saveYH:         dc.b 0
saveT:          dc.b 0
saveD:          dc.b 0
saveStateEnd:
