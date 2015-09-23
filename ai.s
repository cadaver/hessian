MAX_LINE_STEPS      = 10

MAX_NAVIGATION_STEPS = 8

AIH_AUTOTURNWALL    = $20
AIH_AUTOTURNLEDGE   = $40
AIH_AUTOSTOPLEDGE   = $80

JOY_FREEMOVE        = $80

AIMODE_IDLE         = 0
AIMODE_TURNTO       = 1
AIMODE_FOLLOW       = 2
AIMODE_SNIPER       = 3
AIMODE_MOVER        = 4
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
                jsr AI_StoreMoveCtrl
                lda temp4
                and #CI_GROUND                  ;Can exit?
                bne AI_FollowClimbCheckExit
                rts

AI_Follow:      lda #ACTI_PLAYER                ;Todo: do not hardcode player as target
                sta actAITarget,x
                ldy actAITarget,x
                jsr GetActorDistance
AI_FollowHasTargetDistance:
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
                and #CI_SHELF                   ;Do not follow target strictly when on "nonnavigable"
                bne AI_FollowWalk               ;ledges, just turn when come to a stop
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

AI_Idle:        jsr AI_RandomReleaseDuck
                jmp AI_StoreMoveCtrl

        ; Sniper AI

AI_Sniper:      lda actTime,x                   ;Ongoing attack?
                bmi AI_ContinueAttack
                jsr FindTargetAndAttackDir
                bcc AI_Idle
                bmi AI_FreeMoveWithTurn         ;Negative control value: need to escape
                cmp #JOY_FIRE
                bcc AI_Idle
                jsr PrepareAttack
                bcc AI_Idle
AI_MoverDone:   rts

            ; Mover AI

AI_Mover:       lda actTime,x                   ;Ongoing attack?
                bmi AI_ContinueAttack
                jsr FindTargetAndAttackDir
                bcc AI_FreeMoveWithTurn
                bmi AI_FreeMoveWithTurn
                cmp #JOY_FIRE
                bcc AI_MoverFollow              ;If cannot fire, pathfind to target
                jsr PrepareAttack
                bcs AI_MoverDone
                bcc AI_FreeMoveWithTurn         ;Freemove while waiting to attack to be a harder target
AI_MoverFollow: ldy actAITarget,x
                jmp AI_FollowHasTargetDistance

        ; Subroutine: free movement

AI_FreeMoveWithTurn:
                jsr AI_RandomReleaseDuck        ;If ducking, continue it randomly
                bne AI_ClearAttackControl
                lda #AIH_AUTOTURNLEDGE|AIH_AUTOTURNWALL
                sta actAIHelp,x
AI_FreeMove:    lda #JOY_RIGHT                  ;Move forward into facing direction, turn at walls / ledges
                ldy actD,x
                bpl AI_FreeMoveRight
                lda #JOY_LEFT
AI_FreeMoveRight:
AI_StoreMoveCtrl:
                sta actMoveCtrl,x
AI_ClearAttackControl:
                lda #$00
                sta actCtrl,x
                rts

        ; Subroutine: continue ongoing attack (do nothing)

AI_ContinueAttack:
                inc actTime,x
                rts

        ; Subroutine: randomly release ducking control (determined by offense)

AI_RandomReleaseDuck:
                lda actMoveCtrl,x
                and #JOY_DOWN
                beq AI_ContinueDuck
                jsr Random
                ldy #AL_OFFENSE
                cmp (actLo),y
                lda #JOY_DOWN
                bcs AI_ContinueDuck
                lda #$00
AI_ContinueDuck:rts

        ; Accumulate aggression & attack to specified direction. Also handle
        ; defensive ducking if the actor can duck
        ;
        ; Parameters: X actor index
        ;             A firing joystick direction (with fire held)
        ; Returns: C=0 Did not attack yet
        ;          C=1 Attacked
        ; Modifies: A,Y,temp1

PrepareAttack:  sta temp1                       ;Attack controls
                lda actF1,x
                cmp #FR_DUCK+1
                bne PA_NotYetDucked
                lda temp5                       ;If already ducked, ensure turning to target
                sta actD,x
                bcs PA_NoDucking                ;C=1 here
PA_NotYetDucked:cmp #FR_CLIMB
                bcs PA_NoDucking
                lda temp7                       ;No ducking if target not level
                bne PA_NoDucking                ;or not facing target
                lda temp5
                eor actD,x
                bmi PA_NoDucking
                ldy #AL_MOVEFLAGS
                lda (actLo),y
                and #AMF_DUCK
                beq PA_NoDucking
                jsr Random
                ldy #AL_DEFENSE
                cmp (actLo),y
                bcs PA_NoDucking
                jsr GetCharInfo                 ;Verify not going to climb down instead
                and #CI_CLIMB
                bne PA_NoDucking
                lda #JOY_DOWN
                sta actMoveCtrl,x
PA_NoDucking:   jsr Random
                ldy #AL_OFFENSE
                and (actLo),y
                clc
                adc actTime,x                   ;Increment aggression counter
                bpl PA_AggressionNotOver
                lda #$7f                        ;Clamp to positive, as negative means ongoing attack
PA_AggressionNotOver:
                ldy attackTime                  ;Check global attack timer
                bmi PA_CannotAttack             ;(someone else attacking now?)
                ldy actAttackD,x                ;Check weapon's attack timer
                bne PA_CannotAttack
                ldy actWpn,x
                cmp itemNPCAttackThreshold-2,y  ;Enough aggression?
                bcc PA_CannotAttack
                lda temp1
                sta actCtrl,x
                lda actMoveCtrl,x               ;NPC stops moving when attacking
                and #JOY_DOWN                   ;(only retain ducking control as necessary)
                sta actMoveCtrl,x
                lda itemNPCAttackLength-2,y     ;New attack: set both per-actor and global timers
                sta attackTime
                sec
PA_CannotAttack:sta actTime,x
                rts

        ; Validate existing AI target / find new target. If has target, find out
        ; the possible firing controls
        ;
        ; Parameters: X actor index
        ; Returns: C=0 No active target / no line of sight yet
        ;          C=1 Has active target, firing controls in A or special values:
        ;              $01-$0f - Suggested movement to get into firing position. 
        ;                        Can also do pathfinding or be idle
        ;              $80     - Should evade by e.g. moving forward
        ; Modifies: A,Y,temp regs (temp5-8 contain target distance values if has good target)

FindTargetAndAttackDir:
                ldy actAITarget,x
                bmi FT_PickNew
                lda actHp,y                     ;When actor is removed (actT = 0) also health is zeroed
                beq FT_Invalidate               ;so only checking for health is enough
                lda actLine,x                   ;Invalidate / pick new if no line of sight
                bmi FT_TargetOK
                bne FT_Invalidate
FT_Invalidate:  lda #NOTARGET
FT_StoreTarget: sta actAITarget,x
FT_NoTarget:    clc
                rts
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
                sta actLine,x
                tya
                bpl FT_StoreTarget

FT_TargetOK:    jsr GetActorDistance
                ldy actWpn,x
                lda temp8
                beq GAD_Horizontal
                lda temp6
                beq GAD_Vertical
                cmp temp8
                beq GAD_Diagonal
GAD_NoAttackDir:bcc GAD_GoVertical              ;Diagonal, but not completely: need to move either closer or away
GAD_NeedLessDistance:
                sec
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
                                                ;(note: C=1 here)
GAD_NeedMoreDistance:
                sec
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
                cmp itemNPCMinDist-2,y
                bcc GAD_NeedMoreDistance
                cmp itemNPCMaxDist-2,y
                bcs GAD_NeedLessDistance
                lda #JOY_RIGHT|JOY_FIRE
                ldy temp5
                bpl GAD_AttackRight
                lda #JOY_LEFT|JOY_FIRE
GAD_AttackRight:ldy temp8                       ;If block-distance is zero, do not fire diagonally
                beq GAD_Done
GAD_AttackAboveOrBelow:
                sec
                ldy temp7
                beq GAD_Done
                bpl GAD_AttackBelow
GAD_AttackAbove:ora #JOY_UP|JOY_FIRE
                rts
GAD_AttackBelow:ora #JOY_DOWN|JOY_FIRE
                rts
GAD_Vertical:   lda temp8                       ;For vertical distance, only check if too far
                cmp itemNPCMaxDist-2,y
                lda #$00                        ;If so, currently there is no navigation hint
                bcc GAD_AttackAboveOrBelow
GAD_Done:       tay                             ;Get flags of A
                sec
                rts

        ; Check if there are obstacles between actors (coarse line-of-sight)
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

