                include macros.s
                include mainsym.s

        ; Script 24, endsequence

                org scriptCodeStart

                dc.w EndSequence

EndSequence:    ldx #STACKSTART
                txs
                sty endingNum
                cpy #2
                bcc NoSurvivors
                lda #ACT_HACKER
                jsr FindLevelActor
                bcs HaveSurvivors
                lda #ACT_SCIENTIST3
                jsr FindLevelActor
                bcc NoSurvivors
HaveSurvivors:  inc endingNum
NoSurvivors:    ldx endingNum
                lda endingUpdateTblLo,x
                sta UpdateJump+1
                lda endingUpdateTblHi,x
                sta UpdateJump+2
                lda endingTxtTblLo,x
                sta EndingTextLo+1
                lda endingTxtTblHi,x
                sta EndingTextHi+1
                lda endingInitTblLo,x
                sta InitJump+1
                lda endingInitTblHi,x
                sta InitJump+2
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
                stx endingTime
                stx endingText
                stx actT+ACTI_PLAYER            ;Remove player
CopyChars:      lda textChars+$100,x            ;Copy text chars to be able to show text & level graphics mixed
                sta chars+$500,x
                lda textChars+$200,x
                sta chars+$600,x
                lda textChars+$300,x
                sta chars+$700,x
                inx
                bne CopyChars
                jsr StopScript
                jsr ConvertTime
InitJump:       jsr $1000
FrameLoop:      ldy #$01
                sty scrollSY
                dey
                sty scrollSX
                jsr ScrollLogic
                jsr DrawActors
                jsr FinishFrame
                jsr GetControls
                jsr ScrollLogic
UpdateJump:     jsr $1000
                jsr UA_NoShakeReset
                jsr FinishFrame
                lda endingText
                beq FrameLoop
                jsr FadeText
                jsr FadeText
                jsr GetFireClick
                bcs FinishEnding
                lda keyType
                bpl FinishEnding
                bmi FrameLoop
FinishEnding:   jsr SetupTextScreen
                jsr FadeSong
                lda #$00
                sta textFade
                sta $d01b                       ;Sprites on top of BG again
                jsr UTC_ScoreScreen
                lda #MUSIC_OFFICES+1
                jsr PlaySong
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
                lda #$06                        ;Restore normal fadetable
                ldx #$03
                jsr SetFadeTable
                jsr FadeTextIn
                jsr WaitForExit
                jsr FadeTextOut
                jsr BlankScreen
                jsr FadeSong
                jmp UM_SaveGame

        ; Ending init
        
InitEnding1:    lda #$02                        ;Use red/yellow for text fade
                ldx #$07
                jsr SetFadeTable
                ldy #ACTI_FIRSTITEM
                jsr InitEndingActor
                lda #$80                        ;Missile start pos.
                sta actXL,x
                lda #$00
                sta actYL,x
                lda #$fe
                sta actXH,x
                lda #$19
                sta actYH,x
                lda #72
                sta actF1,x
                jmp InitDestructionCommon

InitEnding2:
InitDestructionCommon:
                ldy #C_ENDING
                jsr EnsureSpriteFile
                lda #MUSIC_ENDING1
                jmp PlaySong

InitVictory:    lda #MUSIC_ENDING2
                jmp PlaySong

        ; Ending frame update

UpdateEnding1:  ldx #ACTI_FIRSTITEM
                lda actT,x
                beq UMC_UpdateMushroom
                jsr Random
                and #$01
                tay
                lda missileColorTbl,y
                sta actFlash,x
                lda #4*8
                jsr MoveActorX
                lda #6*8
                jsr MoveActorY
                lda actYH,x
                cmp #$26
                bcc UMC_NoExplode
UMC_Explode:    jsr RemoveActor
                jmp UMC_LargeFlash
UMC_NoExplode:  rts

UMC_EndFlash:   lda #$00
                sta endingTime
                jmp UMC_AnimateMushroom

UMC_UpdateMushroom:
                lda endingText          ;Only flashing once text is on
                bne UMC_EndFlash
                inc endingTime
                lda endingTime
                cmp #25
                beq UMC_CreateMushroom
                bcs UMC_AnimateMushroom
UMC_LargeFlash: cmp #$01
                bne UMC_NoColorConvert
                jsr ConvertScreenAndCharColors
UMC_NoColorConvert:
                jsr Random
                and #$03
                sta shakeScreen
                lsr
                tay
                lda missileColorTbl,y
                sta Irq1_Bg1+1
                sta Irq1_Bg2+1
                sta Irq1_Bg3+1
                rts
UMC_CreateMushroom:
                lda #$ff
                sta $d01b               ;Mushroom behind BG (fence)
                lda #ACTI_FIRSTITEM+1
                sta temp1
UMC_CreateMushroomLoop:
                ldy temp1
                jsr InitEndingActor
                lda mushroomXL-ACTI_FIRSTITEM-1,x
                sta actXL,x
                lda mushroomXH-ACTI_FIRSTITEM-1,x
                sta actXH,x
                lda mushroomYL-ACTI_FIRSTITEM-1,x
                sta actYL,x
                lda mushroomYH-ACTI_FIRSTITEM-1,x
                sta actYH,x
                lda mushroomF-ACTI_FIRSTITEM-1,x
                sta actF1,x
                inc temp1
                cpx #ACTI_FIRSTITEM+9
                bcc UMC_CreateMushroomLoop
UMC_AnimateMushroom:
                lda actF1+ACTI_FIRSTITEM+1
                cmp #4*3
                php
                jsr Random
                tay
                and #$01
                ora endingText
                eor #$01
                sta shakeScreen
                tya
                lsr
                and #$01
                tay
                plp
                bcc UMC_BrightFlash
                iny
UMC_BrightFlash:jsr UMC_SetFlashColors
                ldy endingTime
                cpy #37
                bcs UMC_NextMushroomFrame
                rts
UMC_NextMushroomFrame:
                ldx #ACTI_FIRSTITEM+1
                lda actF1,x
                cmp #7*3
                bcs UMC_MushroomLastFrame
                ldy #26
                sty endingTime
UMC_AnimateLoop:lda actF1,x
                clc
                adc #$03
                sta actF1,x
                inx
                cpx #ACTI_FIRSTITEM+10
                bcc UMC_AnimateLoop
UMC_NoTextYet:  rts
UMC_MushroomLastFrame:
                cpy #50                         ;Extra wait before printing text
                bcc UMC_NoTextYet
                jmp PrintEndingText

UMC_SetFlashColors:
                lda skyFlashTbl,y
                sta Irq1_Bg1+1
                lda groundFlashTbl,y
                sta Irq1_Bg2+1
                lda groundFlashTbl2,y
                sta Irq1_Bg3+1
                rts

UpdateEnding2:
UpdateVictory:
                clc
                rts

        ; Convert char color to postnuclear
        
ConvertScreenAndCharColors:
                ldx #$00
CC_ScreenColors:
                lda colors,x
                jsr ConvertColor
                sta colors,x
                lda colors+$100,x
                jsr ConvertColor
                sta colors+$100,x
                lda colors+$200,x
                jsr ConvertColor
                sta colors+$200,x
                lda colors+SCROLLROWS*40-$100,x
                jsr ConvertColor
                sta colors+SCROLLROWS*40-$100,x
                inx
                bne CC_ScreenColors
CC_CharColors:  lda charColors,x
                jsr ConvertColor
                sta charColors,x
                inx
                bpl CC_CharColors
                rts

ConvertColor:   and #$0f
                cmp #$0b
                bne CC_Done
                lda #$09
CC_Done:        rts

        ; Init actor for ending (index = Y)

InitEndingActor:jsr GFA_Found
                tya
                tax
                lda #ACT_ENDINGSPRITES
                sta actT,x              ;Missile
                jmp InitActor

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
                lsr
                ldy endingNum
                cpy #$02
                adc #$00                        ;If not destruction ending, add 50000 more
                tax
EB_Loop:        lda #<5000
                ldy #>5000
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

PrintEndingText:lda #0
                sta textFade
                lda #1
                sta textFadeDir
                sta endingText
                jsr UpdateTextColor
EndingTextLo:   lda #$00
EndingTextHi:   ldx #$00
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

FadeText:       lda textFade
                clc
                adc textFadeDir
                bmi FT_OverNeg
                cmp #4*2
                bcc FT_NotOverPos
                lda #4*2
                skip2
FT_OverNeg:     lda #0
FT_NotOverPos:  sta textFade
UpdateTextColor:lda textFade
                lsr
                lsr
                tax
                lda textFadeTbl,x
                ldy screen
                cpy #$02
                beq UTC_ScoreScreen
                ldx #34
UTC_Loop:       sta colors+40,x
                sta colors+80,x
                sta colors+120,x
                dex
                bpl UTC_Loop
                rts
UTC_ScoreScreen:ldx #$00
UTC_Loop2:      sta colors+$c0,x
                sta colors+$1c0,x
                inx
                bne UTC_Loop2
                rts

        ; Blocking fades (for time display)

FadeTextIn:     lda #1
                sta textFadeDir
FTI_Loop:       jsr FinishFrame
                jsr FadeText
                lda textFade
                cmp #4*2
                bcc FTI_Loop
                rts

FadeTextOut:    lda #-1
                sta textFadeDir
FTO_Loop:       jsr FinishFrame
                jsr FadeText
                lda textFade
                bne FTO_Loop
                rts

SetFadeTable:   sta textFadeTbl
                stx textFadeTbl+1
                rts

endingTxtTblLo: dc.b <txtEnding1
                dc.b <txtEnding2
                dc.b <txtEnding3a
                dc.b <txtEnding3b

endingTxtTblHi: dc.b >txtEnding1
                dc.b >txtEnding2
                dc.b >txtEnding3a
                dc.b >txtEnding3b

endingInitTblLo:dc.b <InitEnding1
                dc.b <InitEnding2
                dc.b <InitVictory
                dc.b <InitVictory

endingInitTblHi:dc.b >InitEnding1
                dc.b >InitEnding2
                dc.b >InitVictory
                dc.b >InitVictory

endingUpdateTblLo:
                dc.b <UpdateEnding1
                dc.b <UpdateEnding2
                dc.b <UpdateVictory
                dc.b <UpdateVictory

endingUpdateTblHi:
                dc.b >UpdateEnding1
                dc.b >UpdateEnding2
                dc.b >UpdateVictory
                dc.b >UpdateVictory

txtEnding1:     dc.b " HACKED 2ND STRIKE SYSTEMS ATTACK",0
                dc.b "IN RANDOM. RETALIATIONS ENSUE, AND",0
                dc.b "     A NUCLEAR WINTER BEGINS.",0,0

txtEnding2:     dc.b "JORMUNGANDR TRAVERSES THE CRUST.",0
                dc.b "MASSIVE VOLCANIC ERUPTIONS BLACKEN",0
                dc.b "THE SUN, AND A NEW ICE AGE BEGINS.",0,0

txtEnding3a:    dc.b "THE CONSTRUCT IS NO MORE. ALONE,",0
                dc.b "KIM PONDERS JORMUNGANDR'S WORDS -",0
                dc.b "IS SHE MORE MACHINE THAN HUMAN NOW?",0,0

txtEnding3b:    dc.b "THE CONSTRUCT IS NO MORE. THE ONLY",0
                dc.b "WITNESSES TO THE INCIDENT DECIDE TO",0
                dc.b "DISAPPEAR TO AVOID DETENTION..",0,0

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

MUSHROOMBASEX = $0680
MUSHROOMBASEY = $24b0

mushroomXL:     dc.b <MUSHROOMBASEX, <(MUSHROOMBASEX+24*8), <(MUSHROOMBASEX+48*8)
                dc.b <MUSHROOMBASEX, <(MUSHROOMBASEX+24*8), <(MUSHROOMBASEX+48*8)
                dc.b <MUSHROOMBASEX, <(MUSHROOMBASEX+24*8), <(MUSHROOMBASEX+48*8)
mushroomXH:     dc.b >MUSHROOMBASEX, >(MUSHROOMBASEX+24*8), >(MUSHROOMBASEX+48*8)
                dc.b >MUSHROOMBASEX, >(MUSHROOMBASEX+24*8), >(MUSHROOMBASEX+48*8)
                dc.b >MUSHROOMBASEX, >(MUSHROOMBASEX+24*8), >(MUSHROOMBASEX+48*8)
mushroomYL:     dc.b <MUSHROOMBASEY, <MUSHROOMBASEY, <MUSHROOMBASEY
                dc.b <(MUSHROOMBASEY+21*8), <(MUSHROOMBASEY+21*8), <(MUSHROOMBASEY+21*8)
                dc.b <(MUSHROOMBASEY+42*8), <(MUSHROOMBASEY+42*8), <(MUSHROOMBASEY+42*8)
mushroomYH:     dc.b >MUSHROOMBASEY, >MUSHROOMBASEY, >MUSHROOMBASEY
                dc.b >(MUSHROOMBASEY+21*8), >(MUSHROOMBASEY+21*8), >(MUSHROOMBASEY+21*8)
                dc.b >(MUSHROOMBASEY+42*8), >(MUSHROOMBASEY+42*8), >(MUSHROOMBASEY+42*8)
mushroomF:      dc.b 0,1,2,24,25,26,48,49,50


textFadeTbl:    dc.b 6,3,1
missileColorTbl:dc.b 1,7
skyFlashTbl:    dc.b 10,2,9
groundFlashTbl: dc.b 7,10,8
groundFlashTbl2:dc.b 1,7,12

textFade:       dc.b 0
textFadeDir:    dc.b 0
endingNum:      dc.b 0
endingTime:     dc.b 0
endingText:     dc.b 0

                checkscriptend