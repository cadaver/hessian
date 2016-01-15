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
                jsr PrintMultiRow
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
SRC_Common:     jsr PrintMultiRow
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
                jmp WaitForExit
SRC_NoCode:     lda #26
                sta temp1
                lda #7
                sta temp2
                lda #<txtNA
                ldx #>txtNA
                jsr PrintText
                jmp WaitForExit

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
                sta temp2                       ;Todo: setup story elements as needed
                ldx #1
                jsr AddItem
                jmp TP_PrintItemName

        ; Setup text screen

SetupTextScreen:jsr BlankScreen
                lda #$02
                sta screen                      ;Set text screen mode
                lda #$0f
                sta scrollX
                ldx #$00
                stx SL_CSSScrollY+1
                stx Irq1_Bg1+1
STS_ClearScreenLoop:lda #$20
                sta screen1,x
                sta screen1+$100,x
                sta screen1+$200,x
                sta screen1+SCROLLROWS*40-$100,x
                lda #$01
                sta colors,x
                sta colors+$100,x
                sta colors+$200,x
                sta colors+SCROLLROWS*40-$100,x
                inx
                bne STS_ClearScreenLoop
                rts

        ; Wait for exit from computer display either by pressing fire or key

WaitForExit:    jsr FinishFrame
                jsr GetControls
                jsr GetFireClick
                bcs DoExit
                lda keyType
                bmi WaitForExit
DoExit:         ldy lvlObjNum                   ;Allow immediate re-entry
                jsr InactivateObject
                jmp CenterPlayer

        ; Print multiple rows

PrintMultiRow:  sta zpSrcLo
                stx zpSrcHi
PMR_NextRow:    jsr PrintTextContinue
                ldy #$00
                lda (zpSrcLo),y
                beq PMR_Exit
                inc temp2
                bne PMR_NextRow
PMR_Exit:       rts

        ; Print null-terminated text

PrintText:      sta zpSrcLo
                stx zpSrcHi
PrintTextContinue:
                ldy temp2
                lda #40
                ldx #zpDestLo
                jsr MulU
                lda zpDestHi
                ora #>screen1
                sta zpDestHi
                lda temp1
                jsr Add8
                ldy #$00
PrintTextLoop:  lda (zpSrcLo),y
                beq PrintTextDone
                sta (zpDestLo),y
                iny
                bne PrintTextLoop
PrintTextDone:  iny
                tya
                ldx #zpSrcLo
                jmp Add8

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

                checkscriptend