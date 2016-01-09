                include macros.s
                include mainsym.s

        ; Script 5, laser + other interactions

                org scriptCodeStart

                dc.w SwitchGenerator
                dc.w SwitchLaser
                dc.w InstallAmplifier
                dc.w RunLaser
                dc.w MoveGenerator

        ; Switch generator script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

SwitchGenerator:lda #PLOT_GENERATOR
                jsr GetPlotBit
                bne SG_AlreadyOn
                lda #PLOT_GENERATOR
                jsr SetPlotBit
                jsr AddQuestScore
                lda #<txtGeneratorOn
                ldx #>txtGeneratorOn
                ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText
SL_Broken:
SG_AlreadyOn:   rts

        ; Switch laser script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

SwitchLaser:    lda #PLOT_GENERATOR
                jsr GetPlotBit
                beq SL_NoPower
                lda lvlObjB+$2b                 ;Wall already opened?
                bmi SL_Broken
                ldy #$0f
                jsr ToggleObject
                lda #PLOT_AMPINSTALLED
                jsr GetPlotBit
                bne SL_IsAmplified
                rts
SL_NoPower:     lda #<txtNoPower
                ldx #>txtNoPower
SL_TextCommon:  ldy #REQUIREMENT_TEXT_DURATION
                jmp PrintPanelText
SL_IsAmplified: lda #$00
                sta laserTime
                lda limitR
                sec
                sbc #10
                sta mapX
                lda #0
                sta blockX
                jsr RedrawScreen
                ldx #MENU_INTERACTION
                jsr SetMenuMode
                lda #<EP_RUNLASER
                ldx #>EP_RUNLASER
                jmp SetScript

        ; Install amplifier script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

InstallAmplifier:
                lda lvlObjB+$0e
                bpl IA_NotOpen
                lda lvlObjB+$0f
                bmi IA_IsLive
                jsr AddQuestScore
                lda #SFX_POWERUP
                jsr PlaySfx
                lda #PLOT_AMPINSTALLED
                jsr SetPlotBit
                ldy #ITEM_AMPLIFIER
                jsr RemoveItem
                lda #<txtAmpInstalled
                ldx #>txtAmpInstalled
                jmp SL_TextCommon
IA_IsLive:      lda #<txtCantInstall
                ldx #>txtCantInstall
                jsr SL_TextCommon
                lda #ACTI_FIRSTPLRBULLET
                ldy #ACTI_LASTPLRBULLET
                jsr GetFreeActor
                bcc IA_NoEffect
                tya
                tax
                lda lvlObjX+$0e
                sta actXH,x
                lda lvlObjY+$0e
                and #$7f
                sta actYH,x
                lda #$80
                sta actXL,x
                lda #$40
                sta actYL,x
                lda #ACT_EMP
                sta actT,x
                jsr InitActor
                lda #COLOR_FLICKER
                sta actFlash,x
                lda #8
                sta actTime,x
                lda #0
                sta actBulletDmgMod-ACTI_FIRSTPLRBULLET,x
                jsr NoInterpolation
IA_NoEffect:    ldx #ACTI_PLAYER
                lda #DMG_PISTOL+NOMODIFY
                jmp DamageSelf
IA_NotOpen:     rts

        ; Laser effect continuous script routine
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RunLaser:       lda #0
                sta scrollSX                    ;Prevent scrolling by player position
                inc laserTime
                lda laserTime
                cmp #80
                bcc RL_Animate
                beq RL_Explode
                cmp #110
                bcs RL_Finish
                rts
RL_Animate:     and #$01
                tay
                lda laserColorTbl,y
                sta Irq1_Bg3+1
                tya
                bne RL_NoSound
                lda #SFX_DAMAGE
                jmp PlaySfx
RL_NoSound:     jsr Random
                pha
                and #$01
                sta shakeScreen
                pla
                cmp #$80
                bcs RL_NoNewExplosion
                lda #ACTI_FIRSTNPC              ;Use any free actors for explosions
                ldy #ACTI_LASTNPCBULLET
                jsr GetFreeActor
                bcc RL_NoNewExplosion
                tya
                tax
                lda lvlObjX+$2b
                sta actXH,x
                lda lvlObjY+$2b
                and #$7f
                sta actYH,x
                jsr Random
                and #$7f
                clc
                adc #$40
                sta actXL,x
                jsr Random
                and #$3f
                sta actYL,x
                lda #ACT_EXPLOSION
                sta actT,x
                jsr InitActor
RL_NoNewExplosion:
                rts
RL_Explode:     ldy #$0f
                jsr ToggleObject
                ldy #$2b
                jsr ToggleObject
                jsr AddQuestScore
                lda #SFX_EXPLOSION
                jmp PlaySfx
RL_Finish:      jsr StopScript
                ldx #MENU_NONE
                jsr SetMenuMode
                jmp CenterPlayer

        ; Generator (screen shake) move routine
        ;
        ; Parameters: X actor number
        ; Returns: -
        ; Modifies: various

MoveGenerator:  lda #PLOT_GENERATOR
                jsr GetPlotBit
                beq MG_NotOn
                inc actFd,x
                lda actFd,x
                and #$01
                sta shakeScreen
                inc actTime,x
                lda actTime,x
                cmp #$03
                bcc MG_NoSound
                lda #SFX_GENERATOR
                jsr PlaySfx
                lda #$00
                sta actTime,x
MG_NoSound:
MG_NotOn:       rts

        ; Variables

laserTime:      dc.b 0

        ; Tables

laserColorTbl:  dc.b $0c,$0e

        ; Messages

txtGeneratorOn: dc.b "GENERATOR ON",0
txtNoPower:     dc.b "NO POWER",0
txtAmpInstalled:dc.b "AMPLIFIER INSTALLED",0
txtCantInstall: dc.b "TURN OFF TO INSTALL",0

                checkscriptend