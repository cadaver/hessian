MAX_ROUTE_STEPS     = 10

MAX_NAVIGATION_STEPS = 8

AIH_CHECKLEFT       = $01
AIH_CHECKRIGHT      = $02
AIH_FOUNDLEFT       = $04
AIH_FOUNDRIGHT      = $08
AIH_AUTOTURNWALL    = $10
AIH_AUTOSTOPLEDGE   = $20
AIH_AUTOTURNLEDGE   = $40
AIH_AUTOJUMPLEDGE   = $80

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

ROUTE_NOTCHECKED    = $00
ROUTE_NO            = $01
ROUTE_YES           = $80

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
                ldy actAITarget,x
                bmi AI_FollowNoTarget
                jsr GetActorDistance
AI_CheckClimbing:
                lda actF1,x                     ;Check for possibility to climb to target
                cmp #FR_CLIMB
                bcs AI_IsClimbing
                lda temp7
                bpl AI_NoStairCheck
                lda actMB,x                     ;Check for climbing up a stair junction one char above
                lsr                             ;(hack, this is something the player can do only by jumping)
                bcc AI_NoStairCheck
                lda #-1
                jsr GetCharInfoOffset
                lsr
                bcc AI_NoStairCheck
                lda #-8*8
                jsr MoveActorY
                jmp AI_NoClimbing
AI_NoStairCheck:lda temp8                       ;Do not start climbing unless at least 1 block distance to target
                beq AI_NoClimbing               ;TODO: should actually check whether target is reachably with the ladder
AI_OKToClimb:   ldy #AL_MOVEFLAGS
                lda (actLo),y
                and #AMF_CLIMB
                beq AI_NoClimbing
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
                jmp AI_FreeMove
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
AI_NotAtTarget: lda actAIHelp,x                 ;Previous navigation searches still ongoing?
                tay
                and #AIH_CHECKLEFT|AIH_CHECKRIGHT
                bne AI_NoNewSearch
                tya
                ora #AIH_CHECKLEFT|AIH_CHECKRIGHT|AIH_AUTOTURNWALL|AIH_AUTOTURNLEDGE
                sta actAIHelp,x
                and #AIH_FOUNDLEFT|AIH_FOUNDRIGHT ;Found route either on left or right?
                beq AI_NoNewSearch
                cmp #AIH_FOUNDLEFT|AIH_FOUNDRIGHT ;If both found, continue to current dir
                beq AI_NoNewSearch              ;else turn to the correct direction
                jmp AI_StoreMoveCtrl
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
                lda actRoute,x                  ;If route blocked, try to get new target
                bmi AI_HasRoute
                beq AI_Idle
                jsr FT_PickNew
                jmp AI_Idle
AI_HasRoute:    jsr GetAttackDir
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
FT_CheckRoute:  cpx #ACTI_LASTNPC+1             ;If this is a homing bullet, there will be no navigation/route
                bcs FT_CheckRoute2              ;check later, so check now
                lda #ROUTE_NOTCHECKED           ;For NPCs, reset route information now until checked
                sta actRoute,x
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
                lda #ROUTE_YES
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
                readblockinfo
                and #BI_OBSTACLE
                beq RC_Loop
RC_NoRoute:     lda #ROUTE_NO
                clc                             ;Route not found
                rts

        ; Check whether there is navigability to target on either left or right
        ;
        ; Parameters: X actor index, A value of actAIHelp
        ; Returns: actAIHelp modified
        ; Modifies: A,Y,temp variables

NC_GoStraight:  pla
                sta NC_GoStraightModifyX
                lda actXH,y
                sta NC_GoStraightTarget+1
                sec
                sbc actXH,x                     ;Consider the straight search always a failure if going
                eor NC_GoStraightModifyX        ;into the wrong direction
                and #$40
                beq NC_StoreFailure2
                ldy actXH,x
NC_GoStraightLoop:
NC_GoStraightTarget:
                cpy #$00                        ;Target reached?
                beq NC_StoreSuccess2
                lda (zpDestLo),y
                sty zpBitBuf
                readblockinfo
                ldy zpBitBuf
                lsr                             ;If no continuous ground, failure
                bcc NC_StoreFailure2
NC_GoStraightModifyX:
                iny
                dec temp1
                bne NC_GoStraightLoop           ;If the straight search does not terminate in an obstacle,
NC_StoreFailure2:                               ;consider it a success
                jmp NC_StoreFailure
NC_StoreSuccess2:
                jmp NC_StoreSuccess

NavigationCheck:
                lsr
                lda #$c8                        ;INY
                bcc NC_Right
                lda #$88                        ;DEY
NC_Right:       pha
                lda #MAX_NAVIGATION_STEPS       ;Store maximum steps counter
                sta temp1
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
                beq NC_GoStraight
                bcs NC_GoUp
NC_GoDown:      pla
                sta NC_GoDownModifyX
                cmp #$c8
                lda #BI_STAIRSLEFT
                adc #$00
                sta NC_GoDownStairType+1        ;Store correct stair type for going down
                ldy actXH,x
NC_GoDownLoop:  lda (zpDestLo),y
                sty zpBitBuf
                readblockinfo
                ldy zpBitBuf
NC_GoDownStairType:
                cmp #BI_STAIRSLEFT              ;If found stairs leading down, success
                beq NC_StoreSuccess
                cmp #BI_STAIRSLEFT              ;Stairs to any direction are OK for continuing;
                bcs NC_GoDownModifyX            ;there may be a ladder further on
                lsr
                and #BI_CLIMB/2                 ;Check for ladder
                bne NC_StoreSuccess
                bcc NC_StoreFailure             ;If no continuous ground, failure
NC_GoDownModifyX:
                iny
                cpy limitR
                bcs NC_StoreFailure             ;Got outside map, failure
                cpy limitL
                bcc NC_StoreFailure
                dec temp1
                bne NC_GoDownLoop

NC_StoreFailure:lda actAIHelp,x
                lsr
                lda #$ff-AIH_CHECKLEFT-AIH_FOUNDLEFT
                bcs NC_StoreFailureCommon
NC_StoreFailureRight:
                lda #$ff-AIH_CHECKRIGHT-AIH_FOUNDRIGHT
NC_StoreFailureCommon:
                and actAIHelp,x
NC_StoreCommon: sta actAIHelp,x
                rts
NC_StoreSuccess:lda actAIHelp,x
                lsr
                bcs NC_StoreSuccessLeft
NC_StoreSuccessRight:
                lda actAIHelp,x
                and #$ff-AIH_CHECKRIGHT
                ora #AIH_FOUNDRIGHT
                bne NC_StoreCommon
NC_StoreSuccessLeft:
                lda actAIHelp,x
                and #$ff-AIH_CHECKLEFT
                ora #AIH_FOUNDLEFT
                bne NC_StoreCommon

NC_GoUp:        pla
                sta NC_GoUpModifyX
                cmp #$c8
                lda #BI_STAIRSLEFT
                adc #$00
                eor #$01
                sta NC_GoUpStairType+1          ;Store correct stair type for going up
                ldy actXH,x
NC_GoUpLoop:    lda (zpDestLo),y                ;First check that ground continues below feet, otherwise failure
                sty zpBitBuf
                readblockinfo
                ldy zpBitBuf
NC_GoUpStairType:
                cmp #BI_STAIRSRIGHT
                beq NC_StoreSuccess
                lsr
                bcc NC_StoreFailure
                lda (zpSrcLo),y
                readblockinfo
                ldy zpBitBuf
                cmp #BI_CLIMB                   ;If found stairs/ladder leading up, success. The stairs can
                bcs NC_StoreSuccess             ;be either orientation
NC_GoUpModifyX:
                iny
                cpy limitR
                bcs NC_StoreFailure             ;Got outside map, failure
                cpy limitL
                bcc NC_StoreFailure
                dec temp1
                bne NC_GoUpLoop

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
