SCRIPT_TITLE    = 0
SCRIPT_ENEMIES  = 1

EP_TITLE        = $0000
EP_MOVEDROID    = $0100
EP_MOVEFLYINGCRAFT = $0101
EP_MOVEWALKER   = $0102
EP_MOVETANK     = $0103
EP_MOVEFLOATINGMINE = $0104
EP_MOVETURRET   = $0105
EP_MOVEFIRE     = $0106
EP_MOVESMOKECLOUD = $0107
EP_MOVERAT      = $0108
EP_MOVESPIDER   = $0109
EP_MOVEFLY      = $010a
EP_MOVEBAT      = $010b
EP_MOVEFISH     = $010c
EP_MOVEROCK     = $010d
EP_MOVEFIREBALL = $010e
EP_MOVESTEAM    = $010f
EP_MOVEORGANICWALKER = $0110
EP_DESTROYFIRE  = $0111
EP_RATDEATH     = $0112
EP_SPIDERDEATH  = $0113
EP_FLYDEATH     = $0114
EP_BATDEATH     = $0115
EP_DESTROYROCK  = $0116
EP_ORGANICWALKERDEATH = $0117
EP_MOVELARGEWALKER = $0118
EP_EXPLODE2_8 = $0119
EP_EXPLODE2_8_OFS6 = $011a
EP_EXPLODE2_8_OFS10 = $011b
EP_EXPLODE3_OFS15 = $011c
EP_EXPLODE4_OFS15 = $011d
EP_MOVESCRAPMETAL = $011e
EP_MOVEROCKTRAP   = $011f
EP_DESTROYCPU     = $0120
EP_MOVEEYESTAGE1  = $0121
EP_MOVEEYESTAGE2  = $0122
EP_DESTROYEYE     = $0123
EP_MOVEJORMUNGANDR = $0200

AT_ADD          = 1
AT_REMOVE       = 2
AT_DESTROY      = 4
AT_NEAR         = 8

SPEECHBUBBLEOFFSET = -40*8

        ; Set or modify trigger for an actor type
        ;
        ; Parameters: A Script entrypoint, X script file, Y actor type, temp1 trigger mask
        ; Returns: -
        ; Modifies: A,X,Y,zpSrcLo

SetActorTrigger:pha
                jsr ATSearch                    ;Either search for existing or create new
                pla
                sta atScriptEP,y
                txa
                sta atScriptF,y
                lda zpSrcLo
                sta atType,y
                lda temp1
                sta atMask,y
                rts

        ; Remove trigger from an actor type
        ;
        ; Parameters: Y actor type
        ; Returns: -
        ; Modifies: A,Y,zpSrcLo

RemoveActorTrigger:
                jsr ATSearch
                bcc RAT_NotFound
RAT_Loop:       lda atType+1,y
                sta atType,y
                lda atScriptEP+1,y
                sta atScriptEP,y
                lda atScriptF+1,y
                sta atScriptF,y
                lda atMask+1,y
                sta atMask,y
                iny
                cpy #MAX_ACTORTRIGGERS
                bcc RAT_Loop
RAT_NotFound:   rts

ATSearch:       sty zpSrcLo
                ldy #$00
ATSearch_Loop:  lda atType,y
                beq ATSearch_NotFound
ATSearch_Cmp:   cmp zpSrcLo
                beq ATSearch_Found              ;C=1 if found existing
                iny
                bne ATSearch_Loop
ATSearch_NotFound:
                clc
ATSearch_Found: rts

        ; Run an actor trigger routine
        ;
        ; Parameters: Y trigger type (mask bit), X actor number
        ; Returns: -
        ; Modifies: A,Y,loader temp vars

ActorTrigger:   lda actFlags,x
                and #AF_USETRIGGERS             ;First check: does the actor use triggers at all?
                beq AT_Fail
ActorTriggerNoFlagCheck:
                sty ES_ParamY+1
                ldy actT,x
                jsr ATSearch
                bcc AT_Fail
                lda atMask,y
AT_MaskCheck:   and ES_ParamY+1
                beq AT_Fail
                stx ES_ParamX+1
                lda atScriptEP,y
                ldx atScriptF,y
                jsr ExecScript
                ldx ES_ParamX+1
ES_LoadOnly:
AT_Fail:        rts

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
