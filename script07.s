                include macros.s
                include mainsym.s

CHUNK_DURATION = 40

        ; Script 7, lower labs interactions

                org scriptCodeStart

                dc.w DisconnectSubnet
                dc.w ServerRoomComputer
                dc.w MoveScientists
                dc.w RadioConstruct
                dc.w FindFilter
                dc.w BeginSurgery
                dc.w BeginSurgery2

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
                ;jmp FindFilter
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
                lda #PLOT_ELEVATOR1
                jsr GetPlotBit
                beq SRC_SecurityOn
SRC_SecurityOff:ldx #2
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
                lda #<txtProtocolOff
                ldx #>txtProtocolOff
                bne SRC_Common
SRC_SecurityOn: lda #26
                sta temp1
                lda #7
                sta temp2
                lda #<txtNA
                ldx #>txtNA
                jsr PrintText
                lda #<txtProtocolOn
                ldx #>txtProtocolOn
SRC_Common:     ldy #0
                sty temp1
                ldy #5
                sty temp2
                jsr PrintMultiRow
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
                lda #SFX_RADIO
                jsr PlaySfx
                ldy #ACT_PLAYER
                lda #<txtRadioMoveScientists
                ldx #>txtRadioMoveScientists
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
                lda #SFX_RADIO
                jsr PlaySfx
                ldy #ACT_PLAYER
                lda #<txtRadioConstruct
                ldx #>txtRadioConstruct
                jmp SpeakLine
HP_TryAgain:    ldy lvlObjNum
                jmp InactivateObject

        ; Find filter script. Also move scientists to final positions before surgery
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

FindFilter:     jsr StopZoneScript

                ldy lvlObjNum                   ;Hack for testing (when this script is executed by a door)
                lda #$00
                sta lvlObjDL,y
                sta lvlObjDH,y
                sta lvlObjB,y

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
                lda #SFX_RADIO
                jsr PlaySfx
                ldy #ACT_PLAYER
                lda #<txtRadioFindFilter
                ldx #>txtRadioFindFilter
                jmp SpeakLine
MoveScientistSub2:
                sta lvlActX,y                   ;Set also Y & level so that this can be used as shortcut in testing
                lda #$56
                sta lvlActY,y
                txa
                sta lvlActF,y
                lda #$08+ORG_GLOBAL
                sta lvlActOrg,y
BS2_NotYet:
BS_NoFilter:    rts

        ; Begin surgery script.
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BeginSurgery:   ldy #ITEM_LUNGFILTER
                jsr FindItem
                bcc BS_NoFilter
                lda actXH+ACTI_PLAYER
                cmp #$44
                bcs BS_NoFilter
                jsr AddQuestScore
                lda #<EP_BEGINSURGERY2
                sta actScriptEP
                lda #$00
                sta scriptVariable
                ldy #ACT_SCIENTIST2
                lda #<txtBeginSurgery
                ldx #>txtBeginSurgery
                jmp SpeakLine

        ; Begin surgery script, part 2
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BeginSurgery2:  lda actXH+ACTI_PLAYER
                cmp #$41
                bcs BS2_NotYet
                lda actMB+ACTI_PLAYER
                lsr
                bcc BS2_NotYet
                lda scriptVariable
                asl
                tay
                lda bs2JumpTbl,y
                sta BS2_Jump+1
                lda bs2JumpTbl+1,y
                sta BS2_Jump+2
BS2_Jump:       jmp BS2_1

BS2_1:          inc scriptVariable
                ldy #ACT_SCIENTIST2
                lda #<txtBeginSurgery2_1
                ldx #>txtBeginSurgery2_1
                jmp SpeakLine

BS2_2:          lda #$00                    ;Disabled controls during the delay to simplify scripting
                sta joystick
                lda #ACT_SCIENTIST3
                jsr FindActor
                lda #AIMODE_IDLE
                sta actAIMode,x
                lda #$80
                sta actD,x
                inc actTime,x
                lda actTime,x
                cmp #25
                bcc BS2_2Wait
                lda #$00
                sta actTime,x
                inc scriptVariable
BS2_2Wait:      rts

BS2_3:          inc scriptVariable
                lda #ACT_SCIENTIST3
                jsr FindActor
                lda #AIMODE_TURNTO
                sta actAIMode,x
                lda #ITEM_EMPGENERATOR
                sta actWpn,x
                ldy #ACT_SCIENTIST3
                lda #<txtBeginSurgery2_2
                ldx #>txtBeginSurgery2_2
                jmp SpeakLine

BS2_4:          jsr BlankScreen
                lda #<EP_AFTERSURGERY
                sta actScriptEP+1
                lda #>EP_AFTERSURGERY
                sta actScriptF+1
                lda #0
                sta actScriptF
                lda #<EP_AFTERSURGERYRUN
                ldx #>EP_AFTERSURGERYRUN
                jsr SetScript
                lda #50
                sta scriptVariable
BS2_Delay:      jsr WaitBottom
                dec scriptVariable
                bne BS2_Delay
                jmp CenterPlayer

bs2JumpTbl:     dc.w BS2_1
                dc.w BS2_2
                dc.w BS2_3
                dc.w BS2_4

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
txtRadioFindFilter:
                dc.b 34,"LINDA HERE. WE GOT AHEAD OF OURSELVES - THERE ARE NO LUNG FILTERS STORED HERE. SINCE YOU'RE MUCH BETTER SUITED TO EXPLORING, "
                dc.b "WE'LL HAVE TO ASK YOU TO FIND ONE. THERE SHOULD BE AT LEAST ONE PACKAGE SOMEWHERE IN THE LOWER LABS.",34,0
txtBeginSurgery:dc.b 34,"YOU GOT THE FILTER? EXCELLENT. WE'RE READY, FOR REAL THIS TIME. THIS IS A STANDARD NANO-ASSISTED "
                dc.b "PROCEDURE WITH SOME RISK INVOLVED. THE TUNNELS BELOW SHOULD BE SURVIVABLE AFTER. "
                dc.b "STEP TO THE OPERATING TABLE WHEN YOU WISH TO PROCEED.",34,0

txtBeginSurgery2_1:
                dc.b 34,"GOOD. WE WILL BEGIN. LINDA, JUST IN CASE WE GET COMPANY, THERE SHOULD BE A WEAPON IN THE CUPBOARD.",34,0
txtBeginSurgery2_2:
                dc.b 34,"GOT IT.",34,0

                checkscriptend