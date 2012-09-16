PANEL_TEXT_SIZE = 22

        ; Update scorepanel each frame
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,loader temp vars

UpdatePanel:    lda actHp+ACTI_PLAYER
                cmp displayedHealth
                beq UP_HealthDone
                bcs UP_IncrementHealth
UP_DecrementHealth:
                dec displayedHealth
                bpl UP_RedrawHealth
UP_IncrementHealth:
                inc displayedHealth
UP_RedrawHealth:ldx #$00
                lda displayedHealth
                lsr
                lsr
                beq UP_NoWholeChars
                sta zpSrcLo
                lda #$10
UP_WholeCharsLoop:
                sta screen1+SCROLLROWS*40+41,x
                inx
                cpx zpSrcLo
                bcc UP_WholeCharsLoop
UP_NoWholeChars:lda displayedHealth
                and #$03
                beq UP_NoHalfChar
                clc
                adc #$0c
                sta screen1+SCROLLROWS*40+41,x
                inx
UP_NoHalfChar:  lda #$20
                bne UP_EmptyCharsCmp
UP_EmptyCharsLoop:
                sta screen1+SCROLLROWS*40+41,x
                inx
UP_EmptyCharsCmp:
                cpx #HP_PLAYER/4
                bcc UP_EmptyCharsLoop
UP_HealthDone:  lda panelTextTime
                beq UP_TextDone
                dec panelTextTime
                beq UP_UpdateText
UP_TextDone:    rts
UP_UpdateText:  ldx #$00
UP_ContinueText:ldy #$00
                lda panelTextHi
                beq UP_ClearEndOfLine
                sta zpSrcHi
                lda panelTextLo
                sta zpSrcLo
                lda (zpSrcLo),y
                beq UP_ClearEndOfLine
UP_BeginLine:   lda panelTextDelay
                asl
                sta panelTextTime
UP_PrintTextLoop:
                sty zpBitsHi
                lda #$00
                sta zpBitsLo
UP_ScanWordLoop:lda (zpSrcLo),y
                beq UP_ScanWordDone
                cmp #$20
                beq UP_ScanWordDone
                cmp #"-"
                beq UP_ScanWordDone2
                inc zpBitsLo
                iny
                bne UP_ScanWordLoop
UP_ScanWordDone2:
                inc zpBitsLo
UP_ScanWordDone:ldy zpBitsHi
                txa
                clc
                adc zpBitsLo
                sta UP_WordCmp+1
                cmp #PANEL_TEXT_SIZE+1
                bcc UP_WordCmp
UP_EndLine:     stx zpBitBuf
                tya
                clc
                adc zpSrcLo
                sta panelTextLo
                lda zpSrcHi
                adc #$00
                sta panelTextHi
                cpx #PANEL_TEXT_SIZE
                bcs UP_PrintTextDone
UP_ClearEndOfLine:
                lda #$20
UP_ClearLoop:   sta screen1+SCROLLROWS*40+40+9,x
                inx
                cpx #PANEL_TEXT_SIZE
                bcc UP_ClearLoop
UP_PrintTextDone:
                rts
UP_WordLoop:    lda (zpSrcLo),y
                sta screen1+SCROLLROWS*40+40+9,x
                inx
                iny
UP_WordCmp:     cpx #$00
                bcc UP_WordLoop
UP_SpaceLoop:   lda (zpSrcLo),y
                beq UP_EndLine
                cmp #$20
                bne UP_SpaceLoopDone
                cpx #PANEL_TEXT_SIZE
                bcs UP_SpaceSkip
                sta screen1+SCROLLROWS*40+40+9,x
                inx
UP_SpaceSkip:   iny
                bne UP_SpaceLoop
UP_SpaceLoopDone:
                cpx #PANEL_TEXT_SIZE
                bcc UP_PrintTextLoop
                bcs UP_EndLine

        ; Show text on panel, possibly multi-line
        ;
        ; Parameters: A,X text address, Y delay in game logic frames (25 = 1 sec)
        ; Returns: -
        ; Modifies: A
        
ShowPanelText:  sty panelTextDelay
SetTextPtr:     sta panelTextLo
                stx panelTextHi
                jmp UP_UpdateText

        ; Show continued panel text. Should be called immediately after printing
        ; the beginning part.
        ;
        ; Parameters: A,X text address, Y delay in game logic frames (25 = 1 sec)
        ; Returns: -
        ; Modifies: A
        
ContinueText:   sty panelTextDelay
                sta panelTextLo
                stx panelTextHi
                ldx zpBitBuf
                jmp UP_ContinueText


        ; Clear the panel text
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X

ClearPanelText: ldx #$00
                beq SetTextPtr
