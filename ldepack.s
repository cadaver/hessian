        ; Loader depacker (ldepack algorithm)

                include memory.s
                include kernal.s
                include loadsym.s

dpSrcLo         = $fc
dpSrcHi         = $fd
dpLength        = $fe
dpBits          = $ff

                org $0801

line1:          dc.w line2
                dc.w 0
                dc.b $8f," HOLD SPACE OR FIRE ON START TO",0

line2:          dc.w line3
                dc.w 1
                dc.b $8f," DISABLE FASTLOADER (SAFE MODE)",0

line3:          dc.w line4
                dc.w 2
                dc.b $9e," 2136",0

line4:          dc.b 0,0

                org $0858

                ldx #depackCodeEnd-depackCodeStart-1
CopyCodeLoop:   lda depackCodeStart,x
                sta $0100,x
                dex
                bpl CopyCodeLoop
                txs
                rts                             ;RTS into the depacker

depackCodeStart:

                rorg $0100

                dc.b #<(DepackStart-1)
                dc.b #>(DepackStart-1)
                dc.b #<(InitLoader-1)
                dc.b #>(InitLoader-1)

DP_NewBits:     sta dpBits
                ldx #$08
DepackStart:    jsr DP_Get                      ;Get new bitcodes/next byte
                dex                             ;X is 0 on first entry
                bmi DP_NewBits
                lsr dpBits
                bcs DP_Store                    ;Bit is 1 -> a literal
DP_String:      tay                             ;One or two-byte string, or EOF?
                bmi DP_OneByte
                beq DP_GetDone                  ;RTS into the loader init
DP_TwoByte:     jsr DP_Get
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

DP_Get:         lda packedData
                inc DP_Get+1
                bne DP_GetDone
                inc DP_Get+2
DP_GetDone:     rts
                rend

depackCodeEnd:

packedData:     incbin loader.pak
