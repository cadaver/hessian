MAX_ACTX        = 14
MAX_ACTY        = 9

AD_NUMSPRITES   = 0
AD_SPRFILE      = 1
AD_LEFTFRADD    = 2
AD_NUMFRAMES    = 3                             ;For incrementing framepointer. Only significant if multiple sprites
AD_FRAMES       = 4

ADH_SPRFILE     = 1
ADH_LEFTFRADD   = 2
ADH_BASEFR      = 3                             ;Index to a static 256-byte table for humanoid actor spriteframes
ADH_SPRFILE2    = 4
ADH_LEFTFRADD2  = 5                             ;Index to a static 256-byte table for humanoid actor framenumbers
ADH_BASEFR2     = 6

ONESPRITE       = $00
TWOSPRITE       = $01
THREESPRITE     = $02
FOURSPRITE      = $03
HUMANOID        = $80

ACTI_PLAYER     = 0

        ; Draw actors as sprites
        ; Accesses the sprite cache to load/unpack new sprites as necessary
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,actor ZP temp vars

DrawActors:
                if SHOW_ACTOR_RASTERTIME > 0
                lda #$02
                sta $d020
                endif
                lda scrollX                     ;Save this frame's finescrolling for InterpolateActors
                lsr
                sta IA_PrevScrollX+1
                lda scrollY
                sta IA_PrevScrollY+1
                ldx #$00                        ;Reset amount of used sprites
                stx sprIndex
DA_Loop:        ldy actType,x
                bne DA_NotZero
DA_ActorDone:   inx
                cpx #MAX_ACT
                bcc DA_Loop
DA_FillSprites: ldx sprIndex                    ;If less sprites used than last frame, set unused Y-coords to max.
DA_FillSpritesLoop:
                lda #$ff
                sta sprY,x
                inx
DA_LastSprIndex:cpx #$00
                bcc DA_FillSpritesLoop
DA_FillSpritesDone:
                lda sprIndex
                sta DA_LastSprIndex+1
                if SHOW_ACTOR_RASTERTIME > 0
                jsr AgeSpriteCache
                lda #$00
                sta $d020
                rts
                else
                jmp AgeSpriteCache              ;Sprite cache use finished, age the cache now
                endif

DA_NotZero:     stx actIndex
                lda actDispTblLo-1,y            ;Get actor display structure address
                sta actLo
                lda actDispTblHi-1,y
                sta actHi
DA_GetScreenPos:
                lda actYL,x                     ;Convert actor coordinates to screen
                sta actPrevYL,x
                sec
DA_SprSubYL:    sbc #$00
                sta temp2
                lda actYH,x
                sta actPrevYH,x
DA_SprSubYH:    sbc #$00
                cmp #MAX_ACTY
                bcs DA_ActorDone
                tay
                lda temp2
                lsr
                lsr
                lsr
                ora coordTblYLo,y
                sta temp2
                lda coordTblYHi,y
                sta temp3
                lda actXL,x
                sta actPrevXL,x
                sec
DA_SprSubXL:    sbc #$00
                sta temp1
                lda actXH,x
                sta actPrevXH,x
DA_SprSubXH:    sbc #$00
                cmp #MAX_ACTX                   ;Skip if significantly outside the screen
                bcs DA_ActorDone
                tay
                lda temp1
                lsr
                lsr
                lsr
                lsr
                ora coordTblX,y
                sta temp1
                ldy #$0f                        ;Get flashing/flicker/color override:
                lda actC,x                      ;$01-$0f = color override only
                sta GASS_ColorOr+1              ;$40/$80 = flicker with sprite's own color
                and #$0f                        ;$4x/$8x = flicker with color override
                beq DA_ColorOverrideDone
                ldy #$00
DA_ColorOverrideDone:
                sty GASS_ColorAnd+1
                ldy #AD_SPRFILE                 ;Get spritefile. Also called for invisible actors,
                lda (actLo),y                   ;so the spritefile must be valid
                cmp sprFileNum
                beq DA_SameSprFile
                sta sprFileNum                  ;Store spritefilenumber, needed in caching
                tay
                lda fileHi,y
                bne DA_SprFileLoaded
                jsr LoadSpriteFile
DA_SprFileLoaded:
                sta sprFileHi
                lda fileLo,y
                sta sprFileLo
DA_SameSprFile: ldy #AD_NUMSPRITES              ;Get number of sprites / humanoid / invisible flag
                clc
                lda (actLo),y
                beq DA_OneSprite
                bmi DA_Humanoid

DA_Normal:      sta temp4
                lda actF1,x
                ldy actDir,x
                bpl DA_NormalRight
                ldy #AD_LEFTFRADD               ;Add left frame offset if necessary
                adc (actLo),y
DA_NormalRight: adc #AD_FRAMES
                sta temp5                       ;Store framepointer
                ldx sprIndex
DA_NormalLoop:  tay
                lda (actLo),y
                dec temp4                       ;Decrement actor sprite count
                bmi DA_LastSprite               ;If last sprite, no need to add the connect-spot
                jsr GetAndStoreSprite
                ldy #AD_NUMFRAMES
                lda temp5                       ;Advance framepointer
                clc
                adc (actLo),y
                sta temp5
                bcc DA_NormalLoop

DA_OneSprite:   lda actF1,x                     ;Fast path for onesprite-actors
                ldy actDir,x
                bpl DA_OneSpriteRight
                ldy #AD_LEFTFRADD               ;Add left frame offset if necessary
                adc (actLo),y
DA_OneSpriteRight:
                adc #AD_FRAMES
                ldx sprIndex
                tay
                lda (actLo),y
DA_LastSprite:  jsr GetAndStoreLastSprite
                stx sprIndex
                ldx actIndex
                jmp DA_ActorDone

DA_Humanoid:    lda actF2,x
                ldy actDir,x
                bpl DA_HumanRight2
                ldy #ADH_LEFTFRADD              ;Add left frame offset if necessary
                adc (actLo),y
DA_HumanRight2: ldy #ADH_BASEFR2
                adc (actLo),y
                tay
                lda humanUpperFrTbl,y           ;Take sprite frame from the frametable
                sta DA_HumanFrame2+1
                lda actF1,x
                ldy actDir,x
                bpl DA_HumanRight1
                ldy #ADH_LEFTFRADD              ;Add left frame offset if necessary
                adc (actLo),y
DA_HumanRight1: ldy #ADH_BASEFR
                adc (actLo),y
                tay
                lda humanLowerFrTbl,y           ;Take sprite frame from the frametable
                ldx sprIndex
                jsr GetAndStoreSprite
                ldy #ADH_SPRFILE2               ;Get second part spritefile
                lda (actLo),y
                cmp sprFileNum
                beq DA_SameSprFile2
                sta sprFileNum
                tay
                lda fileHi,y
                bne DA_SprFileLoaded2
                jsr LoadSpriteFile
DA_SprFileLoaded2:
                sta sprFileHi
                lda fileLo,y
                sta sprFileLo
DA_SameSprFile2:
DA_HumanFrame2: lda #$00
                jsr GetAndStoreSprite
                stx sprIndex
                ldx actIndex
                jmp DA_ActorDone

        ; Interpolate actors' movement each second frame
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

IA_Done2:
                if SHOW_ACTOR_RASTERTIME > 0
                lda #$00
                sta $d020
                endif
                rts

InterpolateActors:
                if SHOW_ACTOR_RASTERTIME > 0
                lda #$04
                sta $d020
                endif
                lda scrollX                     ;Calculate how much the scrolling has changed
                lsr
                sec
IA_PrevScrollX: sbc #$00
                bmi IA_ScrollXNeg
                cmp #$03
                bcc IA_ScrollXOk
                sbc #$04
                bcc IA_ScrollXOk
IA_ScrollXNeg:  cmp #$fe
                bcs IA_ScrollXOk
                adc #$04
IA_ScrollXOk:   sta IA_ScrollXAdjust+1
                lda scrollY
                sec
IA_PrevScrollY: sbc #$00
                bmi IA_ScrollYNeg
                cmp #$05
                bcc IA_ScrollYOk
                sbc #$08
                bcc IA_ScrollYOk
IA_ScrollYNeg:  cmp #$fc
                bcs IA_ScrollYOk
                adc #$08
IA_ScrollYOk:   sta IA_ScrollYAdjust+1
                ldx DA_LastSprIndex+1
                dex
                bmi IA_Done2
IA_SprLoop:     lda sprC,x                      ;Process flickering
                cmp #$40
                bcc IA_NoFlicker
                eor #$80                        ;If sprite is invisible on this frame,
                sta sprC,x                      ;no need to calculate & add offset
                bmi IA_Next
IA_NoFlicker:   ldy sprAct,x                    ;Take actor number associated with sprite
                lda actPrevYH,y                 ;Offset already calculated?
                bmi IA_AddOffset
                lda actXL,y                     ;Calculate average movement
                sec                             ;of actor in X-direction
                sbc actPrevXL,y
                sta temp1
                lda actXH,y
                sbc actPrevXH,y
                lsr
                ror temp1
                lda temp1
                lsr
                lsr
                lsr
                lsr
                bit temp1
                bpl IA_XMovePos
                ora #$f0
                adc #$00
IA_XMovePos:    sec
IA_ScrollXAdjust:
                sbc #$00                        ;Add scrolling
                sta actPrevXL,y
                clc
                adc sprX,x
                sta sprX,x                      ;Add offset to sprite
                lda actYL,y                     ;Calculate average movement
                sec                             ;of actor in Y-direction
                sbc actPrevYL,y
                sta temp1
                lda actYH,y
                sbc actPrevYH,y
                lsr
                ror temp1
                lda temp1
                lsr
                lsr
                lsr
                bit temp1
                bpl IA_YMovePos
                ora #$e0
                adc #$00
IA_YMovePos:    sec
IA_ScrollYAdjust:
                sbc #$00                        ;Add scrolling
                sta actPrevYL,y
                clc
                adc sprY,x
                sta sprY,x                      ;Add offset to sprite
                lda #$ff                        ;Replace the Y-coord MSB with a marker
                sta actPrevYH,y                 ;so we don't repeat this calculation
IA_Next:        dex
                bpl IA_SprLoop
IA_Done:
                if SHOW_ACTOR_RASTERTIME > 0
                lda #$00
                sta $d020
                endif
                rts

IA_AddOffset:   lda sprX,x                      ;Add offset to sprite coords
                clc
                adc actPrevXL,y
                sta sprX,x
                lda sprY,x
                clc
                adc actPrevYL,y
                sta sprY,x
                dex
                bmi IA_Done
                jmp IA_SprLoop

        ; Accelerate actor in X-direction, then move
        ;
        ; Parameters: X actor index, A acceleration, Y speed limit
        ; Returns: -
        ; Modifies: A,temp8

AccMoveActorX:  sty temp8
                clc
                adc actSX,x
                bmi AMAX_SpeedNeg
AMAX_SpeedPos:  bit temp8                       ;If speed positive and limit negative,
                bmi AMAX_AccDone                ;can't have reached limit yet
                cmp temp8
                bcc AMAX_AccDone
                bcs AMAX_AccLimit
AMAX_SpeedNeg:  bit temp8                       ;If speed negative and limit positive,
                bpl AMAX_AccDone                ;can't have reached limit yet
                cmp temp8
                bcs AMAX_AccDone
AMAX_AccLimit:  tya
AMAX_AccDone:   sta actSX,x

        ; Move actor in X-direction
        ;
        ; Parameters: X actor index, A speed
        ; Returns: -
        ; Modifies: A,Y

MoveActorX:     cmp #$80
                bcs MAX_Neg
MAX_Pos:        adc actXL,x
                sta actXL,x
                bcc MAX_PosOk
                inc actXH,x
MAX_PosOk:      rts
MAX_Neg:        clc
                adc actXL,x
                sta actXL,x
                bcs MAX_NegOk
                dec actXH,x
MAX_NegOk:      rts

        ; Accelerate actor in Y-direction, then move
        ;
        ; Parameters: X actor index, A acceleration, Y speed limit
        ; Returns: -
        ; Modifies: A,temp8

AccMoveActorY:  sty temp8
                clc
                adc actSY,x
                bmi AMAY_SpeedNeg
AMAY_SpeedPos:  bit temp8                       ;If speed positive and limit negative,
                bmi AMAY_AccDone                ;can't have reached limit yet
                cmp temp8
                bcc AMAY_AccDone
                bcs AMAY_AccLimit
AMAY_SpeedNeg:  bit temp8                       ;If speed negative and limit positive,
                bpl AMAY_AccDone                ;can't have reached limit yet
                cmp temp8
                bcs AMAY_AccDone
AMAY_AccLimit:  tya
AMAY_AccDone:   sta actSY,x

        ; Move actor in Y-direction
        ;
        ; Parameters: X actor index, A speed
        ; Returns: -
        ; Modifies: A,Y

MoveActorY:     cmp #$80
                bcs MAY_Neg
MAY_Pos:        adc actYL,x
                sta actYL,x
                bcc MAY_PosOk
                inc actYH,x
MAY_PosOk:      rts
MAY_Neg:        clc
                adc actYL,x
                sta actYL,x
                bcs MAY_NegOk
                dec actYH,x
MAY_NegOk:      rts

        ; Get screen relative char coordinates for actor. To be used for example in scrolling
        ;
        ; Parameters: X actor index
        ; Returns: A X-coordinate, Y y-coordinate
        ; Modifies: A,Y,temp8

GetActorCharCoords:
                lda actYL,x
                rol
                rol
                rol
                and #$03
                sec
                sbc SL_CSSBlockY+1
                and #$03
                sta temp8
                lda actYH,x
                sbc SL_CSSMapY+1
                asl
                asl
                ora temp8
                tay
                lda actXL,x
                rol
                rol
                rol
                and #$03
                sec
                sbc SL_CSSBlockX+1
                and #$03
                sta temp8
                lda actXH,x
                sbc SL_CSSMapX+1
                asl
                asl
                ora temp8
                rts
      
        ; Check if two actors have collided
        ;
        ; Parameters: X,Y actor numbers
        ; Returns: C=1 if collided
        ; Modifies: A,temp7-temp8

CheckActorCollision:
                lda actXL,x
                sec
                sbc actXL,y
                sta temp8
                lda actXH,x
                sbc actXH,y
                bpl CAC_XPos
                sta temp7
                lda temp8
                eor #$ff
                adc #$01                        ;C=0
                sta temp8
                lda temp7
                eor #$ff
                adc #$00
CAC_XPos:       lsr
                ror temp8
                lsr
                ror temp8
                lsr
                bne CAC_TooFar
                ror temp8
                lda actSizeH,x
                adc actSizeH,y
                cmp temp8
                bcs CAC_XOk
CAC_TooFar:     clc
                rts
CAC_XOk:        lda actYL,x
                sec
                sbc actYL,y
                sta temp8
                lda actYH,x
                sbc actYH,y
                bpl CAC_YPos
CAC_YNeg:       sta temp7
                eor #$ff
                adc #$01                        ;C=0
                sta temp8
                lda temp7
                eor #$ff  
                adc #$00
                lsr
                ror temp8
                lsr
                ror temp8
                lsr
                bne CAC_TooFar
                ror temp8
                lda actSizeD,x
                adc actSizeU,y
                cmp temp8
                rts
CAC_YPos:       lsr
                ror temp8
                lsr
                ror temp8
                lsr
                bne CAC_TooFar
                ror temp8
                lda actSizeU,x
                adc actSizeD,y
                cmp temp8
                rts