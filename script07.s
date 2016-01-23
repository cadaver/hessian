                include macros.s
                include mainsym.s

        ; Script 7, rechargers

                org scriptCodeStart

                dc.w UseHealthRecharger
                dc.w UseBatteryRecharger
                dc.w RechargerEffect

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

        ; Variables

rechargerColor: dc.b 0

        ; Messages

txtHealthRecharger:
                dc.b "HEALTH RESTORED",0
txtBatteryRecharger:
                dc.b "BATTERY RECHARGED",0

                checkscriptend
