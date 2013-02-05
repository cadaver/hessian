        ; Show bitmap mode
        ; (return to normal display by calling RedrawScreen)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X

ShowBitmap:     jsr WaitBottom
                jsr InitScroll
                lda #$02
                sta screen
                lda #$0f
                sta scrollX
                lda #$20
                sta scrollY
                lda #$00
                sta Irq1_Bg1+1
                sta Irq4_LevelUpdate+1
                tax
SB_ClearColors: sta screen1,x
                sta screen1+13*40-256,x
                sta colors,x
                sta colors+13*40-256,x
                inx
                bne SB_ClearColors
                rts

        ; Draw a picture into the bitmap
        ;
        ; Parameters: X,Y char position, zpSrcLo,Hi picture address, zpBitsLo,Hi
        ;             picture size in chars
        ; Returns: -
        ; Modifies: A,X,Y,temp regs

DrawToBitmap:   stx temp1
                iny
                iny
                iny
                lda #40
                ldx #zpDestLo
                jsr MulU
                lda temp1
                jsr Add8
                sta temp1                       ;temp1 = screen data dest address
                sta temp3                       ;temp3 = color data dest address
                lda zpDestHi
                ora #>screen1
                sta temp2
                adc #>(colors-screen1)
                sta temp4
                lda zpBitsLo
                ldy zpBitsHi
                ldx #<temp5
                jsr MulU
                lda temp5
                sta temp7
                lda temp6
                sta temp8
                ldy #$03
DB_MulLoop:     asl zpDestLo
                rol zpDestHi
                asl temp7
                rol temp8
                dey
                bne DB_MulLoop
                lda zpSrcLo
                adc temp7
                sta actLo                       ;actLo = screen data address
                lda zpSrcHi
                adc temp8
                sta actHi
                lda actLo
                adc temp5
                sta wpnLo                       ;wpnLo = color data address
                lda actHi
                adc temp6
                sta wpnHi
DB_RowLoop:     lda zpDestLo
                sta temp5                       ;temp5 = bitmap data dest address
                lda zpDestHi
                clc
                adc #>textChars
                sta temp6
                lda #$00
                sta temp7
DB_ColLoop:     ldy #$07
DB_CharLoop:    lda (zpSrcLo),y
                sta (temp5),y
                dey
                bpl DB_CharLoop
                ldy temp7
                lda (actLo),y
                sta (temp1),y
                lda (wpnLo),y
                sta (temp3),y
                ldx #<zpSrcLo
                lda #$08
                jsr Add8
                ldx #<temp5
                lda #$08
                jsr Add8
                inc temp7
                lda temp7
                cmp zpBitsLo
                bcc DB_ColLoop
                lda zpBitsLo
                ldx #actLo
                jsr Add8
                lda zpBitsLo
                ldx #wpnLo
                jsr Add8
                lda #<320
                ldy #>320
                ldx #zpDestLo
                jsr Add16Immediate
                lda #40
                ldx #temp1
                jsr Add8
                lda #40
                ldx #temp3
                jsr Add8
                dec zpBitsHi
                bne DB_RowLoop
                rts
