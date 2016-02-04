MAX_SPRX        = 335
MIN_SPRY        = 34
MAX_SPRY        = IRQ3_LINE-1

FIRSTCACHEFRAME = (spriteCache-$c000)/$40
EMPTYSPRITEFRAME = (emptySprite-$c000)/$40

SPRH_MASK       = 0
SPRH_COLOR      = 1
SPRH_HOTSPOTX   = 2
SPRH_HOTSPOTXFLIP = 3
SPRH_CONNECTSPOTX = 4
SPRH_CONNECTSPOTXFLIP = 5
SPRH_HOTSPOTY   = 6
SPRH_CONNECTSPOTY = 7
SPRH_CACHEFRAME = 8
SPRH_CACHEFRAMEFLIP = 9
SPRH_DATA       = 10

        ; Load a sprite file
        ;
        ; Parameters: Y sprite file number
        ; Returns: A sprite file address highbyte
        ; Modifies: A,temp6-temp8,loader temp vars

EnsureSpriteFile:
                lda fileHi,y
                bne ESF_Loaded
LoadSpriteFile: stx LSF_SaveX+1
                tya
                sec
                sbc #C_FIRSTSPR
                ldx #F_SPRITE
                jsr MakeFileName
LSF_Retry:      jsr LoadAllocFile
                bcc LSF_NoError
                jsr LFR_ErrorPrompt
                ldy temp6
                bpl LSF_Retry
LSF_NoError:    jsr PostLoad
                ldy temp6                       ;LoadAllocFile puts chunk number to temp6
                lda fileHi,y
LSF_SaveX:      ldx #$00
ESF_Loaded:     rts

        ; Get and store a sprite. Cache (depack) if not cached yet.
        ;
        ; Parameters: A frame number, X sprite index, temp1 X coord,
        ;             temp3 Y coord, actIndex actor index, sprFileLo-Hi spritefile
        ; Returns: X incremented if sprite accepted, temp1-temp4 modified for next sprite
        ; Modifies: A,X,Y,temp1-temp4

GetAndStoreSprite:
                sta zpBitsLo                    ;Framenumber with direction in high bit
                asl
                tay
                lda (sprFileLo),y               ;Get sprite header address
                sta frameLo
                iny
                lda (sprFileLo),y
                sta frameHi
                lda #$80
                rol                             ;C=1 for the subtraction below
                sta zpLenLo                     ;Sprite direction
                ora #SPRH_HOTSPOTX
                tay
                lda temp1                       ;Subtract X-hotspot
                sbc (frameLo),y
                sta temp2
                iny
                iny
                clc
                adc (frameLo),y                 ;Add X-connect spot
                sta temp1
                ldy #SPRH_HOTSPOTY
                lda temp3                       ;Subtract Y-hotspot
                sec
                sbc (frameLo),y
                sta temp4
                iny
                clc
                adc (frameLo),y                 ;Add Y-connect spot
                sta temp3
                cpx #MAX_SPR                    ;Ran out of sprites?
                bcs GASS_DoNotAccept
                ldy #$00                        ;Finalize Y-pos
                lda temp4
                bpl GASS_YLo
                dey
GASS_YLo:       adc #$00
                sta sprY,x
                tya
GASS_YHi:       adc #$00
                bne GASS_DoNotAccept            ;Y high byte must be zero (visible)
                lda sprY,x                      ;Check Y visibility
                cmp #MIN_SPRY
                bcc GASS_DoNotAccept
                cmp #MAX_SPRY
                bcs GASS_DoNotAccept
                ldy #$00
                lda temp2                       ;Finalize X-pos
                bpl GASS_XLo
                dey
GASS_XLo:       adc #$00                        ;C=0 here
                sta sprXL,x
                tya
GASS_XHi:       adc #$00
                sta sprXH,x
                beq GASS_XOK
                lda sprXL,x                     ;Check X visibility
                cmp #MAX_SPRX-256
                bcs GASS_DoNotAccept
GASS_XOK:       lda actIndex                    ;Sprite was accepted: store actor index
                sta sprAct,x                    ;for interpolation
                ldy #SPRH_COLOR
                lda (frameLo),y
GASS_ColorAnd:  and #$00
GASS_ColorOr:   ora #$00
                sta sprC,x                      ;Store color
                lda #SPRH_CACHEFRAME
                ora zpLenLo
                tay
                lda (frameLo),y                 ;Check if already cached
                beq GASS_CacheSprite
GASS_StoreFrame:sta sprF,x
                tay
                lda GASS_CurrentFrame+1         ;Mark cached sprite in use
                sta cacheSprAge-FIRSTCACHEFRAME,y
                inx                             ;Finally increment sprite count
GASS_DoNotAccept:
                rts

        ; Cache (depack) a sprite

GASS_CacheSprite:
                if SHOW_SPRITEDEPACK_TIME > 0
                inc $d020
                endif
                stx zpBitsHi
GASS_CachePos:  ldx #$7f                        ;Continue from where we left off last time
GASS_Loop:      inx
                bpl GASS_NotOver
                ldx #FIRSTCACHEFRAME+1          ;First frame is used for the empty sprite
GASS_NotOver:   lda cacheSprAge-FIRSTCACHEFRAME,x
GASS_CurrentFrame:
                cmp #$01
                beq GASS_Loop
GASS_LastFrame: cmp #$01
                beq GASS_Loop
GASS_Found:     stx GASS_CachePos+1             ;Store cache position for next search
                txa
                sta (frameLo),y                 ;Store cache frame into sprite header
                ldy cacheSprFile-FIRSTCACHEFRAME,x ;Clear the old cache mapping if the old file still in memory
                bmi GASS_NoOldSprite
                lda fileHi,y
                beq GASS_NoOldSprite
                sta zpSrcHi
                lda fileLo,y
                sta zpSrcLo
                lda cacheSprFrame-FIRSTCACHEFRAME,x
                asl
                tay
                lda (zpSrcLo),y
                sta zpDestLo
                iny
                lda (zpSrcLo),y
                sta zpDestHi
                lda #SPRH_CACHEFRAME/2
                rol
                tay
                lda #$00
                sta (zpDestLo),y
GASS_NoOldSprite:
                lda sprFileNum                  ;Save new file & frame numbers so that this mapping
                sta cacheSprFile-FIRSTCACHEFRAME,x ;can be cleared in the future
                tay
                lda #$00
                sta fileAge,y                   ;Reset file age, only done when depacking a new sprite
                lda zpBitsLo
                sta cacheSprFrame-FIRSTCACHEFRAME,x
                lda #$34                        ;Need access to RAM under the I/O area
                sta irqSave01
                sta $01
                lda zpLenLo                     ;Use normal or flipped routine?
                bne GASS_Flipped
                jmp GASS_NonFlipped

GASS_Flipped:   lda #$08
                sta zpBitBuf
                txa                             ;Calculate sprite address
                lsr
                ror zpBitBuf
                lsr
                ror zpBitBuf
                ora #>videoBank
                cmp GASS_FlipFullSlice1+2           ;Modify STA-instructions as necessary
                beq GASS_FlipAddressOk
                sta GASS_FlipFullSlice1+2
                sta GASS_FlipFullSlice2+2
                sta GASS_FlipFullSlice3+2
                sta GASS_FlipFullSlice4+2
                sta GASS_FlipFullSlice5+2
                sta GASS_FlipFullSlice6+2
                sta GASS_FlipFullSlice7+2
                sta GASS_FlipEmptySlice1+2
                sta GASS_FlipEmptySlice2+2
                sta GASS_FlipEmptySlice3+2
                sta GASS_FlipEmptySlice4+2
                sta GASS_FlipEmptySlice5+2
                sta GASS_FlipEmptySlice6+2
                sta GASS_FlipEmptySlice7+2
GASS_FlipAddressOk:
                ldy #SPRH_COLOR
                lda (frameLo),y                 ;Get slice bitmask high bit
                asl
                dey
                lda (frameLo),y                 ;Get rest of the bits
                ror
                sta zpBitsLo                    ;C=1 if first slice has data
                ldx zpBitBuf
                ldy #SPRH_DATA
                bcc GASS_FlipEmptySlice
GASS_FlipFullSlice:
                lda (frameLo),y
                sta GASS_GetFlipped1+1
GASS_GetFlipped1:
                lda flipTbl
GASS_FlipFullSlice1:sta $1000,x
                iny
                lda (frameLo),y
                sta GASS_GetFlipped2+1
GASS_GetFlipped2:
                lda flipTbl
GASS_FlipFullSlice2:sta $1000+3,x
                iny
                lda (frameLo),y
                sta GASS_GetFlipped3+1
GASS_GetFlipped3:
                lda flipTbl
GASS_FlipFullSlice3:sta $1000+6,x
                iny
                lda (frameLo),y
                sta GASS_GetFlipped4+1
GASS_GetFlipped4:
                lda flipTbl
GASS_FlipFullSlice4:sta $1000+9,x
                iny
                lda (frameLo),y
                sta GASS_GetFlipped5+1
GASS_GetFlipped5:
                lda flipTbl
GASS_FlipFullSlice5:sta $1000+12,x
                iny
                lda (frameLo),y
                sta GASS_GetFlipped6+1
GASS_GetFlipped6:
                lda flipTbl
GASS_FlipFullSlice6:sta $1000+15,x
                iny
                lda (frameLo),y
                sta GASS_GetFlipped7+1
GASS_GetFlipped7:
                lda flipTbl
GASS_FlipFullSlice7:sta $1000+18,x
                iny
GASS_FlipNextSlice:
                lda flipNextSliceTbl,x
                beq GASS_DepackDone
                tax
                dex
                lsr zpBitsLo
                bcs GASS_FlipFullSlice
GASS_FlipEmptySlice:lda #$00
GASS_FlipEmptySlice1:sta $1000,x
GASS_FlipEmptySlice2:sta $1000+3,x
GASS_FlipEmptySlice3:sta $1000+6,x
GASS_FlipEmptySlice4:sta $1000+9,x
GASS_FlipEmptySlice5:sta $1000+12,x
GASS_FlipEmptySlice6:sta $1000+15,x
GASS_FlipEmptySlice7:sta $1000+18,x
                beq GASS_FlipNextSlice

GASS_DepackDone:lda #$35                        ;Restore I/O registers
                sta irqSave01
                sta $01
                ldx zpBitsHi
                lda GASS_CachePos+1
                if SHOW_SPRITEDEPACK_TIME > 0
                dec $d020
                endif
                jmp GASS_StoreFrame
GASS_DepackDone2:
                beq GASS_DepackDone

GASS_NonFlipped:sta zpBitBuf
                txa                             ;Calculate sprite address
                lsr
                ror zpBitBuf
                lsr
                ror zpBitBuf
                ora #>videoBank
                cmp GASS_FullSlice1+2           ;Modify STA-instructions as necessary
                beq GASS_AddressOk
                sta GASS_FullSlice1+2
                sta GASS_FullSlice2+2
                sta GASS_FullSlice3+2
                sta GASS_FullSlice4+2
                sta GASS_FullSlice5+2
                sta GASS_FullSlice6+2
                sta GASS_FullSlice7+2
                sta GASS_EmptySlice1+2
                sta GASS_EmptySlice2+2
                sta GASS_EmptySlice3+2
                sta GASS_EmptySlice4+2
                sta GASS_EmptySlice5+2
                sta GASS_EmptySlice6+2
                sta GASS_EmptySlice7+2
GASS_AddressOk: ldy #SPRH_COLOR
                lda (frameLo),y                 ;Get slice bitmask high bit
                asl
                dey
                lda (frameLo),y                 ;Get rest of the bits
                ror
                sta zpBitsLo                    ;C=1 if first slice has data
                ldx zpBitBuf
                ldy #SPRH_DATA
                bcc GASS_EmptySlice
GASS_FullSlice: lda (frameLo),y
GASS_FullSlice1:sta $1000,x
                iny
                lda (frameLo),y
GASS_FullSlice2:sta $1000+3,x
                iny
                lda (frameLo),y
GASS_FullSlice3:sta $1000+6,x
                iny
                lda (frameLo),y
GASS_FullSlice4:sta $1000+9,x
                iny
                lda (frameLo),y
GASS_FullSlice5:sta $1000+12,x
                iny
                lda (frameLo),y
GASS_FullSlice6:sta $1000+15,x
                iny
                lda (frameLo),y
GASS_FullSlice7:sta $1000+18,x
                iny
GASS_NextSlice: lda nextSliceTbl,x
                beq GASS_DepackDone2
                tax
                lsr zpBitsLo
                bcs GASS_FullSlice
GASS_EmptySlice:lda #$00
GASS_EmptySlice1:sta $1000,x
GASS_EmptySlice2:sta $1000+3,x
GASS_EmptySlice3:sta $1000+6,x
GASS_EmptySlice4:sta $1000+9,x
GASS_EmptySlice5:sta $1000+12,x
GASS_EmptySlice6:sta $1000+15,x
GASS_EmptySlice7:sta $1000+18,x
                beq GASS_NextSlice
