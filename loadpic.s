                include macros.s
                include mainsym.s

                org loaderCodeEnd

                lda #<$a000
                ldx #>$a000
                jsr LoadFile                    ;Load bitmap data attached to this file
                lda #<$8c00
                ldx #>$8c00
                jsr LoadFile                    ;Load screen data
                lda #<colors
                ldx #>colors
                jsr LoadFile                    ;Load color-RAM data
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
                sta $d011                       ;Screen on
                inc fileNumber
                lda #>(InitAll-1)
                pha
                lda #<(InitAll-1)
                pha
                lda #<loaderCodeEnd
                ldx #>loaderCodeEnd
                jmp LoadFile                    ;Load mainpart
