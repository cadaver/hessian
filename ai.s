MAX_LINE_STEPS      = 10

AIH_AUTOSTOPLEDGE   = $01
AIH_AUTOTURNLEDGE   = $02
AIH_AUTOTURNWALL    = $04
AIH_AUTOSCALEWALL   = $80

JOY_FREEMOVE        = $80

AIMODE_IDLE         = 0
AIMODE_TURNTO       = 1
AIMODE_FOLLOW       = 2
AIMODE_SNIPER       = 3
AIMODE_MOVER        = 4
AIMODE_GUARD        = 5
AIMODE_BERZERK      = 6
AIMODE_FLYER        = 7
AIMODE_TURRET       = 7
AIMODE_ANIMAL       = 8
AIMODE_FREEMOVE     = 9
AIMODE_FLYERFREEMOVE = 10
AIMODE_FISH         = 11

NOTARGET            = $ff

LINE_NOTCHECKED     = $00
LINE_NO             = $40
LINE_YES            = $80

LADDER_DELAY        = $40

GUARD_STOP_PROBABILITY = $04

BERZERK_JUMP_MAXDIST    = 3

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
                lda actGroundCharInfo,x         ;If trying to climb down, but ladder doesn't continue, exit
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
                lda actAIMode,x                 ;Do not do the X-check in combat to prevent stopping
                cmp #AIMODE_FOLLOW
                bne AI_FollowClimbInCombat
                lda temp6                       ;Get new dir if X-distance zero (on the same ladder)
                beq AI_FollowClimbNewDir        ;or currently not moving
AI_FollowClimbInCombat:
                lda actMoveCtrl,x
                beq AI_FollowClimbNewDir        ;Otherwise remove the left/right controls
                and #JOY_UP|JOY_DOWN            ;and continue previous up/down direction
                jsr AI_StoreMoveCtrl
                lda actGroundCharInfo,x
                and #CI_GROUND                  ;Can exit?
                bne AI_FollowClimbCheckExit
                rts

AI_Follow:      lda #ACTI_PLAYER                ;Todo: do not hardcode player as target
                sta actAITarget,x
                ldy actAITarget,x
                jsr GetActorDistance
AI_FollowHasTargetDistance:
                ldy #AL_MOVEFLAGS               ;Get movement capability flags
                lda (actLo),y
                sta temp3
                and #AMF_JUMP
                beq AI_CantJump
                lda #AIH_AUTOSCALEWALL
AI_CantJump:    sta temp2
                ora #AIH_AUTOTURNLEDGE|AIH_AUTOTURNWALL
                sta actAIHelp,x
                lda actF1,x
                cmp #FR_CLIMB
                bcs AI_FollowClimb
                ldy actAITarget,x
                lda temp7                       ;If target 1 block above and jumping, treat as if level
                cmp #$ff
                bcc AI_TargetNotJumping
                lda actMB,y
                and #MB_GROUNDED
                bne AI_TargetNotJumping
                sta temp7
                sta temp8
AI_TargetNotJumping:
                lda actGroundCharInfo,y         ;If target stands on nonnavigable chars,
                sta temp1                       ;treat Y-distance as zero (turn to X-dir)
                and #CI_NOPATH                  ;when in actual follow mode
                beq AI_FollowTargetIsNavigable  ;In combat modes this could result in
                lda actAIMode,x                 ;enemies stopping, if they can't fire diagonally
                cmp #AIMODE_FOLLOW
                bne AI_FollowTargetIsNavigable
                lda #$00
                sta temp8
                beq AI_FollowTurnToTarget
AI_FollowTargetIsNavigable:
                lda actGroundCharInfo,x         ;Dedicated turning logic on stairs
                cmp #CI_GROUND+$80
                beq AI_FollowOnStairs
                and #CI_NOPATH                  ;Do not follow target strictly when on nonnavigable
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
                lda temp6                       ;Special case: don't turn when target is on stairs and X & Y dist
                bne AI_FollowTurnToTarget       ;both zero
                lda temp1
                bmi AI_FollowWalk
AI_FollowTurnToTarget:
                lda actLine,x                   ;Don't turn when no line of sight
                bpl AI_FollowWalk
                lda temp5
AI_FollowChangeDir:
                sta actD,x
                lda #AIH_AUTOSTOPLEDGE
                ora temp2
                sta actAIHelp,x
AI_FollowWalk:  lsr actLastNavLadder,x
                lda temp6                       ;If no X & Y distance, idle
                ora temp8
                beq AI_Idle
AI_NoIdle:      lda actGroundCharInfo,x         ;Check climbing down
                and #CI_CLIMB
                beq AI_FollowNoClimbDown
                lda actLastNavLadder,x          ;Do not climb if delay count from last climb still active
                bne AI_FollowNoClimbDown
                lda temp7
                bmi AI_FollowNoClimbDown
                beq AI_FollowNoClimbDown
                lda temp3
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
                ldy actSY,x                     ;If jumping upward, try to make the jump as long as possible
                bmi AI_FollowInAir
                ldy temp7                       ;Need to go up?
                bpl AI_FollowNoWalkUp
                ldy actLastNavLadder,x          ;Do not climb if delay count from last climb still active
                bne AI_FollowNoWalkUp           ;(Todo: should still walk up stairs)
AI_FollowInAir: ora #JOY_UP
                sta actPrevCtrl,x               ;Prevent jumping
AI_FollowNoWalkUp:
                jmp AI_StoreMoveCtrl

AI_FollowOnStairs:
                ldy temp1                       ;Turning OK if target also on stairs
                bmi AI_FollowStairTurnOK
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

        ; Idle AI (used as part of other routines)

AI_Idle:        jsr AI_RandomReleaseDuck
                jmp AI_StoreMoveCtrl

        ; Sniper AI

AI_Sniper:      lda actTime,x                   ;Ongoing attack?
                bmi AI_ContinueAttack
                jsr FindTargetAndAttackDir
                bcc AI_Idle
                bmi AI_FreeMoveNoDuck           ;Negative control value: need to escape
                cmp #JOY_FIRE
                bcc AI_Idle
AI_SniperPrepareAttack:
                jsr PrepareAttack
                bcc AI_Idle
AI_MoverDone:   rts

            ; Mover AI

AI_Mover:       lda actTime,x                   ;Ongoing attack?
                bmi AI_ContinueAttack
                jsr FindTargetAndAttackDir
                bcc AI_FreeMoveNoDuck
                bmi AI_FreeMoveNoDuck
                cmp #JOY_FIRE
                bcc AI_MoverFollow              ;If cannot fire, pathfind to target
                jsr PrepareAttack
                bcs AI_MoverDone
                bcc AI_FreeMoveWithTurn         ;Freemove while waiting to attack to be a harder target
AI_MoverFollow: jmp AI_FollowHasTargetDistance

        ; Subroutine: continue ongoing attack (do nothing)

AI_ContinueAttack:
                inc actTime,x
                rts

            ; Guard AI

AI_Guard:       lda actTime,x                   ;Ongoing attack?
                bmi AI_ContinueAttack
                jsr FindTargetAndAttackDir
                bcc AI_Idle
                bmi AI_FreeMoveNoDuck           ;Break from ducking if must flee
                cmp #JOY_FIRE
                bcc AI_MoverFollow              ;If cannot fire, pathfind to target
                jsr PrepareAttack
                bcs AI_MoverDone
                lda actMoveCtrl,x
                cmp #JOY_LEFT
                bcc AI_Idle                     ;If already stopped for attack, continue to stand
                lda actWpn,x                    ;If using a melee weapon, *must* stop at earliest opportunity
                cmp #ITEM_PISTOL                ;because otherwise may be too close to hit
                bcc AI_Idle
                jsr Random
                cmp #GUARD_STOP_PROBABILITY     ;Otherwise random probability to stop, to keep
                bcc AI_Idle                     ;multiple guard formations standing in the same X-pos

        ; Subroutine: free movement

AI_FreeMoveWithTurn:
                jsr AI_RandomReleaseDuck        ;If ducking, continue it randomly
                bne AI_ClearAttackControl
AI_FreeMoveNoDuck:
                lda actF1,x                     ;If on ladder, use pathfinding
                cmp #FR_CLIMB
                bcs AI_FreeMoveFollowClimb
AI_FreeMoveNoClimb:
                lda actGroundCharInfo,x
                and #CI_NOPATH
                beq AI_FreeMoveNormal
                lda #AIH_AUTOTURNWALL           ;If on nonnavigable platform, do not turn but fall as applicable
                skip2
AI_FreeMoveNormal:
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
AI_FreeMoveFollowClimb:
                jmp AI_FollowClimb

            ; Berzerk AI

AI_Berzerk:     lda actTime,x                   ;Ongoing attack?
                bmi AI_ContinueAttack
                jsr FindTargetAndAttackDir
                bcc AI_FreeMoveNoDuck
                bmi AI_FreeMoveNoDuck
                cmp #JOY_FIRE
                bcc AI_MoverFollow              ;If cannot fire, pathfind to target
AI_BerzerkCommon:
                jsr PrepareAttack
                bcs AI_BerzerkDone
                jsr GetCharInfo4Above
                and #CI_CLIMB
                bne AI_FreeMoveWithTurn
                lda actSY,x                     ;When jumping, jump maximally high
                bmi AI_BerzerkContinueJump
                lda temp8                       ;While waiting to attack, possibility to jump
                bne AI_FreeMoveWithTurn         ;Must be facing target, level, and close enough
                lda temp6
                cmp #BERZERK_JUMP_MAXDIST
                bcs AI_FreeMoveWithTurn
                lda temp5
                eor actD,x
                bmi AI_FreeMoveWithTurn
                jsr Random
                lsr
                ldy #AL_OFFENSE
                cmp (actLo),y
                bcs AI_FreeMoveWithTurn
AI_BerzerkContinueJump:
                lda actMoveCtrl,x
                ora #JOY_UP
                bne AI_StoreMoveCtrl

        ; Animal AI (variation of berzerk)
        
AI_Animal:      lda actTime,x
                bmi AI_ContinueAttack2
                jsr FindTargetAndAttackDir
                bcc AI_FreeMoveNoDuck
                bmi AI_FreeMoveNoDuck
                cmp #JOY_FIRE
                bcc AI_FreeMoveNoDuck
                bcs AI_BerzerkCommon

        ; Subroutine: randomly release ducking control (determined by offense)

AI_RandomReleaseDuck:
                lda actMoveCtrl,x
                and #JOY_DOWN
                beq AI_ReleaseDuckDone
                ldy actAITarget,x               ;If no target, random probability
                bmi AI_ReleaseDuckCheck
                lda actF1,y                     ;If has target and target is ducking,
                cmp #FR_DUCK+1                  ;do *not* stand up
                bcs AI_TargetIsDucking
AI_ReleaseDuckCheck:
                jsr Random
                ldy #AL_OFFENSE
                cmp (actLo),y
AI_TargetIsDucking:
                lda #JOY_DOWN
                bcs AI_ReleaseDuckDone
AI_ReleaseDuck: lda #$00
AI_ReleaseDuckDone:
AI_BerzerkDone:
AI_FlyerDone:
DoNothing:
                rts

AI_ContinueAttack2:
                jmp AI_ContinueAttack

        ; Flyer AI

AI_Flyer:       lda actTime,x                   ;Ongoing attack?
                bmi AI_ContinueAttack2
                inc actYH,x                     ;Aim 1 block above the target
                jsr FindTargetAndAttackDir
                php
                dec actYH,x
                plp
AI_FlyerCommon: bcc AI_FlyerIdle
                cmp #JOY_FIRE
                bcc AI_FlyerFollow
                ldy actWpn,x                    ;If no weapon, always follow (mines)
                beq AI_FlyerFollow
                tay
                bmi AI_FlyerIdle                ;Too close to target, make a diagonal pass
                sta temp1
                lda actSX,x                     ;Make sure is traveling to direction of target
                eor temp5                       ;before firing
                bmi AI_FlyerFollow
                jsr PA_NoDucking
                bcs AI_FlyerDone
AI_FlyerFollow: lda temp7
                clc
                adc actFall,x                   ;Y-targeting offset
                sta temp7
                lda #$00                        ;Determine acceleration direction toward target
                sta actAIHelp,x
                ldy temp5
                bmi AI_FlyerLeft
                ora #JOY_RIGHT
                skip2
AI_FlyerLeft:   ora #JOY_LEFT
AI_FlyerXDone:  ldy temp7
                bmi AI_FlyerUp
                ora #JOY_DOWN
                skip2
AI_FlyerUp:     ora #JOY_UP
AI_FlyerYDone:
AI_FlyerStoreDir:
                jmp AI_StoreMoveCtrl
AI_FlyerIdle:   lda #AIH_AUTOTURNWALL           ;Turn automatically if hit horizontal/vertical wall
                sta actAIHelp,x
                lda actMoveCtrl,x               ;When idle, make sure is going either left or right
                tay                             ;and either up or down
                and #JOY_LEFT|JOY_RIGHT
                beq AI_FlyerPickDir
                tya
                and #JOY_UP|JOY_DOWN
                beq AI_FlyerPickDir
AI_FlyerIdleContinue:
                jmp AI_ClearAttackControl       ;Continue existing dir, make sure fire isn't pressed
AI_FlyerPickDir:jsr Random
                and #$02
                tay
                lda actD,x
                bpl AI_FlyerPickDirRight
                iny
AI_FlyerPickDirRight:
                lda flyerDirTbl,y
                bpl AI_FlyerStoreDir

        ; Fish AI

AI_Fish:        jsr FindTargetAndAttackDir
                jmp AI_FlyerCommon

        ; Accumulate aggression & attack to specified direction. Also handle
        ; defensive ducking if the actor can duck
        ;
        ; Parameters: X actor index
        ;             A firing joystick direction (with fire held)
        ; Returns: C=0 Did not attack yet
        ;          C=1 Attacked
        ; Modifies: A,Y,temp1

PA_NoWeapon:    clc
                rts
PrepareAttack:  sta temp1                       ;Attack controls
                lda actF1,x
                cmp #FR_DUCK+1
                bne PA_NotYetDucked
                lda temp5                       ;If already ducked, ensure turning to target
                sta actD,x
                bcs PA_NoDucking                ;C=1 here
PA_NotYetDucked:cmp #FR_CLIMB
                bcs PA_NoDucking
                lda actTime,x                   ;Only make the decision once at the start of attack
                ora temp7                       ;No ducking if target not level
                bne PA_NoDucking
                lda temp5                       ;Or if not facing target
                eor actD,x
                bmi PA_NoDucking
                ldy #AL_MOVEFLAGS               ;No ducking if can't
                lda (actLo),y
                and #AMF_DUCK
                beq PA_NoDucking
                ldy #AL_DEFENSE
                lda (actLo),y
                sta temp2
                ldy actAITarget,x
                lda actF1,y
                cmp #FR_DUCK+1                  ;Increased probability if target already ducked
                bne PA_TargetNotDucking
                asl temp2
PA_TargetNotDucking:
                jsr Random
                cmp temp2
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
                beq PA_NoWeapon
                cmp itemNPCAttackThreshold-1,y  ;Enough aggression?
                bcc PA_CannotAttack
                lda temp1
                sta actCtrl,x
                lda actAIMode,x
                cmp #AIMODE_BERZERK
                bcc PA_StopMovement
                lda temp5                       ;If firing behind back, stop
                eor actD,x
                bpl PA_NoStop
PA_StopMovement:lda actMoveCtrl,x               ;NPC stops moving when attacking
                and #JOY_DOWN|JOY_UP            ;(only retain ducking/climbing controls)
                sta actMoveCtrl,x
PA_NoStop:      lda itemNPCAttackLength-1,y     ;New attack: set both per-actor and global timers
                sta attackTime
                sec
PA_CannotAttack:sta actTime,x
                rts

        ; Validate existing AI target / find new target. If has target, find out
        ; the possible firing controls
        ;
        ; Parameters: X actor index
        ; Returns: C=0 No active target / no line of sight yet
        ;          C=1 Has active target, controls in A:
        ;              $00     - No opportunity to fire, need to pathfind/follow
        ;              $10-$1f - Attack dir with fire pressed
        ;              $ff     - Too close; should evade by e.g. moving forward
        ; Modifies: A,Y,temp regs (temp5-8 contain target distance values if has good target)

FindTargetAndAttackDir:
                ldy actAITarget,x
                bmi FT_PickNew
                lda actHp,y                     ;When actor is removed (actT = 0) also health is zeroed
                beq FT_Invalidate               ;so only checking for health is enough
                lda actLine,x                   ;Invalidate / pick new if no line of sight
                bmi FT_TargetOK
                beq FT_NoTarget                 ;Line of sight not checked yet
FT_Invalidate:  lda #NOTARGET
FT_StoreTarget: sta actAITarget,x
FT_NoTarget:    clc
                rts
FT_PickNew:     ldy numTargets
                beq FT_NoTarget
                jsr PickTargetSub
                tay
                lda actFlags,x                  ;Must not be in same group
                eor actFlags,y
                and #AF_GROUPBITS
                beq FT_NoTarget
FT_SetNewTarget:lda #LINE_NOTCHECKED            ;Reset line-of-sight information now until checked
                sta actLine,x
                tya
                bpl FT_StoreTarget

FT_TargetOK:    jsr GetActorDistance
                ldy #AL_ATTACKDIRS
                lda (actLo),y
                sta temp1                       ;Store valid attack dirs
                lda temp7                       ;For purposes of diagonal attacks,
                bne FT_NotHorizontal            ;consider target below if half block or greater distance
                lda temp4
                bpl FT_AdjustOK
                inc temp8
                inc temp7
                bne FT_AdjustOK
FT_NotHorizontal:
                cmp #$01                        ;Hack for high walker: consider 1 block below horizontal
                bne FT_AdjustOK
                lda actT,x
                cmp #ACT_HIGHWALKER
                bne FT_AdjustOK
                lda #$00
                sta temp7
                sta temp8
FT_AdjustOK:    ldy actWpn,x
                lda temp6
                beq GAD_Vertical
GAD_Horizontal2:cmp itemNPCMinDist-1,y
                bcc GAD_NeedMoreDistance
                cmp #$01
                bcs GAD_NoMelee
                lda temp3                       ;Do not melee attack if distance unsuitable
                adc #$40
                bpl GAD_NeedMoreDistance
                bmi GAD_MeleeOK
GAD_NoMelee:    cmp itemNPCMaxDist-1,y
                bcs GAD_NoAttackDir
GAD_MeleeOK:    lda temp8
                beq GAD_Horizontal
                cmp temp6
                beq GAD_Diagonal
GAD_NoAttackDir:lda #$00                        ;Need to pathfind
                skip2
GAD_NeedMoreDistance:
                lda #$ff                        ;Freemove to break away
GAD_NoAttackDir2:
GAD_HasAttackDir:
                sec
                rts
GAD_Horizontal: ;lda temp1                      ;Check valid attack direction
                ;and #AB_HORIZONTAL             ;(horizontal dir always valid)
                ;beq GAD_NoAttackDir2
                lda #$00
GAD_DiagonalCommon:
                ldy temp5
                bmi GAD_Left
GAD_Right:      ora #JOY_RIGHT|JOY_FIRE
                bne GAD_HasAttackDir
GAD_Left:       ora #JOY_LEFT|JOY_FIRE
                bne GAD_HasAttackDir
GAD_Vertical:   lda temp8                       ;If both X & Y dist zero, rather use
                beq GAD_Horizontal2             ;horizontal attack
                cmp itemNPCMaxDist-1,y
                bcs GAD_NoAttackDir
                lda temp1
                ldy temp7
                bmi GAD_Up
GAD_Down:       and #AB_DOWN                    ;Check valid attack direction
                beq GAD_NoAttackDir2
                lda #JOY_DOWN|JOY_FIRE
                bne GAD_HasAttackDir
GAD_Up:         and #AB_UP
                beq GAD_NoAttackDir2
                lda #JOY_UP|JOY_FIRE
                bne GAD_HasAttackDir
GAD_Diagonal:   lda temp1
                ldy temp7
                bmi GAD_DiagonalUp
GAD_DiagonalDown:
                and #AB_DIAGONALDOWN
                beq GAD_NoAttackDir2
                lda #JOY_DOWN|JOY_FIRE
                bne GAD_DiagonalCommon
GAD_DiagonalUp: and #AB_DIAGONALUP
                beq GAD_NoAttackDir2
                lda #JOY_UP|JOY_FIRE
                bne GAD_DiagonalCommon

PickTargetSub:  jsr Random
                and targetListAndTbl-1,y
                cmp numTargets
                bcc FT_PickTargetOK
                sbc numTargets
FT_PickTargetOK:tay
                lda targetList,y
                rts
