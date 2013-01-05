                processor 6502

                mac VarBase
NEXT_VAR        set {1}
                endm

                mac Var
{1}             = NEXT_VAR
NEXT_VAR        set NEXT_VAR + 1
                endm

                mac VarRange
{1}             = NEXT_VAR
NEXT_VAR        set NEXT_VAR + {2}
                endm

                mac CheckVarBase
                if NEXT_VAR > {1}
                    err
                endif
                endm

                mac CodeStart
                if NEXT_VAR > {1}
                    err
                endif
                org {1}
                endm

        ; BIT instruction for skipping the next 1- or 2-byte instruction

                mac skip1
                dc.b $24
                endm

                mac skip2
                dc.b $2c
                endm
                
                mac CheckScriptEnd
                if * > $fffa
                    err
                endif
                endm