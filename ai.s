MAX_ROUTE_STEPS = 8

AIH_AUTOTURNWALL = $01
AIH_AUTOTURNLEDGE = $02
AIH_AUTOJUMPLEDGE = $04

AIMODE_NONE     = 0
AIMODE_SNIPER   = 1

ROUTE_NOTCHECKED = $00
ROUTE_FAIL      = $01
ROUTE_OK        = $80

NOTARGET        = $ff

ATTACK_LEFT_CHARLIMIT = $01
ATTACK_RIGHT_CHARLIMIT = $26

        ; AI character update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveAIHuman:    lda actCtrl,x
                sta actPrevCtrl,x
                txa                             ;Skip even and odd actors on consecutive
                eor CheckRoute+1                ;frames
                lsr
                bcs MA_SkipAI
                ldy actAIMode,x
                beq MA_SkipAI
                lda aiJumpTblLo-1,y
                sta MA_AIJump+1
                lda aiJumpTblHi-1,y
                sta MA_AIJump+2
MA_AIJump:      jsr $0000
MA_SkipAI:      jsr MoveHuman
                jmp AttackHuman

AI_ContinueAttack:
                dec actTime,x
                rts
AI_GoIdle:      jsr Random
                ldy #AL_DEFENSE                 ;When no target or no route, randomly rise from duck
                cmp (actLo),y
                bcs AI_NoAttack
                lda #$00
                sta actMoveCtrl,x
AI_NoAttack:    lda #$00
                sta actCtrl,x
                rts

AI_Sniper:      lda actTime,x                   ;Attack time left?
                bne AI_ContinueAttack
                jsr ValidateTarget
                tya
                bmi AI_GoIdle
                lda actAIRoute,x
                bpl AI_NoAttack
                jsr GetActorDistance
                lda temp5                       ;Always face the target when in line of sight
                sta actD,x
                lda temp6                       ;Get absolute distance to target,
                cmp temp8                       ;whichever (X/Y) is greater
                bcs AI_XGreater
                lda temp8
AI_XGreater:    ldy actWpn,x                    ;Check that weapon is effective
                beq AI_NoAttack
                cmp itemNPCMinDist-1,y
                bcc AI_NoAttack
                cmp itemNPCMaxDist-1,y
                bcs AI_NoAttack
                lda actAttackD,x
                bne AI_NoAttack
                jsr Random                      ;Get random number for offense/defense logic
                ldy #AL_DEFENSE
                cmp (actLo),y
                bcs AI_NoDuckingCheck
                sta temp1
                lda temp8                       ;If on the same level as target, possibly duck
                bne AI_ShouldNotDuck
                ldy actAITarget,x
                lda actF1,y                     ;If target is ducking or rolling, definitely duck
                cmp #FR_DUCK+1                  ;If not, 50% chance to stand instead
                beq AI_ShouldDuck
                cmp #FR_ROLL
                bcs AI_ShouldDuck
                lda temp1
                lsr
                bcs AI_ShouldDuck
AI_ShouldNotDuck:
                lda #$00
                beq AI_DuckingCheckDone
AI_ShouldDuck:  jsr GetCharInfo                 ;However do not climb down unintentionally
                and #CI_CLIMB
                bne AI_ShouldNotDuck
                lda #JOY_DOWN
AI_DuckingCheckDone:
                sta actMoveCtrl,x
                jmp AI_NoAttack                 ;Do not attack on same frame when ducking changed
AI_NoDuckingCheck:
                ldy #AL_OFFENSE                 ;Check attack probability
                cmp (actLo),y
                bcs AI_NoAttack
                jsr GetActorCharCoordX          ;To not be unfair, require the enemy be on screen before firing
                cmp #ATTACK_LEFT_CHARLIMIT
                bcc AI_NoAttack2
                cmp #ATTACK_RIGHT_CHARLIMIT+1
                bcs AI_NoAttack2
                lda temp8                       ;Check whether to attack horizontally, vertically or diagonally
                beq AI_Horizontal
                lda actWpn,x                    ;Grenade is a special case which does not require exact diagonal distance
                cmp #WPN_GRENADE
                bne AI_NoGrenade
AI_Grenade:     lda temp6                       ;No vertical attack with grenade
                beq AI_NoAttack2
                bne AI_Diagonal
AI_NoGrenade:   lda temp6
                beq AI_Vertical
                cmp temp8
                bne AI_NoAttack2
AI_Diagonal:    lda temp5
                bmi AI_DiagonalLeft
AI_DiagonalRight:
                lda #JOY_FIRE+JOY_RIGHT+JOY_DOWN
                ldy temp7
                bpl AI_AttackDirOK
                lda #JOY_FIRE+JOY_RIGHT+JOY_UP
                bne AI_AttackDirOK
AI_DiagonalLeft:lda #JOY_FIRE+JOY_LEFT+JOY_DOWN
                ldy temp7
                bpl AI_AttackDirOK
                lda #JOY_FIRE+JOY_LEFT+JOY_UP
                bne AI_AttackDirOK
AI_NoAttack2:   jmp AI_NoAttack
AI_Vertical:    lda #JOY_FIRE+JOY_DOWN
                ldy temp7
                bpl AI_AttackDirOK
                lda #JOY_FIRE+JOY_UP
                bne AI_AttackDirOK
AI_Horizontal:  lda #JOY_FIRE+JOY_RIGHT
                ldy temp5
                bpl AI_AttackDirOK
                lda #JOY_FIRE+JOY_LEFT
AI_AttackDirOK: sta actCtrl,x
                ldy actWpn,x
                lda itemNPCAttackLength-1,y
                sta actTime,x
                rts

        ; Verify that target is valid, and/or pick next target
        ;
        ; Parameters: X actor index
        ; Returns: Y target, or $ff if none
        ; Modifies: A,Y

ValidateTarget: ldy actAITarget,x
                bmi VT_PickNew
                lda actT,y
                beq VT_Invalidate
                lda actHp,y
                beq VT_Invalidate
VT_TargetOK:    rts
VT_PickNew:     ldy #<heroList
                lda actGrp,x
                bmi VT_BeginPick
                ldy #<villainList
VT_BeginPick:   sty VT_PickLoop+1
                ldy #$00
VT_PickLoop:    lda heroList,y
                bmi VT_Invalidate
                bpl VT_NewTargetFound           ;TODO: now always picks first target, randomize
                iny
                bpl VT_PickLoop
VT_Invalidate:  lda #NOTARGET
VT_NewTargetFound:
                sta actAITarget,x
                tay
                lda #ROUTE_NOTCHECKED           ;Reset routecheck for new target
                sta actAIRoute,x
                rts
