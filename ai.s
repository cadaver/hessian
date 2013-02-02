MAX_ROUTE_STEPS = 8

AIH_AUTOTURNWALL = $01
AIH_AUTOTURNLEDGE = $02
AIH_AUTOJUMPLEDGE = $04

AIMODE_NONE     = 0
AIMODE_SNIPER   = 1

NOTARGET        = $80

        ; AI character update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveAIHuman:    lda actCtrl,x
                sta actPrevCtrl,x
                txa                             ;Skip even and odd actors on consecutive
                eor DA_ItemFlashCounter+1       ;frames
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
                inc actTime,x
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
                bmi AI_ContinueAttack
                jsr FindTarget
                ldy actAITarget,x
                bmi AI_GoIdle
                jsr GetActorDistance
                lda temp5                       ;Always face the target when in line of sight
                sta actD,x
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
                bcc AI_NoAttack
                cmp itemNPCMaxDist-1,y
                bcs AI_NoAttack
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
AI_Vertical:    ldy actWpn,x
                lda wpnTblLo-1,y
                sta wpnLo
                lda wpnTblHi-1,y
                sta wpnHi
                lda temp7
                bpl AI_VerticalDown
AI_VerticalUp:  ldy #WD_MINAIM                  ;Check that weapon can actually be fired up
                lda (wpnLo),y
                cmp #AIM_UP
                bne AI_NoAttack2
                lda #JOY_FIRE+JOY_UP
                bne AI_AttackDirOK
AI_VerticalDown:ldy #WD_MAXAIM                  ;Check that weapon can actually be fired down
                lda (wpnLo),y
                cmp #AIM_DOWN
                bne AI_NoAttack2
                lda #JOY_FIRE+JOY_DOWN
                bne AI_AttackDirOK
AI_Horizontal:  lda #JOY_FIRE+JOY_RIGHT
                ldy temp5
                bpl AI_AttackDirOK
                lda #JOY_FIRE+JOY_LEFT
AI_AttackDirOK: sta temp4
                ldy actAITarget,x               ;Check line of sight before actually firing
                jsr RouteCheck
                bcc AI_AttackNoRoute
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

        ; Validate existing AI target / find new target
        ;
        ; Parameters: X actor index
        ; Returns: actAITarget set to new value if necessary
        ; Modifies: A,Y,temp regs

FindTarget:     ldy actAITarget,x
                bmi FT_PickNew
                lda actT,y
                beq FT_Invalidate
                lda actHp,y
                beq FT_Invalidate
FT_TargetOK:    rts
FT_Invalidate:  lda #NOTARGET
FT_StoreTarget: sta actAITarget,x
FT_NoTarget:    rts
FT_PickNew:     lda actFlags,x
                bpl FT_PickVillain
FT_PickHero:    ldy numHeroes
                beq FT_NoTarget
                jsr Random
                and targetListAndTbl-1,y
                cmp numHeroes
                bcc FT_PickHeroOK
                sbc numHeroes
FT_PickHeroOK:  tay
                lda heroList,y
                bpl FT_TargetCommon
FT_PickVillain: ldy numVillains
                beq FT_NoTarget
                jsr Random
                and targetListAndTbl-1,y
                cmp numVillains
                bcc FT_PickVillainOK
                sbc numVillains
FT_PickVillainOK:
                tay
                lda villainList,y
FT_TargetCommon:tay
FT_CheckRoute:  sty tgtActIndex
                jsr RouteCheck
                bcc FT_NoTarget
                lda tgtActIndex
                bcs FT_StoreTarget
