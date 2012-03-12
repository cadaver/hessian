MAX_SPRX        = 335
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

        ; Load a sprite file
        ;
        ; Parameters: Y sprite file number
        ; Returns: A sprite file address highbyte
        ; Modifies: A,Y,temp6-temp8,loader temp vars

LoadSpriteFile: stx LSF_SaveX+1
                tya
                sec
                sbc #C_FIRSTSPR
                ldx #F_SPRITE
                jsr MakeFileName
                jsr LoadAllocFile               ;TODO: check for error
                jsr PostLoad
                ldy temp6                       ;LoadAllocFile puts chunk number to temp6
                sty sprFileNum                  ;PurgeChunk clears sprFileNum, restore it now
                lda fileHi,y
LSF_SaveX:      ldx #$00
GASS_DoNotAccept:
                rts

        ; Get and store a sprite. Cache (depack) if not cached yet.
        ;
        ; Parameters: A frame number, X sprite index, temp1-temp2 X coord, temp3-temp4 Y coord,
        ;             actIndex actor index, sprFileLo-Hi spritefile
        ; Returns: X incremented if sprite accepted, temp1-temp4 modified for next sprite
        ; Modifies: A,X,Y,temp1-temp4

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
                sta sprXL,x
                lda temp2
                sbc #$00
                sta sprXH,x
                beq GASS_XNotOutside
                lda sprXL,x
                cmp #MAX_SPRX-256
                bcs GASS_XOutside
GASS_XNotOutside:
                lda (frameLo),y                 ;Add X-connect spot
                clc
                bmi GASS_CSXNeg
                adc sprXL,x
                sta temp1
                lda #$00
                beq GASS_CSXCommon
GASS_CSXNeg:    adc sprXL,x
                sta temp1
                lda #$ff
GASS_CSXCommon: adc sprXH,x
                sta temp2
                iny
                lda temp3                       ;Subtract Y-hotspot
                sec
                sbc (frameLo),y
                iny
                sta sprY,x
                lda temp4
                sbc #$00
                sta temp4
                bne GASS_YOutside
                lda (frameLo),y                 ;Add Y-connect spot
                clc
                bmi GASS_CSYNeg
                adc sprY,x
                sta temp3
                lda #$00
                beq GASS_CSYCommon
GASS_CSYNeg:    adc sprY,x
                sta temp3
                lda #$ff
GASS_CSYCommon: adc temp4
                sta temp4
                jmp GASS_Accept

GASS_XOutside:  lda (frameLo),y                 ;X coord is outside, but must still add the connect-spot
                clc
                bmi GASS_CSXNeg2
                adc sprXL,x
                sta temp1
                lda #$00
                beq GASS_CSXCommon2
GASS_CSXNeg2:   adc sprXL,x
                sta temp1
                lda #$ff
GASS_CSXCommon2:adc sprXH,x
                sta temp2
                iny                
                lda temp3                       ;Subtract Y-hotspot
                sec
                sbc (frameLo),y
                iny
                sta sprY,x
                lda temp4
                sbc #$00
                sta temp4
GASS_YOutside:  lda (frameLo),y                 ;Y coord is outside, but must still add the connect-spot
                clc
                bmi GASS_CSYNeg2
                adc sprY,x
                sta temp3
                lda #$00
                beq GASS_CSYCommon2
GASS_CSYNeg2:   adc sprY,x
                sta temp3
                lda #$ff
GASS_CSYCommon2:adc temp4
                sta temp4
GASS_DoNotAccept2:
                rts

        ; Get and store a sprite without modifying coords for next sprite
        ;
        ; Parameters: A frame number, X sprite index, temp1-temp2 X coord, temp3-temp4 Y coord,
        ;             actIndex actor index, sprFileLo-Hi spritefile
        ; Returns: X incremented if sprite accepted
        ; Modifies: A,X,Y

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
                lda temp4                       ;Optimization: check Y high without actually
                bne GASS_DoNotAccept2           ;subtracting the hotspot from it
                ldy #SPRH_HOTSPOTX
                lda temp1                       ;Subtract X-hotspot
                sec
                sbc (frameLo),y
                sta sprXL,x
                lda temp2
                sbc #$00
                sta sprXH,x
                beq GASS_XNotOutside2
                lda sprXL,x
                cmp #MAX_SPRX-256
                bcs GASS_DoNotAccept2
GASS_XNotOutside2:
                ldy #SPRH_HOTSPOTY              ;Subtract Y-hotspot
                lda temp3
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
                sta zpSrcHi
                lda fileLo,y
                sta zpSrcLo
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
