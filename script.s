SCRIPT_TITLE    = 0
SCRIPT_ENEMIES  = 1
SCRIPT_JORMUNGANDR = 2
SCRIPT_BOSSES   = 3
SCRIPT_UPGRADE  = 4

EP_TITLE        = $0000

EP_USEHEALTHRECHARGER = $0100
EP_USEBATTERYRECHARGER = $0101
EP_RECHARGEREFFECT = $0102
EP_ENTERCODE    = $0103
EP_ENTERCODELOOP = $0104
EP_ELEVATOR     = $0105
EP_ELEVATORLOOP = $0106
EP_RADIOUPPERLABSELEVATOR = $0107
EP_RADIOSECURITYPASS = $0108
EP_ESCORTSCIENTISTSSTART = $0109
EP_ESCORTSCIENTISTSREFRESH = $010a
EP_ESCORTSCIENTISTSZONE = $010b
EP_ESCORTSCIENTISTSFINISH = $010c
EP_HACKERFOLLOW = $010d
EP_HACKERFOLLOWZONE = $010e
EP_RADIOSECURITYCENTER = $010f
EP_COMBATROBOTSABOTEUR = $0110
EP_DESTROYCOMBATROBOTSABOTEUR = $0111

EP_GAMESTART    = $0200
EP_SCIENTIST1   = $0201
EP_SCIENTIST2   = $0202
EP_RADIOUPPERLABSENTRANCE = $0203

EP_RECYCLINGSTATION = $0300
EP_MOVEROTORDRONE = $0301
EP_DESTROYROTORDRONE = $0302
EP_HACKER       = $0303
EP_HACKER2      = $0304
EP_HACKER3      = $0305
EP_HACKER4      = $0306

EP_CONFIGUREUPGRADE = $0400
EP_INSTALLUPGRADE = $0401
EP_INSTALLEFFECT = $0402

EP_SWITCHGENERATOR = $0500
EP_SWITCHLASER = $0501
EP_INSTALLAMPLIFIER = $0502
EP_RUNLASER     = $0503
EP_MOVEGENERATOR = $0504
EP_MOVELARGESPIDER = $0505
EP_OPENWALL     = $0506
EP_MOVEACID     = $0507
EP_RADIOLOWERLABS = $0508
EP_RADIOCAVES   = $0509

EP_MOVEJORMUNGANDR = $0600

EP_SUBNETROUTER = $0700
EP_SERVERROOMCOMPUTER = $0701
EP_MOVESCIENTISTS = $0702
EP_RADIOCONSTRUCT = $0703
EP_THRONECHIEF = $0704
EP_FINDFILTER   = $0705
EP_BEGINAMBUSH  = $0706
EP_RADIOCONSTRUCT2 = $0707

EP_BEGINSURGERY = $0800
EP_BEGINSURGERY2 = $0801
EP_AFTERSURGERY = $0802
EP_AFTERSURGERYRUN = $0803
EP_AFTERSURGERYZONE = $0804
EP_AFTERSURGERYNOAIR = $0805
EP_AFTERSURGERYFOLLOW = $0806
EP_AFTERSURGERYNOAIRDIE = $0807
EP_AFTERSURGERYNOAIRRADIO = $0808
EP_REACHOLDTUNNELS = $0809

EP_MOVESECURITYCHIEF = $0900
EP_DESTROYSECURITYCHIEF = $0901
EP_SECURITYCHIEFSPEECH = $0902
EP_HACKERAMBUSH = $0903
EP_GIVELAPTOP = $0904
EP_ENTERBIODOME = $0905
EP_BIODOMEENDING = $0906

EP_HACKERFOLLOWFINISH = $0a00
EP_ENTERLAB = $0a01
EP_HACKERENTERLAB = $0a02
EP_LABCOMPUTER = $0a03
EP_GIVELAPTOP2 = $0a04
EP_SCIENTISTENTERLAB = $0a05
EP_HAZMAT = $0a06
EP_HAZMATLEAVE = $0a07
EP_DESTROYCOMMENT = $0a08
EP_HACKERFINAL = $0a09

EP_TUNNELMACHINE = $0b00
EP_TUNNELMACHINEITEMS = $0b01
EP_TUNNELMACHINERUN = $0b02
EP_RADIOJORMUNGANDR = $0b03
EP_RADIOJORMUNGANDRRUN = $0b04
EP_MOVEEYESTAGE1 = $0b05
EP_MOVEEYESTAGE2 = $0b06
EP_DESTROYEYE = $0b07
EP_CONSTRUCTSPEECH = $0b08
EP_CONSTRUCTENDING = $0b09
EP_DESTROYPLAN = $0b0a

EP_ENDING1 = $0c00
EP_ENDING2 = $0c01
EP_ENDING3 = $0c02

EP_INSTALLLAPTOP = $0d00
EP_INSTALLLAPTOPWORK = $0d01
EP_INSTALLLAPTOPFINISH = $0d02

PLOT_ELEVATOR1  = $00                       ;Upper <-> lower lab
PLOT_ELEVATOR2  = $01                       ;Jormungandr <-> Bio-Dome
PLOT_GENERATOR  = $02                       ;Upper labs generator switched on
PLOT_AMPINSTALLED = $03                     ;Laser amplifier installed
PLOT_HIDEOUTOPEN = $04                      ;Rotordrone boss destroyed
PLOT_BATTERY    = $05                       ;Tunnel machine battery installed
PLOT_FUEL       = $06                       ;Tunnel machine refueled
PLOT_DISRUPTCOMMS = $07                     ;AI communication disrupted with the laptop
PLOT_LOWERLABSNOAIR = $08                   ;Air being sucked from lower labs (must be plotbit 8)
PLOT_MOVESCIENTISTS = $09                   ;Scientists moved to wait in upper labs
PLOT_ELEVATORMSG = $0a                      ;Player attempted lower lab elevator entry
PLOT_ESCORTCOMPLETE = $0b                   ;Scientists got to the operating room
PLOT_OLDTUNNELSLAB1 = $0c                   ;Linda reached old tunnels lab
PLOT_OLDTUNNELSLAB2 = $0d                   ;Jeff reached old tunnels lab
PLOT_HIDEOUTAMBUSH = $0e                    ;Robot ambush to Jeff's hideout ongoing
PLOT_RIGTUNNELMACHINE = $0f                 ;Tunnel machine prepared with explosives for simultaneous destruction

SPEECHBUBBLEOFFSET = -40*8

        ; Execute a script
        ;
        ; Parameters: A script entrypoint, X script file, ES_ParamX+1, ES_ParamY+1 (or Y in ExecScriptParam)
        ; Returns: -
        ; Modifies: A,X,Y,loader temp vars

ExecScriptParam:sty ES_ParamY+1
ExecScript:     pha
ES_LoadedScriptFile:
                cpx #$ff                        ;Check if same file already loaded
                beq ES_SameFile
                stx ES_LoadedScriptFile+1
                txa
                ldx #F_SCRIPT
                jsr MakeFileName
                lda #$00                        ;Reset any text printing in case it was from
                sta textHi                      ;script and will be overwritten
                lda #<scriptCodeStart
                ldx #>scriptCodeStart
                jsr LoadFileRetry
ES_SameFile:    pla
                bmi ES_LoadOnly
                asl
                tax
                lda scriptCodeStart,x
                sta ES_ScriptJump+1
                lda scriptCodeStart+1,x
                sta ES_ScriptJump+2
ES_ParamX:      ldx #$00
ES_ParamY:      ldy #$00
ES_ScriptJump:  jmp $1000

        ; Set/stop a continuous script
        ;
        ; Parameters: A script entrypoint, X script file (0 = stop)
        ; Returns: -
        ; Modifies: -
        
StopScript:     ldx #$00
SetScript:      stx scriptF
                sta scriptEP
ES_LoadOnly:    rts

        ; Set/stop zone transition script
        ;
        ; Parameters: A script entrypoint, X script file (0 = stop)
        ; Returns: -
        ; Modifies: -
        
StopZoneScript: ldx #$00
SetZoneScript:  stx zoneScriptF
                sta zoneScriptEP
                rts

        ; NPC speak a line
        ;
        ; Parameters: Y actor type, A,X text address
        ; Returns: -
        ; Modifies: A,X,Y,temp1-temp4

SpeakLine:      sty SL_ActT+1
                jsr PrintPanelTextIndefinite
SL_ActT:        lda #$00
                jsr FindActor
                bcc SL_NoSpeechBubble
                lda #ACTI_FIRSTEFFECT
                ldy #ACTI_LASTEFFECT
                jsr GetFreeActor
                bcc SL_NoSpeechBubble
                lda #$00
                sta temp1
                sta temp2
                lda #<SPEECHBUBBLEOFFSET
                sta temp3
                lda #>SPEECHBUBBLEOFFSET
                sta temp4
                lda #ACT_SPEECHBUBBLE
                jsr SpawnWithOffset
SL_NoSpeechBubble:
                lda #$00                        ;Reset controls during conversation
                sta actCtrl+ACTI_PLAYER
                sta actMoveCtrl+ACTI_PLAYER
                ldx #MENU_DIALOGUE
                jmp SetMenuMode

        ; Get the value of a plotbit
        ;
        ; Parameters: A plotbit number
        ; Returns: A nonzero if set
        ; Modifies: A,Y

GetPlotBit:     jsr DecodeBit
                and plotBits,y
                rts

        ; Set a plotbit
        ;
        ; Parameters: A plotbit number
        ; Returns: -
        ; Modifies: A,Y

SetPlotBit:     jsr DecodeBit
                ora plotBits,y
                bne CPB_Store

        ; Clear a plotbit
        ;
        ; Parameters: A plotbit number
        ; Returns: -
        ; Modifies: A,Y

ClearPlotBit:   jsr DecodeBit
                eor #$ff
                and plotBits,y
CPB_Store:      sta plotBits,y
                rts

        ; Turn a number into a byte offset into a bit-table and a bitmask
        ;
        ; Parameters: A number
        ; Returns: A bitmask, Y byte offset
        ; Modifies: A,Y

DecodeBit:      pha
                and #$07
                tay
                lda keyRowBit,y
                eor #$ff
                sta DB_Value+1
                pla
                lsr
                lsr
                lsr
                tay
DB_Value:       lda #$00
SameLevel:      rts

        ; Get text resource address (load if necessary)
        ;
        ; Parameters: A text file number, X text number
        ; Returns: A,X address
        ; Modifies: A,X,sprFileLo-Hi,frameLo

GetTextAddress: sty frameLo
                tay
                lda fileHi,y
                bne GTA_Loaded
                jsr LoadSpriteFile              ;Ok to reuse
GTA_Loaded:     sta sprFileHi
                lda fileLo,y
                sta sprFileLo
                lda #$00
                sta fileAge,y
                txa
                asl
                tay
                lda (sprFileLo),y
                pha
                iny
                lda (sprFileLo),y
                tax
                pla
                ldy frameLo
                rts
