        ; Get the value of a plotbit
        ;
        ; Parameters: A plotbit number
        ; Returns: A nonzero if set
        ; Modifies: A,Y

GetPlotBit:     jsr DecodeBit
                and plotBits,y
                rts

        ; Set a plotbit
        ;
        ; Parameters: A plotbit number
        ; Returns: -
        ; Modifies: A,Y

SetPlotBit:     jsr DecodeBit
                ora plotBits,y
                bne CPB_Store

        ; Clear a plotbit
        ;
        ; Parameters: A plotbit number
        ; Returns: -
        ; Modifies: A,Y

ClearPlotBit:   jsr DecodeBit
                eor #$ff
                and plotBits,y
CPB_Store:      sta plotBits,y
                rts

        ; Turn a number into a byte offset into a bit-table and a bitmask
        ;
        ; Parameters: A number
        ; Returns: A bitmask, Y byte offset
        ; Modifies: A,Y

DecodeBit:      pha
                and #$07
                tay
                lda keyRowBit,y
                eor #$ff
                sta DB_Value+1
                pla
                lsr
                lsr
                lsr
                tay
DB_Value:       lda #$00
CL_Done:        rts