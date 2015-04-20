scriptCodeStart:
scriptCodeEnd   = scriptCodeStart+SCRIPTAREASIZE
fileAreaStart   = scriptCodeEnd

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
                lda #$00                        ;Blank screen
                sta $d011
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

        ; Fade out loading music now

                lda fastLoadMode
                cmp #$01
                beq InitRaster
FadeMusicLoop:  ldy #$08
FadeMusicDelay: jsr WaitBottom
                dey
                bne FadeMusicDelay
                lda musicData+$8c
                beq InitRaster
                dec musicData+$8c
                bpl FadeMusicLoop

        ; Initialize raster IRQs
        ; Relies on loader init to have already disabled the timer interrupt

InitRaster:     sei
                lda #$35
                sta irqSave01
                sta $01
                lda #<Irq1                      ;Set initial IRQ vector
                sta $fffe
                lda #>Irq1
                sta $ffff
                lda #$00                        ;IRQs disabled until the screen is ready to be drawn
                sta $d01a
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
IR_IsNtsc:      lda $d030                       ;Detect C128/SCPU and disable Irq6 if neither detected
                cmp #$ff                        ;to not waste CPU cycles
                bne IR_IsC128
                lda $d0bc
                bpl IR_IsSuperCPU
                lda #<Irq1
                sta Irq4_End+1
                lda #>Irq1
                sta Irq4_End+3
                lda #IRQ1_LINE
                sta Irq4_End+5
IR_IsSuperCPU:
IR_IsC128:      cli

        ; Initializations are complete. Start the main program

                lda #<EP_TITLE                  ;Load and execute the title screen
                ldx #>EP_TITLE
                ldy #$00
                jmp ExecScriptParam

        ; Scorepanel chars (overwritten)

textCharsCopy:  incbin bg/scorescr.chr

        ; Scorepanel screen/color data (overwritten)

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