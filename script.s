SCRIPT_TITLE    = 0
SCRIPT_ENEMIES  = 1
SCRIPT_JORMUNGANDR = 2
SCRIPT_BOSSES   = 3
SCRIPT_UPGRADE  = 4

EP_TITLE        = $0000

EP_MOVEFLYINGCRAFT = $0100
EP_MOVEWALKER   = $0101
EP_MOVETANK     = $0102
EP_DESTROYFLYINGCRAFT = $0103
EP_MOVETURRET   = $0104
EP_MOVEFIRE     = $0105
EP_MOVESMOKECLOUD = $0106
EP_MOVERAT      = $0107
EP_MOVESPIDER   = $0108
EP_MOVEFLY      = $0109
EP_MOVEBAT      = $010a
EP_MOVEFISH     = $010b
EP_MOVEROCK     = $010c
EP_MOVEFIREBALL = $010d
EP_MOVESTEAM    = $010e
EP_MOVEORGANICWALKER = $010f
EP_DESTROYFIRE  = $0110
EP_RATDEATH     = $0111
EP_SPIDERDEATH  = $0112
EP_FLYDEATH     = $0113
EP_BATDEATH     = $0114
EP_DESTROYROCK  = $0115
EP_ORGANICWALKERDEATH = $0116
EP_MOVELARGEWALKER = $0117
EP_MOVEROCKTRAP   = $0118
EP_MOVEEXPLOSIONGENERATORRISING = $0119
EP_MOVELARGETANK = $011a
EP_MOVEHIGHWALKER = $011b
EP_USEHEALTHRECHARGER = $011c
EP_USEBATTERYRECHARGER = $011d
EP_RECHARGEREFFECT = $011e
EP_ENTERCODE    = $011f
EP_ENTERCODELOOP = $0120
EP_ELEVATOR     = $0121
EP_ELEVATORLOOP = $0122
EP_EXPLODEENEMY2_OFS15 = $0123
EP_EXPLODEENEMY4_OFS15 = $0124
EP_EXPLODEENEMY4_RISING = $0125
EP_DISCONNECTSUBNET = $0126
EP_INSTALLFILTER = $0127

EP_MOVEJORMUNGANDR = $0200

EP_MOVEEYESTAGE1  = $0300
EP_MOVEEYESTAGE2  = $0301
EP_DESTROYEYE     = $0302
EP_MOVESECURITYCHIEF = $0303
EP_DESTROYSECURITYCHIEF = $0304
EP_MOVEROTORDRONE   = $0305
EP_DESTROYROTORDRONE = $0306
EP_MOVELARGESPIDER = $0307
EP_OPENWALL     = $0308
EP_MOVEACID     = $0309
EP_RECYCLINGSTATION = $030a
EP_HIDEOUTDOOR = $030b

EP_CONFIGUREUPGRADE = $0400
EP_INSTALLUPGRADE = $0401
EP_INSTALLEFFECT = $0402

EP_SWITCHGENERATOR = $0500
EP_SWITCHLASER = $0501
EP_INSTALLAMPLIFIER = $0502
EP_RUNLASER = $0503
EP_MOVEGENERATOR = $0504

PLOT_ELEVATOR1  = $00                       ;Upper <-> lower lab
PLOT_ELEVATOR2  = $01                       ;Jormungandr <-> Bio-Dome
PLOT_GENERATOR  = $02                       ;HV Supply switched on
PLOT_AMPINSTALLED = $03                     ;Amplifier installed in laser
PLOT_ROTORDRONE  = $04                      ;Rotordrone boss destroyed

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
        ; Parameters: A script entrypoint, X script file (negative = stop)
        ; Returns: -
        ; Modifies: -
        
StopScript:     ldx #$ff
SetScript:      stx scriptF
                sta scriptEP
ES_LoadOnly:    rts

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
