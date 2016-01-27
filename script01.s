                include macros.s
                include mainsym.s

        ; Script 1, intro conversations

                org scriptCodeStart

                dc.w Scientist1
                dc.w Scientist2
                dc.w GarageComputer

        ; Scientist 1 (intro) move routine & conversation
        ;
        ; Parameters: X actor number
        ; Returns: -
        ; Modifies: various

Scientist1:     jsr MoveHuman
                lda menuMode
                cmp #MENU_DIALOGUE
                beq S1_InDialogue
                lda scriptVariable
                asl
                tay
                lda S1_JumpTbl,y
                sta S1_Jump+1
                lda S1_JumpTbl+1,y
                sta S1_Jump+2
S1_Jump:        jsr $0000
                ldx actIndex
S1_InDialogue:  rts

S1_JumpTbl:     dc.w S1_WaitFrame
                dc.w S1_IntroDialogue
                dc.w S1_SetAttack
                dc.w S1_Dying
                dc.w S1_DoNothing

S1_WaitFrame:   inc scriptVariable              ;Special case wait 1 frame (loading)
                ldy lvlDataActBitsStart+$04
                lda lvlStateBits,y              ;Disable rotordrone until parking garage visited
                and #$ff-$04
                sta lvlStateBits,y
                ldx #MENU_INTERACTION           ;Set interaction mode meanwhile so that player can't move away
                jmp SetMenuMode

S1_IntroDialogue:
                inc scriptVariable
                ldy #ACT_SCIENTIST1
                gettext txtIntro1
                jmp SpeakLine

S1_SetAttack:   jsr S1_LimitControl
                lda actHp,x
                beq S1_Dead
                lda #JOY_RIGHT
                sta actMoveCtrl,x
                lda #ACT_SMALLDROID
                jsr FindActor
                bcc S1_NoDroid
                lda #AIMODE_FLYER
                sta actAIMode,x
                lda actIndex                    ;Make sure targets the scientist
                sta actAITarget,x
                lda actTime,x                   ;Artificially increase aggression to guarantee kill
                bmi S1_NoAggression
                clc
                adc #$20
                bpl S1_AggressionOK
                lda #$7f
S1_AggressionOK:sta actTime,x
S1_NoAggression:lda #LINE_YES
                sta actLine,x
S1_DyingContinue:
S1_NoDroid:     rts
S1_Dead:        inc scriptVariable
                lda #ACT_SMALLDROID
                jsr FindActor
                bcc S1_NoDroid
                lda #JOY_LEFT|JOY_UP
                sta actMoveCtrl,x
                lda #AIMODE_FLYERFREEMOVE
                sta actAIMode,x                 ;Fly away after kill, become nonpersistent (not found anymore)
                jmp SetNotPersistent

S1_Dying:       jsr S1_LimitControl
                lda actF1,x                     ;Wait until on the ground
                cmp #FR_DUCK+1
                beq S1_DieAgain
                cmp #FR_DIE+2
                bcc S1_DyingContinue
                lda actTime,x
                cmp #DEATH_FLICKER_DELAY+1
                bcs S1_DyingContinue
                ldy #ACTI_PLAYER                ;Turn to player
                jsr GetActorDistance
                lda temp5
                sta actD,x
                inc actHp,x                     ;Halt dying for now to speak
                lda #FR_DUCK+1
                sta actF1,x
                sta actF2,x
                lda #JOY_DOWN
                sta actMoveCtrl,x
                ldy #ACT_SCIENTIST1
                gettext txtIntro2
                jmp SpeakLine
S1_DieAgain:    inc scriptVariable
                lda #DEATH_FLICKER_DELAY+25
                sta actTime,x
                lda #FR_DIE+2
                sta actF1,x
                sta actF2,x
                dec actHp,x
                lda #$00
                sta temp4
                lda #ITEM_PISTOL
                jsr DI_ItemNumber
                ldy temp8
                lda #10
                sta actHp,y                     ;Full mag
S1_DoNothing:   rts

S1_LimitControl:lda #JOY_RIGHT|JOY_LEFT|JOY_DOWN|JOY_UP ;Don't allow entering the container in the beginning,
                ldy actXH+ACTI_PLAYER                   ;or going too far to the left
                cpy #$67
                bcs S1_LimitLeft
                lda #JOY_RIGHT|JOY_DOWN
S1_LimitLeft:   and joystick
                sta joystick
                rts

        ; Scientist 2 conversation
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Scientist2:     ldy #C_SCIENTIST                ;Ensure sprite file on the same frame as first script exec
                jsr EnsureSpriteFile
                lda actXH+ACTI_PLAYER           ;Wait until player close enough
                cmp #$37
                bcc S2_Wait
                cmp #$3c
                bcs S2_Wait
                lda actYH+ACTI_PLAYER
                cmp #$29
                bcs S2_Wait
                lda actMB+ACTI_PLAYER
                lsr
                bcc S2_Wait
                lda scriptVariable
                asl
                tay
                lda S2_JumpTbl,y
                sta S2_Jump+1
                lda S2_JumpTbl+1,y
                sta S2_Jump+2
S2_Jump:        jmp $0000
S2_Wait:        rts

S2_JumpTbl:     dc.w S2_Dialogue1
                dc.w S2_Dialogue2
                dc.w S2_Dialogue3
                dc.w S2_Dialogue4

S2_Dialogue1:   jsr AddQuestScore
                inc scriptVariable
                ldy lvlDataActBitsStart+$04
                lda lvlStateBits,y              ;Enable rotordrone now
                ora #$04
                sta lvlStateBits,y
                ldy #ACT_SCIENTIST2
                gettext txtParkingGarage1
                jmp SpeakLine

S2_Dialogue2:   inc scriptVariable
                ldy #ACT_SCIENTIST3
                gettext txtParkingGarage2
                jmp SpeakLine

S2_Dialogue3:   inc scriptVariable
                ldy #ACT_SCIENTIST2
                gettext txtParkingGarage3
                jmp SpeakLine

S2_Dialogue4:   lda #ITEM_COMMGEAR
                ldx #1
                jsr AddItem
                ldx actIndex
                lda #$00
                sta temp4
                lda #ITEM_SECURITYPASS
                jsr DI_ItemNumber
                lda actD,x
                asl
                lda #$7f
                adc #$00
                ldx temp8
                jsr MoveActorX                  ;Move item to scientist's facing direction
                lda #-16*8
                jsr MoveActorY
                lda #SFX_PICKUP
                jsr PlaySfx
                lda #$00
                sta actScriptF                  ;No more script exec here
                ldy #ACT_SCIENTIST2
                gettext txtParkingGarage4
                jmp SpeakLine

        ; Computer in garage script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

GarageComputer: jsr SetupTextScreen
                gettext txtGarageComputer
                ldy #0
                sty temp1
                sty temp2
                jsr PrintMultipleRows
                jsr WaitForExit
                jmp CenterPlayer

        ; Messages

txtIntro1:      dc.b 34,"GOOD, YOU'RE ON YOUR FEET. I'M VIKTOR - WE NEED TO REACH THE OTHERS, WHO ARE HOLED UP ON THE PARKING GARAGE BOTTOM LEVEL. FOLLOW ME.",34,0

txtIntro2:      dc.b 34,"ARGH, I'M NO GOOD TO GO ON. SEARCH THE UPSTAIRS - YOU'LL NEED A PASSCARD WE USED TO LOCK UP THIS PLACE. "
                dc.b "WATCH OUT FOR MORE OF THOSE BASTARDS.. AND ONE FINAL THING - THE NANOBOTS RUNNING YOUR BODY DEPEND ON BATTERY POWER. "
                dc.b "DON'T RUN OUT.",34,0

txtParkingGarage1:
                dc.b 34,"I SEE VIKTOR DIDN'T MAKE IT. BUT YOU DID, THAT'S WHAT COUNTS. AMOS, NANOSURGEON. SHE'S LINDA, CYBER-PSYCHOLOGIST. "
                dc.b "YOU'VE SEEN HOW OUR CREATIONS HAVE TURNED ON US. TOTAL INTERNET AND PHONE BLACKOUT. WE'RE STUCK AND HELP IS UNLIKELY. "
                dc.b "AS THE ONLY ENHANCED PERSON IN THIS ROOM, RIGHT NOW YOU'RE OUR BEST BET.",34,0

txtParkingGarage2:
                dc.b 34,"COMMON SENSE WOULD DICTATE WE ATTEMPT TO ESCAPE. BUT THESE MACHINES' HIGHLY COORDINATED ACTIONS "
                dc.b "SUGGEST A CENTRAL AI, WHICH I DIDN'T KNOW WE HAD DEVELOPED. "
                dc.b "THERE MAY BE MORE THAN OUR LIVES AT STAKE.",34,0

txtParkingGarage3:
                dc.b 34,"YES. WE MUST FIND OUT THEIR ULTIMATE AIM BEYOND JUST KILLING EVERYONE. "
                dc.b "TAKE THIS SECURITY PASS TO ACCESS THE UPPER LABS, PLUS A WIRELESS CAMERA/RADIO "
                dc.b "SET SO WE CAN STAY IN TOUCH.",34,0

txtParkingGarage4:
                dc.b 34,"GOOD LUCK.",34,0

txtGarageComputer:
                     ;0123456789012345678901234567890123456789
                dc.b "SEQUENCE OF EVENTS:",0
                dc.b " ",0
                dc.b "1. 'HESSIAN' PROJECT CANCELLED",0
                dc.b "2. NORMAN THRONE GOES MISSING",0
                dc.b "3. ???",0
                dc.b "4. ROBOTS OUT OF CONTROL, PERSONNEL",0
                dc.b "   MASSACRED",0,0

                checkscriptend
