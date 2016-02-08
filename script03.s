                include macros.s
                include mainsym.s

        ; Script 3, entrance texts, right side
        
                org scriptCodeStart

                dc.w RadioUpperLabsEntrance
                dc.w OfficeComputer5
                dc.w ITComputer
                dc.w ScreenSaverEffect

        ; Radio speech for upper labs entrance
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

RadioUpperLabsEntrance:
                ldy #ITEM_SECURITYPASS
                jsr FindItem
                bcc RULI_NoPass
                gettext txtRadioUpperLabs
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx
RULI_NoPass:    ldy lvlObjNum
                jmp InactivateObject            ;Retry later to check for pass

ITComputer:     gettext txtITComputer
                bne DisplayCommon
DisplayCommon:  ldy #0
                sty temp1
                sty temp2
                jsr SetupTextScreen
                jsr PrintMultipleRows
                jsr WaitForExit
                jmp CenterPlayer

OfficeComputer5:gettext txtOfficeComputer5
                bne DisplayCommon

        ; Screensaver effect
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

NUMCHARS = 40

ScreenSaverEffect:
                jsr SetupTextScreen
                ldx #NUMCHARS-1
                stx charPos+NUMCHARS
SSE_Randomize:  jsr Random
                and #$3f
                cmp #SCROLLROWS-1
                bcs SSE_Randomize
                cmp charPos+1,x
                beq SSE_Randomize               ;Avoid same pos. as previous
                sta charPos,x
                dex
                bpl SSE_Randomize
SSE_Loop:       ldx #$00
SSE_FadeColors: lda #$00
                sta $d07a                       ;SCPU to slow mode
                sta $d030                       ;C128 back to 1MHz mode
                lda colors,x                    ;(keep effect speed consistent)
                jsr SSE_Fade
                sta colors,x
                lda colors+210,x
                jsr SSE_Fade
                sta colors+210,x
                lda colors+420,x
                jsr SSE_Fade
                sta colors+420,x
                lda colors+630,x
                jsr SSE_Fade
                sta colors+630,x
                inx
                cpx #210
                bcc SSE_FadeColors
                lda #NUMCHARS-1
                sta temp1
SSE_CharLoop:   ldx temp1
                lda charPos,x
                clc
                adc #$01
                cmp #SCROLLROWS-1
                bcc SSE_NotOver
                lda #$00
SSE_NotOver:    sta charPos,x
                tay
                jsr GetRowAddress
                lda zpDestLo
                sta zpBitsLo
                lda zpDestHi
                and #$03
                ora #>colors
                sta zpBitsHi
                jsr Random
                and #$1f
                clc
                adc #$30
                ldy temp1
                sta (zpDestLo),y
                lda #$01
                sta (zpBitsLo),y
                dec temp1
                bpl SSE_CharLoop
                jsr FinishFrame
                jsr GetControls
                jsr GetFireClick
                bcs SSE_Exit
                lda keyType
                bpl SSE_Exit
                jmp SSE_Loop
SSE_Exit:       jmp CenterPlayer

SSE_Fade:       and #$0f
                beq SSE_NoFade
                ldy #$06
                cmp #$05
                beq SSE_FadeRandom
                ldy #$00
                cmp #$06
                beq SSE_FadeRandom
SSE_FadeToGreen:lda #$05
SSE_NoFade:     rts
SSE_FadeRandom: pha
                jsr Random
                cmp #$40
                pla
                bcs SSE_NoFade
                tya
                rts

        ; Messages

txtRadioUpperLabs:
                dc.b 34,"AMOS HERE. YOU'RE CLOSE TO THE UPPER LABS. SEE IF YOU CAN FIND ANY CLUES. "
                dc.b "IF NOT, YOU'LL HAVE TO PUSH ON TO THE HIGH-CLEARANCE LOWER LABS. "
                dc.b "ALSO LOOK FOR CODE-LOCKED ROOMS, WHICH WERE USED FOR NANOBOT RESEARCH AS PART "
                dc.b "OF THE 'HESSIAN' MILITARY CONTRACT. FIND THE ENTRY CODES, AND YOU CAN UPGRADE "
                dc.b "YOUR ABILITIES. UPGRADES WILL CONSUME MORE POWER, THOUGH.",34,0

txtOfficeComputer5:
                     ;0123456789012345678901234567890123456789
                dc.b "RE: INSUBORDINATION",0
                dc.b " ",0
                dc.b "GORMAN, I SUGGEST TO KEEP A CLOSE EYE ON",0
                dc.b "OUR IT LEAD. I DON'T DOUBT HIS SKILLS",0
                dc.b "BUT HE HAS PARANOID TENDENCIES AND LACKS",0
                dc.b "DISCRETION. EXAMPLE: WHEN THE MILITARY",0
                dc.b "NETWORK LINK WAS INSTALLED, HE EMAILED",0
                dc.b "EVERYONE. THE PLAN WAS TO KEEP IT ON A",0
                dc.b "'NEED TO KNOW' BASIS.",0
                dc.b " ",0
                dc.b "--",0
                dc.b "RUTGER THRONE",0
                dc.b "HEAD OF SECURITY",0,0

txtITComputer:
                     ;0123456789012345678901234567890123456789
                dc.b "OK, THIS IS IT. I'M RELOCATING TO THE",0
                dc.b "SERVICE TUNNELS HIDEOUT, EFFECTIVE",0
                dc.b "IMMEDIATELY.",0
                dc.b " ",0
                dc.b "- NORMAN IS MISSING FOR WEEKS NOW",0
                dc.b "- BURSTS OF ENCRYPTED TRAFFIC WHILE NO-",0
                dc.b "  ONE SHOULD HAVE BEEN WORKING",0
                dc.b "- PERIODIC SHORT NETWORK OUTAGES CAUSED",0
                dc.b "  BY ROUTER OVERLOAD, ORIGIN INSIDE THE",0
                dc.b "  COMPLEX",0
                dc.b " ",0
                dc.b "ANYONE WHO REALLY NEEDS TO SEE ME SHOULD",0
                dc.b "KNOW THE WAY. BOTTOM FLOOR, FAR LEFT.",0
                dc.b "I WILL PUT THE ROTORDRONE ON GUARD, SO",0
                dc.b "WATCH OUT. IT SHOOTS LIVE ROUNDS.",0
                dc.b " ",0
                dc.b "- JEFF",0,0

charPos:
                checkscriptend

