                include macros.s
                include mainsym.s

        ; Script 20, old tunnels computers + give laptop

                org scriptCodeStart

                dc.w LabComputer4
                dc.w GiveLaptop2
                dc.w LabComputer1
                dc.w LabComputer2
                dc.w LabComputer3
                dc.w HackerFinal

        ; Lab computer note #4
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

LabComputer4:   lda #ACT_HACKER
                jsr FindLevelActor
                bcc LC_NoActor
                lda lvlActOrg,y
                cmp #$0f+ORG_GLOBAL
                bne LC_NoActor
                lda lvlActX,y
                cmp #$70
                bne LC_NoActor
                lda #$88
                sta lvlActX,y
                lda #$48
                sta lvlActY,y
                lda #$10+AIMODE_TURNTO
                sta lvlActF,y
                lda #<EP_GIVELAPTOP2
                ldx #>EP_GIVELAPTOP2
                sta actScriptEP+2
                stx actScriptF+2
                lda #$00
                sta scriptVariable
LC_NoActor:     gettext txtNote4
DisplayCommon:  jsr SetupTextScreen
                ldy #0
                sty temp1
                sty temp2
                jsr PrintMultipleRows
                jsr WaitForExit
                jmp CenterPlayer

        ; Lab computer note #1
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

LabComputer1:   lda codes+6*3+2
                ora #$30
                sta txtNumber3
                gettext txtNote1
                bne DisplayCommon

        ; Lab computer note #2
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

LabComputer2:   gettext txtNote2
                bne DisplayCommon

        ; Lab computer note #3
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

LabComputer3:   gettext txtNote3
                bne DisplayCommon

        ; Jeff gives laptop after reading apocalyptic note
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

GiveLaptop2:    lda scriptVariable
                bne GiveLaptop2b
                inc scriptVariable
                gettext txtGiveLaptop2
H_SpeakCommon:  ldy #ACT_HACKER
                jmp SpeakLine
GiveLaptop2b:   lda #SFX_PICKUP
                jsr PlaySfx
                lda #ITEM_LAPTOP
                ldx #1
                jsr AddItem
                lda #0
                sta actScriptF+2
HF_TooFar:
SEL_Wait:       rts

        ; Jeff interaction if return to lab after installing laptop
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerFinal:    lda actXH+ACTI_PLAYER
                cmp #$84
                bcc HF_TooFar
                jsr AddQuestScore
                lda #$00
                sta actScriptF+2
                gettext txtHackerFinal
                bne H_SpeakCommon

        ; Messages

                     ;0123456789012345678901234567890123456789
txtNote1:       dc.b "NOTE #1",0
                dc.b " ",0
                dc.b "SUCCESS: THE AI MATRIX IS STABLE AND",0
                dc.b "CAPABLE OF COHERENT THOUGHT.",0
                dc.b " ",0
                dc.b "TO NOT FORGET, THE THIRD NUMBER FOR THE",0
                dc.b "SUITE LAB: "
txtNumber3:     dc.b "X. SIMULATIONS WERE PROMISING",0
                dc.b "BUT ONLY A LIVE TEST CAN FULLY CONFIRM.",0
                dc.b "TOO BAD IT'S TOO LATE FOR THE CONTRACT.",0
                textjump txtNormanSignature

txtNote2:            ;0123456789012345678901234567890123456789
                dc.b "NOTE #2",0
                dc.b " ",0
                dc.b "I HAVE GIVEN THE AI FREE REIGN OF THE",0
                dc.b "NETHER TUNNEL AND THE INVENTION CHAMBER.",0
                dc.b "MEANWHILE THIS LAB IS SHIELDED FROM IT",0
                dc.b "AS A SECURITY PRECAUTION.",0
                dc.b " ",0
                dc.b "I GAVE IT A QUESTION TO PONDER: HOW TO",0
                dc.b "FUTURE-PROOF MANKIND?",0
                textjump txtNormanSignature

txtNote3:            ;0123456789012345678901234567890123456789
                dc.b "NOTE #3",0
                dc.b " ",0
                dc.b "SETBACK! THE AI REDEFINED ROBOTS AS THE",0
                dc.b "'NEW HUMANS' THAT SHALL INHERIT EARTH.",0
                dc.b "IT HAS BEGUN TO CONSTRUCT SOMETHING, BUT",0
                dc.b "REFUSES TO EXPLAIN IT TO ME.",0
                dc.b " ",0
                dc.b "ADDENDUM: IT'S CALLED 'JORMUNGANDR.' A",0
                dc.b "HUGE BURROWING MACHINE.",0
                dc.b " ",0
                dc.b "LUCKILY THE PLUG CAN BE PULLED AT ANY",0
                dc.b "MOMENT.",0
                textjump txtNormanSignature

                     ;0123456789012345678901234567890123456789
txtNote4:       dc.b "NOTE #4",0
                dc.b " ",0
                dc.b "THE AI HAS REPURPOSED THE FIBER-OPTIC",0
                dc.b "LINK BETWEEN THE SERVER VAULT AND THE",0
                dc.b "INVENTION CHAMBER.",0
                dc.b " ",0
                dc.b "I CALL IT A 'BI-DIRECTIONAL REVENGE",0
                dc.b "PROTOCOL.' IF COMMUNICATION CEASES DUE",0
                dc.b "TO EITHER JORMUNGANDR OR THE AI BEING",0
                dc.b "DISABLED, THE ONE THAT REMAINS LAUNCHES",0
                dc.b "ITS ATTACK.",0
                dc.b " ",0
                dc.b "IT'S ALSO TAKEN CONTROL OF THE MILITARY",0
                dc.b "LINE. I NEED TO CONTACT RUTGER URGENTLY.",0
txtNormanSignature:
                dc.b " ",0
                dc.b "- NORMAN",0,0

txtGiveLaptop2: dc.b 34,"SORRY FOR SNEAKING UP ON YOU. BUT THAT IF ANY IS EVIL. TAKE THIS LAPTOP. "
                dc.b "IF YOU CAN FIND THE LINK, WE MIGHT BE ABLE TO TRICK THE PROTOCOL. THEN YOU CAN "
                dc.b "SAFELY BLAST THEM BOTH TO HELL. OF COURSE.. "
                dc.b "ANY TAMPERING COULD ALREADY TRIGGER ARMAGEDDON.",34,0

txtHackerFinal: dc.b 34,"HEY. YOU SHOULD BE KICKING JORMUNGANDR AND CONSTRUCT ASS, AS I'VE NO WORRIES HERE. WELL, "
                dc.b "EXCEPT WHETHER YOU'LL RETURN ALIVE. TRY TO DO THAT, OK?",34,0

                checkscriptend
