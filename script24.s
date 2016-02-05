                include macros.s
                include mainsym.s

        ; Script 24, endsequence

NUM_PAGES = 3

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
                sta textPageTblLo
                lda endingTxtTblHi,x
                sta textPageTblHi
                lda endingInitTblLo,x
                sta InitJump+1
                lda endingInitTblHi,x
                sta InitJump+2
                jsr EndingBonus
                jsr RemoveLevelActors
                jsr StopScript
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
                jsr Random                      ;Common per-frame random number
                sta temp1
UpdateJump:     jsr $1000
                jsr UA_NoShakeReset
                jsr FinishFrame
                lda pageNum
                bmi FrameLoop
                jsr UpdateText
NoFadeOut:      jsr GetFireClick
                bcs FinishEnding
                lda keyType
                bmi FrameLoop
FinishEnding:   jsr FadeSong
                jmp UM_SaveGame

        ; Ending init routines

InitEnding1:    lda #$02                        ;Use red/yellow for text fade
                ldx #$07
                sta textFadeTbl
                stx textFadeTbl+1
                ldy #ACTI_FIRSTITEM
                jsr InitEndingActor
                lda #$c0                        ;Missile start pos.
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

        ; Ending frame update routines

UpdateEnding1:  ldx #ACTI_FIRSTITEM
                lda actT,x
                beq UMC_UpdateMushroom
                lda temp1
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
                sta shakeScreen
                lda temp1
                and #$01
                ora #$02
                tay
                jmp UMC_SetFlashColors

UMC_UpdateMushroom:
                lda pageNum                 ;Only flashing (no shake) once text is on
                bpl UMC_EndFlash
                inc endingTime
                lda endingTime
                cmp #25
                beq UMC_CreateMushroom
                bcs UMC_AnimateMushroom
UMC_LargeFlash: cmp #$01
                bne UMC_NoColorConvert
                jsr ConvertScreenAndCharColors
UMC_NoColorConvert:
                lda temp1
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
                lda temp1
                and #$01
                sta shakeScreen
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
                lda #$00
                sta pageNum                     ;Allow text printing now
                rts

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
CC_ScreenColors:lda colors+SCROLLROWS*40-$300,x
                jsr ConvertColor
                sta colors+SCROLLROWS*40-$300,x
                lda colors+SCROLLROWS*40-$200,x
                jsr ConvertColor
                sta colors+SCROLLROWS*40-$200,x
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
                tay
                lda convertColorTbl,y
                rts

        ; Init actor for ending (index = Y)

InitEndingActor:jsr GFA_Found
                tya
                tax
                lda #ACT_ENDINGSPRITES
                sta actT,x              ;Missile
                jmp InitActor

        ; Ending bonus calculation + prepare the final score / final time texts

EndingBonus:    sta temp1
                sty temp2
                ldy saveDifficulty
                lda plrDmgModifyTbl,y
                lsr
                lsr
                ldy endingNum
                cpy #$02
                adc #$00                        ;If victory ending, add 50000 more
                tax
EB_Loop:        lda #<5000
                ldy #>5000
                jsr AddScore
                dex
                bne EB_Loop
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

        ; Ending text update

UpdateText:     lda textFade
                bne FadeText
                lda #1
                sta textFadeDir
                sta temp2
                sta pageDelay
                ldy pageNum
                lda textPosTbl,y
                sta temp1
                lda textPageTblLo,y
                ldx textPageTblHi,y
                sta zpSrcLo
                stx zpSrcHi
                iny
                cpy #NUM_PAGES
                bcc EPM_PageNotOver
                ldy #$00
EPM_PageNotOver:sty pageNum
                ldx #34
                lda #$a0
EPM_Clear:      sta screen1+40,x                ;Clear first before printing
                sta screen1+80,x
                sta screen1+120,x
                dex
                bpl EPM_Clear
EPM_RowLoop:    ldy temp2
                jsr GetRowAddress
                lda temp1
                jsr Add8
                ldy #$00
                lda (zpSrcLo),y
                beq FadeText                    ;Set initial colors after printing
EP_Loop:        lda (zpSrcLo),y
                beq EP_Done
                ora #$80
                sta (zpDestLo),y
                iny
                bne EP_Loop
EP_Done:        iny
                tya
                ldx #zpSrcLo
                jsr Add8
                inc temp2
                bne EPM_RowLoop

FadeText:       ldy #$00
                lda textFadeDir
                beq FT_NoFade
                clc
                adc textFade
                bmi FT_OverNeg
                cmp #2*2
                bcc FT_NotOverPos
                lda #2*2
                skip2
FT_OverNeg:     lda #0
                sty textFadeDir
FT_NotOverPos:  sta textFade
UpdateTextColor:lda textFade
                lsr
                tax
                lda textFadeTbl,x
                ldx #34
UTC_Loop:       sta colors+40,x
                sta colors+80,x
                sta colors+120,x
                dex
                bpl UTC_Loop
FT_DelayNotExceeded:
                rts
FT_NoFade:      inc pageDelay
                lda pageDelay
                cmp #250
                bcc FT_DelayNotExceeded
                dec textFadeDir                 ;Fade out text & switch page after a set time
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

textPageTblLo:  dc.b <txtEnding1
                dc.b <txtFinalScore
                dc.b <txtThanks
textPageTblHi:  dc.b >txtEnding1
                dc.b >txtFinalScore
                dc.b >txtThanks
textPosTbl:     dc.b 1,8,7

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

txtFinalScore:  dc.b "FINAL SCORE "
txtScore:       dc.b "0000000",0
                dc.b " ",0
                dc.b " FINAL TIME "
txtTime:        dc.b "0:00:00",0,0

txtThanks:      dc.b " THE END OF ",34,"HESSIAN",34,0
                dc.b " ",0
                dc.b "THANK YOU FOR PLAYING!",0,0

MUSHROOMBASEX = $06c0
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
skyFlashTbl:    dc.b 10,2,9,2
groundFlashTbl: dc.b 7,10,8,10
groundFlashTbl2:dc.b 1,7,12,15

convertColorTbl:dc.b 0,1,2,3,4,5,6,7,8,9,15,9,15,15,15,9

textFade:       dc.b 0
textFadeDir:    dc.b 0
endingNum:      dc.b 0
endingTime:     dc.b 0
pageDelay:      dc.b 0
pageNum:        dc.b $ff

                checkscriptend