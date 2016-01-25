                include macros.s
                include mainsym.s

        ; Script 7, rechargers, saboteur robot

                org scriptCodeStart

                dc.w UseHealthRecharger
                dc.w UseBatteryRecharger
                dc.w RechargerEffect
                dc.w CombatRobotSaboteur
                dc.w DestroyCombatRobotSaboteur

        ; Health recharger script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

UseHealthRecharger:
                lda actHp+ACTI_PLAYER
                cmp #HP_PLAYER
                bcs UHR_Full
                lda #HP_PLAYER
                sta actHp+ACTI_PLAYER
                lda #<txtHealthRecharger
                ldx #>txtHealthRecharger
Recharger_Common:
                ldy #REQUIREMENT_TEXT_DURATION
                jsr PrintPanelText
                lda #SFX_EMP
                jsr PlaySfx
                lda #$00
                sta rechargerColor
                lda #<EP_RECHARGEREFFECT
                ldx #>EP_RECHARGEREFFECT
                jmp SetScript
UHR_Full:
UBR_Full:       rts

        ; Battery recharger script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

UseBatteryRecharger:
                lda battery+1
                cmp #MAX_BATTERY
                bcs UBR_Full
                lda #$00
                sta battery
                lda #MAX_BATTERY
                sta battery+1
                lda #<txtBatteryRecharger
                ldx #>txtBatteryRecharger
                bne Recharger_Common

        ; Recharger color effect script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RechargerEffect:
                lda rechargerColor
                inc rechargerColor
                cmp #$04
                bcs RE_End
                lsr
                bcs RE_Restore
                lda Irq1_Bg3+1
                sta Irq1_Bg1+1
                lda #$01
                sta Irq1_Bg3+1
                rts
RE_Restore:     jmp SetZoneColors
RE_End:         jmp StopScript

        ; Saboteur robot
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

CombatRobotSaboteur:
                lda #FR_ATTACK+3
                sta actF2,x
                lda #FR_STAND
                sta actF1,x
                jsr Random
                and #$08
                sta temp1
                lda actXL,x
                and #$f0
                ora temp1
                sta actXL,x
                jsr Random
                and #$1f
                clc
                adc actTime,x
                sta actTime,x
                bcc CRS_NoEffect
                lda #ACTI_FIRSTNPCBULLET
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc CRS_NoEffect
                lda #ACT_EMP
                jsr SpawnActor
                tya
                tax
                lda #8*8
                jsr MoveActorX
                lda #8*8
                jsr MoveActorY
                dec actYH,x
                lda #COLOR_FLICKER
                sta actFlash,x
                lda #8
                sta actTime,x
                lda #0
                sta actBulletDmgMod-ACTI_FIRSTPLRBULLET,x ;Make sure the EMP doesn't do actual damage to anyone
                ldx actIndex
CRS_NoEffect:   rts

        ; Saboteur robot death
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

DestroyCombatRobotSaboteur:
                lda #PLOT_LOWERLABSNOAIR        ;Make lower labs safe again
                jsr ClearPlotBit
                lda #$00
                sta ULO_NoAirFlag+1
                stx temp6
                lda #MUSIC_MYSTERY              ;Restore original music
                jsr PlaySong
                ldx temp6
                jmp ExplodeEnemy3_Ofs24

        ; Variables

rechargerColor: dc.b 0

        ; Messages

txtHealthRecharger:
                dc.b "HEALTH RESTORED",0
txtBatteryRecharger:
                dc.b "BATTERY RECHARGED",0

                checkscriptend
