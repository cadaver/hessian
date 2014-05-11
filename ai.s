MAX_ROUTE_STEPS = 8

AIH_AUTOTURNWALL = $01
AIH_AUTOTURNLEDGE = $02
AIH_AUTOJUMPLEDGE = $04

AIMODE_NONE     = 0
AIMODE_SNIPER   = 1
AIMODE_THUG     = 2

NOTARGET        = $80

        ; AI character update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveAIHuman:    lda actCtrl,x
                sta actPrevCtrl,x
                txa                             ;Skip even and odd actors on consecutive
                eor UA_ItemFlashCounter+1       ;frames
                lsr
                bcs MA_SkipAI
                ldy actAIMode,x
                lda aiJumpTblLo,y
                sta MA_AIJump+1
                lda aiJumpTblHi,y
                sta MA_AIJump+2
MA_AIJump:      jsr $0000
MA_SkipAI:      jsr MoveHuman
                jmp AttackHuman

        ; Turn to AI
        
AI_TurnTo:      ldy #ACTI_PLAYER
                jsr GetActorDistance
                lda temp5
                sta actD,x
                rts

AI_ContinueAttack:
                inc actTime,x
                rts
AI_GoIdle:      jsr Random
                ldy #AL_DEFENSE                 ;When no target or no route, randomly rise from duck
                cmp (actLo),y
                bcs AI_NoAttack
                lda #$00
                sta actMoveCtrl,x

        ; Idle AI

AI_Idle:
AI_NoAttack:    lda #$00
                sta actCtrl,x
                rts

        ; Sniper AI

AI_Sniper:      lda actTime,x                   ;Attack time left?
                bmi AI_ContinueAttack
                jsr FindTarget
                ldy actAITarget,x
                bmi AI_GoIdle
                jsr GetActorDistance
AI_AttackCommon:lda temp5                       ;Always face target (TODO: should check previous routecheck
                sta actD,x                      ;and not do that if no line of sight)
                jsr Random                      ;Get random number for offense/defense logic
                ldy #AL_DEFENSE
                cmp (actLo),y
                bcs AI_NoDuckingCheck
                sta temp1
                ldy actWpn,x
                lda itemNPCMaxDist-1,y          ;If beyond attack distance, do not duck
                cmp temp6
                bcc AI_ShouldNotDuck
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
                lda actMoveCtrl,x
                and #$ff-JOY_DOWN
                jmp AI_DuckingCheckDone
AI_ShouldDuck:  jsr GetCharInfo                 ;However do not climb down unintentionally
                and #CI_CLIMB
                bne AI_ShouldNotDuck
                lda #JOY_DOWN
AI_DuckingCheckDone:
                sta actMoveCtrl,x
                jmp AI_NoAttack                 ;Do not attack on same frame when ducking changed
AI_NoDuckingCheck:
                ldy #AL_OFFENSE                 ;Accumulate aggression
                and (actLo),y
                clc
                adc actTime,x
                bpl AI_AggressionOK
                lda #$7f
AI_AggressionOK:sta actTime,x
                ldy actWpn,x                    ;Check for enough aggression for weapon in question
                cmp itemNPCAttackThreshold-1,y
                bcc AI_NoAttack
                lda temp6                       ;Get absolute distance to target,
                cmp temp8                       ;whichever (X/Y) is greater
                bcs AI_XGreater
                lda temp8
AI_XGreater:    cmp itemNPCMinDist-1,y          ;Check that weapon is effective
                bcc AI_NoAttack2
                cmp itemNPCMaxDist-1,y
                bcs AI_NoAttack2
                lda actAttackD,x
                bne AI_NoAttack2
                lda temp8                       ;Check whether to attack horizontally, vertically or diagonally
                beq AI_Horizontal
                lda temp6
                beq AI_Vertical
                clc                             ;For diagonal attacks, allow 1 block of error
                adc #$02
                sbc temp8                       ;C=0, subtract one more
                cmp #$03
                bcs AI_NoAttack2
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
AI_Vertical:    lda temp7
                bpl AI_VerticalDown
AI_VerticalUp:  lda #JOY_FIRE+JOY_UP
                bne AI_AttackDirOK
AI_VerticalDown:lda #JOY_FIRE+JOY_DOWN
                bne AI_AttackDirOK
AI_Horizontal:  lda #JOY_FIRE+JOY_RIGHT
                ldy temp5
                bpl AI_AttackDirOK
                lda #JOY_FIRE+JOY_LEFT
AI_AttackDirOK: sta temp4
                ldy actAITarget,x               ;Check line of sight before actually firing
                jsr RouteCheck
                bcc AI_AttackNoRoute
                lda temp5                       ;Always face target when attacking
                sta actD,x
                lda temp4
                sta actCtrl,x
                ldy actWpn,x
                lda itemNPCAttackLength-1,y
AI_AttackSetTime:
                sta actTime,x
                rts
AI_AttackNoRoute:
                lda #$00                        ;Clear aggression to avoid making repeated
                beq AI_AttackSetTime            ;routechecks

        ; Thug AI. Possibly not final

AI_ThugContinueAttack:
                jmp AI_ContinueAttack
AI_ThugIdle:    lda actD,x
                jsr AI_SetLeftRightCtrl         ;Just continue forward
                lda #AIH_AUTOTURNWALL|AIH_AUTOTURNLEDGE
                sta actAIHelp,x
                lda #$00
                sta actCtrl,x                   ;Clear attack controls
                rts
AI_Thug:        lda actTime,x
                bmi AI_ThugContinueAttack
                jsr FindTarget
                ldy actAITarget,x
                bmi AI_ThugIdle
                jsr GetActorDistance
                lda temp8                       ;If target far above/below, perform idle logic
                cmp #2
                bcs AI_ThugIdle
                ldy actWpn,x
                lda temp6
                cmp itemNPCMaxDist-1,y
                bcs AI_ThugMoveCloserUnconditional
                cmp itemNPCMinDist-1,y
                bcc AI_ThugIdle
                bne AI_ThugMoveCloser
AI_ThugStop:    lda actMoveCtrl,x
                and #JOY_DOWN
                bne AI_ThugAttack               ;If already ducking, do not move
                jsr AI_SetStopCtrl
                beq AI_ThugAttack
AI_ThugMoveCloser:
                lda actMoveCtrl,x
                and #JOY_DOWN
                bne AI_ThugAttack               ;If already ducking, do not move
AI_ThugMoveCloserUnconditional:
                lda temp5
                jsr AI_SetLeftRightCtrl
AI_ThugAttack:  lda temp5                       ;Always face target (TODO: should check previous routecheck
                sta actD,x                      ;and not do that if no line of sight)
                jmp AI_AttackCommon             ;Jump to sniper common code for attack

AI_SetLeftRightCtrl:
                tay
                bmi AI_SetLeftCtrl
                lda #JOY_RIGHT
                bne AI_SetMoveCtrl
AI_SetLeftCtrl: lda #JOY_LEFT
                bne AI_SetMoveCtrl
AI_SetStopCtrl: lda #$00
AI_SetMoveCtrl: sta actMoveCtrl,x
                rts

        ; Validate existing AI target / find new target
        ;
        ; Parameters: X actor index
        ; Returns: actAITarget set to new value if necessary
        ; Modifies: A,Y,temp regs

FindTarget:     ldy actAITarget,x
                bmi FT_PickNew
                lda actHp,y                     ;When actor is removed (actT = 0) also health is zeroed
                beq FT_Invalidate               ;so only checking for health is enough
FT_TargetOK:    rts
FT_Invalidate:  lda #NOTARGET
FT_StoreTarget: sta actAITarget,x
FT_NoTarget:    rts
FT_PickNew:     ldy numTargets
                beq FT_NoTarget
                jsr Random
                and targetListAndTbl-1,y
                cmp numTargets
                bcc FT_PickTargetOK
                sbc numTargets
FT_PickTargetOK:tay
                lda targetList,y
                tay
                lda actFlags,x                  ;Must not be in same group
                eor actFlags,y
                and #AF_GROUPBITS
                beq FT_NoTarget
FT_CheckRoute:  sty tgtActIndex
                jsr RouteCheck
                bcc FT_NoTarget
                lda tgtActIndex
                bcs FT_StoreTarget
