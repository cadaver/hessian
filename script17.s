                include macros.s
                include mainsym.s

        ; Script 17, begin surgery

                org scriptCodeStart

                dc.w BeginSurgery
                dc.w BeginSurgery2

        ; Begin surgery script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BeginSurgery:   ldy #C_SCIENTIST
                jsr EnsureSpriteFile
                ldy #ITEM_LUNGFILTER
                jsr FindItem
                bcc BS_NoFilter
                lda actXH+ACTI_PLAYER
                cmp #$44
                bcs BS_NoFilter
                jsr AddQuestScore
                lda #<EP_BEGINSURGERY2
                sta actScriptEP
                lda #$00
                sta scriptVariable
                ldy #ACT_SCIENTIST2
                gettext txtBeginSurgery1
                jmp SpeakLine

        ; Begin surgery script, part 2
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BeginSurgery2:  lda actXH+ACTI_PLAYER
                cmp #$41
                bcs BS2_NotYet
                lda actMB+ACTI_PLAYER
                lsr
                bcc BS2_NotYet
                lda scriptVariable
                asl
                tay
                lda bs2JumpTbl,y
                sta BS2_Jump+1
                lda bs2JumpTbl+1,y
                sta BS2_Jump+2
BS2_Jump:       jmp BS2_1

BS2_1:          inc scriptVariable
                ldy #ACT_SCIENTIST2
                gettext txtBeginSurgery2
                jmp SpeakLine

BS2_2:          lda #$00                    ;Disabled controls during the delay to simplify scripting
                sta joystick
                lda #ACT_SCIENTIST3
                jsr FindActor
                lda #AIMODE_IDLE
                sta actAIMode,x
                lda #$80
                sta actD,x
                inc actTime,x
                lda actTime,x
                cmp #25
                bcc BS2_2Wait
                lda #$00
                sta actTime,x
                inc scriptVariable
BS2_NotYet:
BS_NoFilter:
BS2_2Wait:      rts

BS2_3:          inc scriptVariable
                lda #ACT_SCIENTIST3
                jsr FindActor
                lda #AIMODE_TURNTO
                sta actAIMode,x
                lda #ITEM_EMPGENERATOR
                sta actWpn,x
                lda #SFX_OBJECT
                jsr PlaySfx
                ldy #ACT_SCIENTIST3
                gettext txtBeginSurgery3
                jmp SpeakLine

BS2_4:          jsr BlankScreen
                lda #<EP_AFTERSURGERY
                sta actScriptEP+1
                lda #>EP_AFTERSURGERY
                sta actScriptF+1
                lda #0
                sta actScriptF
                lda #<EP_AFTERSURGERYRUN
                ldx #>EP_AFTERSURGERYRUN
                jsr SetScript
                lda #50
                sta scriptVariable
BS2_Delay:      jsr WaitBottom
                dec scriptVariable
                bne BS2_Delay
                jmp CenterPlayer

bs2JumpTbl:     dc.w BS2_1
                dc.w BS2_2
                dc.w BS2_3
                dc.w BS2_4

        ; Messages

txtBeginSurgery1:
                dc.b 34,"YOU GOT THE FILTER? EXCELLENT. WE'RE READY, FOR REAL THIS TIME. THIS IS A STANDARD NANO-ASSISTED "
                dc.b "PROCEDURE WITH SOME RISK INVOLVED. THE TUNNELS BELOW SHOULD BE SURVIVABLE AFTER. "
                dc.b "STEP TO THE OPERATING TABLE WHEN YOU WISH TO PROCEED.",34,0

txtBeginSurgery2:
                dc.b 34,"GOOD. WE WILL BEGIN. LINDA, JUST IN CASE WE GET COMPANY, THERE SHOULD BE A WEAPON IN THE CUPBOARD.",34,0

txtBeginSurgery3:
                dc.b 34,"GOT IT.",34,0

                checkscriptend
