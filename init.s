scriptCodeStart:
scriptCodeEnd   = scriptCodeStart+SCRIPTAREASIZE

        ; Initialize registers/variables at startup. This code is called only once and can be
        ; disposed after that.
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

InitAll:        ldx #STACKSTART
                txs
                lda palFlag
                bne IsPAL
                lda #30                         ;Compensate game clock speed for NTSC
                sta timeMaxTbl+3                ;(otherwise no compensation)
IsPAL:          lda $d030                       ;Enable extra IRQ for turbo switching for C128 & SCPU
                cmp #$ff                        ;(or rather, disable it on plain C64)
                bne UseTurbo
                lda $d0bc
                bpl UseTurbo
NoTurbo:        lda #$4c
                sta Irq4_Irq6Jump
                lda #<Irq6_LevelUpdate
                sta Irq4_Irq6Jump+1
                lda #>Irq6_LevelUpdate
                sta Irq4_Irq6Jump+2
UseTurbo:

        ; Initialize zeropage variables

Is128:          ldx #$90-joystick-1
                lda #$00
InitZP:         sta joystick,x
                dex
                bpl InitZP

        ; Initialize playroutine / raster IRQ variables

                sta ntFiltPos
                sta ntFiltTime
                lda #$7f
                sta ntInitSong

                lda #<fileAreaStart
                sta freeMemLo
                lda #>fileAreaStart
                sta freeMemHi

        ; Load options file

                lda #F_OPTIONS                  ;This is the last file and will cache all
                jsr MakeFileName_Direct         ;directory entries
                jsr OpenFile
                ldy #$00
LoadOptions:    jsr GetByte
                bcs LoadOptionsDone
                sta difficulty,y
                iny
                bcc LoadOptions
LoadOptionsDone:

        ; Initialize scrolling

                jsr InitScroll

        ; Initialize panel text printing

                lda #9
                sta textLeftMargin
                lda #REDRAW_ITEM+REDRAW_AMMO+REDRAW_SCORE
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
                ldx #MAX_CHUNKFILES-1           ;fileNumObjects & fileAge may be stored in unused parts
                lda #$00                        ;of screen1 & screen2, so reset here
ISpr_ResetChunkFiles:
                sta fileNumObjects,x
                sta fileAge,x
                dex
                bpl ISpr_ResetChunkFiles

        ; Load resident sprites

                ldy #C_COMMON
                jsr LoadSpriteFile
                ldy #C_ITEM
                jsr LoadSpriteFile
                ldy #C_WEAPON
                jsr LoadSpriteFile

        ; Fade out loading music now

                lda fastLoadMode
                beq InitVideo
FadeMusicLoop:  ldy #$08
FadeMusicDelay: jsr WaitBottom
                dey
                bne FadeMusicDelay
                lda musicData+$8c
                beq InitVideo
                dec musicData+$8c
                bpl FadeMusicLoop

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
                jsr WaitBottom                  ;(some C64's need to "warm up" sprites
                ldx #$00                        ;to avoid one frame flash when they're
                stx $d015                       ;actually used for the first time)
                stx $d026                       ;Set sprite multicolors
                lda #$0a
                sta $d025
IVid_CopyTextChars:
                lda textCharsCopy,x
                sta textChars+$100,x
                lda textCharsCopy+$100,x
                sta textChars+$200,x
                lda textCharsCopy+$200,x
                sta textChars+$300,x
                inx
                bne IVid_CopyTextChars
                ldx #7
                lda #EMPTYSPRITEFRAME
IVid_SetEmptySpriteFrame:
                sta panelScreen+1016,x
                dex
                bpl IVid_SetEmptySpriteFrame
                ldx #39
IVid_InitScorePanel:
                lda #$20
                sta panelScreen+PANELROW*40-40,x
                lda scorePanel,x
                sta panelScreen+PANELROW*40,x
                lda scorePanelColors,x
                sta colors+PANELROW*40,x
                lda scorePanel+40,x
                sta panelScreen+PANELROW*40+40,x
                lda scorePanelColors+40,x
                sta colors+PANELROW*40+40,x
                dex
                bpl IVid_InitScorePanel
                lda #HP_PLAYER                  ;Init health & fists item immediately
                sta actHp+ACTI_PLAYER           ;even before starting the game so that
                lda #MAX_BATTERY                ;the panel looks nice
                sta battery+1
                lda #MAX_OXYGEN
                sta oxygen
                lda #ITEM_FISTS
                sta itemIndex

        ; Initialize raster IRQs
        ; Relies on loader init to have already disabled the timer interrupt

InitRaster:     sei
                ldx #$ff
                txs
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
                lda fastLoadMode                ;If not using serial fastloading, disable MinSprY/MaxSprY writing
                bmi IR_UseFastLoad
                lda #$2c
                sta Irq1_StoreMinSprY
                sta Irq1_StoreMaxSprY
IR_UseFastLoad: cli

        ; Initializations are complete. Start the main program

                lda #<EP_TITLE                  ;Load and execute the title screen
                ldx #>EP_TITLE
                ldy #$00
                jmp ExecScriptParam

        ; Scorepanel chars (overwritten)

textCharsCopy:  incbin bg/scorescr.chr

        ; Scorepanel screen/color data (overwritten)

scorePanel:     dc.b 35,"       ",35,"                      ",35,"       ",35
                dc.b 36
                ds.b 7,61
                dc.b 120
                ds.b 22,61
                dc.b 120
                ds.b 7,61
                dc.b 121

scorePanelColors:
                dc.b 11
                ds.b 7,1
                dc.b 11
                ds.b 22,1
                dc.b 11
                ds.b 7,1
                dc.b 11
                ds.b 40,11

                org scriptCodeEnd