                processor 6502

                mac varbase
NEXT_VAR        set {1}
                endm

                mac var
{1}             = NEXT_VAR
NEXT_VAR        set NEXT_VAR + 1
                endm

                mac varrange
{1}             = NEXT_VAR
NEXT_VAR        set NEXT_VAR + {2}
                endm

                mac checkvarbase
                if NEXT_VAR > {1}
                    err
                endif
                endm

        ; BIT instruction for skipping the next 1- or 2-byte instruction

                mac skip1
                dc.b $24
                endm

                mac skip2
                dc.b $2c
                endm

                mac checkscriptend
                if * > scriptCodeEnd
                    err
                endif
                endm

        ; Text jump. Game texts need to be located between $0000-$7fff to use

                mac textjump
                dc.b >{1} | $80
                dc.b <{1}
                endm

        ; Get text resource address

                mac gettext
                lda #{1}+C_TEXT00
                ldx #{2}
                jsr GetTextAddress
                endm
