                include macros.s
                include mainsym.s

        ; Script 0, title screen & game start/load/save

LOGOSTARTROW    = 1
TEXTSTARTROW    = 12
NUMTEXTROWS     = 8
NUMTITLEPAGES   = 4

LOAD_GAME       = 0
SAVE_GAME       = 1

TITLE_MOVEDELAY = 8
TITLE_PAGEDELAY = 564

CHEATSTRING_LENGTH = 4

logoStart       = chars
logoScreen      = chars+608
logoColors      = chars+608+168
titleTexts      = chars+608+168*2

;START_LEVEL     = $00                          ;Warehouse
;START_X         = $6780
;START_Y         = $1700

;START_LEVEL     = $01                          ;Courtyard
;START_X         = $0280
;START_Y         = $1700

;START_LEVEL     = $03                          ;Entrance, next to car park
;START_X         = $2980
;START_Y         = $1b00

;START_LEVEL     = $04                          ;Service tunnels
;START_X         = $5180
;START_Y         = $1b00

;START_LEVEL     = $04                          ;Service tunnels bridge
;START_X         = $5480
;START_Y         = $3000

;START_LEVEL      = $05                         ;Security center
;START_X          = $0b80
;START_Y          = $0f00

;START_LEVEL      = $05                         ;First upgrade lab
;START_X          = $0d80
;START_Y          = $0600

;START_LEVEL     = $06                          ;Upper labs
;START_X         = $0180
;START_Y         = $1700

;START_LEVEL     = $06                          ;Upper labs, next to recharger
;START_X         = $4b80
;START_Y         = $1300

;START_LEVEL     = $06                          ;Upper labs, next to recycler
;START_X         = $3780
;START_Y         = $1300

START_LEVEL     = $07                          ;First cave
START_X         = $1f80
START_Y         = $1c00

;START_LEVEL     = $07                          ;Large spider's lair
;START_X         = $4f80
;START_Y         = $3b00

;START_LEVEL     = $08                          ;Lower labs
;START_X         = $3780
;START_Y         = $4100

;START_LEVEL     = $0a                          ;Nether tunnel
;START_X         = $0080
;START_Y         = $5600

;START_LEVEL     = $0a                          ;Nether tunnel, next to the machine
;START_X         = $a580
;START_Y         = $7400

;START_LEVEL     = $0a                          ;Jormungandr
;START_X         = $ed80
;START_Y         = $7600

;START_LEVEL     = $0b                          ;Next to Bio-Dome
;START_X         = $4780
;START_Y         = $1700

;START_LEVEL      = $0d                         ;Server vault
;START_X          = $0180
;START_Y          = $2300

;START_LEVEL      = $0d                         ;Next to final server room
;START_X          = $3a80
;START_Y          = $3500

;START_LEVEL     = $0e                          ;Second cave
;START_X         = $1d80
;START_Y         = $1d00

;START_LEVEL     = $0c                          ;Security chief
;START_X         = $1980
;START_Y         = $1300

;START_LEVEL     = $0f                          ;Old tunnels
;START_X         = $0180
;START_Y         = $4a00

;START_LEVEL     = $0f                          ;Old tunnels lab
;START_X         = $6f80
;START_Y         = $4c00

                org scriptCodeStart

                dc.w TitleScreen

TitleScreen:    jsr BlankScreen
                lda #REDRAW_ITEM+REDRAW_AMMO+REDRAW_SCORE ;Redraw all
                sta panelUpdateFlags
                lda #$00                        ;Armor message no longer necessary,
                sta armorMsgTime                ;as game is over
                jsr ClearPanelText
                jsr InitScroll                  ;Make sure no scrolling

        ; Load logo chars & clear screen

                jsr StopScript
                stx ECS_LoadedCharSet+1         ;Mark game charset destroyed (X=$ff)
                lda #F_LOGO
                jsr MakeFileName_Direct
                lda #<logoStart
                ldx #>logoStart
                jsr LoadFileRetry
                lda #$00                        ;Fade out colors initially
                sta Irq1_Bg1+1
                sta Irq1_Bg2+1
                sta Irq1_Bg3+1
                sta menuMode                    ;Reset in-game menu mode
                lda #$03
                sta screen                      ;Set split screen mode
                lda #$0f
                sta scrollX
                ldx #$00
                stx SL_CSSScrollY+1
ClearScreenLoop:lda #$20
                sta screen1,x
                sta screen1+$100,x
                sta screen1+$200,x
                sta screen1+SCROLLROWS*40-$100,x
                lda #$00
                sta colors,x
                sta colors+$100,x
                sta colors+$200,x
                sta colors+SCROLLROWS*40-$100,x
                inx
                bne ClearScreenLoop

        ; Print logo to screen

                ldx #23
PrintLogoLoop:
M               set 0
                repeat 7
                lda logoScreen+M*24,x
                sta screen1+M*40+8+LOGOSTARTROW*40,x
M               set M+1
                repend
                dex
                bpl PrintLogoLoop
                lda #MUSIC_TITLE
                jsr PlaySong

        ; Go to either the title screen or save screen

                lda ES_ParamY+1                 ;Script execution parameter
                beq TitleTexts

        ; Save game

SaveGame:       lda #SAVE_GAME
                jmp LoadOrSaveGame
SaveGameExec:   jsr FadeOutText
                lda #<(saveStateEnd-saveStateStart) ;Save the savegame first
                sta zpBitsLo
                lda #>(saveStateEnd-saveStateStart)
                sta zpBitsHi
                lda #<saveStateStart
                ldx #>saveStateStart
                jsr SaveFile
                ldy #$00
SaveGetLevelName:
                lda levelNamesTbl,y             ;Levelnum
                bmi SGLN_NoCoords
                cmp saveStateZP
                bne SGLN_Next
                lda saveXH                      ;If there are coord limits, they must be listed
                cmp levelNamesTbl+1,y           ;in right->left and bottom->top order to work properly
                bcc SGLN_Next
                lda saveYH
                cmp levelNamesTbl+2,y
                bcs SGLN_Found
SGLN_Next:      iny
                iny
SGLN_Next2:     iny
                iny
                bne SaveGetLevelName            ;Note: will loop endlessly if name not found
SGLN_NoCoords:  and #$7f
                cmp saveStateZP
                bne SGLN_Next2
                dey
                dey
SGLN_Found:     ldx levelNamesTbl+3,y
                lda saveSlotChoice
                jsr GetSaveListPos
                adc #$10
                sta temp1
CopyLevelName:  lda levelNames,x                ;Copy level name until endzero
                sta saveList,y
                beq CLN_Done
                iny
                inx
                bne CopyLevelName
CLN_Done:       ldx #$00
                ldy temp1
CopySaveTime:   lda saveStateStart,x            ;Copy time
                sta saveList,y
                iny
                inx
                cpx #$04
                bcc CopySaveTime
                lda #F_SAVELIST
                jsr MakeFileName_Direct
                lda #<MAX_SAVES*SAVEDESCSIZE
                sta zpBitsLo
                lda #>MAX_SAVES*SAVEDESCSIZE
                sta zpBitsHi
                lda #<saveList
                ldx #>saveList
                jsr SaveFile                    ;Then save the savegamelist also

        ; Title text display

TitleTexts:     lda #0
TitleNextPage:  sta titlePage
                jsr FadeOutText
                jsr ClearText
                lda titlePage
                asl
                tay
                lda titleTexts,y
                ldx titleTexts+1,y
                jsr PrintPage
TitleTextsLoop: jsr Update
                jsr GetFireClick
                bcs EnterMainMenu
                jsr TitlePageDelay
                bcc TitleTextsLoop
                lda titlePage
                adc #$00
                cmp #NUMTITLEPAGES
                bcc TitleNextPage
                bcs TitleTexts

EnterMainMenu:  lda #SFX_SELECT
                jsr PlaySfx

        ; Main menu

MainMenu:       jsr FadeOutText
                jsr ClearText
                lda titleTexts+NUMTITLEPAGES*2
                ldx titleTexts+NUMTITLEPAGES*2+1
                jsr PrintPage
MainMenuLoop:   lda #11
                sta temp1
                lda mainMenuChoice
                asl
                ldx #5
                ldy #TEXTSTARTROW+1
                jsr DrawChoiceArrow
                jsr Update
                lda mainMenuChoice
                ldx #2
                jsr TitleMenuControl
                sta mainMenuChoice
                jsr GetFireClick
                bcs MainMenuSelect
                jsr TitlePageDelayInteractive
                bcc MainMenuLoop
                jmp TitleTexts                  ;Page delay expired, return to title
MainMenuSelect: lda #SFX_SELECT
                jsr PlaySfx
                ldx mainMenuChoice
                lda mainMenuJumpTblLo,x
                sta MainMenuJump+1
                lda mainMenuJumpTblHi,x
                sta MainMenuJump+2
MainMenuJump:   jmp $0000

        ; Options menu

Options:        lda #0
                sta optionsMenuChoice
                jsr FadeOutText
                jsr ClearText
                lda titleTexts+NUMTITLEPAGES*2+2
                ldx titleTexts+NUMTITLEPAGES*2+3
                jsr PrintPage
RefreshOptions: lda #22
                sta temp1
                ldy difficulty
                lda difficultyTxtLo,y
                ldx difficultyTxtHi,y
                ldy #TEXTSTARTROW
                jsr PrintOnOffCommon
                lda musicMode
                ldy #TEXTSTARTROW+2
                jsr PrintOnOff
                lda soundMode
                ldy #TEXTSTARTROW+4
                jsr PrintOnOff
OptionsLoop:    lda #10
                sta temp1
                lda optionsMenuChoice
                asl
                ldx #7
                ldy #TEXTSTARTROW
                jsr DrawChoiceArrow
                jsr Update
                lda optionsMenuChoice
                ldx #3
                jsr TitleMenuControl
                sta optionsMenuChoice
                jsr GetFireClick
                bcs OptionsSelect
                jsr TitlePageDelayInteractive
                bcc OptionsLoop
                jmp TitleTexts                  ;Page delay expired, return to title
OptionsSelect:  ldx optionsMenuChoice
                cpx #3
                bcs OptionsGoBack
                lda #$01
                sta optionsModified
                inc difficulty,x
                lda optionMaxValue,x
                cmp difficulty,x
                bcs OptionsNotOver
                lda #$00
                sta difficulty,x
OptionsNotOver: lda #SFX_SELECT
                jsr PlaySfx
                jsr RestartSong
                jmp RefreshOptions
OptionsGoBack:  lda #SFX_SELECT
                jsr PlaySfx
                jmp MainMenu

        ; Load/save game

LoadGame:       lda #LOAD_GAME
LoadOrSaveGame: sta LoadOrSaveGameMode+1
                jsr FadeOutText
                jsr ClearText
                lda #TEXTSTARTROW
                sta temp2
                lda #<txtLoadSlot
                ldx #>txtLoadSlot
                ldy LoadOrSaveGameMode+1
                beq LoadTextOK
                lda #<txtSaveSlot
                ldx #>txtSaveSlot
LoadTextOK:     jsr PrintTextCenter
                lda #TEXTSTARTROW+2
                sta temp2
                jsr ScanSaves
                jsr ResetPage
LoadGameLoop:   lda #6
                sta temp1
                lda saveSlotChoice
                ldx #MAX_SAVES+1
                ldy #TEXTSTARTROW+2
                jsr DrawChoiceArrow
                jsr Update
                lda saveSlotChoice
                ldx #MAX_SAVES
                jsr TitleMenuControl
                sta saveSlotChoice
                jsr GetFireClick
                bcc LoadGameLoop
                lda #SFX_SELECT
                jsr PlaySfx
                lda saveSlotChoice
                cmp #MAX_SAVES
                bcs LoadGameCancel              ;Cancel load/save (TODO: save needs confirm step as data will be lost)
                ldx #F_SAVE
                jsr MakeFileName
LoadOrSaveGameMode:
                lda #$00
                beq LoadGameExec
                jmp SaveGameExec
LoadGameExec:   lda saveSlotChoice
                jsr GetSaveListPos
                lda saveList,y                  ;No save at slot yet?
                beq LoadGameLoop
                jsr OpenFile                    ;Load the savegame file (unpacked)
                lda #<saveStateStart
                sta zpDestLo
                lda #>saveStateStart
                sta zpDestHi
                ldy #$00
RSF_Loop:       jsr GetByte
                bcs RSF_End
                sta (zpDestLo),y
                iny
                bne RSF_Loop
                inc zpDestHi
                bne RSF_Loop
RSF_End:        tay                             ;Check if load errored
                bne LoadGameLoop
                lda fastLoadMode                ;Fade out screen, unless in slowload mode
                beq LoadSkipFade
                jsr FadeOutAll
LoadSkipFade:   jsr SaveModifiedOptions
                jmp RestartCheckpoint           ;Start loaded game
LoadGameCancel: jmp MainMenu

        ; Start new game

StartNewGame:   jsr FadeOutAll
                jsr SaveModifiedOptions
InitPlayer:     lda #$00                        ;Init player state (level number, inventory selected item,
                ldx #playerStateZPEnd-playerStateZPStart-1 ;inventory items, plotbits, triggers)
IP_InitZPState: sta playerStateZPStart,x
                dex
                bpl IP_InitZPState
                ldx #playerStateZeroEnd-playerStateStart
IP_InitState:   sta playerStateStart-1,x
                dex
                bne IP_InitState
                ldx #MAX_LVLACT-1               ;No stored levelactors
IP_InitLevelActors:
                sta lvlActT,x
                dex
                bpl IP_InitLevelActors
                ldx #LVLOBJTOTALSIZE
IP_InitLevelObjects:
                sta lvlStateBits+LVLDATAACTTOTALSIZE-1,x ;Assume all persistent levelobjects are inactive
                dex                              ;at start
                bne IP_InitLevelObjects
                ldx #LVLDATAACTTOTALSIZE
                lda #$ff
IP_InitLevelData:
                sta lvlStateBits-1,x             ;Assume all leveldata-actors exist at start
                dex
                bne IP_InitLevelData
                ldx #ITEM_LAST-ITEM_FIRST+1     ;$ff=item not carried
IP_InitInventory:
                sta invCount-1,x
                dex
                bne IP_InitInventory
                lda #ITEM_FISTS
                sta itemIndex
                sta lastItemIndex
                lda #ITEM_FISTS
                ldx #1
                jsr AddItem
                if STARTITEM_CHEAT>0
                lda #ITEM_PISTOL
                ldx #20
                jsr AddItem
                lda #ITEM_PARTS
                ldx #50
                jsr AddItem
                endif
                jsr StopScript                  ;Stop any continuous script
                lda #START_LEVEL
                sta levelNum
                lda #$00
                sta reload
                sta battery
                sta saveD
                #if UPGRADE_CHEAT>0
                lda #$ff
                #endif
                sta upgrade                     ;Reset upgrade status
                lda #<START_X                   ;Set startposition
                sta saveXL
                lda #>START_X
                sta saveXH
                lda #<START_Y
                sta saveYL
                lda #>START_Y
                sta saveYH
                lda #ACT_PLAYER
                sta saveT
                lda #HP_PLAYER
                sta saveHP
                lda #MAX_BATTERY
                sta battery+1
                lda #MAX_OXYGEN
                sta oxygen
                sec                             ;Load first level's actors from disk
                jsr CreatePlayerActor
                if ALLQUESTITEMS_CHEAT>0
                lda #ITEM_WAREHOUSEPASS
IP_GiveAllLoop: sta temp1
                ldx #1
                jsr AddItem
                lda temp1
                adc #$00
                cmp #ITEM_HAZMATSUIT
                bcc IP_GiveAllLoop
                endif
                jsr FindPlayerZone              ;Need to get starting level's charset so that save is named properly
                jsr SaveCheckpoint              ;Save first in-memory checkpoint immediately
                jmp CenterPlayer

        ; Save options if modified

SaveModifiedOptions:
                lda optionsModified
                beq SMC_NoChange
                lda #F_OPTIONS
                jsr MakeFileName_Direct
                lda #<3
                sta zpBitsLo
                lda #>3
                sta zpBitsHi
                lda #<difficulty
                ldx #>difficulty
                jsr SaveFile
                lda #$00
                sta optionsModified
SMC_NoChange:   rts

        ; Update controls, text & logo fade

Update:         jsr Random                      ;Make game different according to delay
                jsr FinishFrame
                jsr GetControls
                jsr WaitBottom

        ; Check for cheat string (on the title text loop)

CheckCheat:     lda keyType
                bmi CC_NoCheat
                ldx cheatIndex
                cmp cheatString,x
                bne CC_CheatWrong
                inc cheatIndex
                cpx #CHEATSTRING_LENGTH-1
                bcc CC_NoCheat
CC_ActivateCheat:
                lda DA_ResetRecharge+1          ;Disable player damage & battery drain
                eor #healTimer^temp7
                sta DA_ResetRecharge+1
                lda DrainBatteryRound
                eor #$69^$a9
                sta DrainBatteryRound
                lda #$01
                sta Irq1_Bg2+1                  ;Flash logo, then restore colors via the normal fadeout code
                sta Irq1_Bg3+1
                sta logoFadeDir
                jsr WaitBottom
CC_CheatWrong:  lda #$00
                sta cheatIndex
CC_NoCheat:

                lda textFadeDir
                beq UC_TextDone
                clc
                adc textFade
                sta textFade
                bpl UC_TextNotOverLow
                inc textFade
                beq UC_StopTextFade
UC_TextNotOverLow:
                cmp #12
                bcc UC_TextNotOverHigh
UC_StopTextFade:lda #0
                sta textFadeDir
UC_TextNotOverHigh:
                lda textFade
                lsr
                lsr
                tay
                lda textFadeTbl,y
                ldx #160
UC_UpdateTextLoop:
                sta colors+TEXTSTARTROW*40-1,x
                sta colors+TEXTSTARTROW*40+159,x
                dex
                bne UC_UpdateTextLoop
UC_TextDone:    lda logoFadeDir
                bne UC_HasLogoFade
                rts
UC_HasLogoFade: clc
                adc logoFade
                sta logoFade
                bpl UC_LogoNotOverLow
                inc logoFade
                beq UC_StopLogoFade
UC_LogoNotOverLow:
                cmp #12
                bcc UC_LogoNotOverHigh
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

        ; Load savegamelist and print savegame descriptions

ScanSaves:      lda #F_SAVELIST                 ;Load the savegamelist which contains levelnames & player state
                jsr MakeFileName_Direct         ;from all savegames
                jsr OpenFile
                lda #0
                sta actIndex
                ldx #1                          ;Always select "continue" in main menu after load/save
                stx mainMenuChoice
                ldx saveSlotChoice              ;If "cancel" selected last time, select first slot instead
                cpx #MAX_SAVES
                bne SaveSlotOK
                sta saveSlotChoice
SaveSlotOK:     tay
ReadSaveList:   jsr GetByte
                bcs ScanSaveLoop
                sta saveList,y
                iny
                bcc ReadSaveList
ScanSaveLoop:   lda #8
                sta temp1
                lda actIndex
                jsr GetSaveListPos
                sty temp8
                lda saveList,y
                bne GetSaveDescription
                lda #<txtEmpty
                ldx #>txtEmpty
                jsr PrintText
SaveDone:       inc temp2
                inc actIndex
                lda actIndex
                cmp #MAX_SAVES
                bcc ScanSaveLoop
                lda #8
                sta temp1
                lda #<txtCancel
                ldx #>txtCancel
                jmp PrintText
GetSaveDescription:
                lda #<saveList
                adc temp8                       ;Level name
                sta zpSrcLo
                lda #>saveList
                adc #$00
                sta zpSrcHi
                ldy #16                         ;Time hours
                lda (zpSrcLo),y
                jsr ConvertToBCD8
                ldx #0
                jsr PrintTimeBCD1
                ldy #17                         ;Time minutes
                lda (zpSrcLo),y
                jsr ConvertToBCD8
                ldx #2
                jsr PrintTimeBCD2
                ldy #18                         ;Time seconds
                lda (zpSrcLo),y
                jsr ConvertToBCD8
                ldx #5
                jsr PrintTimeBCD2
                jsr PrintTextContinue
                lda #<txtTime
                sta zpSrcLo
                lda #>txtTime
                sta zpSrcHi
                lda #25
                sta temp1
                jsr PrintTextContinue
                jmp SaveDone

        ; Pick choice by joystick up/down

TitleMenuControl:
                tay
                stx temp6
                ldx moveDelay
                beq TMC_NoDelay
                dec moveDelay
                rts
TMC_NoDelay:    lda joystick
                lsr
                bcc TMC_NotUp
                dey
                bpl TMC_HasMove
                ldy temp6
TMC_HasMove:    lda #SFX_SELECT
                jsr PlaySfx
                ldx #TITLE_MOVEDELAY
                lda joystick
                cmp prevJoy
                bne TMC_NormalDelay
                dex
                dex
                dex
TMC_NormalDelay:stx moveDelay
TMC_NoMove:     tya
                rts
TMC_NotUp:      lsr
                bcc TMC_NoMove
                iny
                cpy temp6
                bcc TMC_HasMove
                beq TMC_HasMove
                ldy #$00
                beq TMC_HasMove

        ; Title delay counting

TitlePageDelayInteractive:
                lda joystick                    ;Reset delay if joystick moved
                bne ResetTitlePageDelay
TitlePageDelay: inc titlePageDelayLo
                bne TPD_NotOver
                inc titlePageDelayHi
TPD_NotOver:    lda titlePageDelayHi
                cmp #>TITLE_PAGEDELAY
                bne TPD_Done
                lda titlePageDelayLo
                cmp #<TITLE_PAGEDELAY
TPD_Done:       rts

        ; Print page

PrintPage:      ldy #TEXTSTARTROW
                sty temp2
                jsr PrintTextCenter
                inc temp2
TitleRowLoop:   jsr PrintTextCenterContinue
                inc temp2
                lda temp2
                cmp #TEXTSTARTROW+7
                bcc TitleRowLoop

        ; Reset title delay, set text to fade in

ResetPage:      lda #1
                sta textFadeDir
ResetTitlePageDelay:
                lda #0
                sta titlePageDelayLo
                sta titlePageDelayHi
FOT_Done:       rts

        ; Wait until text faded out

FadeOutAll:     lda #-1
                sta logoFadeDir
FadeOutText:    lda #-1
                sta textFadeDir
FOT_Wait:       lda textFade
                beq FOT_Done
                jsr Update
                jmp FOT_Wait

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

        ; Print on/off texts for the options

PrintOnOff:     cmp #$01
                lda #<txtOff
                ldx #>txtOff
                bcc PrintOnOffCommon
                lda #<txtOn
                ldx #>txtOn
PrintOnOffCommon:
                sty temp2

        ; Print null-terminated text

PrintText:      sta zpSrcLo
                stx zpSrcHi
PrintTextContinue:
                ldy temp2
                jsr GetRowAddress
                lda temp1
                jsr Add8
                ldy #$00
PrintTextLoop:  lda (zpSrcLo),y
                beq PrintTextDone
                sta (zpDestLo),y
                iny
                bne PrintTextLoop
PrintTextDone:  iny
                tya
                ldx #zpSrcLo
                jmp Add8

        ; Print centered text

PrintTextCenter:sta zpSrcLo
                stx zpSrcHi
PrintTextCenterContinue:
                lda #20
                sta temp1
                ldy #$00
PTC_Loop:       lda (zpSrcLo),y
                bmi PTC_SetAbsolute
                beq PrintTextContinue
                iny
                lda (zpSrcLo),y
                beq PrintTextContinue
                iny
                dec temp1
                bpl PTC_Loop
PTC_SetAbsolute:and #$7f
                sta temp1
                jsr PrintTextDone               ;Skip the negative byte, then print normally
                jmp PrintTextContinue

        ; Print choice arrow

DrawChoiceArrow:sta zpSrcLo
                stx zpSrcHi
                jsr GetRowAddress
                ldx #0
                ldy temp1
DCA_Loop:       lda #$20
                cpx zpSrcLo
                bne DCA_NoArrow
                lda #62
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
                ldx #zpDestLo
                jsr MulU
                lda zpDestHi
                ora #>screen1
                sta zpDestHi
                rts

        ; Get index of entry A in savegamelist

GetSaveListPos: asl
                asl
                sta temp8
                asl
                asl
                adc temp8
                tay
                rts

        ; Print BCD digits to the time string

PrintTimeBCD2:  lda temp6
                lsr
                lsr
                lsr
                lsr
                jsr PTBCD1_NoAnd
PrintTimeBCD1:  lda temp6
                and #$0f
PTBCD1_NoAnd:   ora #$30
                sta txtTime,x
                inx
                rts

logoFade:       dc.b 0
textFade:       dc.b 0
logoFadeDir:    dc.b 1
textFadeDir:    dc.b 1
moveDelay:      dc.b 0
titlePage:      dc.b 0
titlePageDelayLo:
                dc.b 0
titlePageDelayHi:
                dc.b 0
mainMenuChoice: dc.b 0
optionsMenuChoice:
                dc.b 0

optionsModified: dc.b 0

difficultyTxtLo:dc.b <txtCasual, <txtEasy, <txtMedium, <txtHard
difficultyTxtHi:dc.b >txtCasual, >txtEasy, >txtMedium, >txtHard

txtCasual:      dc.b "CASUAL",0
txtEasy:        dc.b "EASY  ",0
txtMedium:      dc.b "MEDIUM",0
txtHard:        dc.b "HARD  ",0
txtOn:          dc.b "ON ",0
txtOff:         dc.b "OFF",0
txtLoadSlot:    dc.b "LOAD GAME FROM",0
txtSaveSlot:    dc.b "SAVE GAME TO",0
txtEmpty:       dc.b "EMPTY SLOT",0
txtCancel:      dc.b "CANCEL",0
txtTime:        dc.b "0:00:00",0

mainMenuJumpTblLo:
                dc.b <StartNewGame
                dc.b <LoadGame
                dc.b <Options

mainMenuJumpTblHi:
                dc.b >StartNewGame
                dc.b >LoadGame
                dc.b >Options

logoFadeBg2Tbl: dc.b $00,$00,$06,$0e
logoFadeBg3Tbl: dc.b $00,$06,$0e,$03
logoFadeCharTbl:dc.b $08,$08,$08,$08,$08,$08,$08,$08
                dc.b $08,$0e,$08,$08,$08,$08,$08,$08
                dc.b $08,$0b,$08,$0e,$08,$08,$08,$0b
                dc.b $08,$09,$0a,$0b,$0c,$0d,$0e,$0f

textFadeTbl:    dc.b $00,$06,$03,$01

optionMaxValue: dc.b 3,1,1

cheatString:    dc.b KEY_K, KEY_V, KEY_L, KEY_T
cheatIndex:     dc.b 0

levelNamesTbl:  dc.b 0,$28,$00,levelWarehouses-levelNames
                dc.b 0+$80,levelCourtyard-levelNames
                dc.b 1,$00,$18,levelCarPark-levelNames
                dc.b 1+$80,levelCourtyard-levelNames
                dc.b 2+$80,levelServiceTunnels-levelNames
                dc.b 3+$80,levelEntrance-levelNames
                dc.b 4+$80,levelServiceTunnels-levelNames
                dc.b 5+$80,levelSecurityCenter-levelNames
                dc.b 6+$80,levelUpperLabs-levelNames
                dc.b 7+$80,levelUnderground-levelNames
                dc.b 8+$80,levelLowerLabs-levelNames
                dc.b 9+$80,levelSecurityCenter-levelNames
                dc.b 10+$80,levelNetherTunnel-levelNames
                dc.b 11,$50,$00,levelBioDome-levelNames
                dc.b 11+$80,levelCourtyard-levelNames
                dc.b 12+$80,levelThroneSuite-levelNames
                dc.b 13+$80,levelServerVault-levelNames
                dc.b 14+$80,levelUnderground-levelNames
                dc.b 15+$80,levelOldTunnels-levelNames

levelNames:
levelWarehouses:dc.b "WAREHOUSE",0
levelCourtyard: dc.b "COURTYARD",0
levelCarPark:   dc.b "CAR PARK",0
levelServiceTunnels:dc.b "SERVICE TUNNELS",0
levelEntrance:  dc.b "ENTRANCE",0
levelSecurityCenter:dc.b "SECURITY CENTER",0
levelUpperLabs: dc.b "UPPER LABS",0
levelUnderground:dc.b "UNDERGROUND",0
levelLowerLabs: dc.b "LOWER LABS",0
levelNetherTunnel:dc.b "NETHER TUNNEL",0
levelBioDome:   dc.b "BIO-DOME",0
levelThroneSuite:dc.b "THRONE SUITE",0
levelServerVault:dc.b "SERVER VAULT",0
levelOldTunnels: dc.b "OLD TUNNELS",0

                checkscriptend
