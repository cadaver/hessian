MAX_ACTX        = 14
MAX_ACTY        = 9

MAX_NEARTRIGGER_XDIST = 2
MAX_NEARTRIGGER_YDIST = 1

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
COLOR_ONETIMEFLASH = $ff

AL_UPDATEROUTINE = 0
AL_DESTROYROUTINE = 2
AL_ACTORFLAGS   = 4
AL_SIZEHORIZ    = 5
AL_SIZEUP       = 6
AL_SIZEDOWN     = 7
AL_INITIALHP    = 8
AL_DMGMODIFY    = 9
AL_SCORE        = 10
AL_SPAWNAIMODE  = 12
AL_DROPITEMINDEX = 13
AL_OFFENSE      = 14
AL_DEFENSE      = 15
AL_MOVEFLAGS    = 16
AL_MOVESPEED    = 17
AL_GROUNDACCEL  = 18
AL_INAIRACCEL   = 19
AL_FALLACCEL    = 20                           ;Gravity acceleration
AL_LONGJUMPACCEL = 21                          ;Gravity acceleration in longjump
AL_BRAKING      = 22
AL_HEIGHT       = 23                           ;Height for headbump check, negative
AL_JUMPSPEED    = 24                           ;Negative
AL_CLIMBSPEED   = 25

AL_XMOVESPEED   = 16
AL_XACCEL       = 17
AL_YMOVESPEED   = 18
AL_YACCEL       = 19
AL_XCHECKOFFSET = 20
AL_YCHECKOFFSET = 21

GRP_HEROES      = $00
GRP_ENEMIES     = $01
GRP_BEASTS      = $02

AF_GROUPBITS    = $07
AF_INITONLYSIZE = $08
AF_ISORGANIC    = $10
AF_USETRIGGERS  = $20
AF_NOWEAPON     = $40
AF_NOREMOVECHECK = $80

AMF_JUMP        = $01
AMF_DUCK        = $02
AMF_CLIMB       = $04
AMF_ROLL        = $08
AMF_WALLFLIP    = $10
AMF_NOFALLDAMAGE = $20

ADDACTOR_LEFT_LIMIT = 1
ADDACTOR_RIGHT_LIMIT = 11
ADDACTOR_BOTTOM_LIMIT = 8

ORG_TEMP        = $00                           ;Temporary actor, may be overwritten by global or leveldata
ORG_GLOBAL      = $40                           ;Global important actor
ORG_LEVELDATA   = $80                           ;Leveldata actor, added/removed at level change
ORG_LEVELNUM    = $3f

POS_NOTPERSISTENT = $80

DEFAULT_PICKUP  = $ff

LVLOBJSEARCH    = 32
LVLACTSEARCH    = 32

NODAMAGESRC     = $80
NOPLOTBIT       = $80

SPAWNINFRONT_PROBABILITY = $c0

SPAWN_GROUND    = $00
SPAWN_AIR       = $80
SPAWN_AIRTOP    = $c0

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
                beq DA_ActorDone2
                if SHOW_ACTOR_TIME > 0
                lda #$02
                sta $d020
                endif
                lda actDispTblHi-1,y            ;Zero display address = invisible
                beq DA_ActorDone
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
                if OPTIMIZE_SPRITECOORDS = 0
                sta temp4
                else
                bne DA_ActorDone                ;Skip if Y coord MSB nonzero
                endif
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
                stx actIndex
                jsr DrawActorSub
                stx sprIndex
                ldx actIndex
DA_ActorDone:   if SHOW_ACTOR_TIME > 0
                lda #$00
                sta $d020
                endif
DA_ActorDone2:  inx
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

DA_HitFlash:    inc actFlash,x
                lda #$01
                bne DA_NoFlicker

DrawActorSub:   lda actFlash,x                  ;Get programmatic color override
                bmi DA_HitFlash                 ;including one frame hit flash
                cmp #COLOR_FLICKER
                bcc DA_NoFlicker
                txa                             ;Use actor index low bit to determine
                and #$01
                lsr                             ;which sprites flicker this frame
                ror
                ora #COLOR_FLICKER
DA_NoFlicker:   sta GASS_ColorOr+1
                ldy #$0f
                and #$0f
                beq DA_KeepSpriteColor
                ldy #$00
DA_KeepSpriteColor:
                sty GASS_ColorAnd+1
DrawActorSub_NoColor:
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
DA_SameSprFile: ldy #AD_NUMSPRITES              ;Get number of sprites / humanoid flag
                clc
                lda (actLo),y
                bpl DA_Normal

DA_Humanoid:    lda actWpnF,x
                sta DA_HumanWpnF+1
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
                sta temp5
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
DA_SameSprFile2:lda temp5
                jsr GetAndStoreSprite
DA_HumanWpnF:   lda #$00
                cmp #NOWEAPONFRAME
                beq DA_HumanNoWeapon
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
DA_NormalLast:  jmp GetAndStoreSprite

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
                bmi DA_NormalLast
                jsr GetAndStoreSprite
                ldy #AD_NUMFRAMES
                lda temp6                       ;Advance framepointer
                clc
                adc (actLo),y
                sta temp6
                bcc DA_NormalLoop
DA_HumanNoWeapon:
                rts

        ; Set all actors to be added on screen. Used on level transitions
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A

AddAllActorsNextFrame:
                lda #$00
                sta AA_Start+1
                lda #MAX_LVLACT
                sta AA_EndCmp+1
AA_Paused:      rts

        ; Add actors to screen and perform other miscellaneous tasks, like spawners and navigation AI
        ; Do nothing if game paused
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp regs

AddActors:      lda menuMode
                cmp #MENU_PAUSE
                bcs AA_Paused

        ; Get screen border map coordinates for adding/removing actors

GetActorBorders:lda mapX                        ;Calculate borders for add/removechecks
                sbc #ADDACTOR_LEFT_LIMIT-1      ;C=0 here
                bcs GAB_LeftOK1
                lda #$00
GAB_LeftOK1:    cmp limitL
                bcs GAB_LeftOK2
                lda limitL
GAB_LeftOK2:    sta UA_RALeftCheck+1            ;Left border
                sta AA_LeftCheck+1
                lda mapX
                clc
                adc #ADDACTOR_RIGHT_LIMIT
                bcc GAB_RightOK1
                lda #$ff
GAB_RightOK1:   cmp limitR
                bcc GAB_RightOK2
                lda limitR
GAB_RightOK2:   sta UA_RARightCheck+1           ;Right border
                sta AA_RightCheck+1
                lda mapY
GAB_TopOK1:     cmp limitU
                bcs GAB_TopOK2
                lda limitU
GAB_TopOK2:     sta AA_TopCheck+1
                lda mapY
                clc
                adc #ADDACTOR_BOTTOM_LIMIT
                bpl GAB_BottomOK1
                lda #$7f
GAB_BottomOK1:  cmp limitD
                bcc GAB_BottomOK2
                lda limitD
GAB_BottomOK2:  sta UA_RABottomCheck+1          ;Bottom border
                sta AA_BottomCheck+1

        ; Add actors from leveldata to screen

AA_Start:       ldx #$00
AA_Loop:        lda lvlActT,x
                beq AA_Skip
                lda lvlActOrg,x                 ;Must be either a current level's leveldata actor,
                bmi UA_LevelOK                  ;or a global/temp actor with matching level
                and #ORG_LEVELNUM
                cmp levelNum
                bne AA_Skip
UA_LevelOK:     lda lvlActX,x
AA_LeftCheck:   cmp #$00
                bcc AA_Skip
AA_RightCheck:  cmp #$00
                bcs AA_Skip
                lda lvlActY,x
AA_TopCheck:    cmp #$00
                bcc AA_Skip
AA_BottomCheck: cmp #$00
                bcs AA_Skip
                jsr AddLevelActor
                ldx temp1
AA_Skip:        inx
AA_EndCmp:      cpx #LVLACTSEARCH
                bne AA_Loop
                cpx #MAX_LVLACT
                bcc AA_IndexNotOver
                ldx #$00
                clc
AA_IndexNotOver:stx AA_Start+1
                txa
                adc #LVLACTSEARCH
                sta AA_EndCmp+1

        ; Process spawning

UA_DoSpawn:     lda numTargetsAll               ;Skip if already max. spawned enemies + player
                cmp #MAX_SPAWNEDACT+1
                bcs UA_SpawnDone
                ldy #ZONEH_SPAWNCOUNT
                lda (zoneLo),y
                bmi UA_NoSpawnLimit             ;Negative spawncount = unlimited
UA_SpawnCount:  cmp #$00
                if SPAWN_TEST=0
                beq UA_SpawnDone
                endif
UA_NoSpawnLimit:dey
UA_SpawnDelay:  lda #$00                        ;Spawn delay counting
                clc
                adc (zoneLo),y
                sta UA_SpawnDelay+1
                if SPAWN_TEST=0
                bcc UA_SpawnDone
                endif
                dey
                lda (zoneLo),y                  ;Take global spawnlist parameter
                tay
                jsr Random
                and spawnListAndTbl,y
                clc
                adc spawnListAddTbl,y
                jsr AttemptSpawn
UA_SpawnDone:

        ; Build target list for AI & bullet collision

BuildTargetList:ldx #ACTI_LASTNPC
                ldy #$00                        ;Target list index
                sty numTargetsAll
BTL_Loop:       lda actT,x
                beq BTL_Next
                inc numTargetsAll               ;Count alive + dead for spawning
                lda actHp,x                     ;Actor must have nonzero health
                beq BTL_Next
                txa
                sta targetList,y
                iny
BTL_Next:       dex
                bpl BTL_Loop
                lda #$ff                        ;Store endmark
                sta targetList,y
                sty numTargets

        ; Check AI navigation/attack hints for one actor at a time

CN_Current:     ldx #ACTI_FIRSTNPC
CN_Loop:        dex
                bne CN_NotOver
                ldx #ACTI_LASTNPC
CN_NotOver:     lda actT,x
                beq CN_Next
                ldy actAITarget,x
                bpl CN_Found
CN_Next:        cpx CN_Current+1                ;Wrap search without finding a valid actor?
                bne CN_Loop
                beq CN_Done
CN_Found:       stx CN_Current+1
                jmp LineCheck
CN_Done:        rts

        ; Call update routines of all actors, then interpolate. If game is paused, only interpolate
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,actor temp vars

UA_Paused:      ldx #$00                        ;Stop scrolling & level animation when paused
                stx scrollSX                    ;and only interpolate
                stx scrollSY
                jmp InterpolateActors

UpdateActors:   lda menuMode
                cmp #MENU_PAUSE
                bcs UA_Paused
                inc UA_ItemFlashCounter+1
UA_ItemFlashCounter:                            ;Get color override for items + object marker
                lda #$00
                lsr
                lsr
                and #$03
                tax
                lda itemFlashTbl,x
                sta FlashActor+1
                and #$07
                tax
                lda panelScreen+PANELROW*40+9
                cmp #"H"
                bne UA_NoHealthBarFlash
                txa
                ldy actHp+ACTI_PLAYER           ;Flash the H & C letters if health or battery low
                cpy #LOW_HEALTH+1
                bcc UA_FlashHealth
                lda #$01
UA_FlashHealth: sta colors+PANELROW*40+9
                txa
                ldy battery+1
                cpy #LOW_BATTERY+1
                bcc UA_FlashBattery
                lda #$01
UA_FlashBattery:sta colors+PANELROW*40+23
UA_NoHealthBarFlash:
                ldx #MAX_ACT-1
UA_Loop:        ldy actT,x
                beq UA_Next
UA_NotZero:     stx actIndex
                lda actLogicTblLo-1,y           ;Get actor logic structure address
                sta actLo
                lda actLogicTblHi-1,y
                sta actHi
                lda actFlags,x                  ;Perform remove check?
                bmi UA_NoRemove
                lda actXH,x
UA_RALeftCheck: cmp #$00
                bcc UA_Remove
UA_RARightCheck:cmp #$00
                bcs UA_Remove
                lda actYH,x
                cmp mapY
                bcc UA_Remove
UA_RABottomCheck:
                cmp #$00
                bcc UA_NoRemove
UA_Remove:      jsr RemoveLevelActor
                beq UA_Next                     ;A=0 on return
UA_NoRemove:    if SHOW_ACTOR_TIME > 0
                lda #$0a
                sta $d020
                endif
                ldy #AL_UPDATEROUTINE
                lda (actLo),y
                sta UA_Jump+1
                iny
                lda (actLo),y
                sta UA_Jump+2
                cpx #MAX_COMPLEXACT             ;Run AI for NPCs
                bcs UA_Jump
                lda actCtrl,x
                sta actPrevCtrl,x
                ldy actAIMode,x
                lda aiJumpTblLo,y
                sta UA_AIJump+1
                lda aiJumpTblHi,y
                sta UA_AIJump+2
UA_AIJump:      jsr $0000
UA_Jump:        jsr $0000
                if SHOW_ACTOR_TIME > 0
                lda #$00
                sta $d020
                endif
UA_Next:        dex
                bpl UA_Loop

        ; Interpolate actors' movement each second frame

InterpolateActors:
                stx Irq4_LevelUpdate+1          ;Enable/disable level char animation
                lda scrollX
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
IA_Done:        rts

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

        ; Move actor in negated X-direction
        ;
        ; Parameters: X actor index, A speed
        ; Returns: -
        ; Modifies: A

MoveActorXNeg:  eor #$ff
                clc
                adc #$01

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

        ; Move actor in negated Y-direction
        ;
        ; Parameters: X actor index, A speed
        ; Returns: -
        ; Modifies: A

MoveActorYNeg:  eor #$ff
                clc
                adc #$01

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

        ; Accelerate actor in X-direction with either positive or negative acceleration
        ;
        ; Parameters: X actor index, A absolute acceleration, Y absolute speed limit, C direction (0 = right, 1 = left)
        ; Returns:
        ; Modifies: A,Y,temp8

AccActorXNegOrPos:
                bcc AccActorXNoClc

        ; Accelerate actor in negative X-direction
        ;
        ; Parameters: X actor index, A absolute acceleration, Y absolute speed limit
        ; Returns:
        ; Modifies: A,Y,temp8

AccActorXNeg:   sec
AccActorXNegNoSec:
                sty temp8
                sbc actSX,x
                bmi AAX_NegDone
                cmp temp8
                bcc AAX_NegDone2
                tya
AAX_NegDone:    clc
AAX_NegDone2:   eor #$ff
                adc #$01
AAX_Done:       sta actSX,x
AAX_Done2:      rts

        ; Accelerate actor in positive X-direction
        ;
        ; Parameters: X actor index, A acceleration, Y speed limit
        ; Returns: -
        ; Modifies: A,temp8

AccActorX:      clc
AccActorXNoClc: sty temp8
                adc actSX,x
                bmi AAX_Done                    ;If speed negative, can not have reached limit yet
                cmp temp8
                bcc AAX_Done
                tya
                bcs AAX_Done

        ; Brake X-speed of an actor towards zero
        ;
        ; Parameters: X Actor index, A deceleration (always positive)
        ; Returns: -
        ; Modifies: A, temp8

BrakeActorX:    sta temp8
                lda actSX,x
                beq AAX_Done2
                bmi BAct_XNeg
BAct_XPos:      sec
                sbc temp8
                bpl AAX_Done
BAct_XZero:     lda #$00
                beq AAX_Done
BAct_XNeg:      clc
                adc temp8
                bpl BAct_XZero
                bmi AAX_Done

        ; Accelerate actor in Y-direction with either positive or negative acceleration
        ;
        ; Parameters: X actor index, A absolute acceleration, Y absolute speed limit, C direction (0 = down, 1 = up)
        ; Returns:
        ; Modifies: A,Y,temp8

AccActorYNegOrPos:
                bcc AccActorYNoClc

        ; Accelerate actor in negative Y-direction
        ;
        ; Parameters: X actor index, A absolute acceleration, Y absolute speed limit
        ; Returns:
        ; Modifies: A,Y,temp8

AccActorYNeg:   sec
AccActorYNegNoSec:
                sty temp8
                sbc actSY,x
                bmi AAY_NegDone
                cmp temp8
                bcc AAY_NegDone2
                tya
AAY_NegDone:    clc
AAY_NegDone2:   eor #$ff
                adc #$01
AAY_Done:       sta actSY,x
AAY_Done2:      rts

        ; Accelerate actor in positive Y-direction
        ;
        ; Parameters: X actor index, A acceleration, Y speed limit
        ; Returns: -
        ; Modifies: A,temp8

AccActorY:      clc
AccActorYNoClc: sty temp8
                adc actSY,x
                bmi AAY_Done                    ;If speed negative, can not have reached limit yet
                cmp temp8
                bcc AAY_Done
                tya
                bcs AAY_Done

        ; Brake Y-speed of an actor towards zero
        ;
        ; Parameters: X Actor index, A deceleration (always positive)
        ; Returns: -
        ; Modifies: A, temp8

BrakeActorY:    sta temp8
                lda actSY,x
                beq AAY_Done2
                bmi BAct_YNeg
BAct_YPos:      sec
                sbc temp8
                bpl AAY_Done
BAct_YZero:     lda #$00
                beq AAY_Done
BAct_YNeg:      clc
                adc temp8
                bpl BAct_YZero
                bmi AAY_Done

        ; Process animation delay
        ;
        ; Parameters: X actor index, A animation speed-1 (in frames)
        ; Returns: C=1 delay exceeded, animationdelay reset
        ; Modifies: A

AnimationDelay: sta AD_Cmp+1
                lda actFd,x
AD_Cmp:         cmp #$00
                bcs AD_Over
                inc actFd,x
                rts

        ; Perform one-shot animation with delay
        ;
        ; Parameters: Y end frame, A animation speed-1 (in frames)
        ; Returns: C=1 end reached
        ; Modifies: A

OneShotAnimation:
                sta OSA_Cmp+1
                sty OSA_FrameCmp+1
                lda actFd,x
OSA_Cmp:        cmp #$00
                bcs OSA_NextFrame
                inc actFd,x
                rts
OSA_NextFrame:  lda actF1,x
OSA_FrameCmp:   cmp #$00
                bcs AD_Over
                inc actF1,x
AD_Over:        lda #$00
                sta actFd,x
                rts

        ; Get char collision info from 1 block above or below actor's pos (optimized)
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,Y,loader temp vars

GetCharInfo4Below:
                ldy actYH,x
                iny
                jmp GCI_Common

GetCharInfo4Above:
                ldy actYH,x
                dey
                jmp GCI_Common

        ; Get char collision info from 1 char above actor's pos (optimized)
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,Y,loader temp vars

GetCharInfo1Above:
                ldy actYH,x
                lda actYL,x
                sec
                sbc #$40
                bcs GCI_Common2
                dey
                bcc GCI_Common2

        ; Get char collision info from 1 char below actor's pos (optimized)
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,Y,loader temp vars

GetCharInfo1Below:
                ldy actYH,x
                lda actYL,x
                clc
                adc #$40
                bcc GCI_Common2
                iny
                bcs GCI_Common2

        ; Get char collision info from the actor's position
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,Y,loader temp vars

GetCharInfo:    ldy actYH,x
GCI_Common:     lda actYL,x
GCI_Common2:    and #$c0
                sta zpBitsLo
                lda actXH,x
                sta zpBitsHi
                lda actXL,x
GCI_Common3:    lsr
                lsr
                ora zpBitsLo
                lsr
                lsr
                lsr
                lsr
                cpy limitU
                bcc GCI_Outside
GCI_Optimized:  cpy limitD
                bcc GCI_NoLimitDown
                ldy limitD
                dey
                ora #$0c
GCI_NoLimitDown:sta zpBitsLo
                lda mapTblLo,y
                sta zpDestLo
                lda mapTblHi,y
                sta zpDestHi
                ldy zpBitsHi
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
                ldy zpBitsLo
                lda (zpDestLo),y                ;Get char from block
                tay
                lda charInfo,y                  ;Get charinfo
                rts
GCI_Outside:    lda #CI_OBSTACLE                ;Return obstacle outside zone left, right, above
                rts

GetCharInfoOptimizedAfter1Above:
                ldy actYH,x
                lda zpBitsLo
                clc
                adc #$04
                and #$0f
                bpl GCI_Optimized

        ; Get char collision info from the actor's position with Y offset
        ;
        ; Parameters: X actor index, A signed Y offset in chars
        ; Returns: A charinfo
        ; Modifies: A,Y,loader temp vars

GetCharInfoOffset:
                ldy actXH,x
                sty zpBitsHi
                ldy actXL,x
                sty zpBitBuf
GCIO_Common:    tay
                ror
                ror
                ror
                and #$c0
                clc
                adc actYL,x
                and #$c0
                sta zpBitsLo
                php
                tya
                lsr
                lsr
                cpy #$80
                bcc GCIO_NotNeg
                ora #$c0
GCIO_NotNeg:    plp
                adc actYH,x
                tay
                lda zpBitBuf
                jmp GCI_Common3

        ; Get char collision info from the actor's position with both X & Y offset
        ;
        ; Parameters: X actor index, A signed Y offset in chars, Y signed X offset in chars
        ; Returns: A charinfo
        ; Modifies: A,Y,loader temp vars

GetCharInfoXYOffset:
                pha
                tya
                ror
                ror
                ror
                and #$c0
                clc
                adc actXL,x                     ;Final X coord lo
                sta zpBitBuf
                php
                tya
                lsr
                lsr
                cpy #$80
                bcc GCIOXY_XNotNeg
                ora #$c0
GCIOXY_XNotNeg: plp
                adc actXH,x
                sta zpBitsHi                    ;Final X coord hi
                ldy zpBitBuf
                pla
                jmp GCIO_Common

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
                and #AF_INITONLYSIZE
                php
                iny
                lda (actLo),y
                sta actSizeH,x
                iny
                lda (actLo),y
                sta actSizeU,x
                iny
                lda (actLo),y
                sta actSizeD,x
                plp
                bne IA_SkipHealth
                iny
                lda (actLo),y
                sta actHp,x
IA_SkipHealth:  rts

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
DS_Alive:
                rts

        ; Apply damage to self, and do not return if killed. To be called from move routines
        ;
        ; Parameters: A damage amount, X actor index
        ; Returns: C=1 if actor is alive, does not return if killed
        ; Modifies: A,Y,temp7-temp8,possibly other temp registers

ApplyFallDamage:tya
                sec
                sbc #DAMAGING_FALL_DISTANCE
                bcc NoFallDamage
                beq NoFallDamage
                asl
                asl
                ora #$80
DamageSelf:     ldy #NODAMAGESRC
                jsr DamageActor
                bcs DS_Alive
                pla
                pla
NoFallDamage:
ATD_Skip:       rts

        ; Modify damage based on whether target is organic/nonorganic, then apply
        ;
        ; Parameters: X bullet actor Y target actor
        ; Returns: A modified damage
        ; Modifies: A,X,Y,temp7,temp8,loader temp vars

ApplyTargetDamage:
                lda actBulletDmgMod-ACTI_FIRSTPLRBULLET,x ;Damage modifier
                sta temp7
                lda actHp,x                     ;Amount of damage
                sta temp8
                lda actFlags,y                  ;Check if target is organic
                and #AF_ISORGANIC
                beq ATD_NonOrganic
ATD_Organic:    lda temp7
                and #$0f
                bpl ATD_Common
ATD_NonOrganic: lda temp7
                lsr
                lsr
                lsr
                lsr
ATD_Common:     tay
                beq ATD_Skip                    ;Skip if multiplier zero now
                lda temp8
                jsr ModifyDamage
                ldx tgtActIndex
                ldy actIndex

        ; Damage actor, and destroy if health goes to zero
        ;
        ; Parameters: A damage amount (>= $80 skip modify), X actor index, Y damage source actor if applicable or >=$80 if none
        ; Returns: C=1 if actor is alive, C=0 if killed
        ; Modifies: A,Y,temp7-temp8,zpSrcLo,possibly other temp registers

DamageActor:    sty temp7
                sta temp8
                tay
                bpl DA_UseModify                ;Unmodified damage (drowning, falling)
                and #$7f                        ;will not involve player's armor
                bpl DA_SkipModify
DA_UseModify:   txa
                bne DA_NoPlayerArmor
                ldy #ITEM_ARMOR
                lda invCount-1,y                ;Check player armor
                bmi DA_NoPlayerArmor
                pha
                lda #5                          ;Round the armor strength reduction to next 5
DA_NextMultiplyOf5:
                cmp temp8
                bcs DA_ReduceOK
                adc #5
                bcc DA_NextMultiplyOf5
DA_ReduceOK:    jsr DecreaseAmmo
                lda #INVENTORY_TEXT_DURATION    ;Show decreased armor level in the status
                sta armorMsgTime                ;panel center (same as oxygen meter)
                pla
                cmp temp8                       ;Can reduce damage fully, or partially?
                bcc DA_NotFullReduce
                lda temp8
DA_NotFullReduce:lsr                            ;Reduce max. half of the damage to health
                eor #$ff
                sec
                adc temp8
                sta temp8
DA_NoPlayerArmor:
                jsr GetActorLogicData
                ldy #AL_DMGMODIFY
                lda (actLo),y
                tay
                lda temp8
                jsr ModifyDamage
DA_SkipModify:  sta temp8
                txa
                bne DA_NotPlayer
DA_ResetRecharge:
                if GODMODE_CHEAT = 0
                stx healTimer                   ;If player hit, reset healing timer
                else
                stx temp8
                endif
DA_NotPlayer:   lda actHp,x                     ;First check that there is health
                beq DA_Done                     ;(prevent destroy being called multiple times)
                sec
DA_Sub:         sbc temp8
                bcs DA_NotDead
                lda #$00
DA_NotDead:     sta actHp,x
                php
                lda #COLOR_ONETIMEFLASH
                sta actFlash,x
                lda #SFX_DAMAGE
                jsr PlaySfx
                plp
                bne DA_Done
                ldy temp7

        ; Call destroy routine of an actor
        ;
        ; Parameters: X actor index, Y damage source actor if applicable or >=$80 if none
        ; Returns: C=0
        ; Modifies: A,Y,possibly temp registers

DestroyActor:   sty DA_DamageSrc+1
                cpy #ACTI_FIRSTNPCBULLET
                jsr GetActorLogicData
                ldy #AL_DESTROYROUTINE
                lda (actLo),y
                sta DA_Jump+1
                iny
                lda (actLo),y
                sta DA_Jump+2
                bcs DA_NoScore
                ldy #AL_SCORE
                lda (actLo),y
                pha
                iny
                lda (actLo),y
                tay
                pla
                jsr AddScore
DA_NoScore:     ldy #AT_DESTROY                 ;Run the DESTROY trigger
                jsr ActorTrigger
DA_DamageSrc:   ldy #$00
DA_Jump:        jsr $0000
                clc
DA_Done:
AS_Done2:       rts

        ; Attempt to spawn an actor to screen edges (left, right or top, depending on spawn type)
        ;
        ; Parameters: A spawnlist index
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

AS_InAir:       asl
                lda #$00
                sta temp3
                bcs AS_InAirTop
AS_InAirSide:   lda #$80                        ;Middle of block
                sta actYL,y
                jmp AS_SideCommon
AS_InAirTop:    jsr Random
                pha
                asl
                and #$c0
                sta actXL,y
                ror
                sta actD,y                      ;Randomize direction
                pla
                and #$0f
                cmp #$0a
                bcc AS_InAirCoordOK
                sbc #$07
AS_InAirCoordOK:sec
                adc AA_LeftCheck+1
                sta actXH,y
                lda mapY
                sta actYH,y
                bpl AS_CheckBackground

AttemptSpawn:   sta temp2
                tax
                lda spawnPlotTbl,x              ;Requires a plotbit to spawn?
                bmi AS_NoPlotBit
                jsr GetPlotBit
                beq AS_Done2
AS_NoPlotBit:   jsr GetFreeNPC
                bcc AS_Done2
                lda #$00
                sta actYL,y
                ldx temp2
                lda spawnTypeTbl,x
                sta actT,y
                lda spawnWpnTbl,x
                pha
                and #$3f
                sta actWpn,y
                pla
                asl
                bcs AS_InAir
AS_Ground:      lda #CI_GROUND
                sta temp3
AS_SideCommon:  jsr Random
                and #$07
                cmp #$06
                bcc AS_SideYOK
                sbc #$03
                clc
AS_SideYOK:     adc mapY
                sta actYH,y
                jsr Random
                cmp #SPAWNINFRONT_PROBABILITY   ;Prefer to spawn in front of player
                lda actD+ACTI_PLAYER
                bcc AS_SideNoReverse
                eor #$80
AS_SideNoReverse:
                asl
                bcc AS_GroundRight
AS_GroundLeft:  lda AA_LeftCheck+1
                ldx #$3f
                bne AS_GroundStorePosDir
AS_GroundRight: lda AA_RightCheck+1
                sbc #$00                         ;C=0 here
                ldx #$c0
AS_GroundStorePosDir:
                cmp actXH+ACTI_PLAYER            ;Do not spawn exactly at player
                beq AS_Remove2
                sta actXH,y
                txa
                sta actXL,y
                sta actD,y
AS_CheckBackground:
                tya
                tax
AS_BGRetry:     jsr GetCharInfo
                and #CI_GROUND|CI_OBSTACLE|CI_NOPATH|CI_NOSPAWN
                cmp temp3
                beq AS_BGOK
                lda temp3                       ;If trying to match ground, retry all sub-positions
                lsr                             ;within block
                bcc AS_Remove
                lda #8*8
                jsr MoveActorY
                lda actYL,x
                bne AS_BGRetry
                beq AS_Remove

AS_BGOK:        jsr GetCharInfo1Above           ;Do not spawn into a wall
                and #CI_OBSTACLE
                bne AS_Remove
AS_SpawnOK:     jsr InitActor
                inc UA_SpawnCount+1
                ldy #AL_SPAWNAIMODE
                lda (actLo),y                   ;Set default AI mode for actor type
                sta actAIMode,x
                lda #POS_NOTPERSISTENT          ;Spawned actors never persistent (disappear at zone change)
                bmi AS_StoreLvlDataPos

        ; Set persistence mode for a newly created actor
        ;
        ; Parameters: A temporary/global bit, X actor index
        ; Returns: -
        ; Modifies: A

SetPersistence: ora levelNum
                sta actLvlDataOrg,x
                jsr GetNextTempLevelActorIndex  ;Persist as a temporary actor
AS_StoreLvlDataPos:
                sta actLvlDataPos,x
ALA_Fail2:      rts

AS_Remove2:     tya
                tax
AS_Remove:      jmp RemoveActor                 ;Spawned into wrong background type, remove

        ; Add actor from leveldata
        ;
        ; Parameters: X leveldata index
        ; Returns: temp1 stored value of X
        ; Modifies: A,X,Y,temp vars,actor temp vars

AddLevelActor:  stx temp1
                lda lvlActT,x
                bpl ALA_IsNPC
                jmp ALA_IsItem
ALA_IsNPC:      jsr GetFreeNPC
                bcc ALA_Fail2
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
                txa                             ;Store index, ideally same index will be used for removal
                sta actLvlDataPos,y
                lda #$00                        ;Remove from leveldata
                sta lvlActT,x
                lda lvlActOrg,x                 ;Store the persistence mode (leveldata/global/temp)
                sta actLvlDataOrg,y
                tya
                tax
                jsr InitActor
                cpx #ACTI_FIRSTITEM
                bcc ALA_NotItem
                jsr GetCharInfo                 ;For items, check whether it's standing on a shelf/in a
                and #CI_SHELF                   ;weapon closet, and make it grounded in that case
                beq ALA_NotItem
                lda #MB_GROUNDED
                sta actMB,x
ALA_NotItem:    ldy #AL_MOVEFLAGS               ;If the actor can climb and has been spawned in the middle
                lda (actLo),y                   ;of a ladder (and no ground), init climbing mode
                and #AMF_CLIMB                  ;Otherwise the actor will likely fall to death, as we have
                beq ALA_NoInitClimb             ;falling damage
                jsr GetCharInfo
                and #CI_GROUND|CI_CLIMB
                cmp #CI_CLIMB
                bne ALA_NoInitClimb
                jsr MH_InitClimb
ALA_NoInitClimb:ldy #AT_ADD                     ;Run the ADD trigger routine
                jmp ActorTrigger
ALA_Fail:       rts
ALA_Cancel:     jmp AS_Remove2
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
                ldx temp1
                jmp ALA_Common

        ; Remove all actors except player to leveldata if applicable
        ;
        ; Parameters: -
        ; Returns: X=0
        ; Modifies: A,X,Y,zpSrcLo

RemoveLevelActors:
                ldx #MAX_ACT-1
RLA_Loop:       lda actT,x
                beq RLA_Next
                jsr RemoveLevelActor
RLA_Next:       dex
                bne RLA_Loop
                rts

        ; Remove actor and return to leveldata if applicable
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,zpSrcLo

RemoveLevelActor:
                cpx #MAX_PERSISTENTACT          ;Should be persisted?
                bcs RemoveActor
                ldy actLvlDataPos,x
                bmi RemoveActor
                jsr GetLevelActorIndex
                lda actXH,x                     ;Store block coordinates
                sta lvlActX,y
                lda actYH,x
                sta lvlActY,y
                lda actLvlDataOrg,x             ;Store levelnumber / persistence mode
                sta lvlActOrg,y
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
                ldy #AT_REMOVE                  ;Run the REMOVE trigger routine
                jsr ActorTrigger

        ; Remove actor without returning to leveldata
        ;
        ; Parameters: X actor index
        ; Returns: A=0
        ; Modifies: A

RemoveActor:    lda #ACT_NONE
                sta actT,x
                sta actHp,x                     ;Clear hitpoints so that bullet collision can not cause damage to an
                sta actFlags,x                  ;actor removed on the same frame (outdated collision list)
RA_Done:        rts

        ; Get a free actor
        ;
        ; Parameters: A first actor index to check (do not pass 0 here), Y last actor index to check
        ; Returns: C=1 free actor found (returned in Y), C=0 no free actor
        ; Modifies: A,Y

GetFreeNPC:     lda #ACTI_FIRSTNPC
                ldy #ACTI_LASTNPC
GetFreeActor:   sta GFA_Cmp+1
GFA_Loop:       lda actT,y
                beq GFA_Found
                dey
GFA_Cmp:        cpy #$00
                bcs GFA_Loop
                rts
GFA_Found:      lda #$00                        ;Reset most actor variables
                sta actF1,y
                sta actFd,y
                sta actSX,y
                sta actSY,y
                sta actFlash,y
                sta actMB,y
                sta actTime,y
                cpy #MAX_COMPLEXACT
                bcs GFA_NotComplex
                sta actF2,y
                sta actCtrl,y
                sta actMoveCtrl,y
                sta actPrevCtrl,y
                sta actAttackD,y
                sta actFall,y
                sta actFallL,y
                sta actAIHelp,y
                sta actLastNavStairs,y
                sta actLastNavLadder,y
                lda #NOTARGET
                sta actWpnF,y
                sta actAITarget,y               ;Start with no target
                sec
GFA_NotComplex: rts

        ; Spawn an actor without offset
        ;
        ; Parameters: A actor type, X creating actor, Y destination actor index
        ; Returns: -
        ; Modifies: A,temp1-temp4

SpawnActor:     sta actT,y
                lda #$00
                sta temp1
                sta temp2
                sta temp3
                sta temp4
                beq SWO_SetCoords

        ; Spawn an actor with X & Y offset
        ;
        ; Parameters: A actor type, X creating actor, Y destination actor index, temp1-temp2 X offset,
        ;             temp3-temp4 Y offset
        ; Returns: -
        ; Modifies: A

SpawnWithOffset:sta actT,y
SWO_SetCoords:  lda actXL,x
                clc
                adc temp1
                sta actXL,y
                sta actPrevXL,y
                lda actXH,x
                adc temp2
                sta actXH,y
                sta actPrevXH,y
                lda actYL,x
                clc
                adc temp3
                sta actYL,y
                sta actPrevYL,y
                lda actYH,x
                adc temp4
                sta actYH,y
                sta actPrevYH,y
                rts

        ; Calculate distance to target actor in blocks
        ;
        ; Parameters: X actor index, Y target actor index
        ; Returns: temp4 result of Y lowbyte subtraction, temp5 X distance, temp6 abs X distance, temp7 Y distance, temp8 abs Y distance
        ; Modifies: A

GetActorDistance:
                lda actYL,y
                sec
                sbc actYL,x
                sta temp4
                lda actYH,y
                sbc actYH,x
                sta temp7
                bpl GAD_YDistPos
                bit temp4
                bne GAD_YDistNegOK
                sbc #$00
GAD_YDistNegOK: eor #$ff
GAD_YDistPos:   sta temp8
GetActorXDistance:
                lda actXL,y
                sec
                sbc actXL,x
                sta temp6
                lda actXH,y
                sbc actXH,x
                sta temp5
                bpl GAD_XDistPos
                bit temp6
                bne GAD_XDistNegOK
                sbc #$00
GAD_XDistNegOK: eor #$ff
GAD_XDistPos:   sta temp6
                rts

        ; Find NPC actor from screen by type
        ;
        ; Parameters: A actor type
        ; Returns: C=1 actor found, index in X, C=0 not found
        ; Modifies: A,X

FindActor:      ldx #ACTI_LASTNPC
FA_Loop:        cmp actT,x
                beq FA_Found
                dex
                bne FA_Loop
FA_NotFound:    clc
FA_Found:       rts

        ; Find NPC actor from leveldata for state editing. If on screen, will be removed first
        ;
        ; Parameters: A actor type
        ; Returns: C=1 actor found, index in Y, C=0 not found
        ; Modifies: A,X,Y

FindLevelActor: sta FLA_Cmp+1
                jsr FindActor
                bcc FLA_NotOnScreen
                jsr RemoveLevelActor
FLA_NotOnScreen:ldy #MAX_LVLACT-1
FLA_Loop:       lda lvlActT,y
FLA_Cmp:        cmp #$00
                beq FA_Found
                dey
                bpl FLA_Loop
                bmi FA_NotFound

        ; Get a free index from levelactortable. May overwrite a temp-actor.
        ; If no room (fatal error, possibly would make game unfinishable) will loop infinitely
        ;
        ; Parameters: Y search startpos
        ; Returns: Y free index
        ; Modifies: A,Y

GLAI_Wrap:      ldy #MAX_LVLACT-1
GetLevelActorIndex:
GLAI_Loop:      lda lvlActT,y
                beq FA_Found
                lda lvlActOrg,y
                cmp #ORG_GLOBAL                 ;Can't overwrite a leveldata-actor
                bcc FA_Found                    ;or an important global actor
GLAI_NotFound:  dey
                bpl GLAI_Loop
                bmi GLAI_Wrap

        ; Get the next leveldata index for a temp actor. Note: does not confirm it is free
        ;
        ; Parameters: -
        ; Returns: nextTempLvlActIndex updated, also returned in A
        ; Modifies: A

GetNextTempLevelActorIndex:
                dec nextTempLvlActIndex
                bpl GNTLAI_NoWrap
                lda #MAX_LVLACT-1
                sta nextTempLvlActIndex
GNTLAI_NoWrap:  lda nextTempLvlActIndex
                rts
