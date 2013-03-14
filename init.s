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
                if DISABLE_MUSIC>0
                lda #$00
                sta musicMode
                lda #$01
                sta soundMode
                else
                lda #$01                        ;Music and sound FX on by default
                sta musicMode
                sta soundMode
                endif
                sta difficulty                  ;Default to Hard difficulty

                lda #<fileAreaStart
                sta freeMemLo
                lda #>fileAreaStart
                sta freeMemHi

                jsr InitScroll

        ; Initialize panel text printing

                lda #8
                sta textLeftMargin
                lda #32
                sta textRightMargin
                lda #REDRAW_ITEM+REDRAW_AMMO
                sta panelUpdateFlags

        ; Initialize video registers and screen memory

InitVideo:      lda $dd00                       ;Set game videobank
                and #$fc
                sta $dd00
                lda #$00
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
                lda FastLoadMode+1              ;If not using fastloader, disable MinSprY/MaxSprY writing
                beq IR_UseFastLoad
                lda #$ea
                ldx #$02
IR_DisableMinMaxSprY:
                sta Irq1_StoreMinSprY,x
                sta Irq1_StoreMaxSprY,x
                dex
                bpl IR_DisableMinMaxSprY
IR_UseFastLoad: cli

        ; Initializations are complete. Start the main program

                lda #<EP_TITLE                  ;Load and execute the title screen
                ldy #>EP_TITLE
                ldx #$00
                jmp ExecScript

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