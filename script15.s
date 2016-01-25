                include macros.s
                include mainsym.s

        ; Script 15, escort finish

                org scriptCodeStart

                dc.w EscortScientistsFinish
                dc.w RadioFindFilter

        ; Escort scientists sequence finish
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EscortScientistsFinish:
                ldx actIndex
                ldy actT,x
                lda npcBrakeTbl-ACT_FIRSTPERSISTENTNPC,y
                jsr BrakeActorX  ;Move at slightly different speed to not look stupid
                lda actXH,x
                cmp npcStopPos-ACT_FIRSTPERSISTENTNPC,y
                bcc ESF_Stop
                lda #JOY_LEFT
                sta actMoveCtrl,x
                lda #AIMODE_IDLE
                beq ESF_StoreMode
ESF_Stop:       cpy #ACT_SCIENTIST3
                bne ESF_NoDialogue
                lda actSX,x
                bne ESF_NoDialogue
                lda #$00                        ;Stop actor script exec for now
                sta actScriptF
                sta actScriptF+1
                ldy #ACT_SCIENTIST2
                gettext txtEscortFinish
                jmp SpeakLine
ESF_NoDialogue: lda #AIMODE_TURNTO
ESF_StoreMode:  sta actAIMode,x
                rts

        ; Find filter script. Also move scientists to final positions before surgery
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioFindFilter:jsr StopZoneScript
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
                ldx #>EP_BEGINSURGERY
                sta actScriptEP
                stx actScriptF
                gettext txtRadioFindFilter
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx
MoveScientistSub2:
                sta lvlActX,y                   ;Set also Y & level so that this can be used as shortcut in testing
                lda #$56
                sta lvlActY,y
                txa
                sta lvlActF,y
                lda #$08+ORG_GLOBAL
                sta lvlActOrg,y
BA_Skip:        rts

        ; Tables

npcStopPos:     dc.b $4e,$4d
npcBrakeTbl:    dc.b 4,0

        ; Messages
        ; Reordered to compress better

txtRadioFindFilter:
                dc.b 34,"LINDA HERE. WE GOT AHEAD OF OURSELVES - THERE'S NO LUNG FILTERS STORED IN HERE. AMOS IS QUITE ANGRY WITH HIMSELF. "
                dc.b "SINCE YOU'RE MUCH BETTER SUITED TO EXPLORING, "
                dc.b "WE'LL HAVE TO ASK YOU TO FIND ONE. THERE SHOULD BE AT LEAST ONE PACKAGE IN THE LOWER LABS SOMEWHERE.",34,0

txtEscortFinish:dc.b 34,"WE'D NEVER HAVE MADE IT ALONE. NOW WE NEED TIME TO SET UP. WE'LL GIVE YOU A CALL WHEN READY.",34,0

                checkscriptend
