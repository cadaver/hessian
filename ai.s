MAX_ROUTE_STEPS = 10

AIH_AUTOTURNWALL = $01
AIH_AUTOSTOPLEDGE = $20
AIH_AUTOTURNLEDGE = $40
AIH_AUTOJUMPLEDGE = $80

AIMODE_IDLE     = 0
AIMODE_TURNTO   = 1
AIMODE_FOLLOW   = 2

NOTARGET        = $ff

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

AI_Follow:      jsr FindTarget                  ;Todo: do not call this, only for testing
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
FT_CheckRoute:  cpx #ACTI_LASTNPC+1             ;If this is a homing bullet, there will be no navigation/route
                bcs FT_CheckRoute2              ;check later, so check now
                lda #$ff                        ;For NPCs, reset navigation information now until checked
                sta actAIMoveHint,x
                tya
                bcc FT_StoreTarget
FT_CheckRoute2: tya
                pha
                jsr RouteCheck
                pla
                bcs FT_StoreTarget
                rts

        ; Check if there is obstacles between actors
        ;
        ; Parameters: X actor index, Y target actor index
        ; Returns: C=1 route OK, C=0 route fail
        ; Modifies: A,Y,temp1-temp3, loader temp variables

RouteCheck:     lda actXH,x
                sta temp1
                lda actYL,x                     ;Check 1 block higher if low Y-pos < $80
                asl
                lda actYH,x
                sbc #$00
                sta temp2
                lda actXH,y
                sta RC_CmpX+1
                lda actYL,y                     ;Check 1 block higher if low Y-pos < $80
                asl
                lda actYH,y
                sbc #$00
                sta RC_CmpY+1
                sta RC_CmpY2+1
                lda #MAX_ROUTE_STEPS
                sta temp3
RC_Loop:        ldy temp1
RC_CmpX:        cpy #$00
                bcc RC_MoveRight
                bne RC_MoveLeft
                ldy temp2
RC_CmpY:        cpy #$00
                bcc RC_MoveDown
                bne RC_MoveUp
                rts                             ;C=1, route found
RC_MoveRight:   iny
                bcc RC_MoveXDone
RC_MoveLeft:    dey
RC_MoveXDone:   sty temp1
                ldy temp2
RC_CmpY2:       cpy #$00
                bcc RC_MoveDown
                beq RC_MoveYDone2
RC_MoveUp:      dey
                bcs RC_MoveYDone
RC_MoveDown:    iny
RC_MoveYDone:   sty temp2
RC_MoveYDone2:  dec temp3
                beq RC_NoRoute
                lda mapTblLo,y
                sta zpDestLo
                lda mapTblHi,y
                sta zpDestHi
                ldy temp1
                lda (zpDestLo),y                ;Take block from map
                tay
                lda blkTblLo,y
                sta zpDestLo
                lda blkTblHi,y
                sta zpDestHi
                ldy #2*4+2
                lda (zpDestLo),y                ;Get char from block (middle)
                tay
                lda charInfo,y                  ;Get charinfo
                and #CI_OBSTACLE
                beq RC_Loop
RC_NoRoute:     clc                             ;Route not found
                rts

        ; Update navigation & attack hints for AI
        ;
        ; Parameters: X actor index, C=1 route OK, C=0 route fail
        ; Returns: -
        ; Modifies: A,Y,temp regs

CheckNavigationHints:
                bcc CNH_NoRoute
CNH_HasRoute:   inc $d020
                rts
CNH_NoRoute:    lda #$ff
                sta actAIMoveHint,x
                rts
