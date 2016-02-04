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
                lda #60                         ;Compensate game clock speed for NTSC
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
                lda #$0f
                sta ntMasterVol

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

        ; Initialize panel text printing

                lda #9
                sta textLeftMargin
                lda #REDRAW_ITEM+REDRAW_AMMO+REDRAW_SCORE
                sta panelUpdateFlags

        ;Initialize the sprite multiplexing system

InitSprites:    ldx #MAX_SPR
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
                sta sprFileNum

        ; Setup memory allocation and preloaded sprites

                lda #<fileAreaStart
                sta freeMemLo
                lda #>fileAreaStart
                sta freeMemHi
                ldx #2
ISpr_Preloaded: lda preloadedLo,x
                sta fileLo+C_COMMON,x
                sta zpDestLo
                sta zpBitsLo
                lda preloadedHi,x
                sta zpDestHi
                sta zpBitsHi
                sta fileHi+C_COMMON,x
                lda preloadedNumObjects,x
                sta fileNumObjects+C_COMMON,x
                txa
                clc
                adc #C_COMMON
                tay
                stx temp1
                jsr LF_Relocate3
                ldx temp1
                dex
                bpl ISpr_Preloaded

        ; Fade out loading music now

                lda fastLoadMode
                beq InitVideo
FadeMusicLoop:  lda musicData+$8c
                beq InitVideo
                dec musicData+$8c
                ldx #$06
FadeMusicDelay: jsr WaitBottom
                dex
                bne FadeMusicDelay
                bpl FadeMusicLoop

        ; Initialize video registers and screen memory

InitVideo:      jsr WaitBottom
                jsr InitScroll
                sta newFrame
                sta firstSortSpr
                sta screen
                sta $d011
                sta $d01b                       ;Sprites on top of BG
                sta $d01d                       ;Sprite X-expand off
                sta $d017                       ;Sprite Y-expand off
                sta $d026                       ;Set sprite multicolors
                lda #$0a
                sta $d025
                lda #$ff                        ;Set all sprites multicolor
                sta $d01c
                ldx #$10
IVid_SpriteY:   dex
                dex
                sta $d001,x                     ;Set all sprites on & to the bottom
                bne IVid_SpriteY
                sta $d015                       ;All sprites on and to the bottom
                jsr WaitBottom                  ;(some C64's need to "warm up" sprites
                                                ;to avoid one frame flash when they're
                stx $d015                       ;actually used for the first time)
IVid_CopyTextChars:
                lda textCharsCopy,x
                sta textChars+$100,x
                lda textCharsCopy+$100,x
                sta textChars+$200,x
                lda textCharsCopy+$200,x
                sta textChars+$300,x
                inx
                bne IVid_CopyTextChars
                ldx #79
IVid_InitScorePanel:
                lda scorePanelColors,x
                sta colors+PANELROW*40,x
                dex
                bpl IVid_InitScorePanel
                lda #ITEM_FISTS                 ;Show fists even before game start
                sta itemIndex

        ; Initialize raster IRQs
        ; Relies on loader init to have already disabled the timer interrupt

InitRaster:     sei
                ldy #$35
                sty irqSave01
                dey
                sty $01
                lda #$00
                ldx #$3f
IR_EmptySprite: sta emptySprite,x               ;Clear the data of the empty sprite
                dex
                bpl IR_EmptySprite
                inc $01
                sta $d01a                       ;IRQs disabled until screen is ready to be shown
                lda #<Irq1                      ;Set initial IRQ vector
                sta $fffe
                lda #>Irq1
                sta $ffff
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

        ; Scorepanel color data (overwritten)

scorePanelColors:
                dc.b 11
                ds.b 7,1
                dc.b 11
                ds.b 22,1
                dc.b 11
                ds.b 7,1
                dc.b 11
                ds.b 9,11
                dc.b 8
                ds.b 7,15
                dc.b 11
                ds.b 4,1
                dc.b 11
                dc.b 8
                ds.b 7,15
                ds.b 9,11

        ; Scorepanel chars & scorepanel screen data (overwritten)

textCharsCopy:  incbin bg/scorescr.chr
                ds.b 40,32
                dc.b 103
                ds.b 7,32
                dc.b 103
                ds.b 22,32
                dc.b 103
                ds.b 7,32
                dc.b 103
                dc.b 96
                ds.b 7,97
                dc.b 98
                dc.b 120
                ds.b 7,122
                dc.b 99
                ds.b 4,32
                dc.b 100
                dc.b 121
                ds.b 7,122
                dc.b 101
                ds.b 7,97
                dc.b 102
                incbin bg/healthbar.chr
                ds.b 8,EMPTYSPRITEFRAME

        ; Preloaded spritefile data

preloadedLo:    dc.b <sprCommon, <sprItem, <sprWeapon
preloadedHi:    dc.b >sprCommon, >sprItem, >sprWeapon
preloadedNumObjects:
                incbin sprcommon.hdr
                incbin spritem.hdr
                incbin sprweapon.hdr

                org scriptCodeEnd