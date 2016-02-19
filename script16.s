                include macros.s
                include mainsym.s

        ; Script 16, throne chief + hideout ambush + Bio-Dome entry

                org scriptCodeStart

                dc.w ThroneChief
                dc.w BeginAmbush
                dc.w HackerAmbush
                dc.w GiveLaptop
                dc.w EnterBioDome
                dc.w BioDomeEnding

        ; Throne chief corpse
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ThroneChief:    lda #ITEM_BIOMETRICID
                sta temp2
                ldx #1
                jsr AddItem
                jsr TP_PrintItemName
                lda #ACT_HACKER                 ;Check that Jeff is in hideout
                jsr FindLevelActor
                lda lvlActOrg,y
                cmp #$04+ORG_GLOBAL
                bne TC_SkipAmbush               ;If not, no ambush
                lda #<EP_BEGINAMBUSH
                ldx #>EP_BEGINAMBUSH
                jsr SetScript
TC_SkipAmbush:  jsr BlankScreen
                lda #F_LETTER
                jsr MakeFileName_Direct
                lda #<chars
                ldx #>chars
                jsr LoadFileRetry
                jsr chars+$300                  ;Show letter and wait for fire/keypress
                jsr FindPlayerZone              ;Reload level charset
                lda actMB+ACTI_PLAYER           ;If player on ground, stop completely
                lsr
                bcc TC_NotGrounded
                lda #$00
                sta actSX+ACTI_PLAYER
TC_NotGrounded: jmp CenterPlayer

        ; Begin hideout ambush + second Construct briefing
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BeginAmbush:    jsr StopScript
                lda #PLOT_HIDEOUTAMBUSH
                jsr SetPlotBit
                ldy lvlDataActBitsStart+$04     ;Enable ambush enemies now
                lda #$c0
                ora lvlStateBits+2,y
                sta lvlStateBits+2,y
                iny
                lda #$03
                ora lvlStateBits+2,y
                sta lvlStateBits+2,y
                lda #<EP_HACKERAMBUSH
                ldx #>EP_HACKERAMBUSH
                sta actScriptEP+2
                stx actScriptF+2
                gettext txtRadioConstruct2
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx

        ; Hacker ambush NPC script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerAmbush:   ldx actIndex
                ldy #ACTI_PLAYER
                jsr GetActorDistance
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
                gettext txtAmbushDeath  
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
                lda #HP_NONCOMBATANT
                sta actHp,x                     ;Make sure to not allow damage now
                lda #AIMODE_TURNTO
                sta actAIMode,x
                lda temp6                       ;Wait until close
                cmp #$02
                bcs HA_Wait
                jsr AddQuestScore
                lda #<EP_GIVELAPTOP
                sta actScriptEP+2
                gettext txtAmbushVictory
H_SpeakCommon:  ldy #ACT_HACKER
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
                gettext txtGiveLaptop
                jmp H_SpeakCommon

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
                jmp RadioMsg

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
                jsr FadeSong
                jsr BlankScreen
                lda #<EP_ENDSEQUENCE
                ldx #>EP_ENDSEQUENCE
                ldy #$00                        ;Ending 1
                jmp ExecScriptParam

        ; Messages

txtRadioConstruct2:
                dc.b 34,"IT'S JEFF. SAW YOU FOUND ACCESS TO THE BIO-DOME. THE AI BEING THERE MAKES SENSE. "
                dc.b "I ALSO GOT SOMETHING. THERE'S A BLACKOUT TO THE OUTSIDE, RIGHT? BUT A DEDICATED LINK "
                dc.b "WAS INSTALLED FOR THE MILITARY CONTRACTS. THERE'S TRAFFIC, BUT I CAN'T SEE WHAT WITHOUT "
                dc.b "PHYSICAL ACCESS. I BET IT'S THE AI. WHAT? I'M SEEING MOVE-",34, " (STATIC)",0

txtAmbushDeath: dc.b 34,"SHOULD'VE BEEN MORE CAREFUL.. JUST.. KICK THEIR ASS FOR ME.",34,0

txtAmbushVictory:
                dc.b 34,"THEY JAMMED THE RADIO AND FOOLED THE DOOR CAMERA TO GET IN. ONE MORE SECOND AND.. "
                dc.b "I'D HUG YOU, BUT THOSE GUNS ARE IN THE WAY. WILL SET A HARD LOCK-DOWN NOW, "
                dc.b "SO USE THE RECYCLER IF YOU NEED.",0

txtGiveLaptop:  dc.b "ALSO TAKE THIS LAPTOP. IF YOU FIND THE DEDICATED LINK, I'D LIKE TO CHECK "
                dc.b "IF WE CAN CUT OFF THE AI'S ACCESS SAFELY.",34,0

txtRadioAmbushDead:
                dc.b 34,"IT'S JEFF-YOU MUST BE MESSED UP 48 4D 20 48 4D 2C 48 41 20 48 41 THIS IS THE CONSTRUCT. THE HACKER IS DEAD.",34,0

txtRadioAbandoned:
                dc.b 34,"JEFF HERE. COULD USE SOME HELP. THEY'VE GOT ME CORNERED.. AARG-",34, " (GUNFIRE)",0

txtRadioBioDomeTriggerEnd:
                dc.b 34,"KIM, IT'S JEFF.. THE NETWORK JUST LIT UP LIKE NEVER BEFORE. I THINK THE AI FOUND OUT. WE'RE SCREWED..",34,0

                checkscriptend
