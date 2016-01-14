                include macros.s

        ; Constants that affect the memory map

MAX_SPR         = 24
MAX_ACT         = 22
MAX_COMPLEXACT  = 7
MAX_CACHESPRITES = 64
MAX_CHUNKFILES   = 26
MAX_MAPROWS     = 128
MAX_BLK         = 192
MAX_LVLDATAACT  = 80                            ;Defined actors per level, on/off persistency
MAX_LVLACT      = 96                            ;Allow extra 16 global or temporary persistent actors
MAX_GLOBALACT   = MAX_LVLACT-MAX_LVLDATAACT
MAX_SAVEACT     = 24                            ;Amount of persistent actors saved in save optimize mode
MAX_LVLOBJ      = 96
MAX_PLOTBITS    = 16
MAX_SAVES       = 5
MAX_PERSISTENTNPCS = 3
MAX_CODES       = 8

ACTI_PLAYER     = 0
ACTI_FIRSTNPC   = 1
ACTI_LASTNPC    = 6
ACTI_FIRSTITEM  = 7
ACTI_LASTITEM   = 11
ACTI_FIRSTPLRBULLET = 12
ACTI_LASTPLRBULLET = 16
ACTI_FIRSTNPCBULLET = 17
ACTI_LASTNPCBULLET = 21
ACTI_FIRSTEFFECT = ACTI_LASTPLRBULLET
ACTI_LASTEFFECT = ACTI_FIRSTNPCBULLET+1

MAX_PERSISTENTACT = ACTI_LASTITEM+1             ;Player + complex actors + items
MAX_BULLETS = ACTI_LASTNPCBULLET-ACTI_FIRSTPLRBULLET+1

SAVEDESCSIZE    = 20
SCRIPTAREASIZE  = 8*256
SCROLLROWS      = 22

STACKSTART      = $7f

        ; Zeropage variables

                varbase $02

                var loadTempReg                 ;Loader variables
                var fileOpen

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
                var scrollWorkFlag
                var shakeScreen
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
                var panelUpdateFlags

                var menuMode                    ;Menu system variables
                var menuCounter
                var menuMoveDelay

                var actIndex                    ;Actor variables
                var actLo
                var actHi
                var tgtActIndex
                var numTargets
                var numSpawned

                var lvlObjNum                   ;Level object variables
                var autoDeactObjNum
                var autoDeactObjCounter

                var wpnLo                       ;Weapon variables
                var wpnHi
                var wpnBits

                var displayedItemName           ;Misc. game variables
                var displayedHealth
                var displayedBattery
                var armorMsgTime
                var healTimer

                var difficulty                  ;Game options
                var musicMode
                var soundMode

                var levelNum                    ;Player ZP state
                var itemIndex
                var lastItemIndex
                var levelActorIndex
                var scriptF
                var scriptEP
                var upgrade
                var reload
                var toxinDelay

playerStateZPStart = levelNum
playerStateZPEnd = toxinDelay+1
palFlag         = freeMemLo

                varrange sprOrder,MAX_SPR+1
                varrange sprY,MAX_SPR+1

                checkvarbase $90

                varbase $c0
                varrange sprXL,MAX_SPR+1
                varrange sprXH,MAX_SPR+1

                var firstSortSpr                ;Frame update/raster IRQ variables
                var newFrame
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

cacheSprFile    = $0180
cacheSprFrame   = $0180+MAX_CACHESPRITES
sprF            = $0200
sprC            = $0200+MAX_SPR
sprAct          = $0200+MAX_SPR*2
cacheSprAge     = $02a7
targetList      = $02a7+MAX_CACHESPRITES

exomizerCodeStart = $0334
loaderCodeStart = $0500
loaderCodeEnd   = $0534

videoBank       = $c000
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
charsetLoadProperties = screen2
sortSprD010     = screen2+SCROLLROWS*40
sprIrqLine      = screen2+SCROLLROWS*40+MAX_SPR*2
sprOrTbl        = screen1+SCROLLROWS*40
sprAndTbl       = screen1+SCROLLROWS*40+MAX_SPR*2
lvlDataActX     = screen2
lvlDataActY     = screen2+MAX_LVLDATAACT
lvlDataActF     = screen2+MAX_LVLDATAACT*2
lvlDataActT     = screen2+MAX_LVLDATAACT*3
lvlDataActWpn   = screen2+MAX_LVLDATAACT*4
introCodeStart  = $f400
musicData       = $f800
