        ; Game data

                include paneldata.s
                include actordata.s
                include itemdata.s
                include weapondata.s
                include sounddata.s
                include aidata.s

        ; Sprite cache / depacking tables

        ; Next slice lowbyte table for sprite depacking. Interleaved with data to not waste memory,
        ; each empty space is 18 bytes.

nextSliceTbl:   dc.b 1,2,21

sprIrqJumpTbl:  dc.b <Irq2_Spr0,<Irq2_Spr1,<Irq2_Spr2,<Irq2_Spr3,<Irq2_Spr4,<Irq2_Spr5,<Irq2_Spr6,<Irq2_Spr7
sprIrqAdvanceTbl:
                dc.b -2,-3,-4,-5,-7,-8,-9,-10

                org nextSliceTbl+21
                dc.b 22,23,42

blockRightTbl:  dc.b $01,$02,$03,$80
                dc.b $05,$06,$07,$84
                dc.b $09,$0a,$0b,$88
                dc.b $0d,$0e,$0f,$8c
screenFrameTbl: dc.b >(screen1+$3f8),>(screen2+$3f8)

                org nextSliceTbl+42
                dc.b 43,44,0

blockDownTbl:   dc.b $04,$05,$06,$07
                dc.b $08,$09,$0a,$0b
                dc.b $0c,$0d,$0e,$0f
                dc.b $80,$81,$82,$83
screenBaseTbl:  dc.b >screen1, >screen2

                org nextSliceTbl+$40
                dc.b $40+1,$40+2,$40+21

shiftSrcTbl:    dc.b 37,38,38
                dc.b 77,78,78
                dc.b 117,118,118
shiftDestTbl:   dc.b 38,38,37
                dc.b 38,38,37
                dc.b 38,38,37

                org nextSliceTbl+$40+21
                dc.b $40+22,$40+23,$40+42

colorJumpTblLo: dc.b <SW_ShiftColorsUp
                dc.b <SW_ShiftColorsUp
                dc.b <SW_ShiftColorsUp
                dc.b <SW_ShiftColorsHoriz
                dc.b <SW_NoWork
                dc.b <SW_ShiftColorsHoriz
                dc.b <SW_ShiftColorsDown
                dc.b <SW_ShiftColorsDown
                dc.b <SW_ShiftColorsDown
colorJumpTblHi: dc.b >SW_ShiftColorsUp
                dc.b >SW_ShiftColorsUp
                dc.b >SW_ShiftColorsUp
                dc.b >SW_ShiftColorsHoriz
                dc.b >SW_NoWork
                dc.b >SW_ShiftColorsHoriz
                dc.b >SW_ShiftColorsDown
                dc.b >SW_ShiftColorsDown
                dc.b >SW_ShiftColorsDown

                org nextSliceTbl+$40+42
                dc.b $40+43,$40+44,0

screenJumpTblLo:dc.b <SW_Shift1
                dc.b <SW_Shift2
screenJumpTblHi:dc.b >SW_Shift1
                dc.b >SW_Shift2
shiftEndTbl:    dc.b $f0,$30,$30
                dc.b $f0,$30,$30
                dc.b $f0,$30,$30

                org nextSliceTbl+$80
                dc.b $80+1,$80+2,$80+21

colorSrcTbl:    dc.b 37,38,1
colorDestTbl:   dc.b 38,38,0
colorEndTbl:    dc.b -1,-1,39
colorYTbl:      dc.b $88,$88,$c8
colorXTbl:      dc.b $ca,$ca,$e8
colorSideTbl:   dc.b 0,-1,38

                org nextSliceTbl+$80+21
                dc.b $80+22,$80+23,$80+42

keyRowBit:      dc.b $fe,$fd,$fb,$f7,$ef,$df,$bf,$7f

d015Tbl:        dc.b $00,$80,$c0,$e0,$f0,$f8,$fc,$fe,$ff

                org nextSliceTbl+$80+42
                dc.b $80+43,$80+44,0

d018Tbl:        dc.b GAMESCR1_D018,GAMESCR2_D018,PANEL_D018

coordTblLo:
N               set -32
                repeat MAX_ACTX
                dc.b <N
N               set N+32
                repend

                org nextSliceTbl+$c0
                dc.b $c0+1,$c0+2,$c0+21

coordTblHi:
N               set -32
                repeat MAX_ACTX
                dc.b >N
N               set N+32
                repend

                org nextSliceTbl+$c0+21
                dc.b $c0+22,$c0+23,$c0+42

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

                org nextSliceTbl+$c0+42
                dc.b $c0+43,$c0+44,0

        ; Char slope table

slopeTbl:       dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;Slope 0
                dc.b $38,$30,$28,$20,$18,$10,$08,$00    ;Slope 1
                dc.b $38,$38,$30,$30,$28,$28,$20,$20    ;Slope 2
                dc.b $18,$18,$10,$10,$08,$08,$00,$00    ;Slope 3
                dc.b $00,$00,$00,$00,$00,$00,$00,$00    ;Slope 4 (unused)
                dc.b $00,$08,$10,$18,$20,$28,$30,$38    ;Slope 5
                dc.b $00,$00,$08,$08,$10,$10,$18,$18    ;Slope 6
                dc.b $20,$20,$28,$28,$30,$30,$38,$38    ;Slope 7

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

actT:           ds.b MAX_ACT,0
actF1:          ds.b MAX_ACT,0
actFd:          ds.b MAX_ACT,0
actC:           ds.b MAX_ACT,0
actD:           ds.b MAX_ACT,0
actXL:          ds.b MAX_ACT,0
actXH:          ds.b MAX_ACT,0
actYL:          ds.b MAX_ACT,0
actYH:          ds.b MAX_ACT,0
actSX:          ds.b MAX_ACT,0
actSY:          ds.b MAX_ACT,0
actPrevXL:      ds.b MAX_ACT,0
actPrevXH:      ds.b MAX_ACT,0
actPrevYL:      ds.b MAX_ACT,0
actPrevYH:      ds.b MAX_ACT,0
actGrp:         ds.b MAX_ACT,0
actOrg:         ds.b MAX_ACT,0
actLvlOrg:      ds.b MAX_ACT,0
actSizeH:       ds.b MAX_ACT,0
actSizeU:       ds.b MAX_ACT,0
actSizeD:       ds.b MAX_ACT,0
actTime:        ds.b MAX_ACT,0
actHp:          ds.b MAX_ACT,0
actMB:          ds.b MAX_ACT,0
actCtrl:        ds.b MAX_COMPLEXACT,0
actMoveCtrl:    ds.b MAX_COMPLEXACT,0
actPrevCtrl:    ds.b MAX_COMPLEXACT,0
actFall:        ds.b MAX_COMPLEXACT,0
actFallL:       ds.b MAX_COMPLEXACT,0
actF2:          ds.b MAX_COMPLEXACT,0
actWpn:         ds.b MAX_COMPLEXACT,WPN_NONE
actWpnF:        ds.b MAX_COMPLEXACT,$ff
actAttackD:     ds.b MAX_COMPLEXACT,0
actAIMode:      ds.b MAX_COMPLEXACT,0
actAIHelp:      ds.b MAX_COMPLEXACT,0
actAITarget:    ds.b MAX_COMPLEXACT,0
actAIRoute:     ds.b MAX_COMPLEXACT,0

        ; Player state

invType:        ds.b MAX_INVENTORYITEMS,0
invCount:       ds.b MAX_INVENTORYITEMS,0
invMag:         ds.b MAX_INVENTORYITEMS,0
plrSkills:
plrAgility:     dc.b 0
plrCarrying:    dc.b 0
plrFirearms:    dc.b 0
plrMelee:       dc.b 0
plrVitality:    dc.b 0

        ; Dynamic memory allocation area begins here

fileAreaStart:
