                include macros.s
                include mainsym.s

        ; Script 12, placeholder endings

                org scriptCodeStart

                dc.w Ending1
                dc.w Ending2
                dc.w Ending3

        ; Ending 1: Jormungandr destroyed
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: Various

Ending1:        jsr SetupTextScreen
                lda #5
                sta temp2
                lda #0
                sta temp1
                lda #<txtEnding1
                ldx #>txtEnding1
                jsr PrintMultipleRows
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
                ldx #STACKSTART
                txs
                jmp UM_SaveGame

        ; Ending 2: Construct destroyed
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: Various

Ending2:        jsr SetupTextScreen
                lda #5
                sta temp2
                lda #0
                sta temp1
                lda #<txtEnding2
                ldx #>txtEnding2
                jsr PrintMultipleRows
                lda #MUSIC_ENDING1
                jmp EndingCommon

        ; Ending 3: both destroyed
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: Various

Ending3:        jsr SetupTextScreen
                lda #5
                sta temp2
                lda #0
                sta temp1
                lda #<txtEnding3
                ldx #>txtEnding3
                jsr PrintMultipleRows
                lda #MUSIC_ENDING2
                jmp EndingCommon

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

                     ;0123456789012345678901234567890123456789
txtEnding1:     dc.b "MILITARY FAIL-DEADLY SYSTEMS ARE TRICKED",0
                dc.b "LEADING TO A NUCLEAR STRIKE AGAINST NON-",0
                dc.b "EXISTENT ENEMIES. A GRIM AGE OF SURVIVAL",0
                dc.b " UNDER A BLACKENED SUN WILL NOW BEGIN..",0,0

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