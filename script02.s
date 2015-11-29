                include macros.s
                include mainsym.s

        ; Script 2, Jormungandr

                org scriptCodeStart

                dc.w MoveJormungandr
                dc.w DestroyJormungandr

PHASE_RISE      = 0
PHASE_WAIT      = 1

JORMUNGANDR_YSIZE = 19
JORMUNGANDR_XSIZE = 19
JORMUNGANDR_OFFSETX = 20

        ; Jormungandr update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveJormungandr:lda lvlObjB+$33
                bpl MJ_DoorClosed
                lda actXH+ACTI_PLAYER
                cmp #$f2                        ;Wait until player approaches the balcony
                bne MJ_WaitStart
                ldy #$33
                jsr InactivateObject
                lda #MUSIC_NETHER+1
                jsr PlaySong
                ldx actIndex
                lda #22                         ;Init Jormungandr vertical screen position
                sta screenPos
                lda #$ff
                sta lastScreenPos
                sta lastFrame
                lda #PHASE_RISE
                sta phase
MJ_Done:
MJ_WaitStart:   rts
MJ_DoorClosed:  jsr Random                      ;Constantly shake the screen during the fight
                and #$01
                sta shakeScreen
                ldy phase
                lda phaseJumpLo,y
                sta MJ_PhaseJump+1
                lda phaseJumpHi,y
                sta MJ_PhaseJump+2
MJ_PhaseJump:   jsr $0000
MJ_Redraw:      lda screenPos
                cmp lastScreenPos
                bne MJ_NeedRedraw
                lda actF1,x
                cmp lastFrame
                beq MJ_Done
MJ_NeedRedraw:  ldy actF1,x
                sty lastFrame
                lda frameTblLo,y
                sta zpSrcLo
                lda frameTblHi,y
                sta zpSrcHi
                lda screenPos
                lda #$00
                sta lastScreenPos
                ldy #40
                ldx #<zpDestLo
                jsr MulU
                lda #JORMUNGANDR_OFFSETX
                jsr Add8
                lda zpDestHi
                ora #>screen2
                sta zpDestHi
                lda #JORMUNGANDR_YSIZE
                sta zpLenLo
MJ_RowLoop:     lda zpDestLo
                cmp #<(screen2+SCROLLROWS*40)
                lda zpDestHi
                sbc #>(screen2+SCROLLROWS*40)
                bcs MJ_RowsNotDone
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

MJ_Rise:        lda #5
                jsr AnimationDelay
                bcc MJ_RiseDone
                dec screenPos
                bne MJ_RiseDone
                inc phase
MJ_RiseDone:    rts

MJ_Wait:        rts

        ; Jormungandr destroy routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DestroyJormungandr:
                stx DJ_RestX+1
                ldy #$33
                jsr ActivateObject
                lda #MUSIC_NETHER
                jsr PlaySong
DJ_RestX:       ldx #$00
                rts

        ; Variables

screenPos:      dc.b 0
lastScreenPos:  dc.b 0
lastFrame:      dc.b 0
phase:          dc.b 0

        ; Phase jumptable

phaseJumpLo:    dc.b <MJ_Rise
                dc.b <MJ_Wait

phaseJumpHi:    dc.b >MJ_Rise
                dc.b >MJ_Wait

        ; Frametable
        
frameTblLo:     dc.b <frame0
frameTblHi:     dc.b >frame0

        ; Char graphics

frame0:         dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$d1,$d2,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$d3,$d4,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$4c,$4d,$4e,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$4f,$50,$51,$52,$5b,$5c,$5d,$5e,$67,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$49,$53,$54,$55,$56,$5f,$60,$61,$62,$68,$69,$6a
                dc.b $00,$00,$00,$00,$00,$00,$4a,$4b,$57,$58,$59,$5a,$63,$64,$65,$66,$00,$6b,$6c
                dc.b $00,$00,$00,$00,$6d,$6e,$6f,$70,$7d,$7e,$7f,$fe,$87,$88,$89,$8a,$00,$00,$97
                dc.b $00,$00,$6d,$a0,$71,$72,$73,$74,$80,$81,$82,$fe,$8b,$8c,$8d,$8e,$00,$98,$99
                dc.b $00,$a1,$a2,$a3,$75,$76,$77,$78,$83,$84,$85,$86,$8f,$90,$91,$92,$9a,$9b,$9c
                dc.b $00,$a4,$a5,$a6,$79,$7a,$7b,$7c,$fe,$fe,$fe,$fe,$93,$94,$95,$96,$9d,$9e,$9f
                dc.b $00,$a7,$a8,$a9,$ab,$ac,$fe,$ad,$b6,$78,$b7,$b8,$bc,$bd,$be,$bf,$c7,$c8,$c9
                dc.b $00,$00,$00,$aa,$ae,$af,$b0,$b1,$00,$00,$b9,$ba,$fe,$c0,$fe,$fe,$ca,$cb,$00
                dc.b $00,$00,$00,$00,$00,$b2,$b3,$6a,$00,$00,$00,$bb,$c1,$fe,$fe,$c2,$cc,$cd,$00
                dc.b $00,$00,$00,$00,$00,$00,$b4,$b5,$00,$00,$00,$74,$c3,$c4,$c5,$c6,$ce,$9d,$6a
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$cf,$fe,$fe,$fe,$fe,$bf,$c7,$d0
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$b9,$ba,$fe,$c0,$fe,$fe,$ca,$cb
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$bb,$c1,$fe,$fe,$c2,$cc,$cd
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$74,$c3,$c4,$c5,$c6,$ce,$9d

                checkscriptend

