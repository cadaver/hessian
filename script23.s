                include macros.s
                include mainsym.s

        ; Script 23, cutscenes & endsequence

                org scriptCodeStart

                dc.w ShowCutscene
                dc.w EndSequence

ShowCutscene:   jmp CenterPlayer

EndSequence:    jsr SetupTextScreen
                lda #5
                sta temp2
                lda #0
                sta temp1
                cpy #1
                bcc Ending1
                beq Ending2
Ending3:        lda #<txtEnding3
                ldx #>txtEnding3
                jsr PrintMultipleRows
                lda #<3750
                ldy #>3750
                jsr EndingBonus
                lda #MUSIC_ENDING2
                jmp EndingCommon

Ending2:        lda #<txtEnding2
                ldx #>txtEnding2
                bne DestructionEndingCommon

Ending1:        lda #<txtEnding1
                ldx #>txtEnding1
DestructionEndingCommon:
                jsr PrintMultipleRows
                lda #<2500
                ldy #>2500
                jsr EndingBonus
                lda #MUSIC_ENDING1
EndingCommon:   ldx #$00                        ;Kill sound effects so the music will play properly
                stx ntChnSfx
                stx ntChnSfx+7
                stx ntChnSfx+14
                jsr PlaySong
                jsr StopScript
                lda score
                ldx score+1
                ldy score+2
                jsr ConvertToBCD24
                ldx #0
                lda temp8
                jsr EndingBCD
                lda temp7
                jsr EndingBCD
                lda temp6
                jsr EndingBCD
                ldx #txtTime-txtScore
                lda time
                jsr ConvertToBCD8
                lda temp6
                jsr StoreOneDigit
                inx
                lda time+1
                jsr ConvertToBCD8
                lda temp6
                jsr EndingBCD
                inx
                lda time+2
                jsr ConvertToBCD8
                lda temp6
                jsr EndingBCD
                lda #11
                sta temp2
                lda #9
                sta temp1
                lda #<txtFinalScore
                ldx #>txtFinalScore
                jsr PrintMultipleRows
                jsr WaitForExit
                jsr FadeSong
                jsr SetupTextScreen
                ldx #STACKSTART
                txs
                jmp UM_SaveGame

        ; Score/time subroutines

EndingBCD:      pha
                lsr
                lsr
                lsr
                lsr
                jsr StoreDigit
                pla
StoreOneDigit:  and #$0f
StoreDigit:     ora #$30
                sta txtScore,x
                inx
                rts

        ; Ending bonus subroutine

EndingBonus:    sta temp1
                sty temp2
                ldy saveDifficulty
                lda plrDmgModifyTbl,y
                lsr
                tax
EB_Loop:        lda temp1
                ldy temp2
                jsr AddScore
                dex
                bne EB_Loop
                rts

        ; Placeholder ending texts

                     ;0123456789012345678901234567890123456789
txtEnding1:     dc.b "  THE CONSTRUCT HACKS AUTOMATED SECOND",0
                dc.b "STRIKE SYSTEMS TO ATTACK RANDOM TARGETS.",0
                dc.b " RETALIATIONS FOLLOW. UNDER A BLACKENED",0
                dc.b "  SUN, A GRIM AGE OF SURVIVAL BEGINS..",0,0

                     ;0123456789012345678901234567890123456789
txtEnding2:     dc.b " JORMUNGANDR TRAVELS THE EARTH'S CRUST.",0
                dc.b "VOLCANIC ERUPTIONS BLACKEN THE SUN UNDER",0
                dc.b "HEAVY ASH CLOUDS. A GRIM AGE OF SURVIVAL",0
                dc.b " IN THE BITTER COLD IS ABOUT TO BEGIN..",0,0

                      ;0123456789012345678901234567890123456789
txtEnding3:     dc.b "  JORMUNGANDR AND CONSTRUCT ARE NO MORE",0
                dc.b "  MANKIND IS ONCE AGAIN FREE TO DESTROY",0
                dc.b "       ITSELF WITHOUT OUTSIDE AID",0,0

txtFinalScore:  dc.b " FINAL SCORE "
txtScore:       dc.b "0000000",0
                dc.b " ",0
                dc.b "  FINAL TIME "
txtTime:        dc.b "0:00:00",0
                dc.b " ",0
                dc.b "PRESS FIRE TO CONTINUE",0,0
                     ;0123456789012345678901

                checkscriptend