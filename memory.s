                include Macros.s

        ; Constants that affect the memory map

MAX_SPR         = 24
MAX_ACT         = 24
MAX_COMPLEXACT  = 7
MAX_CACHESPRITES = 64
MAX_MAPROWS     = 128
MAX_BLK         = 192
MAX_LVLACT      = 128

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

                Var ntscDelay                   ;Frame update/raster IRQ variables
                Var targetFrames
                Var newFrame
                Var irqSaveA
                Var irqSaveX
                Var irqSaveY
                Var irqSave01

                Var joystick                    ;Joystick/keyboard variables
                Var prevJoy
                Var keyPress
                Var keyType

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
                Var tgtActIndex
                Var addActorIndex

                Var wpnLo                       ;Weapon variables
                Var wpnHi
                Var itemIndex

                Var textLo                      ;Panel text printing variables
                Var textHi
                Var textTime
                Var textDelay
                Var textLeftMargin
                Var textRightMargin
                Var panelUpdateFlags

                Var temp1                       ;Temp variables
                Var temp2
                Var temp3
                Var temp4
                Var temp5
                Var temp6
                Var temp7
                Var temp8

                VarRange sprOrder,MAX_SPR+1
                VarRange sprY,MAX_SPR+1

                CheckVarBase $90

                VarBase $c0
                VarRange sprXL,MAX_SPR
                VarRange sprXH,MAX_SPR
                Var ntTemp1                     ;Playroutine
                Var ntTemp2
                Var ntTrackLo
                Var ntTrackHi
                Var ntFiltPos
                Var ntFiltTime

                CheckVarBase $100

        ; Memory areas and non-zeropage variables

depackCodeStart = $0100

sprF            = $0100
sprC            = $0100+MAX_SPR
sprAct          = $0100+MAX_SPR*2
cacheSprInUse   = $0100+MAX_SPR*3
cacheSprFile    = $0200
cacheSprFrame   = $02a7

mainCodeStart   = $0334

mapTblLo        = $cf00
mapTblHi        = $cf80
fileAreaEnd     = mapTblLo
loadBuffer      = mapTblLo
spriteCache     = $d000
colors          = $d800
chars           = $e000
screen1         = $e800
screen2         = $ec00
heroList        = screen2+1016-MAX_SPR*4-(MAX_COMPLEXACT+1)*2
villainList     = screen2+1016-MAX_SPR*4-(MAX_COMPLEXACT+1)
sprOrTbl        = screen2+1016-MAX_SPR*4
sprAndTbl       = screen2+1016-MAX_SPR*2
textChars       = $f000
charInfo        = $f300
charColors      = $f400
lvlActX         = $f500
lvlActY         = $f580
lvlActF         = $f600
lvlActT         = $f680
lvlActWpn       = $f700
blkTblLo        = $f780
blkTblHi        = $f840
depackBuffer    = blkTblHi+1
musicData       = $f900
