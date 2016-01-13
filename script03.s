                include macros.s
                include mainsym.s

        ; Script 3: recycler, early bosses, early NPC interactions

RECYCLER_ITEM_FIRST = ITEM_PISTOL
RECYCLER_ITEM_LAST = ITEM_ARMOR
MAX_RECYCLER_ITEMS = 10
RECYCLER_MOVEDELAY = 8
txtDigits       = actLo
txtCount        = txtDigits-1
recyclerItemList = screen2
recyclerSelection = menuCounter
recyclerListLength = wpnLo
originalItem    = wpnHi
currentIndex    = wpnBits

                org scriptCodeStart

                dc.w RecyclingStation
                dc.w HideoutDoor
                dc.w MoveRotorDrone
                dc.w DestroyRotorDrone
                dc.w Hacker
                dc.w Hacker2
                dc.w Hacker3
                dc.w Hacker4

        ; Recycling station script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RecyclingStation:
                ldy itemIndex
                sty originalItem
                ldy #RECYCLER_ITEM_FIRST
                ldx #$00
                stx txtDigits+3
RS_FindItems:   cpy #ITEM_FIRST_CONSUMABLE
                bcs RS_ItemOK
                jsr FindItem                    ;For weapons, check that is currently held in inventory
                bcc RS_NextItem                 ;(recycler only "sells" ammo, not weapons)
RS_ItemOK:      lda recyclerCountTbl-RECYCLER_ITEM_FIRST,y
                beq RS_NextItem
                tya
                sta recyclerItemList,x
                inx                             ;If using "all items" cheat, the list could be exceeded
                cpx #MAX_RECYCLER_ITEMS         ;Simply cut it in this case
                bcs RS_ListDone
RS_NextItem:    iny
                cpy #RECYCLER_ITEM_LAST+1
                bcc RS_FindItems
RS_ListDone:    lda #$ff
                sta recyclerItemList,x          ;Write endmark
                sta menuMoveDelay               ;Disable controls until joystick centered
                stx recyclerListLength
                jsr BlankScreen
                lda #$02
                sta screen                      ;Set text screen mode
                lda #$0f
                sta scrollX
                ldx #$00
                stx recyclerSelection
                stx SL_CSSScrollY+1
                stx Irq1_Bg1+1
RS_ClearScreenLoop:lda #$20
                sta screen1,x
                sta screen1+$100,x
                sta screen1+$200,x
                sta screen1+SCROLLROWS*40-$100,x
                lda #$01
                sta colors,x
                sta colors+$100,x
                sta colors+$200,x
                sta colors+SCROLLROWS*40-$100,x
                inx
                bne RS_ClearScreenLoop
                lda #9
                sta temp1
                lda #3
                sta temp2
                lda #<txtRecycler
                ldx #>txtRecycler
                jsr PrintText
                lda #0
                sta currentIndex
                lda #5
                sta temp2
RS_PrintItemsLoop:
                lda #10
                sta temp1
                ldx currentIndex
                lda recyclerItemList,x
                bmi RS_PrintExit
                jsr GetItemName
                jsr PrintText
                lda #26
                sta temp1
                ldx currentIndex
                ldy recyclerItemList,x
                lda recyclerCountTbl-RECYCLER_ITEM_FIRST,y
                jsr ConvertDigits
                ldx #0
RS_FindNonZero: lda txtDigits,x
                cmp #$30
                bne RS_FindNonZeroFound
                lda #$20
                sta txtDigits,x
                sta txtDigits-1,x
                inx
                bne RS_FindNonZero
RS_FindNonZeroFound:
                lda #"+"
                sta txtDigits-1,x
                lda #<txtCount
                ldx #>txtCount
                jsr PrintText
                inc temp2
                inc currentIndex
                bne RS_PrintItemsLoop
RS_PrintExit:   lda #<txtExit
                ldx #>txtExit
                jsr PrintText
                lda #9
                sta temp1
                lda #17
                sta temp2
                lda #<txtParts
                ldx #>txtParts
                jsr PrintText
                lda #23
                sta temp1
                lda #<txtCost
                ldx #>txtCost
                jsr PrintText
RS_Redraw:      lda #$20
RS_ArrowLastPos:sta screen1
                lda #8
                sta temp1
                lda recyclerSelection
                clc
                adc #5
                sta temp2
                lda #<txtArrow
                ldx #>txtArrow
                jsr PrintText
                lda zpDestLo
                sta RS_ArrowLastPos+1
                lda zpDestHi
                sta RS_ArrowLastPos+2
                lda #15
                sta temp1
                lda #17
                sta temp2
                lda invCount+ITEM_PARTS-1
                cmp #NO_ITEM_COUNT
                adc #$00
                sta RS_NumParts+1
                jsr Print3Digits
                lda #28
                sta temp1
                lda #$00
                sta reload                      ;Cancel any reloading so that ammo can be shown
                ldx recyclerSelection
                ldy recyclerItemList,x
                bmi RS_ZeroCost
                sty itemIndex
                jsr SetPanelRedrawItemAmmo
                lda recyclerCostTbl-RECYCLER_ITEM_FIRST,y
RS_ZeroCost:    jsr Print3Digits
RS_ControlLoop: jsr FinishFrame
                jsr GetControls
                jsr GetFireClick
                bcs RS_Action
                lda recyclerSelection
                ldx recyclerListLength
                jsr RS_Control
                sta recyclerSelection
                bcs RS_Redraw
                lda keyType
                bmi RS_ControlLoop
RS_Exit:        ldy originalItem
                sty itemIndex
                jsr SetPanelRedrawItemAmmo
                ldy lvlObjNum                   ;Allow immediate re-entry
                jsr InactivateObject
                jmp CenterPlayer
RS_Action:      lda recyclerSelection
                cmp recyclerListLength
                bne RS_Buy
                lda #SFX_SELECT
                jsr PlaySfx
                jmp RS_Exit
RS_Buy:         ldy itemIndex
RS_NumParts:    lda #$00
                cmp recyclerCostTbl-RECYCLER_ITEM_FIRST,y
                bcc RS_BuyFail
                lda recyclerCountTbl-RECYCLER_ITEM_FIRST,y
                tax
                tya
                jsr AddItem
                bcc RS_BuyFail
                ldy itemIndex
                lda recyclerCostTbl-RECYCLER_ITEM_FIRST,y
                ldy #ITEM_PARTS
                jsr DecreaseAmmo
                lda #SFX_EMP
                jsr PlaySfx
                jmp RS_Redraw
RS_BuyFail:     lda #SFX_DAMAGE
                jsr PlaySfx
                jmp RS_ControlLoop

        ; Print 8-bit number in A

Print3Digits:   jsr ConvertDigits
                lda #<txtDigits
                ldx #>txtDigits

        ; Print null-terminated text, with textjump support for item names

PrintText:      sta zpSrcLo
                stx zpSrcHi
                ldy temp2
                lda #40
                ldx #zpDestLo
                jsr MulU
                lda temp1
                jsr Add8
                lda zpDestHi
                ora #>screen1
                sta zpDestHi
                ldy #$00
PT_Loop:        lda (zpSrcLo),y
                bmi PT_Jump
                beq PT_Done
                sta (zpDestLo),y
                iny
                bne PT_Loop
PT_Done:        rts
PT_Jump:        sty PT_Sub+1
                pha
                iny
                lda (zpSrcLo),y
                dey
                sec
PT_Sub:         sbc #$00
                sta zpSrcLo
                pla
                and #$7f
                sbc #$00
                sta zpSrcHi
                bpl PT_Loop

        ; Convert 3 digits to a printable string

ConvertDigits:  jsr ConvertToBCD8
                ldx #$00
                lda temp7
                jsr StoreDigit
                lda temp6
                pha
                lsr
                lsr
                lsr
                lsr
                jsr StoreDigit
                pla
StoreDigit:     and #$0f
                ora #$30
                sta txtDigits,x
                inx
                rts

        ; Recycler menu control

RS_Control:     tay
                stx temp6
                ldx menuMoveDelay
                beq RSC_NoDelay
                bpl RSC_Decrement
RSC_InitialDelay:ldx joystick
                bne RSC_ContinueDelay
                stx menuMoveDelay
RSC_ContinueDelay:
                rts
RSC_Decrement:  dec menuMoveDelay
                rts
RSC_NoDelay:    lda joystick
                lsr
                bcc RSC_NotUp
                dey
                bpl RSC_HasMove
                ldy temp6
RSC_HasMove:    lda #SFX_SELECT
                jsr PlaySfx
                ldx #RECYCLER_MOVEDELAY
                lda joystick
                cmp prevJoy
                bne RSC_NormalDelay
                dex
                dex
                dex
RSC_NormalDelay:stx menuMoveDelay
                sec
                tya
                rts
RSC_NoMove:     clc
                tya
                rts
RSC_NotUp:      lsr
                bcc RSC_NoMove
                iny
                cpy temp6
                bcc RSC_HasMove
                beq RSC_HasMove
                ldy #$00
                beq RSC_HasMove

        ; Hideout door script routine (check that rotordrone is destroyed)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HideoutDoor:    lda #SFX_OBJECT
                jsr PlaySfx
                lda #PLOT_ROTORDRONE
                jsr GetPlotBit
                beq HD_Offline
                ldy lvlObjNum
                jmp ToggleObject
HD_Offline:     lda #<txtHideoutLocked
                ldx #>txtHideoutLocked
                ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText

        ; Rotor drone boss move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveRotorDrone: lda actHp,x
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
                lda #ACTI_FIRSTNPC              ;Use any free actors
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc MRD_NoExplosion
                jsr SpawnActor                  ;Actor type undefined at this point, will be initialized below
                tya
                tax
                jsr ExplodeActor
                ldx actIndex
MRD_NoExplosion:
                rts

        ; Rotor drone boss destroy routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

DestroyRotorDrone:
                lda #-2*8                       ;Give upward speed so that the fall lasts longer
                sta actSY,x
                lda #PLOT_ROTORDRONE
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
                sta txtPercent
                lda #<EP_HACKER2
                sta actScriptEP+2               ;Set 2nd script
                lda #<txtHacker
                ldx #>txtHacker
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
                lda #<txtHacker2
                ldx #>txtHacker2
                bne H_SpeakCommon

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
                lda #<txtHacker3
                ldx #>txtHacker3
                bne H_SpeakCommon

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
                lda #<txtHacker4a
                ldx #>txtHacker4a
                jmp H_SpeakCommon
H4_Ready:       lda #PLOT_LOWERLABSNOAIR        ;If late in the game, the sabotage
                jsr GetPlotBit                  ;must first be dealt with
                bne H4_Unsafe
                ldy #ITEM_OLDTUNNELSPASS
                jsr FindItem
                bcs H4_HasPass
H4_Unsafe:      rts
H4_HasPass:     lda #<EP_HACKERFOLLOW
                sta actScriptEP+2
                lda #>EP_HACKERFOLLOW
                sta actScriptF+2
                lda #<txtHacker4b
                ldx #>txtHacker4b
                jmp H_SpeakCommon

        ; Recycler tables

recyclerCountTbl:
                dc.b 10                         ;Pistol
                dc.b 8                          ;Shotgun
                dc.b 30                         ;Auto rifle
                dc.b 5                          ;Sniper rifle
                dc.b 25                         ;Minigun
                dc.b 30                         ;Flamethrower
                dc.b 15                         ;Laser rifle
                dc.b 10                         ;Plasma gun
                dc.b 1                          ;EMP generator
                dc.b 1                          ;Grenade launcher
                dc.b 1                          ;Bazooka
                dc.b 0                          ;Extinguisher
                dc.b 1                          ;Grenade
                dc.b 1                          ;Mine
                dc.b 1                          ;Medikit
                dc.b 1                          ;Battery
                dc.b 100                        ;Armor

recyclerCostTbl:
                dc.b 10                         ;Pistol
                dc.b 15                         ;Shotgun
                dc.b 20                         ;Auto rifle
                dc.b 20                         ;Sniper rifle
                dc.b 25                         ;Minigun
                dc.b 25                         ;Flamethrower
                dc.b 25                         ;Laser rifle
                dc.b 25                         ;Plasma gun
                dc.b 20                         ;EMP generator
                dc.b 25                         ;Grenade launcher
                dc.b 30                         ;Bazooka
                dc.b 0                          ;Extinguisher
                dc.b 25                         ;Grenade
                dc.b 30                         ;Mine
                dc.b 40                         ;Medikit
                dc.b 40                         ;Battery
                dc.b 50                         ;Armor

        ; Messages

txtRecycler:    dc.b "PART RECYCLING STATION",0
txtExit:        dc.b "EXIT",0
txtCost:        dc.b "COST",0
txtArrow:       dc.b 62,0

txtHideoutLocked:dc.b "LOCKED",0
txtHacker:      dc.b 34,"HEY. YOU MUST BE KIM. THE SCIENTISTS TOLD YOU MIGHT BE COMING. "
                dc.b "I'M JEFF. SORRY ABOUT THAT SENTRY DRONE, HAD TO MAKE SURE YOU'RE NOT A MACHINE. "
                dc.b "I'D ESTIMATE YOUR FIGHTING STYLE AS "
txtPercent:     dc.b "95% HUMAN. YOU CAME FOR THAT SIGNAL AMP FOR THE LASER, RIGHT? "
                dc.b "NEVER TESTED IT SO CAN'T BE SURE WHAT HAPPENS WHEN YOU PLUG IT IN. OH, FEEL FREE TO USE THE RECYCLER "
                dc.b "AT THE BACK. BUT DON'T TOUCH ANYTHING ELSE.",34,0

txtHacker2:     dc.b 34,"IT'S A MESSED UP SITUATION ALL RIGHT. BUT WITH WHAT WE'RE DOING, "
                dc.b "IT WAS BOUND TO HAPPEN SOONER OR LATER.",34,0

txtHacker3:     dc.b 34,"HEY. I APPRECIATE YOU CHECKING ON ME. THIS PLACE IS SECURE SO FAR. BUT I'M SURE THE 'CONSTRUCT' IS AWARE OF IT. "
                dc.b "I'VE PINPOINTED ITS ROUGH LOCATION TO THE FAR SIDE OF THIS "
                dc.b "COMPLEX, UNDER THE BIO-DOME. ANOTHER THING I CAME ACROSS ARE THE SO-CALLED 'OLD TUNNELS' "
                dc.b "WHICH ALSO BRANCH OFF FROM THE LOWER LABS. HAVEN'T SEEN MACHINE TRAFFIC FROM "
                dc.b "THERE AT ALL. COULD BE THEIR BLIND SPOT.",34,0

txtHacker4a:    dc.b 34,"BUT GO AND TAKE CARE OF THOSE SCIENTISTS NOW. THEY'RE NOT EXACTLY SAFE.",34,0

txtHacker4b:    dc.b 34,"YOU'VE GOT THE OLD TUNNELS PASS? I THINK WE SHOULD HEAD THERE IMMEDIATELY.",34,0

                checkscriptend

