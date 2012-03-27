SHOW_FREE_RASTERTIME = 0
REDUCE_CONTROL_LATENCY = 1

SCRCENTER_X     = 19
SCRCENTER_Y     = 13

        ; Memory configuration & loader symbols

                include memory.s
                include loadsym.s

                org loaderCodeEnd

        ; Memory alignment of raster interrupt code is critical, so include first

                include raster.s
                include sound.s
                include input.s
                include math.s
                include file.s
                include sprite.s
                include screen.s
                include level.s
                include actor.s
                include physics.s
                include player.s
                include weapon.s

        ; Test initialization code, will be removed

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
CreatePlayer:   lda #6
                sta actXH
                lda #$80
                sta actXL
                lda #4
                sta actYH
                lda #ACT_PLAYER
                sta actT
                lda #WPN_PISTOL
                sta actWpn

MainLoop:       jsr ScrollLogic
                jsr DrawActors
                jsr ScrollPlayer
                jsr UpdateFrame
                jsr ScrollLogic
                jsr GetControls
                jsr UpdateActors
                jsr InterpolateActors
                jsr ScrollPlayer
                jsr UpdateFrame
                jmp MainLoop

                include actordata.s
                include weapondata.s
                include data.s

        ; Disposable init part

                include init.s
