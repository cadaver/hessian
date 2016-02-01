                include macros.s
                include mainsym.s

        ; Script 1, intro cutscene & conversation

                org scriptCodeStart

                dc.w Scientist1
                dc.w IntroCutscene

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

        ; Intro cutscene (text display at top of screen)
        ;
        ; Parameters: X actor number
        ; Returns: -
        ; Modifies: various

IntroCutscene:  lda #MUSIC_MYSTERY
                jsr PlaySong
                lda #$01                        ;Redraw manually to avoid the update performed by CenterPlayer
                sta blockX                      ;which would cause a small glitch in the player positioning
                lda #$02
                sta blockY
                lda #$64
                sta mapX
                lda #$16
                sta mapY
                jsr RedrawAndAddActors
                lda #$00                        ;Same Y-scroll as textscreen
                sta scrollY
                sta page
                sta textFade
                jsr SL_NewMapPos
                jsr IC_SetPlayerPosition
                jsr DrawActors                  ;Draw actors once to ensure sprites have been loaded
                jsr IC_InitTextDisplay
IC_Loop:        lda textFade
                bne IC_NoNextPage
                lda page
                cmp #2
                bcs IC_BeginGame
                asl
                tay
                lda pageTbl,y
                sta zpSrcLo
                lda pageTbl+1,y
                sta zpSrcHi
                ldy #0
IC_PrintText:   lda (zpSrcLo),y
                sta panelScreen,y
                iny
                cpy #5*40
                bne IC_PrintText
                inc page
                lda #1
                sta textFadeDir
IC_NoNextPage:  jsr IC_Update
                jmp IC_Loop
IC_BeginGame:   lda #FR_JUMP+1
                sta actF1+ACTI_PLAYER
                sta actF2+ACTI_PLAYER
                jsr WaitBottom
                jsr IC_StopTextDisplay
                jmp StartMainLoop

IC_SetPlayerPosition:
                lda #$00
                sta actD+ACTI_PLAYER
                sta actSY+ACTI_PLAYER
                sta actMB+ACTI_PLAYER
                lda #FR_DIE
                sta actF1+ACTI_PLAYER
                lda #FR_STAND
                sta actF2+ACTI_PLAYER
                lda #$b8
                sta actYL+ACTI_PLAYER
                lda #$1a
                sta actYH+ACTI_PLAYER
                rts

IC_Update:      jsr FinishFrame
                jsr GetControls
                lda textFadeDir
                beq IC_TextDone
                clc
                adc textFade
                sta textFade
                bpl IC_TextNotOverLow
                inc textFade
                beq IC_StopTextFade
IC_TextNotOverLow:
                cmp #12
                bcc IC_TextNotOverHigh
IC_StopTextFade:lda #0
                sta textFadeDir
IC_TextNotOverHigh:
                lda textFade
                lsr
                lsr
                tay
                lda textFadeTbl,y
                ldx #5*40
IC_SetTextColor:sta colors-1,x
                dex
                bne IC_SetTextColor
                rts
IC_TextDone:    jsr GetFireClick
                bcs IC_StartPageFade
                lda keyType
                bmi IC_NoPageFade
IC_StartPageFade:
                lda #-1
                sta textFadeDir
IC_NoPageFade:  rts

IC_InitTextDisplay:
                jsr WaitBottom
                ldx #6*40
                lda #$00
                jsr IC_SetTextColor
                lda #54+5*8+1
                sta Irq6_Irq1Pos+1              ;Show text in the top of screen
                sta Irq6_LevelUpdate+1          ;Allow level animation
                rts

IC_StopTextDisplay:
                jsr WaitBottom
                ldx #6*40
                lda #$00
                jsr IC_SetTextColor
                lda #IRQ1_LINE
                sta Irq6_Irq1Pos+1
                jmp PostLoad

        ; Tables / variables

page:           dc.b 0
textFade:       dc.b 0
textFadeDir:    dc.b 0
textFadeTbl:    dc.b $00,$06,$03,$01
pageTbl:        dc.w page1
                dc.w page2

        ; Messages

txtIntro1:      dc.b 34,"GOOD, YOU'RE ON YOUR FEET. I'M VIKTOR - WE NEED TO REACH THE OTHERS, WHO ARE HOLED UP ON THE PARKING GARAGE BOTTOM LEVEL. FOLLOW ME.",34,0

txtIntro2:      dc.b 34,"ARGH, I'M NO GOOD TO GO ON. SEARCH THE UPSTAIRS - YOU'LL NEED A PASSCARD WE USED TO LOCK UP THIS PLACE. "
                dc.b "WATCH OUT FOR MORE OF THOSE BASTARDS.. AND ONE FINAL THING - THE NANOBOTS RUNNING YOUR BODY DEPEND ON BATTERY POWER. "
                dc.b "DON'T RUN OUT.",34,0

page1:               ;0123456789012345678901234567890123456789
                dc.b "KIM, A SECURITY GUARD WORKING THE NIGHT "
                dc.b " SHIFT AT THRONE GROUP SCIENCE COMPLEX  "
                dc.b "WAKES UP INSIDE A CARGO CONTAINER WHICH "
                dc.b " HAS BEEN CONVERTED INTO AN IMPROVISED  "
                dc.b "       EMERGENCY OPERATING ROOM.        "

page2:          dc.b "SHE REMEMBERS MULTIPLE HOSTILES OPENING "
                dc.b "FIRE ON THE STAFF, EVERYTHING FADING TO "
                dc.b " BLACK AS ROUNDS HAMMER INTO HER CHEST  "
                dc.b " AND FINALLY A VOICE: ",34,"NEED ARTIFICIAL  "
                dc.b " CIRCULATION .. NANOBOT INFUSION NOW!",34,"  "

                checkscriptend
