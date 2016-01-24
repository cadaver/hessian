                include macros.s
                include mainsym.s

        ; Script 20, old tunnels give laptop

                org scriptCodeStart

                dc.w LabComputer
                dc.w GiveLaptop2

        ; Lab computer
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

LabComputer:    lda #ACT_HACKER
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
LC_NoActor:     jsr SetupTextScreen
                lda #0
                sta temp1
                sta temp2
                gettext txtLabComputer
                jsr PrintMultipleRows
                jsr WaitForExit
                jmp CenterPlayer

        ; Jeff gives laptop after reading apocalyptic note
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

GiveLaptop2:    lda scriptVariable
                bne GiveLaptop2b
                inc scriptVariable
                gettext txtGiveLaptop2
                ldy #ACT_HACKER
                jmp SpeakLine
GiveLaptop2b:   lda #SFX_PICKUP
                jsr PlaySfx
                lda #ITEM_LAPTOP
                ldx #1
                jsr AddItem
                lda #0
                sta actScriptF+2
SEL_Wait:       rts

        ; Messages

                     ;0123456789012345678901234567890123456789
txtLabComputer: dc.b "NOTE #4",0
                dc.b " ",0
                dc.b "THE AI HAS REPURPOSED THE FIBER-OPTIC",0
                dc.b "LINK BETWEEN THE SERVER VAULT AND THE",0
                dc.b "INVENTION CHAMBER.",0
                dc.b " ",0
                dc.b "I CALL IT A 'BI-DIRECTIONAL REVENGE",0
                dc.b "PROTOCOL.' IF COMMUNICATION ON THE LINE",0
                dc.b "CEASES DUE TO EITHER JORMUNGANDR OR THE",0
                dc.b "AI BEING DISABLED, THE ONE THAT REMAINS",0
                dc.b "WILL LAUNCH ITS ATTACK.",0,0

txtGiveLaptop2: dc.b 34,"SORRY FOR SNEAKING UP ON YOU. BUT THAT IF ANY IS EVIL. TAKE THIS LAPTOP. "
                dc.b "IF YOU CAN FIND THE LINK, WE MIGHT BE ABLE TO TRICK THE PROTOCOL. THEN YOU CAN "
                dc.b "SAFELY BLAST THEM BOTH TO HELL. OF COURSE.. "
                dc.b "ANY TAMPERING COULD ALREADY TRIGGER ARMAGEDDON.",34,0

                checkscriptend
