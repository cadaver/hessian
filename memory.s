                include Macros.s

        ; Constants that affect the memory map

MAX_SPR         = 24
MAX_ACT         = 24
MAX_COMPLEXACT  = 6
MAX_CACHESPRITES = 63

        ; Zeropage variables

                VarBase $02

                Var loadTempReg                 ;Loader variables
                Var bufferStatus
                Var fileOpen
                Var zpLenLo                     ;Exomizer 2 depackroutine variables
                Var zpSrcLo
                Var zpSrcHi
                Var zpBitsLo
                Var zpBitsHi
                Var zpBitBuf
                Var zpDestLo
                Var zpDestHi

                Var newFrame                    ;Frame update/zeropage variables
                Var irqSaveA
                Var irqSaveX
                Var irqSaveY
                Var irqSave01

                Var freeMemLo                   ;Memory allocator variables
                Var freeMemHi

                Var screen                      ;Scrolling/map/zone variables
                Var scrollX
                Var scrollY
                Var scrollSX
                Var scrollSY
                Var scrollCSX
                Var scrollCSY
                Var scrCounter
                Var scrAdd
                Var blockX
                Var blockY
                Var mapX
                Var mapY
                Var levelNum
                Var zoneNum
                Var zoneLo
                Var zoneHi
                Var limitL
                Var limitR
                Var limitU
                Var limitD
                Var mapSizeX

                Var firstSortSpr                ;Sprite multiplexing variables

                Var sprIndex                    ;Spritefile access variables
                Var sprFileNum
                Var sprFileLo
                Var sprFileHi
                Var frameLo
                Var frameHi

                Var actIndex                    ;Actor variables
                Var actLo
                Var actHi

                Var temp1                       ;Temp variables
                Var temp2
                Var temp3
                Var temp4
                Var temp5
                Var temp6
                Var temp7
                Var temp8

                VarRange sprX,MAX_SPR
                VarRange sprY,MAX_SPR+1
                VarRange sprF,MAX_SPR

                CheckVarBase $90

                VarBase $c0

                VarRange sprC,MAX_SPR
                VarRange sprOrder,MAX_SPR+1
                
                Var joystick                    ;Joystick/keyboard variables
                Var prevJoy
                Var keyPress
                Var keyType
                VarRange keyRowTbl,8

                Var ntTemp1                     ;Playroutine
                Var ntTemp2

                CheckVarBase $100

        ; Memory areas and non-zeropage variables

depackCodeStart = $0100

cacheSprFile    = $0100

cacheSprFrame   = $0200

cacheSprInUse   = $02a7
vColBuf         = $02a7+MAX_CACHESPRITES

mainCodeStart   = $0334

fileAreaEnd     = $d000
spriteCache     = $d000
emptySprite     = $dfc0
colors          = $d800
chars           = $e000
screen1         = $e800
screen2         = $ec00
textChars       = $f000
hColBuf         = colors+39
sprOrTbl        = screen2+1016-MAX_SPR*4
sprAndTbl       = screen2+1016-MAX_SPR*2
loadBuffer      = $f400
depackBuffer    = $f501
mapTblLo        = $f400                         ;Map/blocktables need to be always reinitialized
mapTblHi        = $f480                         ;after loading
blkTblLo        = $f500
blkTblHi        = $f580
musicData       = $f600

