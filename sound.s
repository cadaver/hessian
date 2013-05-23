        ; Ninjatracker V2.03 gamemusic playroutine
        ; Relocation defines
        
NT_FIRSTNOTE        = $18
NT_DUR              = $c0
NT_HEADERLENGTH     = 6
NT_NUMFIXUPS        = 21
NT_ADDZERO          = $80
NT_ADDWAVE          = $00
NT_ADDPULSE         = $04
NT_ADDFILT          = $08
NT_ADDCMD           = $0c
NT_ADDLEGATOCMD     = $10
NT_ADDPATT          = $14
NT_HRPARAM          = $00
NT_FIRSTWAVE        = $09

MUSIC_SILENCE       = $00
MUSIC_TITLE         = $01
MUSIC_CARGOSHIP     = $04
MUSIC_CITY          = $08

FIRST_INGAME_SONG   = $04

        ; Play a song. Load if necessary. Do not reinit if already playing
        ;
        ; Parameters: A song number, $00-$03 in first file, $04-$07 in second etc.
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

RestartSong:    lda #$00
PlaySong:       sta RestartSong+1
                cmp #FIRST_INGAME_SONG          ;If title/intro music, always play even if music off
                bcc PS_MusicOn
                ldx musicMode                   ;If music off, always select song 0 of file 0 (global silence)
                bne PS_MusicOn
                txa
PS_MusicOn:     sta PSfx_MusicCheck+1
PS_CurrentSong: cmp #$ff
                beq PS_Done
                sta PS_CurrentSong+1
                pha
                lsr
                lsr
PS_LoadedMusic: cmp #$ff                        ;Check if music already loaded
                beq PS_SameMusicFile
                sta PS_LoadedMusic+1
                ldx #F_MUSIC
                jsr MakeFileName
                lda #$7f
                sta ntInitSong                  ;Silence during loading
                lda #<musicData
                ldx #>musicData
                jsr LoadFileRetry

        ; Initialize new music data
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,loader temp vars

InitMusicData:  lda #<(musicData+NT_HEADERLENGTH-1)
                sta zpSrcLo
                lda #>(musicData+NT_HEADERLENGTH-1)
                sta zpSrcHi
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
                adc zpSrcLo
                sta zpSrcLo
                bcc IMD_AddDone
                inc zpSrcHi
IMD_AddDone:    pla
                and #$03
                clc
                adc zpSrcLo
                ldy #$01
                jsr IMD_Store
                lda #$00
                adc zpSrcHi
                iny
                jsr IMD_Store
                dex
                bpl IMD_Loop
PS_SameMusicFile:
                pla
                and #$03
                sta ntInitSong
PS_Done:        rts

IMD_Store:      sta PlayRoutine,y
                rts

        ; Play a sound effect, with priority (higher memory address has precedence)
        
        ; Parameters: A sound effect number
        ; Returns: -
        ; Modifies: A,loader temp vars

PlaySfx:        stx zpSrcLo
                sty zpSrcHi
                ldx soundMode                   ;Check for sounds disabled
                beq PSfx_Done
                tay
                lda sfxTblLo,y
                sta zpBitsLo
                ldx sfxTblHi,y
PSfx_NextChn:   lda #0                          ;If not playing music, cycle all channels
PSfx_MusicCheck:ldy #$00                        ;else use first channel only
                bne PSfx_HasMusic
                clc
                adc #7
                cmp #21
                bcc PSfx_ChnNotOver
PSfx_HasMusic:  lda #0
PSfx_ChnNotOver:sta PSfx_NextChn+1
                tay
                lda zpBitsLo
                cmp ntChnSfxLo,y
                txa
                sbc ntChnSfxHi,y
                bpl PSfx_Ok
                lda ntChnSfx,y
                bne PSfx_Done
PSfx_Ok:        lda #$01
                sta ntChnSfx,y
                lda zpBitsLo
                sta ntChnSfxLo,y
                txa
                sta ntChnSfxHi,y
PSfx_Done:      ldx zpSrcLo
                ldy zpSrcHi
                rts

        ;New song initialization

Play_DoInit:    asl
                bpl Play_NoSilence
                jmp SilenceSID
Play_NoSilence: asl
                adc ntInitSong
                tay
Play_SongTblP0: lda $1000,y
                sta ntTrackLo
Play_SongTblP1: lda $1000,y
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
                sta ntChnTrans,x
                sta ntInitSong
                rts

        ; Play one frame of music & sound effects
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,player vars

PlayRoutine:    ldx #$00
                lda ntInitSong
                bpl Play_DoInit

          ;Filter execution

                ldy ntFiltPos
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
Play_JumpToWave:ldy ntChnSfx,x
                bne Play_JumpToSfx
                jmp Play_WaveExec
Play_JumpToSfx: jmp Play_SfxExec

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
                ldy ntChnSfx,x
                bne Play_JumpToSfx
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
                lda #NT_FIRSTWAVE
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

          ;Sound effect hard restart
          
Play_SfxHRFirstWave:
                lda #NT_FIRSTWAVE
                sta ntChnWave,x
Play_SfxHR:     lda #$00
                sta $d405,x
                sta $d406,x
                beq Play_WaveDone

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

          ;Sound effect

Play_SfxExec:   lda ntChnSfxLo,x
                sta ntTemp1
                lda ntChnSfxHi,x
                sta ntTemp2
                lda #$fe
                sta ntChnNewNote,x
                sta ntChnGate,x
                inc ntChnSfx,x
                cpy #$02
                beq Play_SfxHRFirstWave
                bcc Play_SfxHR
Play_SfxMain:   lda (ntTemp1),y
                beq Play_SfxEnd
Play_SfxNoEnd:  asl
                tay
                lda ntFreqTbl-24,y
                sta $d400,x
                lda ntFreqTbl-23,y
                sta $d401,x
                ldy ntChnSfx,x
                lda (ntTemp1),y
                beq Play_SfxDone
                cmp #$82
                bcs Play_SfxDone
                inc ntChnSfx,x
Play_SfxWaveChg:sta ntChnWave,x
                sta $d404,x
                ldy #$02
                lda (ntTemp1),y
                sta $d402,x
                sta $d403,x
                dey
                lda (ntTemp1),y
                sta $d405,x
                dey
                lda (ntTemp1),y
                sta $d406,x
Play_SfxDone:   rts
Play_SfxEnd:    sta ntChnSfx,x
                sta ntChnWavePos,x
                sta ntChnWaveOld,x
                beq Play_SfxWaveChg

