MAX_LINE_STEPS     = 10
MAX_NAVIGATION_STEPS = 8

AIH_AUTOTURNWALL    = $20
AIH_AUTOTURNLEDGE   = $40
AIH_AUTOSTOPLEDGE   = $80

NAV_CHECKLEFT       = $01
NAV_CHECKRIGHT      = $02
NAV_FOUNDLEFT       = $04
NAV_FOUNDRIGHT      = $08
NAV_STAIRSLEFT      = $10
NAV_STAIRSRIGHT     = $20

JOY_CLIMBSTAIRS     = $40
JOY_FREEMOVE        = $80

AIMODE_IDLE         = 0
AIMODE_TURNTO       = 1
AIMODE_FOLLOW       = 2
AIMODE_SNIPER       = 3

NOTARGET            = $ff

BI_GROUND           = 1
BI_OBSTACLE         = 2
BI_CLIMB            = 4
BI_STAIRSLEFT       = 8
BI_STAIRSRIGHT      = 9

LINE_NOTCHECKED     = $00
LINE_NO             = $40
LINE_YES            = $80

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

        ; Follow (pathfinding) AI

AI_FollowNoTarget:
                jmp AI_Idle
AI_Follow:      lda #$00                        ;Always go to player (TODO: test code, remove)
                sta actAITarget,x
                lda #AIH_AUTOTURNWALL|AIH_AUTOTURNLEDGE
                sta actAIHelp,x
                ldy actAITarget,x
                bmi AI_FollowNoTarget
                jsr GetActorDistance
AI_CheckClimbing:
                lda actF1,x                     ;Already climbing?
                cmp #FR_CLIMB
                bcs AI_IsClimbing
                lda actMB,x
                lsr
                bcc AI_InAir                    ;If in air, just do freemove to complete the jump/fall
                lda temp7
                bpl AI_NoStairsUp               ;If target is above,
                lda #-1                         ;check for going up at a stairs junction
                jsr GetCharInfoOffset           ;(Hack! Player must do this by jumping up)
                lsr
                bcc AI_NoStairsUp
                lda #-8*8
                jsr MoveActorY
                jmp AI_NoClimbing
AI_NoStairsUp:  lda temp8                       ;Do not climb unless at least 1 block vertical distance
                beq AI_NoClimbing
                ldy #AL_MOVEFLAGS               ;Check first if the actor can actually climb
                lda (actLo),y
                and #AMF_CLIMB
                beq AI_NoClimbing
                lda temp6                       ;If there are stairs at the end of the left/right route
                beq AI_OKToClimb                ;prefer them instead of climbing. Exception: if horizontally
                lda #NAV_STAIRSLEFT             ;at the target, allow to climb
                ldy actD,x
                bmi AI_FacingLeft
                asl
AI_FacingLeft:  and actNav,x
                bne AI_NoClimbing
AI_OKToClimb:
AI_RecheckClimbDir:
                lda temp7
                bmi AI_CheckClimbUp
AI_CheckClimbDown:
                jsr GetCharInfo
                and #CI_CLIMB
                beq AI_NoClimbing
                lda #JOY_DOWN
                jmp AI_StoreMoveCtrl
AI_CheckClimbUp:jsr GetCharInfo4Above
                and #CI_CLIMB
                beq AI_NoClimbing
                lda #JOY_UP
                jmp AI_StoreMoveCtrl
AI_IsClimbing:  lda temp6                       ;If climbing the same ladder as target, stop if close
                ora temp8
                bne AI_ClimbingNotAtTarget
                lda #$00
                jmp AI_StoreMoveCtrl
AI_ClimbingNotAtTarget:
                lda actMoveCtrl,x               ;Restart climbing if was interrupted
                and #JOY_UP|JOY_DOWN
                beq AI_RecheckClimbDir
                cmp #JOY_UP
                beq AI_CheckExitUp
AI_CheckExitDown:
                jsr GetCharInfo                 ;If climbing down, exit when possible
                and #CI_GROUND|CI_CLIMB         ;if target distance is less than block
                lsr                             ;or cannot climb further down
                beq AI_ExitLadder
                lda temp8
                bne AI_NoExitLadder
                bcc AI_NoExitLadder
AI_ExitLadder:  lda temp5                       ;When exiting the ladder, always face target
                sta actD,x
AI_InAir:       jmp AI_FreeMove
AI_NoExitLadder:rts
AI_CheckExitUp: jsr GetCharInfo4Above
                and #CI_CLIMB
                beq AI_ExitLadder
                lda temp8
                bne AI_NoExitLadder
                jsr GetCharInfo
                lsr
                bcs AI_ExitLadder
                rts
AI_NoClimbing:  lda temp8                       ;Check if already close enough to target
                ora temp6
                beq AI_Idle
AI_NotAtTarget: lda actNav,x                    ;Previous navigation searches still ongoing?
                tay
                and #NAV_CHECKLEFT|NAV_CHECKRIGHT
                bne AI_NoNewSearch
                tya
                ora #NAV_CHECKLEFT|NAV_CHECKRIGHT
                sta actNav,x
                and #NAV_FOUNDLEFT|NAV_FOUNDRIGHT ;Found route either on left or right?
                beq AI_NoNewSearch
                cmp #NAV_FOUNDLEFT|NAV_FOUNDRIGHT ;If yes, set new direction
                beq AI_NoNewSearch
AI_TurnToNewDir:jmp AI_StoreMoveCtrl
AI_NoNewSearch: jmp AI_FreeMove

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
AI_StoreMovementHelp:
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
FT_CheckLine:   cpx #ACTI_LASTNPC+1             ;If this is a homing bullet, there will be no line-of-sight
                bcs FT_CheckLine2               ;check later, so check now
                lda #LINE_NOTCHECKED            ;For NPCs, reset line information now until checked
                sta actLine,x
                tya
                bcc FT_StoreTarget
FT_CheckLine2:  tya
                pha
                jsr LineCheck
                pla
                bcs FT_StoreTarget
                rts

        ; Check if there is obstacles (coarse line-of-sight) between actors
        ;
        ; Parameters: X actor index, Y target actor index
        ; Returns: C=1 line-of-sight OK, C=0 line-of-sight fail
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
                sta zpDestLo
                lda mapTblHi,y
                sta zpDestHi
LC_Loop:        ldy temp1
LC_CmpX:        cpy #$00
                bcc LC_MoveRight
                bne LC_MoveLeft
                ldy temp2
LC_CmpY:        cpy #$00
                bcc LC_MoveDown
                bne LC_MoveUp
                rts                             ;C=1, line-of-sight found
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
                lda mapTblLo,y                  ;Take new maprow
                sta zpDestLo
                lda mapTblHi,y
                sta zpDestHi
LC_MoveYDone2:  dec temp3
                beq LC_Fail
                ldy temp1
                lda (zpDestLo),y                ;Take block from map
                readblockinfo
                and #BI_OBSTACLE
                beq LC_Loop
LC_Fail:        clc                             ;Line-of-sight not found
                rts

        ; Check whether there is navigability to target on either left or right
        ;
        ; Parameters: X actor index, A value of actNav
        ; Returns: actNav modified
        ; Modifies: A,Y,temp variables

NavigationCheck:
                lsr
                bcs NC_Left
                lda #$c8                        ;INY
                sta temp3                       ;Horizontal movement instruction
                lda #BI_STAIRSRIGHT
                sta temp4                       ;Stair type for going down
                lda actNav,x
                and #$ff-NAV_CHECKRIGHT-NAV_FOUNDRIGHT-NAV_STAIRSRIGHT
                sta actNav,x                    ;Reset bits
                lda #NAV_FOUNDRIGHT
                ldy #NAV_FOUNDRIGHT|NAV_STAIRSRIGHT
                bne NC_Common
NC_Left:        lda #$88                        ;DEY
                sta temp3
                lda #BI_STAIRSLEFT
                sta temp4
                lda actNav,x
                and #$ff-NAV_CHECKLEFT-NAV_FOUNDLEFT-NAV_STAIRSLEFT
                sta actNav,x
                lda #NAV_FOUNDLEFT
                ldy #NAV_FOUNDLEFT|NAV_STAIRSLEFT
NC_Common:      sta temp5                       ;Success bit
                sty temp6                       ;Stairs+success bit
                lda #MAX_NAVIGATION_STEPS       ;Store maximum steps counter
                sta temp1
                lda #$00
                sta temp7                       ;Ladder found-flag
                ldy actYH,x
                lda mapTblLo,y                  ;Take current maprow
                sta zpDestLo
                lda mapTblHi,y
                sta zpDestHi
                dey
                lda mapTblLo,y                  ;Take the maprow above
                sta zpSrcLo
                lda mapTblHi,y
                sta zpSrcHi
                ldy actAITarget,x
                lda actYH,y                     ;Adjust target Y-position: if jumping/falling,
                sta temp2                       ;set 1 block below
                lda actMB,y
                and #MB_GROUNDED
                bne NC_TargetGrounded
                inc temp2
NC_TargetGrounded:
                lda actYH,x
                cmp temp2
                bne NC_DownOrUp

NC_GoStraight:  lda temp3
                sta NC_GoStraightModifyX
                lda actXH,y
                sta NC_GoStraightTarget+1
                sec
                sbc actXH,x                     ;Consider the straight search always a failure if going
                eor NC_GoStraightModifyX        ;into the wrong direction
                and #$40
                beq NC_Failure
                ldy actXH,x
NC_GoStraightLoop:
NC_GoStraightTarget:
                cpy #$00                        ;Target reached?
                beq NC_Success
                lda (zpDestLo),y
                sty zpBitBuf
                readblockinfo
                ldy zpBitBuf
                lsr                             ;If no continuous ground, failure
                bcc NC_Failure
NC_GoStraightModifyX:
                iny
                dec temp1                       ;If ran out of steps, the straight search is
                bne NC_GoStraightLoop           ;considered a success
                beq NC_Success

NC_DownOrUp:    bcs NC_GoUp
NC_GoDown:      lda temp3
                sta NC_GoDownModifyX
                ldy actXH,x
NC_GoDownLoop:  lda (zpDestLo),y
                sty zpBitBuf
                readblockinfo
                ldy zpBitBuf
NC_GoDownStairType:
                cmp temp4                       ;If found stairs leading down, success
                beq NC_SuccessStairs
                cmp #BI_STAIRSLEFT              ;Stairs to any direction are OK for continuing;
                bcs NC_GoDownModifyX            ;there may be a ladder further on
                lsr
                and #BI_CLIMB/2                 ;Check for ladder
                beq NC_GoDownNoLadder
                inc temp7                       ;Store ladder flag for later
NC_GoDownNoLadder:
                bcc NC_Failure                  ;If no continuous ground, failure
NC_GoDownModifyX:
                iny
                cpy limitR
                bcs NC_Failure                  ;Got outside map, failure
                cpy limitL
                bcc NC_Failure
                dec temp1
                bne NC_GoDownLoop
            
NC_Failure:     lda temp7                       ;If found a ladder during the down/up search, is actually
                bne NC_Success                  ;a success
                rts
NC_Success:     lda temp5
NC_SuccessCommon:
                ora actNav,x
                sta actNav,x
                rts
NC_SuccessStairs:
                lda temp6                       ;If found stairs, it's a special case of success condition
                bne NC_SuccessCommon            ;(more "valuable" than a ladder)

NC_GoUp:        lda temp3
                sta NC_GoUpModifyX
                lda temp4
                eor #$01
                sta temp4                       ;Correct stair type for going up
                ldy actXH,x
NC_GoUpLoop:    lda (zpDestLo),y                ;First check that ground continues below feet, otherwise failure
                sty zpBitBuf
                readblockinfo
                ldy zpBitBuf
NC_GoUpStairType:
                cmp temp4
                beq NC_SuccessStairs
                lsr
                bcc NC_Failure                  ;If no continuous ground, failure
                lda (zpSrcLo),y
                readblockinfo
                ldy zpBitBuf
                cmp #BI_STAIRSLEFT              ;If found stairs/ladder leading up, success. The stairs can
                bcs NC_SuccessStairs            ;be either orientation
                and #BI_CLIMB
                beq NC_GoUpModifyX
                inc temp7                       ;Store ladder flag for later
NC_GoUpModifyX: iny
                cpy limitR
                bcs NC_Failure                  ;Got outside map, failure
                cpy limitL
                bcc NC_Failure
                dec temp1
                bne NC_GoUpLoop
                beq NC_Failure

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
                rts                             ;be moving under a platform, where the line-of-sight is broken
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
