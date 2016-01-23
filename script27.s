                include macros.s
                include mainsym.s

        ; Script 27, placeholder endings

                org scriptCodeStart

                dc.w Ending1
                dc.w Ending2
                dc.w Ending3

        ; Ending 1: Jormungandr destroyed
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: Various

Ending1:        jsr FadeMusic
                jsr SetupTextScreen
                lda #<2500
                ldy #>2500
                jsr EndingBonus
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
                jsr ClearPanelText
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
                jsr SetupTextScreen
                jsr FadeMusicEnd
                ldx #STACKSTART
                txs
                jmp UM_SaveGame

        ; Ending 2: Construct destroyed
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: Various

Ending2:        jsr FadeMusic
                jsr SetupTextScreen
                lda #<2500
                ldy #>2500
                jsr EndingBonus
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

Ending3:        jsr FadeMusic
                jsr SetupTextScreen
                lda #<3750
                ldy #>3750
                jsr EndingBonus
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

        ; Music fade subroutine

FadeMusic:      lda fastLoadMode
                beq FM_Done                     ;Using fallback loader, no fade as there already are screen-blanking pauses
FadeMusicEnd:   lda PS_CurrentSong+1
                beq FM_Done                     ;No fade if game music off
FM_Loop:        lda Play_MasterVol+1
                beq FM_Done
                dec Play_MasterVol+1
                ldx #$06
FM_Delay:       jsr WaitBottom
                dex
                bne FM_Delay
                beq FM_Loop
FM_Done:        rts

        ; Final server room droid spawn positions

droidSpawnXH:   dc.b $3e,$43,$3e,$43
droidSpawnYH:   dc.b $30,$30,$37,$37
droidSpawnYL:   dc.b $00,$00,$ff,$ff
droidSpawnCtrl: dc.b JOY_DOWN|JOY_RIGHT,JOY_DOWN|JOY_LEFT,JOY_UP|JOY_RIGHT,JOY_UP|JOY_LEFT

        ; Eye firing pattern

eyeCtrlTbl:     dc.b JOY_DOWN|JOY_FIRE
                dc.b JOY_RIGHT|JOY_DOWN|JOY_FIRE
                dc.b JOY_RIGHT|JOY_FIRE
                dc.b JOY_RIGHT|JOY_DOWN|JOY_FIRE
                dc.b JOY_DOWN|JOY_FIRE
                dc.b JOY_LEFT|JOY_DOWN|JOY_FIRE
                dc.b JOY_LEFT|JOY_FIRE
                dc.b JOY_LEFT|JOY_DOWN|JOY_FIRE

eyeFrameTbl:    dc.b 2,1,0,1,2,3,4,3

        ; Final explosion Y-positions

explYTbl:       dc.b $31,$32,$33,$34,$35,$36,$33,$34

        ; Placeholder ending texts

                     ;0123456789012345678901234567890123456789
txtEnding1:     dc.b "MILITARY FAIL-DEADLY SYSTEMS ARE TRICKED",0
                dc.b "  TO LAUNCH AN ALL-OUT NUCLEAR STRIKE.",0
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