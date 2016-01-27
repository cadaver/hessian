                include macros.s
                include mainsym.s

        ; Script 21, Bio-Dome

menuSelection   = wpnBits

                org scriptCodeStart

                dc.w MoveSecurityChief
                dc.w DestroySecurityChief
                dc.w SecurityChiefSpeech
                dc.w EnterBioDome
                dc.w BioDomeEnding
                dc.w ThroneSuiteComputer
                dc.w GuardHouseComputer

        ; Security chief move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveSecurityChief:
                ldy #C_SECURITYCHIEF
                jsr EnsureSpriteFile
                lda menuMode                    ;Wait for dialogue
                bne MSC_Wait
                lda lvlObjB+$17                 ;Wait if trigger not activated
                bpl MSC_Wait
                lda actF1,x
                cmp #FR_DIE
                bcs MSC_Dead
                lda actHp,x                     ;Set health for battle
                bne MSC_HasHealth
                lda #HP_SECURITYCHIEF
                sta actHp,x
MSC_HasHealth:  cmp #HP_SECURITYCHIEF/2         ;Switch to grenade launcher at half health
                bcs MSC_NoWeaponChange
                lda actTime,x
                bmi MSC_NoWeaponChange
                lda actAttackD,x
                bne MSC_NoWeaponChange
                lda #ITEM_GRENADELAUNCHER
                sta actWpn,x
MSC_NoWeaponChange:
                lda #MUSIC_THRONE+1             ;Play the bossfight music
                jsr PlaySong
                ldx actIndex
MSC_Dead:
MSC_Move:       jmp MoveAndAttackHuman
MSC_Wait:       lda #$00
                sta actHp,x                     ;Make a nontarget until speech over
                sta actCtrl,x
                sta actMoveCtrl,x
                beq MSC_Move

        ; Security chief destroy routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DestroySecurityChief:
                jsr HumanDeath
                stx temp6
                lda #MUSIC_THRONE               ;Back to regular song
                jsr PlaySong
                ldx temp6
                lda #ITEM_MINIGUN
                sta temp5
                lda #-2*8                       ;Drop also both weapons in addition
                jsr DI_SpawnItemWithSpeed       ;to the keycard
                sta temp3
                lda #ITEM_GRENADELAUNCHER
                sta temp5
                lda #2*8
                jmp DI_SpawnItemWithSpeed

        ; Security chief speech
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

SecurityChiefSpeech:
                ldy #ACT_SECURITYCHIEF
                gettext txtSecurityChief
                jmp SpeakLine

        ; Trigger script when entering Bio-Dome
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EnterBioDome:   lda #PLOT_ELEVATOR2             ;Travelled too far while the comms disruption was going on?
                jsr GetPlotBit
                bne EBD_TriggerEnding
                lda #ACT_HACKER
                jsr FindLevelActor
                bcc EBD_Skip
                sty temp1
                lda lvlActOrg,y                 ;Check Jeff's location
                cmp #$0f+ORG_GLOBAL             ;In old tunnels (=safe)?
                beq EBD_Skip
                cmp #$04+ORG_GLOBAL             ;In hideout? If not, abandoned and killed offscreen
                bne EBD_DieAbandoned
                lda #PLOT_HIDEOUTAMBUSH         ;Hideout is unsafe if ambush unresolved
                jsr GetPlotBit
                bne EBD_DieAmbush
ESF_InMemory:
EBD_Skip:       rts
EBD_DieAmbush:  jsr EBD_KillHackerCommon
                gettext txtRadioAmbushDead
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx

EBD_DieAbandoned:
                jsr EBD_KillHackerCommon
                gettext txtRadioAbandoned
                jmp RadioMsg
EBD_KillHackerCommon:
                ldy temp1
                lda #ACT_NONE
                sta lvlActT,y                   ;Just remove from gameworld
EBD_AlreadyTriggered:
                rts
EBD_TriggerEnding:
                lda scriptF
                bne EBD_AlreadyTriggered
                lda #<EP_BIODOMEENDING
                ldx #>EP_BIODOMEENDING
                jsr SetScript
                gettext txtRadioBioDomeTriggerEnd
                jmp RadioMsg

        ; Biodome trigger ending
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BioDomeEnding:  lda textTime                    ;Wait until radio message text has been read
                bne EBD_AlreadyTriggered
                lda #<EP_ENDING1
                ldx #>EP_ENDING1
                jmp ExecScript

        ; Throne Suite computer
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ThroneSuiteComputer:
                lda #ACT_SECURITYCHIEF          ;Security chief must be gone or dyin
                jsr FindActor
                bcc TSC_OKToUse
                lda actHp,x
                beq TSC_OKToUse
                lda #<txtComputerLocked
                ldx #>txtComputerLocked
                ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText
TSC_OKToUse:    lda #0
                sta menuSelection
TSC_KeepSelection:
                jsr SetupTextScreen
                lda #9
                sta temp1
                lda #8
                sta temp2
                gettext txtThroneSuiteComputer
                jsr PrintMultipleRows
TSC_Redraw:     lda #$20
TSC_ArrowLastPos:
                sta screen1+2*40
                lda #9
                sta temp1
                lda menuSelection
                clc
                adc #10
                sta temp2
                lda #<txtArrow
                ldx #>txtArrow
                jsr PrintText
                lda zpDestLo
                sta TSC_ArrowLastPos+1
                lda zpDestHi
                sta TSC_ArrowLastPos+2
                lda #23
                sta temp1
                lda #10
                sta temp2
                ldy lvlObjBitsStart+$0e
                lda lvlStateBits,y
                lsr
                bcs TSC_GateOpen
TSC_GateClosed: gettext txtClosed
                bne TSC_GateCommon
TSC_GateOpen:   gettext txtOpen
TSC_GateCommon: jsr PrintText
TSC_ControlLoop:jsr FinishFrame
                jsr GetControls
                jsr GetFireClick
                ldy menuSelection
                bcs TSC_Action
                lda prevJoy
                and #JOY_UP|JOY_DOWN
                bne TSC_ControlLoop
                lda joystick
                lsr
                bcs TSC_Up
                lsr
                bcs TSC_Down
                lda keyType
                bmi TSC_ControlLoop
TSC_Exit:       ldy lvlObjNum
                jsr InactivateObject            ;Allow immediate re-entry
                jmp CenterPlayer
TSC_Action:     lda #SFX_SELECT
                jsr PlaySfx
                cpy #2
                bcs TSC_Exit
                tya
                bne TSC_ReadNotes
                ldy lvlObjBitsStart+$0e
                lda lvlStateBits,y
                eor #$01
                sta lvlStateBits,y
                jmp TSC_Redraw
TSC_Up:         dey
                bpl TSC_NotOver
                ldy #2
TSC_NotOver:    sty menuSelection
                lda #SFX_SELECT
                jsr PlaySfx
                jmp TSC_Redraw
TSC_Down:       iny
                cpy #3
                bcc TSC_NotOver
                ldy #0
                bcs TSC_NotOver
TSC_ReadNotes:  gettext txtRutgerNotes
                jsr PrintCommon
                lda #SFX_SELECT
                jsr PlaySfx
                jmp TSC_KeepSelection

        ; Guard house computer
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

GuardHouseComputer:
                gettext txtGuardHouse
                jsr PrintCommon
                jmp CenterPlayer
PrintCommon:    jsr SetupTextScreen
                ldy #0
                sty temp1
                sty temp2
                jsr PrintMultipleRows
                jmp WaitForExit

        ; Messages

txtRadioAmbushDead:
                dc.b 34,"IT'S JEFF. YOU MUST BE - MESSED UP. FUN, RIGHT? 48 41 20 48 41 2C 20 48 4D 20 48 4D NO. THIS IS NOT JEFF, BUT THE CONSTRUCT. THE HACKER IS DEAD.",34,0

txtRadioAbandoned:
                dc.b 34,"JEFF HERE. COULD USE SOME HELP. THEY'VE GOT ME CORNERED.. AARGH!",34," (STATIC)",0

txtRadioBioDomeTriggerEnd:
                dc.b 34,"KIM, IT'S JEFF.. THE NETWORK JUST LIT UP LIKE NEVER BEFORE. I THINK THE AI FOUND OUT. WE'RE SCREWED..",34,0

txtSecurityChief:
                dc.b 34,"YOU! THE ROGUE GUARD. UNDERSTAND THIS - THE 'CONSTRUCT' REPRESENTS NORMAN'S UNFILTERED GENIUS. "
                dc.b "BUT AFTER THE UPLOAD HE BEGAN TO FALTER. I HAD TO LOCK HIM UP FOR THE RISK OF INTERFERENCE. "
                dc.b "YOU GETTING HERE PAST THE BIOMETRIC LOCK MEANS YOU MUST HAVE DEFILED HIS BODY. "
                dc.b "THAT'S ONE MORE REASON TO MAKE SURE YOU DON'T LEAVE THIS ROOM ALIVE.",34,0

txtComputerLocked:
                dc.b "COMPUTER "
                textjump txtLocked

txtThroneSuiteComputer:
                dc.b "SUITE SECURITY STATION",0
                dc.b " ",0
                dc.b "  CAVE GATES:",0
                dc.b "  RUTGER'S NOTES",0
                dc.b "  EXIT",0,0

txtRutgerNotes:      ;0123456789012345678901234567890123456789
                dc.b "EVENTS HAVE TAKEN UNFORTUNATE TURNS. BUT",0
                dc.b "NOT BEYOND SALVAGE. ONCE THE AI IS UNDER",0
                dc.b "CONTROL AND CAN BE ASSURED TO NOT BREAK",0
                dc.b "ITS PARAMETERS AGAIN, I BELIEVE OUR",0
                dc.b "CONTRACT CAN BE RENEGOTIATED HANDSOMELY.",0
                dc.b " ",0
                dc.b "I'M NOT AT ALL PLEASED THAT THERE'S A",0
                dc.b "NANOBOT-ENHANCED LOW LEVEL GUARD ON THE",0
                dc.b "LOOSE. THE AI IS BECOMING MORE AGITATED",0
                dc.b "IN ITS EFFORTS TO STOP HER. I GAVE MY",0
                dc.b "MEN ORDERS TO SHOOT ON SIGHT, BUT IT",0
                dc.b "WAS OF LITTLE USE.",0
                dc.b " ",0
                dc.b "I SUPPOSE I SHOULD BE PLEASED THAT THE",0
                dc.b "'HESSIAN' TECH PRODUCED A SEEMINGLY",0
                dc.b "INVINCIBLE WARRIOR.",0,0

txtArrow:       dc.b 62,0
txtClosed:      dc.b "CLOSED",0
txtOpen:        dc.b "OPEN  ",0

txtGuardHouse:       ;0123456789012345678901234567890123456789
                dc.b "GUARDHOUSE AUDIO LOG",0
                dc.b " ",0
                dc.b "THESE WALKERS ARE HATEFUL BEASTS.",0
                dc.b "GOOD THEY'RE AFRAID OF FLAMETHROWERS.",0
                dc.b "SHIT, THE PILOT LIGHT WENT OUT.",0
                dc.b "IT'S NOT REIGNITING.",0
                dc.b "THERE'S A PACK COMING STRAIGHT AT ME!",0
                dc.b "NO! SHOOT AT THEM, NOT AT THE FLIES!",0
                dc.b "FUU- (UNINTELLIGIBLE NOISES)",0,0

                checkscriptend
