        ; Initialize registers/variables at startup. This code is called only once and can be
        ; disposed after that.
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

InitAll:        lda ntscDelay                   ;Check if loader part detected PAL or NTSC
                beq IsNTSC
                lda #$a5                        ;In PAL mode, disable NTSC delay counting
                sta Irq4_NtscDelay              ;(replace DEC with LDA)
IsNTSC:         lda #<fileAreaStart             ;Initialize dynamic memory allocator
                sta freeMemLo
                lda #>fileAreaStart
                sta freeMemHi
                jsr InitScroll

        ; Initialize controls variables

InitControls:   lda #$00
                sta joystick                    ;Control reset
                sta prevJoy
                sta keyPress
                sta keyType

        ; Initialize one-time playroutine variables

                sta $d415                       ;Filter lowbyte
                sta ntFiltPos
                sta ntFiltTime
        
        ; Initialize panel text printing

                sta textLo
                sta textHi
                sta textLeftMargin
                lda #PANEL_TEXT_SIZE
                sta textRightMargin

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
                lda #$00                        ;Sprites off now
                sta $d015
                lda #SPR_MC1
                sta $d025                       ;Set sprite multicolor 1
                lda #SPR_MC2
                sta $d026                       ;Set sprite multicolor 2
                ldx #$00
IVid_ClearColors:
                sta screen1,x
                sta screen1+$100,x
                sta screen1+$200,x
                sta screen1+$300,x
                sta colors,x
                sta colors+$100,x
                sta colors+$200,x
                sta colors+$300,x
                inx
                bne IVid_ClearColors
                ldx #$07
                lda #$ff
IVid_ClearFirstChar:
                sta chars,x
                dex
                bpl IVid_ClearFirstChar
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
                lda #$34                        ;Need access to RAM under I/O to clear the
                sta $01                         ;empty sprite
                ldx #$3f
                lda #$00
ISpr_ClearEmptySprite:
                sta emptySprite,x
                dex
                bpl ISpr_ClearEmptySprite
                ldx #MAX_CACHESPRITES-1
ISpr_ClearCacheInUse:
                lda #$00
                sta cacheSprInUse,x
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
                lda #$01                        ;Raster interrupt on
                sta $d01a
                cli

        ; Initializations are complete. Start the main program

                jmp Main

        ; Scorepanel chars

textCharsCopy:  incbin bg/scorescr.chr

        ; Initial scorepanel mockup

scorePanel:     dc.b 0,1,1,1,1,1,1,1,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,1,1,1,1,1,1,4
                dc.b 5,"       ",6, "                      ",5,17,18,"07/04",6
                dc.b 7,8,8,8,8,8,8,9,10,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,8,11,8,8,8,8,8,8,9,12

scorePanelColors:
                ds.b 40,11
                dc.b 11
                ds.b 7,13
                dc.b 11
                ds.b 22,1
                ds.b 3,11
                ds.b 5,1
                dc.b 11
                ds.b 40,11