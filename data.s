        ; Script code area

scriptCodeStart:ds.b SCRIPTAREASIZE,0

        ; Game data

                org (* + $ff) & $ff00

scriptCodeEnd:

        ; Sprite cache / depacking tables

        ; Next slice lowbyte table for sprite depacking. Interleaved with data to not waste memory,
        ; each empty space is 15 bytes.

nextSliceTbl:   dc.b 1,2,21
flipNextSliceTbl:dc.b 24,1,2

sprIrqJumpTbl:  dc.b <Irq2_Spr0,<Irq2_Spr1,<Irq2_Spr2,<Irq2_Spr3,<Irq2_Spr4,<Irq2_Spr5,<Irq2_Spr6,<Irq2_Spr7
screenFrameTbl: dc.b >(screen1+$3f8),>(screen2+$3f8)
screenBaseTbl:  dc.b >screen1, >screen2
colorSrcTbl:    dc.b 37,38,1

                org nextSliceTbl+21
                dc.b 22,23,42
                dc.b 45,22,23

sprIrqAdvanceTbl:
                dc.b -2,-3,-4,-5,-7,-8,-9,-10
screenJumpTblLo:dc.b <SW_Shift1
                dc.b <SW_Shift2
screenJumpTblHi:dc.b >SW_Shift1
                dc.b >SW_Shift2
colorDestTbl:   dc.b 38,38,0

                org nextSliceTbl+42
                dc.b 43,44,0
                dc.b 0,43,44

blockRightTbl:  dc.b $01,$02,$03,$80
                dc.b $05,$06,$07,$84
                dc.b $09,$0a,$0b,$88
                dc.b $0d,$0e,$0f,$8c

                org nextSliceTbl+$40
                dc.b $40+1,$40+2,$40+21
                dc.b $40+24,$40+1,$40+2

shiftDestTbl:   dc.b 38,38,37
                dc.b 38,38,37
                dc.b 38,38,37
colorXTbl:      dc.b $ca,$ca,$e8
colorSideTbl:   dc.b 0,-1,38

                org nextSliceTbl+$40+21
                dc.b $40+22,$40+23,$40+42
                dc.b $40+45,$40+22,$40+23

coordTblLo:
N               set -32
                repeat MAX_ACTX
                dc.b <N
N               set N+32
                repend

                org nextSliceTbl+$40+42
                dc.b $40+43,$40+44,0
                dc.b 0,$40+43,$40+44

blockDownTbl:   dc.b $04,$05,$06,$07
                dc.b $08,$09,$0a,$0b
                dc.b $0c,$0d,$0e,$0f
                dc.b $80,$81,$82,$83

                org nextSliceTbl+$80
                dc.b $80+1,$80+2,$80+21
                dc.b $80+24,$80+1,$80+2

coordTblHi:
N               set -32
                repeat MAX_ACTX
                dc.b >N
N               set N+32
                repend

                org nextSliceTbl+$80+21
                dc.b $80+22,$80+23,$80+42
                dc.b $80+45,$80+22,$80+23

shiftSrcTbl:    dc.b 37,38,38
                dc.b 77,78,78
                dc.b 117,118,118
colorEndTbl:    dc.b -1,-1,39
colorYTbl:      dc.b $88,$88,$c8

                org nextSliceTbl+$80+42
                dc.b $80+43,$80+44,0
                dc.b 0,$80+43,$80+44

moveCtrlAndTbl: dc.b $ff-JOY_LEFT-JOY_RIGHT-JOY_UP-JOY_DOWN ;None
                dc.b $ff-JOY_DOWN-JOY_LEFT-JOY_RIGHT ;Up
                dc.b $ff-JOY_UP-JOY_LEFT-JOY_RIGHT ;Down
                dc.b $ff-JOY_UP-JOY_DOWN-JOY_LEFT-JOY_RIGHT ;Up+Down
                dc.b $ff-JOY_RIGHT-JOY_UP-JOY_DOWN ;Left
                dc.b $ff-JOY_RIGHT-JOY_DOWN     ;Left+Up
                dc.b $ff-JOY_RIGHT-JOY_UP       ;Left+Down
                dc.b $ff-JOY_RIGHT-JOY_UP-JOY_DOWN ;Left+Up+Down
                dc.b $ff-JOY_LEFT-JOY_UP-JOY_DOWN ;Right
                dc.b $ff-JOY_LEFT-JOY_DOWN      ;Right+Up
                dc.b $ff-JOY_LEFT-JOY_UP        ;Right+Down
                dc.b $ff-JOY_LEFT-JOY_UP-JOY_DOWN ;Right+Up+Down
                dc.b $ff-JOY_LEFT-JOY_RIGHT-JOY_UP-JOY_DOWN     ;Right+Left
                dc.b $ff-JOY_LEFT-JOY_RIGHT-JOY_DOWN ;Right+Left+Up
                dc.b $ff-JOY_LEFT-JOY_RIGHT-JOY_UP ;Right+Left+Down
                dc.b $ff-JOY_LEFT-JOY_RIGHT-JOY_UP-JOY_DOWN ;Right+Left+Up+Down

                org nextSliceTbl+$c0
                dc.b $c0+1,$c0+2,$c0+21
                dc.b $c0+24,$c0+1,$c0+2

colorJumpTblLo: dc.b <SW_ShiftColorsUp
                dc.b <SW_ShiftColorsUp
                dc.b <SW_ShiftColorsUp
                dc.b <SW_ShiftColorsHoriz
                dc.b <SW_NoWork
                dc.b <SW_ShiftColorsHoriz
                dc.b <SW_ShiftColorsDown
                dc.b <SW_ShiftColorsDown
                dc.b <SW_ShiftColorsDown

d018Tbl:        dc.b GAMESCR1_D018,GAMESCR2_D018,PANEL_D018,GAMESCR1_D018+1

                org nextSliceTbl+$c0+21
                dc.b $c0+22,$c0+23,$c0+42
                dc.b $c0+45,$c0+22,$c0+23

colorJumpTblHi: dc.b >SW_ShiftColorsUp
                dc.b >SW_ShiftColorsUp
                dc.b >SW_ShiftColorsUp
                dc.b >SW_ShiftColorsHoriz
                dc.b >SW_NoWork
                dc.b >SW_ShiftColorsHoriz
                dc.b >SW_ShiftColorsDown
                dc.b >SW_ShiftColorsDown
                dc.b >SW_ShiftColorsDown

menuUpdateTblLo:dc.b <UM_None
                dc.b <UM_Inventory
                dc.b <UM_SkillDisplay
                dc.b <UM_LevelUpMsg
                dc.b <UM_LevelUpChoice
                dc.b <UM_PauseMenu

                org nextSliceTbl+$c0+42
                dc.b $c0+43,$c0+44,0
                dc.b 0,$c0+43,$c0+44

shiftEndTbl:    dc.b $f0,$30,$30
                dc.b $f0,$30,$30
                dc.b $f0,$30,$30

menuUpdateTblHi:dc.b >UM_None
                dc.b >UM_Inventory
                dc.b >UM_SkillDisplay
                dc.b >UM_LevelUpMsg
                dc.b >UM_LevelUpChoice
                dc.b >UM_PauseMenu

                org nextSliceTbl+$100

        ; Sprite flipping table

flipTbl:        dc.b %00000000,%01000000,%10000000,%11000000,%00010000,%01010000,%10010000,%11010000,%00100000,%01100000,%10100000,%11100000,%00110000,%01110000,%10110000,%11110000
                dc.b %00000100,%01000100,%10000100,%11000100,%00010100,%01010100,%10010100,%11010100,%00100100,%01100100,%10100100,%11100100,%00110100,%01110100,%10110100,%11110100
                dc.b %00001000,%01001000,%10001000,%11001000,%00011000,%01011000,%10011000,%11011000,%00101000,%01101000,%10101000,%11101000,%00111000,%01111000,%10111000,%11111000
                dc.b %00001100,%01001100,%10001100,%11001100,%00011100,%01011100,%10011100,%11011100,%00101100,%01101100,%10101100,%11101100,%00111100,%01111100,%10111100,%11111100
                dc.b %00000001,%01000001,%10000001,%11000001,%00010001,%01010001,%10010001,%11010001,%00100001,%01100001,%10100001,%11100001,%00110001,%01110001,%10110001,%11110001
                dc.b %00000101,%01000101,%10000101,%11000101,%00010101,%01010101,%10010101,%11010101,%00100101,%01100101,%10100101,%11100101,%00110101,%01110101,%10110101,%11110101
                dc.b %00001001,%01001001,%10001001,%11001001,%00011001,%01011001,%10011001,%11011001,%00101001,%01101001,%10101001,%11101001,%00111001,%01111001,%10111001,%11111001
                dc.b %00001101,%01001101,%10001101,%11001101,%00011101,%01011101,%10011101,%11011101,%00101101,%01101101,%10101101,%11101101,%00111101,%01111101,%10111101,%11111101
                dc.b %00000010,%01000010,%10000010,%11000010,%00010010,%01010010,%10010010,%11010010,%00100010,%01100010,%10100010,%11100010,%00110010,%01110010,%10110010,%11110010
                dc.b %00000110,%01000110,%10000110,%11000110,%00010110,%01010110,%10010110,%11010110,%00100110,%01100110,%10100110,%11100110,%00110110,%01110110,%10110110,%11110110
                dc.b %00001010,%01001010,%10001010,%11001010,%00011010,%01011010,%10011010,%11011010,%00101010,%01101010,%10101010,%11101010,%00111010,%01111010,%10111010,%11111010
                dc.b %00001110,%01001110,%10001110,%11001110,%00011110,%01011110,%10011110,%11011110,%00101110,%01101110,%10101110,%11101110,%00111110,%01111110,%10111110,%11111110
                dc.b %00000011,%01000011,%10000011,%11000011,%00010011,%01010011,%10010011,%11010011,%00100011,%01100011,%10100011,%11100011,%00110011,%01110011,%10110011,%11110011
                dc.b %00000111,%01000111,%10000111,%11000111,%00010111,%01010111,%10010111,%11010111,%00100111,%01100111,%10100111,%11100111,%00110111,%01110111,%10110111,%11110111
                dc.b %00001011,%01001011,%10001011,%11001011,%00011011,%01011011,%10011011,%11011011,%00101011,%01101011,%10101011,%11101011,%00111011,%01111011,%10111011,%11111011
                dc.b %00001111,%01001111,%10001111,%11001111,%00011111,%01011111,%10011111,%11011111,%00101111,%01101111,%10101111,%11101111,%00111111,%01111111,%10111111,%11111111

        ; Char slope table

slopeTbl:       dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;Slope 0
                dc.b $38,$30,$28,$20,$18,$10,$08,$00    ;Slope 1
                dc.b $38,$38,$30,$30,$28,$28,$20,$20    ;Slope 2
                dc.b $18,$18,$10,$10,$08,$08,$00,$00    ;Slope 3
                dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;Slope 4 (unused)
                dc.b $00,$08,$10,$18,$20,$28,$30,$38    ;Slope 5
                dc.b $00,$00,$08,$08,$10,$10,$18,$18    ;Slope 6
                dc.b $20,$20,$28,$28,$30,$30,$38,$38    ;Slope 7

keyRowBit:      dc.b $fe,$fd,$fb,$f7,$ef,$df,$bf,$7f

d015Tbl:        dc.b $00,$80,$c0,$e0,$f0,$f8,$fc,$fe,$ff

        ; Data with non-critical alignment

                include paneldata.s
                include actordata.s
                include itemdata.s
                include weapondata.s
                include leveldata.s
                include aidata.s
                include sounddata.s
                include text.s

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
actHp:          ds.b MAX_ACT,0
actMB:          ds.b MAX_ACT,0
actAuxData:     ds.b MAX_ACT,0
actAITarget:    ds.b MAX_ACT,0
actLvlDataPos:  ds.b MAX_PERSISTENTACT,0
actLvlDataOrg:  ds.b MAX_PERSISTENTACT,0
actCtrl:        ds.b MAX_COMPLEXACT,0
actMoveCtrl:    ds.b MAX_COMPLEXACT,0
actPrevCtrl:    ds.b MAX_COMPLEXACT,0
actFall:        ds.b MAX_COMPLEXACT,0
actFallL:       ds.b MAX_COMPLEXACT,0
actF2:          ds.b MAX_COMPLEXACT,0
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
lvlSpawnT:      ds.b MAX_SPAWNERS,0
lvlSpawnWpn:    ds.b MAX_SPAWNERS,0
lvlSpawnPlot:   ds.b MAX_SPAWNERS,0

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
plotBits:       ds.b MAX_PLOTBITS/8,0
lvlDataActBits: ds.b LVLDATAACTTOTALSIZE,0
lvlActX:        ds.b MAX_LVLACT,0
lvlActY:        ds.b MAX_LVLACT,0
lvlActF:        ds.b MAX_LVLACT,0
lvlActT:        ds.b MAX_LVLACT,0
lvlActWpn:      ds.b MAX_LVLACT,0
lvlActOrg:      ds.b MAX_LVLACT,0
playerStateEnd:

        ; In-memory checkpoint save

saveStateStart:
saveLvlName:    ds.b 16,0
saveStateZP:    ds.b playerStateZPEnd - playerStateZPStart,0
saveState:      ds.b playerStateEnd - playerStateStart,0
saveXL:         dc.b 0
saveXH:         dc.b 0
saveYL:         dc.b 0
saveYH:         dc.b 0
saveT:          dc.b 0
saveD:          dc.b 0
saveStateEnd:

        ; Other variables

saveSlotChoice: dc.b 0

        ; Dynamic memory allocation area begins here

fileAreaStart:
