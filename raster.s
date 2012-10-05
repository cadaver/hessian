IRQ1_LINE       = 12
IRQ3_LINE       = 221
IRQ4_LINE       = 230

PANEL_D018      = $8a

PANEL_BG1       = $00
PANEL_BG2       = $0b
PANEL_BG3       = $0c

TEXT_BG1        = $00
TEXT_BG2        = $0b
TEXT_BG3        = $0c

        ; Raster interrupt 1. Show game screen

Irq1:           cld
                sta irqSaveA
                stx irqSaveX
                sty irqSaveY
                lda #$35
                sta $01                         ;Ensure IO memory is available
                lda #$00
                sta newFrame
Irq1_ScrollX:   lda #$17
                sta $d016
Irq1_ScrollY:   lda #$57                        ;Check if panel split IRQ needs to blank the
                sta $d011                       ;screen early due to badline
                tax
                ora #$07
                cpx #$16
                bne Irq1_NoBadLine
                ora #$40
Irq1_NoBadLine: sta Irq3_D011+1
Irq1_Screen:    lda #$a8
                sta $d018
Irq1_Bg1:       lda #$06
                sta $d021
Irq1_Bg2:       lda #$0b
                sta $d022
Irq1_Bg3:       lda #$0c
                sta $d023
Irq1_MinSprY:   lda #$00
                sta FL_MinSprY+1
Irq1_MaxSprY:   lda #$00
                sta FL_MaxSprY+1
Irq1_ScreenFrame:
                lda #$00                        ;Ensure sprite frames are loaded to the
                cmp Irq2_Spr0Frame+2            ;correct screen
                beq Irq1_NoScreenFrameChange
                sta Irq2_Spr0Frame+2
                sta Irq2_Spr1Frame+2
                sta Irq2_Spr2Frame+2
                sta Irq2_Spr3Frame+2
                sta Irq2_Spr4Frame+2
                sta Irq2_Spr5Frame+2
                sta Irq2_Spr6Frame+2
                sta Irq2_Spr7Frame+2
Irq1_NoScreenFrameChange:
Irq1_D015:      lda #$00
                sta $d015
                beq Irq1_NoSprites
                lda #<Irq2                      ;Set up the sprite display IRQ
                sta $fffe
                lda #>Irq2
                sta $ffff
Irq1_FirstSortSpr:
                ldx #$00                        ;Go through the first sprite IRQ immediately
                jmp Irq2_Spr0
Irq1_NoSprites: jmp Irq2_AllDone                ;If no sprites, go directly to the panel

        ;Raster interrupt 2. This is where sprite displaying happens

Irq2_SprIrqDone2:
                jmp Irq2_SprIrqDone
                
                org ((*+$ff) & $ff00)

Irq2_Spr0:      lda sortSprY,x
                sta $d00f
                lda sortSprX,x
                ldy sortSprD010,x
                sta $d00e
                sty $d010
                lda sortSprF,x
Irq2_Spr0Frame: sta screen1+$03ff
                lda sortSprC,x
                sta $d02e
                bmi Irq2_SprIrqDone2
                inx

Irq2_Spr1:      lda sortSprY,x
                sta $d00d
                lda sortSprX,x
                ldy sortSprD010,x
                sta $d00c
                sty $d010
                lda sortSprF,x
Irq2_Spr1Frame: sta screen1+$03fe
                lda sortSprC,x
                sta $d02d
                bmi Irq2_SprIrqDone2
                inx

Irq2_Spr2:      lda sortSprY,x
                sta $d00b
                lda sortSprX,x
                ldy sortSprD010,x
                sta $d00a
                sty $d010
                lda sortSprF,x
Irq2_Spr2Frame: sta screen1+$03fd
                lda sortSprC,x
                sta $d02c
                bmi Irq2_SprIrqDone2
                inx

Irq2_Spr3:      lda sortSprY,x
                sta $d009
                lda sortSprX,x
                ldy sortSprD010,x
                sta $d008
                sty $d010
                lda sortSprF,x
Irq2_Spr3Frame: sta screen1+$03fc
                lda sortSprC,x
                sta $d02b
                bpl Irq2_ToSpr4
                jmp Irq2_SprIrqDone
Irq2_ToSpr4:    inx

Irq2_Spr4:      lda sortSprY,x
                sta $d007
                lda sortSprX,x
                ldy sortSprD010,x
                sta $d006
                sty $d010
                lda sortSprF,x
Irq2_Spr4Frame: sta screen1+$03fb
                lda sortSprC,x
                sta $d02a
                bmi Irq2_SprIrqDone
                inx

Irq2_Spr5:      lda sortSprY,x
                sta $d005
                lda sortSprX,x
                ldy sortSprD010,x
                sta $d004
                sty $d010
                lda sortSprF,x
Irq2_Spr5Frame: sta screen1+$03fa
                lda sortSprC,x
                sta $d029
                bmi Irq2_SprIrqDone
                inx

Irq2_Spr6:      lda sortSprY,x
                sta $d003
                lda sortSprX,x
                ldy sortSprD010,x
                sta $d002
                sty $d010
                lda sortSprF,x
Irq2_Spr6Frame: sta screen1+$03f9
                lda sortSprC,x
                sta $d028
                bmi Irq2_SprIrqDone
                inx

Irq2_Spr7:      lda sortSprY,x
                sta $d001
                lda sortSprX,x
                ldy sortSprD010,x
                sta $d000
                sty $d010
                lda sortSprF,x
Irq2_Spr7Frame: sta screen1+$03f8
                lda sortSprC,x
                sta $d027
                bmi Irq2_SprIrqDone
                inx
Irq2_ToSpr0:    jmp Irq2_Spr0

Irq2_SprIrqDone:
                sec
                ldy sprIrqLine,x                ;Get startline of next IRQ
                beq Irq2_AllDone                ;(0 if was last)
                inx
                stx Irq2_SprIndex+1             ;Store next IRQ sprite start-index
                txa
                and #$07
                tax
                lda sprIrqJumpTbl,x             ;Get the correct jump address
                sta Irq2_SprJump+1
                tya
                sbc fileOpen                    ;One line advance if loading
                sta $d012
                sbc #$03                        ;Already late from the next IRQ?
                cmp $d012
                bcc Irq2_Direct                 ;If yes, execute directly
                dec $d019                       ;Acknowledge raster IRQ
                lda irqSave01
                sta $01
                lda irqSaveA
                ldx irqSaveX
                ldy irqSaveY
                rti

Irq2:           cld
                sta irqSaveA
                stx irqSaveX
                sty irqSaveY
                lda #$35
                sta $01                         ;Ensure IO memory is available
Irq2_Direct:
Irq2_SprIndex:  ldx #$00
Irq2_SprJump:   jmp Irq2_Spr0

Irq2_AllDone:   lda #IRQ3_LINE
                sec
                sbc fileOpen
                sta $d012
                sbc #$03
                cmp $d012                       ;Late from the scorepanel IRQ?
                bcc Irq2_LatePanel
                dec $d019                       ;Acknowledge raster IRQ
                lda #<Irq3
                ldx #>Irq3
SetNextIrq:     sta $fffe
                stx $ffff
                lda irqSave01
                sta $01                         ;Restore $01 value
                lda irqSaveA
                ldx irqSaveX
                ldy irqSaveY
                rti

Irq2_LatePanel: ldx irqSaveX
                ldy irqSaveY
                jmp Irq3_Wait

        ;Raster interrupt 4. Show the scorepanel and play music

Irq4:           cld
                sta irqSaveA
                stx irqSaveX
                sty irqSaveY
                lda #$35                        ;Ensure IO memory is available
                sta $01
                lda #$18
                sta $d016
                lda #PANEL_BG1                  ;Set scorepanel multicolors
                sta $d021
                lda #PANEL_BG2
                sta $d022
                lda #PANEL_BG3
                sta $d023
                dec $d019                       ;Acknowledge raster IRQ
                lsr newFrame                    ;Mark frame update available
                lda #$1f                        ;Switch screen back on
                sta $d011
Irq4_NtscDelay: dec ntscDelay                   ;Handle NTSC delay counting
                bpl Irq4_NoNtscDelay
                lda #$05
                sta ntscDelay
                bne Irq4_SkipFrame
Irq4_NoNtscDelay:
                lda targetFrames                ;Maintain a "target frames" counter
                cmp #$02                        ;which the main program will decrement.
                bcs Irq4_TargetFramesOk         ;Delay will not be used when the update
                inc targetFrames                ;is already lagging behind
Irq4_TargetFramesOk:
                jsr PlayMusic                   ;Play music/sound effects
Irq4_LevelUpdate:lda #$00                       ;Animate level background?
                beq Irq4_SkipFrame
                jsr UpdateLevel
Irq4_SkipFrame:
                lda #IRQ1_LINE
                sta $d012
                lda #<Irq1
                ldx #>Irq1
                bne SetNextIrq

        ; Raster interrupt 3. Gamescreen / scorepanel split

Irq3:           sta irqSaveA
                lda #$35
                sta $01                         ;Ensure IO memory is available
Irq3_Wait:      lda $d012
                cmp #IRQ3_LINE+1
                bcc Irq3_Wait
                bit $00
                nop
Irq3_D011:      lda #$57                        ;Stabilize Y-scrolling
                sta $d011                       ;immediately
                cmp #$57
                beq Irq3_BadLine
                nop
                pha
                pla
                pha
                pla
                pha
                pla
                pha
                pla
Irq3_BadLine:   lda #$57
                sta $d011
                lda #PANEL_D018                 ;Set panelscreen screen ptr.
                sta $d018
                lda #EMPTYSPRITEFRAME           ;Set empty spriteframe
N               set 0
                repeat 8
                sta screen1+$3f8+N
N               set N+1
                repend
                lda #IRQ4_LINE                  ;TODO: needs testing on IDE64 new firmware
                sta $d012                       ;as IRQ delay may cause whole frame blanking (?)
                lda #<Irq4
                sta $fffe
                lda #>Irq4
                sta $ffff
                dec $d019                       ;Acknowledge raster IRQ
                lda irqSave01
                sta $01                         ;Restore $01 value
                lda irqSaveA
                rti

        ; IRQ redirector when Kernal is on

RedirectIrq:    ldx $01
                lda #$35                        ;Note: this will necessarily have overhead,
                sta $01                         ;which means that the sensitive IRQs like
                lda #>RI_Return                 ;the panel-split should take extra advance
                pha
                lda #<RI_Return
                pha
                php
                jmp ($fffe)
RI_Return:      stx $01
                jmp $ea81
