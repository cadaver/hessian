MAX_ROUTE_STEPS = 10

AIH_AUTOTURNWALL = $01
AIH_AUTOSTOPLEDGE = $20
AIH_AUTOTURNLEDGE = $40
AIH_AUTOJUMPLEDGE = $80

JOY_FREEMOVE    = $80

AIMODE_IDLE     = 0
AIMODE_TURNTO   = 1
AIMODE_FOLLOW   = 2
AIMODE_SNIPER   = 3

NOTARGET        = $ff

BI_GROUND       = 1
BI_OBSTACLE     = 2
BI_CLIMB        = 4
BI_STAIRSLEFT   = 8
BI_STAIRSRIGHT  = 9

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
                sta actMoveCtrl,x
                rts

        ; Turn to player AI

AI_TurnTo:      ldy #ACTI_PLAYER
                jsr GetActorDistance
                lda temp5
                sta actD,x
                rts

        ; Follow (pathfinding) AI

AI_Follow:      rts

        ; Sniper AI

AI_Sniper:      jsr FindTarget                  ;Todo: add proper aggression/defense code. Now is just a test
                ldy actAITarget,x               ;for attack hints
                bmi AI_Idle
                lda actAIAttackHint,x
                bmi AI_FreeMove
                sta actCtrl,x
                cmp #JOY_FIRE
                bcc AI_NoFire
                lda #$00
AI_NoFire:      sta actMoveCtrl,x
                lda #AIH_AUTOSTOPLEDGE
                bne AI_StoreMovementHelp

AI_FreeMove:    lda #JOY_RIGHT                  ;Move forward into facing direction, turn at walls / ledges
                ldy actD,x
                bpl AI_FreeMoveRight
                lda #JOY_LEFT
AI_FreeMoveRight:
                sta actMoveCtrl,x
                lda #$00
                sta actCtrl,x
                lda #AIH_AUTOTURNLEDGE|AIH_AUTOTURNWALL
AI_StoreMovementHelp:
                sta actAIHelp,x
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
                lda #$00                        ;For NPCs, reset navigation information now until checked
                sta actAIMoveHint,x
                sta actAIAttackHint,x
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
                ldy temp2                       ;Take initial maprow
                lda mapTblLo,y
                sta zpDestLo
                lda mapTblHi,y
                sta zpDestHi
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
                lda mapTblLo,y                  ;Take new maprow
                sta zpDestLo
                lda mapTblHi,y
                sta zpDestHi
RC_MoveYDone2:  dec temp3
                beq RC_NoRoute
                ldy temp1
                lda (zpDestLo),y                ;Take block from map
                lsr
                tay
                lda blockInfo,y
                bcs RC_UpperNybble              ;Blockinfo is packed into 4 bits per block
RC_LowerNybble: and #$0f
                bcc RC_CheckBlockInfo
RC_UpperNybble: lsr
                lsr
                lsr
                lsr
RC_CheckBlockInfo:
                and #BI_OBSTACLE
                beq RC_Loop
RC_NoRoute:     clc                             ;Route not found
                rts

        ; Update navigation & attack hints for AI
        ;
        ; Parameters: X actor index, C=1 route OK, C=0 route fail
        ; Returns: -
        ; Modifies: A,Y,temp regs

CNH_NoRoute:    lda #$00
                sta actAIMoveHint,x
                sta actAIAttackHint,x
                rts
CheckNavigationHints:
                bcc CNH_NoRoute
CNH_HasRoute:   ldy actAITarget,x               ;Check whether attack can be horizontal, vertical or diagonal
                jsr GetActorDistance
                jsr GetActorCharCoords          ;If is on the screen edge, do not fire, but come closer
                dey
                cpy #SCROLLROWS+4               ;(game can be too difficult otherwise)
                bcs CNH_NeedLessDistance
                cmp #39
                bcs CNH_NeedLessDistance
                ldy actWpn,x
                lda temp8
                beq CNH_Horizontal
                lda temp6
                beq CNH_Vertical
                cmp temp8
                beq CNH_Diagonal
CNH_NoAttackDir:bcc CNH_GoVertical              ;Diagonal, but not completely: need to move either closer or away
CNH_NeedLessDistance:
                lda temp5
                bmi CNH_NLDLeft
CNH_NLDRight:   lda #JOY_RIGHT
                bne CNH_StoreAttackHint
CNH_NLDLeft:    lda #JOY_LEFT
                bne CNH_StoreAttackHint
CNH_GoVertical: asl                             ;If is closer to a fully vertical angle, reduce distance instead
                cmp temp8
                bcc CNH_NeedLessDistance
CNH_NoAttackHint:
                lda #$00                        ;Otherwise, it is not wise to go away from target, as target may
                beq CNH_StoreAttackHint         ;be moving under a platform, where the routecheck is broken
CNH_NeedMoreDistance:
                lda temp6                       ;If target is at same block (possibly using a melee weapon)
                ora temp8                       ;break away into whatever direction available
                bne CNH_NotAtSameBlock
                lda #JOY_FREEMOVE
                bne CNH_StoreAttackHint
CNH_NotAtSameBlock:
                lda temp5
                bmi CNH_NLDRight
                bpl CNH_NLDLeft
CNH_Diagonal:
CNH_Horizontal: lda temp6                       ;Verify horizontal distance too close / too far
                cmp itemNPCMinDist-1,y
                bcc CNH_NeedMoreDistance
                cmp itemNPCMaxDist-1,y
                bcs CNH_NeedLessDistance
                lda #JOY_RIGHT|JOY_FIRE
                ldy temp5
                bpl CNH_AttackRight
                lda #JOY_LEFT|JOY_FIRE
CNH_AttackRight:ldy temp8                       ;If block-distance is zero, do not fire diagonally
                beq CNH_StoreAttackHint
CNH_AttackAboveOrBelow:
                ldy temp7
                beq CNH_StoreAttackHint
                bpl CNH_AttackBelow
CNH_AttackAbove:ora #JOY_UP|JOY_FIRE
                bne CNH_StoreAttackHint
CNH_AttackBelow:ora #JOY_DOWN|JOY_FIRE
                bne CNH_StoreAttackHint
CNH_Vertical:   lda temp8                       ;For vertical distance, only check if too far
                cmp itemNPCMaxDist-1,y
                lda #$00                        ;If so, currently there is no navigation hint
                bcc CNH_AttackAboveOrBelow
CNH_StoreAttackHint:
                sta actAIAttackHint,x
                rts