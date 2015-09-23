MAX_LINE_STEPS      = 10

MAX_NAVIGATION_STEPS = 8

AIH_AUTOTURNWALL    = $20
AIH_AUTOTURNLEDGE   = $40
AIH_AUTOSTOPLEDGE   = $80

JOY_CLIMBSTAIRS     = $40
JOY_FREEMOVE        = $80

AIMODE_IDLE         = 0
AIMODE_TURNTO       = 1
AIMODE_FOLLOW       = 2
AIMODE_SNIPER       = 3
AIMODE_NOTPERSISTENT = $80

NOTARGET            = $ff

LINE_NOTCHECKED     = $00
LINE_NO             = $40
LINE_YES            = $80

DIR_UP              = $00
DIR_DOWN            = $01
DIR_LEFT            = $02
DIR_RIGHT           = $03
DIR_NONE            = $ff

HORIZMODE_MAX_YDIST = 2
NAV_HORIZ           = 0
NAV_VERT            = 1

LADDER_DELAY        = $40

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
MA_SkipAI:      jmp MoveAndAttackHuman

        ; Follow (pathfinding) AI

AI_FollowClimbNewDir:
                lda temp6
                ora temp8
                beq AI_FollowClimbDirDone
                lda #JOY_UP
                ldy temp7
                bmi AI_FollowClimbDirDone
                lda #JOY_DOWN
AI_FollowClimbDirDone:
                jmp AI_StoreMoveCtrl

AI_FollowClimbCheckExit:
                lda temp8                       ;If target is level, always exit
                beq AI_FollowClimbDoExit
                lda actMoveCtrl,x
                and #JOY_UP
                bne AI_FollowClimbCheckExitAbove
AI_FollowClimbCheckExitBelow:
                lda temp4                       ;If trying to climb down, but ladder doesn't continue, exit
                and #CI_CLIMB
                beq AI_FollowClimbDoExit
AI_FollowClimbNoExit:
                rts
AI_FollowClimbCheckExitAbove:
                jsr GetCharInfo4Above           ;If trying to climb up, but ladder doesn't continue, exit
                and #CI_CLIMB
                bne AI_FollowClimbNoExit
AI_FollowClimbDoExit:
                lda temp5                       ;Turn to target after climbing
                sta actD,x
                jmp AI_FreeMove

AI_FollowClimb: lda #LADDER_DELAY
                sta actLastNavLadder,x
                lda temp6                       ;Get new dir if X-distance zero (on the same ladder)
                beq AI_FollowClimbNewDir        ;or currently not moving
                lda actMoveCtrl,x
                beq AI_FollowClimbNewDir        ;Otherwise remove the left/right controls
                and #JOY_UP|JOY_DOWN            ;and continue previous up/down direction
                sta actMoveCtrl,x
                lda temp4
                and #CI_GROUND                  ;Can exit?
                bne AI_FollowClimbCheckExit
                rts

AI_Follow:      lda #ACTI_PLAYER                ;Todo: do not hardcode player as target
                sta actAITarget,x
                ldy actAITarget,x
                jsr GetActorDistance
                lda actF1,y
                cmp #FR_JUMP
                bcc AI_FollowTargetNoJump
                cmp #FR_DUCK
                bcs AI_FollowTargetNoJump
                ldy temp7                       ;If target is jumping and Y-distance is small & upward
                iny                             ;($ff, here check for increasing to $00) just disregard it
                bne AI_FollowTargetNoJump
                lda #$00
                sta temp7
                sta temp8
AI_FollowTargetNoJump:
                jsr GetCharInfo                 ;Get charinfo at feet for decisions
                sta temp4
                lda actF1,x                     ;Todo: must check for frame range once AI's can e.g. roll
                cmp #FR_CLIMB
                bcs AI_FollowClimb
                lda actLine,x
                bmi AI_FollowHasLOS             ;Check line of sight first
                jmp AI_FreeMoveWithTurn         ;If none, walk forward & turn to appear to be doing something
AI_FollowHasLOS:lda #AIH_AUTOTURNLEDGE|AIH_AUTOTURNWALL
                sta actAIHelp,x
                lda #JOY_UP                     ;Prevent jumping
                sta actPrevCtrl,x
                lda temp4                       ;Dedicated turning logic on stairs
                cmp #CI_GROUND+$80
                beq AI_FollowOnStairs
                lda actLastNavStairs,x          ;Check if came to level ground from stairs
                bpl AI_FollowNoStairExit
                lda #$00
                sta actLastNavStairs,x
                lda temp8                       ;In that case turn to target if below (switch dir at junction)
                bmi AI_FollowWalk
                bpl AI_FollowTurnToTarget
AI_FollowNoStairExit:
                lda temp8                       ;Turn to target if at same level
                bne AI_FollowWalk
AI_FollowTurnToTarget:
                lda temp5
AI_FollowChangeDir:
                sta actD,x
                lda #AIH_AUTOSTOPLEDGE
                sta actAIHelp,x
AI_FollowWalk:  lsr actLastNavLadder,x
                lda temp6                       ;If no X & Y distance, idle
                ora temp8
                beq AI_Idle
                lda temp4                       ;Check climbing down
                and #CI_CLIMB
                beq AI_FollowNoClimbDown
                lda actLastNavLadder,x          ;Do not climb if delay count from last climb still active
                bne AI_FollowNoClimbDown
                lda temp7
                bmi AI_FollowNoClimbDown
                beq AI_FollowNoClimbDown
                ldy #AL_MOVEFLAGS
                lda (actLo),y
                and #AMF_CLIMB                  ;Can climb?
                beq AI_FollowNoClimbDown
                lda #JOY_DOWN
                bne AI_FollowNoWalkUp
AI_FollowNoClimbDown:
                lda #JOY_RIGHT
                ldy actD,x
                bpl AI_FollowWalkRight
                lda #JOY_LEFT
AI_FollowWalkRight:
                ldy temp7                       ;Need to go up?
                bpl AI_FollowNoWalkUp
                ldy actLastNavLadder,x          ;Do not climb if delay count from last climb still active
                bne AI_FollowNoWalkUp           ;(Todo: should still walk up stairs)
                ora #JOY_UP
AI_FollowNoWalkUp:
                jmp AI_StoreMoveCtrl

AI_FollowOnStairs:
                ldy actLastNavStairs,x          ;Turn once in each flight of stairs
                bmi AI_FollowWalk
                sta actLastNavStairs,x
                lda temp7
                bpl AI_FollowStairTurnOK
                lda actYL,x                     ;Only turn at the bottom when going up
                bpl AI_FollowWalk               ;to prevent bugs when e.g. player has gone higher to a ladder
AI_FollowStairTurnOK:
                lda actXL,x                     ;Find out stairs direction and turn if necessary
                eor actYL,x                    
                and #$c0
                beq AI_StairsDownRight
AI_StairsDownLeft:
                lda temp7
                bpl AI_StairsTurnLeft
AI_StairsTurnRight:
                lda #$00
                beq AI_FollowChangeDir
AI_StairsTurnLeft:
                lda #$80
                bne AI_FollowChangeDir
AI_StairsDownRight:
                lda temp7
                bpl AI_StairsTurnRight
                bmi AI_StairsTurnLeft

        ; Turn to AI

AI_TurnTo:      ldy actAITarget,x
                bmi AI_Idle
                jsr GetActorDistance
AI_TurnToTarget:lda temp5
                sta actD,x                      ;Fall through

        ; Idle AI

AI_Idle:        lda #$00
                jmp AI_StoreMoveCtrl

        ; Sniper AI

AI_Sniper:      jsr FindTarget                  ;Todo: add proper aggression/defense code. Now is just a test
                ldy actAITarget,x               ;for attack direction finding
                bmi AI_Idle
                lda actLine,x                   ;If line-of-sight blocked, try to get new target
                bmi AI_HasLineOfSight
                beq AI_Idle
                jsr FT_PickNew
                jmp AI_Idle
AI_HasLineOfSight:
                jsr GetAttackDir
                bmi AI_FreeMoveWithTurn
                sta actCtrl,x
                cmp #JOY_FIRE
                bcc AI_NoFire
                lda #$00
AI_NoFire:      sta actMoveCtrl,x
                lda #AIH_AUTOSTOPLEDGE
                sta actAIHelp,x
                rts

AI_FreeMoveWithTurn:
                lda #AIH_AUTOTURNLEDGE|AIH_AUTOTURNWALL
                sta actAIHelp,x
AI_FreeMove:    lda #JOY_RIGHT                  ;Move forward into facing direction, turn at walls / ledges
                ldy actD,x
                bpl AI_FreeMoveRight
                lda #JOY_LEFT
AI_FreeMoveRight:
AI_StoreMoveCtrl:
                sta actMoveCtrl,x
                lda #$00
                sta actCtrl,x
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
                lda #LINE_NOTCHECKED            ;Reset line-of-sight information now until checked
                beq LC_StoreLine

        ; Check if there is obstacles between actors (coarse line-of-sight)
        ;
        ; Parameters: X actor index, Y target actor index
        ; Returns: actLine modified
        ; Modifies: A,Y,temp1-temp3, loader temp variables

LineCheck:      lda actXH,x
                sta temp1
                lda actYL,x                     ;Check 1 block higher if low Y-pos < $80
                asl
                lda actYH,x
                sbc #$00
                sta temp2
                lda actXH,y
                sta LC_CmpX+1
                lda actYL,y                     ;Check 1 block higher if low Y-pos < $80
                asl
                lda actYH,y
                sbc #$00
                sta LC_CmpY+1
                sta LC_CmpY2+1
                lda #MAX_LINE_STEPS
                sta temp3
                ldy temp2                       ;Take initial maprow
                lda mapTblLo,y
                sta zpSrcLo
                lda mapTblHi,y
                sta zpSrcHi
LC_Loop:        ldy temp1
LC_CmpX:        cpy #$00
                bcc LC_MoveRight
                bne LC_MoveLeft
                ldy temp2
LC_CmpY:        cpy #$00
                bcc LC_MoveDown
                bne LC_MoveUp
                lda #LINE_YES
LC_StoreLine:   sta actLine,x
                rts
LC_MoveRight:   iny
                bcc LC_MoveXDone
LC_MoveLeft:    dey
LC_MoveXDone:   sty temp1
                ldy temp2
LC_CmpY2:       cpy #$00
                bcc LC_MoveDown
                beq LC_MoveYDone2
LC_MoveUp:      dey
                bcs LC_MoveYDone
LC_MoveDown:    iny
LC_MoveYDone:   sty temp2
                lda mapTblLo,y
                sta zpSrcLo
                lda mapTblHi,y
                sta zpSrcHi
LC_MoveYDone2:  dec temp3
                beq LC_NoLine
                ldy temp1
                lda (zpSrcLo),y
                tay
                lda blkTblLo,y
                sta zpDestLo
                lda blkTblHi,y
                sta zpDestHi
                ldy #$06                        ;Check from middle of block, second row
LC_Lda:         lda (zpDestLo),y
                tay
                lda charInfo,y
                and #CI_OBSTACLE
                beq LC_Loop
LC_NoLine:      lda #LINE_NO
                bne LC_StoreLine

        ; Get attack controls for an AI actor that has a valid target, including "move away" controls
        ; if target is too close
        ;
        ; Parameters: X actor index
        ; Returns: A:controls, flags also reflect its value
        ; Modifies: A,Y,temp regs

GetAttackDir:   ldy actAITarget,x               ;Check whether attack can be horizontal, vertical or diagonal
                jsr GetActorDistance
                jsr GetActorCharCoords          ;If is on the screen edge, do not fire, but come closer
                dey
                cpy #SCROLLROWS+4               ;(game can be too difficult otherwise)
                bcs GAD_NeedLessDistance
                cmp #39
                bcs GAD_NeedLessDistance
                ldy actWpn,x
                lda temp8
                beq GAD_Horizontal
                lda temp6
                beq GAD_Vertical
                cmp temp8
                beq GAD_Diagonal
GAD_NoAttackDir:bcc GAD_GoVertical              ;Diagonal, but not completely: need to move either closer or away
GAD_NeedLessDistance:
                lda temp5
                bmi GAD_NLDLeft
GAD_NLDRight:   lda #JOY_RIGHT
                rts
GAD_NLDLeft:    lda #JOY_LEFT
                rts
GAD_GoVertical: asl                             ;If is closer to a fully vertical angle, reduce distance instead
                cmp temp8
                bcc GAD_NeedLessDistance
GAD_NoAttackHint:
                lda #$00                        ;Otherwise, it is not wise to go away from target, as target may
                rts                             ;be moving under a platform, where the routecheck is broken
GAD_NeedMoreDistance:
                lda temp6                       ;If target is at same block (possibly using a melee weapon)
                ora temp8                       ;break away into whatever direction available
                bne GAD_NotAtSameBlock
                lda #JOY_FREEMOVE
                rts
GAD_NotAtSameBlock:
                lda temp5
                bmi GAD_NLDRight
                bpl GAD_NLDLeft
GAD_Diagonal:
GAD_Horizontal: lda temp6                       ;Verify horizontal distance too close / too far
                cmp itemNPCMinDist-1,y
                bcc GAD_NeedMoreDistance
                cmp itemNPCMaxDist-1,y
                bcs GAD_NeedLessDistance
                lda #JOY_RIGHT|JOY_FIRE
                ldy temp5
                bpl GAD_AttackRight
                lda #JOY_LEFT|JOY_FIRE
GAD_AttackRight:ldy temp8                       ;If block-distance is zero, do not fire diagonally
                beq GAD_Done
GAD_AttackAboveOrBelow:
                ldy temp7
                beq GAD_Done
                bpl GAD_AttackBelow
GAD_AttackAbove:ora #JOY_UP|JOY_FIRE
                rts
GAD_AttackBelow:ora #JOY_DOWN|JOY_FIRE
                rts
GAD_Vertical:   lda temp8                       ;For vertical distance, only check if too far
                cmp itemNPCMaxDist-1,y
                lda #$00                        ;If so, currently there is no navigation hint
                bcc GAD_AttackAboveOrBelow
GAD_Done:       tay                             ;Get flags of A
                rts
