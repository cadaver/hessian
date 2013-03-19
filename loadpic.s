                include memory.s
                include loadsym.s

                org loadPicStart

                incbin loadpic.raw

                org loadPicCodeStart

                ldx #$00
CopyScreenColors:
                lda loadPicStart+$2000,x
                sta $8c00,x
                lda loadPicStart+$2100,x
                sta $8d00,x
                lda loadPicStart+$2200,x
                sta $8e00,x
                lda loadPicStart+$2300,x
                sta $8f00,x
                lda loadPicStart+$2400,x
                sta colors,x
                lda loadPicStart+$2500,x
                sta colors+$100,x
                lda loadPicStart+$2600,x
                sta colors+$200,x
                lda loadPicStart+$2700,x
                sta colors+$300,x
                inx
                bne CopyScreenColors
                lda #$00
                sta $d021
                lda $dd00
                and #$fc
                ora #$01
                sta $dd00
                lda #$38
                sta $d018
                lda #$18
                sta $d016
                jsr WaitBottom
                lda #$3b
                sta $d011
                rts
