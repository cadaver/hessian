                include macros.s
                include mainsym.s

        ; Script 4, install upgrades

upgradeCharsStart = chars+$400
upgradeDataStart = chars+$600

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

                org scriptCodeStart
                
                dc.w ConfigureUpgrade
                dc.w InstallUpgrade

        ; Configure script

ConfigureUpgrade:
                jsr BlankScreen
                stx sprIndex                    ;X=0 on return
                jsr SetMenuMode                 ;Clear all panel text
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
                ldx #$00
                stx screen
                stx scrollY
                jsr ClearScreen
                jsr FindUpgradeIndex
                php
                lda upgradeIndex
                asl
                tax
                lda upgradeDataStart,x          ;Get address of upgrade data structure
                sta actLo
                lda upgradeDataStart+1,x
                sta actHi
                plp
                bcs CU_Same
                ldy #UD_PUZZLE
                ldx #$00
CU_CopyPuzzle:  lda (actLo),y                   ;Reset puzzle if entering a different
                sta puzzleState,x               ;upgrade than before (or if script was
                iny                             ;reloaded in the meanwhile)
                inx
                cpx #BOARD_SIZEX*BOARD_SIZEY
                bcc CU_CopyPuzzle
CU_Same:        jsr WaitBottom
                lda #4
                sta temp1
                lda #8
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
                sta colors+8*40+5
HS_NoHead:      lsr temp1
                bcc HS_NoTorso
                sta colors+9*40+5
                sta colors+10*40+5
                sta colors+11*40+5
HS_NoTorso:     lsr temp1
                bcc HS_NoRArm
                sta colors+9*40+4
                sta colors+10*40+4
HS_NoRArm:      lsr temp1
                bcc HS_NoLArm
                sta colors+9*40+6
                sta colors+10*40+6
HS_NoLArm:      lsr temp1
                bcc HS_NoRLeg
                sta colors+11*40+4
                sta colors+12*40+4
                sta colors+13*40+4
HS_NoRLeg:      lsr temp1
                bcc HS_NoLLeg
                sta colors+11*40+6
                sta colors+12*40+6
                sta colors+13*40+6
HS_NoLLeg:      ldy #UD_NAME
                lda (actLo),y
                sta zpSrcLo
                iny
                lda (actLo),y
                sta zpSrcHi
                lda #8
                sta temp1
                lda #7
                sta temp2
                lda #$01
                sta temp3
                jsr PT_HasAddress               ;Print upgrade name
                lda #9
                sta temp2
                jsr PMR_HasAddress              ;Print description
                lda #8
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
                sta screen1+14*40+8,y
                ldy arrowPosTbl+1,x
                lda #32
                sta screen1+14*40+8,y
CU_ChoiceLoop:  jsr GetControls
                jsr FinishFrame
                jsr GetFireClick
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
CU_DoConfigure: jsr ClearScreen

        ; Install script

InstallUpgrade:
                jsr FindUpgradeIndex
                lda upgrade
                and upgradeBitTbl,x
                bne IU_AlreadyInstalled
                lda upgradeOK
                beq IU_NotConfigured
                rts
IU_AlreadyInstalled:
                lda #<txtAlreadyInstalled
                ldx #>txtAlreadyInstalled
                bne IU_TextCommon
IU_NotConfigured:
                lda #<txtNotConfigured
                ldx #>txtNotConfigured
IU_TextCommon:  ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText

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

upgradeIndex:   dc.b $ff
upgradeOK:      dc.b 0

upgradeLvlTbl:  dc.b 6,6,5,8,8,8,12
upgradeObjTbl:  dc.b $54,$56,$25,$59,$55,$47,$15
upgradeBitTbl:  dc.b 1,2,4,8,16,32,64

arrowPosTbl:    dc.b 0,11,0

humanShape:     dc.b 32,174,32,0
                dc.b 175,176,177,0
                dc.b 178,179,180,0
                dc.b 181,182,183,0
                dc.b 184,185,186,0
                dc.b 187,188,189,0,0

txtConfigureExit: dc.b " CONFIGURE  EXIT",0
txtPuzzleTitle: dc.b "CONFIGURE IMPLANT/HOST INTERFACE",0
txtCompatibility:dc.b "COMPATIBILITY",0
txtInstallTrauma:dc.b "INSTALL TRAUMA",0

txtNotConfigured:
                dc.b "NEED CONFIGURATION",0
txtAlreadyInstalled:
                dc.b "ALREADY INSTALLED",0
txtInstallDone: dc.b "INSTALL SUCCESSFUL",0

traumaTxtTbl:   dc.w traumaLvl0,traumaLvl1,traumaLvl2,traumaLvl3,traumaLvl4

traumaLvl0:     dc.b "NONE",0
traumaLvl1:     dc.b "MINOR",0
traumaLvl2:     dc.b "MAJOR",0
traumaLvl3:     dc.b "CRITICAL",0
traumaLvl4:     dc.b "LETHAL",0

puzzleState:    ds.b BOARD_SIZEX*BOARD_SIZEY,0

                checkscriptend