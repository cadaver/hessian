                include macros.s
                include mainsym.s

CHUNK_DURATION = 40

        ; Script 7, lower labs interactions

                org scriptCodeStart

                dc.w DisconnectSubnet
                dc.w ServerRoomComputer
                dc.w MoveScientists
                dc.w RadioConstruct
                dc.w ThroneChief
                dc.w FindFilter
                dc.w BeginAmbush
                dc.w RadioConstruct2

        ; Subnet router script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

DisconnectSubnet:
                jsr AddQuestScore
                lda #SFX_POWERUP
                jsr PlaySfx
                lda #<txtDisconnected
                ldx #>txtDisconnected
                ldy #REQUIREMENT_TEXT_DURATION
                jsr PrintPanelText
                lda lvlObjB+$4d
                bpl DS_NotBoth
                lda lvlObjB+$4e
                bpl DS_NotBoth
                lda codes+MAX_CODES*3-1         ;Make nether tunnel entry possible
                and #$7f
                sta codes+MAX_CODES*3-1
                lda #PLOT_ELEVATOR1
                jmp SetPlotBit
DS_NotBoth:     rts

        ; Server room computer script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ServerRoomComputer:
                if SKIP_PLOT > 0
                lda #$80
                sta lvlObjB+$4d
                sta lvlObjB+$4e
                jsr DisconnectSubnet
                endif
                jsr SetupTextScreen
                lda #0
                sta temp1
                sta temp2
                lda #<txtMasterRouter
                ldx #>txtMasterRouter
                jsr PrintMultipleRows
                lda #10
                sta temp1
                lda #2
                sta temp2
                lda lvlObjB+$4d
                jsr PrintSubnetText
                inc temp2
                lda lvlObjB+$4e
                jsr PrintSubnetText
                ldy #0
                sty temp1
                ldy #5
                sty temp2
                lda #PLOT_ELEVATOR1
                jsr GetPlotBit
                beq SRC_SecurityOn
SRC_SecurityOff:
                lda #<txtProtocolOff
                ldx #>txtProtocolOff
                bne SRC_Common
SRC_SecurityOn:
                lda #<txtProtocolOn
                ldx #>txtProtocolOn
SRC_Common:     jsr PrintMultipleRows
                lda codes+MAX_CODES*3-1
                bmi SRC_NoCode
SRC_ShowCode:   ldx #2
                ldy #4
SRC_CodeLoop:   lda codes+MAX_CODES*3-3,x
                ora #$30
                sta screen1+7*40+26,y
                dey
                dey
                dex
                bpl SRC_CodeLoop
                lda #PLOT_MOVESCIENTISTS
                jsr GetPlotBit
                bne SRC_AlreadyMoved
                lda #<EP_MOVESCIENTISTS
                ldx #>EP_MOVESCIENTISTS
                jsr SetScript
SRC_AlreadyMoved:
SRC_WaitExitCommon:
                jsr WaitForExit
                jmp CenterPlayer
SRC_NoCode:     lda #26
                sta temp1
                lda #7
                sta temp2
                lda #<txtNA
                ldx #>txtNA
                jsr PrintText
                jmp SRC_WaitExitCommon

PrintSubnetText:bmi PST_Isolated
                lda #<txtConnected
                ldx #>txtConnected
                jmp PrintText
PST_Isolated:   lda #<txtIsolated
                ldx #>txtIsolated
                jmp PrintText

        ; Move scientists script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

MoveScientists: jsr StopScript
                jsr AddQuestScore
                lda #PLOT_MOVESCIENTISTS
                jsr SetPlotBit
                ldy lvlDataActBitsStart+$06
                lda lvlStateBits+2,y            ;Forcibly remove the enemies from the
                and #$ff-$04-$08                ;upper labs recycler room (enemy ID's
                sta lvlStateBits+2,y            ;12,13,2c, must not change)
                lda lvlStateBits+5,y
                and #$ff-$10
                sta lvlStateBits+5,y
                lda #ACT_SCIENTIST2             ;Then move the persistent NPCs
                jsr FindLevelActor
                lda #$37
                jsr MoveScientistSub
                lda #ACT_SCIENTIST3
                jsr FindLevelActor
                lda #$36
                jsr MoveScientistSub
                lda #<EP_ESCORTSCIENTISTSSTART
                sta actScriptEP
                lda #>EP_ESCORTSCIENTISTSSTART
                sta actScriptF
                if SKIP_PLOT > 0
                lda #PLOT_ESCORTCOMPLETE
                jsr SetPlotBit
                lda #<EP_FINDFILTER
                ldx #>EP_FINDFILTER
                jmp ExecScript
                endif
                lda #<txtRadioMoveScientists
                ldx #>txtRadioMoveScientists
RadioMsg:       pha
                lda #SFX_RADIO
                jsr PlaySfx
                pla
                ldy #ACT_PLAYER
                jmp SpeakLine

MoveScientistSub:
                sta lvlActX,y
                lda #$13
                sta lvlActY,y
                lda #$20+AIMODE_TURNTO
                sta lvlActF,y
                lda #$06+ORG_GLOBAL
                sta lvlActOrg,y
                rts

        ; Radio briefing on Construct
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioConstruct: lda #PLOT_MOVESCIENTISTS
                jsr GetPlotBit
                beq HP_TryAgain
                lda #<EP_HACKER3                ;Advance Jeff script now
                sta actScriptEP+2
                lda #>EP_HACKER3
                sta actScriptF+2
                lda #<txtRadioConstruct
                ldx #>txtRadioConstruct
                jmp RadioMsg
HP_TryAgain:    ldy lvlObjNum
                jmp InactivateObject

        ; Throne chief corpse
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ThroneChief:    lda #ITEM_BIOMETRICID           ;Todo: cutscene
                sta temp2
                ldx #1
                jsr AddItem
                jsr TP_PrintItemName
SetupAmbush:    lda #<EP_BEGINAMBUSH            ;On next zone transition
                ldx #>EP_BEGINAMBUSH
                jmp SetZoneScript

        ; Find filter script. Also move scientists to final positions before surgery
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

FindFilter:     jsr StopZoneScript
                lda #ACT_SCIENTIST3
                jsr FindLevelActor
                lda #$3f
                ldx #$30+AIMODE_TURNTO
                jsr MoveScientistSub2
                lda #ACT_SCIENTIST2
                jsr FindLevelActor
                lda #$42
                ldx #$00+AIMODE_TURNTO
                jsr MoveScientistSub2
                lda #<EP_BEGINSURGERY
                sta actScriptEP
                lda #>EP_BEGINSURGERY
                sta actScriptF
                jsr SetupAmbush
                lda #<txtRadioFindFilter
                ldx #>txtRadioFindFilter
                jmp RadioMsg
MoveScientistSub2:
                sta lvlActX,y                   ;Set also Y & level so that this can be used as shortcut in testing
                lda #$56
                sta lvlActY,y
                txa
                sta lvlActF,y
                lda #$08+ORG_GLOBAL
                sta lvlActOrg,y
BA_Skip:        rts

        ; Begin hideout ambush
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BeginAmbush:    jsr StopZoneScript
                lda #PLOT_ELEVATOR1             ;No action until elevator fixed and has the biometric ID
                jsr GetPlotBit
                beq BA_Skip
                ldy #ITEM_BIOMETRICID
                jsr FindItem
                bcc BA_Skip
                lda #
                lda #PLOT_HIDEOUTOPEN           ;Already resolved?
                jsr GetPlotBit
                beq BA_Skip
                lda #PLOT_HIDEOUTAMBUSH         ;Already happening?
                jsr GetPlotBit
                bne BA_Skip
                lda #ACT_HACKER                 ;Check that Jeff is in hideout
                jsr FindLevelActor
                lda lvlActOrg,y
                cmp #$04+ORG_GLOBAL
                bne BA_Skip
                lda #PLOT_HIDEOUTAMBUSH
                jsr SetPlotBit
                ldy lvlDataActBitsStart+$04     ;Enable ambush enemies now
                lda lvlStateBits+2,y
                ora #$c0
                sta lvlStateBits+2,y
                lda lvlStateBits+3,y
                ora #$03
                sta lvlStateBits+3,y
                lda #<EP_HACKERAMBUSH
                sta actScriptEP+2
                lda #>EP_HACKERAMBUSH
                sta actScriptF+2
                lda #<EP_RADIOCONSTRUCT2
                ldx #>EP_RADIOCONSTRUCT2
                jmp SetScript

        ; Radio briefing on Construct, part 2 (when ambush begins)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioConstruct2:jsr StopScript
                lda #<txtRadioConstruct2
                ldx #>txtRadioConstruct2
                jmp RadioMsg

        ; Messages

txtDisconnected:dc.b "SUBNET "
txtIsolated:    dc.b "ISOLATED",0

txtMasterRouter:dc.b "LOWER LABS MASTER ROUTER STATION",0
                dc.b " ",0
                dc.b "SUBNET 1:",0
                dc.b "SUBNET 2:",0
                dc.b " ",0
                dc.b " ",0
                dc.b " ",0
                dc.b "NETHER TUNNEL ENTRY CODE:",0,0

txtConnected:   dc.b "CONNECTED",0
txtProtocolOn:  dc.b "CONSTRUCT SECURITY PROTOCOL ENGAGED",0
                dc.b "ELEVATOR LOCKED DOWN",0,0

txtProtocolOff: dc.b "SECURITY PROTOCOL OFF",0
                dc.b "ELEVATOR UNLOCKED",0,
txtNA:          dc.b "N/A",0

txtRadioMoveScientists:
                dc.b 34,"AMOS HERE. GREAT JOB FIXING THE ELEVATOR. WE'VE FIGURED OUT THE NEXT STEP "
                dc.b "AND NEED TO REACH THE LOWER LABS NOW. BUT GOING ON OUR OWN IS LIKELY TO "
                dc.b "GET US KILLED. WE MANAGED TO SAFELY REACH THE UPPER LABS RECYCLING STATION, MEET US THERE.",34,0
txtRadioConstruct:
                dc.b 34,"KIM, IT'S JEFF. I'VE BEEN DECRYPTING MORE OF THE MACHINES' TRAFFIC. 'CONSTRUCT' HAS TO BE THE NAME OF THE CENTRAL AI. "
                dc.b "IT TASKED THE MACHINES TO BUILD 'JORMUNGANDR.' AMOUNT OF MATERIALS USED WAS ASTRONOMICAL. "
                dc.b "IF THEY FOLLOW NORSE MYTHS, THAT SHOULD BE ONE HUGE SERPENT. FUN, RIGHT?",34,0
txtRadioFindFilter:
                dc.b 34,"LINDA HERE. WE GOT AHEAD OF OURSELVES - THERE ARE NO LUNG FILTERS STORED HERE. SINCE YOU'RE MUCH BETTER SUITED TO EXPLORING, "
                dc.b "WE'LL HAVE TO ASK YOU TO FIND ONE. THERE SHOULD BE AT LEAST ONE PACKAGE SOMEWHERE IN THE LOWER LABS.",34,0
txtRadioConstruct2:
                dc.b 34,"IT'S JEFF. FOUND SOMETHING. THERE'S A BLACKOUT TO THE OUTSIDE, RIGHT? BUT "
                dc.b "TRAFFIC IS GOING OUT ON THE LINK THAT WAS INSTALLED FOR THE MILITARY PROJECT. HEAVILY "
                dc.b "ENCRYPTED, SO I CAN'T KNOW WHAT. BUT IT HAS TO BE THE AI. HMM.. WHAT? I'M SEEING MOVE-",34," (STATIC)",0

                checkscriptend