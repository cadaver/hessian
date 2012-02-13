MAX_SPRX        = 168
MIN_SPRY        = 34
MAX_SPRY        = 221

SPR_MC1         = $00
SPR_MC2         = $0a

FIRSTCACHEFRAME = $40
EMPTYSPRITEFRAME = $7f

SPRH_MASK       = 0
SPRH_COLOR      = 1
SPRH_HOTSPOTX   = 2
SPRH_CONNECTSPOTX = 3
SPRH_HOTSPOTY   = 4
SPRH_CONNECTSPOTY = 5
SPRH_CACHEFRAME = 6
SPRH_DATA       = 7

        ; Select a sprite file for access, and load if unloaded. Note: is unrolled in
        ; DrawActors to avoid JSR
        ;
        ; Parameters: A sprite file number
        ; Returns: sprFileLo-Hi spritefile address
        ; Modifies: A,Y,temp6-temp8,loader temp vars

GetSpriteFile:  sta sprFileNum
                tay
                lda fileHi,y
                bne GSF_Loaded
                jsr LoadSpriteFile
GSF_Loaded:     sta fileHi
                lda fileLo,y
                sta fileLo
                rts

LoadSpriteFile: tya
                sec
                sbc #C_FIRSTSPR
                ldx #F_SPRITE
                jsr MakeFileName
                jsr LoadAllocFile               ;TODO: check for error
                jsr InitMap
                ldy temp6                       ;LoadAllocFile puts chunk number to temp6
                sty sprFileNum                  ;PurgeChunk clears sprFileNum, restore it now
                lda fileHi,y
                sta sprFileHi
GASS_DoNotAccept:
                rts

        ; Get and store a sprite. Cache (depack) if not cached yet.
        ;
        ; Parameters: A frame number, X sprite index, temp1 X coord, temp2-temp3 Y coord, 
        ;             actIndex actor index, sprFileLo-Hi spritefile
        ; Returns: X incremented if sprite accepted, temp1-temp3 modified for next sprite
        ; Modifies: A,Y,temp1-temp3
        
GetAndStoreSprite:
                cpx #MAX_SPR
                bcs GASS_DoNotAccept
                asl
                tay
                sty zpBitsLo                    ;Save framenumber*2
                lda (sprFileLo),y               ;Get sprite header address
                sta frameLo
                iny
                lda (sprFileLo),y
                sta frameHi
                ldy #SPRH_HOTSPOTX
                lda temp1                       ;Subtract X-hotspot
                sec
                sbc (frameLo),y
                iny
                cmp #MAX_SPRX
                bcs GASS_XOutside
                sta sprX,x
                clc                             ;Add X-connect spot
                adc (frameLo),y
                iny
                sta temp1
                lda temp2                       ;Subtract Y-hotspot
                sec
                sbc (frameLo),y
                iny
                sta sprY,x
                lda temp3
                sbc #$00
                sta temp3
                bne GASS_YOutside
                lda (frameLo),y                 ;Check sign of Y-connect spot
                clc
                bmi GASS_CSYNeg
                adc sprY,x
                sta temp2
                lda #$00
                beq GASS_CSYCommon
GASS_CSYNeg:    adc sprY,x
                sta temp2
                lda #$ff
GASS_CSYCommon: adc temp3
                sta temp3
                jmp GASS_Accept

GASS_XOutside:  clc                             ;X coord is outside, but must still add the connect-spot
                adc (frameLo),y
                iny
                sta temp1
                lda temp2                       ;Subtract Y-hotspot
                sec
                sbc (frameLo),y
                iny
                sta sprY,x
                lda temp3
                sbc #$00
                sta temp3
GASS_YOutside:  lda (frameLo),y                 ;Y coord is outside, but must still add the connect-spot
                clc
                bmi GASS_CSYNeg2
                adc sprY,x
                sta temp2
                lda #$00
                beq GASS_CSYCommon2
GASS_CSYNeg2:   adc sprY,x
                sta temp2
                lda #$ff
GASS_CSYCommon2:adc temp3
                sta temp3
GASS_DoNotAccept2:
                rts

        ; Get and store a sprite without modifying coords for next sprite
        ;
        ; Parameters: A frame number, X sprite index, temp1 X coord, temp2-temp3 Y coord,
        ;             actIndex actor index, sprFileLo-Hi spritefile
        ; Returns: X incremented if sprite accepted
        ; Modifies: A,Y,temp1-temp3

GetAndStoreLastSprite:
                cpx #MAX_SPR
                bcs GASS_DoNotAccept2
                asl
                tay
                sty zpBitsLo                    ;Save framenumber*2
                lda (sprFileLo),y               ;Get sprite header address
                sta frameLo
                iny
                lda (sprFileLo),y
                sta frameHi
                lda temp3                       ;Optimization: check Y high without actually
                bne GASS_DoNotAccept2           ;subtracting the hotspot from it
                ldy #SPRH_HOTSPOTX
                lda temp1                       ;Subtract X-hotspot
                sec
                sbc (frameLo),y
                cmp #MAX_SPRX
                bcs GASS_DoNotAccept2
                sta sprX,x
                ldy #SPRH_HOTSPOTY              ;Subtract Y-hotspot
                lda temp2
                sec
                sbc (frameLo),y
                sta sprY,x
GASS_Accept:    lda actIndex                    ;Sprite was accepted: store actor index
                sta sprAct,x                    ;for interpolation
                ldy #SPRH_COLOR
                lda (frameLo),y
GASS_ColorAnd:  and #$00
GASS_ColorOr:   ora #$00
                sta sprC,x                      ;Store color
                ldy #SPRH_CACHEFRAME
                lda (frameLo),y                 ;Check if already cached
                beq GASS_CacheSprite
                sta sprF,x
                tay
                lda #$02                        ;Reset cache age
                sta cacheSprInUse-FIRSTCACHEFRAME,y
                inx                             ;Finally increment sprite count
                rts

        ; Cache (depack) a sprite

GASS_CacheSprite:    
                stx zpBitsHi
GASS_CachePos:  ldx #MAX_CACHESPRITES           ;Continue from where we left off last time
GASS_Loop:      dex
                bpl GASS_NotOver
                ldx #MAX_CACHESPRITES-1
GASS_NotOver:   lda cacheSprInUse,x             ;Check if in use
                bne GASS_Loop
                ldy cacheSprFile,x              ;Clear the old cache mapping if the old file still in memory
                bmi GASS_NoOldSprite
                lda fileHi,y
                beq GASS_NoOldSprite
                sta zpSrcLo
                lda fileLo,y
                sta zpSrcHi
                ldy cacheSprFrame,x
                lda (zpSrcLo),y
                sta zpDestLo
                iny
                lda (zpSrcLo),y
                sta zpDestHi
                ldy #SPRH_CACHEFRAME
                lda #$00
                sta (zpDestLo),y
GASS_NoOldSprite:
                stx GASS_CachePos+1             ;Store cache position for next search
                lda sprFileNum                  ;Save new file & frame numbers so that this mapping
                sta cacheSprFile,x              ;can be cleared in the future
                tay
                lda #$00
                sta fileAge,y                   ;Reset file age, only done when depacking a new sprite
                sta zpBitBuf
                lda zpBitsLo
                sta cacheSprFrame,x
                lda #$02                        ;Mark in use
                sta cacheSprInUse,x
                txa                             ;Calculate sprite address
                lsr
                ror zpBitBuf
                lsr
                ror zpBitBuf
                ora #>spriteCache
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
GASS_AddressOk: lda #$34                        ;Need access to RAM under the I/O area
                sta irqSave01
                sta $01
                ldy #SPRH_COLOR
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
                lda nextSliceTbl,x
                beq GASS_DepackDone
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
                lda nextSliceTbl,x
                beq GASS_DepackDone
                tax
                lsr zpBitsLo
                bcs GASS_FullSlice
                bcc GASS_EmptySlice
GASS_DepackDone:lda #$35                        ;Restore I/O registers
                sta irqSave01
                sta $01
                ldy #SPRH_CACHEFRAME
                lda GASS_CachePos+1             ;Store the used frame into the header for next time
                ora #FIRSTCACHEFRAME
                sta (frameLo),y
                ldx zpBitsHi
                sta sprF,x
                inx                             ;Increment sprite count
                rts

        ; Age the sprite cache. To be called after setting new sprites (DrawActors) is finished
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: -

AgeSpriteCache:
N               set 0
                repeat MAX_CACHESPRITES
                lsr cacheSprInUse+N
N               set N+1
                repend
                rts
