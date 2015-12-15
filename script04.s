                include macros.s
                include mainsym.s

        ; Script 4, install upgrades

upgradeCharsStart = chars
upgradeDataStart = chars
humanShape      = chars+$80

posX            = wpnLo
posY            = wpnHi
sightColor      = wpnBits

UD_NAME         = 0
UD_BITS         = 2
UD_PUZZLE       = 3

PART_HEAD       = 1
PART_TORSO      = 2
PART_RARM       = 4
PART_LARM       = 8
PART_RLEG       = 16
PART_LLEG       = 32

BOARD_SIZEX     = 12
BOARD_SIZEY     = 8

SIGHTFRAME      = $a1
MOVESPEED       = 7
MOVESPEEDFAST   = 5

CONN_NONE       = 0
CONN_UP         = 1
CONN_UPRIGHT    = 2
CONN_RIGHT      = 4
CONN_DOWNRIGHT  = 8
CONN_DOWN       = 16
CONN_DOWNLEFT   = 32
CONN_LEFT       = 64
CONN_UPLEFT     = 128

                mac ApplyPower
                subroutine APStart
                ldy #{2}
                lda puzzleState+{1},x
                beq .1                          ;Early exit if empty
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

        ; Configure script

CU_AlreadyInstalled:
                lda #<txtAlreadyInstalled
                ldx #>txtAlreadyInstalled
                jmp IU_TextCommon
CU_AlreadyConfigured:
                lda #<txtAlreadyConfigured
                ldx #>txtAlreadyConfigured
                jmp IU_TextCommon
                
ConfigureUpgrade:
                jsr FindUpgradeIndex
                adc #$00
                sta CU_CheckSameUpgrade+1
                ldx upgradeIndex
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
                lda #$0f
                sta scrollX
                lda #$00
                sta screen
                sta SL_CSSScrollY+1
                jsr ClearScreen
                lda upgradeIndex
                asl
                tax
                lda upgradeDataStart,x          ;Get address of upgrade data structure
                sta actLo
                lda upgradeDataStart+1,x
                sta actHi
CU_CheckSameUpgrade:
                ldx #$00
                bne CU_Same
                ldy #UD_PUZZLE
CU_CopyPuzzle:  lda (actLo),y                   ;Reset puzzle if entering a different
                sta puzzleState,x               ;upgrade than before (or if script was
                iny                             ;reloaded in the meanwhile)
                inx
                cpx #BOARD_SIZEX*BOARD_SIZEY
                bcc CU_CopyPuzzle
                lda #$00
CU_Same:        jsr WaitBottom
                lda #4
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
                ldx #1*40+5
                jsr Highlight3
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
                jsr PMR_HasAddress              ;Print description
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
                lda keyPress
                bmi CU_NoKey
                lda #1
                sta menuCounter
                bne CU_DoChoice
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

CU_Victory:     lda #SFX_POWERUP
                sta upgradeOK
                jsr PlaySfx
                lda #0
                sta temp2
                lda #8
                sta temp1
                lda #<txtVictory
                ldx #>txtVictory
                jsr PrintTextWhite
                ldy #100
CU_VictoryDelay:jsr WaitBottom
                dey
                bne CU_VictoryDelay
                beq CU_DoExit

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
CU_ConfigureLoop:
                jsr PositionSight
                jsr FinishFrame
                lda poweredConnections
                cmp totalConnections
                beq CU_Victory
                jsr GetControls
                lda keyPress
                bpl CU_DoExit
                jsr GetFireClick
                bcs CU_Action
                ldy #MOVESPEED
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
CU_Action:      lda posX
                sta temp1
                lda posY
                sta temp2
                jsr GetTileIndex
                lda puzzleState,x
                beq CU_NotMovable
                bmi CU_NotMovable
                pha
                and #$f0
                sta CU_TileOr+1                 ;Retain color/state bit
                pla
                and #$0f
                tay
                lda tileNextTbl,y
CU_TileOr:      ora #$00
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

        ; Install script

InstallUpgrade:
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
                sta Irq1_Bg1+1
                sta Irq1_Bg2+1
                sta Irq1_Bg3+1
                rts
IE_Restore:     jmp SetZoneColors
IE_End:         jsr StopScript
                ldx #MENU_NONE
                jsr SetMenuMode
                lda #<txtInstallDone
                ldx #>txtInstallDone
                jmp IU_TextCommon

        ; Evaluate connections

Evaluate:       ldx #BOARD_SIZEX*BOARD_SIZEY-1
Evaluate_Reset: lda puzzleState,x
                beq Evaluate_SkipReset
                and #$70
                cmp #$70                        ;Keep only power sources
                beq Evaluate_SkipReset
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
                sta totalConnections
                sta poweredConnections
                ldx #BOARD_SIZEX*BOARD_SIZEY-1
Evaluate_Count: lda boardConnAndTbl,x           ;Count only at borders
                cmp #$ff
                beq Evaluate_CountNext
                lda puzzleState,x
                beq Evaluate_CountNext
                and #$70
                cmp #$70
                beq Evaluate_CountNext          ;Disregard power sources
                inc totalConnections
                cmp #$10
                bcc Evaluate_CountNext
                inc poweredConnections
Evaluate_CountNext:
                dex
                bpl Evaluate_Count
ET_Done:        rts

EvaluateTile:   lda puzzleState,x
                and #$70
                beq ET_Done                     ;No power to spread, early exit
                lda #$10
                sta temp1
                lda puzzleState,x
                and #$0f
                tay
                lda tileConnTbl,y
                and boardConnAndTbl,x
                sta temp2                       ;Connections of tile
                lsr temp2
                bcc ET_NotUp
                ApplyPower -BOARD_SIZEX,CONN_DOWN
ET_NotUp:       lsr temp2
                bcc ET_NotUpRight
                ApplyPower -BOARD_SIZEX+1,CONN_DOWNLEFT
ET_NotUpRight:  lsr temp2
                bcc ET_NotRight
                ApplyPower 1,CONN_LEFT
ET_NotRight:    lsr temp2
                bcc ET_NotDownRight
                ApplyPower BOARD_SIZEX+1,CONN_UPLEFT
ET_NotDownRight:lsr temp2
                bcc ET_NotDown
                ApplyPower BOARD_SIZEX,CONN_UP
ET_NotDown:     lsr temp2
                bcc ET_NotDownLeft
                ApplyPower BOARD_SIZEX-1,CONN_UPRIGHT
ET_NotDownLeft: lsr temp2
                bcc ET_NotLeft
                ApplyPower -1,CONN_RIGHT
ET_NotLeft:     lsr temp2
                bcc ET_NotUpLeft
                ApplyPower -BOARD_SIZEX-1,CONN_DOWNRIGHT
ET_NotUpLeft:   rts

ApplyPowerSub:  sty temp7
                sta temp3
                and #$0f
                tay
                lda tileConnTbl,y
                and temp7                       ;Check receiving connection
                beq APS_Fail
                lda temp3
                and #$70
                cmp temp1
                bcs APS_Fail                    ;No-op if already has higher power level
                lda temp3
                and #$8f
                ora temp1
                inc temp8                       ;Mark change
                sec
                rts
APS_Fail:       clc
                rts

        ; Refresh whole puzzle display

RedrawBoard:    lda #9
                sta temp1
                lda #0
                sta temp2
                lda #<txtPuzzleTitle
                ldx #>txtPuzzleTitle
                jsr PrintTextWhite
                lda #3
                sta temp1
                lda #19
                sta temp2
                lda #<txtConnections
                ldx #>txtConnections
                jsr PrintTextWhite
                ldx #8
RB_BottomRow:   lda #172
                cpx #8+BOARD_SIZEX*2
                php
                adc #$00
                sta screen1+18*40,x
                lda #$08
                sta colors+18*40,x
                plp
                bcs RB_BottomRowDone
                inx
                bne RB_BottomRow
RB_BottomRowDone:
                lda #>screen1
                sta RB_RightColumnSta+2
                lda #>colors
                sta RB_RightColumnSta2+2
                ldy #80+8+BOARD_SIZEX*2
                ldx #BOARD_SIZEY*2
RB_RightColumn: lda #130
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
RedrawBoard2:   lda #<(screen1+2*40+8)
                sta zpDestLo
                sta zpBitsLo
                lda #>(screen1+2*40+8)
                sta zpDestHi
                lda #>(colors+2*40+8)
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
                inc temp4
                iny
                lda temp4
                sta (zpDestLo),y
                lda temp5
                sta (zpBitsLo),y
                inc temp4
                tya
                clc
                adc #39
                tay
                lda temp4
                sta (zpDestLo),y
                lda temp5
                sta (zpBitsLo),y
                inc temp4
                iny
                lda temp4
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
                lda poweredConnections
                ldx #0
                jsr RB_PrintBCD
                lda totalConnections
                ldx #3
RB_PrintBCD:    jsr ConvertToBCD8
                lda temp6
                pha
                lsr
                lsr
                lsr
                lsr
                ora #$30
                sta screen1+19*40+15,x
                pla
                and #$0f
                ora #$30
                sta screen1+19*40+16,x
                rts

GetTileIndex:   lda temp2
                ldy #12
                ldx #zpSrcLo
                jsr MulU
                lda temp1
                jsr Add8
                ldx zpSrcLo
                rts

        ; Set position of sight sprite

PositionSight:  lda posX
                ldy #16
                ldx #<temp1
                jsr MulU
                lda #22+8*8
                jsr Add8
                lda temp1
                sta sprXL
                lda temp2
                sta sprXH
                lda posY
                ldy #16
                jsr MulU
                lda #53+2*8
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
FUI_Found:      cpx upgradeIndex
                beq FUI_Same
                stx upgradeIndex
                lda #$00
                sta upgradeOK
                clc
                rts
FUI_Same:       sec
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
PMR_HasAddress:
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
                jsr GetRowAddress
                lda temp1
                jsr Add8
                ldx #zpBitsLo
                lda temp1
                jsr Add8
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

        ; Get address of text row Y

GetRowAddress:  lda #40
                ldx #zpDestLo
                jsr MulU
                lda zpDestLo
                sta zpBitsLo
                lda zpDestHi
                pha
                ora #>screen1
                sta zpDestHi
                pla
                ora #>colors
                sta zpBitsHi
                rts

upgradeLvlTbl:  dc.b 6,6,5,8,8,8,12
upgradeObjTbl:  dc.b $54,$56,$25,$59,$55,$47,$15
upgradeBitTbl:  dc.b 1,2,4,8,16,32,64
arrowPosTbl:    dc.b 0,11,0
tileColorTbl:   dc.b $0a,$0f,$0f,$0f,$0f,$0f,$0f,$09

tileNextTbl:    dc.b $00,$02,$01,$04,$05,$06,$03,$08,$09,$0a,$07
tileConnTbl:    dc.b CONN_NONE
                dc.b CONN_UP|CONN_RIGHT|CONN_DOWN|CONN_LEFT
                dc.b CONN_UPRIGHT|CONN_DOWNRIGHT|CONN_DOWNLEFT|CONN_UPLEFT
                dc.b CONN_UP|CONN_DOWNRIGHT|CONN_DOWNLEFT
                dc.b CONN_RIGHT|CONN_DOWNLEFT|CONN_UPLEFT
                dc.b CONN_DOWN|CONN_UPLEFT|CONN_UPRIGHT
                dc.b CONN_LEFT|CONN_UPRIGHT|CONN_UPLEFT
                dc.b CONN_RIGHT|CONN_LEFT
                dc.b CONN_DOWNRIGHT|CONN_UPLEFT
                dc.b CONN_UP|CONN_DOWN
                dc.b CONN_UPRIGHT|CONN_DOWNLEFT

sightColorTbl:  dc.b $01,$07,$0f,$0a,$08,$0a,$0f,$07

txtStation:     dc.b "IMPLANT INSTALLATION STATION",0
txtConfigureExit: dc.b " CONFIGURE  EXIT",0
txtPuzzleTitle: dc.b "IMPLANT/HOST INTERFACE",0
txtConnections: dc.b "CONNECTIONS   /    ANY KEY TO EXIT",0
txtVictory:     dc.b "CONFIGURATION SUCCESSFUL",0

txtNotConfigured:
                dc.b "ERROR: NOT CONFIGURED",0
txtInstallDone: dc.b "INSTALL SUCCESSFUL",0

txtAlreadyConfigured:
                dc.b "READY TO INSTALL",0
txtAlreadyInstalled:
                dc.b "ALREADY INSTALLED",0

puzzleState:    ds.b BOARD_SIZEX*BOARD_SIZEY,0

boardConnAndTbl:dc.b CONN_DOWN|CONN_RIGHT|CONN_DOWNRIGHT
                ds.b BOARD_SIZEX-2,CONN_DOWN|CONN_RIGHT|CONN_LEFT|CONN_DOWNRIGHT|CONN_DOWNLEFT
                dc.b CONN_DOWN|CONN_LEFT|CONN_DOWNLEFT
                repeat BOARD_SIZEY-2
                dc.b CONN_UP|CONN_DOWN|CONN_RIGHT|CONN_UPRIGHT|CONN_DOWNRIGHT
                ds.b BOARD_SIZEX-2,$ff
                dc.b CONN_UP|CONN_DOWN|CONN_LEFT|CONN_UPLEFT|CONN_DOWNLEFT
                repend
                dc.b CONN_UP|CONN_RIGHT|CONN_UPRIGHT
                ds.b BOARD_SIZEX-2,CONN_UP|CONN_RIGHT|CONN_LEFT|CONN_UPRIGHT|CONN_UPLEFT
                dc.b CONN_UP|CONN_LEFT|CONN_UPLEFT

upgradeIndex:   dc.b $ff
upgradeOK:      dc.b 0
totalConnections:dc.b 0
poweredConnections: dc.b 0
installColor:   dc.b 0

                checkscriptend