                include macros.s
                include mainsym.s

        ; Script 18, after surgery ambush

                org scriptCodeStart

                dc.w AfterSurgery
                dc.w AfterSurgeryRun
                dc.w AfterSurgeryZone
                dc.w AfterSurgeryNoAir
                dc.w AfterSurgeryFollow
                dc.w AfterSurgeryNoAirDie
                dc.w AfterSurgeryNoAirRadio

        ; After surgery ambush
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgery:   lda scriptVariable
                asl
                tay
                lda asJumpTbl,y
                sta AS_Jump+1
                lda asJumpTbl+1,y
                sta AS_Jump+2
AS_Jump:        jmp $0000

AS_1:           jsr AfterSurgeryRun             ;Ensure player position right when the screen turns on
                ldy #ITEM_LUNGFILTER
                jsr RemoveItem
                lda upgrade
                ora #UPG_TOXINFILTER
                sta upgrade                     ;Has the filter upgrade now
                lda #HP_PLAYER                  ;Always full HP + at least minimal battery, as there will
                sta actHp+ACTI_PLAYER           ;be battery drain
                lda battery+1
                cmp #LOW_BATTERY
                bcs AS_1BatteryOK
                lda #LOW_BATTERY
                sta battery+1
AS_1BatteryOK:  jsr AddQuestScore
                inc scriptVariable
                ldy #ACT_SCIENTIST2
                gettext txtAfterSurgery1
                jmp SpeakLine

AS_2:           jsr Random
                and #$01
                sta shakeScreen
                jsr Random
                cmp #$10
                bcs AS_2NoExplosion
                jsr HeavyShake
AS_2NoExplosion:lda #ACT_SCIENTIST3
                jsr FindActor
                inc actTime,x
                lda actTime,x
                cmp #50
                bcc AS_2Wait
                inc scriptVariable
AS_2Wait:       rts

HeavyShake:     lda #$02
                sta shakeScreen
                lda #SFX_EXPLOSION
                jmp PlaySfx

AS_3:           inc scriptVariable
                ldy #ACT_SCIENTIST3
                gettext txtAfterSurgery2
                jmp SpeakLine

AS_4:           lda #ACT_HIGHWALKER
                jsr FindLevelActor
                lda lvlActY,y                   ;Unhide waiting enemy now
                and #$7f
                sta lvlActY,y
                jsr GetLevelActorIndex
                lda #$38
                sta lvlActX,y
                lda #$3c
                sta lvlActY,y
                lda #ACT_COMBATROBOTSABOTEUR
                sta lvlActT,y
                lda #$10+AIMODE_IDLE
                sta lvlActF,y
                lda #$00
                sta lvlActWpn,y
                lda #$08+ORG_GLOBAL
                sta lvlActOrg,y                 ;Create saboteur enemy
                inc scriptVariable
                lda #ACT_SCIENTIST2
                jsr FindActor
                lda #AIMODE_IDLE
                sta actAIMode,x
                lda #$00
                sta actMoveCtrl,x
                sta actTime,x
                sta actD,x
                lda #HP_SCIENTIST2              ;Make possible to die
                sta actHp,x
                lda #MUSIC_MYSTERY+1
                jsr PlaySong
                jmp HeavyShake                  ;One more shake + explosion as walker appears

AS_5:           lda #ACT_HIGHWALKER
                jsr FindActor
                bcc AS_5Wait
                lda actXH,x
                pha
                lda #ACT_SCIENTIST2
                jsr FindActor
                pla
                ldy actHp,x
                beq AS_5Dead
                cmp #$46
                bcs AS_5Shake
                inc actTime,x
                lda actTime,x
                cmp #8
                bcc AS_5RunRight
                bcs AS_5RunLeft
AS_5Shake:      lda AA_ItemFlashCounter+1       ;Shake screen until walker visibly onscreen
                asl
                and #$02
                sta shakeScreen
                rts
AS_5RunRight:   lda #JOY_RIGHT
                skip2
AS_5RunLeft:    lda #JOY_LEFT
                sta actMoveCtrl,x
                rts
AS_5Dead:       lda #75                         ;Make the corpse stay slightly longer
                sta actTime,x
                lda #ACT_SCIENTIST3
                jsr FindActor                   ;Linda uses EMP to destroy (2 shots needed)
                lda #AIMODE_SNIPER
                sta actAIMode,x
                inc scriptVariable
AS_6Wait:
AS_5Wait:       rts

AS_6:           lda #ACT_HIGHWALKER
                jsr FindActor
                bcs AS_6Wait
                lda #ACT_EXPLOSIONGENERATORRISING
                jsr FindActor
                bcs AS_6Wait
                inc scriptVariable
                ldy #ACT_SCIENTIST3
                gettext txtAfterSurgery3
                jmp SpeakLine

AS_7:           ldx #ACTI_PLAYER                ;Player regains control
                lda #-9*8
                jsr MoveActorX
                lda #8*8
                jsr MoveActorY
                jsr NoInterpolation
                jsr StopScript
                lda #FR_STAND
                sta actF1+ACTI_PLAYER
                sta actF2+ACTI_PLAYER
                inc scriptVariable
AS_8Wait:       rts

AS_8:           lda actXH+ACTI_PLAYER
                cmp #$40
                beq AS_8Wait
                lda #<EP_AFTERSURGERYFOLLOW   ;Change to following script
                sta actScriptEP+1
                ldy #ACT_SCIENTIST3
                gettext txtAfterSurgery4
                jmp SpeakLine

asJumpTbl:      dc.w AS_1
                dc.w AS_2
                dc.w AS_3
                dc.w AS_4
                dc.w AS_5
                dc.w AS_6
                dc.w AS_7
                dc.w AS_8

        ; After surgery continuous script, keep player in place
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgeryRun:lda joystick
                and #JOY_FIRE                   ;Fire must be possible to advance dialogue
                sta joystick
                lda #$00
                sta actXL+ACTI_PLAYER
                sta actD+ACTI_PLAYER
                sta actSY+ACTI_PLAYER
                lda #FR_DIE+2
                sta actF1+ACTI_PLAYER
                sta actF2+ACTI_PLAYER
                lda #$58
                sta actYL+ACTI_PLAYER
                lda #$41
                sta actXH+ACTI_PLAYER
                lda #$55
                sta actYH+ACTI_PLAYER
ASZ_AlreadySet: rts

        ; After surgery zone script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgeryZone:
                lda levelNum
                cmp #$0f                        ;Reached old tunnels?
                beq ASZ_Survived
                cmp #$08
                bne ASZ_Stop
                lda #ACT_SCIENTIST3
                jsr TransportNPCToPlayer
                lda #PLOT_LOWERLABSNOAIR
                jsr GetPlotBit
                bne ASZ_AlreadySet
                lda #$00
                sta UA_SpawnDelay+1             ;Wait a bit before next dialogue, ensure
                lda #<EP_AFTERSURGERYNOAIR      ;no enemy spawn in the meanwhile
                sta actScriptEP+1
                if SKIP_PLOT > 0
                lda #PLOT_ELEVATOR1
                jsr SetPlotBit
                endif
                lda #PLOT_LOWERLABSNOAIR
                jmp SetPlotBit
ASZ_Survived:   jsr AddQuestScore
                lda #ACT_SCIENTIST3             ;Todo: continue story from here
                jsr TransportNPCToPlayer
                lda #<EP_REACHOLDTUNNELS
                sta actScriptEP+1
                lda #>EP_REACHOLDTUNNELS
                sta actScriptF+1
ASZ_Stop:       jmp StopZoneScript              ;No zone script for now

        ; After surgery follow script (refresh follow mode & zone script)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgeryFollow:
                ldx actIndex
                lda oxygen              ;Die if run out of oxygen,
                beq ASF_Die             ;or if player goes to nether tunnel entrance
                lda actXH+ACTI_PLAYER   ;or to the corridor (avoid elevator script load thrashing)
                clc
                adc actYH+ACTI_PLAYER
                cmp #$6e+$54
                bcs ASF_Die
                cmp #$4a+$42
                bcc ASF_Die
                lda actMB,x             ;Do not follow again until landed
                lsr
                bcc ASF_NoFollow
                lda actXH,x             ;Scripted jump to access the old tunnels
                cmp #$65
                bne ASF_NoJump
                lda actYH,x
                cmp #$4a
                bne ASF_NoJump
                lda actSX,x
                bmi ASF_NoJump
                lda #AIMODE_IDLE
                sta actAIMode,x
                lda #JOY_RIGHT|JOY_UP  ;Jump as far as possible
                sta actMoveCtrl,x
                lda #-6*8+4
                sta actSY,x
                jmp MH_JumpNoPlayer
ASF_NoJump:     lda #AIMODE_FOLLOW
                sta actAIMode,x
                lda #ACTI_PLAYER
                sta actAITarget,x
ASF_NoFollow:   lda #<EP_AFTERSURGERYZONE
                ldx #>EP_AFTERSURGERYZONE
                jmp SetZoneScript
ASF_Die:        ldx actIndex
                lda #AIMODE_IDLE
                sta actAIMode,x
                lda #JOY_DOWN
                sta actMoveCtrl,x
                lda #75
                sta actTime,x
                lda actSX,x                 ;Wait for zero X-speed for the speech bubble
                bne ASF_DieWait
                jsr StopZoneScript
                lda #<EP_AFTERSURGERYNOAIRDIE
                sta actScriptEP+1
ASF_DieTellCode:
                ldy #$02
ASF_DTCLoop:    lda codes+MAX_CODES*3-3,y
                if SKIP_PLOT > 0
                and #$7f
                sta codes+MAX_CODES*3-3,y   ;Unscramble code forcibly now (for testing)
                endif
                ora #$30
                sta txtCode,y
                dey
                bpl ASF_DTCLoop
                ldx actIndex                ;Drop EMP generator now
                lda #ITEM_NONE
                sta actWpn,x
                lda #-15*8
                sta temp4
                lda #ITEM_EMPGENERATOR
                jsr DI_ItemNumber
                ldy #ACT_SCIENTIST3
                gettext txtNoAirDie
                jmp SpeakLine
ASF_DieWait:    rts

        ; After surgery "no air" dialogue
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgeryNoAir:
                ldx actIndex                    ;Stay in place until dialogue
                lda #AIMODE_TURNTO              ;so that speech bubble doesn't levitate
                sta actAIMode,x
                lda oxygen                      ;Let player notice first
                cmp #MAX_OXYGEN-5
                bcs ASNA_Wait
                lda #PLOT_HIDEOUTAMBUSH         ;Radio silence if ambush
                jsr GetPlotBit
                bne ASNA_NoRadioMsg
                lda #ACT_HACKER
                jsr FindLevelActor
                bcc ASNA_NoRadioMsg
                lda #<EP_AFTERSURGERYNOAIRRADIO ;Transmission if Jeff alive (anywhere)
                skip2
ASNA_NoRadioMsg:lda #<EP_AFTERSURGERYFOLLOW     ;Restore follow script again
                sta actScriptEP+1
                ldy #ACT_SCIENTIST3
                gettext txtNoAir
                jmp SpeakLine
ASNAD_NotRemoved:
ASNA_Wait:      rts

        ; NPC death when running out of oxygen
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgeryNoAirDie:
                ldx actIndex
                jsr SetNotPersistent
                lda #JOY_DOWN
                sta actMoveCtrl,x
                jmp DeathFlickerAndRemove

        ; Jeff's radio transmission about the air shortage
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

AfterSurgeryNoAirRadio:
                lda #<EP_AFTERSURGERYFOLLOW
                sta actScriptEP+1
                gettext txtRadioNoAir
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx

        ; Messages

txtAfterSurgery1:
                dc.b 34,"MINOR COMPLICATIONS. THE NANOBOTS WILL TAKE CARE OF IT.",34,0

txtAfterSurgery2:
                dc.b 34,"WHAT'S THAT?",34,0

txtAfterSurgery3:
                dc.b 34,"NO! AMOS.. TOO LATE.",34,0

txtAfterSurgery4:
                dc.b 34,"YOU OK? AMOS IS GONE, BUT WE HAVE TO GET MOVING. THERE COULD BE MORE AT ANY MOMENT.",34,0

txtNoAir:       dc.b 34,"DO YOU NOTICE? IT'S HARDER TO BREATHE. DAMN.. IT'S THE AI DOING THIS!",34,0

txtNoAirDie:    dc.b 34,"I CAN'T GO ON.. BUT I REMEMBER THE CODE. IT'S "
txtCode:        dc.b "XXX. GO!",34,0

txtRadioNoAir:  dc.b 34,"JEFF HERE. AS YOU CUT OFF THE AI FROM THE SUBNETS, THE SABOTAGE MUST BE PHYSICAL. "
                dc.b "POSSIBLY NEAR THE TOP FLOOR WASTE PROCESSING CHAMBERS. DON'T THINK YOU HAVE TIME TO FIX IT NOW THOUGH.",34,0

                checkscriptend
