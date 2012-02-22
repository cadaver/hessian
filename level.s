ZONEH_LEFT      = 0
ZONEH_RIGHT     = 1
ZONEH_UP        = 2
ZONEH_DOWN      = 3
ZONEH_BG1       = 4
ZONEH_BG2       = 5
ZONEH_BG3       = 6
ZONEH_MUSIC     = 7
ZONEH_DATA      = 8

MAX_MAP_ROWS    = 128
MAX_BLOCKS      = 128

        ; Load a level. TODO: add retry/error handling
        ;
        ; Parameters: A:Level number
        ; Returns: -
        ; Modifies: A,X,Y,temp vars

LoadLevel:      sta levelNum
                ldx #F_LEVEL
                jsr MakeFileName
                lda #<charInfo                  ;Load char/zoneinfos
                ldx #>charInfo
                jsr LoadFile
                ldy #C_MAP
                jsr LoadAllocFile               ;Load MAP chunk
                ldy #C_BLOCKS
                jsr LoadAllocFile               ;Load BLOCKS chunk
                lda #<chars                     ;Finally load chars
                ldx #>chars
                jsr LoadFile
                lda #$00                        ;Assume zone 0 after loading
                sta zoneNum                     ;a new level

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
                ldx #$00                        ;The counter
IM_MapLoop:     cpx limitU                      ;Check if outside zone vertically,
                bcc IM_MapRowOutside            ;store zero address in that case
                cpx limitD
                bcs IM_MapRowOutside
                lda zpSrcLo
                sta mapTblLo,x
                lda zpSrcHi
                bne IM_MapRowDone
IM_MapRowOutside:
                lda #$00
IM_MapRowDone:  sta mapTblHi,x
                lda zpSrcLo
                clc
                adc mapSizeX
                sta zpSrcLo
                bcc IM_NotOver1
                inc zpSrcHi
IM_NotOver1:    inx
                bpl IM_MapLoop
                lda fileLo+C_BLOCKS             ;Address of first block
                sta zpSrcLo
                lda fileHi+C_BLOCKS
                sta zpSrcHi
                ldx #$00
IM_BlockLoop:   lda zpSrcHi                     ;Store and increase block-
                sta blkTblHi,x                  ;pointer
                lda zpSrcLo
                sta blkTblLo,x
                clc
                adc #$10
                sta zpSrcLo
                bcc IM_NotOver2
                inc zpSrcHi
IM_NotOver2:    inx                             
                cpx #MAX_BLK
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
        ; Returns: zoneNum, zone
        ; Modifies: A,X,Y,loader temp vars

FindZoneXY:     stx zpSrcLo
                sty zpSrcHi
                lda #$00
                sta zoneNum
FZXY_Loop:      jsr FZ_GetZonePtr
                lda zpSrcLo
                ldy #ZONEH_LEFT
                cmp (zoneLo),y
                bcc FZXY_Next
                iny
                cmp (zoneLo),y
                bcs FZXY_Next
                iny
                lda zpSrcHi
                cmp (zoneLo),y
                bcc FZXY_Next
                iny
                cmp (zoneLo),y
                bcc FZ_Found
FZXY_Next:      inc zoneNum
                lda zoneNum
                cmp fileNumObjects+C_MAP
                bcc FZXY_Loop
                rts

FindZoneNum:    sta zoneNum
                jsr FZ_GetZonePtr

FZ_Found:       ldy #ZONEH_LEFT
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
                rts

FZ_GetZonePtr:  asl
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
                rts
