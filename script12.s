                include macros.s
                include mainsym.s

        ; Script 12, fixing the lower labs elevator
        
                org scriptCodeStart

                dc.w DisconnectSubnet
                dc.w ServerRoomComputer
                dc.w MoveScientists
                dc.w RadioConstruct
                dc.w RadioLowerLabs
                dc.w CombatRobotSaboteur
                dc.w DestroyCombatRobotSaboteur

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
SRC_CodeLoop:   lda codes+MAX_CODES*3-3,x
                ora #$30
                sta screen1+7*40+26,x
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
                lda #$00                        ;Reset Amos script if skipping parts of plot
                sta actScriptF
                lda #<EP_ESCORTSCIENTISTSSTART
                ldx #>EP_ESCORTSCIENTISTSSTART
                sta actScriptEP+1
                stx actScriptF+1
                if SKIP_PLOT > 0
                lda #PLOT_ESCORTCOMPLETE
                jsr SetPlotBit
                lda #<EP_FINDFILTER
                ldx #>EP_FINDFILTER
                jmp ExecScript
                endif
                gettext txtRadioMoveScientists
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx

MoveScientistSub:
                sta lvlActX,y
                lda #$13
                sta lvlActY,y
                lda #$20+AIMODE_TURNTO
                sta lvlActF,y
                lda #$06+ORG_GLOBAL
                sta lvlActOrg,y
RC_Skip:        rts

        ; Radio briefing on Construct
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioConstruct: lda #PLOT_MOVESCIENTISTS        ;Wait until elevator fixed
                jsr GetPlotBit
                beq RC_TryAgain
                ldy #ITEM_BIOMETRICID           ;If has the biometric ID already, ambush will have happened
                jsr FindItem                    ;and this information is redundant
                bcs RC_Skip
                lda #PLOT_HIDEOUTOPEN           ;If Jeff has left the hideout, redundant / do not mess script state
                jsr GetPlotBit
                beq RC_Skip
                lda #<EP_HACKER3                ;Advance Jeff script now
                ldx #>EP_HACKER3
                sta actScriptEP+2
                stx actScriptF+2
                gettext txtRadioConstruct
                jmp RadioMsg
RC_TryAgain:    ldy lvlObjNum
                jmp InactivateObject

        ; Radio speech shortly after entering lower labs
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioLowerLabs: gettext txtRadioLowerLabs
                jmp RadioMsg

        ; Saboteur robot
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

CombatRobotSaboteur:
                lda #FR_ATTACK+3
                sta actF2,x
                lda #FR_STAND
                sta actF1,x
                jsr Random
                and #$08
                sta temp1
                lda actXL,x
                and #$f0
                ora temp1
                sta actXL,x
                jsr Random
                and #$1f
                clc
                adc actTime,x
                sta actTime,x
                bcc CRS_NoEffect
                lda #ACTI_FIRSTNPCBULLET
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc CRS_NoEffect
                lda #ACT_EMP
                jsr SpawnActor
                tya
                tax
                lda #8*8
                jsr MoveActorX
                lda #8*8
                jsr MoveActorY
                dec actYH,x
                lda #COLOR_FLICKER
                sta actFlash,x
                lda #8
                sta actTime,x
                lda #0
                sta actBulletDmgMod-ACTI_FIRSTPLRBULLET,x ;Make sure the EMP doesn't do actual damage to anyone
                ldx actIndex
CRS_NoEffect:   rts

        ; Saboteur robot death
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

DestroyCombatRobotSaboteur:
                lda #PLOT_LOWERLABSNOAIR        ;Make lower labs safe again
                jsr ClearPlotBit
                lda #$00
                sta ULO_NoAirFlag+1
                stx temp6
                lda #MUSIC_MYSTERY              ;Restore original music
                jsr PlaySong
                ldx temp6
                jmp ExplodeEnemy3_Ofs24

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
                dc.b "ELEVATOR UNLOCKED",0,0

txtNA:          dc.b "N/A",0

txtRadioLowerLabs:
                dc.b 34,"LINDA HERE. WE GOT JEFF TO HELP - HE MANAGED TO DECRYPT SOME OF THE MACHINE "
                dc.b "COMMUNICATIONS. THEIR ACTIVITY IS FOCUSED ON THE TUNNELS THAT LEAD FURTHER BELOW "
                dc.b "THE LOWER LABS. THEY'VE BUILT SOMETHING CALLED "
                dc.b "'JORMUNGANDR.' THAT DOESN'T SOUND GOOD. THE AIR DOWN THERE IS TOXIC. "
                dc.b "WE MUST FIGURE OUT HOW TO PROCEED. MEANWHILE, YOU JUST GET THE ELEVATOR WORKING.",34,0

txtRadioMoveScientists:
                dc.b 34,"AMOS HERE. GREAT JOB FIXING THE ELEVATOR. WE'VE FIGURED OUT THE NEXT STEP. "
                dc.b "WILL TELL THE DETAILS IN PERSON. WE'RE NOW AT THE UPPER LABS RECYCLER, MEET US THERE.",34,0

txtRadioConstruct:
                dc.b 34,"KIM, IT'S JEFF. I'VE BEEN DECRYPTING MORE OF THE MACHINES' NET TRAFFIC. 'CONSTRUCT' HAS TO BE THE NAME OF THE CENTRAL AI. "
                dc.b "IT TASKED THE ROBOTS TO BUILD 'JORMUNGANDR.' AMOUNT OF MATERIALS USED WAS ASTRONOMICAL. "
                dc.b "IF THEY FOLLOW NORSE MYTHS, THAT SHOULD BE ONE HUGE SERPENT. FUN, RIGHT?",34,0

                checkscriptend
