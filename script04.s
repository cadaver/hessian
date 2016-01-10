                include macros.s
                include mainsym.s

        ; Script 4, install upgrades

EDIT_PUZZLE     = 0

upgradeCharsStart = chars
upgradeDataStart = chars

posX            = wpnLo
posY            = wpnHi
sightColor      = wpnBits
totalOutputs    = frameLo
poweredOutputs  = frameHi
fireExitDelay   = menuCounter
installColor    = menuCounter

UD_NAME         = 0
UD_DESC         = 2
UD_BITS         = 4
UD_PUZZLE       = 5

PART_HEAD       = 1
PART_TORSO      = 2
PART_RARM       = 4
PART_LARM       = 8
PART_RLEG       = 16
PART_LLEG       = 32

BOARD_SIZEX     = 13
BOARD_SIZEY     = 7

SIGHTFRAME      = $a1
MOVESPEED       = 7
MOVESPEEDFAST   = 5

CONN_NONE       = 0
CONN_UP         = 1
CONN_RIGHT      = 2
CONN_DOWN       = 4
CONN_LEFT       = 8
CONN_ALL        = 15

                mac ApplyPower
                subroutine APStart
                ldy #{2}
                lda puzzleState+{1},x
                jsr ApplyPowerSub
                bcc .1
                sta puzzleState+{1},x
.1:
                subroutine APEnd
                endm

                org scriptCodeStart

                dc.w ConfigureUpgrade
                dc.w InstallUpgrade
                dc.w InstallEffect

        ; Configure station script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

CU_AlreadyInstalled:
                lda #<txtAlreadyInstalled
                ldx #>txtAlreadyInstalled
                jmp IU_TextCommon
CU_AlreadyConfigured:
                lda #<txtAlreadyConfigured
                ldx #>txtAlreadyConfigured
                jmp IU_TextCommon

ConfigureUpgrade:
                jsr CheckForReset
                jsr FindUpgradeIndex
                lda upgrade
                and upgradeBitTbl,x
                bne CU_AlreadyInstalled
                lda upgradeOK
                bne CU_AlreadyConfigured
                jsr BlankScreen
                stx sprIndex                    ;X=0 on return
                jsr DA_FillSprites              ;Remove game sprites
                ldx #$ff
                stx ECS_LoadedCharSet+1         ;Mark game charset destroyed
                lda #F_UPGRADE
                jsr MakeFileName_Direct
                lda #<upgradeCharsStart
                ldx #>upgradeCharsStart
                jsr LoadFileRetry
                ldx #$00
                stx Irq1_Bg1+1
                stx screen
                stx SL_CSSScrollY+1
                lda #$0f
                sta scrollX
                lda #$0b
                sta Irq1_Bg2+1
                lda #$0c
                sta Irq1_Bg3+1
CU_CopyTextChars:
                lda textChars+$100,x
                sta chars+$100,x
                lda textChars+$200,x
                sta chars+$200,x
                lda textChars+$300,x
                sta chars+$300,x
                inx
                bne CU_CopyTextChars
CU_Again:       jsr ClearScreen
                lda upgradeIndex
                asl
                tax
                lda upgradeDataStart,x          ;Get address of upgrade data structure
                sta actLo
                lda upgradeDataStart+1,x
                sta actHi
                lda upgradeIndex
                cmp upgradePuzzleIndex
                beq CU_Same
                sta upgradePuzzleIndex
                ldy #UD_PUZZLE
                ldx #$00
CU_CopyPuzzle:  lda (actLo),y                   ;Reset puzzle if entering a different
                sta puzzleState,x               ;upgrade than before (or if script was
                iny                             ;reloaded in the meanwhile)
                inx
                cpx #BOARD_SIZEX*BOARD_SIZEY
                bcc CU_CopyPuzzle
CU_Same:        lda #4
                sta temp1
                lda #7
                sta temp2
                lda #$0d
                sta temp3
                lda #<humanShape
                ldx #>humanShape
                jsr PrintMultipleRows
                ldy #UD_BITS
                lda (actLo),y
                sta temp1
                lda #$09
                lsr temp1                       ;Highlight parts of the human shape
                bcc HS_NoHead                   ;according to bits
                sta colors+7*40+5
HS_NoHead:      lsr temp1
                bcc HS_NoTorso
                ldx #5
                jsr Highlight2
HS_NoTorso:     lsr temp1
                bcc HS_NoRArm
                ldx #4
                jsr Highlight2
HS_NoRArm:      lsr temp1
                bcc HS_NoLArm
                ldx #6
                jsr Highlight2
HS_NoLArm:      lsr temp1
                bcc HS_NoRLeg
                ldx #3*40+4                     ;Highlight also the center,
                jsr Highlight3                  ;as leg upgrade is always both
                inx
                jsr Highlight3
HS_NoRLeg:      lsr temp1
                bcc HS_NoLLeg
                ldx #3*40+6
                jsr Highlight3
HS_NoLLeg:      lda #6
                sta temp1
                lda #4
                sta temp2
                lda #<txtStation
                ldx #>txtStation
                jsr PrintTextWhite              ;Print title text
                lda #9
                sta temp1
                lda #7
                sta temp2
                ldy #UD_NAME+1
                lda (actLo),y
                tax
                dey
                lda (actLo),y
                jsr PrintText                   ;Print upgrade name
                lda #9
                sta temp2
                ldy #UD_DESC+1
                lda (actLo),y
                tax
                dey
                lda (actLo),y
                jsr PrintMultipleRows           ;Print description
                lda #12
                sta temp1
                lda #14
                sta temp2
                lda #<txtConfigureExit
                ldx #>txtConfigureExit
                jsr PrintText
                jmp CU_ChoiceRedrawSilent
CU_ChoiceRedraw:lda #SFX_SELECT
                jsr PlaySfx
CU_ChoiceRedrawSilent:
                ldx menuCounter
                ldy arrowPosTbl,x
                lda #62
                sta screen1+14*40+12,y
                ldy arrowPosTbl+1,x
                lda #32
                sta screen1+14*40+12,y
CU_ChoiceLoop:  jsr FinishFrame
                jsr GetControls
                if EDIT_PUZZLE=0
                lda keyPress
                bmi CU_NoKey
                lda #1
                sta menuCounter
                bne CU_DoChoice
                else
                lda keyType
                cmp #KEY_Z
                bne CU_NotPrevUpgrade
                dec upgradeIndex
                jmp CU_Again
CU_NotPrevUpgrade:
                cmp #KEY_X
                bne CU_NotNextUpgrade
                inc upgradeIndex
                jmp CU_Again
CU_NotNextUpgrade:
                endif
CU_NoKey:       jsr GetFireClick
                bcs CU_DoChoice
                jsr MenuControl
                lsr
                bcs CU_MoveLeft
                lsr
                bcs CU_MoveRight
                bcc CU_ChoiceLoop
CU_MoveLeft:    lda menuCounter
                beq CU_ChoiceLoop
                dec menuCounter
                bpl CU_ChoiceRedraw
CU_MoveRight:   lda menuCounter
                bne CU_ChoiceLoop
                inc menuCounter
                bpl CU_ChoiceRedraw
CU_DoChoice:    lda #SFX_SELECT
                jsr PlaySfx
                lda menuCounter
                beq CU_DoConfigure
CU_DoExit:      ldy lvlObjNum                   ;Allow immediate re-entry
                jsr InactivateObject
                jsr FindPlayerZone              ;Reload level charset
                jmp CenterPlayer

        ; Configuration puzzle

                if EDIT_PUZZLE=0
CU_Victory:     lda #SFX_POWERUP
                sta upgradeOK
                jsr PlaySfx
                lda #1
                sta temp2
                lda #8
                sta temp1
                lda #<txtVictory
                ldx #>txtVictory
                jsr PrintTextWhite
                lda #100
                sta fireExitDelay
CU_VictoryDelay:jsr CU_Frame
                dec fireExitDelay
                bne CU_VictoryDelay
                beq CU_DoExit
                endif

CU_DoConfigure: jsr BlankScreen
                jsr ClearScreen
                jsr Evaluate
                jsr RedrawBoard
                lda #BOARD_SIZEX/2
                sta posX
                lda #BOARD_SIZEY/2
                sta posY
                lda #$00
                sta sightColor
                sta menuMoveDelay
                sta fireExitDelay
CU_ConfigureLoop:
                jsr CU_Frame
                if EDIT_PUZZLE=0
                lda poweredOutputs
                cmp totalOutputs
                beq CU_Victory
                endif
                jsr GetControls
                if EDIT_PUZZLE=0
                lda keyType
                bpl CU_DoExit
                else
                lda menuMoveDelay
                beq CU_EditOK
                bne CU_NoEdit
CU_EditOK:      jsr GetTileIndex
                lda keyPress
                cmp #KEY_X
                bne CU_NotNext
                inc puzzleState,x
                jmp CU_EditRedraw
CU_NotNext:     cmp #KEY_Z
                bne CU_NoEdit
                dec puzzleState,x
CU_EditRedraw:  lda #6
                sta menuMoveDelay
                jsr RedrawBoard2
CU_NoEdit:
                endif
                jsr GetFireClick
                bcs CU_Action
                lda joystick                                    ;Exit also by holding button down long
                cmp #JOY_FIRE
                bne CU_NoFireExit
                inc fireExitDelay
                lda fireExitDelay
                cmp #100
                bcs CU_DoExit
                bcc CU_FireExitDone
CU_NoFireExit:  lda #$00
                sta fireExitDelay
CU_FireExitDone:ldy #MOVESPEED
                lda menuMoveDelay
                beq CU_MoveOK
                ldy #MOVESPEEDFAST                             ;Continuous move is faster
                dec menuMoveDelay
                bne CU_ConfigureLoop
CU_MoveOK:      lda joystick
                sta temp1
                lsr temp1
                bcc CU_NoMoveUp
                lda posY
                beq CU_NoMoveUp
                jsr CU_DoMove
                dec posY
CU_NoMoveUp:    lsr temp1
                bcc CU_NoMoveDown
                lda posY
                cmp #BOARD_SIZEY-1
                bcs CU_NoMoveDown
                jsr CU_DoMove
                inc posY
CU_NoMoveDown:  lsr temp1
                bcc CU_NoMoveLeft
                lda posX
                beq CU_NoMoveLeft
                jsr CU_DoMove
                dec posX
CU_NoMoveLeft:  lsr temp1
                bcc CU_NoMoveRight
                lda posX
                cmp #BOARD_SIZEX-1
                bcs CU_NoMoveRight
                jsr CU_DoMove
                inc posX
CU_NoMoveRight: jmp CU_ConfigureLoop
CU_Action:      jsr GetTileIndex
                lda puzzleState,x
                pha
                and #$f0
                sta CU_TileOr+1                 ;Retain power/state bits
                pla
                and #$0f
                tay
                lda tileNextTbl,y
CU_TileOr:      ora #$00
                cmp puzzleState,x
                beq CU_NotMovable
                sta puzzleState,x
                lda #SFX_OBJECT
                jsr PlaySfx
                jsr Evaluate
                jsr RedrawBoard2
                jmp CU_ConfigureLoop
CU_NotMovable:  lda #SFX_DAMAGE
                jsr PlaySfx
                jmp CU_ConfigureLoop

CU_DoMove:      sty menuMoveDelay
                lda #SFX_SELECT
                jsr PlaySfx
                rts

CU_Frame:       jsr PositionSight
                jsr FinishFrame
                lda errored
                beq CU_FrameNotErrored
                jsr Random
                and #$03
CU_FrameNotErrored:
                tay
                lda errorColorTbl,y
                sta Irq1_Bg2+1
                rts

        ; Evaluate connections

Evaluate:       lda #$00
                sta errored
                ldx #BOARD_SIZEX*BOARD_SIZEY-1
Evaluate_Reset: lda puzzleState,x
                beq Evaluate_SkipReset
                bmi Evaluate_SkipReset          ;Skip empty & initial power sources
                lda puzzleState,x
                and #$8f
                sta puzzleState,x
Evaluate_SkipReset:
                dex
                bpl Evaluate_Reset
Evaluate_Again: lda #$00                        ;Changes made counter
                sta temp8
                ldx #$00
Evaluate_Forward:
                jsr EvaluateTile
                inx
                cpx #BOARD_SIZEX*BOARD_SIZEY
                bcc Evaluate_Forward
                lda temp8                       ;Stop if no further changes
                beq Evaluate_Done
                lda #$00
                sta temp8
                ldx #BOARD_SIZEX*BOARD_SIZEY-1
Evaluate_Backward:
                jsr EvaluateTile
                dex
                bpl Evaluate_Backward
                lda temp8
                bne Evaluate_Again
Evaluate_Done:  lda #$00
                sta totalOutputs
                sta poweredOutputs
                ldx #BOARD_SIZEX*BOARD_SIZEY-1
Evaluate_Count: lda puzzleState,x               ;Disregard power sources and anything movable
                and #$0f
                cmp #$09
                bcs Evaluate_CountNext
                tay
                lda boardConnAndTbl,x           ;Check for wire leading out of the board
                eor #CONN_ALL
                and tileConnTbl,y
                beq Evaluate_CountNext
                inc totalOutputs
                lda puzzleState,x               ;Powered?
                and #$70
                beq Evaluate_CountNext
                inc poweredOutputs
Evaluate_CountNext:
                dex
                bpl Evaluate_Count
                lda errored
                beq Evaluate_NoError
                lda #$00
                sta poweredOutputs
Evaluate_NoError:
ET_Done:        rts

EvaluateTile:   lda puzzleState,x
                beq ET_Done                     ;Emptiness, early exit
                pha
                and #$0f
                tay
                sty temp4
                pla
                and #$70
                beq ET_Done                     ;No power to spread
                sec
                sbc #$10
                sta temp1
                lda tileConnTbl,y
                and boardConnAndTbl,x
                sta temp2                       ;Connections of tile
                lsr temp2
                bcc ET_NotUp
                ApplyPower -BOARD_SIZEX,CONN_DOWN
ET_NotUp:       lsr temp2
                bcc ET_NotRight
                ApplyPower 1,CONN_LEFT
ET_NotRight:    lsr temp2
                bcc ET_NotDown
                ApplyPower BOARD_SIZEX,CONN_UP
ET_NotDown:     lsr temp2
                bcc ET_NotLeft
                ApplyPower -1,CONN_RIGHT
ET_NotLeft:     rts

ApplyPowerSub:  sty temp7
                sta temp3
                and #$0f
                tay
                lda tileConnTbl,y
                and temp7                       ;Check receiving connection
                beq APS_CheckError
                lda temp1
                cpy #$0f
                bne APS_NoPowerSource           ;Power sources always get max power
                lda #$70
APS_NoPowerSource:
                sta temp6
                lda temp3
                and #$f0
                cmp temp6
                bcs APS_Fail                    ;Skip if already same or higher level
                lda temp3
                and #$8f
                ora temp6
                inc temp8                       ;Mark change
                sec
                rts
APS_CheckError: cpy #$09                        ;Blocked: error if leading to emptiness,
                bcs APS_Fail                    ;but OK for power sources
                lda temp4
                cmp #$0f
                beq APS_Fail
                inc errored
APS_Fail:       clc
                rts

        ; Refresh whole puzzle display

RedrawBoard:    lda #9
                sta temp1
                lda #1
                sta temp2
                lda #<txtPuzzleTitle
                ldx #>txtPuzzleTitle
                jsr PrintTextWhite
                lda #6
                sta temp1
                lda #18
                sta temp2
                lda #<txtOutputs
                ldx #>txtOutputs
                jsr PrintTextWhite
                ldx #7
RB_BottomRow:   lda #129
                sta screen1+17*40,x
                lda #$08
                sta colors+17*40,x
                inx
                cpx #7+BOARD_SIZEX*2
                bcc RB_BottomRow
                lda #192
                sta screen1+17*40,x
                lda #$08
                sta colors+17*40,x
                lda #>screen1
                sta RB_RightColumnSta+2
                lda #>colors
                sta RB_RightColumnSta2+2
                ldy #120+7+BOARD_SIZEX*2
                ldx #BOARD_SIZEY*2
RB_RightColumn: lda #160
RB_RightColumnSta:
                sta screen1,y
                lda #$08
RB_RightColumnSta2:
                sta colors,y
                tya
                clc
                adc #40
                tay
                bcc RB_RightColumnNotOver
                inc RB_RightColumnSta+2
                inc RB_RightColumnSta2+2
RB_RightColumnNotOver:
                dex
                bne RB_RightColumn
RedrawBoard2:   lda #<(screen1+3*40+7)
                sta zpDestLo
                sta zpBitsLo
                lda #>(screen1+3*40+7)
                sta zpDestHi
                lda #>(colors+3*40+7)
                sta zpBitsHi
                ldx #$00
                lda #BOARD_SIZEY
                sta temp2
RB_RowLoop:     lda #BOARD_SIZEX
                sta temp1
                ldy #$00
RB_ColumnLoop:  sty temp3
                lda puzzleState,x
                pha
                and #$0f
                asl
                ora #$80
                sta temp4
                pla
                lsr
                lsr
                lsr
                lsr
                and #$07
                tay
                lda tileColorTbl,y
                sta temp5
                ldy temp3
                lda temp4
                sta (zpDestLo),y
                lda temp5
                sta (zpBitsLo),y
                iny
                lda temp4
                ora #$01
                sta (zpDestLo),y
                lda temp5
                sta (zpBitsLo),y
                tya
                clc
                adc #39
                tay
                lda temp4
                ora #$20
                sta (zpDestLo),y
                lda temp5
                sta (zpBitsLo),y
                iny
                lda temp4
                ora #$21
                sta (zpDestLo),y
                lda temp5
                sta (zpBitsLo),y
                inx
                ldy temp3
                iny
                iny
                dec temp1
                bne RB_ColumnLoop
                lda zpDestLo
                clc
                adc #80
                sta zpDestLo
                sta zpBitsLo
                bcc RB_RowNotOver
                inc zpDestHi
                inc zpBitsHi
RB_RowNotOver:  dec temp2
                bne RB_RowLoop
                lda poweredOutputs
                ldx #0
                jsr RB_PrintBCD
                lda totalOutputs
                ldx #3
RB_PrintBCD:    jsr ConvertToBCD8
                lda temp6
                pha
                lsr
                lsr
                lsr
                lsr
                ora #$30
                sta screen1+18*40+14,x
                pla
                and #$0f
                ora #$30
                sta screen1+18*40+15,x
                rts

GetTileIndex:   lda posY
                ldy #BOARD_SIZEX
                ldx #zpSrcLo
                jsr MulU
                lda posX
                jsr Add8
                ldx zpSrcLo
                rts

        ; Set position of sight sprite

PositionSight:  lda posX
                ldy #16
                ldx #<temp1
                jsr MulU
                lda #22+7*8
                jsr Add8
                lda temp1
                sta sprXL
                lda temp2
                sta sprXH
                lda posY
                ldy #16
                jsr MulU
                lda #53+3*8
                jsr Add8
                lda temp1
                sta sprY
                lda #SIGHTFRAME
                sta sprF
                inc sightColor
                lda sightColor
                lsr
                lsr
                and #$07
                tax
                lda sightColorTbl,x
                sta sprC
                rts

        ; Highlight parts of the human figure
        
Highlight3:     sta colors+7*40,x
Highlight2:     sta colors+8*40,x
                sta colors+9*40,x
                rts

        ; Clear whole screen
        
ClearScreen:    ldx #$00
ClearScreenLoop:lda #$20
                sta screen1,x
                sta screen1+$100,x
                sta screen1+$200,x
                sta screen1+SCROLLROWS*40-$100,x
                inx
                bne ClearScreenLoop
                rts

        ; Print multiple rows

PrintMultipleRows:
                sta zpSrcLo
                stx zpSrcHi
PMR_Loop:       ldy #$00
                lda (zpSrcLo),y
                beq PMR_End
                jsr PT_HasAddress
                inc temp2
                bne PMR_Loop
PMR_End:        rts

        ; Print null-terminated text

PrintTextWhite: ldy #$01
                sty temp3
PrintText:      sta zpSrcLo
                stx zpSrcHi
PT_HasAddress:  ldy temp2
                ldy temp2
                lda #40
                ldx #zpDestLo
                jsr MulU
                lda temp1
                jsr Add8
                lda zpDestLo
                sta zpBitsLo
                lda zpDestHi
                pha
                ora #>screen1
                sta zpDestHi
                pla
                ora #>colors
                sta zpBitsHi
                ldy #$00
PT_Loop:        lda (zpSrcLo),y
                beq PT_Done
                sta (zpDestLo),y
                lda temp3
                sta (zpBitsLo),y
                iny
                bne PT_Loop
PT_Done:        iny
                tya
                ldx #zpSrcLo
                jmp Add8

        ; Install station script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

InstallUpgrade: jsr CheckForReset
                jsr FindUpgradeIndex
                lda upgrade
                and upgradeBitTbl,x
                beq IU_NotInstalled
                jmp CU_AlreadyInstalled
IU_NotInstalled:lda upgradeOK
                beq IU_NotConfigured
                lda upgrade
                ora upgradeBitTbl,x
                sta upgrade
                jsr ApplyUpgrades
                lda #$00
                sta installColor
                lda #<EP_INSTALLEFFECT
                ldx #>EP_INSTALLEFFECT
                jsr SetScript
                ldx #MENU_INTERACTION           ;Make player stand in place until effect done
                jmp SetMenuMode

IU_NotConfigured:
                lda #<txtNotConfigured
                ldx #>txtNotConfigured
IU_TextCommon:  ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText

        ; Install color effect script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

InstallEffect:  lda installColor
                and #$07
                bne IE_NoSound
IE_BeginSound:  lda #SFX_EMP
                jsr PlaySfx
IE_NoSound:     lda installColor
                inc installColor
                cmp #50
                bcs IE_End
                lsr
                bcs IE_Restore
                lda #$01
                ;sta Irq1_Bg2+1
                sta Irq1_Bg3+1
                rts
IE_Restore:     jmp SetZoneColors
IE_End:         jsr StopScript
                jsr SetMenuMode                 ;X=0 on return
                lda #<1000
                ldy #>1000
                jsr AddScore
                lda #<txtInstallDone
                ldx #>txtInstallDone
                jmp IU_TextCommon

        ; Find which upgrade, based on level & object number

FindUpgradeIndex:
                ldx #6
FUI_Loop:       lda upgradeLvlTbl,x
                cmp levelNum
                bne FUI_Next
                ldy upgradeObjTbl,x
                cpy lvlObjNum
                beq FUI_Found
                iny
                cpy lvlObjNum                   ;The install machine is configurator+1
                beq FUI_Found
FUI_Next:       dex
                bpl FUI_Loop
                inx                             ;Should not happen
FUI_Found:      cpx upgradeIndex                ;Same upgrade?
                beq FUI_Same
                stx upgradeIndex
                lda #$00
                sta upgradeOK                   ;Reset configure status
FUI_Same:       rts

        ; Check whether the game was restarted from checkpoint and puzzle should be reset

CheckForReset:  lda scriptVariable
                bne CFR_OK
                inc scriptVariable
                lda #$ff
                sta upgradeIndex
                sta upgradePuzzleIndex
                lda #$00
                sta upgradeOK
CFR_OK:         rts

upgradeLvlTbl:  dc.b 6,8,5,8,6,8,12
upgradeObjTbl:  dc.b $55,$59,$24,$55,$53,$47,$15
upgradeBitTbl:  dc.b 1,2,4,8,16,32,64
arrowPosTbl:    dc.b 0,11,0
tileColorTbl:   dc.b $08,$0b,$0f,$0f,$0f,$0f,$0f,$09

tileNextTbl:    dc.b $00,$01,$02,$03,$04,$05,$06,$07,$08,$0a,$09,$0c,$0d,$0e,$0b,$0f

tileConnTbl:    dc.b CONN_NONE
                dc.b CONN_UP|CONN_DOWN
                dc.b CONN_LEFT|CONN_RIGHT
                dc.b CONN_LEFT|CONN_UP
                dc.b CONN_RIGHT|CONN_UP
                dc.b CONN_RIGHT|CONN_DOWN
                dc.b CONN_LEFT|CONN_DOWN
                dc.b CONN_ALL
                dc.b CONN_NONE
                dc.b CONN_UP|CONN_DOWN
                dc.b CONN_LEFT|CONN_RIGHT
                dc.b CONN_UP|CONN_DOWN|CONN_RIGHT
                dc.b CONN_LEFT|CONN_RIGHT|CONN_DOWN
                dc.b CONN_LEFT|CONN_UP|CONN_DOWN
                dc.b CONN_UP|CONN_LEFT|CONN_RIGHT
                dc.b CONN_ALL

sightColorTbl:  dc.b $01,$07,$0f,$0a,$08,$0a,$0f,$07
errorColorTbl:  dc.b $0b,$09,$02,$0a

txtStation:     dc.b "IMPLANT INSTALLATION STATION",0
txtConfigureExit: dc.b " CONFIGURE  EXIT",0
txtPuzzleTitle: dc.b "IMPLANT/HOST INTERFACE",0
txtOutputs:     dc.b "OUTPUTS   /    ANY KEY EXITS",0
txtVictory:     dc.b "CONFIGURATION SUCCESSFUL",0

txtNotConfigured:
                dc.b "ERROR: NOT CONFIGURED",0
txtInstallDone: dc.b "INSTALL COMPLETE",0

txtAlreadyConfigured:
                dc.b "READY TO INSTALL",0
txtAlreadyInstalled:
                dc.b "ALREADY INSTALLED",0

humanShape:     dc.b 128,193,128,0
                dc.b 194,195,196,0
                dc.b 197,198,199,0
                dc.b 200,201,202,0
                dc.b 203,204,205,0
                dc.b 206,207,208,0,0

puzzleState:    ds.b BOARD_SIZEX*BOARD_SIZEY,0

boardConnAndTbl:dc.b CONN_DOWN|CONN_RIGHT
                ds.b BOARD_SIZEX-2,CONN_DOWN|CONN_RIGHT|CONN_LEFT
                dc.b CONN_DOWN|CONN_LEFT
                repeat BOARD_SIZEY-2
                dc.b CONN_UP|CONN_DOWN|CONN_RIGHT
                ds.b BOARD_SIZEX-2,CONN_ALL
                dc.b CONN_UP|CONN_DOWN|CONN_LEFT
                repend
                dc.b CONN_UP|CONN_RIGHT
                ds.b BOARD_SIZEX-2,CONN_UP|CONN_RIGHT|CONN_LEFT
                dc.b CONN_UP|CONN_LEFT

upgradePuzzleIndex:
                dc.b $ff
upgradeIndex:   dc.b $ff
upgradeOK:      dc.b 0
errored:        dc.b 0

                checkscriptend