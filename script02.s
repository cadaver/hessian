                include macros.s
                include mainsym.s

        ; Script 2, parking garage conversation

                org scriptCodeStart

                dc.w Scientist2
                dc.w GarageComputer

        ; Scientist 2 conversation
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

Scientist2:     ldy #C_SCIENTIST                ;Ensure sprite file on the same frame as first script exec
                jsr EnsureSpriteFile
                lda actXH+ACTI_PLAYER           ;Wait until player close enough
                cmp #$37
                bcc S2_Wait
                cmp #$3c
                bcs S2_Wait
                lda actYH+ACTI_PLAYER
                cmp #$29
                bcs S2_Wait
                lda actMB+ACTI_PLAYER
                lsr
                bcc S2_Wait
                lda scriptVariable
                asl
                tay
                lda S2_JumpTbl,y
                sta S2_Jump+1
                lda S2_JumpTbl+1,y
                sta S2_Jump+2
S2_Jump:        jmp $0000
S2_Wait:        rts

S2_JumpTbl:     dc.w S2_Dialogue1
                dc.w S2_Dialogue2
                dc.w S2_Dialogue3
                dc.w S2_Dialogue4

S2_Dialogue1:   jsr AddQuestScore
                inc scriptVariable
                ldy lvlDataActBitsStart+$04
                lda lvlStateBits,y              ;Enable rotordrone now
                ora #$04
                sta lvlStateBits,y
                ldy #ACT_SCIENTIST2
                gettext txtParkingGarage1
                jmp SpeakLine

S2_Dialogue2:   inc scriptVariable
                ldy #ACT_SCIENTIST3
                gettext txtParkingGarage2
                jmp SpeakLine

S2_Dialogue3:   inc scriptVariable
                ldy #ACT_SCIENTIST2
                gettext txtParkingGarage3
                jmp SpeakLine

S2_Dialogue4:   lda #ITEM_COMMGEAR
                ldx #1
                jsr AddItem
                ldx actIndex
                lda #$00
                sta temp4
                lda #ITEM_SECURITYPASS
                jsr DI_ItemNumber
                lda actD,x
                asl
                lda #$7f
                adc #$00
                ldx temp8
                jsr MoveActorX                  ;Move item to scientist's facing direction
                lda #-16*8
                jsr MoveActorY
                lda #SFX_PICKUP
                jsr PlaySfx
                lda #$00
                sta actScriptF                  ;No more script exec here
                ldy #ACT_SCIENTIST2
                gettext txtParkingGarage4
                jmp SpeakLine

        ; Computer in garage script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

GarageComputer: jsr SetupTextScreen
                gettext txtGarageComputer
                ldy #0
                sty temp1
                sty temp2
                jsr PrintMultipleRows
                jsr WaitForExit
                jmp CenterPlayer

        ; Note: reordered to compress better
        
txtParkingGarage4:
                dc.b 34,"GOOD LUCK.",34,0

txtParkingGarage2:
                dc.b 34,"COMMON SENSE WOULD DICTATE WE ATTEMPT TO ESCAPE. BUT THESE MACHINES' HIGHLY COORDINATED ACTIONS "
                dc.b "SUGGEST A CENTRAL AI, WHICH I DIDN'T KNOW WE HAD DEVELOPED. "
                dc.b "THERE MAY BE MORE THAN OUR LIVES AT STAKE.",34,0

txtParkingGarage1:
                dc.b 34,"I SEE VIKTOR DIDN'T MAKE IT. BUT YOU DID, THAT'S WHAT COUNTS. AMOS, NANOSURGEON. SHE'S LINDA, CYBER-PSYCHOLOGIST. "
                dc.b "YOU'VE SEEN HOW OUR CREATIONS HAVE TURNED ON US. TOTAL INTERNET AND PHONE BLACKOUT. WE'RE STUCK AND HELP IS UNLIKELY. "
                dc.b "AS THE ONLY ENHANCED PERSON IN THIS ROOM, RIGHT NOW YOU'RE OUR BEST BET.",34,0

txtParkingGarage3:
                dc.b 34,"YES. WE MUST FIND OUT THEIR ULTIMATE AIM BEYOND JUST KILLING EVERYONE. "
                dc.b "TAKE THIS SECURITY PASS TO ACCESS THE UPPER LABS, PLUS A WIRELESS CAMERA/RADIO "
                dc.b "SET SO WE CAN STAY IN TOUCH.",34,0

txtGarageComputer:
                     ;0123456789012345678901234567890123456789
                dc.b "SEQUENCE OF EVENTS:",0
                dc.b " ",0
                dc.b "1. 'HESSIAN' PROJECT CANCELLED",0
                dc.b "2. NORMAN THRONE GOES MISSING",0
                dc.b "3. ???",0
                dc.b "4. MACHINES OUT OF CONTROL, KILLING",0
                dc.b "   EVERYONE",0,0

                checkscriptend
