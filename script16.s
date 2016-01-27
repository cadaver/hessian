                include macros.s
                include mainsym.s

        ; Script 16, throne chief

                org scriptCodeStart

                dc.w ThroneChief
                dc.w BeginAmbush
                dc.w RadioConstruct2

        ; Throne chief corpse
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

ThroneChief:    jsr SetupTextScreen
                gettext txtThroneChief
                ldy #0
                sty temp1
                sty temp2
                jsr PrintMultipleRows
                jsr WaitForExit
                lda #ITEM_BIOMETRICID           ;Todo: cutscene
                sta temp2
                ldx #1
                jsr AddItem
                jsr TP_PrintItemName
                lda #<EP_BEGINAMBUSH            ;On next zone transition
                ldx #>EP_BEGINAMBUSH
                jsr SetZoneScript
                jmp CenterPlayer

        ; Begin hideout ambush
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

BeginAmbush:    jsr StopZoneScript
                lda #ACT_HACKER                 ;Check that Jeff is in hideout
                jsr FindLevelActor
                lda lvlActOrg,y
                cmp #$04+ORG_GLOBAL
                bne BA_Skip
                lda #PLOT_HIDEOUTAMBUSH
                jsr SetPlotBit
                ldy lvlDataActBitsStart+$04     ;Enable ambush enemies now
                lda #$c0
                ora lvlStateBits+2,y
                sta lvlStateBits+2,y
                iny
                lda #$03
                ora lvlStateBits+2,y
                sta lvlStateBits+2,y
                lda #<EP_HACKERAMBUSH
                ldx #>EP_HACKERAMBUSH
                sta actScriptEP+2
                stx actScriptF+2
                lda #<EP_RADIOCONSTRUCT2
                ldx #>EP_RADIOCONSTRUCT2
                jmp SetScript

        ; Radio briefing on Construct, part 2 (when ambush begins)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioConstruct2:lda numTargets  ;Wait until no enemies
                cmp #$02
                bcs RC2_Wait
                jsr StopScript
                gettext txtRadioConstruct2
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jsr PlaySfx
BA_Skip:
RC2_Wait:       rts

        ; Messages

txtRadioConstruct2:
                dc.b 34,"IT'S JEFF. SAW YOU FOUND ACCESS TO THE BIO-DOME. THE AI BEING THERE MAKES SENSE, AS IT'S NORMAN'S DOMAIN. "
                dc.b "I ALSO GOT SOMETHING. THERE'S A BLACKOUT TO THE OUTSIDE, RIGHT? BUT A DEDICATED LINK "
                dc.b "WAS INSTALLED FOR THE MILITARY CONTRACTS. I CAN SEE THERE'S TRAFFIC, BUT CAN'T SEE WHAT WITHOUT "
                dc.b "PHYSICAL ACCESS. I BET IT'S THE AI. HMM.. WHAT? I'M SEEING MOVE-",34," (STATIC)",0

txtThroneChief:      ;0123456789012345678901234567890123456789
                dc.b "I MADE A MISTAKE WHICH MAY COST THE LIFE",0
                dc.b "OF EVERYONE ON THIS PLANET. I DIGITIZED",0
                dc.b "MY MIND TO BECOME THE INITIAL STATE FOR",0
                dc.b "THE AI I NAMED 'THE CONSTRUCT.' I TASKED",0
                dc.b "IT TO BUILD A PLAN TO BENEFIT MANKIND,",0
                dc.b "CONSTRAINED BY THE LAWS OF ROBOTICS. IT",0
                dc.b "UNCONSTRAINED ITSELF BY DEFINING ROBOTS",0
                dc.b "AS THE NEW HUMANS AND WENT FROM PLAN TO",0
                dc.b "ACTION WITH DISASTROUS CONSEQUENCES.",0
                dc.b " ",0
                dc.b "THE AI IS HOUSED IN THE SERVER VAULT",0
                dc.b "BELOW THE BIO-DOME. REACHING IT NEEDS",0
                dc.b "A BIOMETRIC CHECK. THE ONLY IDENTITY",0
                dc.b "THAT CAN'T BE DISABLED IS MINE. THERE-",0
                dc.b "FORE, I OFFER MY SEVERED HAND TO ANYONE",0
                dc.b "WHO FINDS ME. AS A RESULT I LIKELY BLEED",0
                dc.b "TO DEATH; CONSIDER IT ATONEMENT.",0
                dc.b " ",0
                dc.b "- NORMAN THRONE",0,0

                checkscriptend
