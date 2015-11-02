IRQ1_LINE       = MIN_SPRY-12
IRQ3_LINE       = SCROLLROWS*8+44
IRQ4_LINE       = IRQ3_LINE+8
IRQ5_LINE       = 143

PANEL_BG2       = $0b
PANEL_BG3       = $0c

TEXT_BG1        = $00
TEXT_BG2        = $0b
TEXT_BG3        = $0c

        ; Blank the gamescreen and turn off sprites
        ; (return to normal display by calling UpdateFrame)
        ;
        ; Parameters: -
        ; Returns: X=0
        ; Modifies: A,X
        
BlankScreen:    jsr WaitBottom
                lda #$57
                sta Irq1_ScrollY+1
BS_Common:      ldx #$00
                stx Irq1_D015+1
                stx Irq1_MaxSprY+1
                stx Irq4_LevelUpdate+1          ;Disable level animation by default
                rts

        ; Raster interrupt 3. Gamescreen / scorepanel split

Irq3:           sta irqSaveA
                stx irqSaveX
                lda #$35
                sta $01                         ;Ensure IO memory is available
Irq3_Direct:    lda $d011
                ldx #IRQ3_LINE
Irq3_Wait:      cpx $d012
                bcs Irq3_Wait
                cmp #$15
                bne Irq3_NoBadLine
Irq3_Blank:     lda #$57                        ;Immediate blanking if badline
                sta $d011
                lda #PANEL_D018                 ;Set panelscreen screen ptr.
                sta $d018
Irq3_SplitDone: sty irqSaveY
                lsr newFrame                    ;Can update sprites now
                lda #$00
                sta $d015                       ;Make sure sprites are off in the border and
                sta $d021                       ;do not disturb the fastloader
                lda #PANEL_BG2                  ;Set scorepanel multicolors
                sta $d022
                lda #PANEL_BG3
                sta $d023
                lda #<Irq4
                ldx #>Irq4
                ldy #IRQ4_LINE
Irq3_EndJump:   jmp SetNextIrq
Irq3_NoBadLine: ora #$07                        ;No badline: stabilize Y-scroll first
                sta $d011
                nop
                ldx #5
Irq3_Delay:     dex
                bpl Irq3_Delay
                bmi Irq3_Blank

        ; Raster interrupt 1. Show game screen

Irq1:           jsr StartIrq
                ldx #$00                        ;Reset frame update
                stx newFrame
Irq1_MinSprY:   lda #$00                        ;Copy new min/max sprite Y range to know
Irq1_StoreMinSprY:                              ;when fastloader can transfer data
                sta FL_MinSprY+1
Irq1_MaxSprY:   lda #$00
Irq1_StoreMaxSprY:
                sta FL_MaxSprY+1
Irq1_ScrollX:   lda #$17
                sta $d016
Irq1_ScrollY:   lda #$57
                sta $d011
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
                stx $d07a                       ;SCPU back to slow mode
                stx $d030                       ;C128 back to 1MHz
Irq1_D015:      lda #$00
                sta $d015
                bne Irq1_HasSprites
Irq1_NoSprites: cpy #GAMESCR1_D018+1            ;Use split mode?
                beq Irq1_SetupTextscreenSplit
                jmp Irq2_AllDone
Irq1_SetupTextscreenSplit:
                lda #<Irq5
                ldx #>Irq5
                ldy #IRQ5_LINE
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

                if (Irq2_Spr0 & $ff00) != (Irq2_Spr7 & $ff00)
                err
                endif

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
                sta $d012
                sec
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

Irq2_AllDone:   lda #IRQ3_LINE-1
                tay
                sec
                sbc #$03
                cmp $d012                       ;Late from the scorepanel IRQ?
                bcc Irq2_LatePanel
                lda #<Irq3
                ldx #>Irq3
SetNextIrq:     sty $d012
                sta $fffe
                stx $ffff
SetNextIrqNoAddress:
                dec $d019                       ;Acknowledge raster IRQ
                lda irqSave01
                sta $01                         ;Restore $01 value
                lda irqSaveA
                ldx irqSaveX
                ldy irqSaveY
                rti

Irq2_LatePanel: ldy irqSaveY
                jmp Irq3_Direct

        ;Raster interrupt 4. Show panel, play music, set C128 to 2MHz mode and SCPU to turbo mode,
        ;if no loading going on. Also animate level graphics

Irq4:           jsr StartIrq
                lda #$18
                sta $d016
                lda #$17                        ;Switch screen back on
                sta $d011
                if SHOW_PLAYROUTINE_TIME > 0
                inc $d020
                endif
                jsr PlayRoutine                 ;Play music/sound effects
                if SHOW_PLAYROUTINE_TIME > 0
                dec $d020
                endif
                ldx fileOpen
                bne Irq4_NoTurbo
                inx
Irq4_WaitTurbo: lda $d012                       ;Busy-wait for the last badline (required for C128)
                cmp #240
                bcc Irq4_WaitTurbo
Irq4_EnableTurbo:
                stx $d07b
                stx $d030
Irq4_NoTurbo:
Irq4_LevelUpdate:
                lda #$00                        ;Animate level background?
                beq Irq4_NoLevelUpdate
                if SHOW_LEVELUPDATE_TIME > 0
                inc $d020
                endif
                jsr UpdateLevel
                if SHOW_LEVELUPDATE_TIME > 0
                dec $d020
                endif
Irq4_NoLevelUpdate:
                lda #<Irq1
                ldx #>Irq1
                ldy #IRQ1_LINE
                jmp SetNextIrq

        ; Raster interrupt 5. Text screen split

Irq5:           jsr StartIrq
                lda #TEXTSCR_D018
                sta $d018
                jmp Irq2_AllDone

        ; IRQ common startup code

StartIrq:       cld
                sta irqSaveA
                stx irqSaveX
                sty irqSaveY
                lda #$35                        ;Ensure IO memory is available
                sta $01
                rts
