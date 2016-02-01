                include macros.s
                include mainsym.s

        ; Script 16, throne chief + hideout ambush

                org scriptCodeStart

                dc.w ThroneChief
                dc.w BeginAmbush
                dc.w HackerAmbush
                dc.w GiveLaptop

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
TC_SkipAmbush:  rts

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

        ; Messages

txtRadioConstruct2:
                dc.b 34,"IT'S JEFF. SAW YOU FOUND ACCESS TO THE BIO-DOME. THE AI BEING THERE MAKES SENSE. "
                dc.b "I ALSO GOT SOMETHING. THERE'S A BLACKOUT TO THE OUTSIDE, RIGHT? BUT A DEDICATED LINK "
                dc.b "WAS INSTALLED FOR THE MILITARY CONTRACTS. THERE'S TRAFFIC, BUT I CAN'T SEE WHAT WITHOUT "
                dc.b "PHYSICAL ACCESS. I BET IT'S THE AI. WHAT? I'M SEEING MOVE-",34, " (STATIC)",0

txtAmbushDeath: dc.b 34,"SUCKS IT HAPPENED LIKE THIS. BUT BETTER WITH YOU HERE. JUST.. PROMISE TO KICK THEIR ASS.",34,0

txtAmbushVictory:
                dc.b 34,"THEY JAMMED THE RADIO AND FOOLED THE DOOR CAMERA TO GET IN. ONE MORE SECOND AND.. "
                dc.b "I'D HUG YOU, BUT THOSE GUNS ARE IN THE WAY. WILL SET A HARD LOCK-DOWN NOW, "
                dc.b "SO USE THE RECYCLER IF YOU NEED.",0

txtGiveLaptop:  dc.b "ALSO TAKE THIS LAPTOP. IF YOU CAN FIND THE DEDICATED LINK, I'D LIKE TO ANALYZE THE TRAFFIC, TO "
                dc.b "SEE IF WE CAN JUST SAFELY CUT THE AI'S ACCESS.",34,0

                checkscriptend
