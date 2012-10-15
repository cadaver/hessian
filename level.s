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

InitLevel       = lvlCodeStart
UpdateLevel     = lvlCodeStart+3

        ; Load a level. TODO: add retry/error handling
        ;
        ; Parameters: A Level number
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

LoadLevel:      sta levelNum
                lda #$00                        ;Assume zone 0 after loading
                sta zoneNum                     ;a new level
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

OperateObject:  lda actMoveCtrl,x               ;Only operate on the first frame
                cmp actPrevCtrl,x               ;TODO: play sound
                beq OO_Done
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
        ; Modifies: A,Y,temp vars
        
InactivateObject:
                lda lvlObjB,y                 ;Make sure that is active
                bpl OO_Done
                and #$ff-OBJ_ACTIVE
                sta lvlObjB,y
                lda lvlObjY,y                 ;Check for animation
                bpl OO_Done
                lda #$ff

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
        ; Modifies: A,Y,temp vars

ActivateObject: lda lvlObjB,y                 ;Make sure that is inactive
                bmi OO_Done
                ora #OBJ_ACTIVE
                sta lvlObjB,y
                lda lvlObjY,y                 ;Check for animation
                bpl OO_Done
                lda #$01
                bne AnimateObjectDelta

