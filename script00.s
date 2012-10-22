                include macros.s
                include mainsym.s

LOGOSTARTROW    = 2
TEXTSTARTROW    = 11
NUMTEXTROWS     = 8
NUMSAVES        = 5

LOAD_GAME       = 0
SAVE_GAME       = 1

                org scriptCodeStart

                dc.w TitleScreen

TitleScreen:    stx TitleScreenParam+1          ;Go to save screen (X>0) or main menu (X=0)
                jsr BlankScreen
                jsr ClearPanelText
                lda #0                          ;Reset fade variables
                sta logoFade
                sta textFade
                lda #1
                sta logoFadeDir
                sta textFadeDir
                jsr ClearActors                 ;Reset sprites
                jsr DrawActors

        ; Load the always resident sprites

                lda fileHi+C_COMMON             ;If not loaded yet, load the always
                bne SpritesLoaded               ;resident sprites
                ldy #C_COMMON
                jsr LoadSpriteFile
                ldy #C_WEAPON
                jsr LoadSpriteFile
                lda #HP_PLAYER                  ;Init health & fists item immediately
                sta actHp+ACTI_PLAYER           ;even before starting the game so that
                lda #ITEM_FISTS                 ;the panel looks nice
                sta invType

        ; Copy logo chars & clear screen

SpritesLoaded:  ldx #$00
CopyLogoLoop:   lda logoChars,x
                sta textChars+$300,x
                lda logoChars+$100,x
                sta textChars+$400,x
                lda logoChars+$200,x
                sta textChars+$500,x
                inx
                bne CopyLogoLoop
                lda #$00
                sta Irq1_Bg1+1
                sta scrollY
                sta menuMode
                lda #$02
                sta screen
                lda #$0f
                sta scrollX
                ldx #$00
                lda #$20
ClearScreenLoop:sta screen1,x
                sta screen1+$100,x
                sta screen1+$200,x
                sta screen1+$270,x
                inx
                bne ClearScreenLoop
                
        ; Print logo to screen

                ldx #23
PrintLogoLoop:
M               set 0
                repeat 7
                lda logoScreen+M*24,x
                sta screen1+M*40+8+LOGOSTARTROW*40,x
                lda #$00
                sta colors+M*40+8+LOGOSTARTROW*40,x
M               set M+1
                repend
                dex
                bpl PrintLogoLoop
                lda #$00                        ;Play the title song
                jsr PlaySong

TitleScreenParam:
                lda #$00
                beq MainMenu
                jmp SaveGame

        ; New game / load game choice
        
MainMenu:       jsr FadeOutText
                jsr ClearText
                lda #TEXTSTARTROW+2
                sta temp8
                lda #<txtNewGame
                ldx #>txtNewGame
                jsr PrintTextCenter
                inc temp8
                inc temp8
                lda #<txtLoadGame
                ldx #>txtLoadGame
                jsr PrintText
                lda #1
                sta textFadeDir
MainMenuLoop:   lda #11
                sta temp7
                lda mainMenuChoice
                asl
                ldx #4
                ldy #TEXTSTARTROW+2
                jsr DrawChoiceArrow
                jsr Update
                lda mainMenuChoice
                ldx #1
                jsr TitleMenuControl
                sta mainMenuChoice
                jsr GetFireClick
                bcc MainMenuLoop
                lda mainMenuChoice
                bne LoadGame
                jmp StartGame

        ; Load/save game
        
LoadGame:       lda #LOAD_GAME
LoadOrSaveGame: sta saveMode
                jsr FadeOutText
                jsr ClearText
                lda #TEXTSTARTROW
                sta temp8
                lda #<txtLoadSlot
                ldx #>txtLoadSlot
                ldy saveMode
                beq LoadTextOK
                lda #<txtSaveSlot
                ldx #>txtSaveSlot
LoadTextOK:     jsr PrintTextCenter
                lda #12
                sta temp7
                lda #TEXTSTARTROW+2
                sta temp8
                jsr ScanSaves
                lda #1
                sta textFadeDir
LoadGameLoop:   lda #10
                sta temp7
                lda saveSlotChoice
                ldx #NUMSAVES+1
                ldy #TEXTSTARTROW+2
                jsr DrawChoiceArrow
                jsr Update
                lda saveSlotChoice
                ldx #NUMSAVES
                jsr TitleMenuControl
                sta saveSlotChoice
                jsr GetFireClick
                bcc LoadGameLoop
                lda saveSlotChoice
                cmp #NUMSAVES
                bcs LoadGameCancel              ;Cancel load/save (TODO: save needs confirm step as data will be lost)
                ldx #F_SAVE
                jsr MakeFileName
                lda saveMode
                bne SaveGameExec
LoadGameExec:   jsr OpenFile                    ;Load the savegame now
                lda #<saveStateStart
                ldx #>saveStateStart
                jsr ReadSaveFile
                bcc LoadGameLoop                ;Fail
                jsr RestartCheckpoint           ;Success, start loaded game
                jmp MainLoop
LoadGameCancel: jmp MainMenu

        ; Save game

SaveGame:       lda #SAVE_GAME
                jmp LoadOrSaveGame
SaveGameExec:   jsr FadeOutText
                lda #<saveStateEnd
                sta zpDestLo
                lda #>saveStateEnd
                sta zpDestHi
                lda #<saveStateStart
                ldx #>saveStateStart
                jsr SaveFile
                jmp MainMenu

        ; Start new game

StartGame:      jsr FadeOutAll
InitPlayer:     lda #0
                ldx #NUM_SKILLS-1
IP_XPSkillLoop: sta xpLo,x
                sta plrSkills,x
                dex
                bpl IP_XPSkillLoop
                ldx #MAX_INVENTORYITEMS-1
IP_InvLoop:     sta invType,x
                sta invCount,x
                sta invMag,x
                dex
                bpl IP_InvLoop
                sta itemIndex
                sta levelUp
                lda #<FIRST_XPLIMIT
                sta xpLimitLo
                lda #1
                sta xpLevel
                sta invType                     ;1 = fists
                lda #$00
                sta saveLevelNum                ;Set startposition & level
                sta saveD
                sta saveYL
                lda #$80
                sta saveXL
                lda #6
                sta saveXH
                lda #2
                sta saveYH
                lda #ACT_PLAYER
                sta saveT
                jsr RCP_CreatePlayer
                jsr SaveCheckpoint              ;Save first checkpoint immediately
                jmp MainLoop

        ; Update controls, text & logo fade

Update:         jsr GetControls
                jsr FinishFrame_NoScroll
                jsr WaitBottom
                lda textFadeDir
                beq UC_TextDone
                clc
                adc textFade
                sta textFade
                cmp #$ff
                bne UC_TextNotOverLow
                inc textFade
                beq UC_StopTextFade
UC_TextNotOverLow: 
                cmp #16
                bne UC_TextNotOverHigh
                dec textFade
UC_StopTextFade:lda #0
                sta textFadeDir
UC_TextNotOverHigh:
                lda textFade
                lsr
                lsr
                tay
                lda textFadeTbl,y
                ldx #39
UC_UpdateTextLoop:
M               set 0
                repeat NUMTEXTROWS
                sta colors+TEXTSTARTROW*40+M*40,x
M               set M+1
                repend
                dex
                bpl UC_UpdateTextLoop
UC_TextDone:    lda logoFadeDir
                bne UC_HasLogoFade
                rts
UC_HasLogoFade: clc
                adc logoFade
                sta logoFade
                cmp #$ff
                bne UC_LogoNotOverLow
                inc logoFade
                beq UC_StopLogoFade
UC_LogoNotOverLow:
                cmp #16
                bne UC_LogoNotOverHigh
                dec logoFade
UC_StopLogoFade:lda #0
                sta logoFadeDir
UC_LogoNotOverHigh:
                lda logoFade
                lsr
                lsr
                tax
                lda logoFadeBg2Tbl,x
                sta Irq1_Bg2+1
                lda logoFadeBg3Tbl,x
                sta Irq1_Bg3+1
                lda logoFade
                asl
                and #$f8
                sta temp1
                ldx #23
UC_UpdateLogoLoop:
M               set 0
                repeat 7
                lda logoColors+M*24,x
                adc temp1
                tay
                lda logoFadeCharTbl-8,y
                sta colors+M*40+8+LOGOSTARTROW*40,x
M               set M+1
                repend
                dex
                bpl UC_UpdateLogoLoop
UC_LogoDone:    rts

        ; Wait until logo faded out
 
FadeOutAll:     lda #-1
                sta textFadeDir
FadeOutLogo:    lda #-1
                sta logoFadeDir
FOL_Wait:       jsr Update
                lda logoFade
                bne FOL_Wait
                rts

        ; Wait until text faded out

FadeOutText:    lda #-1
                sta textFadeDir
FOT_Wait:       jsr Update
                lda textFade
                bne FOT_Wait
                rts
        
        ; Clear text rows
        
ClearText:      lda #$20
                ldx #39
ClearTextLoop:
M               set 0
                repeat NUMTEXTROWS
                sta screen1+TEXTSTARTROW*40+M*40,x
M               set M+1
                repend
                dex
                bpl ClearTextLoop
                rts

        ; Print null-terminated text

PrintText:      sta zpSrcLo
                stx zpSrcHi
PTC_Done:       ldy temp8
                jsr GetRowAddress
                lda temp7
                jsr Add8
                ldy #$00
PrintTextLoop:  lda (zpSrcLo),y
                beq PrintTextDone
                sta (zpDestLo),y
                iny
                bne PrintTextLoop
PrintTextDone:  rts

        ; Print centered text
        
PrintTextCenter:sta zpSrcLo
                stx zpSrcHi
                lda #20
                sta temp7
                ldy #$00
PTC_Loop:       lda (zpSrcLo),y
                beq PTC_Done
                iny
                lda (zpSrcLo),y
                beq PTC_Done
                iny
                dec temp7
                bpl PTC_Loop

        ; Print choice arrow
        
DrawChoiceArrow:sta zpSrcLo
                stx zpSrcHi
                jsr GetRowAddress
                ldx #0
                ldy temp7
DCA_Loop:       lda #$20
                cpx zpSrcLo
                bne DCA_NoArrow
                lda #22
DCA_NoArrow:    sta (zpDestLo),y
                lda zpDestLo
                clc
                adc #40
                sta zpDestLo
                bcc DCA_NextRowOK
                inc zpDestHi
DCA_NextRowOK:  inx
                cpx zpSrcHi
                bcc DCA_Loop
                rts

        ; Get address of text row Y

GetRowAddress:  lda #40
                ldx #<zpDestLo
                jsr MulU
                lda zpDestHi
                ora #>screen1
                sta zpDestHi
                rts

        ; Scan savegames and print their descriptions

ScanSaves:      lda #0
                sta temp6
                ldx #1                          ;Always select "continue" in main menu after load/save
                stx mainMenuChoice
                ldx saveSlotChoice              ;If "cancel" selected, select first slot instead
                cpx #NUMSAVES
                bne ScanSaveLoop
                sta saveSlotChoice
ScanSaveLoop:   ldx #F_SAVE
                jsr MakeFileName
                jsr OpenFile
                lda #<saveStateBuffer
                ldx #>saveStateBuffer
                jsr ReadSaveFile
                bcs GetSaveDescription
                lda #<txtEmpty
                ldx #>txtEmpty
                jsr PrintText
SaveDone:       inc temp8
                inc temp6
                lda temp6
                cmp #NUMSAVES
                bcc ScanSaveLoop
                lda #<txtCancel
                ldx #>txtCancel
                jmp PrintText
GetSaveDescription:
                lda #<(saveLevelName-saveStateStart+saveStateBuffer)
                ldx #>(saveLevelName-saveStateStart+saveStateBuffer)
                jsr PrintText                   ;TODO: print level & XP
                jmp SaveDone

        ; Read an opened savefile. C=1 if read to the end
        
ReadSaveFile:   sta zpDestLo
                stx zpDestHi
                ldy #$00
                ldx #$00
RSF_Loop:       jsr GetByte
                bcs RSF_End
                sta (zpDestLo),y
                iny
                bne RSF_Loop
                inc zpDestHi
                inx
                bne RSF_Loop
RSF_End:        cpx #>(saveStateEnd-saveStateStart)
                bcc RSF_Empty
                bne RSF_NotEmpty
                cpy #<(saveStateEnd-saveStateStart)
RSF_Empty:
RSF_NotEmpty:   rts

        ; Pick choice by joystick up/down
        
TitleMenuControl:
                tay
                stx temp6
                lda joystick
                cmp prevJoy
                beq TMC_NoMove
                lsr
                bcc TMC_NotUp
                dey
                bpl TMC_NoMove
                ldy temp6
TMC_NoMove:     tya
                rts
TMC_NotUp:      lsr
                bcc TMC_NoMove
                iny
                cpy temp6
                bcc TMC_NoMove
                beq TMC_NoMove
                ldy #$00
                beq TMC_NoMove

saveMode:       dc.b 0
logoFade:       dc.b 0
textFade:       dc.b 0
logoFadeDir:    dc.b 1
textFadeDir:    dc.b 1
txtNewGame:     dc.b "START NEW GAME",0
txtLoadGame:    dc.b "CONTINUE GAME",0
txtLoadSlot:    dc.b "CONTINUE FROM SAVE",0
txtSaveSlot:    dc.b "PICK SLOT FOR SAVE",0
txtEmpty:       dc.b "EMPTY SLOT",0
txtCancel:      dc.b "CANCEL",0

logoFadeBg2Tbl: dc.b $00,$00,$06,$0e
logoFadeBg3Tbl: dc.b $00,$06,$0e,$03
logoFadeCharTbl:dc.b $08,$08,$08,$08,$08,$08,$08,$08
                dc.b $08,$0e,$08,$08,$08,$08,$08,$08
                dc.b $08,$0b,$08,$0e,$08,$08,$08,$0b
                dc.b $08,$09,$0a,$0b,$0c,$0d,$0e,$0f

textFadeTbl:    dc.b $00,$06,$03,$01

logoChars:      incbin bg/logo.chr
logoScreen:     incbin bg/logoscr.bin
logoColors:     incbin bg/logocol.bin

saveStateBuffer:ds.b saveStateEnd-saveStateStart,0