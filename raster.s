IRQ1_LINE       = 12
IRQ3_LINE       = SCROLLROWS*8+45
IRQ4_LINE       = SCROLLROWS*8+54
IRQ5_LINE       = 147
IRQ6_LINE       = $fb

PANEL_BG1       = $00
PANEL_BG2       = $0b
PANEL_BG3       = $0c

TEXT_BG1        = $00
TEXT_BG2        = $0b
TEXT_BG3        = $0c

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

        ; Raster interrupt 5. Text screen split

Irq5:           jsr StartIrq
Irq5_Wait:      lda $d012
                cmp #IRQ5_LINE+3
                bcc Irq5_Wait
                lda #PANEL_D018
                sta $d018
Irq5_Bg2:       lda #$0a
                sta $d022
Irq5_Bg3:       lda #$09
                sta $d023
                jmp Irq2_AllDone
                
        ; Raster interrupt 1. Show game screen

Irq1:           jsr StartIrq
                if SHOW_FRAME_DROP>0
                ldy #$02
                lda newFrame
                beq Irq1_Late
                ldy #$00
Irq1_Late:      sty $d020
                endif
                lda #$00
                sta newFrame
                sta $d07a                       ;SCPU back to slow mode
                sta $d030                       ;C128 back to 1MHz
Irq1_LevelUpdate:
                lda #$00                        ;Animate level background?
                beq Irq1_NoLevelUpdate
                if SHOW_LEVELUPDATE_TIME>0
                dec $d020
                endif
                jsr UpdateLevel
                if SHOW_LEVELUPDATE_TIME>0
                inc $d020
                endif
Irq1_NoLevelUpdate:
Irq1_MinSprY:   lda #$00
Irq1_StoreMinSprY:
                sta FL_MinSprY+1
Irq1_MaxSprY:   ldy #$00
Irq1_StoreMaxSprY:
                sty FL_MaxSprY+1
Irq1_ScrollX:   lda #$17
                sta $d016
Irq1_ScrollY:   lda #$57                        ;Check if panel split IRQ needs to blank the
                sta $d011                       ;screen early due to badline
                tax
                ora #$07
                ;cpy #IRQ3_LINE
                ;bcs Irq1_SpritesAtSplit
                cpx #$16
                bne Irq1_NoBadLine
Irq1_SpritesAtSplit:
                ora #$40
Irq1_NoBadLine: sta Irq3_D011+1
Irq1_Screen:    ldy #GAMESCR1_D018
                sty $d018
Irq1_Bg1:       lda #$06
                sta $d021
Irq1_Bg2:       lda #$0b
                sta $d022
Irq1_Bg3:       lda #$0c
                sta $d023
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
                bne Irq1_HasSprites
Irq1_NoSprites: cpy #GAMESCR1_D018+1            ;Use split mode?
                beq Irq1_SetupTextscreenSplit
                jmp Irq2_AllDone
Irq1_SetupTextscreenSplit:
                lda #IRQ5_LINE
                sta $d012
                lda #<Irq5
                ldx #>Irq5
                jmp SetNextIrq
Irq1_HasSprites:lda #<Irq2                      ;Set up the sprite display IRQ
                sta $fffe
                lda #>Irq2
                sta $ffff
Irq1_FirstSortSpr:
                ldx #$00                        ;Go through the first sprite IRQ immediately

        ;Raster interrupt 2. This is where sprite displaying happens

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
Irq2_SprIrqDone2:
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

                ;if (Irq2_Spr0 & $ff00) != (Irq2_Spr7 & $ff00)
                ;err
                ;endif

Irq2_SprIrqDone:
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
                sec
                sbc fileOpen                    ;One line advance if loading
                sta $d012
                sbc #$03                        ;Already late from the next IRQ?
                cmp $d012
                bcs SetNextIrqNoAddress
                bcc Irq2_Direct                 ;If yes, execute directly

Irq2:           cld                             ;To save time, do not use StartIrq here, as the sprite IRQs
                sta irqSaveA                    ;may repeat several times
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
                lda #<Irq3
                ldx #>Irq3
SetNextIrq:     sta $fffe
                stx $ffff
SetNextIrqNoAddress:
                dec $d019                       ;Acknowledge raster IRQ
                lda irqSave01
                sta $01                         ;Restore $01 value
                lda irqSaveA
                ldx irqSaveX
                ldy irqSaveY
                rti

Irq2_LatePanel: ldx irqSaveX
                ldy irqSaveY
                bcc Irq3_Wait

        ; Raster interrupt 3. Gamescreen / scorepanel split

Irq3:           sta irqSaveA
                lda #$35
                sta $01                         ;Ensure IO memory is available
Irq3_Wait:      lda $d012
                cmp #IRQ3_LINE+1
                bcc Irq3_Wait
                nop
                nop
Irq3_D011:      lda #$57                        ;Stabilize Y-scrolling
                sta $d011                       ;immediately
                cmp #$57
                beq Irq3_NoDelay
                lda #$07
Irq3_Delay:     sbc #$01
                bne Irq3_Delay
                lda #$57
                sta $d011
Irq3_NoDelay:   lda #PANEL_D018                 ;Set panelscreen screen ptr.
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
                

        ;Raster interrupt 4. Show the scorepanel and play music

Irq4:           jsr StartIrq
                lda #$18
                sta $d016
                lda #PANEL_BG1                  ;Set scorepanel multicolors
                sta $d021
                lda #PANEL_BG2
                sta $d022
                lda #PANEL_BG3
                sta $d023
                lsr newFrame                    ;Mark frame update available
                if SCROLLROWS > 21
                lda #$1f                        ;Switch screen back on
                else
                lda #$17
                endif
                sta $d011
                if SHOW_PLAYROUTINE_TIME>0
                dec $d020
                endif
                jsr PlayRoutine                 ;Play music/sound effects
                if SHOW_PLAYROUTINE_TIME>0
                inc $d020
                endif
                lda fileOpen                    ;If file not open, switch SCPU to turbo mode
                bne Irq4_NoSCPU                 ;during the bottom of the screen to prevent
                sta $d07b                       ;slowdown during heavy game logic
Irq4_NoSCPU:    lda #<Irq6
                ldx #>Irq6
                ldy #IRQ6_LINE
                jmp Irq6_End
