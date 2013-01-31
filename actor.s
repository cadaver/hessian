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
ACTI_LASTEFFECT = 24

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

COLOR_FLICKER   = $40
COLOR_INVISIBLE = $80
COLOR_ONETIMEFLASH = $f0

AL_UPDATEROUTINE = 0
AL_DESTROYROUTINE = 2
AL_ACTORFLAGS   = 4
AL_SIZEHORIZ    = 5
AL_SIZEUP       = 6
AL_SIZEDOWN     = 7
AL_INITIALHP    = 8
AL_COLOROVERRIDE = 9
AL_DMGMODIFY    = 10
AL_KILLXP       = 11
AL_OFFENSE      = 12
AL_DEFENSE      = 13
AL_MOVEFLAGS    = 14
AL_MOVESPEED    = 15
AL_GROUNDACCEL  = 16
AL_INAIRACCEL   = 17
AL_FALLACCEL    = 18                           ;Gravity acceleration
AL_LONGJUMPACCEL = 19                          ;Gravity acceleration in longjump
AL_BRAKING      = 20
AL_HEIGHT       = 21                           ;Height for headbump check, negative
AL_JUMPSPEED    = 22                           ;Negative
AL_CLIMBSPEED   = 23
AL_HALFSPEEDRIGHT = 24                         ;Ladder jump / wallflip speed right
AL_HALFSPEEDLEFT = 25                          ;Ladder jump / wallflip speed left

AF_NONE         = $00
AF_ISHERO       = $01
AF_INITONLYSIZE = $02
AF_ISORGANIC    = $04
AF_NOREMOVECHECK = $40
AF_ISVILLAIN    = $80

AMF_JUMP        = $01
AMF_DUCK        = $02
AMF_CLIMB       = $04
AMF_ROLL        = $08
AMF_WALLFLIP    = $10
AMF_NOFALLDAMAGE = $20

ADDACTOR_LEFT_LIMIT = 1
ADDACTOR_TOP_LIMIT = 0
ADDACTOR_RIGHT_LIMIT = 12
ADDACTOR_BOTTOM_LIMIT = 8

ORG_NONE        = $80                           ;No leveldata origin
                                                ;TODO: differentiate between persistent/nonpersistent
DEFAULT_PICKUP  = $ff

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
                inc DA_ItemFlashCounter+1
DA_ItemFlashCounter:                            ;Get color override for items
                lda #$00
                lsr
                lsr
                and #$03
                tax
                lda itemFlashTbl,x
                ldx #ACTI_LASTITEM-ACTI_FIRSTITEM
DA_ItemFlashLoop:
                sta actC+ACTI_FIRSTITEM,x
                dex
                bpl DA_ItemFlashLoop
                ldx GASS_CurrentFrame+1
                stx GASS_LastFrame+1
                inx                             ;Increment framenumber for sprite cache
                bne DA_FrameOK                  ;(framenumber is never 0)
                inx
DA_FrameOK:     stx GASS_CurrentFrame+1
                txa
DA_CheckCacheAge:
                ldx #MAX_CACHESPRITES-1
                sec                             ;If age stored in cache is older than significant, reset
                sbc cacheSprAge,x               ;to prevent overflow error (check one sprite per frame)
                cmp #4
                bcc DA_CacheAgeOK
                lda #0
                sta cacheSprAge,x
DA_CacheAgeOK:  dex
                bpl DA_CacheAgeNotOver
                ldx #MAX_CACHESPRITES-1
DA_CacheAgeNotOver:
                stx DA_CheckCacheAge+1
                ldx #$00                        ;Reset amount of used sprites
                stx sprIndex
DA_Loop:        ldy actT,x
                bne DA_NotZero
DA_ActorDone:   inx
                cpx #MAX_ACT
                bcc DA_Loop
DA_FillSprites: ldx sprIndex                    ;If less sprites used than last frame, set unused Y-coords to max.
                txa
                ldy #$ff
DA_FillSpritesLoop:
                sty sprY,x
                inx
DA_LastSprIndex:cpx #$00
                bcc DA_FillSpritesLoop
DA_FillSpritesDone:
                sta DA_LastSprIndex+1
                rts

DA_NotZero:     lda actDispTblHi-1,y            ;Zero display address = invisible
                beq DA_ActorDone
                stx actIndex
                sta actHi
                lda actDispTblLo-1,y            ;Get actor display structure address
                sta actLo
DA_GetScreenPos:lda actYL,x                     ;Convert actor coordinates to screen
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
                cmp #COLOR_ONETIMEFLASH         ;$40/$80 = flicker with sprite's own color
                bcc DA_NoHitFlash               ;$4x/$8x = flicker with color override
                and #$0f                        ;$f0-$ff = one time hit flash + color override
                sta actC,x
                lda #$01
DA_NoHitFlash:  sta GASS_ColorOr+1
                and #$0f
                beq DA_ColorOverrideDone
                iny
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
                ldy #$0f                        ;No color override for the weapon sprite
                sty GASS_ColorAnd+1
                ldy #$00
                sty GASS_ColorOr+1
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
UA_Skip:        rts

        ; Add all actors to screen and update them once before drawing. Call before
        ; entering the main loop after moving to another area or loading a level
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,actor temp vars

UpdateAndAddAllActors:
                lda #$00
                sta addActorIndex
                sta UA_AAEndCmp+1
                beq GetActorBorders

        ; Update actors. Build first collision lists for bullet collisions. Also add
        ; and remove actors from/to leveldata when crossing the screen edges. Followed
        ; by InterpolateActors
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,actor temp vars

UpdateActors:   lda addActorIndex
                clc
                adc #MAX_LVLACT/8               ;To account for max. scrolling speed, check
                and #MAX_LVLACT-1               ;all level actors in space of 8 logic frames
                sta UA_AAEndCmp+1

        ; Calculate border coordinates for adding/removing actors

GetActorBorders:lda mapX                        ;Calculate borders for add/removechecks
                sec
                sbc #ADDACTOR_LEFT_LIMIT
                bcs GAB_LeftOK1
                lda #$00
GAB_LeftOK1:    cmp limitL
                bcs GAB_LeftOK2
                lda limitL
GAB_LeftOK2:    sta UA_RALeftCheck+1            ;Left border
                sta UA_AALeftCheck+1
                lda mapX
                clc
                adc #ADDACTOR_RIGHT_LIMIT
                bcc GAB_RightOK1
                lda #$ff
GAB_RightOK1:   cmp limitR
                bcc GAB_RightOK2
                lda limitR
GAB_RightOK2:   sta UA_RARightCheck+1           ;Right border
                sta UA_AARightCheck+1
                lda mapY
                ;sec
                ;sbc #ADDACTOR_TOP_LIMIT
                ;bcs GAB_TopOK1
                ;lda #$00
GAB_TopOK1:     cmp limitU
                bcs GAB_TopOK2
                lda limitU
GAB_TopOK2:     sta UA_RATopCheck+1             ;Top border
                sta UA_AATopCheck+1
                lda mapY
                clc
                adc #ADDACTOR_BOTTOM_LIMIT
                bpl GAB_BottomOK1
                lda #$7f
GAB_BottomOK1:  cmp limitD
                bcc GAB_BottomOK2
                lda limitD
GAB_BottomOK2:  sta UA_RABottomCheck+1          ;Bottom border
                sta UA_AABottomCheck+1

        ; Add actors from leveldata to screen

AddActors:      ldx addActorIndex
UA_AddActorsLoop:
                lda lvlActT,x
                beq UA_AASkip
                lda lvlActX,x
UA_AALeftCheck: cmp #$00
                bcc UA_AASkip
UA_AARightCheck:cmp #$00
                bcs UA_AASkip
                lda lvlActY,x
UA_AATopCheck:  cmp #$00
                bcc UA_AASkip
UA_AABottomCheck:
                cmp #$00
                bcs UA_AASkip
                jsr AddLevelActor
UA_AASkip:      inx
                bpl UA_AAEndCmp
                ldx #$00
UA_AAEndCmp:    cpx #$00
                bne UA_AddActorsLoop
                stx addActorIndex

        ; Build hero/villain lists for bullet collision

BuildCollisionLists:
                ldx #ACTI_LASTNPC
                ldy #$00                        ;Villain list index
                sty temp1                       ;Hero list index
BCL_Loop:       lda actT,x                      ;Actor must exist and have nonzero health
                beq BCL_Next
                lda actHp,x
                beq BCL_Next
                lda actFlags,x
                and #AF_ISHERO|AF_ISVILLAIN
                beq BCL_Next
                bpl BCL_StoreHero
BCL_StoreVillain:
                txa
                sta villainList,y
                iny
BCL_Next:       dex
                bpl BCL_Loop
                bmi BCL_AllDone
BCL_StoreHero:  txa
                ldx temp1
                sta heroList,x
                inc temp1
                tax
                dex
                bpl BCL_Loop
BCL_AllDone:    lda #$ff                        ;Store endmarks
                sta villainList,y
                ldx temp1
                sta heroList,x

                lda menuMode                    ;If levelup or pausemenu in progress,
                cmp #MENU_LEVELUPMSG            ;do not move actors
                bcc CheckRoute
UA_SkipUpdate:  jmp InterpolateActors

        ; Do route check for one AI actor at a time

CheckRoute:     ldx #ACTI_FIRSTNPC
                lda actT,x
                beq CR_NoCheck2
                ldy actAITarget,x
                bmi CR_NoCheck2
                lda actXH,x
                sta temp1
                lda actMB,x                     ;If actor is grounded, check 1 block higher
                eor #$01
                lsr
                lda actYH,x
                sbc #$00
                sta temp2
                lda actXH,y
                sta CR_CmpX+1
                lda actMB,y                     ;If actor is grounded, check 1 block higher
                eor #$01
                lsr
                lda actYH,y
                sbc #$00
                sta CR_CmpY+1
                sta CR_CmpY2+1
                lda #MAX_ROUTE_STEPS
                sta temp3
CR_Loop:        ldy temp1
CR_CmpX:        cpy #$00
                bcc CR_MoveRight
                bne CR_MoveLeft
                ldy temp2
CR_CmpY:        cpy #$00
                bcc CR_MoveDown
                bne CR_MoveUp
                lda #ROUTE_OK                   ;Route found
                bne CR_Done
CR_NoCheck2:    jmp CR_NoCheck
CR_MoveRight:   iny
                bcc CR_MoveXDone
CR_MoveLeft:    dey
CR_MoveXDone:   sty temp1
                ldy temp2
CR_CmpY2:       cpy #$00
                bcc CR_MoveDown
                beq CR_MoveYDone2
CR_MoveUp:      dey
                bcs CR_MoveYDone
CR_MoveDown:    iny
CR_MoveYDone:   sty temp2
CR_MoveYDone2:  dec temp3
                beq CR_NoRoute
                lda mapTblLo,y
                sta zpDestLo
                lda mapTblHi,y
                sta zpDestHi
                ldy temp1
                lda (zpDestLo),y                ;Take block from map
                tay
                lda blkTblLo,y
                sta zpDestLo
                lda blkTblHi,y
                sta zpDestHi
                ldy #2*4+2
                lda (zpDestLo),y                ;Get char from block (middle)
                tay
                lda charInfo,y                  ;Get charinfo
                and #CI_OBSTACLE
                beq CR_Loop
CR_NoRoute:     lda #ROUTE_FAIL                 ;Route not found
CR_Done:        sta actAIRoute,x
CR_NoCheck:     inx
                cpx #ACTI_LASTNPC+1
                bcc CR_NotOver
                ldx #ACTI_FIRSTNPC
CR_NotOver:     stx CheckRoute+1

        ; Call update routines of all on-screen actors

                ldx #MAX_ACT-1
UA_Loop:        ldy actT,x
                beq UA_Next
UA_NotZero:     stx actIndex
                lda actLogicTblLo-1,y           ;Get actor logic structure address
                sta actLo
                lda actLogicTblHi-1,y
                sta actHi
                lda actFlags,x                  ;Perform remove check?
                asl
                bmi UA_NoRemove
                lda actXH,x
UA_RALeftCheck: cmp #$00
                bcc UA_Remove
UA_RARightCheck:cmp #$00
                bcs UA_Remove
                lda actYH,x
UA_RATopCheck:  cmp #$00
                bcc UA_Remove
UA_RABottomCheck:
                cmp #$00
                bcc UA_NoRemove
UA_Remove:      jsr RemoveLevelActor
                jmp UA_Next
UA_NoRemove:    ldy #AL_UPDATEROUTINE
                lda (actLo),y
                sta UA_Jump+1
                iny
                lda (actLo),y
                sta UA_Jump+2
UA_Jump:        jsr $0000
UA_Next:        dex
                bpl UA_Loop

        ; Interpolate actors' movement each second frame

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
                bpl IA_SprLoop
                rts
IA_SprLoop:     lda sprC,x                      ;Process flickering
                cmp #COLOR_FLICKER
                bcc IA_NoFlicker
                eor #COLOR_INVISIBLE            ;If sprite is invisible on this frame,
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
        ; Modifies: A
        
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
        ; Modifies: A,Y,zpSrcLo

GetActorCharCoords:
                lda actYL,x
                rol
                rol
                rol
                and #$03
                sec
                sbc SL_CSSBlockY+1
                and #$03
                sta zpSrcLo
                lda actYH,x
                sbc SL_CSSMapY+1
                asl
                asl
                ora zpSrcLo
                tay
GetActorCharCoordX:
                lda actXL,x
                rol
                rol
                rol
                and #$03
                sec
                sbc SL_CSSBlockX+1
                and #$03
                sta zpSrcLo
                lda actXH,x
                sbc SL_CSSMapX+1
                asl
                asl
                ora zpSrcLo
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
                beq GCI_Outside
                sta zpDestHi
                lda mapTblLo,y
                sta zpDestLo
                ldy actXH,x
                cpy limitL
                bcc GCI_Outside
                cpy limitR
                bcs GCI_Outside
                lda (zpDestLo),y                ;Get block from map
                tay
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
GCI_Outside:    lda #CI_OBSTACLE                ;Return obstacle char if outside map
                rts

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
                bmi GCI_Outside

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

        ; Get actor's logic data address
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,actLo-actHi

GetActorLogicData:
                ldy actT,x
                lda actLogicTblLo-1,y
                sta actLo
                lda actLogicTblHi-1,y
                sta actHi
                rts

        ; Init actor: set initial health, color override, group & collision size
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,actLo-actHi

InitActor:      jsr GetActorLogicData
                ldy #AL_ACTORFLAGS
                lda (actLo),y
                sta actFlags,x
                lsr
                lsr
                iny
                lda (actLo),y
                sta actSizeH,x
                iny
                lda (actLo),y
                sta actSizeU,x
                iny
                lda (actLo),y
                sta actSizeD,x
                bcs IA_SkipHealthColor
                iny
                lda (actLo),y
                sta actHp,x
                iny
                lda (actLo),y
                sta actC,x
IA_SkipHealthColor:
                rts

        ; Check if two actors have collided. Actors further apart than 128 pixels
        ; are assumed to not collide, regardless of sizes
        ;
        ; Parameters: X,Y actor numbers
        ; Returns: C=1 if collided
        ; Modifies: A,temp8

CheckActorCollision:
                lda actXL,x
                sec
                sbc actXL,y
                sta temp8
                lda actXH,x
                sbc actXH,y
                lsr
                ror temp8
                lsr
                ror temp8
                cmp #$00
                beq CAC_XPos
                cmp #$3f
                bcs CAC_XNeg
                rts                             ;128 pixels or more apart in X-dir
CAC_XPos:       lsr
                lda temp8
                ror
                sbc actSizeH,x                  ;C=1
                bcc CAC_XOk
                sbc actSizeH,y
                bcc CAC_XOk
                clc                             ;Too far apart in X-dir
                rts
CAC_XNeg:       lsr
                lda temp8
                ror
                clc
                adc actSizeH,x
                bcs CAC_XOk2
                adc actSizeH,y
                bcs CAC_XOk2
                rts                             ;Too far apart in X-dir
CAC_XOk:        sec
CAC_XOk2:       lda actYL,x
                sbc actYL,y
                sta temp8
                lda actYH,x
                sbc actYH,y
                lsr
                ror temp8
                lsr
                ror temp8
                cmp #$00
                beq CAC_YPos
                cmp #$3f
                bcs CAC_YNeg
                rts                             ;128 pixels or more apart in Y-dir
CAC_YPos:       lsr
                lda temp8
                ror
                sbc actSizeU,x                  ;C=1
                bcc CAC_HasCollision
                sbc actSizeD,y
                bcc CAC_HasCollision
                clc                             ;Too far apart in Y-dir
                rts
CAC_YNeg:       lsr
                lda temp8
                ror
                clc
                adc actSizeD,x
                bcs CAC_HasCollision2
                adc actSizeU,y
                rts
CAC_HasCollision:
                sec
CAC_HasCollision2:
DA_Done:        rts

        ; Damage actor, and destroy if health goes to zero
        ;
        ; Parameters: A damage amount, X actor index, Y damage source actor if applicable or $ff if none
        ; Returns: -
        ; Modifies: A,Y,temp7-temp8,possibly other temp registers

DamageActor:    sty temp7
                sta temp8
                cpx #ACTI_PLAYER
                bne DA_NotPlayer
                if GODMODE_CHEAT>0
                lda actHp,x
                bne DA_NotDead
                endif
DA_HealthRechargeDelay:
                ldy #-HEALTH_RECHARGE_DELAY     ;If player hit, reset health recharge timer
                sty healthRecharge
DA_NotPlayer:   jsr GetActorLogicData
                ldy #AL_DMGMODIFY
                lda (actLo),y
                tay
                lda temp8
                jsr ModifyDamage
                tay                             ;Never reduce damage to zero with the damage
                bne DA_NotZeroDamage            ;modifier
                lda #$01
DA_NotZeroDamage:
                ldy temp7
                sta temp8
                lda actHp,x                     ;First check that there is health
                beq DA_Done                     ;(prevent destroy being called multiple times)
                sec
DA_Sub:         sbc temp8
                bcs DA_NotDead
                lda #$00
DA_NotDead:     sta actHp,x
                php
                lda actC,x                      ;Flash actor as a sign of damage
                ora #$f0
                sta actC,x
                lda #SFX_DAMAGE
                jsr PlaySfx
                plp
                bne DA_Done

        ; Call destroy routine of an actor
        ;
        ; Parameters: X actor index, Y damage source actor if applicable or $ff if none
        ; Returns: -
        ; Modifies: A,Y,temp8,possibly other temp registers

DestroyActor:   sty temp8
                lda #ORG_NONE                   ;If scrolled off the screen, do not return
                sta actLvlOrg,x
                jsr GetActorLogicData
                ldy #AL_DESTROYROUTINE
                lda (actLo),y
                sta DA_Jump+1
                iny
                lda (actLo),y
                sta DA_Jump+2
                ldy temp8                       ;Check if player is damage source and give XP
                bmi DA_Jump                     ;in that case
                lda actOrg,y
                bne DA_Jump
                ldy #AL_KILLXP
                lda (actLo),y
                jsr GiveXP
                ldy temp8
DA_Jump:        jmp $0000

        ; Add actor from leveldata
        ;
        ; Parameters: X leveldata index
        ; Returns: -
        ; Modifies: A,Y,temp vars,actor temp vars

AddLevelActor:  stx addActorIndex
                lda lvlActT,x
                bmi ALA_IsItem
ALA_IsNPC:      lda #ACTI_FIRSTNPC
                ldy #ACTI_LASTNPC
                jsr GetFreeActor
                bcc ALA_Fail
                lda lvlActF,x
                and #$0f
                sta actAIMode,y
                lda lvlActT,x
                sta actT,y
                lda lvlActWpn,x
                pha
                and #$7f
                sta actWpn,y
                pla
                sta actD,y
ALA_Common:     lda lvlActX,x
                sta actXH,y
                lda lvlActY,x
                sta actYH,y
                lda lvlActF,x
                pha
                and #$c0
                sta actYL,y
                pla
                asl
                asl
                and #$c0
                sta actXL,y
                txa                             ;Store leveldata origin
                sta actLvlOrg,y
                lda #$00                        ;Remove from leveldata
                sta lvlActT,x
                tya
                tax
                jsr InitActor
                ldx addActorIndex
ALA_Fail:       rts
ALA_IsItem:     lda #ACTI_FIRSTITEM
                ldy #ACTI_LASTITEM
                jsr GetFreeActor
                bcc ALA_Fail
                lda #ACT_ITEM
                sta actT,y
                lda lvlActT,x
                and #$7f
                sta actF1,y
                lda lvlActWpn,x
                cmp #DEFAULT_PICKUP
                bne ALA_NoDefaultPickup
                ldx actF1,y
                lda itemDefaultPickup-1,x
ALA_NoDefaultPickup:
                sta actHp,y
                ldx addActorIndex
                bpl ALA_Common

        ; Remove actor and return to leveldata if applicable
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,zpSrcLo

RemoveLevelActor:
                lda actT,x
                beq RA_Done
                ldy actLvlOrg,x                 ;Has leveldata origin?
                bmi RemoveActor
                sty RA_EndCmp+1
RA_Search:      lda lvlActT,y                   ;Look for empty space in leveldata
                beq RA_Found
                iny
                bpl RA_EndCmp
                ldy #$00
RA_EndCmp:      cpy #$00                        ;Keep searching until looped back
                bne RA_Search                   ;to the beginning
                beq RemoveActor
RA_Found:       lda actXH,x                     ;Store block coordinates
                sta lvlActX,y
                lda actYH,x
                sta lvlActY,y
                lda actXL,x                     ;Store char coordinates
                and #$c0
                lsr
                lsr
                sta zpSrcLo
                lda actYL,x
                and #$c0
                ora zpSrcLo
                cpx #MAX_COMPLEXACT
                bcs RA_SkipAIMode
                ora actAIMode,x
RA_SkipAIMode:  sta lvlActF,y
                lda actT,x                      ;Store actor type differently if
                cmp #ACT_ITEM                   ;item or NPC
                bne RA_StoreNPC
RA_StoreItem:   lda actF1,x
                ora #$80
                sta lvlActT,y
                lda actHp,x
                jmp RA_StoreCommon
RA_StoreNPC:    sta lvlActT,y
                lda actD,x
                and #$80
                ora actWpn,x
RA_StoreCommon: sta lvlActWpn,y

        ; Remove actor without returning to leveldata
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A

RemoveActor:    lda #ACT_NONE
                sta actT,x
                sta actHp,x                     ;Clear hitpoints so that bullet collision can not cause damage to an
RA_Done:        rts                             ;actor removed on the same frame (outdated collision list)

        ; Remove all actors except player back to leveldata
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X

RemoveLevelActors:ldx #MAX_ACT-1
RAA_Loop:       jsr RemoveLevelActor
                dex
                bne RAA_Loop
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
GFA_Found:      lda #$00                        ;Reset animation & speed when free actor found
                sta actF1,y
                sta actFd,y
                sta actSX,y
                sta actSY,y
                sta actC,y
                sta actMB,y
                sta actTime,y
                cpy #MAX_COMPLEXACT
                bcs GFA_NotComplex
                sta actF2,y
                sta actCtrl,y
                sta actMoveCtrl,y
                sta actPrevCtrl,y
                sta actWpn,y
                sta actAttackD,y
                sta actFall,y
                sta actFallL,y
                sta actAIHelp,y
                sta actAITarget,y
                sta actAIRoute,y
                lda #$ff
                sta actWpnF,y
                sta actAITarget,y               ;Start with no target
                sec
GFA_NotComplex: rts

        ; Spawn an actor without offset
        ;
        ; Parameters: A actor type, X creating actor, Y destination actor index
        ; Returns: -
        ; Modifies: A

SpawnActor:     sta actT,y
                lda actXL,x
                sta actXL,y
                lda actXH,x
                sta actXH,y
                lda actYL,x
                sta actYL,y
                lda actYH,x
                sta actYH,y
                rts

        ; Spawn an actor with X & Y offset
        ;
        ; Parameters: A actor type, X creating actor, Y destination actor index, temp5-temp6 X offset,
        ;             temp7-temp8 Y offset
        ; Returns: -
        ; Modifies: A

SpawnWithOffset:sta actT,y
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

        ; Get flicker color override for actor based on low bit of actor index
        ;
        ; Parameters: A actor index
        ; Returns: A color override value, either $40 or $c0
        ; Modifies: A

GetFlickerColorOverride:
                ror
                ror
                and #COLOR_INVISIBLE
                ora #COLOR_FLICKER
                rts

        ; Calculate distance to target actor in blocks
        ;
        ; Parameters: X actor index, Y target actor index
        ; Returns: temp5 X distance, temp6 abs X distance, temp7 Y distance, temp8 abs Y distance
        ; Modifies: A
        
GetActorDistance:
                lda actXL,y
                sec
                sbc actXL,x
                lda actXH,y
                sbc actXH,x
                sta temp5
                bpl GAD_XDistPos
                eor #$ff
GAD_XDistPos:   sta temp6
                lda actYL,y
                sec
                sbc actYL,x
                lda actYH,y
                sbc actYH,x
                sta temp7
                bpl GAD_YDistPos
                eor #$ff
GAD_YDistPos:   sta temp8
                rts
                