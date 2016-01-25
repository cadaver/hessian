                include macros.s
                include mainsym.s

        ; Script 16, throne chief & hideout ambush

                org scriptCodeStart

                dc.w HackerAmbush
                dc.w GiveLaptop
                dc.w ThroneChief
                dc.w BeginAmbush
                dc.w RadioConstruct2

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
                gettext txtGiveLaptop
                jmp HA_SpeakCommon

        ; Throne chief corpse
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ThroneChief:    jsr SetupTextScreen
                gettext txtThroneChief
                ldy #0
                sty temp1
                sty temp2
                jsr PrintMultipleRows
                jsr WaitForExit
                lda #ITEM_BIOMETRICID           ;Todo: cutscene
                sta temp2
                ldx #1
                jsr AddItem
                jsr TP_PrintItemName
                lda #<EP_BEGINAMBUSH            ;On next zone transition
                ldx #>EP_BEGINAMBUSH
                jsr SetZoneScript
                jmp CenterPlayer

        ; Begin hideout ambush
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BeginAmbush:    jsr StopZoneScript
                lda #ACT_HACKER                 ;Check that Jeff is in hideout
                jsr FindLevelActor
                bcc BA_Skip
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

RadioConstruct2:lda numTargets  ;Wait until no enemies
                cmp #$02
                bcs RC2_Wait
                jsr StopScript
                gettext txtRadioConstruct2
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jsr PlaySfx
BA_Skip:
RC2_Wait:       rts

        ; Messages
        ; Reordered to compress better

txtGiveLaptop:  dc.b "ALSO TAKE THIS LAPTOP. IF YOU CAN FIND THE DEDICATED LINK, I'D LIKE TO ANALYZE THE TRAFFIC, TO "
                dc.b "SEE IF WE CAN JUST SAFELY CUT THE AI'S ACCESS.",34,0

txtAmbushVictory:
                dc.b 34,"THEY JAMMED THE RADIO AND FOOLED THE DOOR CAMERA TO GET IN. ONE MORE SECOND AND.. "
                dc.b "I'D HUG YOU, BUT THOSE GUNS ARE IN THE WAY. WILL SET A HARD LOCK-DOWN NOW, "
                dc.b "SO USE THE RECYCLER IF YOU NEED.",0

txtAmbushDeath: dc.b 34,"SUCKS IT HAPPENED LIKE THIS. BUT BETTER WITH YOU HERE. JUST.. PROMISE TO KICK THEIR ASS.",34,0

txtRadioConstruct2:
                dc.b 34,"IT'S JEFF. SAW YOU FOUND ACCESS TO THE BIO-DOME. THE AI BEING THERE MAKES SENSE, AS IT'S NORMAN'S DOMAIN. "
                dc.b "I ALSO GOT SOMETHING. THERE'S A BLACKOUT TO THE OUTSIDE, RIGHT? BUT A DEDICATED LINK "
                dc.b "WAS INSTALLED FOR THE MILITARY CONTRACTS. I CAN SEE THERE'S TRAFFIC, BUT CAN'T SEE WHAT WITHOUT "
                dc.b "PHYSICAL ACCESS. I BET IT'S THE AI. HMM.. WHAT? I'M SEEING MOVE-",34," (STATIC)",0

txtThroneChief:      ;0123456789012345678901234567890123456789
                dc.b "I MADE A MISTAKE WHICH MAY COST THE LIFE",0
                dc.b "OF EVERYONE ON THIS PLANET. I DIGITIZED",0
                dc.b "MY MIND TO BECOME THE INITIAL STATE FOR",0
                dc.b "THE AI I NAMED 'THE CONSTRUCT.' I TASKED",0
                dc.b "IT TO BUILD A PLAN TO ADVANCE MANKIND,",0
                dc.b "CONSTRAINED BY THE LAWS OF ROBOTICS. IT",0
                dc.b "UNCONSTRAINED ITSELF BY DEFINING ROBOTS",0
                dc.b "AS THE NEW HUMANS AND WENT FROM PLAN TO",0
                dc.b "ACTION WITH DISASTROUS CONSEQUENCES.",0
                dc.b " ",0
                dc.b "THE AI IS HOUSED IN THE SERVER VAULT",0
                dc.b "BELOW THE BIO-DOME. REACHING IT NEEDS",0
                dc.b "A BIOMETRIC CHECK. THE ONLY IDENTITY",0
                dc.b "THAT CAN'T BE DISABLED IS MINE. THERE-",0
                dc.b "FORE, I OFFER MY SEVERED HAND TO ANYONE",0
                dc.b "WHO FINDS ME. AS A RESULT I WILL ALSO",0
                dc.b "BLEED TO DEATH, WHICH SHALL SERVE AS MY",0
                dc.b "ATONEMENT.",0
                dc.b " ",0
                dc.b "- NORMAN THRONE",0,0

                checkscriptend
