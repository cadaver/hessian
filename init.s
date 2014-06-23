scriptCodeStart:

        ; Initialize registers/variables at startup. This code is called only once and can be
        ; disposed after that.
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

InitAll:

        ; Initialize zeropage variables

                ldx #$90-joystick-1
                lda #$00
InitZP:         sta joystick,x
                dex
                bpl InitZP

        ; Initialize playroutine

                sta $d415                       ;Filter lowbyte
                sta ntFiltPos
                sta ntFiltTime
                lda #$7f
                sta ntInitSong

                lda #<fileAreaStart
                sta freeMemLo
                lda #>fileAreaStart
                sta freeMemHi

        ; Load options file
        
                lda #F_OPTIONS
                jsr MakeFileName_Direct
                jsr OpenFile
                ldx #$00
LoadOptions:    jsr GetByte
                bcs LoadOptionsDone
                sta difficulty,x
                inx
                bcc LoadOptions
LoadOptionsDone:

        ; Detect REU and install the REU scrolling routines if applicable

DetectREU:      lda $dc01                       ;If space held down when starting,
                and #$10                        ;revert to no REU scrolling to avoid
                beq NoREU                       ;possible incompatibility
                ldx #$00
DR_WriteLoop:   txa
                sta screen2,x
                inx
                bne DR_WriteLoop
                ldx #$90
                jsr DR_Transfer
                ldx #$00
                txa
DR_ClearLoop:   sta screen2,x
                inx
                bne DR_ClearLoop
                ldx #$91
                jsr DR_Transfer
                ldx #$00
DR_CheckLoop:   txa
                cmp screen2,x
                bne NoREU
                inx
                bne DR_CheckLoop
                jsr InstallREUScroller
NoREU:

        ; Initialize scrolling

                jsr InitScroll

        ; Initialize panel text printing

                lda #8
                sta textLeftMargin
                lda #32
                sta textRightMargin
                lda #REDRAW_ITEM+REDRAW_AMMO
                sta panelUpdateFlags

        ;Initialize the sprite multiplexing system

InitSprites:    lda #$00
                sta newFrame
                sta firstSortSpr
                lda #$ff
                sta sprFileNum
                ldx #MAX_SPR
                lda #$01
                sta temp1
ISpr_Loop:      txa
                sta sprOrder,x
                lda #$ff
                sta sprY,x
                cpx #MAX_SPR
                beq ISpr_OrValueOk
                lda temp1
                sta sprOrTbl,x
                sta sprOrTbl+MAX_SPR,x
                eor #$ff
                sta sprAndTbl,x
                sta sprAndTbl+MAX_SPR,x
                asl temp1
                bne ISpr_OrValueOk
                lda #$01
                sta temp1
ISpr_OrValueOk: dex
                bpl ISpr_Loop
                ldx #MAX_CACHESPRITES-1
ISpr_ClearCacheInUse:
                lda #$00
                sta cacheSprAge,x
                lda #$ff
                sta cacheSprFile,x
                dex
                bpl ISpr_ClearCacheInUse

        ; Load resident sprites

                ldy #C_COMMON
                jsr LoadSpriteFile
                ldy #C_ITEM
                jsr LoadSpriteFile
                ldy #C_WEAPON
                jsr LoadSpriteFile

        ; Initialize video registers and screen memory

InitVideo:      jsr WaitBottom
                lda $dd00                       ;Set game videobank
                and #$fc
                sta $dd00
                lda #$00
                sta $d011                       ;Blank screen
                sta $d01b                       ;Sprites on top of BG
                sta $d01d                       ;Sprite X-expand off
                sta $d017                       ;Sprite Y-expand off
                sta screen
                lda #$ff                        ;Set all sprites multicolor
                sta $d01c
                sta $d001
                sta $d003
                sta $d005
                sta $d007
                sta $d009
                sta $d00b
                sta $d00d
                sta $d00f
                sta $d015                       ;All sprites on and to the bottom
                jsr WaitBottom
                ldx #$00                        ;Sprites off now
                stx $d015
                stx $d026                       ;Set sprite multicolors
                lda #$0a
                sta $d025
                ldx #$00
IVid_CopyTextChars:
                lda textCharsCopy,x
                sta textChars,x
                lda textCharsCopy+$100,x
                sta textChars+$100,x
                lda textCharsCopy+$200,x
                sta textChars+$200,x
                inx
                bne IVid_CopyTextChars
                ldx #39
IVid_InitScorePanel:
                lda scorePanel,x
                sta screen1+SCROLLROWS*40,x
                lda scorePanelColors,x
                sta colors+SCROLLROWS*40,x
                lda scorePanel+40,x
                sta screen1+SCROLLROWS*40+40,x
                lda scorePanelColors+40,x
                sta colors+SCROLLROWS*40+40,x
                lda scorePanel+80,x
                sta screen1+SCROLLROWS*40+80,x
                lda scorePanelColors+80,x
                sta colors+SCROLLROWS*40+80,x
                dex
                bpl IVid_InitScorePanel

                lda #HP_PLAYER                  ;Init health & fists item immediately
                sta actHp+ACTI_PLAYER           ;even before starting the game so that
                lda #ITEM_FISTS                 ;the panel looks nice
                sta invType

        ; Initialize raster IRQs
        ; Relies on loader init to have already disabled the timer interrupt

InitRaster:     sei
                lda #$35
                sta irqSave01
                sta $01
                lda #<RedirectIrq               ;Setup the IRQ redirector for Kernal off mode
                sta $0314
                lda #>RedirectIrq
                sta $0315
                lda #<Irq1                      ;Set initial IRQ vector
                sta $fffe
                lda #>Irq1
                sta $ffff
                lda $d011
                and #$7f                        ;High bit of interrupt position = 0
                sta $d011
                lda #IRQ1_LINE                  ;Line where next IRQ happens
                sta $d012
                lda fastLoadMode                ;If not using fastloader, disable MinSprY/MaxSprY writing
                beq IR_UseFastLoad
                lda #$2c
                sta Irq1_StoreMinSprY
                sta Irq1_StoreMaxSprY
IR_UseFastLoad:
IR_DetectNtsc1: lda $d012                       ;Detect PAL/NTSC again
IR_DetectNtsc2: cmp $d012
                beq IR_DetectNtsc2
                bmi IR_DetectNtsc1
                cmp #$20
                bcc IR_IsNtsc
                lda #$ff
                sta UF_ColorShiftLateCheck+1
IR_IsNtsc:      cli

        ; Initializations are complete. Start the main program

                lda #<EP_TITLE                  ;Load and execute the title screen
                ldx #>EP_TITLE
                ldy #$00
                jmp ExecScriptParam

        ; Subroutine for REU detection: perform transfer either to REU (X = $90) or to C64
        ; (X = $91)

DR_Transfer:    lda #$00
                sta $df0a
                lda #<screen2
                sta $df02
                lda #>screen2
                sta $df03
                lda #$00
                sta $df04
                sta $df05
                sta $df06
                lda #<$100
                sta $df07
                lda #>$100
                sta $df08
                stx $df01                       ;Execute transfer
                rts

        ; Enable REU scrolling by modifying code

InstallREUScroller:
                lda #<REUScrollerPatches
                sta temp1
                lda #>REUScrollerPatches
                sta temp2
IRS_PatchLoop:  ldy #$00
                lda (temp1),y                   ;Get destination
                sta zpDestLo
                iny
                lda (temp1),y
                beq IRS_Done
                sta zpDestHi
                iny
                lda (temp1),y                   ;Get size of patch
                sta zpBitsLo
                iny
                lda (temp1),y
                sta zpBitsHi
                lda #$04
                ldx #temp1
                jsr Add8
                lda temp1                       ;Get source address
                sta zpSrcLo
                lda temp2
                sta zpSrcHi
                ldy #zpBitsLo
                jsr Add16
                jsr CopyMemory_PointersSet
                jmp IRS_PatchLoop
IRS_Done:       rts

REUScrollerPatches:
                dc.w SL_XDone
                dc.w 1
                dc.b $2c

                dc.w SL_YDone
                dc.w REU_SL_YDone_End-REU_SL_YDone
REU_SL_YDone:   
                rorg SL_YDone
                clc
                bcc SL_DetermineSpeed
                rend
REU_SL_YDone_End:

                dc.w UF_CheckNoColorScroll
                dc.w REU_UF_CheckNoColorScroll_End-REU_UF_CheckNoColorScroll
REU_UF_CheckNoColorScroll:
                rorg UF_CheckNoColorScroll
                jmp UF_CheckNoColorScrollDone
                rend
REU_UF_CheckNoColorScroll_End:

                dc.w UF_WaitColorShiftCheck+1
                dc.w 1
                dc.b IRQ3_LINE-$28

                dc.w ScrollWork
                dc.w REU_ScrollWork_End-REU_ScrollWork
REU_ScrollWork:
                rorg ScrollWork
                lda scrCounter
                cmp #$04
                beq DrawScreenREU
                rts
DrawScreenREU:  ldy screen
                lda #$00
                sta $df0a
                sta $df02
                sta $df06
                sta $df08
                sta DSR_AddHi+1
                lda screenBaseTbl,y
                sta $df03
                lda mapY
                sec
                sbc limitU
                ldy mapSizeX
                ldx #temp1
                jsr MulU
                lda temp1               ;Calculate start of window
                asl                     ;from Y-map position
                rol temp2
                asl
                rol temp2
                asl
                rol temp2
                asl
                rol temp2
                sta temp1
                lda blockY              ;Add Y-position within block
                ldy mapSizeX
                ldx #temp3
                jsr MulU
                lda mapX
                sec
                sbc limitL
                jsr Add8                ;Add X-map position
                lda temp3
                asl
                rol temp4
                asl
                rol temp4
                sta temp3
                lda blockX              ;Add X-position within block
                jsr Add8
                ldx #temp1
                ldy #temp3
                jsr Add16               ;REU window position ready in temp1,temp2
                lda mapSizeX
                asl
                rol DSR_AddHi+1
                asl
                rol DSR_AddHi+1
                sta DSR_AddLo+1
                jsr DrawScreenREUSub    ;Fill the screen from first 64KB bank
                lda #<colors            ;Then the colors from second 64KB bank
                sta $df02
                lda #>colors
                sta $df03
                lda #$01
                sta $df06
DrawScreenREUSub:
                lda temp1
                sta temp3
                ldy temp2
                ldx #SCROLLROWS
                clc
DSR_Loop:       lda temp3
                sta $df04
DSR_AddLo:      adc #$00
                sta temp3
                tya
                sta $df05
DSR_AddHi:      adc #$00
                tay
                lda #40                 ;Transfer a full row so that we don't have to touch
                sta $df07               ;the C64 side address
                lda #$91
                sta $df01               ;Execute transfer REU -> C64
                dex
                bne DSR_Loop
                rts
DrawMapREU:     lda #$00                        ;Current blockrow
                sta temp2
                sta temp4                       ;Temp4,5=REU dest.pointer
                sta temp5
                sta temp7
                sta $df0a
                lda mapSizeX
                asl
                rol temp7
                asl
                rol temp7
                sta temp6                       ;Temp6,7 = length of row in bytes
                ldy limitU                      ;Current maprow
DMR_MapRowLoop: sty temp1
                lda mapTblLo,y
                sta DMR_MapLda+1
                lda mapTblHi,y
                sta DMR_MapLda+2
DMR_RowLoop:    lda #$00                        ;Screen & colorscreen destination pointers
                sta zpDestLo
                sta zpBitsLo
                lda #>screen2
                sta zpDestHi
                lda #>colors
                sta zpBitsHi
                ldy limitL
                clc
DMR_Loop:       sty temp3
DMR_MapLda:     lda $1000,y                     ;Take block from map
                tay
                lda blkTblLo,y
                adc temp2
                sta zpSrcLo
                lda blkTblHi,y
                adc #$00
                sta zpSrcHi
                ldy #$00
                lda (zpSrcLo),y                 ;Copy chars & colors for one block's row
                sta (zpDestLo),y
                tax
                lda charColors,x
                sta (zpBitsLo),y
                iny
                lda (zpSrcLo),y
                sta (zpDestLo),y
                tax
                lda charColors,x
                sta (zpBitsLo),y
                iny
                lda (zpSrcLo),y
                sta (zpDestLo),y
                tax
                lda charColors,x
                sta (zpBitsLo),y
                iny
                lda (zpSrcLo),y
                sta (zpDestLo),y
                tax
                lda charColors,x
                sta (zpBitsLo),y
                lda zpDestLo
                adc #$04
                sta zpDestLo
                sta zpBitsLo
                bcc DMR_NotOver
                inc zpDestHi
                inc zpBitsHi
DMR_NotOver:    ldy temp3
                iny
                cpy limitR                      ;Maprow done?
                bcc DMR_Loop
                lda #<screen2
                sta $df02
                lda #>screen2
                sta $df03
                lda #$00
                sta $df06                       ;Screen data to first bank
                jsr DMR_DoTransfer
                lda #<colors
                sta $df02
                lda #>colors
                sta $df03
                lda #$01
                sta $df06                       ;Color data to second bank
                jsr DMR_DoTransfer
                lda temp4                       ;Increment REU address for next row
                clc
                adc temp6
                sta temp4
                lda temp5
                adc temp7
                sta temp5
                lda temp2                       ;Move to next blockrow
                adc #$04
                cmp #$10
                bcs DMR_MapRowDone
                sta temp2
                jmp DMR_RowLoop
DMR_MapRowDone: lda #$00                        ;Move to next maprow
                sta temp2
                ldy temp1
                iny
                cpy limitD
                bcs DMR_AllDone
                jmp DMR_MapRowLoop
DMR_DoTransfer: lda temp4
                sta $df04
                lda temp5
                sta $df05
                lda temp6
                sta $df07
                lda temp7
                sta $df08
                lda #$90
                sta $df01                       ;Execute transfer C64 -> REU
DMR_AllDone:    rts
                rend
REU_ScrollWork_End:

                dc.w RedrawScreen
                dc.w REU_RedrawScreen_End-REU_RedrawScreen
REU_RedrawScreen:
                rorg RedrawScreen
                jsr DrawMapREU
                ldy #$00
                sty screen
                lda #$01
                sta Irq1_LevelUpdate+1          ;Can animate level
                jsr DrawScreenREU
                jmp InitScroll
                rend
REU_RedrawScreen_End:

                dc.w 0                          ;Endmark

        ; Scorepanel chars

textCharsCopy:  incbin bg/scorescr.chr

        ; Scorepanel borders

scorePanel:     dc.b 0,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,1,1,1,1,1,4
                dc.b 5,"      ",6, "                        ",5,35,36,"    ",6
                dc.b 7,8,8,8,8,8,9,10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,11,8,8,8,8,8,9,12

scorePanelColors:
                ds.b 40,11
                dc.b 11
                ds.b 6,13
                dc.b 11
                ds.b 24,1
                dc.b 11
                ds.b 2,8
                ds.b 4,1
                dc.b 11
                ds.b 40,11

scriptCodeEnd   = scriptCodeStart+SCRIPTAREASIZE
