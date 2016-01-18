                include macros.s
                include mainsym.s

        ; Script 9, Bio-Dome

                org scriptCodeStart

                dc.w MoveSecurityChief
                dc.w DestroySecurityChief
                dc.w SecurityChiefSpeech
                dc.w HackerAmbush
                dc.w GiveLaptop
                dc.w EnterBioDome
                dc.w InstallLaptop
                dc.w BioDomeEnding

        ; Security chief move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveSecurityChief:
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

        ; Trigger script when entering Bio-Dome
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EnterBioDome:   lda #PLOT_ELEVATOR2             ;Travelled too far while the comms disruption was going on?
                jsr GetPlotBit
                bne EBD_TriggerEnding
                lda #PLOT_HIDEOUTOPEN           ;Check if ambush resolved by locking the hideout
                jsr GetPlotBit
                beq EBD_Skip
                lda #ACT_HACKER
                jsr FindLevelActor
                bcc EBD_Skip
                sty temp1
                lda lvlActOrg,y
                cmp #$0f+ORG_GLOBAL             ;In old tunnels (=safe)?
                beq EBD_Skip
                cmp #$04+ORG_GLOBAL             ;Abandoned elsewhere
                bne EBD_DieAbandoned
                lda #PLOT_HIDEOUTAMBUSH
                bne EBD_DieAmbush
EBD_Skip:       rts
EBD_DieAmbush:  jsr EBD_KillHackerCommon
                lda #<txtRadioDieAmbush
                ldx #>txtRadioDieAmbush
RadioMsg:       pha
                lda #SFX_RADIO
                jsr PlaySfx
                pla
                ldy #ACT_PLAYER
                jmp SpeakLine
EBD_DieAbandoned:
                jsr EBD_KillHackerCommon
                lda #<txtRadioDieAbandoned
                ldx #>txtRadioDieAbandoned
                bne RadioMsg
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
                lda #<txtRadioBioDomeEnding
                ldx #>txtRadioBioDomeEnding
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

        ; Hacker ambush NPC script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerAmbush:   ldx actIndex
                lda actF1,x
                cmp #FR_DIE
                bcs HA_Dying
                cmp #FR_DUCK+1
                beq HA_DieAgain
                lda actHp,x                     ;Set health (invincible by default)
                bne HA_HealthSet
                lda #HP_HACKER
                sta actHp,x
HA_HealthSet:   lda #ACT_HIGHWALKER
                jsr FindActor
                bcc HA_EnemyDestroyed
                lda actIndex
                ldy actHp,x
                cpy #HP_HIGHWALKER
                bcs HA_NotDamaged
                lda #ACTI_PLAYER                ;Attack player once damaged, Jeff otherwise
HA_NotDamaged:  sta actAITarget,x
                ldx actIndex
                lda actXH,x                     ;Continue running if already left
                cmp #$17
                bcc HA_Run
                lda actHp,x
                cmp #HP_HACKER
                bcs HA_Wait                     ;Wait until hit once, then run
HA_Run:         lda #JOY_LEFT
HA_SetControls: sta actMoveCtrl,x
                lda #AIMODE_IDLE
                sta actAIMode,x
HA_Wait:        rts
HA_Dying:       lda #DEATH_DISAPPEAR_DELAY      ;Keep resetting the time
                sta actTime,x
                lda #ACT_HIGHWALKER
                jsr FindActor
                bcs HA_Wait                     ;Wait until enemy gone
                ldx actIndex
                ldy #ACTI_PLAYER
                jsr GetActorDistance
                lda temp6                       ;Wait until player close
                cmp #$04
                bcs HA_Wait
                lda temp5
                sta actD,x
                inc actHp,x
                lda #FR_DUCK+1
                sta actF1,x
                sta actF2,x
                lda #JOY_DOWN
                jsr HA_SetControls
                ldy #ACT_HACKER
                lda #<txtHackerDeath
                ldx #>txtHackerDeath
                jmp SpeakLine
HA_DieAgain:    lda #FR_DIE+2
                sta actF1,x
                sta actF2,x
                dec actHp,x
HA_StopScript:  lda #$00                        ;Stop actor script exec
                sta actScriptF+2
                rts
HA_EnemyDestroyed:
                lda #PLOT_HIDEOUTAMBUSH
                jsr ClearPlotBit
                ldx actIndex
                lda #AIMODE_TURNTO
                sta actAIMode,x
                ldy #ACTI_PLAYER
                jsr GetActorDistance
                lda temp6                       ;Wait until close
                cmp #$02
                bcs HA_Wait
                jsr AddQuestScore
                lda #<EP_GIVELAPTOP
                sta actScriptEP+2
                lda #<txtAmbushSuccess
                ldx #>txtAmbushSuccess
HA_SpeakCommon: ldy #ACT_HACKER
                jmp SpeakLine

        ; Give laptop script (end of ambush)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various
        
GiveLaptop:     lda #$00
                sta actScriptF+2                ;Stop script exec now
                lda #PLOT_HIDEOUTOPEN
                jsr ClearPlotBit                ;Hideout will be closed from now on
                lda #SFX_PICKUP
                jsr PlaySfx
                lda #ITEM_LAPTOP
                ldx #1
                jsr AddItem
                lda #<txtGiveLaptop
                ldx #>txtGiveLaptop
                bne HA_SpeakCommon

        ; Install laptop script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

InstallLaptop:  ldy #ITEM_LAPTOP
                jsr FindItem
                bcc IL_NoItem
                jsr RemoveItem
                jsr AddQuestScore               ;Todo: cutscene
                lda #PLOT_DISRUPTCOMMS          ;(if PLOT_OLDTUNNELSLAB2 is set, Jeff knows
                jsr SetPlotBit                  ;what to expect)
                lda #$00
                sta temp4
                lda #ITEM_LAPTOP
                jsr DI_ItemNumber
                ldx temp8
                lda #$80
                sta actXL,x                     ;Always center of block
                lda #$00
                sta actSY,x                     ;No speed
                lda #<txtRadioInstallLaptop
                ldx #>txtRadioInstallLaptop
                jmp RadioMsg
IL_NoItem:      rts

        ; Security chief speech
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

SecurityChiefSpeech:
                ldy #ACT_SECURITYCHIEF
                lda #<txtSecurityChief
                ldx #>txtSecurityChief
                jmp SpeakLine

        ; Messages
        
txtRadioDieAmbush:
                dc.b 34,"IT'S JEFF. FOUND SOMETHING. FUN, RIGHT? 48 41 20 48 41 2C 20 48 4D 20 48 4D NO. THIS IS NOT JEFF, BUT THE CONSTRUCT. THE HACKER IS DEAD.",34,0

txtRadioDieAbandoned:
                dc.b 34,"JEFF HERE. COULD USE SOME HELP. THEY'VE GOT ME CORNERED.. AARGH!",34," (STATIC)",0

txtHackerDeath: dc.b 34,"SUCKS IT HAPPENED LIKE THIS. BUT WITH YOU HERE, IT SUCKS A BIT LESS. PROMISE ME TO KICK THEIR ASS.",34,0

txtAmbushSuccess:
                dc.b 34,"THEY JAMMED THE RADIO AND FOOLED THE DOOR CAMERA TO GET IN. ONE MORE SECOND AND.. "
                dc.b "I'D HUG YOU, BUT THOSE GUNS ARE IN THE WAY. WILL SET A HARD LOCK-DOWN NOW, "
                dc.b "SO USE THE RECYCLER IF YOU NEED.",0

txtGiveLaptop:  dc.b "ALSO TAKE THIS LAPTOP. MY THEORY IS, THE AI HAS A DEDICATED NETWORK LINK. "
                dc.b "IF YOU CAN FIND IT, WE MAY BE ABLE TO CUT IT OFF COMPLETELY.",34,0

txtRadioInstallLaptop:
                dc.b 34,"JEFF HERE. THIS MUST BE THE AI'S LINK. LET'S GET TO WORK.",34,0

txtRadioBioDomeEnding:
                dc.b 34,"KIM, JEFF HERE. THE NETWORK JUST LIT UP LIKE NEVER BEFORE. I THINK THE AI IS ON TO OUR TRICK. SHIT..",34,0

txtSecurityChief:
                dc.b 34,"YOU! THE ROGUE GUARD. UNDERSTAND THIS - THE 'CONSTRUCT' REPRESENTS NORMAN'S TRUE GENIUS AND COURAGE. "
                dc.b "AFTER THE UPLOAD HE BECAME DOUBTFUL. WEAK. I HAD TO LOCK HIM UP FOR THE RISK OF INTERFERENCE. "
                dc.b "KILLING HIMSELF WAS HIS CHOICE. BUT YOU GETTING HERE PAST THE BIOMETRIC LOCK "
                dc.b "MEANS YOU MUST HAVE DEFILED HIS BODY. THAT'S ONE MORE REASON TO MAKE SURE YOU DON'T LEAVE THIS ROOM ALIVE.",34,0

                ;checkscriptend