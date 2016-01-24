                include macros.s
                include mainsym.s

        ; Script 13, second hacker scene (optional) + saboteur robot

                org scriptCodeStart

                dc.w Hacker3
                dc.w Hacker4
                dc.w CombatRobotSaboteur
                dc.w DestroyCombatRobotSaboteur

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
H_SpeakCommon:  ldy #ACT_HACKER
                jmp SpeakLine

CheckDistance:  lda actXH+ACTI_PLAYER
                cmp #$1c
                bcc CD_Close
                pla                             ;If far, do not return
                pla
CD_Close:       rts

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

        ; Saboteur robot
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

CombatRobotSaboteur:
                lda #FR_ATTACK+3
                sta actF2,x
                lda #FR_STAND
                sta actF1,x
                jsr Random
                and #$08
                sta temp1
                lda actXL,x
                and #$f0
                ora temp1
                sta actXL,x
                jsr Random
                and #$1f
                clc
                adc actTime,x
                sta actTime,x
                bcc CRS_NoEffect
                lda #ACTI_FIRSTNPCBULLET
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc CRS_NoEffect
                lda #ACT_EMP
                jsr SpawnActor
                tya
                tax
                lda #8*8
                jsr MoveActorX
                lda #8*8
                jsr MoveActorY
                dec actYH,x
                lda #COLOR_FLICKER
                sta actFlash,x
                lda #8
                sta actTime,x
                lda #0
                sta actBulletDmgMod-ACTI_FIRSTPLRBULLET,x ;Make sure the EMP doesn't do actual damage to anyone
                ldx actIndex
CRS_NoEffect:   rts

        ; Saboteur robot death
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

DestroyCombatRobotSaboteur:
                lda #PLOT_LOWERLABSNOAIR        ;Make lower labs safe again
                jsr ClearPlotBit
                lda #$00
                sta ULO_NoAirFlag+1
                stx temp6
                lda #MUSIC_MYSTERY              ;Restore original music
                jsr PlaySong
                ldx temp6
                jmp ExplodeEnemy3_Ofs24

        ; Messages
        ; Reordered to compress better
        
txtHacker4b:    dc.b 34,"YOU'VE GOT THE OLD TUNNELS PASS? I THINK WE SHOULD HEAD THERE IMMEDIATELY. "
                dc.b "I'LL LOCK THE HIDEOUT, SO USE THE RECYCLER NOW IF YOU NEED.",34,0

txtHacker3:     dc.b 34,"HEY. I APPRECIATE YOU CHECKING ON ME. THIS PLACE IS SECURE SO FAR, BUT I BET THE AI "
                dc.b "IS AWARE OF IT. THERE'S SOMETHING ELSE I FOUND: THE SO-CALLED 'OLD TUNNELS' "
                dc.b "WHICH ALSO BRANCH OFF FROM THE LOWER LABS. HAVEN'T SEEN MACHINE TRAFFIC FROM "
                dc.b "THERE AT ALL. COULD BE THEIR BLIND SPOT, AND THEREFORE SAFE.",34,0

txtHacker4a:    dc.b 34,"BUT GO AND TAKE CARE OF THOSE SCIENTISTS NOW. THEY'RE MUCH MORE EXPOSED.",34,0

                checkscriptend
