MAX_ACTX        = 14
MAX_ACTY        = 9

ACTI_PLAYER     = 0
ACTI_FIRSTNPC   = 1
ACTI_LASTNPC    = 6
ACTI_FIRSTPLRBULLET = 7
ACTI_LASTPLRBULLET = 11
ACTI_FIRSTNPCBULLET = 12
ACTI_LASTNPCBULLET = 16
ACTI_FIRSTITEM  = 17
ACTI_LASTITEM   = 21
ACTI_FIRSTEFFECT = 22
ACTI_LASTEFFECT = 23

AD_NUMSPRITES   = 0
AD_SPRFILE      = 1
AD_LEFTFRADD    = 2
AD_NUMFRAMES    = 3                             ;For incrementing framepointer. Only significant if multiple sprites
AD_FRAMES       = 4

ADH_SPRFILE     = 1
ADH_BASEFRAME   = 2
ADH_BASEINDEX   = 3                             ;Index to a static 256-byte table for humanoid actor spriteframes
ADH_LEFTFRADD   = 4
ADH_SPRFILE2    = 5
ADH_BASEFRAME2  = 6
ADH_BASEINDEX2  = 7                             ;Index to a static 256-byte table for humanoid actor framenumbers
ADH_LEFTFRADD2  = 8

ONESPRITE       = $00
TWOSPRITE       = $01
THREESPRITE     = $02
FOURSPRITE      = $03
HUMANOID        = $80

AL_UPDATEROUTINE = 0
AL_SIZEHORIZ     = 2
AL_SIZEUP        = 3
AL_SIZEDOWN      = 4
AL_INITIALHP     = 5
AL_MOVECAPS      = 6
AL_MOVESPEED     = 7
AL_FALLSPEED     = 8                            ;Terminal falling velocity, positive
AL_GROUNDACCEL   = 9
AL_INAIRACCEL    = 10
AL_FALLACCEL     = 11                           ;Gravity acceleration
AL_LONGJUMPACCEL = 12                           ;Gravity acceleration in longjump
AL_BRAKING       = 13
AL_HEIGHT        = 14                           ;Height for headbump check, negative
AL_JUMPSPEED     = 15                           ;Negative
AL_CLIMBSPEED    = 16
AL_HALFSPEEDRIGHT = 17                          ;Ladder jump / wallflip speed right
AL_HALFSPEEDLEFT = 18                           ;Ladder jump / wallflip speed left

AMC_JUMP        = 1
AMC_DUCK        = 2
AMC_CLIMB       = 4
AMC_ROLL        = 8
AMC_WALLFLIP    = 16

        ; Draw actors as sprites
        ; Accesses the sprite cache to load/unpack new sprites as necessary
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,actor ZP temp vars

DrawActors:     lda scrollX                     ;Save this frame's finescrolling for InterpolateActors
                sta IA_PrevScrollX+1
                lda scrollY
                sta IA_PrevScrollY+1
                ldx #$00                        ;Reset amount of used sprites
                stx sprIndex
DA_Loop:        ldy actT,x
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
                jmp AgeSpriteCache              ;Sprite cache use finished, age the cache now

DA_NotZero:     stx actIndex
                lda actDispTblHi-1,y            ;Zero display address = invisible
                beq DA_ActorDone
                sta actHi
                lda actDispTblLo-1,y            ;Get actor display structure address
                sta actLo
DA_GetScreenPos:
                lda actYL,x                     ;Convert actor coordinates to screen
                sta actPrevYL,x
                sec
DA_SprSubYL:    sbc #$00
                sta temp3
                lda actYH,x
                sta actPrevYH,x
DA_SprSubYH:    sbc #$00
                cmp #MAX_ACTY
                bcs DA_ActorDone
                tay
                lda temp3
                lsr
                lsr
                lsr
                ora coordTblLo+1,y
                sta temp3
                lda coordTblHi+1,y
                sta temp4
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
                ora coordTblLo,y
                sta temp1
                lda coordTblHi,y
                sta temp2
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

DA_Normal:      sta temp5
                lda actF1,x
                ldy actD,x
                bpl DA_NormalRight
                ldy #AD_LEFTFRADD               ;Add left frame offset if necessary
                adc (actLo),y
DA_NormalRight: adc #AD_FRAMES
                sta temp6                       ;Store framepointer
                ldx sprIndex
DA_NormalLoop:  tay
                lda (actLo),y
                dec temp5                       ;Decrement actor sprite count
                bmi DA_LastSprite               ;If last sprite, no need to add the connect-spot
                jsr GetAndStoreSprite
                ldy #AD_NUMFRAMES
                lda temp6                       ;Advance framepointer
                clc
                adc (actLo),y
                sta temp6
                bcc DA_NormalLoop

DA_OneSprite:   lda actF1,x                     ;Fast path for onesprite-actors
                ldy actD,x
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

DA_Humanoid:    lda actWpnF,x
                sta DA_HumanWpnF+1
                jsr DA_GetHumanFrames
DA_HumanFrame1: lda #$00
                ldx sprIndex
                jsr GetAndStoreSprite
                ldy #ADH_SPRFILE2               ;Get second part spritefile
                lda (actLo),y
                cmp sprFileNum
                beq DA_HumanFrame2
                sta sprFileNum
                tay
                lda fileHi,y
                bne DA_SprFileLoaded2
                jsr LoadSpriteFile
DA_SprFileLoaded2:
                sta sprFileHi
                lda fileLo,y
                sta sprFileLo
DA_HumanFrame2: lda #$00
                jsr GetAndStoreSprite
DA_HumanWpnF:   lda #$00
                bmi DA_HumanNoWeapon
                ldy #C_WEAPON                   ;Note: weapon sprites must always be loaded
                sty sprFileNum                  ;into the memory
                ldy fileLo+C_WEAPON
                sty sprFileLo
                ldy fileHi+C_WEAPON
                sty sprFileHi
                jsr GetAndStoreLastSprite
DA_HumanNoWeapon:
                stx sprIndex
                ldx actIndex
                jmp DA_ActorDone

DA_GetHumanFrames:
                lda actF1,x
                ldy actD,x
                bpl DA_HumanRight1
                ldy #ADH_LEFTFRADD              ;Add left frame offset if necessary
                adc (actLo),y
DA_HumanRight1: ldy #ADH_BASEINDEX
                adc (actLo),y
                tay
                lda humanLowerFrTbl,y           ;Take sprite frame from the frametable
                ldy #ADH_BASEFRAME
                adc (actLo),y
                sta DA_HumanFrame1+1
                lda actF2,x
                ldy actD,x
                bpl DA_HumanRight2
                ldy #ADH_LEFTFRADD2             ;Add left frame offset if necessary
                adc (actLo),y
DA_HumanRight2: ldy #ADH_BASEINDEX2
                adc (actLo),y
                tay
                lda humanUpperFrTbl,y           ;Take sprite frame from the frametable
                ldy #ADH_BASEFRAME2
                adc (actLo),y
                sta DA_HumanFrame2+1
                rts

        ; Update actors
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,actor temp vars

UpdateActors:   ldx #$00
UA_Loop:        ldy actT,x
                bne UA_NotZero
UA_Next:        inx
                cpx #MAX_ACT
                bcc UA_Loop
                rts
UA_NotZero:     stx actIndex
                lda actLogicTblLo-1,y            ;Get actor logic structure address
                sta actLo
                lda actLogicTblHi-1,y
                sta actHi
                ldy #AL_UPDATEROUTINE
                lda (actLo),y
                sta UA_Jump+1
                iny
                lda (actLo),y
                sta UA_Jump+2
UA_Jump:        jsr $1000
                inx
                cpx #MAX_ACT
                bcc UA_Loop
IA_Done2:       rts

        ; Interpolate actors' movement each second frame
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

InterpolateActors:
                lda scrollX                     ;Calculate how much the scrolling has changed
                sec
IA_PrevScrollX: sbc #$00
                bmi IA_ScrollXNeg
                cmp #$05
                bcc IA_ScrollXOk
                sbc #$08
                bcc IA_ScrollXOk
IA_ScrollXNeg:  cmp #$fc
                bcs IA_ScrollXOk
                adc #$08
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
                cmp #$c0
                beq IA_AddOffset
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
                bit temp1
                bpl IA_XMovePos
                ora #$f0
                adc #$00
IA_XMovePos:    sec
IA_ScrollXAdjust:
                sbc #$00                        ;Add scrolling
                sta actPrevXL,y
                clc
                bmi IA_XOffsetNeg
                adc sprXL,x
                sta sprXL,x                     ;Add offset to sprite
                lda #$00
                beq IA_XOffsetCommon
IA_XOffsetNeg:  adc sprXL,x
                sta sprXL,x
                lda #$ff
IA_XOffsetCommon:
                adc sprXH,x
                sta sprXH,x
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
                lda #$c0                        ;Replace the Y-coord MSB with a marker
                sta actPrevYH,y                 ;so we don't repeat this calculation
IA_Next:        dex
                bmi IA_Done
                jmp IA_SprLoop
IA_Done:        rts

IA_AddOffset:   lda actPrevXL,y                 ;Add offset to sprite coords
                clc
                bmi IA_XOffsetNeg2
                adc sprXL,x
                sta sprXL,x
                lda #$00
                beq IA_XOffsetCommon2
IA_XOffsetNeg2: adc sprXL,x
                sta sprXL,x
                lda #$ff
IA_XOffsetCommon2:
                adc sprXH,x
                sta sprXH,x
                lda sprY,x
                clc
                adc actPrevYL,y
                sta sprY,x
                dex
                bmi IA_Done
                jmp IA_SprLoop

        ; Disable actor interpolation for the current position
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modified: A
        
NoInterpolation:lda actXL,x
                sta actPrevXL,x
                lda actXH,x
                sta actPrevXH,x
                lda actYL,x
                sta actPrevYL,x
                lda actYH,x
                sta actPrevYH,x
                rts

        ; Move actor in X-direction
        ;
        ; Parameters: X actor index, A speed
        ; Returns: -
        ; Modifies: A

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

        ; Move actor in Y-direction
        ;
        ; Parameters: X actor index, A speed
        ; Returns: -
        ; Modifies: A

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

        ; Accelerate actor in X-direction with negative acceleration & speed limit
        ;
        ; Parameters: X actor index, A absolute acceleration, Y absolute speed limit
        ; Returns:
        ; Modifies: A,temp8

AccActorXNeg:   sta temp8
                tya
                eor #$ff
                tay
                iny
                lda actSX,x
                sec
                sbc temp8
                sty temp8
                bmi AAX_SpeedNeg
                bpl AAX_SpeedPos

        ; Accelerate actor in X-direction
        ;
        ; Parameters: X actor index, A acceleration, Y speed limit
        ; Returns: -
        ; Modifies: A,temp8

AccActorX:      sty temp8
                clc
                adc actSX,x
                bmi AAX_SpeedNeg
AAX_SpeedPos:   bit temp8                       ;If speed positive and limit negative,
                bmi AAX_AccDone                 ;can't have reached limit yet
                cmp temp8
                bcc AAX_AccDone
                bcs AAX_AccLimit
AAX_SpeedNeg:   bit temp8                       ;If speed negative and limit positive,
                bpl AAX_AccDone                 ;can't have reached limit yet
                cmp temp8
                bcs AAX_AccDone
AAX_AccLimit:   tya
AAX_AccDone:    sta actSX,x
                rts

        ; Accelerate actor in Y-direction
        ;
        ; Parameters: X actor index, A acceleration, Y speed limit
        ; Returns: -
        ; Modifies: A, temp8

AccActorY:      sty temp8
                clc
                adc actSY,x
                bmi AAY_SpeedNeg
AAY_SpeedPos:   bit temp8                       ;If speed positive and limit negative,
                bmi AAY_AccDone                 ;can't have reached limit yet
                cmp temp8
                bcc AAY_AccDone
                bcs AAY_AccLimit
AAY_SpeedNeg:   bit temp8                       ;If speed negative and limit positive,
                bpl AAY_AccDone                 ;can't have reached limit yet
                cmp temp8
                bcs AAY_AccDone
AAY_AccLimit:   tya
AAY_AccDone:    sta actSY,x
                rts

        ; Brake X-speed of an actor towards zero
        ;
        ; Parameters: X Actor index, A deceleration (always positive)
        ; Returns: -
        ; Modifies: A, temp8

BrakeActorX:    sta temp8
                lda actSX,x
                beq BAct_XDone2
                bmi BAct_XNeg
BAct_XPos:      sec
                sbc temp8
                bpl BAct_XDone
                lda #$00
BAct_XDone:     sta actSX,x
BAct_XDone2:    rts
BAct_XNeg:      clc
                adc temp8
                bmi BAct_XDone
                lda #$00
                sta actSX,x
                rts

        ; Brake Y-speed of an actor towards zero
        ;
        ; Parameters: X Actor index, A deceleration (always positive)
        ; Returns: -
        ; Modifies: A, temp8

BrakeActorY:    sta temp8
                lda actSY,x
                beq BAct_YDone2
                bmi BAct_YNeg
BAct_YPos:      sec
                sbc temp8
                bpl BAct_YDone
                lda #$00
BAct_YDone:     sta actSY,x
BAct_YDone2:    rts
BAct_YNeg:      clc
                adc temp8
                bmi BAct_YDone
                lda #$00
                sta actSY,x
                rts

        ; Process actor's animation delay
        ;
        ; Parameters: X actor index, A animation speed-1 (in frames)
        ; Returns: C=1 delay exceeded, animationdelay reset
        ; Modifies: A

AnimationDelay: sta AD_Cmp+1
                lda actFd,x
AD_Cmp:         cmp #$00
                bcs AD_Over
                adc #$01
                sta actFd,x
                rts
AD_Over:        lda #$00
                sta actFd,x
                rts

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

        ; Get char collision info from the actor's position
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,Y,loader temp vars

GetCharInfo:    ldy actYH,x
GCI_Common2:    lda actYL,x
                and #$c0
                lsr
                lsr
                lsr
                lsr
                sta zpBitsLo
GCI_Common:     lda mapTblHi,y
                beq GCI_Outside2
                sta zpDestHi
                lda mapTblLo,y
                sta zpDestLo
                ldy actXH,x
                cpy limitL
                bcc GCI_Outside
                cpy limitR
                bcs GCI_Outside
                lda (zpDestLo),y                ;Get block from map
GCI_OutsideDone:tay
                lda blkTblLo,y
                sta zpDestLo
                lda blkTblHi,y
                sta zpDestHi
                lda actXL,x
                rol
                rol
                rol
                and #$03
                ora zpBitsLo
                tay
                lda (zpDestLo),y                ;Get char from block
                tay
                lda charInfo,y                  ;Get charinfo
                rts
GCI_Outside:    lda #$00                        ;Outside map block $00 is always returned
GCI_Outside2:   sta zpBitsLo
                beq GCI_OutsideDone

        ; Get char collision info from 1 char above actor's pos (optimized)
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,Y,loader temp vars

GetCharInfo1Above:
                lda actYL,x
                and #$c0
                lsr
                lsr
                lsr
                lsr
                ldy actYH,x
                sbc #$04-1                      ;C=0
                bcs GCI1A_Ok
                lda #$0c
                dey
GCI1A_Ok:       sta zpBitsLo
                jmp GCI_Common

        ; Get char collision info from 1 char above actor's pos (optimized)
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,Y,loader temp vars

GetCharInfo1Below:
                lda actYL,x
                and #$c0
                lsr
                lsr
                lsr
                lsr
                ldy actYH,x
                adc #$04
                cmp #$10
                bcc GCI1B_Ok
                lda #$00
                iny
GCI1B_Ok:       sta zpBitsLo
                jmp GCI_Common

        ; Get char collision info from 4 chars above actor's pos (optimized)
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,Y,loader temp vars

GetCharInfo4Above:
                ldy actYH,x
                dey
                bpl GCI_Common2
                bpl GCI_Outside

        ; Get char collision info from the actor's position with Y offset
        ;
        ; Parameters: X actor index, A signed Y offset in chars
        ; Returns: A charinfo
        ; Modifies: A,Y,loader temp vars

GetCharInfoOffset:
                sta zpBitsLo
                lda actYL,x
                rol
                rol
                rol
                and #$03
                clc
                adc zpBitsLo
                tay
                asl
                asl
                and #$0c
                sta zpBitsLo
                tya
                cmp #$80
                ror
                cmp #$80
                ror
                clc
                adc actYH,x
                bmi GCI_Outside
                tay
                jmp GCI_Common

        ; Set collision size for actor
        ;
        ; Parametrs: X actor index
        ; Returns: -
        ; Modifies: A,Y,actLo-actHi
        
SetActorSize:   ldy actT,x
                lda actLogicTblLo-1,y            ;Get actor logic structure address
                sta actLo
                lda actLogicTblHi-1,y
                sta actHi
                ldy #AL_SIZEHORIZ
                lda (actLo),y
                sta actSizeH,x
                iny
                lda (actLo),y
                sta actSizeU,x
                iny
                lda (actLo),y
                sta actSizeD,x
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

        ; Remove actor
        ; TODO: return to leveldata
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A

RemoveActor:    lda #ACT_NONE
                sta actT,x
                rts

        ; Remove all actors
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X

RemoveAllActors:ldx #MAX_ACT-1
RAA_Loop:       jsr RemoveActor
                dex
                bpl RAA_Loop
                rts

        ; Clear all actors without returning them to leveldata
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X

ClearActors:    ldx #MAX_ACT-1
CA_Loop:        lda #ACT_NONE
                sta actT,x
                dex
                bpl CA_Loop
                rts

        ; Get a free actor
        ;
        ; Parameters: A first actor index to check (do not pass 0 here), Y last actor index to check
        ; Returns: C=1 free actor found (returned in Y), C=0 no free actor
        ; Modifies: A,Y

GetFreeActor:   sta GFA_Cmp+1
GFA_Loop:       lda actT,y
                beq GFA_Found
                dey
GFA_Cmp:        cpy #$00
                bcs GFA_Loop
                rts
GFA_Found:      sec
                lda #$00                        ;Reset animation & speed when free actor found
                sta actF1,y                     ;TODO: reset more as needed
                sta actFd,y
                sta actSX,y
                sta actSY,y
                sta actC,y
                sta actMoveFlags,y
                cpy #MAX_COMPLEXACT
                bcs GFA_NotComplex
                sta actF2,y
                sta actCtrl,y
                sta actMoveCtrl,y
                sta actPrevCtrl,y
                sta actWpn,y
                lda #$ff
                sta actWpnF,y
GFA_NotComplex: rts

        ; Spawn an actor with X & Y offset
        ;
        ; Parameters: A actor type, X creating actor, Y destination actor index, temp5-temp6 X offset,
        ;             temp7-temp8 Y offset
        ; Returns: -
        ; Modifies: A

SpawnWithOffset:sta actT,y
                lda actGrp,x                    ;Copy origin group
                sta actGrp,y
                lda actXL,x
                clc
                adc temp5
                sta actXL,y
                lda actXH,x
                adc temp6
                sta actXH,y
                lda actYL,x
                clc
                adc temp7
                sta actYL,y
                lda actYH,x
                adc temp8
                sta actYH,y
                rts

        ; Get flashing color override for actor based on low bit of actor index
        ;
        ; Parameters: A actor index
        ; Returns: A color override value, either $40 or $c0
        ; Modifies: A
        
GetFlashColorOverride:
                ror
                ror
                and #$80
                ora #$40
                rts
