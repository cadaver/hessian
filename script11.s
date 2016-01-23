                include macros.s
                include mainsym.s

        ; Script 11, caves

CHUNK_DURATION = 40

                org scriptCodeStart

                dc.w RadioCaves
                dc.w MoveBat
                dc.w MoveSpider
                dc.w MoveLargeSpider
                dc.w OpenWall
                dc.w MoveAcid
                dc.w RadioLowerLabs

        ; Radio speech when entering caves
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioCaves:     gettext txtRadioCaves
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx

        ; Bat movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MB_Dead:        lda #FR_DEADBATGROUND
                sta temp1
                jmp MR_Dead
MoveBat:        ldy #C_ANIMALS
                jsr EnsureSpriteFile
                lda actHp,x
                beq MB_Dead
                lda #2                          ;Wings flapping acceleration up
                cmp actF1,x                     ;or gravity acceleration down,
                bcc MB_Gravity                  ;depending on frame
                lda actMoveCtrl,x
                and #JOY_UP
                bne MB_StrongFlap
                lda #2
                skip2
MB_StrongFlap:  lda #7
                bne MB_Accel
MB_Gravity:     lda #2
MB_Accel:       ldy #2*8
                jsr AccActorYNegOrPos
                lda #$00
                sta temp6
                jsr MFE_NoVertAccel             ;Left/right acceleration & move
                lda #2
                ldy #FR_DEADBATGROUND-1
                jmp MB_BatCommon

        ; Spider movement
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars
        
MoveSpider:     ldy #C_ANIMALS
                jsr EnsureSpriteFile
                lda #FR_DEADSPIDERGROUND
                sta temp1
                lda actHp,x
                bne MS_Alive
                jmp MR_Dead
MS_Alive:       jsr MoveGeneric
                lda #2
                ldy #2
                jsr LoopingAnimation
                jmp MF_Damage

        ; Large spider boss move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveLargeSpider:ldy #C_LARGESPIDER
                jsr EnsureSpriteFile
                lda actHp,x
                bne MLS_Alive
MLS_Dying:      lda actXH,x                     ;Reached the wall?
                cmp #$3d
                bne MLS_DyingNoWall
                lda actXL,x
                cmp #$60
                bcs MLS_DyingNoWall
                jmp MLS_Explode
MLS_DyingNoWall:lda #<EP_OPENWALL               ;Wall script runs until spider no longer exists, then activates the wall object
                ldx #>EP_OPENWALL
                jsr SetScript
                ldx actIndex
                lda actFd,x
                and #$08
                beq MLS_DyingNoFlash
                lda #$0c
MLS_DyingNoFlash:
                sta actFlash,x
                jsr Random
                pha
                and #$01
                sta shakeScreen
                pla                             ;Spawn explosions randomly while retreating
                cmp #$20
                bcs MLS_NoDyingExplosion
                jsr GetAnyFreeActor
                bcc MLS_NoDyingExplosion
                jsr SpawnActor                  ;Actor type undefined at this point, will be initialized below
                tya
                tax
                jsr ExplodeActor
                jsr Random
                jsr MoveActorX
                dec actYH,x
                jsr Random
                sta actYL,x
                ldx actIndex
MLS_NoDyingExplosion:
                lda #JOY_LEFT
                bne MLS_ForcedMoveImmediate

MLS_Alive:      lda #MUSIC_CAVES+1
                jsr PlaySong
                ldx actIndex
MLS_Decision:   lda actXH,x                     ;Move forward when about to hit the left wall
                cmp #$3d
                bne MLS_NotAtWall
                lda #JOY_RIGHT
MLS_ForcedMoveImmediate:
                pha
                lda #$00                        ;After forced move, make next random decision
                sta actTime,x                   ;immediately
                pla
                bne MLS_StoreMove
MLS_NotAtWall:  cmp #$3e                        ;Do not perform retreat when almost at the wall
                beq MLS_NotTooClose             ;(too easy to exploit)
                ldy #ACTI_PLAYER
                lda actHp,y                     ;If already dead, no need
                beq MLS_NotTooClose
                jsr GetActorDistance            ;Get X-distance to player
                lda temp6
                bne MLS_NotTooClose             ;If too close, retreat
                lda actD+ACTI_PLAYER
                asl
                lda #JOY_LEFT
                bcc MLS_ForcedMoveImmediate
                asl
                bne MLS_ForcedMoveImmediate
MLS_NotTooClose:dec actTime,x
                bpl MLS_Move
                lda actAttackD+ACTI_PLAYER      ;If player is attacking now, always attack
                beq MLS_NoForcedAttack          ;as the next decision
                lda #$03
                bne MLS_ForcedMove
MLS_NoForcedAttack:
                jsr Random
                and #$03
                cmp #$02                        ;Do not attack twice in a row
                bcc MLS_ForcedMove
                ldy actMoveCtrl,x
                cpy #JOY_FIRE
                beq MLS_NoForcedAttack          ;Rerandomize in that case
MLS_ForcedMove: tay
                jsr Random
                and spiderDelayAndTbl,y
                clc
                adc #$10
                sta actTime,x
                lda spiderMoveTbl,y
MLS_StoreMove:  sta actMoveCtrl,x
MLS_Move:       jsr MoveGeneric
                lda actXL+ACTI_PLAYER
                cmp actXL,x
                lda actXH+ACTI_PLAYER           ;Override direction: always face player
                sbc actXH,x
                sta actD,x
                lda actSX,x
                jsr Asr8
                clc
                adc actFd,x
                bpl MLS_NotOverNeg
                clc
                adc #$60
MLS_NotOverNeg: cmp #$60
                bcc MLS_NotOverPos
                sbc #$60
MLS_NotOverPos: sta actFd,x
                lsr
                lsr
                lsr
                lsr
                lsr
                sta actF1,x
                lda actMoveCtrl,x               ;About to launch acid?
                cmp #JOY_FIRE
                bne MLS_NoAttack
                lda #2
                sta actF1,x
                lda #$40                        ;Reset walking animation after attack
                sta actFd,x
                lda actTime,x
                cmp #8
                bcs MLS_NoAttack
                cmp #4
                bcc MLS_NoAttack
                php
                inc actF1,x
                plp
                bne MLS_NoAttack

MLS_Attack:     lda #ACTI_FIRSTNPCBULLET
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc MLS_NoAttack
                lda #SFX_SHOTGUN
                jsr PlaySfx
                lda #<(-9*8)
                sta temp3
                lda #>(-9*8)
                sta temp4
                lda actD,x
                bmi MLS_AttackLeft
MLS_AttackRight:lda #<28*8
                sta temp1
                lda #>28*8
                sta temp2
                lda #ACT_ACID
                jsr SpawnWithOffset
                tya
                tax
                jsr InitActor
                lda #6*8+4
                sta actSX,x
                lda actXH,x
                sec
                sbc actXH+ACTI_PLAYER           ;Player is on the right -> negative
MLS_AttackCommon:
                asl
                asl
                adc #-3*8-2
                sta actSY,x
                ldx actIndex
MLS_NoAttack:   rts

MLS_AttackLeft: lda #<(-28*8)
                sta temp1
                lda #>(-28*8)
                sta temp2
                lda #ACT_ACID
                jsr SpawnWithOffset
                tya
                tax
                jsr InitActor
                lda #-6*8-4
                sta actSX,x
                lda actXH+ACTI_PLAYER
                sec
                sbc actXH,x                    ;Player is on the left -> negative
                jmp MLS_AttackCommon

MLS_Explode:    lda #MUSIC_CAVES
                jsr PlaySong
                ldx actIndex
                lda #-15*8
                jsr MoveActorYNoInterpolation
                lda #6
                ldy #$ff
                jsr ExplodeEnemyMultiple
                lda #-2*8-8
                sta temp7                       ;Initial base X-speed
                lda #0
                sta temp8                       ;Initial shape
MLS_ChunkLoop:  jsr GetAnyFreeActor
                bcc MLS_ChunkDone
                lda #ACT_SPIDERCHUNK
                jsr SpawnActor
                jsr Random
                and #$0f                        ;Randomize upward + sideways speed
                clc
                adc #-7*8
                sta actSY,y
                jsr Random
                and #$0f
                clc
                adc temp7
                sta actSX,y
                lda temp8
                sta actF1,y
                inc temp8
                lda #CHUNK_DURATION
                sta actTime,y
                lda temp7
                bpl MLS_ChunkDone
                clc
                adc #2*8
                sta temp7
                bne MLS_ChunkLoop
MLS_ChunkDone:  rts

        ; Script routine for opening the wall after spider death
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

OpenWall:       lda #ACT_LARGESPIDER            ;Run either when the spider has exploded, or player exits the zone
                jsr FindActor
                bcs OW_HasSpider
                ldy #7
                jsr ActivateObject
                jmp StopScript
MA_NotDone:
OW_HasSpider:   rts

        ; Acid move routine
        ;
        ; Parameters: X actor index
        ; Returns: -
        ; Modifies: A,Y,temp1-temp8,loader temp vars

MoveAcid:       lda actHp+ACTI_PLAYER
                beq MA_NoPlayerCollision
                lda #DMG_ACID
                jsr CollideAndDamagePlayer
                bcs MA_StartPlayerSplash
MA_NoPlayerCollision:
                jsr FallingMotionCommon
                tay                             ;Any collision -> splash
                bne MA_StartSplash
                lda #1
                ldy #3
                jmp LoopingAnimation
MA_StartSplash: lda #ACT_WATERSPLASH
                jsr TransformActor
MA_SplashCommon:jsr NoInterpolation
                lda #13
                sta actFlash,x
                lda #SFX_SPLASH
                jmp PlaySfx
MA_StartPlayerSplash:
                lda #ACT_EXPLOSION
                jsr TransformActor
                lda #-4*8
                jsr MoveActorY
                lda #2
                sta actF1,x
                bne MA_SplashCommon

        ; Radio speech shortly after entering lower labs
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioLowerLabs: gettext txtRadioLowerLabs
                jmp RadioMsg

        ; Tables

spiderMoveTbl:  dc.b JOY_LEFT,JOY_RIGHT,JOY_FIRE,JOY_FIRE
spiderDelayAndTbl:
                dc.b $1f,$1f,$07,$07
        
        ; Messages

txtRadioCaves:  dc.b 34,"IT'S AMOS. EXCELLENT WORK. WITH LUCK, THESE CAVES LEAD YOU TO THE LOWER LABS. ONCE THERE, "
                dc.b "SEE IF YOU CAN UNLOCK THE ELEVATOR. DON'T BE ALARMED IF YOU SEE "
                dc.b "UNUSUAL CAVE DWELLERS. THERE HAVE BEEN LEAKS OF SOME STRONGLY MUTAGENIC CHEMICALS.",34,0

txtRadioLowerLabs:
                dc.b 34,"LINDA HERE. WE GOT JEFF TO HELP - HE MANAGED TO DECRYPT SOME OF THE MACHINE "
                dc.b "COMMUNICATIONS. THEIR ACTIVITY IS FOCUSED ON THE TUNNELS THAT LEAD FURTHER BELOW "
                dc.b "FROM THE LOWER LABS. THEY'VE BUILT SOMETHING CALLED "
                dc.b "'JORMUNGANDR.' THAT DOESN'T SOUND GOOD. THE AIR DOWN THERE IS TOXIC. "
                dc.b "WE MUST FIGURE OUT HOW TO PROCEED. MEANWHILE, YOU JUST GET THE ELEVATOR WORKING.",34,0

                checkscriptend
