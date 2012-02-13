        ; Loader depacker (ldepack algorithm)

                include Memory.s
                include Kernal.s
                include LoadSym.s

                org depackCodeStart

                dc.b #<(DepackStart-1)
                dc.b #>(DepackStart-1)
                dc.b #<(InitLoader-1)
                dc.b #>(InitLoader-1)

dpSrcLo         = $60
dpSrcHi         = $61
dpLength        = $62
dpBits          = $63

DP_NewBits:     sta dpBits
                ldx #$08
DepackStart:    jsr ChrIn                       ;Get new bitcodes/next byte
                dex                             ;(X is $ff when entered)
                bmi DP_NewBits
                lsr dpBits
                bcs DP_Store                    ;Bit is 1 -> a literal
DP_String:      tay                             ;One or two-byte string, or EOF?
                bmi DP_OneByte
                beq DP_CopyLoop+1               ;EOF, branch into an RTS
DP_TwoByte:     jsr ChrIn
DP_CalcOffsetLength:
                adc DP_Store+1
                sta dpSrcLo
                tya
                ora #$f8
                adc DP_Store+2
                sta dpSrcHi
                tya
                lsr
                lsr
                lsr
                sta dpLength
                ldy #$00
DP_CopyLoop:    lda (dpSrcLo),y                 ;Copy string / store literal
                iny                             ;shared code
                cpy dpLength
DP_Store:       sta mainCodeStart
                inc DP_Store+1
                bne DP_StoreOk
                inc DP_Store+2
DP_StoreOk:     bcc DP_CopyLoop
                bcs DepackStart
DP_OneByte:     ldy #7+2*8                      ;One byte string: fixed offset highbyte, length 2
                bne DP_CalcOffsetLength





