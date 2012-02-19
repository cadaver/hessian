        ; Ninjatracker V2.03 gamemusic playroutine
        ; Defines
        
NT_FIRSTNOTE       = $18
NT_DUR             = $c0
NT_HEADERLENGTH    = 6
NT_NUMFIXUPS       = 21
NT_ADDZERO         = $80
NT_ADDWAVE         = $00
NT_ADDPULSE        = $04
NT_ADDFILT         = $08
NT_ADDCMD          = $0c
NT_ADDLEGATOCMD    = $10
NT_ADDPATT         = $14
NT_HRPARAM         = $00
NT_FIRSTWAVE       = $09
NT_SFXHRPARAM      = $00
NT_SFXFIRSTWAVE    = $09

        ; Load new music file
        ;
        ; Parameters: A music file number
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

LoadMusic:      ldx #F_MUSIC
                jsr MakeFileName
                lda #$7f
                sta PMus_InitSongNum+1          ;Silence during loading
                lda #<musicData
                ldx #>musicData
                jsr LoadFile                    ;TODO: check for error
                jsr PostLoad

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
IMD_Store:      sta PlayMusic,y
LM_Error:       rts

        ;New song initialization

PMus_DoInit:    asl
                bpl PMus_NoSilence
                jmp SilenceSID
PMus_NoSilence: asl
                adc PMus_InitSongNum+1
                tay
PMus_SongTblP0: lda $1000,y
                sta PMus_TrackLo+1
PMus_SongTblP1: lda $1000,y
                sta PMus_TrackHi+1
                txa
                sta PMus_FiltPos+1
                sta $d417
                ldx #21
PMus_InitLoop:  sta ntChnPattPos-1,x
                dex
                bne PMus_InitLoop
                lda #$04                        ;Hack: reset NTSC-delay to avoid systematic
                sta ntscDelay                   ;hard restart bug at tempo 5
                jsr PMus_InitChn
                ldx #$07
                jsr PMus_InitChn
                ldx #$0e
PMus_InitChn:    
PMus_SongTblP2: lda $1000,y
                sta ntChnSongPos,x
                iny
                lda #$ff
                sta ntChnNewNote,x
                sta ntChnDuration,x

        ; Initialize subtune from the music data
        ;
        ; Parameters: A subtune
        ; Returns: -
        ; Modifies: -

InitMusic:      sta PMus_InitSongNum+1
                rts

        ; Initialize sound effect playback, with priority (higher memory address has precedence)
        
        ; Parameters: A,X sound effect address Y channel index (0,7,14)
        ; Returns: -
        ; Modifies: A

InitSound:      sta ISnd_AddressLo+1
                cmp ntChnSfxLo,y
                txa
                sbc ntChnSfxHi,y
                bpl ISnd_Ok
                lda ntChnSfx,y
                bne ISnd_Skip
ISnd_Ok:        lda #$01
                sta ntChnSfx,y
ISnd_AddressLo: lda #$00
                sta ntChnSfxLo,y
                txa
                sta ntChnSfxHi,y
ISnd_Skip:      rts

        ; Call each frame to advance music & sound effect playback
        ; Modifies: A,X,Y,player temp vars

PlayMusic:      ldx #$00
PMus_InitSongNum:
                lda #$7f
                bpl PMus_DoInit

          ;Filter execution

PMus_FiltPos:   ldy #$00
                beq PMus_FiltDone
PMus_FiltTimeM1:lda $1000,y
                bpl PMus_FiltMod
                cmp #$ff
                bcs PMus_FiltJump
PMus_SetFilt:   sta $d417
                and #$70
                sta PMus_FiltDone+1
PMus_FiltJump:    
PMus_FiltSpdM1a:lda $1000,y
                bcs PMus_FiltJump2
PMus_NextFilt:  inc PMus_FiltPos+1
                bcc PMus_StoreCutoff
PMus_FiltJump2: sta PMus_FiltPos+1
                bcs PMus_FiltDone
PMus_FiltMod:   clc
                dec ntFiltTime
                bmi PMus_NewFiltMod
                bne PMus_FiltCutoff
                inc PMus_FiltPos+1
                bcc PMus_FiltDone
PMus_NewFiltMod:sta ntFiltTime
PMus_FiltCutoff:lda #$00
PMus_FiltSpdM1b:adc $1000,y
PMus_StoreCutoff:
                sta PMus_FiltCutoff+1
                sta $d416
PMus_FiltDone:  lda #$00
PMus_MasterVolume:
                ora #$0f
                sta $d418

        ;Channel execution

                jsr PMus_ChnExec
                ldx #$07
                jsr PMus_ChnExec
                ldx #$0e

        ;Update duration counter

PMus_ChnExec:   inc ntChnCounter,x
                bne PMus_NoPattern

        ;Get data from pattern

PMus_Pattern:   ldy ntChnPattNum,x
PMus_PattTblLoM1: 
                lda $1000,y
                sta ntTemp1
PMus_PattTblHiM1: 
                lda $1000,y
                sta ntTemp2
                ldy ntChnPattPos,x
                lda (ntTemp1),y
                lsr
                sta ntChnNewNote,x
                bcc PMus_NoNewCmd
PMus_NewCmd:    iny
                lda (ntTemp1),y
                sta ntChnCmd,x
                bcc PMus_Rest
PMus_CheckHr:   bmi PMus_Rest
                lda ntChnSfx,x
                bne PMus_Rest
                lda #$fe
                sta ntChnGate,x
                sta $d405,x
                lda #NT_HRPARAM
                sta $d406,x
PMus_Rest:      iny
                lda (ntTemp1),y
                cmp #$c0
                bcc PMus_NoNewDur
                iny
                sta ntChnDuration,x
PMus_NoNewDur:  lda (ntTemp1),y
                beq PMus_EndPatt
                tya
PMus_EndPatt:   sta ntChnPattPos,x
PMus_JumpToWave:ldy ntChnSfx,x
                bne PMus_JumpToSfx
                jmp PMus_WaveExec
PMus_JumpToSfx: jmp PMus_SfxExec

        ;No new command, or gate control

PMus_NoNewCmd:  cmp #NT_FIRSTNOTE/2
                bcc PMus_GateCtrl
                lda ntChnCmd,x
                bcs PMus_CheckHr
PMus_GateCtrl:  lsr
                ora #$fe
                sta ntChnGate,x
                bcc PMus_NewCmd
                sta ntChnNewNote,x
                bcs PMus_Rest

        ;No new pattern data

PMus_LegatoCmd: tya
                and #$7f
                tay
                bpl PMus_SkipAdsr

PMus_JumpToPulse:
                ldy ntChnSfx,x
                bne PMus_JumpToSfx
                jmp PMus_PulseExec
PMus_NoPattern: lda ntChnCounter,x
                cmp #$02
                bne PMus_JumpToPulse

        ;Reload counter and check for new note / command exec / track access

PMus_Reload:    lda ntChnDuration,x
                sta ntChnCounter,x
                lda ntChnNewNote,x
                bpl PMus_NewNoteInit
                lda ntChnPattPos,x
                bne PMus_JumpToPulse

         ;Get data from track

PMus_Track:
PMus_TrackLo:   lda #$00
                sta ntTemp1
PMus_TrackHi:   lda #$00
                sta ntTemp2
                ldy ntChnSongPos,x
                lda (ntTemp1),y
                bne PMus_NoSongJump
                iny
                lda (ntTemp1),y
                tay
                lda (ntTemp1),y
PMus_NoSongJump:bpl PMus_NoSongTrans
                sta ntChnTrans,x
                iny
                lda (ntTemp1),y
PMus_NoSongTrans:
                sta ntChnPattNum,x
                iny
                tya
                sta ntChnSongPos,x
                bcs PMus_JumpToWave
                bcc PMus_CmdExecuted

        ;New note init / command exec

PMus_NewNoteInit: cmp #NT_FIRSTNOTE/2
                bcc PMus_SkipNote
                adc ntChnTrans,x
                asl
                sta ntChnNote,x
                sec
PMus_SkipNote:  ldy ntChnCmd,x
                bmi PMus_LegatoCmd
PMus_CmdADM1:   lda $1000,y
                sta $d405,x
PMus_CmdSRM1:   lda $1000,y
                sta $d406,x
                bcc PMus_SkipGate
                lda #$ff
                sta ntChnGate,x
                lda #NT_FIRSTWAVE
                sta $d404,x
PMus_SkipGate:
PMus_SkipAdsr:
PMus_CmdWaveM1: lda $1000,y
                beq PMus_SkipWave
                sta ntChnWavePos,x
                lda #$00
                sta ntChnWaveTime,x
PMus_SkipWave:    
PMus_CmdPulseM1:lda $1000,y
                beq PMus_SkipPulse
                sta ntChnPulsePos,x
                lda #$00
                sta ntChnPulseTime,x
PMus_SkipPulse:   
PMus_CmdFiltM1: lda $1000,y
                beq PMus_SkipFilt
                sta PMus_FiltPos+1
                lda #$00
                sta ntFiltTime
PMus_SkipFilt:  clc
                lda ntChnPattPos,x
                beq PMus_Track
PMus_CmdExecuted:
PMus_NoTrack:   rts

        ;Pulse execution

PMus_NoPulseMod:cmp #$ff
PMus_PulseSpdM1a:
                lda $1000,y
                bcs PMus_PulseJump
                inc ntChnPulsePos,x
                bcc PMus_StorePulse
PMus_PulseJump: sta ntChnPulsePos,x
                bcs PMus_PulseDone
PMus_PulseExec: ldy ntChnPulsePos,x
                beq PMus_PulseDone
PMus_PulseTimeM1:
                lda $1000,y
                bmi PMus_NoPulseMod
PMus_PulseMod:  clc
                dec ntChnPulseTime,x
                bmi PMus_NewPulseMod
                bne PMus_NoNewPulseMod
                inc ntChnPulsePos,x
                bcc PMus_PulseDone
PMus_NewPulseMod:
                sta ntChnPulseTime,x
PMus_NoNewPulseMod:
                lda ntChnPulse,x
PMus_PulseSpdM1b:
                adc $1000,y
                adc #$00
PMus_StorePulse:sta ntChnPulse,x
                sta $d402,x
                sta $d403,x
PMus_PulseDone:

        ;Wavetable execution

PMus_WaveExec:  ldy ntChnWavePos,x
                beq PMus_WaveDone
PMus_WaveM1:    lda $1000,y
                cmp #$c0
                bcs PMus_SlideOrVib
                cmp #$90
                bcc PMus_WaveChange

        ;Delayed wavetable

PMus_WaveDelay: beq PMus_NoWaveChange
                dec ntChnWaveTime,x
                beq PMus_NoWaveChange
                bpl PMus_WaveDone
                sbc #$90
                sta ntChnWaveTime,x
                bcs PMus_WaveDone

        ;Wave change + arpeggio

PMus_WaveChange:sta ntChnWave,x
                tya
                sta ntChnWaveold,x
PMus_NoWaveChange:
PMus_WaveP0:    lda $1000,y
                cmp #$ff
                bcs PMus_WaveJump
PMus_NoWaveJump:inc ntChnWavePos,x
                bcc PMus_WaveJumpdone
PMus_WaveJump:
PMus_NoteP0:    lda $1000,y
                sta ntChnWavePos,x
PMus_WaveJumpdone:
PMus_NoteM1a:   lda $1000,y
                asl
                bcs PMus_AbsFreq
                adc ntChnNote,x
PMus_AbsFreq:   tay
                bne PMus_NoteNum
PMus_SlideDone: ldy ntChnNote,x
                lda ntChnWaveold,x
                sta ntChnWavePos,x
PMus_NoteNum:   lda ntFreqTbl-24,y
                sta ntChnFreqLo,x
                sta $d400,x
                lda ntFreqTbl-23,y
PMus_StoreFreqHi: 
                sta $d401,x
                sta ntChnFreqHi,x
PMus_WaveDone:  lda ntChnWave,x
                and ntChnGate,x
                sta $d404,x
                rts

        ;Slide or vibrato

PMus_SlideOrVib:sbc #$e0
                sta ntTemp1
                lda ntChnCounter,x
                beq PMus_WaveDone
PMus_NoteM1b:   lda $1000,y
                sta ntTemp2
                bcc PMus_Vibrato

        ;Slide (toneportamento)

PMus_Slide:     ldy ntChnNote,x
                lda ntChnFreqLo,x
                sbc ntFreqTbl-24,y
                pha
                lda ntChnFreqHi,x
                sbc ntFreqTbl-23,y
                tay
                pla
                bcs PMus_SlideDown
PMus_Slideup:   adc ntTemp2
                tya
                adc ntTemp1
                bcs PMus_SlideDone
PMus_FreqAdd:   lda ntChnFreqLo,x
                adc ntTemp2
                sta ntChnFreqLo,x
                sta $d400,x
                lda ntChnFreqHi,x
                adc ntTemp1
                jmp PMus_StoreFreqHi

        ;Sound effect hard restart
       
PMus_SfxHr:     lda #NT_SFXHRPARAM
                sta $d406,x
                bcc PMus_WaveDone

PMus_SlideDown: sbc ntTemp2
                tya
                sbc ntTemp1
                bcc PMus_SlideDone
PMus_FreqSub:   lda ntChnFreqLo,x
                sbc ntTemp2
                sta ntChnFreqLo,x
                sta $d400,x
                lda ntChnFreqHi,x
                sbc ntTemp1
                jmp PMus_StoreFreqHi

          ;Vibrato

PMus_Vibrato:   lda ntChnWaveTime,x
                bpl PMus_VibNoDir
                cmp ntTemp1
                bcs PMus_VibNoDir2
                eor #$ff
PMus_VibNoDir:  sec
PMus_VibNoDir2: sbc #$02
                sta ntChnWaveTime,x
                lsr
                lda #$00
                sta ntTemp1
                bcc PMus_FreqAdd
                bcs PMus_FreqSub

          ;Sound effect

PMus_SfxExec:   lda ntChnSfxLo,x
                sta ntTemp1
                lda ntChnSfxHi,x
                sta ntTemp2
                lda #$fe
                sta ntChnNewNote,x
                sta ntChnGate,x
                inc ntChnSfx,x
                cpy #$02
                beq PMus_SfxInit
                bcc PMus_SfxHr
PMus_SfxMain:   lda (ntTemp1),y
                beq PMus_SfxEnd
PMus_SfxNoEnd:  asl
                tay
                lda ntFreqTbl-24,y
                sta $d400,x
                lda ntFreqTbl-23,y
                sta $d401,x
                ldy ntChnSfx,x
                lda (ntTemp1),y
                beq PMus_SfxDone
                cmp #$82
                bcs PMus_SfxDone
                inc ntChnSfx,x
PMus_SfxWaveChg:sta ntChnWave,x
                sta $d404,x
PMus_SfxDone:   rts
PMus_SfxEnd:    sta ntChnSfx,x
                sta ntChnWavePos,x
                sta ntChnWaveold,x
                beq PMus_SfxWaveChg
PMus_SfxInit:   lda (ntTemp1),y
                sta $d402,x
                sta $d403,x
                dey
                lda (ntTemp1),y
                sta $d405,x
                dey
                lda (ntTemp1),y
                sta $d406,x
                lda #NT_SFXFIRSTWAVE
                bcs PMus_SfxWaveChg
