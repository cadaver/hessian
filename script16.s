                include macros.s
                include mainsym.s

        ; Script 16, hideout ambush

                org scriptCodeStart

                dc.w HackerAmbush
                dc.w GiveLaptop

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
                ldy #ACTI_PLAYER
                jsr GetActorDistance
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

        ; Messages
        ; Reordered to compress better

txtGiveLaptop:  dc.b "ALSO TAKE THIS LAPTOP. IF YOU CAN FIND THE DEDICATED LINK, I'D LIKE TO ANALYZE THE TRAFFIC, TO "
                dc.b "SEE IF WE CAN JUST SAFELY CUT THE AI'S ACCESS.",34,0

txtAmbushVictory:
                dc.b 34,"THEY JAMMED THE RADIO AND FOOLED THE DOOR CAMERA TO GET IN. ONE MORE SECOND AND.. "
                dc.b "I'D HUG YOU, BUT THOSE GUNS ARE IN THE WAY. WILL SET A HARD LOCK-DOWN NOW, "
                dc.b "SO USE THE RECYCLER IF YOU NEED.",0

txtAmbushDeath: dc.b 34,"SUCKS IT HAPPENED LIKE THIS. BUT BETTER WITH YOU HERE. JUST.. PROMISE TO KICK THEIR ASS.",34,0

                checkscriptend
