                include macros.s
                include mainsym.s

        ; Script 13, escort scientists begin & end

                org scriptCodeStart

                dc.w EscortScientistsStart
                dc.w EscortScientistsFinish
                dc.w RadioFindFilter

        ; Start escort scientists sequence
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EscortScientistsStart:
                ldy #C_SCIENTIST                ;Ensure sprite file on the same frame as first script exec
                jsr EnsureSpriteFile
                ldx actIndex
                lda actXH,x
                sec
                sbc actXH+ACTI_PLAYER
                cmp #$03
                bcs ESS_WaitUntilClose
                lda scriptVariable
                asl
                tay
                lda ESS_JumpTbl,y
                sta ESS_Jump+1
                lda ESS_JumpTbl+1,y
                sta ESS_Jump+2
ESS_Jump:       jmp $1000

ESS_JumpTbl:    dc.w ESS_1
                dc.w ESS_2
                dc.w ESS_3

ESS_1:          inc scriptVariable
                jsr AddQuestScore
                ldy #ACT_SCIENTIST2
                gettext txtEscortStart1
                jmp SpeakLine

ESS_2:          inc scriptVariable
                ldy #ACT_SCIENTIST3
                gettext txtEscortStart2
                jmp SpeakLine

ESS_3:          inc scriptVariable
                ldy #ACT_SCIENTIST2
                gettext txtEscortStart3
                jsr SpeakLine
                lda #<EP_ESCORTSCIENTISTSREFRESH
                ldx #>EP_ESCORTSCIENTISTSREFRESH
                sta actScriptEP
                stx actScriptF
                sta actScriptEP+1
                stx actScriptF+1
ESS_WaitUntilClose:
                rts

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
        
txtEscortStart2:dc.b 34,"NO-ONE TOOK NOTICE WHILE THE AI ORDERED HUGE SHIPMENTS TO BUILD THIS THING UNDERGROUND. "
                dc.b "I BELIEVE IT'S RE-ENACTING THE RAGNAROK MYTH - JORMUNGANDR POISONING THE SKY. "
                dc.b "HOW EXACTLY, I'M NOT SURE. BUT A MACHINE THAT LARGE IS A CREDIBLE THREAT. "
                dc.b "IT'S A LOT TO ASK, BUT OUR BELIEF IS THAT YOU MUST VENTURE BELOW AND DISABLE JORMUNGANDR. THERE'S "
                dc.b "NO KNOWING IF IT'S ALREADY READY TO ACT, SO WAITING FOR THE CAVALRY COULD BE TOO LATE.",34,0

txtEscortStart3:dc.b 34,"YOU'LL NEED A LUNG FILTER TO SURVIVE THE TUNNELS. THAT MEANS A SECOND SURGERY. THIS REQUIRES THE OPERATING ROOM ON THE LOWER LABS' "
                dc.b "RIGHT SIDE, AT THE VERY BOTTOM. PLEASE LEAD THE WAY.",34,0

txtEscortStart1:dc.b 34,"THERE YOU ARE. I'LL LET LINDA EXPLAIN.",34,0

txtRadioFindFilter:
                dc.b 34,"LINDA HERE. WE GOT AHEAD OF OURSELVES - THERE'S NO LUNG FILTERS STORED IN HERE. AMOS IS QUITE ANGRY WITH HIMSELF. "
                dc.b "SINCE YOU'RE MUCH BETTER SUITED TO EXPLORING, "
                dc.b "WE'LL HAVE TO ASK YOU TO FIND ONE. THERE SHOULD BE AT LEAST ONE PACKAGE IN THE LOWER LABS SOMEWHERE.",34,0

txtEscortFinish:dc.b 34,"WE'D NEVER HAVE MADE IT ALONE. NOW WE NEED TIME TO SET UP. WE'LL GIVE YOU A CALL WHEN READY.",34,0

                checkscriptend