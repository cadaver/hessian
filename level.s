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
OBJTYPE_SIDEDOOR = $08

DOORENTRYDELAY  = 4
AUTODEACTDELAY  = 12

InitLevel       = lvlCodeStart
UpdateLevel     = lvlCodeStart+3

        ; Load a level. TODO: add retry/error handling
        ;
        ; Parameters: A Level number
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

LoadLevel:      sta levelNum
                lda #$ff
                sta autoDeactObjNum             ;Reset object auto-deactivation
                lda #$00                        ;Assume zone 0 after loading
                sta zoneNum                     ;a new level
                sta doorEntry                   ;Reset door entering
                sta Irq4_LevelUpdate+1          ;No level update while loading
                ldx #F_LEVEL
                jsr MakeFileName
                jsr BlankScreen
                lda #<lvlActX                   ;Load levelactors, chars & charinfo/colors
                ldx #>lvlActX
                jsr LoadFile
                ldy #C_MAP
                jsr LoadAllocFile               ;Load MAP chunk
                ldy #C_BLOCKS
                jsr LoadAllocFile               ;Load BLOCKS chunk
                jsr InitLevel
                inc Irq4_LevelUpdate+1          ;Can update now

        ; Calculate start addresses for each map-row (of current zone) and for each
        ; block, and set zone multicolors. Also re-enables raster interrupts if disabled
        ; by serial device Kernal loading mode.
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,loader temp vars

PostLoad:       lda #$01                        ;Re-enable raster interrupts if disabled
                sta $d01a                       ;by the loader
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

        ; Set zone multicolors for the raster interrupt
        ;
        ; Parameters: zone
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
AOD_Done:
OO_Done:        rts

        ; Operate a level object
        ;
        ; Parameters: X player actor index (0), Y object number
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

OO_Hold:        lda lvlObjB,y                 ;If holding joystick up, increment
                bpl OO_Done                   ;door entry counter for doors, first
                and #OBJ_TYPEBITS             ;check the door is still open
                cmp #OBJTYPE_DOOR
                bne OO_Done
                cpy autoDeactObjNum           ;Reset door auto-deactivation timer
                bne OO_NoDoorAutoDeact        ;while holding
                lda #AUTODEACTDELAY
                sta autoDeactObjCounter
OO_NoDoorAutoDeact:
                inc doorEntry
                jmp OO_Done

OperateObject:  lda actMoveCtrl,x             ;Only activate on the frame joystick pushed up,
                cmp actPrevCtrl,x             ;not when holding
                beq OO_Hold
                lda #FR_ENTER                 ;Todo: play sound
                sta actF1,x
                sta actF2,x
                lda lvlObjB,y
                bmi OO_Active
OO_Inactive:    jmp ActivateObject
OO_Active:      and #OBJ_MODEBITS
                cmp #OBJMODE_MANUALAD
                bne OO_Done
                
        ; Inactivate a level object
        ; 
        ; Parameters: Y object number
        ; Returns: -
        ; Modifies: A,X,Y,temp vars
        
InactivateObject:
                lda lvlObjB,y                 ;Make sure that is active
                bpl OO_Done
                and #$ff-OBJ_ACTIVE
                sta lvlObjB,y
                lda #$ff
                ldx lvlObjY,y                 ;Check for animation
                bpl OO_Done

AnimateObjectDelta:
                sta temp2
                sty temp1
                lda lvlObjY,y
                jsr AOD_Sub
                ldy temp1
                lda lvlObjB,y
                and #OBJ_SIZE
                beq AOD_Done
                lda lvlObjY,y
                sec
                sbc #$01
AOD_Sub:        and #$7f
                ldx lvlObjX,y
                tay
                lda temp2
                jmp UpdateBlockDelta

        ; Activate a level object
        ;
        ; Parameters: Y object number
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

ActivateObject: lda lvlObjB,y                 ;Make sure that is inactive
                bmi AO_Done
                ora #OBJ_ACTIVE
                sta lvlObjB,y
                and #OBJ_AUTODEACT            ;Enable auto-deactivation if necessary
                beq AO_NoAutoDeact
                lda autoDeactObjNum           ;If another object already deactivating,
                bmi AO_NoPreviousAutoDeact    ;deactivate it immediately
                sty temp3
                tay
                jsr InactivateObject
                ldy temp3
AO_NoPreviousAutoDeact:
                sty autoDeactObjNum
                lda #AUTODEACTDELAY
                sta autoDeactObjCounter
AO_NoAutoDeact: lda #$01
                ldx lvlObjY,y                 ;Check for animation
                bmi AnimateObjectDelta
ULO_Done:
AO_Done:        rts

        ; Update level objects. Handle auto-deactivation and actually entering doors
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
ULO_NoAutoDeact:ldy lvlObjNum
                bmi ULO_Done
                lda doorEntry
                cmp #DOORENTRYDELAY
                bcs ULO_EnterDoor
                lda lvlObjB,y                   ;Check for side door
                and #OBJ_TYPEBITS
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
                cpx #$ff
                bcc ULO_Done

ULO_EnterDoor:  lda lvlObjDL,y                 ;Get destination door. TODO: handle level change
                tay
                lda #$80
                sta actXL+ACTI_PLAYER
                lda lvlObjX,y
                sta actXH+ACTI_PLAYER
                lda #$00
                sta actYL+ACTI_PLAYER
                sta actSX+ACTI_PLAYER
                sta doorEntry
                lda lvlObjY,y
                and #$7f
                tax
                inx
                stx actYH+ACTI_PLAYER
                lda #FR_STAND
                sta actF1+ACTI_PLAYER
                sta actF2+ACTI_PLAYER
                lda #MB_GROUNDED
                sta actMB+ACTI_PLAYER

        ; Centers player on screen, redraws screen, and adds all actors from leveldata
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

CenterPlayer:   jsr BlankScreen
                ldx actXH+ACTI_PLAYER
                ldy actYH+ACTI_PLAYER
                jsr FindZoneXY
                jsr InitMap
                lda limitR
                sec
                sbc #10
                sta temp1
                lda limitD
                sbc #6
                sta temp2
                ldx #3
                ldy #2
                lda actXH+ACTI_PLAYER
                sbc #5
                bcc CP_OverLeft
                cmp limitL
                bcs CP_NotOverLeft
CP_OverLeft:    lda limitL
                ldx #0
CP_NotOverLeft: cmp temp1
                bcc CP_NotOverRight
                lda temp1
                ldx #1
CP_NotOverRight:sta mapX
                lda actYH+ACTI_PLAYER
                sec
                sbc #4
                bcc CP_OverUp
                cmp limitU
                bcs CP_NotOverUp
CP_OverUp:      lda limitU
                ldy #0
CP_NotOverUp:   cmp temp2
                bcc CP_NotOverDown
                lda temp2
                ldy #2
CP_NotOverDown: sta mapY
                stx blockX
                sty blockY
                jsr RedrawScreen
                jmp UpdateAndAddAllActors
