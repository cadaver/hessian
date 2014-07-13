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

                mac getmaprow
                lda mapTblLo,y
                sta zpSrcLo
                lda mapTblHi,y
                sta zpSrcHi
                endm
                
                mac getblockinfo
                subroutine rbi
                lda (zpSrcLo),y
                lsr
                tay
                lda blockInfo,y
                bcs .1              ;Blockinfo is packed into 4 bits per block
                and #$0f
                bcc .2
.1:             lsr
                lsr
                lsr
                lsr
.2:
                subroutine rbiend
                endm

        ; Scripting macros

                mac setscript
                lda #<{1}
                ldx #>{1}
                jsr SetScript
                endm
                
                mac stopscript
                jsr StopScript
                endm

                mac settrigger
                lda #{3}
                sta temp1
                ldy #{1}
                lda #<{2}
                ldx #>{2}
                jsr SetActorTrigger
                endm

                mac removetrigger
                ldy #{1}
                jsr RemoveActorTrigger
                endm
                
                mac speak
                ldy #{1}
                lda #<{2}
                ldx #>{2}
                jsr SpeakLine
                endm

                mac checkitem
                lda #{1}
                jsr FindItem
                endm
                
                mac additem
                lda #{1}
                lda #{2}
                jsr AddItem
                endm
                
                mac removeitem
                lda #{1}
                jsr RemoveItem
                endm

