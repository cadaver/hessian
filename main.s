SHOW_ACTOR_RASTERTIME = 0
SHOW_SPRITE_RASTERTIME = 0
SHOW_SPRITEIRQ_RASTERTIME = 0
SHOW_SCROLL_RASTERTIME = 0
SHOW_MUSIC_RASTERTIME = 0

SCRCENTER_X     = 19
SCRCENTER_Y     = 13
NUMEXTRAACTORS  = 22

        ; Memory configuration & loader symbols

                include memory.s
                include loadsym.s

                org loaderCodeEnd

Start:          jmp InitAll

        ; Memory alignment of raster interrupt code is critical, so include first

                include raster.s

        ; Test mainloop, will be removed


Main:           lda #0
                jsr LoadLevel
                ldx #0
                ldy #0
                jsr SetMapPos
                jsr RedrawScreen
                jsr UpdateFrame

                lda #0
                jsr LoadMusic
                lda #0
                jsr InitMusic

                lda #6
                sta actXH
                lda #$80
                sta actXL
                lda #4
                sta actYH
                lda #ACT_PLAYER
                sta actType

                ldx #NUMEXTRAACTORS-1
ActLoop:        txa
                and #$07
                clc
                adc #6
                sta actXH+1,x
                txa
                lsr
                lsr
                lsr
                clc
                adc #4
                sta actYH+1,x
                lda #ACT_EXPLOSION
                sta actType+1,x
                txa
                ror
                ror
                and #$80
                ora #$40
                ;sta actC+1,x
                lda #1
                sta actF1+1,x
                dex
                bpl ActLoop

MainLoop:       jsr ScrollLogic
                jsr DrawActors
                jsr ScrollPlayer
                jsr UpdateFrame
                jsr GetControls
                jsr ScrollLogic
                jsr MovePlayer
                jsr Animate
                jsr InterpolateActors
                jsr UpdateFrame
                jsr GetFireClick
                bcc MainLoop

                jsr ShowTextScreen

TextLoop:       jsr WaitBottom
                jsr GetControls
                jsr GetFireClick
                bcc TextLoop

                jsr SetZoneColors
                jmp MainLoop

Animate:        ldx #NUMEXTRAACTORS-1
AnimLoop:       lda actF1+1,x
                clc
                adc #1
                cmp #5
                bcc AnimOk
                lda #0
AnimOk:         sta actF1+1,x
                dex
                bpl AnimLoop
                rts

MovePlayer:     ldx #$00
                lda joystick
                and #JOY_LEFT
                beq MP_NotLeft
                lda #-4*8
                jsr MoveActorX
MP_NotLeft:     lda joystick
                and #JOY_RIGHT
                beq MP_NotRight
                lda #4*8
                jsr MoveActorX
MP_NotRight:    lda joystick
                and #JOY_UP
                beq MP_NotUp
                lda #-4*8
                jsr MoveActorY
MP_NotUp:       lda joystick
                and #JOY_DOWN
                beq MP_NotDown
                lda #4*8
                jsr MoveActorY
MP_NotDown:     rts

ScrollPlayer:   ldx #$00
                jsr GetActorCharCoords
                sta temp1
                sty temp2
                ldx #0
                ldy #0
                lda temp1
                cmp #SCRCENTER_X-3
                bcs SP_NotLeft1
                dex
SP_NotLeft1:    cmp #SCRCENTER_X-1
                bcs SP_NotLeft2
                dex
SP_NotLeft2:    cmp #SCRCENTER_X+2
                bcc SP_NotRight1
                inx
SP_NotRight1:   cmp #SCRCENTER_X+4
                bcc SP_NotRight2
                inx
SP_NotRight2:   lda temp2
                cmp #SCRCENTER_Y-3
                bcs SP_NotUp1
                dey
SP_NotUp1:      cmp #SCRCENTER_Y-1
                bcs SP_NotUp2
                dey
SP_NotUp2:      cmp #SCRCENTER_Y+2
                bcc SP_NotDown1
                iny
SP_NotDown1:    cmp #SCRCENTER_Y+4
                bcc SP_NotDown2
                iny
SP_NotDown2:    stx scrollSX
                sty scrollSY
                rts

        ; Include rest of the code & data

                include sound.s
                include input.s
                include math.s
                include file.s
                include sprite.s
                include screen.s
                include actor.s
                include level.s
                include actordata.s
                include data.s
        
        ; Disposable init part

                include init.s
