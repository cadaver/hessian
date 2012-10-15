SCROLLROWS      = 22
SCROLLSPLIT     = 11

SCRCENTER_X     = 19
SCRCENTER_Y     = 13

CI_GROUND       = 1                             ;Char info bits
CI_OBSTACLE     = 2
CI_CLIMB        = 4
CI_SLOPE1       = 32
CI_SLOPE2       = 64
CI_SLOPE3       = 128

OPTIMIZE_SPRITEIRQS = 0

        ; Reset & center scrolling
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A

InitScroll:     lda #$00
                sta scrollSX
                sta scrollSY
                sta scrCounter
                sta scrAdd
                lda #$04
                sta scrollX
                sta scrollY
                jmp SL_NewMapPos

        ; Blank the gamescreen and turn off sprites
        ; (return to normal display by calling UpdateFrame)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X
        
BlankScreen:    jsr WaitBottom
                lda #$57
                sta Irq1_ScrollY+1
BS_Common:      ldx #$00
                stx Irq1_D015+1
                stx Irq1_MaxSprY+1
                rts

        ; Perform scrolling logic
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y

ScrollLogic:    lda scrAdd                      ;If speed is zero, look out
                beq SL_GetNewSpeed              ;for a new speed-setting
                clc
                adc scrCounter                  ;Update workcounter
                sta scrCounter
                tax
                lda scrollX                     ;Update finescroll-counters
                adc scrollCSX                   ;(let them wrap)
                and #$07
                sta scrollX
                lda scrollY
                clc
                adc scrollCSY
                and #$07
                sta scrollY                     ;Then check workcounter
                cpx #$08                        ;If it's >7 then this scrolling
                bcs SL_GetNewSpeed              ;is ready
                cpx #$04
                bne SL_CalcSprSub2
SL_SwapScreen:  lda screen
                eor #$01
                sta screen
SL_NewMapPos:   lda blockX
                sta SL_CSSBlockX+1
                lda blockY
                sta SL_CSSBlockY+1
                lda mapX
                sta SL_CSSMapX+1
                lda mapY
                sta SL_CSSMapY+1
SL_CalcSprSub2: jmp SL_CalcSprSub

SL_GetNewSpeed: lda #$00                        ;Reset the workcounter
                sta scrCounter
                ldx #$04                        ;Reset shift direction (center)
                lda scrollSX                    ;Get the requested speed
                sta scrollCSX
                beq SL_XDone
                bmi SL_XNeg
SL_XPos:        lda mapX                        ;Are we on the edge of map?
                clc                             ;(right)
                adc #$0a
                cmp limitR
                bcc SL_XPosOk
                lda blockX
                cmp #$01
                bcs SL_XZero
SL_XPosOk:      lda blockX                      ;Update block & map-coords
                adc #$01
                cmp #$04
                and #$03
                sta blockX
                bcc SL_XPosOk2
                inc mapX
SL_XPosOk2:     lda #$04
                sta scrollX
                inx
                bpl SL_XDone
SL_XNeg:        lda blockX                      ;Are we on the edge of map?
                bne SL_XNegOk                   ;(left)
                lda mapX
                cmp limitL
                beq SL_XZero
SL_XNegOk:      lda #$03
                dec blockX                      ;Update block & map-coords
                bpl SL_XNegOk2
                sta blockX
                dec mapX
SL_XNegOk2:     sta scrollX
                dex
                bpl SL_XDone
SL_XZero:       lda #$00
                sta scrollCSX
SL_XDone:       stx SW_ColorShiftDir+1
                lda scrollSY
                sta scrollCSY
                beq SL_YDone
                bmi SL_YNeg
SL_YPos:        lda mapY                        ;Are we on the edge of map?
                clc                             ;(bottom)
                adc #$06
                cmp limitD
                bcc SL_YPosOk
                lda blockY
                cmp #$02
                bcs SL_YZero
SL_YPosOk:      lda blockY                      ;Update block & map-coords
                adc #$01
                cmp #$04
                and #$03
                sta blockY
                bcc SL_YPosOk2
                inc mapY
SL_YPosOk2:     lda #$04
                sta scrollY
                inx
                inx
                inx
                bpl SL_YDone
SL_YNeg:        lda blockY                      ;Are we on the edge of map?
                bne SL_YNegOk                   ;(top)
                lda mapY
                cmp limitU
                beq SL_YZero
SL_YNegOk:      lda #$03
                dec blockY                      ;Update block & map-coords
                bpl SL_YNegOk2
                sta blockY
                dec mapY
SL_YNegOk2:     sta scrollY
                dex
                dex
                dex
                bpl SL_YDone
SL_YZero:       lda #$00
                sta scrollCSY
SL_YDone:       stx SW_ShiftDir+1
                ldy screen                      ;Update scrollwork jumps now
                lda screenBaseTbl,y
                eor #$04
                sta SW_DrawColorsUpLoop+2
                sta SW_DrawColorsUpLdx2+2
                sta SW_DrawColorsUpLdx3+2
                clc
                adc #$01
                sta SW_DrawColorsRLoop+2
                sta SW_DrawColorsRLdx2+2
                sta SW_DrawColorsRLdx3+2
                adc #$02
                sta SW_DrawColorsDownLoop+2
                sta SW_DrawColorsDownLdx2+2
                sta SW_DrawColorsDownLdx3+2
                lda screenJumpTblLo,y
                sta SW_ScreenJump+1
                lda screenJumpTblHi,y
                sta SW_ScreenJump+2
                lda colorJumpTblLo,x
                sta SW_ColorJump+1
                lda colorJumpTblHi,x
                sta SW_ColorJump+2
                lda scrollCSX                   ;Get absolute X-speed
                bpl SL_XPos2
                eor #$ff
                clc
                adc #$01
SL_XPos2:       tax
                sta scrAdd
                lda scrollCSY                   ;Then absolute Y-speed
                bpl SL_YPos2
                eor #$ff
                clc
                adc #$01
SL_YPos2:       tay
                cmp scrAdd                      ;Use the higher speed
                bcc SL_ScrAddYNotHigher
                sta scrAdd
SL_ScrAddYNotHigher:
                lda scrAdd
                cmp #$02                        ;If speed 2, then must use that on both axes
                bcc SL_ScrAddOk
                cpx #$02
                bcs SL_XSpeedOk
                asl scrollCSX
SL_XSpeedOk:    cpy #$02
                bcs SL_ScrAddOk
                asl scrollCSY
SL_ScrAddOk:
SL_CalcSprSub:
SL_CSSBlockX:   lda #$00
                asl
                asl
                asl
                ora scrollX
                asl
                asl
                asl
                sec
                sbc #<(31*8)
                sta DA_SprSubXL+1
SL_CSSMapX:     lda #$00
                sbc #(>(31*8))+1
                sta DA_SprSubXH+1
SL_CSSBlockY:   lda #$00
                asl
                asl
                asl
                ora scrollY
                asl
                asl
                asl
                sec
                sbc #<(54*8)
                sta DA_SprSubYL+1
SL_CSSMapY:     lda #$00
                sbc #(>(54*8))
                sta DA_SprSubYH+1
                rts

        ; Sort sprites, set new frame to be displayed and perform scrollwork
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp1-temp6

                if sprOrder < MAX_SPR+1         ;Ensure that a zeropage addressing trick works
                    err
                endif

UpdateFrame:
                if SHOW_FREE_RASTERTIME > 0
                dec $d020
                endif
UF_Wait:        lda targetFrames                ;Wait for NTSC delay if needed
                beq UF_Wait
                lda newFrame                    ;Wait until sprite IRQs are done with the current sprites
                bmi UF_Wait
                if SHOW_FREE_RASTERTIME > 0
                inc $d020
                endif
                dec targetFrames               
                lda firstSortSpr                ;Switch sprite doublebuffer side
                eor #MAX_SPR
                sta firstSortSpr
                ldx #$00
                stx temp3                       ;D010 bits for first IRQ
                txa
SSpr_Loop1:     ldy sprOrder,x                  ;Check for coordinates being in order
                cmp sprY,y
                beq SSpr_NoSwap2
                bcc SSpr_NoSwap1
                stx temp1                       ;If not in order, begin insertion loop
                sty temp2
                lda sprY,y
                ldy sprOrder-1,x
                sty sprOrder,x
                dex
                beq SSpr_Swapdone1
SSpr_Swap1:     ldy sprOrder-1,x
                sty sprOrder,x
                cmp sprY,y
                bcs SSpr_Swapdone1
                dex
                bne SSpr_Swap1
SSpr_Swapdone1: ldy temp2
                sty sprOrder,x
                ldx temp1
                ldy sprOrder,x
SSpr_NoSwap1:   lda sprY,y
SSpr_NoSwap2:   inx
                cpx #MAX_SPR
                bne SSpr_Loop1
                ldx #$00
SSpr_FindFirst: ldy sprOrder,x                  ;Find upmost visible sprite
                lda sprY,y
                cmp #MIN_SPRY
                bcs SSpr_FirstFound
                inx
                bne SSpr_FindFirst
SSpr_FirstFound:txa
                adc #<sprOrder                  ;Add one more, C=1 becomes 0
                sbc firstSortSpr                ;Subtract one more to cancel out
                sta SSpr_CopyLoop1+1
                ldy firstSortSpr
                tya
                adc #8-1                        ;C=1
                sta SSpr_CopyLoop1End+1         ;Set endpoint for first copyloop
                bpl SSpr_CopyLoop1

SSpr_CopyLoop1Skip:
                inc SSpr_CopyLoop1+1
SSpr_CopyLoop1: ldx sprOrder,y
                lda sprY,x                      ;If reach the maximum Y-coord, all done
                cmp #MAX_SPRY
                bcs SSpr_CopyLoop1Done
                sta sortSprY,y
                lda sprC,x                      ;Check flashing
                bmi SSpr_CopyLoop1Skip
                sta sortSprC,y
                lda sprF,x
                sta sortSprF,y
                lda sprXL,x
                sta sortSprX,y
                lda sprXH,x
                beq SSpr_CopyLoop1MsbLow
                lda temp3
                ora sprOrTbl,y
                sta temp3
SSpr_CopyLoop1MsbLow:
                iny
SSpr_CopyLoop1End:
                cpy #$00
                bcc SSpr_CopyLoop1
                lda temp3
                sta sortSprD010-1,y
                lda sortSprC-1,y                ;Make first IRQ endmark
                ora #$80
                sta sortSprC-1,y
                lda SSpr_CopyLoop1+1            ;Copy sortindex from first copyloop
                sta SSpr_CopyLoop2+1            ;to second
                bcs SSpr_CopyLoop2

SSpr_CopyLoop1Done:
                lda temp3
                sta sortSprD010-1,y
                sty temp1                       ;Store sorted sprite end index
                cpy firstSortSpr                ;Any sprites at all?
                beq SSpr_NoSprites
                lda sortSprC-1,y                ;Make first (and final) IRQ endmark
                ora #$80
                sta sortSprC-1,y
                jmp SSpr_FinalEndMark
SSpr_NoSprites: jmp SSpr_AllDone

SSpr_CopyLoop2Skip:
                inc SSpr_CopyLoop2+1
SSpr_CopyLoop2: ldx sprOrder,y
                lda sprY,x
                cmp #MAX_SPRY
                bcs SSpr_CopyLoop2Done
                sta sortSprY,y
                sbc #21-1
                cmp sortSprY-8,y                ;Check for physical sprite overlap
                bcc SSpr_CopyLoop2Skip
                lda sprC,x                      ;Check flashing
                bmi SSpr_CopyLoop2Skip
                sta sortSprC,y
                lda sprF,x
                sta sortSprF,y
                lda sprXL,x
                sta sortSprX,y
                lda sprXH,x
                beq SSpr_CopyLoop2MsbLow
                lda sortSprD010-1,y
                ora sprOrTbl,y
                bne SSpr_CopyLoop2MsbDone
SSpr_CopyLoop2MsbLow:
                lda sortSprD010-1,y
                and sprAndTbl,y
SSpr_CopyLoop2MsbDone:
                sta sortSprD010,y
                iny
                bne SSpr_CopyLoop2

SSpr_CopyLoop2Done:
                sty temp1                       ;Store sorted sprite end index
                ldy SSpr_CopyLoop1End+1         ;Go back to the second IRQ start
                cpy temp1
                beq SSpr_FinalEndMark
SSpr_IrqLoop:   sty temp2                       ;Store IRQ startindex
                lda sortSprY,y                  ;C=0 here
                if OPTIMIZE_SPRITEIRQS > 0
                sbc #21+12-1                    ;First sprite of IRQ: store the Y-coord
                sta SSpr_IrqYCmp1+1             ;compare values
                adc #21+12+6-1
                else
                adc #6
                endif
                sta SSpr_IrqYCmp2+1
SSpr_IrqSprLoop:iny
                cpy temp1
                bcs SSpr_IrqDone
                if OPTIMIZE_SPRITEIRQS > 0
                lda sortSprY-8,y                ;Add next sprite to this IRQ?
SSpr_IrqYCmp1:  cmp #$00                        ;(try to add as many as possible while
                bcc SSpr_IrqSprLoop             ;avoiding glitches)
                endif
                lda sortSprY,y
SSpr_IrqYCmp2:  cmp #$00
                bcc SSpr_IrqSprLoop
SSpr_IrqDone:   tya
                sbc temp2
                tax
                lda sprIrqAdvanceTbl-1,x
                ldx temp2
                adc sortSprY,x
                sta sprIrqLine-1,x              ;Store IRQ start line (with advance)
                lda sortSprC-1,y                ;Make endmark
                ora #$80
                sta sortSprC-1,y
                cpy temp1                       ;Sprites left?
                bcc SSpr_IrqLoop
SSpr_FinalEndMark:
                lda #$00                        ;Make final endmark
                sta sprIrqLine-1,y

SSpr_AllDone:
                if SHOW_FREE_RASTERTIME > 0
                dec $d020
                endif
UF_WaitPrevFrame:
                lda newFrame                    ;Now wait until the previous new frame
                bne UF_WaitPrevFrame            ;has been processed
                lda scrCounter                  ;Is it the colorshift? (needs special timing)
                cmp #$04
                bne UF_WaitNormal
                if SHOW_COLORSCROLL_WAIT > 0
                dec $d020
                endif
UF_WaitColorShift:
                lda $d012                       ;Wait until we are near the scorescreen split
                cmp #IRQ3_LINE-$48
                bcc UF_WaitColorShift
                cmp #IRQ3_LINE+$20
                bcs UF_WaitColorShift
                if SHOW_COLORSCROLL_WAIT > 0
                inc $d020
                endif
                bcc UF_WaitDone
UF_WaitNormal:  lda $d011                       ;If no colorshift, just need to make sure we
                bmi UF_WaitDone                 ;are not late from the frameupdate
                lda $d012
                cmp #IRQ1_LINE+$02
                bcs UF_WaitDone
                cmp #IRQ1_LINE-$05
                bcs UF_WaitNormal
UF_WaitDone:    
                if SHOW_FREE_RASTERTIME > 0
                inc $d020
                endif
                lda scrollX                     ;Copy scrolling and screen number
                eor #$07
                ora #$10
                sta Irq1_ScrollX+1
                lda scrollY
                eor #$07
                ora #$10
                sta Irq1_ScrollY+1
                ldx screen
                lda d018Tbl,x
                sta Irq1_Screen+1
                lda screenFrameTbl,x
                sta Irq1_ScreenFrame+1
                tya                             ;Check which sprites are on
                sec
                sbc firstSortSpr
                cmp #$09
                bcc UF_NotMoreThan8
                lda #$08
UF_NotMoreThan8:tax
                lda d015Tbl,x
                sta Irq1_D015+1
                beq UF_NoSprites
                ldx firstSortSpr                ;Find out sprite Y-range for the fastloader
                stx Irq1_FirstSortSpr+1
                lda sortSprY,x                  ;(where to avoid the timed data transfer)
                sec
                sbc #$04
                sta Irq1_MinSprY+1
                ldy temp1
                lda sortSprY-1,y
                adc #22
UF_NoSprites:   sta Irq1_MaxSprY+1
                lda #$80
                sta newFrame
                
ScrollWork:     lda scrCounter
                bne SW_NoScreenShift
                lda scrAdd
                beq SW_NoWork
SW_ShiftScreen:
SW_ShiftDir:    ldx #$04
                lda shiftEndTbl,x
                pha
                ldy shiftSrcTbl,x
                lda shiftDestTbl,x
                tax
                pla
SW_ScreenJump:  jmp SW_NoWork

SW_NoScreenShift:
                cmp #$04
                bne SW_NoShiftColors
SW_ShiftColors:
SW_ColorShiftDir:
                ldx #$00
                stx temp1
SW_ColorJump:   jmp SW_NoWork
            
SW_NoShiftColors:
                cmp #$02
                bne SW_NoWork
SW_DrawBlocks:  lda scrollCSX
                beq SW_DBXDone
                bmi SW_DBLeft
SW_DBRight:     jsr SW_DrawRight
                jmp SW_DBXDone
SW_DBLeft:      jsr SW_DrawLeft
SW_DBXDone:     lda scrollCSY
                beq SW_NoWork
                bmi SW_DBUp
SW_DBDown:      jmp SW_DrawDown
SW_DBUp:        jmp SW_DrawUp
SW_NoWork:      rts

        ; Screen shifting routines

SW_Shift1:      sta SW_Shift1End
SW_Shift1Loop:                                  ;Screen shift routine:
N               set 0                           ;From screen1 to screen2
                repeat SCROLLROWS
                lda screen1-40+N*40,y
                sta screen2+N*40,x
N               set N+1
                repend
                dey
                dex
SW_Shift1End:   beq SW_Shift1Done
                jmp SW_Shift1Loop
SW_Shift1Done:  rts

SW_Shift2:      sta SW_Shift2End
SW_Shift2Loop:                                  ;Screen shift routine:
N               set 0                           ;From screen2 to screen1
                repeat SCROLLROWS
                lda screen2-40+N*40,y
                sta screen1+N*40,x
N               set N+1
                repend
                dey
                dex
SW_Shift2End:   beq SW_Shift2Done
                jmp SW_Shift2Loop
SW_Shift2Done:  rts

        ; Color shifting routines

SW_ShiftColorsUp:
                lda colorYTbl-3,x
                sta SW_ShiftColorsUpTopIny
                sta SW_ShiftColorsUpBottomIny
                lda colorXTbl-3,x
                sta SW_ShiftColorsUpTopInx
                sta SW_ShiftColorsUpBottomInx
                lda colorEndTbl-3,x
                sta SW_ShiftColorsUpTopCpx+1
                sta SW_ShiftColorsUpBottomCpx+1
                ldy colorDestTbl-3,x
                lda colorSrcTbl-3,x
                tax
SW_ShiftColorsUpTopLoop:
N               set SCROLLSPLIT-1
                repeat SCROLLSPLIT
                lda colors+N*40,x
                sta colors+40+N*40,y
N               set N-1
                repend
SW_ShiftColorsUpTopIny:
                iny
SW_ShiftColorsUpTopInx:
                inx
SW_ShiftColorsUpTopCpx:
                cpx #$00
                bne SW_ShiftColorsUpTopLoop
                jsr SW_DrawColorsUp
                ldx temp1
                ldy colorSideTbl-3,x
                jsr SW_DrawColorsHorizTop
                ldx temp1
                ldy colorDestTbl-3,x
                lda colorSrcTbl-3,x
                tax
SW_ShiftColorsUpBottomLoop:
N               set SCROLLROWS-2
                repeat SCROLLROWS-SCROLLSPLIT-2
                lda colors+N*40,x
                sta colors+40+N*40,y
N               set N-1
                repend
SW_ShiftColorsUpBottomIny:
                iny
SW_ShiftColorsUpBottomInx:
                inx
SW_ShiftColorsUpBottomCpx:
                cpx #$00
                bne SW_ShiftColorsUpBottomLoop
                jsr SW_DrawColorsReconstruct
                ldx temp1
                ldy colorSideTbl-3,x
SW_DrawColorsHorizBottom:
                bmi SW_DrawColorsHorizBottomSkip
                lda screen
                bne SW_DrawColorsHorizBottomScreen2
SW_DrawColorsHorizBottomScreen1:
N               set SCROLLSPLIT
                repeat SCROLLROWS-SCROLLSPLIT
                ldx screen1+N*40,y
                lda charColors,x
                sta colors+N*40,y
N               set N+1
                repend
SW_DrawColorsHorizBottomSkip:
                rts
SW_DrawColorsHorizBottomScreen2:
N               set SCROLLSPLIT
                repeat SCROLLROWS-SCROLLSPLIT
                ldx screen2+N*40,y
                lda charColors,x
                sta colors+N*40,y
N               set N+1
                repend
                rts

SW_ShiftColorsHoriz:
                lda colorYTbl-3,x
                sta SW_ShiftColorsHorizTopIny
                sta SW_ShiftColorsHorizBottomIny
                lda colorXTbl-3,x
                sta SW_ShiftColorsHorizTopInx
                sta SW_ShiftColorsHorizBottomInx
                lda colorEndTbl-3,x
                sta SW_ShiftColorsHorizTopCpx+1
                sta SW_ShiftColorsHorizBottomCpx+1
                ldy colorDestTbl-3,x
                lda colorSrcTbl-3,x
                tax
SW_ShiftColorsHorizTopLoop:
N               set 0
                repeat SCROLLSPLIT
                lda colors+N*40,x
                sta colors+N*40,y
N               set N+1
                repend
SW_ShiftColorsHorizTopIny:
                iny
SW_ShiftColorsHorizTopInx:
                inx
SW_ShiftColorsHorizTopCpx:
                cpx #$00
                bne SW_ShiftColorsHorizTopLoop
                ldx temp1
                ldy colorSideTbl-3,x
                jsr SW_DrawColorsHorizTop
                ldx temp1
                ldy colorDestTbl-3,x
                lda colorSrcTbl-3,x
                tax
SW_ShiftColorsHorizBottomLoop:
N               set SCROLLSPLIT
                repeat SCROLLROWS-SCROLLSPLIT
                lda colors+N*40,x
                sta colors+N*40,y
N               set N+1
                repend
SW_ShiftColorsHorizBottomIny:
                iny
SW_ShiftColorsHorizBottomInx:
                inx
SW_ShiftColorsHorizBottomCpx:
                cpx #$00
                bne SW_ShiftColorsHorizBottomLoop
                ldx temp1
                ldy colorSideTbl-3,x
                jmp SW_DrawColorsHorizBottom

SW_ShiftColorsDown:
                lda colorYTbl-3,x
                sta SW_ShiftColorsDownTopIny
                sta SW_ShiftColorsDownBottomIny
                lda colorXTbl-3,x
                sta SW_ShiftColorsDownTopInx
                sta SW_ShiftColorsDownBottomInx
                lda colorEndTbl-3,x
                sta SW_ShiftColorsDownTopCpx+1
                sta SW_ShiftColorsDownBottomCpx+1
                ldy colorDestTbl-3,x
                lda colorSrcTbl-3,x
                tax
SW_ShiftColorsDownTopLoop:
N               set 0
                repeat SCROLLSPLIT
                lda colors+40+N*40,x
                sta colors+N*40,y
N               set N+1
                repend
SW_ShiftColorsDownTopIny:
                iny
SW_ShiftColorsDownTopInx:
                inx
SW_ShiftColorsDownTopCpx:
                cpx #$00
                bne SW_ShiftColorsDownTopLoop
                ldx temp1
                ldy colorSideTbl-3,x
                jsr SW_DrawColorsHorizTop
                ldx temp1
                ldy colorDestTbl-3,x
                lda colorSrcTbl-3,x
                tax
SW_ShiftColorsDownBottomLoop:
N               set SCROLLSPLIT
                repeat SCROLLROWS-SCROLLSPLIT-1
                lda colors+40+N*40,x
                sta colors+N*40,y
N               set N+1
                repend
SW_ShiftColorsDownBottomIny:
                iny
SW_ShiftColorsDownBottomInx:
                inx
SW_ShiftColorsDownBottomCpx:
                cpx #$00
                bne SW_ShiftColorsDownBottomLoop
                ldx temp1
                ldy colorSideTbl-3,x
                jsr SW_DrawColorsHorizBottom
                jmp SW_DrawColorsDown

SW_DrawColorsHorizTop:
                bmi SW_DrawColorsHorizTopSkip
                lda screen
                bne SW_DrawColorsHorizTopScreen2
SW_DrawColorsHorizTopScreen1:
N               set 0
                repeat SCROLLSPLIT
                ldx screen1+N*40,y
                lda charColors,x
                sta colors+N*40,y
N               set N+1
                repend
SW_DrawColorsHorizTopSkip:
                rts
SW_DrawColorsHorizTopScreen2:
N               set 0
                repeat SCROLLSPLIT
                ldx screen2+N*40,y
                lda charColors,x
                sta colors+N*40,y
N               set N+1
                repend
                rts

SW_DrawColorsReconstruct:
                ldy #12                         ;Reconstruct the colors that are lost at
SW_DrawColorsRLoop:                             ;the scroll split
                ldx screen1+SCROLLSPLIT*40+40,y
                lda charColors,x
                sta colors+SCROLLSPLIT*40+40,y
SW_DrawColorsRLdx2:
                ldx screen1+SCROLLSPLIT*40+40+13,y
                lda charColors,x
                sta colors+SCROLLSPLIT*40+40+13,y
SW_DrawColorsRLdx3:
                ldx screen1+SCROLLSPLIT*40+40+26,y
                lda charColors,x
                sta colors+SCROLLSPLIT*40+40+26,y
                dey
                bpl SW_DrawColorsRLoop
                rts

SW_DrawColorsUp:ldy #12
SW_DrawColorsUpLoop:
                ldx screen1,y
                lda charColors,x
                sta colors,y
SW_DrawColorsUpLdx2:
                ldx screen1+13,y
                lda charColors,x
                sta colors+13,y
SW_DrawColorsUpLdx3:
                ldx screen1+26,y
                lda charColors,x
                sta colors+26,y
                dey
                bpl SW_DrawColorsUpLoop
                rts

SW_DrawColorsDown:
                ldy #12
SW_DrawColorsDownLoop:
                ldx screen1+SCROLLROWS*40-40,y
                lda charColors,x
                sta colors+SCROLLROWS*40-40,y
SW_DrawColorsDownLdx2:
                ldx screen1+SCROLLROWS*40-40+13,y
                lda charColors,x
                sta colors+SCROLLROWS*40-40+13,y
SW_DrawColorsDownLdx3:
                ldx screen1+SCROLLROWS*40-40+26,y
                lda charColors,x
                sta colors+SCROLLROWS*40-40+26,y
                dey
                bpl SW_DrawColorsDownLoop
                rts

        ; New blocks drawing routines

SW_DrawRight:   lda blockX
                clc
                adc #$02
                cmp #$04
                and #$03
                sta temp1
                lda mapX
                adc #$09
                ldy #38
                bne SWDL_Common

SW_DrawLeft:    lda blockX
                sta temp1
                lda mapX
                ldy #$00
SWDL_Common:    sty SWDL_Sta+1
                ldx mapY
                clc
                adc mapTblLo,x
                sta temp3
                lda mapTblHi,x
                adc #$00
                sta temp4
                lda screen
                eor #$01
                tax
                lda screenBaseTbl,x
                sta SWDL_Sta+2
                lda #SCROLLROWS-1
                sta temp5
                lda blockY
                asl
                asl
                ora temp1
                ldx #$00
SWDL_GetBlock:  sta temp2
                ldy #$00
                lda (temp3),y
                tay
                lda blkTblLo,y
                sta SWDL_Lda+1
                lda blkTblHi,y
                sta SWDL_Lda+2
                ldy temp2
                clc
SWDL_Lda:       lda $1000,y
SWDL_Sta:       sta $1000,x
                dec temp5
                bmi SWDL_Ready
                txa
                adc #40
                tax
                bcc SWDL_Not2
                clc
                inc SWDL_Sta+2
SWDL_Not2:      lda blockDownTbl,y
                tay
                bpl SWDL_Lda
SWDL_Block:     lda temp3
                adc mapSizeX
                sta temp3
                bcc SWDL_Not3
                inc temp4
SWDL_Not3:      lda temp1
                bpl SWDL_GetBlock
SWDL_Ready:     rts

SW_DrawDown:    lda mapY                        ;Draw new blocks to bottom of
                clc                             ;screen
                adc #$05
                tax
                lda blockY
                adc #$01
                cmp #$04
                bcc SW_DDCalcDone
                and #$03
                inx
SW_DDCalcDone:  asl
                asl
                ora blockX
                sta temp2
                lda screen
                eor #$01
                tay
                lda #<(screen1+SCROLLROWS*40-40)
                sta SWDU_Sta+1
                lda screenBaseTbl,y
                ora #>(SCROLLROWS*40-40)
                sta SWDU_Sta+2
                bne SWDU_Common

SW_DrawUp:      ldx mapY                     ;Draw new blocks to top of screen
                lda blockY
                asl
                asl
                ora blockX
                sta temp2
                lda screen
                eor #$01
                tay
                lda #$00
                sta SWDU_Sta+1
                lda screenBaseTbl,y
                sta SWDU_Sta+2
SWDU_Common:    lda mapTblLo,x
                sta temp3
                lda mapTblHi,x
                sta temp4
                ldx #$00
                ldy mapX
SWDU_GetBlock:  lda (temp3),y
                iny
                sty temp5
                tay
                lda blkTblLo,y
                sta SWDU_Lda+1
                lda blkTblHi,y
                sta SWDU_Lda+2
                ldy temp2
SWDU_Lda:       lda $1000,y
SWDU_Sta:       sta screen1,x
                inx
                cpx #39
                bcs SWDU_Ready
                lda blockRightTbl,y
                tay
                bpl SWDU_Lda
                and #$0f
                sta temp2
                ldy temp5
                jmp SWDU_GetBlock
SWDU_Ready:     rts

        ; Redraw screen fully and center scrolling
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp1-temp7

RedrawScreen:   lda blockY
                asl
                asl
                ora blockX
                sta temp1
                sta temp2
                ldy screen
                lda #$00
                sta SWDU_Sta+1
                lda screenBaseTbl,y
                sta SWDU_Sta+2
                lda #SCROLLROWS
                sta temp6
                ldx mapY
RS_Loop:        stx temp7
                jsr SWDU_Common
                ldx temp7
                lda SWDU_Sta+1
                clc
                adc #40
                sta SWDU_Sta+1
                bcc RS_NotOver1
                inc SWDU_Sta+2
RS_NotOver1:    ldy temp1
                lda blockDownTbl,y
                bpl RS_NotOver3
                inx
RS_NotOver2:    and #$0f
RS_NotOver3:    sta temp1
                sta temp2
                dec temp6
                bne RS_Loop
                ldy #38                         ;Finally draw the colors
RS_Colors:      jsr SW_DrawColorsHorizTop
                jsr SW_DrawColorsHorizBottom
                dey
                bpl RS_Colors
                jmp InitScroll

        ; Update block outside the current zone. No need to update on screen, but must find out
        ; the destination zone first. Note: nonexistent map position causes undefined behaviour

UB_OutsideZone: lda zoneNum                     ;TODO: test this codepath
                sta temp4
                jsr FindZoneXY
                lda temp8
                sec
                sbc limitU
                ldy mapSizeX
                ldx #zpDestLo
                jsr MulU
                ldy #zoneLo
                jsr Add16
                lda #ZONEH_DATA                 ;Add zone mapdata offset
                jsr Add8
                lda temp7
                sec
                sbc limitL
                tay
                lda (zpDestLo),y
                clc
                and temp6
                adc temp5
                sta (zpDestLo),y
UB_RestoreZone: lda temp4
                jmp FindZoneNum

        ; Animate a block on the map by deltavalue. If on screen, refresh it immediately. 
        ; Note: call only in between ScrollLogic & UpdateFrame
        ;
        ; Parameters: A block deltavalue, X horizontal map coordinate, Y vertical map coordinate
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

UpdateBlockDelta:
                sta temp5
                lda #$ff
                sta temp6
                bne UB_Common

        ; Update a block on the map. If on screen, refresh it immediately. 
        ; Note: call only in between ScrollLogic & UpdateFrame
        ;
        ; Parameters: A new block, X horizontal map coordinate, Y vertical map coordinate
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

UpdateBlock:    sta temp5
                lda #$00
                sta temp6
UB_Common:      stx temp7
                sty temp8
                cpx limitL
                bcc UB_OutsideZone
                cpx limitR
                bcs UB_OutsideZone
                cpy limitU
                bcc UB_OutsideZone
                cpy limitD
                bcs UB_OutsideZone
UB_InsideZone:  lda mapTblLo,y
                sta zpDestLo
                lda mapTblHi,y
                sta zpDestHi
                txa
                tay
                lda (zpDestLo),y
                clc
                and temp6
                adc temp5
                sta (zpDestLo),y
                tay
                lda blkTblLo,y
                sta UB_Lda+1
                sta UB_Lda2+1
                lda blkTblHi,y
                sta UB_Lda+2
                sta UB_Lda2+2
                lda temp7                       ;Calculate screen position for update
                sec
                sbc SL_CSSMapX+1
                cmp #11
                bcs UB_Done
                asl
                asl
                sec
                sbc SL_CSSBlockX+1
                sta temp5
                lda temp8
                sec
                sbc SL_CSSMapY+1
                cmp #7
                bcs UB_Done
                asl
                asl
                sec
                sbc SL_CSSBlockY+1
                sta temp6
                ldx #$00
UB_Row:         lda temp6
                cmp #SCROLLROWS
                bcs UB_SkipRow
                jsr UB_GetRowOffset
                ldy screen
                lda zpDestHi
                ora screenBaseTbl,y
                sta zpDestHi
                and #$03
                ora #>colors
                sta zpBitsHi
                lda zpDestLo
                sta zpBitsLo
                ldy temp5
UB_Column:      cpy #39
                bcs UB_SkipColumn
UB_Lda:         lda $1000,x                     ;Take char from block
                sta (zpDestLo),y                ;Store char to screen
                sta UB_LdaColor+1
UB_LdaColor:    lda charColors
                sta (zpBitsLo),y                ;Store color to color-RAM
UB_SkipColumn:  iny
                inx
                txa
                and #$03
                bne UB_Column
                beq UB_RowDone
UB_SkipRow:     txa
                adc #$03                        ;C=1
                tax
UB_RowDone:     inc temp6
                cpx #$10
                bcc UB_Row
UB_Done:        lda scrAdd                      ;If scrolling is in the phase of copying the screen
                beq UB_Done2                    ;must also write the block to the other screen
                lda scrCounter
                beq UB_Done2
                cmp #$04
                bcs UB_Done2
                lda temp7
                sec
                sbc mapX
                cmp #11
                bcs UB_Done2
                asl
                asl
                sec
                sbc blockX
                sta temp5
                lda temp8
                sec
                sbc mapY
                cmp #7
                bcs UB_Done2
                asl
                asl
                sec
                sbc blockY
                sta temp6
                ldx #$00
UB_Row2:        lda temp6
                cmp #SCROLLROWS
                bcs UB_SkipRow2
                jsr UB_GetRowOffset
                ldy screen
                lda zpDestHi
                ora screenBaseTbl,y
                eor #$04
                sta zpDestHi
                ldy temp5
UB_Column2:     cpy #39
                bcs UB_SkipColumn2
UB_Lda2:        lda $1000,x                     ;Take char from block
                sta (zpDestLo),y                ;Store char to screen
UB_SkipColumn2: iny
                inx
                txa
                and #$03
                bne UB_Column2
                beq UB_RowDone2
UB_SkipRow2:    txa
                adc #$03                        ;C=1
                tax
UB_RowDone2:    inc temp6
                cpx #$10
                bcc UB_Row2
UB_Done2:       rts

        ;Subroutine to get screen row start offset with optimized multiply by 40

UB_GetRowOffset:ldy #$00
                sty zpDestHi
                sta zpBitBuf
                asl
                rol zpDestHi
                asl
                rol zpDestHi
                clc
                adc zpBitBuf
                bcc UB_NotOver
                inc zpDestHi
UB_NotOver:     asl
                rol zpDestHi
                asl
                rol zpDestHi
                asl
                rol zpDestHi
                sta zpDestLo
                rts
