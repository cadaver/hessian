                include macros.s
                include mainsym.s

        ; Script 9, rotordrone boss, hideout scenes

                org scriptCodeStart

                dc.w MoveRotorDrone
                dc.w DestroyRotorDrone
                dc.w Hacker
                dc.w Hacker2
                dc.w Hacker3
                dc.w Hacker4

        ; Rotor drone boss move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveRotorDrone: ldy #C_ROTORDRONE               ;Ensure sprite file on the same frame as first script exec
                jsr EnsureSpriteFile            ;so that there isn't a pause -> frame -> pause sequence
                lda actHp,x
                beq MRD_Fall
                lda #MUSIC_MAINTENANCE+1        ;If alive, play the bossfight music
                jsr PlaySong
                ldx actIndex
                lda #-1                         ;Stay higher than normal flyers
                sta actFall,x
                lda actCtrl,x
                and #JOY_FIRE
                beq MRD_NotFiring
                lda actCtrl,x                   ;Convert horizontal firing to diagonal down
                ora #JOY_DOWN
                sta actCtrl,x
MRD_NotFiring:  lda actYH,x                     ;Prevent going outside zone
                cmp limitU
                bcs MRD_NoLimitU
                lda actMoveCtrl,x
                and #$ff-JOY_UP
                ora #JOY_DOWN
                sta actMoveCtrl,x
                bne MRD_ControlsOK
MRD_NoLimitU:   adc #$00
                cmp limitD
                bne MRD_ControlsOK
                lda actMoveCtrl,x
                and #$ff-JOY_DOWN
                ora #JOY_UP
                sta actMoveCtrl,x
MRD_ControlsOK: jsr MoveAccelerateFlyer
                lda #$00
                ldy actSX,x
                bmi MRD_SpeedNeg
MRD_SpeedPos:   cpy #1*8
                bcc MRD_FrameOK
                lda #$08
                bne MRD_FrameOK
MRD_SpeedNeg:   cpy #-1*8+1
                bcs MRD_FrameOK
                lda #$04
MRD_FrameOK:    sta temp1
                inc actFd,x
                lda actFd,x
                and #$01
                ora temp1
                sta adRotorDroneFrames
                ora #$02
                sta adRotorDroneFrames+1
                jmp AttackGeneric
MRD_Fall:       jsr Random
                and #$01
                sta shakeScreen
                jsr FallingMotionCommon
                tay
                beq MRD_ContinueFall
                lda #MUSIC_MAINTENANCE          ;Back to the normal music
                jsr PlaySong
                ldx actIndex
                jmp ExplodeEnemy2_8             ;Drop item & explode at any collision
MRD_ContinueFall:
                jsr Random                      ;Spawn explosions randomly while falling
                and #$3f
                clc
                adc #$10
                adc actTime,x
                sta actTime,x
                bcc MRD_NoExplosion
                jsr GetAnyFreeActor
                bcc MRD_NoExplosion
                jsr SpawnActor                  ;Actor type undefined at this point, will be initialized below
                tya
                tax
                jsr ExplodeActor
                ldx actIndex
MRD_NoExplosion:
ESF_InMemory:   rts

        ; Rotor drone boss destroy routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DestroyRotorDrone:
                lda #-2*8                       ;Give upward speed so that the fall lasts longer
                sta actSY,x
                lda #PLOT_HIDEOUTOPEN
                jmp SetPlotBit

        ; Hacker script routine (initial scene in the hideout)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Hacker:         jsr CheckDistance
                jsr AddQuestScore
H_Random:       jsr Random
                and #$03
                beq H_Random
                clc
                adc #$36                        ;Randomize between 75%, 85%, 95%
                ldy #$00
                sta txtPercent
                lda #<EP_HACKER2
                sta actScriptEP+2               ;Set 2nd script
                gettext txtHacker1
H_SpeakCommon:  ldy #ACT_HACKER
                jmp SpeakLine

CheckDistance:  lda actXH+ACTI_PLAYER
                cmp #$1c
                bcc CD_Close
                pla                             ;If far, do not return
                pla
H_NoItem:
CD_Close:       rts

        ; Hacker script routine 2 (when picking up the amp)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Hacker2:        ldy #ITEM_AMPLIFIER
                jsr FindItem
                bcc H_NoItem
                lda actF1+ACTI_PLAYER           ;Wait until player is standing again
                cmp #FR_DUCK
                bcs H_NoItem
                lda #$00                        ;No more scripts for now
                sta actScriptF+2
                gettext txtHacker2
                jmp H_SpeakCommon

        ; Hacker script routine 3 (after lower labs server room)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Hacker3:        jsr CheckDistance
                jsr AddQuestScore
                lda #<EP_HACKER4
                sta actScriptEP+2
                if SKIP_PLOT > 0
                lda #PLOT_ESCORTCOMPLETE
                jsr SetPlotBit
                lda #PLOT_ELEVATOR1
                jsr SetPlotBit
                endif
                gettext txtHacker3
                jmp H_SpeakCommon

        ; Hacker script routine 4 (going to old tunnels)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Hacker4:        jsr CheckDistance
                lda #PLOT_ESCORTCOMPLETE
                jsr GetPlotBit
                bne H4_Ready
                lda #$00                        ;No more scripts for now
                sta actScriptF+2
                gettext txtHacker4a
                jmp H_SpeakCommon
H4_Ready:       lda #PLOT_LOWERLABSNOAIR        ;If late in the game, the sabotage
                jsr GetPlotBit                  ;must first be dealt with
                bne H4_Unsafe
                ldy #ITEM_OLDTUNNELSPASS
                jsr FindItem
                bcs H4_HasPass
H4_Unsafe:      rts
H4_HasPass:     lda #PLOT_HIDEOUTOPEN           ;Can not return to hideout
                jsr ClearPlotBit
                lda #<EP_HACKERFOLLOW
                ldx #>EP_HACKERFOLLOW
                sta actScriptEP+2
                stx actScriptF+2
                gettext txtHacker4b
                jmp H_SpeakCommon

        ; Messages

txtHacker1:     dc.b 34,"HEY. YOU MUST BE KIM. THE SCIENTISTS TOLD YOU MIGHT DROP BY. "
                dc.b "I'M JEFF. SORRY ABOUT THAT SENTRY DRONE, HAD TO MAKE SURE YOU'RE NOT A MACHINE. "
                dc.b "I'D ESTIMATE YOUR FIGHTING STYLE AS "
txtPercent:     dc.b "X5% HUMAN. YOU CAME FOR THAT SIGNAL AMP FOR THE LASER, RIGHT? "
                dc.b "IT'S UNTESTED, SO USE CAUTION. OH, FEEL FREE TO USE THE RECYCLER "
                dc.b "AT THE BACK. BUT DON'T TOUCH ANYTHING ELSE.",34,0

txtHacker2:     dc.b 34,"IT'S A MESSED UP SITUATION ALL RIGHT. BUT IN OUR LINE OF WORK, "
                dc.b "IT WAS BOUND TO HAPPEN SOONER OR LATER.",34,0

txtHacker3:     dc.b 34,"HEY. GOOD TO SEE YOU. THIS PLACE IS SECURE SO FAR, BUT I BET THE AI "
                dc.b "IS AWARE OF IT. THERE'S SOMETHING MORE I FOUND: THE SO-CALLED 'OLD TUNNELS' "
                dc.b "WHICH ALSO BRANCH OFF FROM THE LOWER LABS. NO MACHINE TRAFFIC FROM "
                dc.b "THERE AT ALL. COULD BE THEIR BLIND SPOT, AND THEREFORE SAFE.",34,0

txtHacker4a:    dc.b 34,"BUT GO AND TAKE CARE OF THOSE SCIENTISTS NOW. THEY'RE MUCH MORE EXPOSED.",34,0

txtHacker4b:    dc.b 34,"YOU'VE GOT THE OLD TUNNELS PASS? I THINK WE SHOULD HEAD THERE IMMEDIATELY. "
                dc.b "I'LL LOCK THE HIDEOUT, SO USE THE RECYCLER NOW IF YOU NEED.",34,0

                checkscriptend
