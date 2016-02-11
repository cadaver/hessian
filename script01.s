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
                jsr MH_AnimDone
                lda #JOY_DOWN
                sta actMoveCtrl,x
                ldy #ACT_SCIENTIST1
                gettext txtIntro2
                jmp SpeakLine
S1_DieAgain:    inc scriptVariable
                lda #DEATH_FLICKER_DELAY+25
                sta actTime,x
                lda #FR_DIE+2
                jsr MH_AnimDone
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
                lda #$00
                sta page
                sta textFade
                jsr SL_NewMapPos
                jsr IC_SetPlayerPosition
                jsr DrawActors
                jsr IC_InitTextDisplay
IC_Loop:        lda textFade
                bne IC_NoNextPage
                lda page
                cmp #3
                bcs IC_BeginGame
                asl
                tay
                lda pageTbl,y
                ldx pageTbl+1,y
                jsr PrintPage
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
                ldx #3*40
IC_SetTextColor:pha
                jsr WaitBottom
                pla
IC_STCLoop:     sta colors+40-1,x
                dex
                bne IC_STCLoop
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
                lda #<textSplit
                sta Irq5_Get+1
                lda #>textSplit
                sta Irq5_Get+2
                ldx #6*40
                lda #$00
                jsr IC_SetTextColor
                ldx #39
                lda #32
IC_SetEmptyRow: sta screen1+4*40,x              ;Set row below the text empty to hide the split
                dex
                bpl IC_SetEmptyRow
                inc Irq6_LevelUpdate+1          ;Allow level animation
                inc Irq6_SplitMode+1            ;Start split mode
                rts

IC_StopTextDisplay:
                ldx #6*40
                lda #$00
                jsr IC_SetTextColor
                sta Irq6_SplitMode+1            ;End split mode
                rts

PrintPage:      ldy #$00
                sta zpSrcLo
                stx zpSrcHi
PP_Loop:        lda (zpSrcLo),y
                sta screen1+40,y
                iny
                cpy #3*40
                bcc PP_Loop
                rts

        ; Tables / variables

page:           dc.b 0
textFade:       dc.b 0
textFadeDir:    dc.b 0
textFadeTbl:    dc.b $00,$06,$03,$01
pageTbl:        dc.w page1
                dc.w page2
                dc.w page3

textSplit:      dc.b $18,TEXTSCR_D018           ;Show screen1 with text charset
                dc.b $11,$13                    ;Use same Y-scroll as game
                dc.b 50+4*8+1                   ;Resume gamescreen below

        ; Messages

txtIntro1:      dc.b 34,"GOOD, YOU'RE ON YOUR FEET. I'M VIKTOR - WE NEED TO REACH THE OTHERS, WHO ARE HOLED UP ON THE PARKING GARAGE BOTTOM LEVEL. FOLLOW ME.",34,0

txtIntro2:      dc.b 34,"ARGH, I'M NO GOOD TO GO ON. SEARCH THE UPSTAIRS - YOU'LL NEED A PASSCARD WE USED TO LOCK UP THIS PLACE. "
                dc.b "WATCH OUT FOR MORE OF THOSE BASTARDS.. AND ONE FINAL THING - THE NANOBOTS RUNNING YOUR BODY DEPEND ON BATTERY POWER. "
                dc.b "DON'T RUN OUT.",34,0

page1:               ;0123456789012345678901234567890123456789
                dc.b " KIM, A NIGHT SECURITY GUARD WORKING AT "
                dc.b "THRONE GROUP SCIENCE COMPLEX WAKES UP IN"
                dc.b " AN IMPROVISED EMERGENCY OPERATING ROOM."

page2:          dc.b " SHE REMEMBERS MULTIPLE HOSTILES OPENING"
                dc.b " FIRE ON THE STAFF, EVERYTHING FADING TO"
                dc.b " BLACK AS ROUNDS HAMMER INTO HER CHEST.."

page3:          dc.b "  AND FINALLY VOICES: ",34,"MASSIVE TRAUMA.. "
                dc.b "  NEED ARTIFICIAL CIRCULATION.. PREPARE "
                dc.b "       THE NANOBOT INJECTION NOW!",34,"      "

                checkscriptend
