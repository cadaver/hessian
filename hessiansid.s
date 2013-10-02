                processor 6502
                org $0000

SUBTUNES        = 14

                dc.b "PSID"
                dc.b 0,2
                dc.b 0,$7c
                dc.b $00,$00
                dc.b $10,$00
                dc.b $10,$03
                dc.b 0,SUBTUNES
                dc.b 0,1
                dc.b 0,0,0,0

                org $0016
                dc.b "Hessian"

                org $0036
                dc.b "Cadaver & NecroPolo"

                org $0056

                dc.b "2013 Covert Bitops"

                org $007c
                dc.b $00,$10
                rorg $1000

ntTemp1         = $f8
ntTemp2         = $f9
ntTrackLo       = $fa
ntTrackHi       = $fb
ntFiltPos       = $fc
ntFiltTime      = $fd
ntFiltCutoff    = $fe

orgMusicData    = $f800
musicData       = $c000

NT_FIRSTNOTE    = $18
NT_DUR          = $c0
NT_HEADERLENGTH = 6
NT_NUMFIXUPS    = 21
NT_ADDZERO      = $80
NT_ADDWAVE      = $00
NT_ADDPULSE     = $04
NT_ADDFILT      = $08
NT_ADDCMD       = $0c
NT_ADDLEGATOCMD = $10
NT_ADDPATT      = $14
NT_HRPARAM      = $00
NT_FIRSTWAVE    = $09

                jmp Init

Play:

        ; Play one frame of music & sound effects
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,player vars

Play:           ldx #$00
Play_InitFlag:  lda #$00
                bmi Play_FiltExec

        ;New song initialization

Play_DoInit:    asl
                asl
                adc Play_InitFlag+1
                tay
Play_SongTblP0: lda $1000,y
                sta ntTrackLo
Play_SongTblP1: lda $1000,y
                sec
                sbc #>(orgMusicData-musicData)
                sta ntTrackHi
                txa
                sta ntFiltPos
                sta $d417
                ldx #21
Play_InitLoop:  sta ntChnPattPos-1,x
                dex
                bne Play_InitLoop
                jsr Play_InitChn
                ldx #$07
                jsr Play_InitChn
                ldx #$0e
Play_InitChn:
Play_SongTblP2: lda $1000,y
                sta ntChnSongPos,x
                iny
                lda #$ff
                sta ntChnNewNote,x
                sta ntChnDuration,x
                sta Play_InitFlag+1
                rts

          ;Filter execution

Play_FiltExec:  ldy ntFiltPos
                beq Play_FiltDone
Play_FiltTimeM1:lda $1000,y
                bpl Play_FiltMod
                cmp #$ff
                bcs Play_FiltJump
Play_SetFilt:   sta $d417
                and #$70
                sta Play_FiltDone+1
Play_FiltJump:
Play_FiltSpdM1a:lda $1000,y
                bcs Play_FiltJump2
Play_NextFilt:  inc ntFiltPos
                bcc Play_StoreCutoff
Play_FiltJump2: sta ntFiltPos
                bcs Play_FiltDone
Play_FiltMod:   clc
                dec ntFiltTime
                bmi Play_NewFiltMod
                bne Play_FiltCutoff
                inc ntFiltPos
                bcc Play_FiltDone
Play_NewFiltMod:sta ntFiltTime
Play_FiltCutoff:lda ntFiltCutoff
Play_FiltSpdM1b:adc $1000,y
Play_StoreCutoff:
                sta ntFiltCutoff
                sta $d416
Play_FiltDone:  lda #$00
Play_MasterVolume:
                ora #$0f
                sta $d418

        ;Channel execution

                jsr Play_ChnExec
                ldx #$07
                jsr Play_ChnExec
                ldx #$0e

        ;Update duration counter

Play_ChnExec:   inc ntChnCounter,x
                bne Play_NoPattern

        ;Get data from pattern

Play_Pattern:   ldy ntChnPattNum,x
Play_PattTblLoM1:
                lda $1000,y
                sta ntTemp1
Play_PattTblHiM1:
                lda $1000,y
                sec
                sbc #>(orgMusicData-musicData)
                sta ntTemp2
                ldy ntChnPattPos,x
                lda (ntTemp1),y
                lsr
                sta ntChnNewNote,x
                bcc Play_NoNewCmd
Play_NewCmd:    iny
                lda (ntTemp1),y
                sta ntChnCmd,x
                bcc Play_Rest
Play_CheckHr:   bmi Play_Rest
                lda ntChnSfx,x
                bne Play_Rest
                lda #$fe
                sta ntChnGate,x
                sta $d405,x
                lda #NT_HRPARAM
                sta $d406,x
Play_Rest:      iny
                lda (ntTemp1),y
                cmp #$c0
                bcc Play_NoNewDur
                iny
                sta ntChnDuration,x
Play_NoNewDur:  lda (ntTemp1),y
                beq Play_EndPatt
                tya
Play_EndPatt:   sta ntChnPattPos,x
Play_JumpToWave:jmp Play_WaveExec

        ;No new command, or gate control

Play_NoNewCmd:  cmp #NT_FIRSTNOTE/2
                bcc Play_GateCtrl
                lda ntChnCmd,x
                bcs Play_CheckHr
Play_GateCtrl:  lsr
                ora #$fe
                sta ntChnGate,x
                bcc Play_NewCmd
                sta ntChnNewNote,x
                bcs Play_Rest

        ;No new pattern data

Play_LegatoCmd: tya
                and #$7f
                tay
                bpl Play_SkipAdsr

Play_JumpToPulse:
                jmp Play_PulseExec
Play_NoPattern: lda ntChnCounter,x
                cmp #$02
                bne Play_JumpToPulse

        ;Reload counter and check for new note / command exec / track access

Play_Reload:    lda ntChnDuration,x
                sta ntChnCounter,x
                lda ntChnNewNote,x
                bpl Play_NewNoteInit
                lda ntChnPattPos,x
                bne Play_JumpToPulse

         ;Get data from track

Play_Track:     ldy ntChnSongPos,x
                lda (ntTrackLo),y
                bne Play_NoSongJump
                iny
                lda (ntTrackLo),y
                tay
                lda (ntTrackLo),y
Play_NoSongJump:bpl Play_NoSongTrans
                sta ntChnTrans,x
                iny
                lda (ntTrackLo),y
Play_NoSongTrans:
                sta ntChnPattNum,x
                iny
                tya
                sta ntChnSongPos,x
                bcs Play_JumpToWave
                bcc Play_CmdExecuted

        ;New note init / command exec

Play_NewNoteInit: 
                cmp #NT_FIRSTNOTE/2
                bcc Play_SkipNote
                adc ntChnTrans,x
                asl
                sta ntChnNote,x
                sec
Play_SkipNote:  ldy ntChnCmd,x
                bmi Play_LegatoCmd
Play_CmdADM1:   lda $1000,y
                sta $d405,x
Play_CmdSRM1:   lda $1000,y
                sta $d406,x
                bcc Play_SkipGate
                lda #$ff
                sta ntChnGate,x
                lda #$09
                sta $d404,x
Play_SkipGate:
Play_SkipAdsr:
Play_CmdWaveM1: lda $1000,y
                beq Play_SkipWave
                sta ntChnWavePos,x
                lda #$00
                sta ntChnWaveTime,x
Play_SkipWave:    
Play_CmdPulseM1:lda $1000,y
                beq Play_SkipPulse
                sta ntChnPulsePos,x
                lda #$00
                sta ntChnPulseTime,x
Play_SkipPulse:   
Play_CmdFiltM1: lda $1000,y
                beq Play_SkipFilt
                sta ntFiltPos
                lda #$00
                sta ntFiltTime
Play_SkipFilt:  clc
                lda ntChnPattPos,x
                beq Play_Track
Play_CmdExecuted:
Play_NoTrack:   rts

        ;Pulse execution

Play_NoPulseMod:cmp #$ff
Play_PulseSpdM1a:
                lda $1000,y
                bcs Play_PulseJump
                inc ntChnPulsePos,x
                bcc Play_StorePulse
Play_PulseJump: sta ntChnPulsePos,x
                bcs Play_PulseDone
Play_PulseExec: ldy ntChnPulsePos,x
                beq Play_PulseDone
Play_PulseTimeM1:
                lda $1000,y
                bmi Play_NoPulseMod
Play_PulseMod:  clc
                dec ntChnPulseTime,x
                bmi Play_NewPulseMod
                bne Play_NoNewPulseMod
                inc ntChnPulsePos,x
                bcc Play_PulseDone
Play_NewPulseMod:
                sta ntChnPulseTime,x
Play_NoNewPulseMod:
                lda ntChnPulse,x
Play_PulseSpdM1b:
                adc $1000,y
                adc #$00
Play_StorePulse:sta ntChnPulse,x
                sta $d402,x
                sta $d403,x
Play_PulseDone:

        ;Wavetable execution

Play_WaveExec:  ldy ntChnWavePos,x
                beq Play_WaveDone
Play_WaveM1:    lda $1000,y
                cmp #$c0
                bcs Play_SlideOrVib
                cmp #$90
                bcc Play_WaveChange

        ;Delayed wavetable

Play_WaveDelay: beq Play_NoWaveChange
                dec ntChnWaveTime,x
                beq Play_NoWaveChange
                bpl Play_WaveDone
                sbc #$90
                sta ntChnWaveTime,x
                bcs Play_WaveDone

        ;Wave change + arpeggio

Play_WaveChange:sta ntChnWave,x
                tya
                sta ntChnWaveOld,x
Play_NoWaveChange:
Play_WaveP0:    lda $1000,y
                cmp #$ff
                bcs Play_WaveJump
Play_NoWaveJump:inc ntChnWavePos,x
                bcc Play_WaveJumpDone
Play_WaveJump:
Play_NoteP0:    lda $1000,y
                sta ntChnWavePos,x
Play_WaveJumpDone:
Play_NoteM1a:   lda $1000,y
                asl
                bcs Play_AbsFreq
                adc ntChnNote,x
Play_AbsFreq:   tay
                bne Play_NoteNum
Play_SlideDone: ldy ntChnNote,x
                lda ntChnWaveOld,x
                sta ntChnWavePos,x
Play_NoteNum:   lda ntFreqTbl-24,y
                sta ntChnFreqLo,x
                sta $d400,x
                lda ntFreqTbl-23,y
Play_StoreFreqHi: 
                sta $d401,x
                sta ntChnFreqHi,x
Play_WaveDone:  lda ntChnWave,x
                and ntChnGate,x
                sta $d404,x
                rts

        ;Slide or vibrato

Play_SlideOrVib:sbc #$e0
                sta ntTemp1
                lda ntChnCounter,x
                beq Play_WaveDone
Play_NoteM1b:   lda $1000,y
                sta ntTemp2
                bcc Play_Vibrato

        ;Slide (toneportamento)

Play_Slide:     ldy ntChnNote,x
                lda ntChnFreqLo,x
                sbc ntFreqTbl-24,y
                pha
                lda ntChnFreqHi,x
                sbc ntFreqTbl-23,y
                tay
                pla
                bcs Play_SlideDown
Play_Slideup:   adc ntTemp2
                tya
                adc ntTemp1
                bcs Play_SlideDone
Play_FreqAdd:   lda ntChnFreqLo,x
                adc ntTemp2
                sta ntChnFreqLo,x
                sta $d400,x
                lda ntChnFreqHi,x
                adc ntTemp1
                jmp Play_StoreFreqHi

Play_SlideDown: sbc ntTemp2
                tya
                sbc ntTemp1
                bcc Play_SlideDone
Play_FreqSub:   lda ntChnFreqLo,x
                sbc ntTemp2
                sta ntChnFreqLo,x
                sta $d400,x
                lda ntChnFreqHi,x
                sbc ntTemp1
                jmp Play_StoreFreqHi

        ;Vibrato

Play_Vibrato:   lda ntChnWaveTime,x
                bpl Play_VibNoDir
                cmp ntTemp1
                bcs Play_VibNoDir2
                eor #$ff
Play_VibNoDir:  sec
Play_VibNoDir2: sbc #$02
                sta ntChnWaveTime,x
                lsr
                lda #$00
                sta ntTemp1
                bcc Play_FreqAdd
                bcs Play_FreqSub

        ;Init subtune

Init:           tay
                ldx subTuneModuleTbl,y
                lda subTuneTuneTbl,y
                pha
                lda moduleTblLo,x
                sta InitCopyLda+1
                sta InitCopyLda2+1
                lda moduleTblHi,x
                sta InitCopyLda+2
                clc
                adc #$07
                sta InitCopyLda2+2
                lda #>musicData
                sta InitCopySta+2
                ldy #$07
                ldx #$00
InitCopyLda:    lda $1000,x
InitCopySta:    sta musicData,x
                inx
                bne InitCopyLda
                inc InitCopyLda+2
                inc InitCopySta+2
                dey
                bne InitCopyLda
InitCopyLda2:   lda $1000,x
InitCopySta2:   sta musicData+$700,x
                inx
                cpx #$fa
                bne InitCopyLda2
InitMusicData:  lda #<(musicData+NT_HEADERLENGTH-1)
                sta ntTrackLo
                lda #>(musicData+NT_HEADERLENGTH-1)
                sta ntTrackHi
                ldx #NT_NUMFIXUPS-1
IMD_Loop:       lda ntFixupTblLo,x
                sta IMD_Store+1
                lda ntFixupTblHi,x
                sta IMD_Store+2
                lda ntFixupTblAdd,x
                pha
                bmi IMD_AddDone
                lsr
                lsr
IMD_AddSize:    tay
IMD_GetSize:    lda musicData,y
                clc
                adc ntTrackLo
                sta ntTrackLo
                bcc IMD_AddDone
                inc ntTrackHi
IMD_AddDone:    pla
                and #$03
                clc
                adc ntTrackLo
                ldy #$01
                jsr IMD_Store
                lda #$00
                adc ntTrackHi
                iny
                jsr IMD_Store
                dex
                bpl IMD_Loop
                pla
                sta Play_InitFlag+1
                rts

IMD_Store:      sta Play,y
                rts

        ; Music relocation tables

ntFixupTblLo:   dc.b <Play_SongTblP2
                dc.b <Play_SongTblP1
                dc.b <Play_SongTblP0
                dc.b <Play_PattTblHiM1
                dc.b <Play_PattTblLoM1
                dc.b <Play_CmdFiltM1
                dc.b <Play_CmdPulseM1
                dc.b <Play_CmdWaveM1
                dc.b <Play_CmdSRM1
                dc.b <Play_CmdADM1
                dc.b <Play_FiltSpdM1b
                dc.b <Play_FiltSpdM1a
                dc.b <Play_FiltTimeM1
                dc.b <Play_PulseSpdM1b
                dc.b <Play_PulseSpdM1a
                dc.b <Play_PulseTimeM1
                dc.b <Play_NoteP0
                dc.b <Play_NoteM1b
                dc.b <Play_NoteM1a
                dc.b <Play_WaveP0
                dc.b <Play_WaveM1

ntFixupTblHi:   dc.b >Play_SongTblP2
                dc.b >Play_SongTblP1
                dc.b >Play_SongTblP0
                dc.b >Play_PattTblHiM1
                dc.b >Play_PattTblLoM1
                dc.b >Play_CmdFiltM1
                dc.b >Play_CmdPulseM1
                dc.b >Play_CmdWaveM1
                dc.b >Play_CmdSRM1
                dc.b >Play_CmdADM1
                dc.b >Play_FiltSpdM1b
                dc.b >Play_FiltSpdM1a
                dc.b >Play_FiltTimeM1
                dc.b >Play_PulseSpdM1b
                dc.b >Play_PulseSpdM1a
                dc.b >Play_PulseTimeM1
                dc.b >Play_NoteP0
                dc.b >Play_NoteM1b
                dc.b >Play_NoteM1a
                dc.b >Play_WaveP0
                dc.b >Play_WaveM1

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

        ; Music modules

moduleTblLo:    dc.b <module0
                dc.b <module1
                dc.b <module2
                dc.b <module3
                dc.b <module4
                dc.b <module5
                dc.b <module6
                dc.b <module7
                dc.b <module8
                dc.b <module9
                dc.b <module10
                dc.b <module11
                dc.b <module12
                dc.b <module13

moduleTblHi:    dc.b >module0
                dc.b >module1
                dc.b >module2
                dc.b >module3
                dc.b >module4
                dc.b >module5
                dc.b >module6
                dc.b >module7
                dc.b >module8
                dc.b >module9
                dc.b >module10
                dc.b >module11
                dc.b >module12
                dc.b >module13

subTuneModuleTbl:
                dc.b 0
                dc.b 3
                dc.b 4
                dc.b 5
                dc.b 6
                dc.b 7
                dc.b 8
                dc.b 9
                dc.b 10
                dc.b 11
                dc.b 12
                dc.b 13
                dc.b 2
                dc.b 1

subTuneTuneTbl: dc.b 1
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0
                dc.b 0

module0:        incbin music00.bin
module1:        incbin music01.bin
module2:        incbin music02.bin
module3:        incbin music03.bin
module4:        incbin music04.bin
module5:        incbin music05.bin
module6:        incbin music06.bin
module7:        incbin music07.bin
module8:        incbin music08.bin
module9:        incbin music09.bin
module10:       incbin music10.bin
module11:       incbin music11.bin
module12:       incbin music12.bin
module13:       incbin music13.bin