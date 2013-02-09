ZONEH_LEFT      = 0
ZONEH_RIGHT     = 1
ZONEH_UP        = 2
ZONEH_DOWN      = 3
ZONEH_BG1       = 4
ZONEH_BG2       = 5
ZONEH_BG3       = 6
ZONEH_MUSIC     = 7
ZONEH_DATA      = 8

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

OBJTYPE_NONE    = $00
OBJTYPE_DOOR    = $04
OBJTYPE_SWITCH  = $08
OBJTYPE_REVEAL  = $0c
OBJTYPE_SCRIPT  = $10
OBJTYPE_SIDEDOOR = $14
OBJTYPE_SPAWN   = $18

DOORENTRYDELAY  = 5
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
                beq CL_Done
                pha
                jsr GetLevelDataActorBits
                ldy lvlDataActBitsLen,x         ;Assume leveldata actors are all gone
                dey
                lda #$00
ULD_ClearStateBits:
                sta (zpDestLo),y
                dey
                bpl ULD_ClearStateBits
                ldx #MAX_LVLACT-1
ULD_LevelDataLoop:
                lda lvlActT,x
                beq ULD_NextActor
                lda lvlActOrg,x                  ;Check persistence mode, must be leveldata
                bpl ULD_NextActor
                and #$7f
                jsr DecodeBit
                ora (zpDestLo),y
                sta (zpDestLo),y
ULD_NextActor:  dex
                bpl ULD_LevelDataLoop
                pla
                sta levelNum
                sec                             ;Load new level's leveldata actors

        ; Load level without processing actor removal
        ;
        ; Parameters: levelNum, C=0 do not load leveldata actors, C=1 load
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

LoadLevel:      ror                             ;C to high bit
                sta LL_ActorMode+1
                ldx #$ff
                stx autoDeactObjNum             ;Reset object auto-deactivation
                inx                             ;Assume zone 0 after loading
                stx zoneNum                     ;a new level
                lda levelNum
                ldx #F_LEVEL
                jsr MakeFileName
                jsr BlankScreen                 ;Blank screen, stop level animation
LoadLevelRetry: lda #<lvlObjX                   ;Load level objects & spawners
                ldx #>lvlObjX
                jsr LoadFile
                bcs LoadLevelError
                lda #<lvlName                   ;Load level graphics, animation code &
                ldx #>lvlName                   ;level actors
                jsr LoadFile
                bcs LoadLevelError
                ldy #C_MAP
                jsr LoadAllocFile               ;Load MAP chunk
                bcs LoadLevelError
                ldy #C_BLOCKS
                jsr LoadAllocFile               ;Load BLOCKS chunk
                bcs LoadLevelError
LL_ActorMode:   lda #$00                        ;Check if should copy leveldata actors
                bpl PostLoad
                ldx #MAX_LVLACT-1
LL_PurgeOldLevelDataActors:
                lda lvlActOrg,x                 ;Remove the current leveldata actors
                bpl LL_PurgeNext                ;to make room for new
                lda #$00
                sta lvlActT,x
LL_PurgeNext:   dex
                bpl LL_PurgeOldLevelDataActors
                jsr GetLevelDataActorBits
                ldx #MAX_LVLDATAACT-1           ;Copy level actors
LL_CopyLevelDataActors:
                lda lvlDataActT,x               ;Slot occupied in leveldata?
                beq LL_NextLevelDataActor
                txa
                jsr DecodeBit
                and (zpDestLo),y                ;Check state, whether actor still exists
                beq LL_NextLevelDataActor
                jsr GetNextTempLevelActorIndex  ;It's actually not a temp actor, but use the same
                tay                             ;FIFO indexing scheme
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
                                                ;TODO: at this point item actors at REVEAL-type
                                                ;objects should be re-hidden, as all level objects
                                                ;have been reset to deactivated state

        ; Calculate start addresses for each map-row (of current zone) and for each
        ; block, and set zone multicolors.
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
                rts

        ; Get address of levelactor-bits according to current level
        ;
        ; Parameters: levelNum
        ; Returns: bits address in zpDestLo
        ; Modifies: A,X,loader temp vars

GetLevelDataActorBits:
                ldx levelNum
                lda #<lvlDataActBits
                clc
                adc lvlDataActBitsStart,x
                sta zpDestLo
                lda #>lvlDataActBits
                adc #$00
                sta zpDestHi
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
IO_Done:        rts

        ; Toggle a level object
        ; 
        ; Parameters: Y object number
        ; Returns: -
        ; Modifies: A,X,temp vars

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
                lda #$ff
                ldx lvlObjY,y                 ;Check for animation
                bpl IO_Done

        ; Animate a level object by block deltavalue
        ; 
        ; Parameters: A deltavalue, Y object number
        ; Returns: -
        ; Modifies: A,X,temp vars

AnimateObjectDelta:
                sty temp3
                sta temp4
                lda lvlObjY,y
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
AOD_Done:       rts

        ; Activate a level object
        ;
        ; Parameters: Y object number
        ; Returns: -
        ; Modifies: A,X,temp vars

ActivateObject: lda lvlObjB,y                   ;Make sure that is inactive
                bmi AO_Done
                and #OBJ_TYPEBITS
                tax
                tya
                pha
                cpx #OBJTYPE_SCRIPT             ;Check for action to perform
                beq AO_Script
                cpx #OBJTYPE_SWITCH
                beq AO_Switch
                cpx #OBJTYPE_REVEAL
                beq AO_Reveal
                bne AO_NoOperation

        ; Script execution

AO_Script:      ldx lvlObjDL,y
                lda lvlObjDH,y
                tay
                txa
                jsr ExecScript

        ; No operation / object animation

AO_NoOperation: pla
                tay
                lda lvlObjB,y
                ora #OBJ_ACTIVE
                sta lvlObjB,y
                and #OBJ_AUTODEACT              ;Enable auto-deactivation if necessary
                beq AO_NoAutoDeact
                lda autoDeactObjNum             ;If another object already deactivating,
                bmi AO_NoPreviousAutoDeact      ;deactivate it immediately
                sty temp2
                tay
                jsr InactivateObject
                ldy temp2
AO_NoPreviousAutoDeact:
                sty autoDeactObjNum
                lda #AUTODEACTDELAY
                sta autoDeactObjCounter
AO_NoAutoDeact: lda #$01
                ldx lvlObjY,y                   ;Check for animation
                bmi AnimateObjectDelta
AO_Done:        rts

         ; Switch, activate another object

AO_Switch:      ldx lvlObjDL,y
                lda lvlObjDH,y                  ;Has requirement item?
                beq AO_RequirementOK
                sta temp3
                jsr FindItem
                bcs AO_RequirementOK
                lda #<txtRequired
                ldx #>txtRequired
                ldy #INVENTORY_TEXT_DURATION
                jsr PrintPanelText
                lda temp3
                jsr GetItemName
                jmp ContinuePanelText
AO_RequirementOK:
                txa                             ;Get destination object and toggle it
                tay
                jsr ToggleObject
                jmp AO_NoOperation

        ; Reveal hidden items (weapon closet)

AO_Reveal:      lda lvlObjX,y
                sta AO_RevealXCmp+1
                lda lvlObjY,y
                and #$7f
                sta AO_RevealYCmpHi+1
                tax
                dex
                stx AO_RevealYCmpLo+1
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
                and #$7f
AO_RevealYCmpLo:cmp #$00
                beq AO_DoReveal
AO_RevealYCmpHi:cmp #$00
                bne AO_RevealNext
AO_DoReveal:    sta lvlActY,x
                jsr AddAllActorsNextFrame       ;Hack: add all actors next frame
AO_RevealNext:  dex                             ;to reveal the item as quickly as possible
                bpl AO_RevealLoop
                jmp AO_NoOperation

        ; Update level objects. Handle operation, auto-deactivation and actually entering doors
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

UpdateLevelObjects:
                ldy autoDeactObjNum
                bmi ULO_NoAutoDeact
                dec autoDeactObjCounter
                bne ULO_NoAutoDeact
                lda #$ff
                sta autoDeactObjNum
                jsr InactivateObject
ULO_NoAutoDeact:
ULO_OperateFlag:lda #$00                        ;Check for manual operation of object
                ldx #$00
                stx ULO_OperateFlag+1
                ldy lvlObjNum
                bmi ULO_Done
                tax
                beq ULO_NoOperate
                inc actFd+ACTI_PLAYER           ;Start the doorentry-counter
                lda lvlObjB,y
                bmi ULO_OperateActive
                and #OBJ_MODEBITS
                cmp #OBJMODE_MANUAL             ;Check if manual activation possible
                bcc ULO_NoOperate
                jsr ActivateObject
                jmp ULO_NoOperate
ULO_OperateActive:
                and #OBJ_MODEBITS               ;Object was active, inactivate if possible
                cmp #OBJMODE_MANUALAD
                bcc ULO_NoOperate
                jsr InactivateObject
ULO_NoOperate:  lda lvlObjB,y
                and #OBJ_TYPEBITS+OBJ_ACTIVE
                cmp #OBJTYPE_DOOR+OBJ_ACTIVE    ;Check for ordinary door that is open
                bne ULO_NoDoor
                ldx actF1+ACTI_PLAYER
                cpx #FR_ENTER
                bne ULO_NoDoor
                ldx actFd+ACTI_PLAYER           ;Check for entry delay
                cpx #DOORENTRYDELAY
                bcs ULO_EnterDoor
ULO_NoDoor:     and #OBJ_TYPEBITS               ;Check for side door
                cmp #OBJTYPE_SIDEDOOR
                bne ULO_Done
                lda actXH+ACTI_PLAYER
                cmp lvlObjX,y
                bne ULO_Done
                ldx actXL+ACTI_PLAYER
                cmp limitL                      ;TODO: now side doors must be at
                bne ULO_NotLeftSide             ;zone side boundaries. Permit other locations
                txa
                beq ULO_EnterDoor
                bne ULO_Done
ULO_NotLeftSide:adc #$00
                cmp limitR
                bne ULO_Done
                inx
                beq ULO_EnterDoor
ULO_Done:       rts

ULO_EnterDoor:  jsr RemoveLevelActors           ;Remove all actors except player back to leveldata
                ldy lvlObjNum
                lda lvlObjDL,y                  ;Get destination door
                pha
                lda lvlObjDH,y
                jsr ChangeLevel                 ;Load new level if necessary
                pla
                tay
                jsr BlankScreen
                jsr ActivateObject              ;Activate the door that was entered. Also side-doors
                lda #$80                        ;will get activated but this should not matter
                sta actXL+ACTI_PLAYER
                lda lvlObjX,y
                sta actXH+ACTI_PLAYER
                lda #$00
                sta actYL+ACTI_PLAYER
                sta actSX+ACTI_PLAYER
                lda lvlObjY,y
                and #$7f
                tax
                inx
                stx actYH+ACTI_PLAYER
                lda #MB_GROUNDED
                sta actMB+ACTI_PLAYER
                ldx #ACTI_PLAYER
                jsr MH_StandAnim
                jsr SaveCheckpoint              ;Save checkpoint now. TODO: check for save-disabled zone

        ; Centers player on screen, redraws screen, and adds all actors from leveldata
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

CenterPlayer:   ldx actXH+ACTI_PLAYER
                ldy actYH+ACTI_PLAYER
                jsr FindZoneXY
                jsr SetZoneColors
                iny
                lda (zoneLo),y
                jsr PlaySong                    ;Play zone's music
                jsr InitMap
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
                lda #$80
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
                cmp limitU
                bcs CP_NotOverUp
CP_OverUp:      lda limitU
                ldy #0
                beq CP_NotOverDown
CP_NotOverUp:   cmp temp2
                bcc CP_NotOverDown
                lda temp2
                ldy #2
CP_NotOverDown: sta mapY
                sty blockY
                jsr RedrawScreen
                sty lvlObjNum                   ;Reset found levelobject (Y=$ff)
                jsr AddAllActorsNextFrame
                jmp UpdateActors

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
