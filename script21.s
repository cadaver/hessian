                include macros.s
                include mainsym.s

        ; Script 21, Bio-Dome

                org scriptCodeStart

                dc.w MoveSecurityChief
                dc.w DestroySecurityChief
                dc.w SecurityChiefSpeech
                dc.w EnterBioDome
                dc.w BioDomeEnding

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
                stx temp6
                lda #MUSIC_THRONE               ;Back to regular song
                jsr PlaySong
                ldx temp6
                jsr HumanDeath
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

                checkscriptend
