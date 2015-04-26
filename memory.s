                include macros.s

        ; Constants that affect the memory map

MAX_SPR         = 24
MAX_ACT         = 21
MAX_COMPLEXACT  = 6
MAX_CACHESPRITES = 64
MAX_CHUNKFILES   = 32
MAX_MAPROWS     = 128
MAX_BLK         = 192
MAX_INVENTORYITEMS = 16
MAX_LVLDATAACT  = 80
MAX_LVLACT      = 96                            ;Allow extra 16 global or temporary persistent actors
MAX_GLOBALACT   = MAX_LVLACT - MAX_LVLDATAACT
MAX_LVLOBJ      = 128                           ;Note: must be 128! And-operations are used in code
MAX_SPAWNERS    = 16
MAX_PLOTBITS    = 64
MAX_ACTORTRIGGERS = 16
MAX_SAVES       = 5
NUM_SKILLS      = 5

ACTI_PLAYER     = 0
ACTI_FIRSTNPC   = 1
ACTI_LASTNPC    = 5
ACTI_FIRSTITEM  = 6
ACTI_LASTITEM   = 10
ACTI_FIRSTPLRBULLET = 11
ACTI_LASTPLRBULLET = 15
ACTI_FIRSTNPCBULLET = 16
ACTI_LASTNPCBULLET = 20
ACTI_FIRSTEFFECT = ACTI_LASTPLRBULLET
ACTI_LASTEFFECT = ACTI_FIRSTNPCBULLET+1

MAX_PERSISTENTACT = ACTI_LASTITEM+1             ;Player + complex actors + items
MAX_SPAWNEDACT = 3
MAX_BULLETS = ACTI_LASTNPCBULLET-ACTI_FIRSTPLRBULLET+1

SAVEDESCSIZE    = 24
SCRIPTAREASIZE  = 8*256
SCROLLROWS      = 23

        ; Zeropage variables

                varbase $02

                var loadTempReg                 ;Loader variables
                var bufferStatus
                var fileOpen
                var ntscFlag

                var zpLenLo                     ;Exomizer 2 depackroutine variables
                var zpSrcLo
                var zpSrcHi
                var zpBitsLo
                var zpBitsHi
                var zpBitBuf
                var zpDestLo
                var zpDestHi

                var temp1                       ;Temp variables
                var temp2
                var temp3
                var temp4
                var temp5
                var temp6
                var temp7
                var temp8

                var freeMemLo                   ;Memory allocator variables
                var freeMemHi

                var joystick                    ;Joystick/keyboard variables
                var prevJoy
                var keyPress
                var keyType

                var screen                      ;Scrolling/map/zone variables
                var scrollX
                var scrollY
                var scrollSX
                var scrollSY
                var scrollCSX
                var scrollCSY
                var scrCounter
                var scrAdd
                var blockX
                var blockY
                var mapX
                var mapY
                var mapSizeX
                var zoneNum
                var zoneLo
                var zoneHi
                var limitL
                var limitR
                var limitU
                var limitD

                var firstSortSpr                ;Sprite multiplexing variables

                var sprIndex                    ;Spritefile access variables
                var sprFileNum
                var sprFileLo
                var sprFileHi
                var frameLo
                var frameHi

                var textLo                      ;Panel text printing variables
                var textHi
                var textTime
                var textDelay
                var textLeftMargin
                var textRightMargin
                var panelUpdateFlags

                var menuMode                    ;Menu system variables
                var menuCounter
                var menuMoveDelay

                var actIndex                    ;Actor variables
                var actLo
                var actHi
                var tgtActIndex
                var numTargets

                var lvlObjNum                   ;Level object variables
                var autoDeactObjNum
                var autoDeactObjCounter

                var wpnLo                       ;Weapon variables
                var wpnHi
                var wpnBits
                var magazineSize

                var displayedItemName           ;Misc. game variables
                var displayedHealth
                var healthRecharge

                var difficulty                  ;Game options
                var musicMode
                var soundMode

                var levelNum                    ;Player state
                var itemIndex
                var nextTempLvlActIndex

playerStateZPStart = levelNum
playerStateZPEnd = nextTempLvlActIndex+1

                varrange sprOrder,MAX_SPR+1
                varrange sprY,MAX_SPR+1

                checkvarbase $90

                varbase $c0
                varrange sprXL,MAX_SPR+1
                varrange sprXH,MAX_SPR+1

                var newFrame                    ;Frame update/raster IRQ variables
                var ntscDelay
                var irqSaveA
                var irqSaveX
                var irqSaveY
                var irqSave01

                var ntInitSong                  ;Playroutine
                var ntTemp1
                var ntTemp2
                var ntTrackLo
                var ntTrackHi
                var ntFiltPos
                var ntFiltTime
                var ntFiltCutoff

                checkvarbase $100

        ; Memory areas and non-zeropage variables

sprF            = $0100
sprC            = $0118
sprAct          = $0130
cacheSprAge     = $0148
cacheSprFile    = $0200
cacheSprFrame   = $02a7

mainCodeStart   = $0334

spriteCache     = $d000
fileAreaEnd     = spriteCache
colors          = $d800
textChars       = $e000
emptySprite     = $e300
panelScreen     = $e000
mapTblLo        = $e000
mapTblHi        = $e080
blkTblLo        = $e400
loadBuffer      = mapTblLo
blkTblHi        = $e4c0
depackBuffer    = blkTblLo + 1
lvlCodeStart    = $e580
charInfo        = $e600
charColors      = $e700
chars           = $e800
introStart      = $ec00
screen2         = $f000
screen1         = $f400
blockInfo       = screen2+SCROLLROWS*40
sprOrTbl        = screen1+SCROLLROWS*40
sprAndTbl       = screen1+SCROLLROWS*40+MAX_SPR*2
lvlDataActX     = screen2
lvlDataActY     = screen2+MAX_LVLDATAACT
lvlDataActF     = screen2+MAX_LVLDATAACT*2
lvlDataActT     = screen2+MAX_LVLDATAACT*3
lvlDataActWpn   = screen2+MAX_LVLDATAACT*4
lvlLoadName     = screen2+MAX_LVLDATAACT*5
lvlLoadWaterDamage = screen2+MAX_LVLDATAACT*5+16
lvlLoadWaterSplashColor = screen2+MAX_LVLDATAACT*5+17
introCodeStart  = $f400
musicData       = $f800
