                include macros.s
                include mainsym.s

CHUNK_DURATION = 40

        ; Script 7, lower labs interactions

                org scriptCodeStart

                dc.w DisconnectSubnet
                dc.w ServerRoomComputer
                dc.w MoveScientists
                dc.w HijackPlan

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
                ;lda #PLOT_ELEVATOR1
                ;jsr SetPlotBit
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
                ;lda #$2f
                jsr MoveScientistSub
                lda #ACT_SCIENTIST3
                jsr FindLevelActor
                lda #$36
                ;lda #$2e
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
                ;lda #$55
                sta lvlActY,y
                lda #$20+AIMODE_TURNTO
                sta lvlActF,y
                lda #$06+ORG_GLOBAL
                ;lda #$08+ORG_GLOBAL
                sta lvlActOrg,y
                rts

        ; Jeff's hijack plan script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HijackPlan:     lda #PLOT_MOVESCIENTISTS
                jsr GetPlotBit
                beq HP_TryAgain
                lda #SFX_RADIO
                jsr PlaySfx
                ldy #ACT_PLAYER
                lda #<txtRadioHijackPlan
                ldx #>txtRadioHijackPlan
                jmp SpeakLine
HP_TryAgain:    ldy lvlObjNum
                jmp InactivateObject

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
                dc.b 34,"AMOS HERE. SUPERB JOB FIXING THE ELEVATOR. WE'VE FIGURED OUT THE NEXT STEP "
                dc.b "AND NEED TO REACH THE LOWER LABS NOW. BUT GOING ON OUR OWN IS LIKELY TO "
                dc.b "GET US KILLED. WE MANAGED TO SAFELY REACH THE UPPER LABS RECYCLING STATION, MEET US THERE.",34,0

txtRadioHijackPlan:
                dc.b 34,"IT'S JEFF. I HAVE ANOTHER SUGGESTION. GET INSIDE THE ARMORY IN THE LOWER LABS "
                dc.b "SECURITY CENTER, AND I CAN HELP YOU HIJACK A ROBOT TANK. THAT GIVES YOU MORE FIREPOWER "
                dc.b "AND A DISTRACTION ON YOUR SIDE FOR ESCORTING THE SCIENTISTS.",34,0

                checkscriptend