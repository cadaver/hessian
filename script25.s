                include macros.s
                include mainsym.s

        ; Script 25, Jormungandr bossfight

                org scriptCodeStart

                dc.w MoveJormungandr

PHASE_RISE      = 0
PHASE_WAIT      = 1
PHASE_ATTACK    = 2
PHASE_WAITDECISION = 3
PHASE_MINESDOWN = 4
PHASE_MINESUP   = 5

JORMUNGANDR_YSIZE = 21
JORMUNGANDR_XSIZE = 20
JORMUNGANDR_OFFSETX = 18

LOWPOS          = 23
HEADLOWPOS      = 11
HIGHPOS         = 1

NUMEYECOLORS    = 6

        ; Jormungandr update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MJ_WaitBegin:   lda actXH+ACTI_PLAYER
                cmp #$f2                        ;Wait until player approaches the balcony
                bne MJ_Done
                ldy #$33
                jsr InactivateObject
                lda #MUSIC_NETHER+1
                jsr PlaySong
                ldx actIndex
                lda #LOWPOS*4                   ;Init Jormungandr vertical screen position
                sta screenPos
                lda #$ff
                sta lastScreenPos
                sta lastFrame
                lda #HP_JORMUNGANDR             ;Init health now
                sta actHp,x
                lda #PHASE_RISE
                sta frame
                sta decision
                sta eyeColor
                sta MJ_OldEyePos+2
                jsr MJ_SetPhase
MJ_Done:        rts

MoveJormungandr:lda lvlObjB+$33
                bmi MJ_WaitBegin
                jsr MJ_Redraw
                lda actHp,x
                bne MJ_Alive
                jmp MJ_Destroy
MJ_Alive:       ldy actFlash,x                  ;Hit
                cpy #COLOR_ONETIMEFLASH
                bcc MJ_Shake
                lda hitColorTbl-COLOR_ONETIMEFLASH,y
                sta Irq1_Bg3+1
MJ_Shake:       jsr Random                      ;Screen shake in all phases
                and #$01
                sta shakeScreen
                ldy phase
                lda phaseJumpLo,y
                sta MJ_PhaseJump+1
                lda phaseJumpHi,y
                sta MJ_PhaseJump+2
MJ_PhaseJump:   jmp $0000

MJ_Rise:        lda #HP_JORMUNGANDR             ;Keep resetting health to max. during
                sta actHp,x                     ;initial rise
                dec screenPos
                lda screenPos
                cmp #HIGHPOS*4
                bne MJ_RiseDone
                lda #PHASE_WAIT
                jsr MJ_SetPhase
MJ_RiseDone:
MJ_MoveShake:   ldy screenPos                   ;When Jormungandr moves, use the
                tya                             ;shaking effect to smooth scrolling
                and #$02
                eor #$02
                sta shakeScreen
MJ_AttackDone:
MJ_WaitDone:    rts

MJ_Wait:        lda eyeColor                    ;Restore white eye color now
                beq MJ_NormalEyeColor
                dec eyeColor
MJ_NormalEyeColor:
                lda #0
                sta frame
                lda #5
                sta actAttackD,x                ;Minor fire delay in next phase
                lda #PHASE_ATTACK
                ldy #60
MJ_WaitNextPhase:
                inc phaseTime
                cpy phaseTime
                bne MJ_WaitDone
MJ_SetPhase:    sta phase
                lda #$00
                sta phaseTime
                rts

MJ_Attack:      lda #1
                sta frame
                lda actAttackD,x
                bne MJ_FireDelay
                lda #<wdFlameThrower
                sta wpnLo
                lda #>wdFlameThrower
                sta wpnHi
                ldy #WD_BITS
                lda (wpnLo),y
                sta wpnBits
                lda #<(-$240)
                sta temp1
                lda #>(-$240)
                sta temp2
                lda #<($100)
                sta temp3
                lda #>($100)
                sta temp4
                lda #$ff
                sta tgtActIndex
                lda #8
                sta AH_FireDir+1
                jsr AttackCustomOffset
                ldy tgtActIndex
                bmi MJ_FireDone
                lda #-60
                sta actSX,y
                lda phaseTime
                lsr
                and #$0f
                tax
                lda fireWaveTbl,x           ;Custom firing angle
                sta actSY,y
                ldx actIndex
                jmp MJ_FireDone
MJ_FireDelay:   dec actAttackD,x
MJ_FireDone:    lda #PHASE_WAITDECISION
                ldy #100
                jmp MJ_WaitNextPhase

MJ_WaitDecision:lda #0
                sta frame
                lda #5
                sta actAttackD,x                ;Minor fire delay in next phase
                lda phaseTime
                bne MJ_HasDecision
                ldy #PHASE_ATTACK
                jsr Random
                and #$7f
                adc #$30
                adc decision
                bcs MJ_DoMineAttackNext
                sta decision
                bpl MJ_DoFlameAttackNext
MJ_DoMineAttackNext:
                ldy #PHASE_MINESDOWN
MJ_DoFlameAttackNext:
                sty MJ_HasDecision+1
MJ_HasDecision: lda #PHASE_ATTACK
                cmp #PHASE_MINESDOWN
                bne MJ_NoEyeAnim
                ldy phaseTime                   ;If going to do mine attack,
                cpy #25                         ;darken eye after one second
                bcc MJ_NoEyeAnim
                ldy eyeColor                    ;Darken eye now
                cpy #NUMEYECOLORS-1
                bcs MJ_NoEyeAnim
                inc eyeColor
MJ_NoEyeAnim:   ldy #60
                jmp MJ_WaitNextPhase

MJ_MinesDown:   lda #$00                        ;Reset mine phase accumulator
                sta decision
                jsr MJ_SpawnMines
                lda screenPos
                cmp #HEADLOWPOS*4
                bcs MJ_MinesDownWait
                inc screenPos
                jmp MJ_MoveShake
MJ_MinesDownWait:
                lda #PHASE_MINESUP
                ldy #25
                jmp MJ_WaitNextPhase

MJ_MinesUp:     jsr MJ_SpawnMines
                dec screenPos
                lda screenPos
                cmp #HIGHPOS*4
                bne MJ_MinesUpDone
                lda #PHASE_WAIT                 ;Always flame at least once after mines
                jsr MJ_SetPhase
MJ_MinesUpDone: jmp MJ_MoveShake

MJ_SpawnMines:  lda actAttackD,x
                bne MJ_SpawnMineDelay
                jsr GetFreeNPC
                bcc MJ_NoRoomForMine
                lda #ACT_ROLLINGMINE
                jsr SpawnActor
                tya
                tax
                jsr InitActor
                lda #-12*8
                sta actSY,x
                lda #-8*8
                sta actSX,x
                lda #$80
                sta actD,x                      ;Head left
                lda #AIMODE_BERZERK
                sta actAIMode,x
                lda #SFX_SHOTGUN
                jsr PlaySfx
                ldx actIndex
                lda #40
                sta actAttackD,x
MJ_NoRoomForMine:
                rts
MJ_SpawnMineDelay:
                dec actAttackD,x
                rts

MJ_Destroy:     jsr Random
                pha
                and #$03
                sta shakeScreen
                pla
                clc
                and #$7f
                adc actFall,x
                sta actFall,x
                bcc MJ_NoExplosion
                jsr GetAnyFreeActor
                bcc MJ_NoExplosion
                inc screenPos
                inc screenPos
                lda screenPos
                cmp #LOWPOS*4
                bcs MJ_DestroyDone
                lda #$01
                sta Irq1_Bg3+1
                lda #$0e
                sta Irq1_Bg2+1
                jsr MJ_GetOffsetSub
                lda temp1
                sta temp3
                lda temp2
                sta temp4
                jsr MJ_GetOffsetSub
                jsr SpawnWithOffset
                tya
                tax
                jsr ExplodeActor                ;Play explosion sound & init animation
                ldx actIndex
                rts
MJ_NoExplosion: jmp SetZoneColors
MJ_DestroyDone: ldx actIndex
                jsr RemoveActor
                lda #PLOT_DISRUPTCOMMS          ;Construct fooled?
                jsr GetPlotBit
                beq MJ_TriggerEnding            ;If not, game ends now
                ldy #$33                        ;Exit door opens
                jsr ActivateObject
                lda #PLOT_ELEVATOR2             ;Elevator usable now
                jsr SetPlotBit
                lda #MUSIC_NETHER
                jmp PlaySong
MJ_TriggerEnding:
                lda #<EP_ENDING1
                ldx #>EP_ENDING1
                jmp ExecScript

MJ_GetOffsetSub:jsr Random
                pha
                sec
                sbc #15*8
                sta temp1
                pla
                and #$01
                sbc #$00
                sta temp2
MJ_NoRedraw:    rts

MJ_Redraw:      lda screenPos
                lsr
                lsr
                sta temp1
                cmp lastScreenPos
                bne MJ_NeedRedraw
                lda frame
                cmp lastFrame
                bne MJ_NeedRedraw
                lda lastScreenPos               ;Do not redraw eye color if it's clipped to bottom
                cmp #HEADLOWPOS                 ;(would cause glitch in blank char which is supposed to
                bcs MJ_NoRedraw                 ;have black color)
                ldy eyeColor
                lda eyeColorTbl,y
                jmp MJ_EraseEye
MJ_NeedRedraw:  lda #$00
                sta temp2
                lda temp1
                ldy #6
MJ_MakeActorPos:asl
                rol temp2
                dey
                bne MJ_MakeActorPos
                and #$c0
                ldy frame
                clc
                adc frameActorYLOfs,y
                sta actYL,x                     ;Set actor position based on screen position
                lda temp2
                ;adc frameActorYHOfs,y
                adc #$73
                sta actYH,x
                lda frameActorXL,y
                sta actXL,x
                ;lda frameActorXH,y
                lda #$f7
                sta actXH,x
                lda #$08
                jsr MJ_EraseEye
                lda oldHornsPos
                sta zpDestLo
                cmp #<(screen2+SCROLLROWS*40)   ;Erase the old horns from the top row
                lda oldHornsPos+1               ;in case moved down
                bpl MJ_NoOldPos
                sta zpDestHi
                sbc #>(screen2+SCROLLROWS*40)
                bpl MJ_NoOldPos
                ldy #10
                lda #$00
                sta (zpDestLo),y
                iny
                sta (zpDestLo),y
MJ_NoOldPos:    ldy frame
                sty lastFrame
                lda frameTblLo,y
                sta zpSrcLo
                lda frameTblHi,y
                sta zpSrcHi
                lda temp1
                sta lastScreenPos
                ldy #40
                ldx #<zpDestLo
                jsr MulU
                lda #JORMUNGANDR_OFFSETX
                jsr Add8
                ldy lastFrame
                lda zpDestLo
                clc
                adc frameEyePosLo,y
                sta MJ_EyePos+1
                lda zpDestHi
                adc frameEyePosHi,y
                ora #>colors
                sta MJ_EyePos+2                 ;Calculate & draw new eye color,
                lda MJ_EyePos+1                 ;if it's not outside screen
                cmp #<(colors+SCROLLROWS*40)
                lda MJ_EyePos+2
                sbc #>(colors+SCROLLROWS*40)
                bpl MJ_NoNewEye
                ldy eyeColor
                lda eyeColorTbl,y
MJ_EyePos:      sta $1000
                lda MJ_EyePos+1
                sta MJ_OldEyePos+1
                lda MJ_EyePos+2
                sta MJ_OldEyePos+2
MJ_NoNewEye:    lda zpDestHi
                ora #>screen2
                sta zpDestHi
                sta oldHornsPos+1               ;Remember last position of the top row (horns)
                lda zpDestLo
                sta oldHornsPos
                lda #JORMUNGANDR_YSIZE
                sta zpLenLo
MJ_RowLoop:     lda zpDestLo
                cmp #<(screen2+SCROLLROWS*40)
                lda zpDestHi
                sbc #>(screen2+SCROLLROWS*40)
                bmi MJ_RowsNotDone
                jmp MJ_RowsDone
MJ_RowsNotDone: ldy #0
                repeat JORMUNGANDR_XSIZE
                lda (zpSrcLo),y
                sta (zpDestLo),y
                iny
                repend
                tya
                clc
                adc zpSrcLo
                sta zpSrcLo
                bcc MJ_NoSrcOver
                inc zpSrcHi
                clc
MJ_NoSrcOver:   lda zpDestLo
                adc #40
                sta zpDestLo
                bcc MJ_NoDestOver
                inc zpDestHi
MJ_NoDestOver:  dec zpLenLo
                beq MJ_RowsDone
                jmp MJ_RowLoop
MJ_RowsDone:    ldx actIndex
                rts

MJ_EraseEye:    ldy MJ_OldEyePos+2
                bpl MJ_NoOldEye
MJ_OldEyePos:   sta $1000
RHW_NoActor:
RHW_HasItem:
MJ_NoOldEye:    rts

        ; Variables

screenPos:      dc.b 0
lastScreenPos:  dc.b 0
frame:          dc.b 0
lastFrame:      dc.b 0
phase:          dc.b 0
phaseTime:      dc.b 0
decision:       dc.b 0
eyeColor:       dc.b 0
oldHornsPos:    dc.w 0

        ; Phase jumptable

phaseJumpLo:    dc.b <MJ_Rise
                dc.b <MJ_Wait
                dc.b <MJ_Attack
                dc.b <MJ_WaitDecision
                dc.b <MJ_MinesDown
                dc.b <MJ_MinesUp

phaseJumpHi:    dc.b >MJ_Rise
                dc.b >MJ_Wait
                dc.b >MJ_Attack
                dc.b >MJ_WaitDecision
                dc.b >MJ_MinesDown
                dc.b >MJ_MinesUp

        ; Frame related data

frameTblLo:     dc.b <frame0,<frame1
frameTblHi:     dc.b >frame0,>frame1
frameEyePosLo:  dc.b <247,<286
frameEyePosHi:  dc.b >247,>286
frameActorYLOfs:dc.b $40,$80
;frameActorYHOfs:dc.b $73,$73                        ;Depends on Jormungandr's lair position on the game map
frameActorXL:   dc.b $40,$00
;frameActorXH:   dc.b $f7,$f7                        ;Depends on Jormungandr's lair position on the game map

hitColorTbl:    dc.b $01,$0e

fireWaveTbl:    dc.b 3,6,9,12,15,18,21,24,21,18,15,12,9,6,3,0

eyeColorTbl:    dc.b $09,$0f,$0f,$0f,$0f,$0a

        ; Char graphics

frame0:         dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$d1,$d2,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$d3,$d4,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$4c,$4d,$4e,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$4f,$50,$51,$52,$5b,$5c,$5d,$5e,$67,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$49,$53,$54,$55,$56,$5f,$60,$61,$62,$68,$69,$6a,$00
                dc.b $00,$00,$00,$00,$00,$00,$4a,$4b,$57,$58,$59,$5a,$63,$64,$65,$66,$00,$6b,$6c,$00
                dc.b $00,$00,$00,$00,$6d,$6e,$6f,$70,$7d,$7e,$7f,$fe,$87,$88,$89,$8a,$00,$00,$97,$00
                dc.b $00,$00,$6d,$a0,$71,$72,$73,$f7,$80,$81,$82,$fe,$8b,$8c,$8d,$8e,$00,$98,$99,$00
                dc.b $00,$a1,$a2,$a3,$75,$76,$77,$78,$83,$84,$85,$86,$8f,$90,$91,$92,$9a,$9b,$9c,$00
                dc.b $00,$a4,$a5,$a6,$79,$7a,$7b,$7c,$fe,$fe,$fe,$fe,$93,$94,$95,$96,$9d,$9e,$9f,$00
                dc.b $00,$a7,$a8,$a9,$ab,$ac,$fe,$ad,$b6,$78,$b7,$b8,$bc,$bd,$be,$bf,$c7,$c8,$c9,$00
                dc.b $00,$00,$00,$aa,$ae,$af,$b0,$b1,$00,$00,$b9,$ba,$fe,$c0,$fe,$fe,$ca,$cb,$00,$00
                dc.b $00,$00,$00,$00,$00,$b2,$b3,$6a,$00,$00,$00,$bb,$c1,$fe,$fe,$c2,$cc,$cd,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$b4,$b5,$00,$00,$00,$74,$c3,$c4,$c5,$c6,$ce,$9d,$6a,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cf,$fe,$fe,$fe,$fe,$bf,$c7,$d0,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$b9,$ba,$fe,$c0,$fe,$fe,$ca,$cb,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$bb,$c1,$fe,$fe,$c2,$cc,$cd,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$74,$c3,$c4,$c5,$c6,$ce,$9d,$6a
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cf,$fe,$fe,$fe,$fe,$bf,$c7,$d0
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$b9,$ba,$fe,$c0,$fe,$fe,$ca,$cb
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$bb,$c1,$fe,$fe,$c2,$cc,$cd

frame1:         dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$d1,$d2,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$d3,$d4,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$4c,$4d,$4e,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$4f,$50,$51,$52,$5b,$5c,$5d,$5e,$67,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$49,$53,$54,$55,$56,$5f,$60,$61,$62,$68,$69,$6a,$00,$00
                dc.b $00,$00,$00,$00,$00,$4a,$4b,$57,$58,$59,$5a,$63,$64,$65,$66,$00,$6b,$6c,$00,$00
                dc.b $00,$00,$00,$6d,$6e,$6f,$70,$7d,$7e,$7f,$fe,$87,$88,$89,$8a,$00,$00,$97,$00,$00
                dc.b $00,$6d,$a0,$71,$72,$73,$f7,$80,$81,$82,$fe,$8b,$8c,$8d,$8e,$00,$98,$99,$00,$00
                dc.b $a1,$a2,$a3,$75,$76,$77,$78,$83,$84,$85,$86,$8f,$90,$91,$92,$9a,$9b,$9c,$00,$00
                dc.b $a4,$a5,$a6,$79,$7a,$7b,$7c,$fe,$fe,$fe,$fe,$93,$94,$95,$96,$9d,$9e,$9f,$00,$00
                dc.b $a7,$a8,$a9,$ab,$ac,$fe,$ad,$b6,$78,$b7,$b8,$bc,$bd,$be,$bf,$c7,$c8,$c9,$00,$00
                dc.b $00,$00,$aa,$ae,$af,$b0,$b1,$00,$00,$b9,$ba,$fe,$c0,$fe,$fe,$ca,$cb,$00,$00,$00
                dc.b $00,$00,$00,$00,$b2,$b3,$6a,$00,$00,$00,$bb,$c1,$fe,$fe,$c2,$cc,$ff,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$b4,$b5,$00,$00,$00,$74,$c3,$fe,$c4,$c5,$c6,$ce,$9d,$6a,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cf,$fe,$fe,$fe,$fe,$bf,$c7,$d0,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$b9,$ba,$fe,$c0,$fe,$fe,$ca,$cb,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$bb,$c1,$fe,$fe,$c2,$cc,$cd,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$74,$c3,$c4,$c5,$c6,$ce,$9d,$6a
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cf,$fe,$fe,$fe,$fe,$bf,$c7,$d0
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$b9,$ba,$fe,$c0,$fe,$fe,$ca,$cb

                checkscriptend
