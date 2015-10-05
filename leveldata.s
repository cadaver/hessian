        ; This file is programmatically generated from by worlded utility

                include bg/world.s

        ; Check for bitarea size exceeded

                if LVLDATAACTTOTALSIZE+LVLOBJTOTALSIZE > 255
                    err
                endif
        ; Player/world state

playerStateStart:
time:           ds.b 4,0
score:          ds.b 3,0
battery:        ds.b 2,0
oxygen:         dc.b 0
plotBits:       ds.b MAX_PLOTBITS/8,0
atType:         ds.b MAX_ACTORTRIGGERS+1,0
atScriptF:      ds.b MAX_ACTORTRIGGERS,0
atScriptEP:     ds.b MAX_ACTORTRIGGERS,0
atMask:         ds.b MAX_ACTORTRIGGERS,0
playerStateZeroEnd:
invMag:         ds.b ITEM_LAST_MAG-ITEM_FIRST_MAG+1,0
invCount:       ds.b ITEM_LAST-ITEM_FIRST+1,0
lastItemIndex:  dc.b 0
lvlStateBits:   ds.b LVLDATAACTTOTALSIZE+LVLOBJTOTALSIZE,0
playerStateEnd:

                if playerStateZeroEnd-playerStateStart > 255
                    err
                endif

        ; In-memory checkpoint save

saveStateStart:
saveState:      ds.b playerStateEnd - playerStateStart,0
saveStateZP:    ds.b playerStateZPEnd - playerStateZPStart,0
saveLvlActX:    ds.b MAX_SAVEACT,0
saveLvlActY:    ds.b MAX_SAVEACT,0
saveLvlActF:    ds.b MAX_SAVEACT,0
saveLvlActT:    ds.b MAX_SAVEACT,0
saveLvlActWpn:  ds.b MAX_SAVEACT,0
saveLvlActOrg:  ds.b MAX_SAVEACT,0
saveXL:         dc.b 0
saveXH:         dc.b 0
saveYL:         dc.b 0
saveYH:         dc.b 0
saveT:          dc.b 0
saveD:          dc.b 0
saveHP:         dc.b 0
saveStateEnd:

saveBattery     = saveState + battery - playerStateStart
