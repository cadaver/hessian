MAX_ROUTE_STEPS = 8

AIH_AUTOTURNWALL = $01
AIH_AUTOSTOPLEDGE = $20
AIH_AUTOTURNLEDGE = $40
AIH_AUTOJUMPLEDGE = $80

AIMODE_IDLE     = 0
AIMODE_TURNTO   = 1
AIMODE_FOLLOW   = 2

NOTARGET        = $80

        ; AI character update routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveAIHuman:    lda actCtrl,x
                sta actPrevCtrl,x
                ldy actAIMode,x
                lda aiJumpTblLo,y
                sta MA_AIJump+1
                lda aiJumpTblHi,y
                sta MA_AIJump+2
MA_AIJump:      jsr $0000
MA_SkipAI:      jsr MoveHuman
                jmp AttackHuman

        ; Idle AI

AI_Idle:        lda #$00
                sta actCtrl,x
                rts

        ; Turn to player AI

AI_TurnTo:      ldy #ACTI_PLAYER
                jsr GetActorDistance
                lda temp5
                sta actD,x
                rts

        ; Follow (pathfinding) AI
        
AI_Follow:      ldy #ACTI_PLAYER                ;Todo: use the actual target
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
