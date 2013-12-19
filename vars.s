                org scriptCodeEnd

        ; Playroutine variables

ntChnPattPos:   dc.b 0
ntChnCounter:   dc.b 0
ntChnNewNote:   dc.b 0
ntChnWavePos:   dc.b 0
ntChnPulsePos:  dc.b 0
ntChnWave:      dc.b 0
ntChnPulse:     dc.b 0

                dc.b 0,0,0,0,0,0,0
                dc.b 0,0,0,0,0,0,0

ntChnGate:      dc.b $fe
ntChnTrans:     dc.b $ff
ntChnCmd:       dc.b $01
ntChnSongPos:   dc.b 0
ntChnPattNum:   dc.b 0
ntChnDuration:  dc.b 0
ntChnNote:      dc.b 0

                dc.b $fe,$ff,$01,0,0,0,0
                dc.b $fe,$ff,$01,0,0,0,0

ntChnFreqLo:    dc.b 0
ntChnFreqHi:    dc.b 0
ntChnWaveTime:  dc.b 0
ntChnPulseTime: dc.b 0
ntChnSfx:       dc.b 0
ntChnSfxLo:     dc.b 0
ntChnSfxHi:
ntChnWaveOld:   dc.b 0

                dc.b 0,0,0,0,0,0,0
                dc.b 0,0,0,0,0,0,0

        ; Sprite variables

sortSprY:       ds.b MAX_SPR*2,0
sortSprX:       ds.b MAX_SPR*2,0
sortSprD010:    ds.b MAX_SPR*2,0
sortSprF:       ds.b MAX_SPR*2,0
sortSprC:       ds.b MAX_SPR*2,0
sprIrqLine:     ds.b MAX_SPR*2,0

        ; Chunk-file memory allocation variables

fileLo:         ds.b MAX_CHUNKFILES,0
fileHi:         ds.b MAX_CHUNKFILES,0
fileNumObjects: ds.b MAX_CHUNKFILES,0
fileAge:        ds.b MAX_CHUNKFILES,0

        ; Actor variables

actXL:          ds.b MAX_ACT,0
actXH:          ds.b MAX_ACT,0
actYL:          ds.b MAX_ACT,0
actYH:          ds.b MAX_ACT,0
actT:           ds.b MAX_ACT,0
actD:           ds.b MAX_ACT,0
actHp:          ds.b MAX_ACT,0
actF1:          ds.b MAX_ACT,0
actFd:          ds.b MAX_ACT,0
actC:           ds.b MAX_ACT,0
actSX:          ds.b MAX_ACT,0
actSY:          ds.b MAX_ACT,0
actPrevXL:      ds.b MAX_ACT,0
actPrevXH:      ds.b MAX_ACT,0
actPrevYL:      ds.b MAX_ACT,0
actPrevYH:      ds.b MAX_ACT,0
actFlags:       ds.b MAX_ACT,0
actSizeH:       ds.b MAX_ACT,0
actSizeU:       ds.b MAX_ACT,0
actSizeD:       ds.b MAX_ACT,0
actTime:        ds.b MAX_ACT,0
actMB:          ds.b MAX_ACT,0
actAuxData:     ds.b MAX_ACT,0
actAITarget:    ds.b MAX_ACT,0
actLvlDataPos:  ds.b MAX_PERSISTENTACT,0
actLvlDataOrg:  ds.b MAX_PERSISTENTACT,0
actF2:          ds.b MAX_COMPLEXACT,0
actCtrl:        ds.b MAX_COMPLEXACT,0
actMoveCtrl:    ds.b MAX_COMPLEXACT,0
actPrevCtrl:    ds.b MAX_COMPLEXACT,0
actFall:        ds.b MAX_COMPLEXACT,0
actFallL:       ds.b MAX_COMPLEXACT,0
actWaterDamage: ds.b MAX_COMPLEXACT,0
actWpn:         ds.b MAX_COMPLEXACT,ITEM_NONE
actWpnF:        ds.b MAX_COMPLEXACT,$ff
actAttackD:     ds.b MAX_COMPLEXACT,0
actAIMode:      ds.b MAX_COMPLEXACT,0
actAIHelp:      ds.b MAX_COMPLEXACT,0

        ; Level objects and spawner data (not saved)

lvlObjX:        ds.b MAX_LVLOBJ,0
lvlObjY:        ds.b MAX_LVLOBJ,0
lvlObjB:        ds.b MAX_LVLOBJ,0
lvlObjDL:       ds.b MAX_LVLOBJ,0
lvlObjDH:       ds.b MAX_LVLOBJ,0
lvlObjR:        ds.b MAX_LVLOBJ,0
lvlSpawnT:      ds.b MAX_SPAWNERS,0
lvlSpawnWpn:    ds.b MAX_SPAWNERS,0
lvlSpawnPlot:   ds.b MAX_SPAWNERS,0

lvlPropertiesStart:
lvlName:        ds.b 16,0
lvlWaterSplashColor:
                dc.b 0
lvlWaterDamage: dc.b 0
lvlPropertiesEnd:

        ; Player/world state

playerStateStart:
invType:        ds.b MAX_INVENTORYITEMS,0
invCount:       ds.b MAX_INVENTORYITEMS,0
invMag:         ds.b MAX_INVENTORYITEMS,0
plrSkills:
plrAgility:     dc.b 0
plrCarrying:    dc.b 0
plrFirearms:    dc.b 0
plrMelee:       dc.b 0
plrVitality:    dc.b 0
plrReload:      dc.b 0
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

        ; Other variables

saveSlotChoice: dc.b 0
improveList:    ds.b NUM_SKILLS+1,0
targetList:     ds.b MAX_COMPLEXACT+1,0

        ; Dynamic memory allocation area begins here

fileAreaStart:
