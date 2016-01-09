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
EP_TUNNELREROUTE = $0107
EP_RECYCLINGSTATION = $0108
EP_SUBNETROUTER = $0109
EP_INSTALLFILTER = $010a ;TODO replace
EP_TUNNELMACHINE = $010b
EP_TUNNELMACHINEITEMS = $010c
EP_TUNNELMACHINERUN = $010d
EP_RADIOUPPERLABSELEVATOR = $010e

EP_SCIENTIST1   = $0200
EP_CREATEPERSISTENTNPCS = $0201                 ;Used for testing. Once game is final, trigger object can be removed
EP_SCIENTIST2   = $0202
EP_RADIOUPPERLABSENTRANCE = $0203

EP_MOVEEYESTAGE1 = $0300
EP_MOVEEYESTAGE2 = $0301
EP_DESTROYEYE   = $0302
EP_MOVESECURITYCHIEF = $0303
EP_DESTROYSECURITYCHIEF = $0304
EP_MOVEROTORDRONE = $0305
EP_DESTROYROTORDRONE = $0306
EP_HIDEOUTDOOR  = $0307
EP_HACKER       = $0308

EP_CONFIGUREUPGRADE = $0400
EP_INSTALLUPGRADE = $0401
EP_INSTALLEFFECT = $0402

EP_SWITCHGENERATOR = $0500
EP_SWITCHLASER = $0501
EP_INSTALLAMPLIFIER = $0502
EP_RUNLASER = $0503
EP_MOVEGENERATOR = $0504
EP_MOVELARGESPIDER = $0505
EP_OPENWALL     = $0506
EP_MOVEACID     = $0507
EP_RADIOLOWERLABS = $0508

EP_MOVEJORMUNGANDR = $0600

PLOT_ELEVATOR1  = $00                       ;Upper <-> lower lab
PLOT_ELEVATOR2  = $01                       ;Jormungandr <-> Bio-Dome
PLOT_GENERATOR  = $02                       ;Upper labs generator switched on
PLOT_AMPINSTALLED = $03                     ;Laser amplifier installed
PLOT_ROTORDRONE  = $04                      ;Rotordrone boss destroyed
PLOT_BATTERY    = $05                       ;Tunnel machine battery installed
PLOT_FUEL       = $06                       ;Tunnel machine refueled
PLOT_WALLBREACHED = $07                     ;Tunnel machine has been used

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
