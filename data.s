        ; Game data

                include actordata.s
                include itemdata.s
                include weapondata.s
                include sounddata.s

        ; Music relocation tables

ntFixupTblLo:   dc.b <PMus_SongTblP2
                dc.b <PMus_SongTblP1
                dc.b <PMus_SongTblP0
                dc.b <PMus_PattTblHiM1
                dc.b <PMus_PattTblLoM1
                dc.b <PMus_CmdFiltM1
                dc.b <PMus_CmdPulseM1
                dc.b <PMus_CmdWaveM1
                dc.b <PMus_CmdSRM1
                dc.b <PMus_CmdADM1
                dc.b <PMus_FiltSpdM1b
                dc.b <PMus_FiltSpdM1a
                dc.b <PMus_FiltTimeM1
                dc.b <PMus_PulseSpdM1b
                dc.b <PMus_PulseSpdM1a
                dc.b <PMus_PulseTimeM1
                dc.b <PMus_NoteP0
                dc.b <PMus_NoteM1b
                dc.b <PMus_NoteM1a
                dc.b <PMus_WaveP0
                dc.b <PMus_WaveM1

ntFixupTblHi:   dc.b >PMus_SongTblP2
                dc.b >PMus_SongTblP1
                dc.b >PMus_SongTblP0
                dc.b >PMus_PattTblHiM1
                dc.b >PMus_PattTblLoM1
                dc.b >PMus_CmdFiltM1
                dc.b >PMus_CmdPulseM1
                dc.b >PMus_CmdWaveM1
                dc.b >PMus_CmdSRM1
                dc.b >PMus_CmdADM1
                dc.b >PMus_FiltSpdM1b
                dc.b >PMus_FiltSpdM1a
                dc.b >PMus_FiltTimeM1
                dc.b >PMus_PulseSpdM1b
                dc.b >PMus_PulseSpdM1a
                dc.b >PMus_PulseTimeM1
                dc.b >PMus_NoteP0
                dc.b >PMus_NoteM1b
                dc.b >PMus_NoteM1a
                dc.b >PMus_WaveP0
                dc.b >PMus_WaveM1

ntFixupTblAdd:  dc.b NT_ADDZERO+3
                dc.b NT_ADDZERO+2
                dc.b NT_ADDPATT+1
                dc.b NT_ADDPATT
                dc.b NT_ADDLEGATOCMD
                dc.b NT_ADDLEGATOCMD
                dc.b NT_ADDLEGATOCMD
                dc.b NT_ADDCMD
                dc.b NT_ADDCMD
                dc.b NT_ADDFILT
                dc.b NT_ADDZERO
                dc.b NT_ADDFILT
                dc.b NT_ADDPULSE
                dc.b NT_ADDZERO
                dc.b NT_ADDPULSE
                dc.b NT_ADDWAVE
                dc.b NT_ADDZERO+1
                dc.b NT_ADDZERO
                dc.b NT_ADDWAVE
                dc.b NT_ADDZERO+1
                dc.b NT_ADDZERO

        ; Frequency table

ntFreqTbl:      dc.w $022d,$024e,$0271,$0296,$02be,$02e8
                dc.w $0314,$0343,$0374,$03a9,$03e1,$041c
                dc.w $045a,$049c,$04e2,$052d,$057c,$05cf
                dc.w $0628,$0685,$06e8,$0752,$07c1,$0837
                dc.w $08b4,$0939,$09c5,$0a5a,$0af7,$0b9e
                dc.w $0c4f,$0d0a,$0dd1,$0ea3,$0f82,$106e
                dc.w $1168,$1271,$138a,$14b3,$15ee,$173c
                dc.w $189e,$1a15,$1ba2,$1d46,$1f04,$20dc
                dc.w $22d0,$24e2,$2714,$2967,$2bdd,$2e79
                dc.w $313c,$3429,$3744,$3a8d,$3e08,$41b8
                dc.w $45a1,$49c5,$4e28,$52cd,$57ba,$5cf1
                dc.w $6278,$6853,$6e87,$751a,$7c10,$8371
                dc.w $8b42,$9389,$9c4f,$a59b,$af74,$b9e2
                dc.w $c4f0,$d0a6,$dd0e,$ea33,$f820,$ffff

        ; Sprite cache / depacking tables

        ; Next slice lowbyte table for sprite depacking. Interleaved with data to not waste memory,
        ; each empty space is 18 bytes.

nextSliceTbl:   dc.b 1,2,21

d018Tbl:        dc.b $a8,$b8
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

moveCtrlAndTbl: dc.b $ff                        ;None
                dc.b $ff-JOY_DOWN               ;Up
                dc.b $ff-JOY_UP                 ;Down
                dc.b $ff-JOY_DOWN-JOY_UP        ;Up+Down
                dc.b $ff-JOY_RIGHT              ;Left
                dc.b $ff-JOY_RIGHT-JOY_DOWN     ;Left+Up
                dc.b $ff-JOY_RIGHT-JOY_UP       ;Left+Down
                dc.b $ff-JOY_RIGHT-JOY_DOWN-JOY_UP ;Left+Up+Down
                dc.b $ff-JOY_LEFT               ;Right
                dc.b $ff-JOY_LEFT-JOY_DOWN      ;Right+Up
                dc.b $ff-JOY_LEFT-JOY_UP        ;Right+Down
                dc.b $ff-JOY_LEFT-JOY_DOWN-JOY_UP ;Right+Up+Down
                dc.b $ff-JOY_LEFT-JOY_RIGHT     ;Right+Left
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
actSizeH:       ds.b MAX_ACT,0
actSizeU:       ds.b MAX_ACT,0
actSizeD:       ds.b MAX_ACT,0
actTime:        ds.b MAX_ACT,0
actHp:          ds.b MAX_ACT,0
actMB:          ds.b MAX_ACT,0
actCtrl:        ds.b MAX_COMPLEXACT,0
actMoveCtrl:    ds.b MAX_COMPLEXACT,0
actPrevCtrl:    ds.b MAX_COMPLEXACT,0
actF2:          ds.b MAX_COMPLEXACT,0
actWpn:         ds.b MAX_COMPLEXACT,WPN_NONE
actWpnF:        ds.b MAX_COMPLEXACT,$ff
actAttackD:     ds.b MAX_COMPLEXACT,0
actFall:        ds.b MAX_COMPLEXACT,0
actFallL:       ds.b MAX_COMPLEXACT,0
actAIMode:      ds.b MAX_COMPLEXACT,0
actAIHelp:      ds.b MAX_COMPLEXACT,0

        ;Other variables

invType:        ds.b MAX_INVENTORYITEMS,0
invCount:       ds.b MAX_INVENTORYITEMS,0
invMag:         ds.b MAX_INVENTORYITEMS,0
displayedItemName:dc.b 0
displayedHealth:dc.b 0
healthRecharge: dc.b 0
magazineSize:   dc.b 0
menuCounter:    dc.b 0
menuMoveDelay:  dc.b 0

        ; Dynamic memory allocation area begins here

fileAreaStart:
