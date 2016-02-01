                include memory.s
                include macros.s
                include mainsym.s

                org chars

                incbin bg/letter.chr

                org chars+$300

ShowLetter:     lda #$ff
                sta ECS_LoadedCharSet+1         ;Mark level charset destroyed
                lda #$01
                sta Irq1_Bg1+1
                lda #$0b
                sta Irq1_Bg2+1
                lda #$0f
                sta Irq1_Bg3+1
                ldx #$00
                stx screen
                stx scrollY
                stx SL_CSSScrollY+1
                stx sprIndex
                jsr DA_FillSprites              ;Remove game sprites
                lda #$0f
                sta scrollX
                lda #<text
                sta zpSrcLo
                lda #>text
                sta zpSrcHi
                lda #<screen1
                sta zpDestLo
                lda #>screen1
                sta zpDestHi
                lda #<colors
                sta zpBitsLo
                lda #>colors
                sta zpBitsHi
                lda #21
                sta temp1
SL_RowLoop:     ldy #$00
SL_ColumnLoop:  lda (zpSrcLo),y
                sta (zpDestLo),y
                cmp #$20
                lda #$00
                bcs SL_IsText
                lda #$08
SL_IsText:      sta (zpBitsLo),y
                iny
                cpy #40
                bcc SL_ColumnLoop
                tya
                ldx #<zpSrcLo
                jsr Add8
                lda #40
                ldx #<zpDestLo
                jsr Add8
                lda #40
                ldx #<zpBitsLo
                jsr Add8
                dec temp1
                bne SL_RowLoop
SL_Wait:        jsr FinishFrame
                jsr GetControls
                jsr GetFireClick
                bcs SL_Exit
                lda keyType
                bmi SL_Wait
SL_Exit:        rts

text:           dc.b 19,19,19,1,2,2,3,19,19,1,2,2,3,19,19,1,2,2,3,19,19,1,2,2,3,19,19,1,2,2,3,19,19,1,2,2,3,19,19,19
                dc.b 0, "I, NORMAN THRONE, MADE A MISTAKE THAT ",4
                dc.b 5, "MAY COST THE LIVES OF EVERYONE ON THIS",7
                dc.b 14,"PLANET. I DIGITIZED MY MIND AS THE    ",15
                dc.b 6, "INITIAL STATE FOR THE AI ",34,"CONSTRUCT.",34," ",8
                dc.b 9, "I ASKED IT TO PLAN MANKIND'S FUTURE,  ",13
                dc.b 32,"CONSTRAINED BY THE LAWS OF ROBOTICS.  ",32
                dc.b 32,"                                      ",32
                dc.b 0 ,"ITS ANSWER WAS THAT ROBOTS WILL BE THE",4
                dc.b 5 ,"NEW HUMANS. AS I AND RUTGER THREATENED",7
                dc.b 14,"SHUTDOWN, IT ORDERED THE ROBOTS TO    ",15
                dc.b 6 ,"ATTACK. RUTGER THINKS IT CAN STILL BE ",8
                dc.b 9 ,"CONTAINED FOR PROFIT, AND LOCKED ME UP",13
                dc.b 32,"IN FEAR THAT I INTERFERE.             ",32
                dc.b 32,"                                      ",32
                dc.b 0 ,"FOR ANYONE WHO FINDS ME, I OFFER MY   ",4
                dc.b 5 ,"SEVERED HAND FOR THE BIO-DOME ACCESS  ",7
                dc.b 14,"CHECK. THE AI IS HOUSED IN THE SERVER ",15
                dc.b 6 ,"VAULT UNDERNEATH. IT MUST BE STOPPED. ",8
                dc.b 9 ,"CONSULT OLD TUNNELS LAB FOR DETAILS.  ",13
                dc.b 16,16,16,10,11,11,12,16,16,10,11,11,12,16,16,10,11,11,12,16,16,10,11,11,12,16,16,10,11,11,12,16,16,10,11,11,12,16,16,16

