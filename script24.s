                include macros.s
                include mainsym.s

        ; Script 24, endsequence

                org scriptCodeStart

                dc.w EndSequence

EndSequence:    cpy #1
                bcc Ending1
                beq Ending2
Ending3:        ;lda #<3750
                ;ldy #>3750
                ;jsr EndingBonus
                lda #MUSIC_ENDING2
                jmp EndingCommon

Ending2:
Ending1:
DestructionEndingCommon:
                lda #MUSIC_ENDING1
EndingCommon:   pha
                jsr RemoveLevelActors
                lda #$02
                jsr ChangeLevel
                lda #$00
                sta actXH+ACTI_PLAYER
                sta mapX
                lda #$01
                sta blockX
                sta blockY
                lda #$1e
                sta actYH+ACTI_PLAYER
                sta mapY
                jsr FindPlayerZone              ;Load charset
                jsr RedrawScreen
                jsr SL_NewMapPos
                jsr SetZoneColors
                ldx #$00                        ;Kill sound effects so the music will play properly
                stx ntChnSfx
                stx ntChnSfx+7
                stx ntChnSfx+14
                stx actT+ACTI_PLAYER            ;Remove player
CopyChars:      lda textChars+$100,x            ;Copy text chars to be able to show text & level graphics mixed
                sta chars+$500,x
                lda textChars+$200,x
                sta chars+$600,x
                lda textChars+$300,x
                sta chars+$700,x
                inx
                bne CopyChars
                pla
                jsr PlaySong
                jsr StopScript
                jsr ConvertTime
EndingScroll:   lda #1
                sta scrollSY
                lda #$00
                sta scrollSX
                jsr ScrollLogic
                jsr DrawActors
                jsr FinishFrame
                lda scrCounter
                bne EndingScroll
                lda scrollCSY
                bne EndingScroll
                lda #<txtEnding1
                ldx #>txtEnding1
                jsr EndingPrintMultiple
                jsr FadeTextIn
                jsr WaitForExit
                jsr FadeTextOut
                jsr FadeSong
                jsr SetupTextScreen
                lda #$00
                jsr STC_ScoreScreen
                lda #MUSIC_OFFICES+1
                jsr PlaySong
                lda #<2500
                ldy #>2500
                jsr EndingBonus
                jsr ConvertScore
                lda #9
                sta temp1
                lda #6
                sta temp2
                lda saveDifficulty
                and #$01
                clc
                adc #<txtFinalScore
                ldx #>txtFinalScore
                jsr PrintMultipleRows
                jsr FadeTextIn
                jsr WaitForExit
                jsr FadeTextOut
                jsr BlankScreen
                jsr FadeSong
                ldx #STACKSTART
                txs
                jmp UM_SaveGame

        ; Score/time subroutines

ConvertScore:   lda score
                ldx score+1
                ldy score+2
                jsr ConvertToBCD24
                ldx #0
                lda temp8
                jsr EndingBCD
                lda temp7
                jsr EndingBCD
                lda temp6
                jmp EndingBCD

ConvertTime:    ldx #txtTime-txtScore
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
                lda saveDifficulty
                asl
                adc saveDifficulty
                asl
                tax
                ldy #$00
EB_CopyDifficultyText:
                lda txtDifficulties,x
                sta txtDifficulty,y
                inx
                iny
                cpy #$06
                bcc EB_CopyDifficultyText
                rts

        ; Delay subroutine

Delay:          jsr WaitBottom
                dex
                bne Delay
                rts

        ; Text print, using chars $80 ->

EndingPrintMultiple:
                ldy #1
                sty temp1
                sty temp2
                sta zpSrcLo
                stx zpSrcHi
EPM_Loop:       jsr EP_Continue
                inc temp2
                ldy #$00
                lda (zpSrcLo),y
                bne EPM_Loop
                rts

EP_Continue:    ldy temp2
                jsr GetRowAddress
                lda temp1
                jsr Add8
EP_Back:        ldy #$00
EP_Loop:        lda (zpSrcLo),y
                beq EP_Done
                ora #$80
                sta (zpDestLo),y
                iny
                bne EP_Loop
EP_Done:        iny
                tya
                ldx #zpSrcLo
                jmp Add8

        ; Set colors of text area

TextFadeCommon: jsr FinishFrame
                lda textFade
                lsr
                lsr
                tax
                lda textFadeTbl,x
                ldy screen
                cpy #$02
                beq STC_ScoreScreen
SetTextColors:  ldx #35
STC_Loop:       sta colors+40,x
                sta colors+80,x
                sta colors+120,x
                dex
                bpl STC_Loop
                rts
STC_ScoreScreen:ldx #$00
STC_Loop2:      sta colors+$c0,x
                sta colors+$1c0,x
                inx
                bne STC_Loop2
                rts


        ; Clear text area
        
ClearTextArea:  lda #$a0
                ldx #35
CTA_Loop:       sta screen1+40,x
                sta screen1+80,x
                sta screen1+120,x
                dex
                bpl CTA_Loop
                rts

FadeTextIn:     lda #$ff
                sta textFade
FTI_Loop:       inc textFade
                jsr TextFadeCommon
                cmp #1
                bne FTI_Loop
FTO_Done:       rts

FadeTextOut:    dec textFade
                bmi FTO_Done
                jsr TextFadeCommon
                jmp FadeTextOut

        ; Placeholder ending texts

txtEnding1:     dc.b "HACKED SECOND STRIKE SYSTEMS ATTACK",0
                dc.b "IN RANDOM, LEADING IN RETALIATIONS.",0
                dc.b "A GRIM AGE OF SURVIVAL BEGINS.",0,0

                     ;0123456789012345678901234567890123456789
;txtEnding2:     dc.b " JORMUNGANDR TRAVELS THE EARTH'S CRUST.",0
;                dc.b "VOLCANIC ERUPTIONS BLACKEN THE SUN UNDER",0
;                dc.b "HEAVY ASH CLOUDS. A GRIM AGE OF SURVIVAL",0
;                dc.b " IN THE BITTER COLD IS ABOUT TO BEGIN..",0,0

txtFinalScore:  dc.b "  COMPLETED ON "
txtDifficulty:  dc.b "XXXXXX",0
                dc.b " ",0
                dc.b " ",0
                dc.b " FINAL SCORE "
txtScore:       dc.b "0000000",0
                dc.b " ",0
                dc.b "  FINAL TIME "
txtTime:        dc.b "0:00:00",0
                dc.b " ",0
                dc.b " ",0
                dc.b "THANK YOU FOR PLAYING!",0,0

txtDifficulties:dc.b "EASY  "
                dc.b "MEDIUM"
                dc.b "HARD  "
                dc.b "INSANE"

textFadeTbl:     dc.b 6,3,1
textFade:        dc.b 0

                checkscriptend