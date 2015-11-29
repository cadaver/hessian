ZONEH_LEFT      = 0
ZONEH_RIGHT     = 1
ZONEH_UP        = 2
ZONEH_DOWN      = 3
ZONEH_CHARSET   = 4
ZONEH_BG1       = 5
ZONEH_BG2       = 6
ZONEH_BG3       = 7
ZONEH_MUSIC     = 8
ZONEH_SPAWNPARAM = 9
ZONEH_SPAWNSPEED = 10
ZONEH_SPAWNCOUNT = 11
ZONEH_DATA      = 12

OBJ_ANIMATE     = $80                           ;In levelobject Y-coordinate
OBJ_MODEBITS    = $03
OBJ_TYPEBITS    = $1c
OBJ_AUTODEACT   = $20
OBJ_SIZE        = $40
OBJ_ACTIVE      = $80

OBJMODE_NONE    = $00
OBJMODE_TRIG    = $01
OBJMODE_MANUAL  = $02
OBJMODE_MANUALAD = $03

OBJTYPE_SIDEDOOR = $00
OBJTYPE_DOOR    = $04
OBJTYPE_BACKDROP = $08
OBJTYPE_SWITCH  = $0c
OBJTYPE_REVEAL  = $10
OBJTYPE_SCRIPT  = $14
OBJTYPE_CHAIN   = $18

DOORENTRYDELAY  = 6
AUTODEACTDELAY  = 12

UpdateLevel     = lvlCodeStart

LoadLevelError: jsr LFR_ErrorPrompt
                jmp LoadLevelRetry

        ; Change current level and remove leveldata-actors back into statebits
        ; Note: actors must have been removed from screen, or else they will go permanently missing!
        ;
        ; Parameters: A Level number
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

ChangeLevel:    cmp levelNum                    ;Check if level already loaded
                beq SameLevel
                pha
                jsr SaveLevelState
                pla
                sta levelNum

        ; Load level without processing actor removal. Note: does not call InitMap
        ; as that is usually done later after finding the correct zone in the new level
        ;
        ; Parameters: levelNum
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

LoadLevel:      lda levelNum
                ldx #F_LEVEL
                jsr MakeFileName
                jsr BlankScreen                 ;Level loading will trash the second screen partially, so blank
LoadLevelRetry: lda #<lvlObjX                   ;Load level objects
                ldx #>lvlObjX
                jsr LoadFile
                bcs LoadLevelError
                lda #<lvlDataActX               ;Load level actors under screen2
                ldx #>lvlDataActX
                jsr LoadFile
                bcs LoadLevelError
                ldy #C_MAP
                jsr LoadAllocFile               ;Load MAP chunk
                bcs LoadLevelError
                lda #$ff
                sta autoDeactObjNum             ;Reset object auto-deactivation
                ldx #MAX_LVLACT-1
LL_PurgeOldLevelDataActors:
                lda lvlActOrg,x                 ;Remove the current leveldata actors
                bpl LL_PurgeNext                ;to make room for new
                lda #$00
                sta lvlActT,x
                sta lvlActOrg,x
LL_PurgeNext:   dex
                bpl LL_PurgeOldLevelDataActors
                jsr GetLevelDataActorBits
                ldx #MAX_LVLDATAACT-1           ;Copy level actors
LL_CopyLevelDataActors:
                lda lvlDataActT,x               ;Slot occupied in leveldata?
                beq LL_NextLevelDataActor
                txa
                jsr DecodeBit
                and (actLo),y                   ;Check state, whether actor still exists
                beq LL_NextLevelDataActor
                jsr GetLevelActorIndex
                lda lvlDataActX,x
                sta lvlActX,y
                lda lvlDataActY,x
                sta lvlActY,y
                lda lvlDataActF,x
                sta lvlActF,y
                lda lvlDataActT,x
                sta lvlActT,y
                lda lvlDataActWpn,x
                sta lvlActWpn,y
                txa                             ;Store the index in leveldata
                ora #ORG_LEVELDATA
                sta lvlActOrg,y
LL_NextLevelDataActor:
                dex
                bpl LL_CopyLevelDataActors
LL_SkipLevelDataActors:
                jsr GetLevelObjectBits          ;Set persistent levelobjects' active state now
                ldx #$00                        ;Levelobject index
                stx temp1                       ;Persistent levelobject index
LL_SetLevelObjectsActive:
                jsr IsLevelObjectPersistent
                beq LL_NextLevelObject
                and (actLo),y                   ;Active?
                beq LL_NextLevelObject
                txa
                tay
                lda lvlObjB,y
                ora #OBJ_ACTIVE
                sta lvlObjB,y
                and #OBJ_TYPEBITS
                cmp #OBJTYPE_REVEAL             ;If this is a weapon closet, make sure items at it are revealed
                bne LL_NoReveal
                jsr AO_Reveal
LL_NoReveal:    jsr AnimateObjectActivation     ;Animate if necessary
                tya
                tax
LL_NextLevelObject:
                inx
                cpx #MAX_LVLOBJ
                bcc LL_SetLevelObjectsActive
                rts

        ; Find the zone at player's position. Also load the proper charset if not loaded
        ; Falls through to InitMap regardless of whether charset was changed.
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,loader temp vars

FindPlayerZone: ldx actXH+ACTI_PLAYER
                ldy actYH+ACTI_PLAYER
                jsr FindZoneXY
                jsr EnsureCharSet

        ; Calculate start addresses for each map-row (of current zone) and for each
        ; block
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,loader temp vars

PostLoad:
InitMap:        lda zoneNum                     ;Map address might have changed
                jsr FindZoneNum                 ;(dynamic memory), so re-find
                lda limitU                      ;Startrow of zone
                ldy mapSizeX                    ;Multiply with map row width
                ldx #zpSrcLo
                jsr MulU
                lda limitL                      ;Add startcolumn of zone
                jsr Add8
                jsr Negate16                    ;Negate
                ldy #zoneLo                     ;Add zone startaddress
                jsr Add16
                lda #ZONEH_DATA                 ;Add zone mapdata offset
                jsr Add8
                ldy #$00                        ;Row counter
IM_MapLoop:     cpy limitU                      ;Check if outside zone vertically,
                bcc IM_MapRowOutside            ;store zero address in that case
                cpy limitD
                bcs IM_MapRowOutside
                lda zpSrcLo
                sta mapTblLo,y
                lda zpSrcHi
                bne IM_MapRowDone
IM_MapRowOutside:
                lda #$00
IM_MapRowDone:  sta mapTblHi,y
                lda mapSizeX
                jsr Add8
                iny
                bpl IM_MapLoop
                lda fileLo+C_BLOCKS             ;Address of first block
                sta zpSrcLo
                lda fileHi+C_BLOCKS
                sta zpSrcHi
                ldy #$00
IM_BlockLoop:   lda zpSrcLo                     ;Store and increase block-
                sta blkTblLo,y                  ;pointer
                lda zpSrcHi
                sta blkTblHi,y
                lda #$10
                jsr Add8
                iny
                cpy #MAX_BLK
                bcc IM_BlockLoop
                ldy #ZONEH_BG2                  ;Check if zone air is toxic
                lda (zoneLo),y                  ;(result needed in several places)
                bpl IM_NoToxicAir
                ldy lvlAirToxinDelay            ;Unaffected by filter?
                bmi IM_HasToxicAir
                eor upgrade
IM_HasToxicAir:
IM_NoToxicAir:  sta ULO_AirToxinFlag+1
                rts

        ; Get address of levelactor-bits according to current level
        ;
        ; Parameters: levelNum
        ; Returns: bits address in actLo/actHi, Y bitarea size-1, A=0
        ; Modifies: A,X,Y,actLo-actHi

GetLevelDataActorBits:
                lda #$00
                skip2

        ; Get address of levelobject-bits according to current level
        ;
        ; Parameters: levelNum
        ; Returns: bits address in actLo/actHi, Y bitarea size-1, A=0
        ; Modifies: A,X,Y,actLo-actHi

GetLevelObjectBits:
                lda #NUMLEVELS
                clc
                adc levelNum
                tax
                lda #<lvlStateBits
                adc lvlDataActBitsStart,x
                sta actLo
                lda #>lvlStateBits
                adc #$00
                sta actHi
                lda lvlDataActBitsStart+1,x
                sbc lvlDataActBitsStart,x       ;C=0, subtract one more as intended (size-1)
                tay
                lda #$00
                rts

        ; Check if a levelobject should be persisted. If yes, calculate its bitvalue
        ;
        ; Parameters: X levelobject index, temp1 persistent levelobject index
        ; Returns: A>0 is persistent, bit in A and temp1 incremented, A=0 not persistent
        ; Modifies: A

IsLevelObjectPersistent:
                lda lvlObjB,x                   ;Autodeactivating: not persistent
                tay
                and #OBJ_AUTODEACT
                bne ILOP_No
                lda lvlObjY,x                   ;Animating: is persistent
                bmi ILOP_Yes
                tya
                and #OBJ_TYPEBITS
                cmp #OBJTYPE_SWITCH
                bcc ILOP_No
ILOP_Yes:       lda temp1
                inc temp1
                jmp DecodeBit
ILOP_No:        lda #$00
                rts

        ; Save state of leveldata actors & leveldata objects as bits
        ; Needs to be done on level change and on game save
        ;
        ; Parameters: levelNum
        ; Returns: -
        ; Modifies: A,X,Y,actLo-actHi

SaveLevelState: jsr RemoveLevelActors           ;Make sure are removed from screen first
                jsr GetLevelDataActorBits       ;First clear all actor bits, then set those that exist
SLAS_ClearLoop: sta (actLo),y
                dey
                bpl SLAS_ClearLoop
                ldx #MAX_LVLACT-1
SLAS_ActorLoop: lda lvlActT,x
                beq SLAS_NextActor
                lda lvlActOrg,x                 ;Check persistence mode, must be leveldata
                bpl SLAS_NextActor
                and #$7f                        ;Actor is not gone, set bit
                jsr DecodeBit
                ora (actLo),y
                sta (actLo),y
SLAS_NextActor: dex
                bpl SLAS_ActorLoop
                jsr GetLevelObjectBits          ;First clear all object bits, then set those that are active
SLOS_ClearLoop: sta (actLo),y
                dey
                bpl SLOS_ClearLoop
                tax
                sta temp1                       ;Persistent object index
SLOS_Loop:      jsr IsLevelObjectPersistent
                beq SLOS_NextObject
                lda lvlObjB,x                   ;Check if active
                bpl SLOS_NextObject
                lda DB_Value+1
                ora (actLo),y
                sta (actLo),y
SLOS_NextObject:inx
                cpx #MAX_LVLOBJ
                bcc SLOS_Loop
ECS_HasCharSet: rts

        ; Find new level to load after entering a sidedoor
        ;
        ; Parameters: temp1 target X coord, temp2 target Y coord
        ; Returns: new level loaded, X & Y new target coords
        ; Modifies: A,X,Y,temp regs,loader temp regs

FindNewLevel:   lda temp1                   ;Convert X coord to screens
                cmp #$ff                    ;Handle -1 (moving left out of level) as a special case
                bne FNL_NotNegative
                lda #$ff
                sta temp3
                lda #9
                bne FNL_NegativeDone
FNL_NotNegative:ldy #10
                ldx #<temp3
                jsr DivU
FNL_NegativeDone:
                pha                         ;Store remainder
                lda temp3
                ldx levelNum
                clc
                adc lvlLimitL,x             ;Add level X origin in screens
                sta temp5
                ldx #$00
FNL_Loop:       cpx levelNum                ;Current level is always excluded
                beq FNL_Next
                lda temp5                   ;Note: if there's ambiguity in bounds
                cmp lvlLimitL,x             ;the first matching level number is used
                bcc FNL_Next
                cmp lvlLimitR,x             
                bcs FNL_Next
                lda temp2                   ;Y coordinates are always just blocks
                cmp lvlLimitU,x
                bcc FNL_Next
                cmp lvlLimitD,x
                bcc FNL_Found
FNL_Next:       inx
                bpl FNL_Loop                ;Will produce rubbish result if not found
FNL_Found:      stx FNL_NewLevelNum+1
                lda temp5
                sec
                sbc lvlLimitL,x             ;Subtract screen origin of new level
                ldy #10
                ldx #<temp3                 ;Convert back to blocks
                jsr MulU
                pla                         ;Add back block remainder
                clc
                adc temp3
                pha                         ;New X coord
                lda temp2
                pha                         ;Old Y coord (temp2 will likely be trashed by ChangeLevel)
FNL_NewLevelNum:lda #$00
                jsr ChangeLevel
                pla
                tay
                pla
                tax
                rts

        ; Ensure that zone's charset is loaded. Does not call InitMap on all code paths
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,loader temp regs

EnsureCharSet:  ldy #ZONEH_CHARSET
                lda (zoneLo),y
ECS_LoadedCharSet:
                cmp #$ff                        ;Switch charset if required
                beq ECS_HasCharSet
                sta ECS_LoadedCharSet+1
                ldx #F_CHARSET
                jsr MakeFileName
                jsr BlankScreen                 ;Blank screen to make sure no animation
                beq ECS_RetryCharSet            ;X=0 on return
ECS_LoadCharSetError:
                jsr LFR_ErrorPrompt
ECS_RetryCharSet:
                lda #<lvlCodeStart              ;Load char animation code, charset and colors/infos
                ldx #>lvlCodeStart
                jsr LoadFile
                bcs ECS_LoadCharSetError
                ldy #C_BLOCKS
                jsr LoadAllocFile               ;Load BLOCKS chunk
                bcs ECS_LoadCharSetError
                ldx #lvlPropertiesEnd-lvlPropertiesStart-1
ECS_CopyLevelProperties:                        ;Copy level properties into place
                lda charsetLoadProperties,x
                sta lvlPropertiesStart,x
                dex
                bpl ECS_CopyLevelProperties
                rts

        ; Set zone's multicolors
        ;
        ; Parameters: zoneLo,zoneHi
        ; Returns: -
        ; Modifies: A,Y

SetZoneColors:  ldy #ZONEH_BG1                  ;Set zone multicolors
                lda (zoneLo),y
                sta Irq1_Bg1+1
                iny
                lda (zoneLo),y
                sta Irq1_Bg2+1
                iny
                lda (zoneLo),y
                sta Irq1_Bg3+1
                rts

        ; Calculate horizontal centerpoint of zone
        ;
        ; Parameters: -
        ; Returns: A zone center, also stored in temp8
        ; Modifies: A, temp8

GetZoneCenterX: lda limitL
                clc
                adc limitR
                ror
                sta temp8
                rts

        ; Find the zone indicated by coordinates or number.
        ;
        ; Parameters: A zone number (FindZoneNum) or X,Y pos (FindZoneXY)
        ; Returns: zoneNum, zoneLo-zoneHi
        ; Modifies: A,X,Y,loader temp vars

FindZoneXY:     sty zpBitBuf
                lda #$00
FZXY_Loop:      jsr FindZoneNum
                cpx limitL
                bcc FZXY_Next
                cpx limitR
                bcs FZXY_Next
                ldy zpBitBuf
                cpy limitU
                bcc FZXY_Next
                cpy limitD
                bcc FZXY_Done
FZXY_Next:      inc zoneNum
                lda zoneNum
                cmp fileNumObjects+C_MAP
                bcc FZXY_Loop
FZXY_Done:      rts

FindZoneNum:    sta zoneNum
                asl
                tay
                lda fileLo+C_MAP
                sta zpBitsLo
                lda fileHi+C_MAP
                sta zpBitsHi
                lda (zpBitsLo),y
                sta zoneLo
                iny
                lda (zpBitsLo),y
                sta zoneHi
                ldy #ZONEH_LEFT
                lda (zoneLo),y
                sta limitL
                iny
                lda (zoneLo),y
                sta limitR
                sec
                sbc limitL
                sta mapSizeX
                iny
                lda (zoneLo),y
                sta limitU
                iny
                lda (zoneLo),y
                sta limitD
OO_Done:        rts

        ; Operate a level object
        ;
        ; Parameters: Y object number (should also be in lvlObjNum)
        ; Returns: C=1 if object was operated successfully (should not jump), C=0 if not
        ; Modifies: A,X,Y,temp vars

OperateObject:  lda actF1+ACTI_PLAYER           ;Already in enter/operate stance?
                cmp #FR_ENTER
                beq OO_ContinueOperate
                lda actPrevCtrl+ACTI_PLAYER     ;If joystick already held up, do not operate again
                and #JOY_UP                     ;(eg. after entering a door)
                clc
                bne OO_Done
                lda lvlObjB,y                   ;Must either be manually activated object,
                and #$ff-OBJ_SIZE
                cmp #OBJTYPE_DOOR+OBJ_ACTIVE    ;or a door opened from elsewhere
                beq OO_EnterNoOperate
                and #OBJ_MODEBITS
                cmp #OBJMODE_MANUAL
                bcc OO_Done
                lda lvlObjB,y
                bpl OO_Inactive
OO_Active:      and #OBJ_MODEBITS               ;Object was active, inactivate if possible
                cmp #OBJMODE_MANUALAD
                bcc OO_EnterNoOperate
OO_Inactive:    lda lvlObjY,y                   ;If animating, play sound always
                bmi OO_PlaySound
                lda lvlObjB,y                   ;Otherwise check that isn't a door that is always open
                and #OBJ_TYPEBITS               ;(keycard slots and other non-animating objects should
                cmp #OBJTYPE_DOOR               ;play a sound)
                beq OO_NoSound
OO_PlaySound:   lda #SFX_OBJECT
                jsr PlaySfx
OO_NoSound:     lda lvlObjB,y
                and #OBJ_TYPEBITS
                cmp #OBJTYPE_SCRIPT
                beq OO_RequirementOK            ;Script object doesn't have requirement
                lda lvlObjDH,y                  ;Check requirement item from object parameters if has them
                beq OO_RequirementOK
                sta temp3
                tay
                jsr FindItem
                bcs OO_RequirementOK
                lda #<txtRequired
                ldx #>txtRequired
                ldy #REQUIREMENT_TEXT_DURATION
                jsr PrintPanelText
                lda temp3
                jsr GetItemName
                jsr ContinuePanelText
                jmp OO_EnterNoOperate           ;Turn to object but do not actually operate
OO_RequirementOK:
                ldy lvlObjNum
                jsr ToggleObject                ;Note: animating the object here (before UpdateFrame)
OO_EnterNoOperate:                              ;may theoretically induce an UpdateBlock bug if colorscroll
                lda #FR_ENTER                   ;is happening on the same frame. However, in practice it seems
                sta actF1+ACTI_PLAYER           ;the bug will not occur, as the scrolling is never in that phase
                sta actF2+ACTI_PLAYER           ;on the actor logic update frame
                lda #$00
                sta actFd+ACTI_PLAYER           ;Reset door entry delay
                beq OO_Success
OO_ContinueOperate:
                lda actFd+ACTI_PLAYER
                bmi OO_Success
                inc actFd+ACTI_PLAYER           ;Increment door entry delay, up to 128
OO_Success:     sec
IO_Done:        rts

        ; Toggle a level object
        ;
        ; Parameters: Y object number
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

ToggleObject:   lda lvlObjB,y
                bpl ActivateObject

        ; Inactivate a level object
        ;
        ; Parameters: Y object number
        ; Returns: -
        ; Modifies: A,X,temp vars

InactivateObject:
                lda lvlObjB,y                 ;Make sure that is active
                bpl IO_Done
                and #$ff-OBJ_ACTIVE
                sta lvlObjB,y
                pha
                lda #$ff
                jsr AnimateObjectDelta
                pla
                and #OBJ_TYPEBITS
                cmp #OBJTYPE_CHAIN
                bne IO_Done
                lda lvlObjDL,y
                tay
                jmp InactivateObject

        ; Animate a level object by block deltavalue
        ;
        ; Parameters: A deltavalue, Y object number
        ; Returns: -
        ; Modifies: A,X,temp vars

AnimateObjectActivation:
                lda #$01
AnimateObjectDelta:
                sty temp3
                sta temp4
                lda lvlObjY,y
                bpl AOD_Done                    ;No animation
                jsr AOD_Sub
                lda lvlObjB,y
                and #OBJ_SIZE
                beq AOD_Done
                lda lvlObjY,y
                sec
                sbc #$01
AOD_Sub:        and #$7f
                ldx lvlObjX,y
                tay
                lda temp4
                jsr UpdateBlockDelta
                ldy temp3
AO_Done:
AOD_Done:       rts

        ; Activate a level object
        ;
        ; Parameters: Y object number
        ; Returns: temp2: object number
        ; Modifies: A,X,Y,temp vars

AO_Chain:       lda lvlObjDL,y
                tay
ActivateObject: sty temp2
                lda lvlObjB,y                   ;Make sure that is inactive
                bmi AO_Done
                ora #OBJ_ACTIVE
                sta lvlObjB,y
                pha
                and #OBJ_AUTODEACT              ;Enable auto-deactivation if necessary
                beq AO_NoAutoDeact
                lda autoDeactObjNum             ;If another object already deactivating,
                bmi AO_NoPreviousAutoDeact      ;deactivate it immediately
                cpy autoDeactObjNum
                beq AO_NoPreviousAutoDeact      ;If same object deactivating, no need to do that
                tay
                jsr InactivateObject
                ldy temp2
AO_NoPreviousAutoDeact:
                sty autoDeactObjNum
                lda #AUTODEACTDELAY
                sta autoDeactObjCounter
AO_NoAutoDeact: jsr AnimateObjectActivation     ;Animate object if necessary
                pla
                and #OBJ_TYPEBITS               ;Check for type-specific action
                cmp #OBJTYPE_CHAIN
                beq AO_Chain
                cmp #OBJTYPE_SCRIPT
                beq AO_Script
                cmp #OBJTYPE_SWITCH
                beq AO_Toggle
                cmp #OBJTYPE_REVEAL
                beq AO_Reveal
AO_NoOperation: rts

        ; Script execution

AO_Script:      ldx lvlObjDH,y
                lda lvlObjDL,y
                jmp ExecScript

        ; Toggle object

AO_Toggle:      lda lvlObjDL,y
                tay
                jmp ToggleObject

        ; Reveal actors (weapon closet)

AO_Reveal:      lda lvlObjX,y
                sta AO_RevealXCmp+1
                lda lvlObjY,y
                ora #$80                        ;Check for hidden bit
                sta AO_RevealYCmp+1
                ldx #MAX_LVLACT-1
AO_RevealLoop:  lda lvlActT,x
                beq AO_RevealNext
                lda lvlActOrg,x                 ;Check whether is a leveldata actor,
                bmi AO_RevealLevelOK            ;or is global/temp which belongs to the current level
                and #ORG_LEVELNUM
                cmp levelNum
                bne AO_RevealNext
AO_RevealLevelOK:
                lda lvlActX,x
AO_RevealXCmp:  cmp #$00
                bne AO_RevealNext
                lda lvlActY,x
AO_RevealYCmp:  cmp #$00
                bne AO_RevealNext
AO_DoReveal:    and #$7f
                sta lvlActY,x
                jsr AddAllActorsNextFrame       ;Hack: add all actors next frame
AO_RevealNext:  dex                             ;to reveal the item as quickly as possible
                bpl AO_RevealLoop
                rts

        ; Position actor to levelobject, coarsely only
        ;
        ; Parameters: X:actor number, Y levelobject number
        ; Returns: -
        ; Modifies: A

SetActorAtObject:
                lda #$80
                sta actXL,x
                asl                             ;A=0
                sta actYL,x
                lda lvlObjX,y
                sta actXH,x
                lda lvlObjY,y
                and #$7f
                sta actYH,x
AAOG_Done:      rts

        ; Save an in-memory checkpoint. Removes other actors than player as a byproduct
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp regs

SaveCheckpoint: jsr SaveLevelState
                ldx #6
                ldy #6*MAX_ACT
                sec
StorePlayerActorVars:
                lda actXL+ACTI_PLAYER,y
                sta saveXL,x
                tya
                sbc #MAX_ACT
                tay
                dex
                bpl StorePlayerActorVars
                ldx saveHP                      ;Ensure minimum health & battery level when saving
                cpx #LOW_HEALTH
                bcs SCP_HealthOK
                ldx #LOW_HEALTH
                stx saveHP
SCP_HealthOK:   lda #$00
                ldx saveBattery+1
                cpx #LOW_BATTERY
                bcs SCP_BatteryOK
                ldx #LOW_BATTERY
                stx saveBattery+1
                sta saveBattery
SCP_BatteryOK:  ldy #MAX_SAVEACT                ;Clear actor save table first
SCP_ClearSaveLoop:
                sta saveLvlActT-1,y
                dey
                bne SCP_ClearSaveLoop
                ldx #MAX_LVLACT-1
SCP_SaveGlobalLoop:
                lda lvlActT,x                   ;Save the important global actors
                beq SCP_SaveGlobalNext
                lda lvlActOrg,x
                bmi SCP_SaveGlobalNext          ;(skip leveldata actors and temp now)
                asl
                bpl SCP_SaveGlobalNext
                jsr SaveActorSub
SCP_SaveGlobalNext:
                dex
                bpl SCP_SaveGlobalLoop
                ldx levelActorIndex
SCP_SaveItemsLoop:
                cpy #MAX_SAVEACT                ;Then save as many temp items (weapons etc.)
                bcs SCP_SaveItemsDone           ;as possible, from the latest stored
                lda lvlActT,x
                bpl SCP_SaveItemsNext
                lda lvlActOrg,x
                cmp #ORG_GLOBAL
                bcs SCP_SaveItemsNext
                jsr SaveActorSub
SCP_SaveItemsNext:
                inx
                cpx #MAX_LVLACT
                bcc SCP_SaveItemsNotOver
                ldx #$00
SCP_SaveItemsNotOver:
                cpx levelActorIndex             ;Exit when wrapped
                bne SCP_SaveItemsLoop
SCP_SaveItemsDone:
                ldx #playerStateZPEnd-playerStateZPStart
SCP_ZPState:    lda playerStateZPStart-1,x
                sta saveStateZP-1,x
                dex
                bne SCP_ZPState
                lda #<playerStateStart
                sta zpSrcLo
                lda #>playerStateStart
                sta zpSrcHi
                lda #<saveState
                ldx #>saveState
                jmp SaveState_CopyMemory

SaveActorSub:   lda lvlActX,x
                sta saveLvlActX,y
                lda lvlActY,x
                sta saveLvlActY,y
                lda lvlActF,x
                sta saveLvlActF,y
                lda lvlActT,x
                sta saveLvlActT,y
                lda lvlActWpn,x
                sta saveLvlActWpn,y
                lda lvlActOrg,x
                sta saveLvlActOrg,y
                iny
ULO_IsPaused:
ULO_PlayerDead:
ULO_ToxinDelay:
                rts

        ; Update level objects. Handle operation, auto-deactivation and actually entering doors.
        ; Also check for picking up items, player health regeneration and incrementing game clock
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

ULO_DoToxinDamage:
                dec toxinDelay
                bpl ULO_ToxinDelay
                dey
                tya
                and #$7f                        ;There may be extra control data in the high bit
                sta toxinDelay
ULO_DoDrowningDamage:
                ldy #NODAMAGESRC
                lda #DMG_DROWNING
                jmp DamageActor                 ;X must be 0

UpdateLevelObjects:
                ldx #$03
                lda menuMode                    ;Increase time in ingame & dialogue, but not in pause
                cmp #MENU_PAUSE
                beq ULO_NoTime
                php
                sec
ULO_IncreaseTime:
                lda time,x                      ;time+3 = frames
                adc #$00                        ;time = hours
                cmp timeMaxTbl,x
                bcc ULO_TimeNotOver
                lda #$00
ULO_TimeNotOver:sta time,x
                dex
                bpl ULO_IncreaseTime
                plp
ULO_NoTime:     bcs ULO_IsPaused
                lda attackTime                  ;Decrement global attack timer if necessary
                bpl ULO_NoGlobalAttack
                inc attackTime
ULO_NoGlobalAttack:
                ldy autoDeactObjNum
                bmi ULO_NoAutoDeact
                dec autoDeactObjCounter
                bne ULO_NoAutoDeact
                cpy lvlObjNum                   ;If it's a sidedoor the player is standing at,
                bne ULO_AutoDeactOK             ;do not deactivate until walked away
                lda lvlObjB,y
                and #OBJ_TYPEBITS
                bne ULO_AutoDeactOK
                inc autoDeactObjCounter         ;Retry next frame
                bne ULO_NoAutoDeact
ULO_AutoDeactOK:lda #$ff
                sta autoDeactObjNum
                jsr InactivateObject

ULO_NoAutoDeact:ldx #ACTI_PLAYER
                lda actHp+ACTI_PLAYER           ;Heal if not dead and not yet at full health
                beq ULO_PlayerDead              ;full health
                cmp #HP_PLAYER
                bcs ULO_NoHealing
                lda battery+1                   ;No healing if low battery
                cmp #LOW_BATTERY+1
                bcc ULO_NoHealing
                lda healTimer
ULO_HealingRate:adc #INITIAL_HEALTIMER-1        ;C=1 here
                bcc ULO_NoHealing2
                lda #DRAIN_HEAL
                jsr DrainBattery
                inc actHp+ACTI_PLAYER
                lda #HEALTIMER_RESET            ;Heal faster after first unit
ULO_NoHealing2: sta healTimer
ULO_NoHealing:  lda upgrade                     ;Check battery auto-recharge
                asl
                bpl ULO_NoRecharge
                lda battery+1
                cmp #MAX_BATTERY
                bcs ULO_NoRecharge
                inc battery
                bne ULO_NoRecharge
                inc battery+1

ULO_NoRecharge: lda actF1+ACTI_PLAYER           ;Check for player losing oxygen
                cmp #FR_SWIM                    ;(must be swimming & head under water)
                bcc ULO_RestoreOxygen
                lda #-1
                jsr GetCharInfoOffset
                and #CI_WATER|CI_OBSTACLE
                beq ULO_RestoreOxygen
                lda actFd+ACTI_PLAYER
                bne ULO_OxygenDone
                lda oxygen
                bne ULO_DecreaseOxygen
                lda actF1+ACTI_PLAYER           ;Do damage slower than oxygen drain
                lsr
                bcc ULO_OxygenDone
                jsr ULO_DoDrowningDamage
                jmp ULO_OxygenDone
ULO_RestoreOxygen:
                lda oxygen
                cmp #MAX_OXYGEN-1
                beq ULO_RestoreOne
                bcs ULO_OxygenDone
ULO_RestoreTwo: inc oxygen
ULO_RestoreOne: inc oxygen
                bne ULO_OxygenDone
ULO_DecreaseOxygen:
                dec oxygen

ULO_OxygenDone: ldy lvlWaterToxinDelay          ;Toxic water?
                beq ULO_NoWaterDamage
                bmi ULO_WaterDamageNotFiltered  ;Filter upgrade cancels damage?
                lda upgrade
                bmi ULO_NoWaterDamage           ;Note: filter upgrade must stay at bit 7
ULO_WaterDamageNotFiltered:
                lda actMB+ACTI_PLAYER
                and #MB_INWATER
                beq ULO_NoWaterDamage
                jsr ULO_DoToxinDamage
                jmp ULO_NoAirDamage             ;If already doing water damage, no air damage
                                                ;(applies to the nether tunnel where water is lava
                                                ;so it should take priority)
ULO_NoWaterDamage:
ULO_AirToxinFlag:
                lda #$00
                bpl ULO_NoAirDamage
                ldy #ZONEH_BG1
                lda UA_ItemFlashCounter+1
                and #$01
                beq ULO_ToxinEffectColor
                lda (zoneLo),y
ULO_ToxinEffectColor:
                sta Irq1_Bg1+1
                ldy lvlAirToxinDelay
                jsr ULO_DoToxinDamage

ULO_NoAirDamage:lda actYH+ACTI_PLAYER           ;Kill player actor if fallen outside level
                cmp limitD                      ;or run out of battery
                bcc ULO_NotOutside
                bne ULO_Outside
ULO_NotOutside: lda battery
                ora battery+1
                bne ULO_CheckPickupIndex
ULO_Outside:    jsr DestroyActorNoSource
                txa
                sta actSY,x
                rts
ULO_CheckPickupIndex:                           ;Check if player is colliding with an item
                ldy #ACTI_FIRSTITEM             ;If was at an item last frame, continue search from that
ULO_CheckPickupLoop:
                lda actT,y
                beq ULO_CPNoItem
                jsr CheckActorCollision
                bcs ULO_HasItem
ULO_CPNoItem:   iny
                cpy #ACTI_LASTITEM+1
                bcc ULO_CPNoItemNoWrap
                ldy #ACTI_FIRSTITEM
ULO_CPNoItemNoWrap:
                cpy ULO_CheckPickupIndex+1
                bne ULO_CheckPickupLoop
                lda displayedItemName           ;If no items, clear existing item name
                beq ULO_CheckContinuousScript   ;text
                jsr ClearPanelText
                bcs ULO_CheckContinuousScript   ;C=1 when returning
ULO_HasItem:    sty ULO_CheckPickupIndex+1
                lda textTime                    ;Make sure to not overwrite other game
                bne ULO_SkipItemName            ;messages
                lda actF1,y
                cmp displayedItemName           ;Do not reprint same item name
                beq ULO_SkipItemName
                pha
                jsr GetItemName
                ldy #$00
                jsr PrintPanelText
                pla
                sta displayedItemName
ULO_SkipItemName:
                lda actCtrl+ACTI_PLAYER
                cmp #JOY_DOWN
                bne ULO_CheckContinuousScript
                lda actFd+ACTI_PLAYER           ;If ducking, try picking up the item
                beq ULO_CheckContinuousScript
                lda actF1+ACTI_PLAYER
                cmp #FR_DUCK
                bne ULO_CheckContinuousScript
                ldy ULO_CheckPickupIndex+1
                jsr TryPickup
ULO_CheckContinuousScript:
                ldx scriptF                     ;Check for continuous script execution
                bmi ULO_CheckNearTrigger
                lda scriptEP
                jsr ExecScript
ULO_CheckNearTrigger:
                ldx #ACTI_LASTNPC
                lda actFlags,x
                and #AF_USETRIGGERS
                beq ULO_CNTNext
                ldy #ACTI_PLAYER
                jsr GetActorDistance
                lda temp6
                cmp #MAX_NEARTRIGGER_XDIST
                bcs ULO_CNTNext
                lda temp8
                cmp #MAX_NEARTRIGGER_YDIST
                bcs ULO_CNTNext
                lda actMB+ACTI_PLAYER           ;If neartrigger would be OK to execute, but player
                lsr                             ;is jumping, skip (neartrigger often triggers
                bcc ULO_CheckObject             ;a conversation, would look stupid if hanging in midair)
                ldy #AT_NEAR
                jsr ActorTriggerNoFlagCheck
ULO_CNTNext:    dex
                bne ULO_CNTNotOver
                ldx #ACTI_LASTNPC
ULO_CNTNotOver: stx ULO_CheckNearTrigger+1

ULO_CheckObject:ldy actYH+ACTI_PLAYER           ;Rescan objects whenever player block position changes
                ldx actYL+ACTI_PLAYER           ;If player stands on the upper half of a block
                cpx #$81                        ;check 1 block above
                bcs ULO_CONotAtTop
                dey
ULO_CONotAtTop: ldx actXH+ACTI_PLAYER
                lda lvlObjNum
ULO_COLastCheckX:
                cpx ULO_COCmpX+1
                bne ULO_CORescan
ULO_COLastCheckY:
                cpy ULO_COSubY+1
                beq ULO_CONoRescan
ULO_CORescan:   lda #$80                        ;Start from beginning
ULO_CONoRescan: stx ULO_COCmpX+1
                sty ULO_COSubY+1
                tay                             ;Already have a valid object that is current?
                bpl ULO_CODone
                cmp #$ff                        ;Search given up in current location?
                beq ULO_CODone
                and #$7f
                tax
                adc #LVLOBJSEARCH               ;C=0 here
                sta ULO_COEndCmp+1
ULO_COLoop:     lda lvlObjX,x
ULO_COCmpX:     cmp #$00
                bne ULO_CONext
                lda lvlObjY,x
                and #$7f
ULO_COSubY:     sbc #$00
                cmp #$02                        ;Above or at object
                bcc ULO_COFound
ULO_CONext:     inx
ULO_COEndCmp:   cpx #LVLOBJSEARCH
                bcc ULO_COLoop
                cpx #MAX_LVLOBJ
                bcc ULO_CONotOver
                ldx #$ff                        ;If search finished with no object,
ULO_CONotOver:  txa                             ;no need to rescan until moved
                ora #$80
                sta lvlObjNum
                bmi ULO_CODone
ULO_COFound:    stx lvlObjNum
                lda lvlObjB,x
                tay
                and #OBJ_TYPEBITS+OBJ_ACTIVE
                cmp #OBJTYPE_DOOR+OBJ_ACTIVE
                beq ULO_COShowMarker
                tya
                and #OBJ_MODEBITS
                cmp #OBJMODE_MANUAL             ;If object is manually activated
                bcc ULO_CODone                  ;or an open door, show marker
                bne ULO_COShowMarker
                tya
                bmi ULO_CODone                  ;If active and not manually deactivable, do not show marker
ULO_COShowMarker:
                lda #ACTI_LASTPLRBULLET         ;Get free actor for object marker. May fail if all bullets
                ldy #ACTI_LASTNPCBULLET         ;are full, in which case the object is not shown until
                jsr GetFreeActor                ;player moves
                bcc ULO_CODone
                sty MObjMarker_Cmp+1
                tya
                tax
                lda #ACT_OBJECTMARKER
                sta actT,x
                ldy lvlObjNum
                jsr SetActorAtObject
                inc actYH,x
ULO_CODone:     ldy lvlObjNum
                bmi ULO_Done
                lda actF1+ACTI_PLAYER           ;Check if player is standing at a door and
                cmp #FR_ENTER                   ;entry delay has elapsed
                bne ULO_NoDoor
                lda lvlObjB,y
                and #OBJ_TYPEBITS+OBJ_ACTIVE
                cmp #OBJTYPE_DOOR+OBJ_ACTIVE
                bne ULO_NoDoor
                ldx actFd+ACTI_PLAYER
                cpx #DOORENTRYDELAY
                bcs ULO_EnterDoor
ULO_NoDoor:     lda lvlObjB,y                   ;Check for triggered activation
                tax
                and #OBJ_MODEBITS+OBJ_ACTIVE
                cmp #OBJMODE_TRIG
                bne ULO_NoTrigger
                lda lvlObjY,y                   ;If animating, play sound
                bpl ULO_TriggerNoSound
                lda #SFX_OBJECT
                jsr PlaySfx
ULO_TriggerNoSound:
                jmp ActivateObject
ULO_NoTrigger:  txa
                and #OBJ_TYPEBITS               ;Check for entering a side door
                bne ULO_Done
                jsr GetZoneCenterX
                lda actXH+ACTI_PLAYER
                ldx actXL+ACTI_PLAYER
                cmp temp8
                txa
                bcc ULO_LeftSide
                inx
ULO_LeftSide:   beq ULO_EnterSideDoor
ULO_Done:       rts

ULO_EnterSideDoor:
                bcc ULO_EnterSideDoorLeft       ;Find the destination zone either left or right
                lda limitR
                bcs ULO_EnterSideDoorCommon
ULO_EnterSideDoorLeft:
                lda limitL
                sbc #$00                        ;C=0
ULO_EnterSideDoorCommon:
                tax
ULO_EnterDoor:  lda lvlObjDL,y
                bne ULO_EnterDoorDest           ;Can also specify destination explicitly
                lda lvlObjY,y
                and #$7f
                tay
ULO_Retry:      stx temp1
                sty temp2
                jsr FindZoneXY
                bcc ULO_SameLevel               ;If zone not found, must change level
                jsr FindNewLevel
                jmp ULO_Retry
ULO_SameLevel:  ldy #$00
ULO_DestDoorLoop:
                lda lvlObjX,y                   ;Object needs to be inside same zone, and
                cmp limitL                      ;a small distance (1 block) from exact target
                bcc ULO_DestDoorNext
                cmp limitR
                bcs ULO_DestDoorNext
                adc #$02                        ;Add 1 too much, as C will be 0 and will subtract one more
                sbc temp1
                cmp #$03
                bcs ULO_DestDoorNext
                lda lvlObjY,y
                and #$7f
                cmp limitU
                bcc ULO_DestDoorNext
                cmp limitD
                bcs ULO_DestDoorNext
                adc #$02
                sbc temp2
                cmp #$03
                tya
                bcc ULO_EnterDoorDest           ;Found!
ULO_DestDoorNext:
                iny
                cpy #MAX_LVLOBJ
                bcc ULO_DestDoorLoop            ;If door search fails, enter a random door. Will probably
                                                ;show trashed graphics and/or kill the player character
ULO_EnterDoorDest:
                and #$7f
                sta ULO_DestDoorNum+1
                jsr RemoveLevelActors
                jsr BlankScreen                 ;X=0 on return
ULO_DestDoorNum:ldy #$00
                jsr SetActorAtObject
                jsr ActivateObject              ;Activate the door that was entered
                jsr FindPlayerZone              ;After entering door, face player toward zone center
                jsr GetZoneCenterX
                lda actXH+ACTI_PLAYER
                cmp temp8
                ror
                sta actD+ACTI_PLAYER
                ldx #ACTI_PLAYER
                stx actSX+ACTI_PLAYER           ;Stop X-movement
                jsr MH_StandAnim
                jsr MH_SetGrounded
                jsr MH_ResetFall
                lda #$40
                sta actYL,x
ULO_FinePositionLoop:                           ;Fineposition player to ground at floor
                lda #8*8
                jsr MoveActorY
                jsr GetCharInfo
                and #CI_GROUND
                beq ULO_FinePositionLoop
                ldy #ZONEH_BG1
                lda (zoneLo),y                  ;Check for save-disabled zone
                ora ULO_AirToxinFlag+1          ;Also don't save if the zone is damaging
                bmi CenterPlayer
                jsr SaveCheckpoint              ;Save checkpoint now
                bmi CenterPlayer                ;N=1 upon returning

        ; Restore an in-memory checkpoint
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

RestartCheckpoint:
                ldx #playerStateZPEnd-playerStateZPStart
RCP_ZPState:    lda saveStateZP-1,x
                sta playerStateZPStart-1,x
                dex
                bne RCP_ZPState
                lda #<saveState
                sta zpSrcLo
                lda #>saveState
                sta zpSrcHi
                lda #<playerStateStart
                ldx #>playerStateStart
                jsr SaveState_CopyMemory
                ldx #MAX_SAVEACT-1
RCP_CopySaveActorsLoop:
                lda saveLvlActX,x
                sta lvlActX,x
                lda saveLvlActY,x
                sta lvlActY,x
                lda saveLvlActF,x
                sta lvlActF,x
                lda saveLvlActT,x
                sta lvlActT,x
                lda saveLvlActWpn,x
                sta lvlActWpn,x
                lda saveLvlActOrg,x
                sta lvlActOrg,x
                dex
                bpl RCP_CopySaveActorsLoop
RCP_ClearActors:ldx #MAX_LVLACT-MAX_SAVEACT-1
                lda #$00
RCP_ClearActorsLoop:
                sta lvlActT+MAX_SAVEACT,x
                dex
                bpl RCP_ClearActorsLoop
                sec                             ;Need to load leveldata actors again
                jsr CreatePlayerActor
                jsr FindPlayerZone
                ldx #ACTI_PLAYER                ;Check if player is at an obstacle door, move left
                jsr GetCharInfo1Above           ;slightly in that case
                and #CI_OBSTACLE
                beq RCP_NoObstacle
                dec actXL+ACTI_PLAYER
RCP_NoObstacle:                                 ;Fall through to CenterPlayer

        ; Centers player on screen, redraws screen, adds all actors from leveldata, and jumps to mainloop
        ; Player zone must have been acquired beforehand
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

CenterPlayer:   ldy #ZONEH_MUSIC
                lda (zoneLo),y
                jsr PlaySong                    ;Play zone's music
                lda limitR
                sec
                sbc #10
                sta temp1
                lda limitD
                sbc #6
                sta temp2
                ldx #3
                lda actXH+ACTI_PLAYER
                sbc #5
                bcc CP_OverLeft
                cmp limitL
                bcs CP_NotOverLeft
CP_OverLeft:    lda limitL
                ldx #0
                beq CP_NotOverRight
CP_NotOverLeft: cmp temp1
                bcc CP_NotOverRight
                lda temp1
                ldx #1
CP_NotOverRight:sta mapX
                stx blockX
                lda #$c0
                clc
                adc actYL+ACTI_PLAYER
                php
                rol
                rol
                rol
                and #$03
                tay
                plp
                lda actYH+ACTI_PLAYER
                sbc #3
                bcc CP_OverUp
                cmp temp2
                bcc CP_NotOverDown
                bne CP_OverDown
                cpy #$02
                bcc CP_NotOverDown
CP_OverDown:    lda temp2
                ldy #$02
                bne CP_NotOverUp
CP_NotOverDown: cmp limitU
                bcs CP_NotOverUp
CP_OverUp:      lda limitU
                ldy #$00
                beq CP_NotOverDown
CP_NotOverUp:   sta mapY
                sty blockY
                ldx #$00
                stx UA_SpawnCount+1             ;Reset enemy spawning variables
                stx UA_SpawnDelay+1
                stx attackTime                  ;Reset global attack timer
                dex
                stx ULO_COSubY+1                ;Reset object search
                ldx #ACTI_PLAYER
                jsr GetCharInfo1Above
                and #CI_WATER                   ;Check if player standing in water
                beq CP_NotInWater               ;and set water bit now to prevent
                lda #MB_INWATER                 ;creating a splash on door entry /
CP_NotInWater:  ora #MB_GROUNDED                ;checkpoint restore
                sta actMB+ACTI_PLAYER
                jsr RedrawScreen
                jsr SetZoneColors
                jsr AddAllActorsNextFrame
                jsr AddActors
                jsr UpdateActors                ;Update actors once first to make sure
                                                ;e.g. weapons are shown correctly

        ; Game main loop

StartMainLoop:  ldx #STACKSTART
                txs
MainLoop:       jsr ScrollLogic
                endif
                jsr DrawActors
                jsr AddActors
                jsr FinishFrame
                jsr ScrollLogic
                jsr GetControlsWaitFrame
                jsr UpdateMenu
                jsr UpdateActors
                jsr FinishFrame
                jsr UpdateLevelObjects
                jmp MainLoop
