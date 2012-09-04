SHOW_FREE_RASTERTIME = 0
REDUCE_CONTROL_LATENCY = 1

        ; Memory configuration & loader symbols

                include memory.s
                include loadsym.s

                org loaderCodeEnd

        ; Entry point. Jump to disposable init
        
                jmp InitAll

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
                include bullet.s

        ; Test initialization code, will be removed

Main:           ldy #C_COMMON                   ;Load the always resident sprites
                jsr LoadSpriteFile
                ldy #C_WEAPON
                jsr LoadSpriteFile
                lda #0
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

                lda #7
                sta actXH+1
                lda #$80
                sta actXL+1
                lda #4
                sta actYH+1
                lda #ACT_INACTIVEPLAYER
                sta actT+1
                lda #WPN_PISTOL
                sta actWpn+1

                lda #5
                sta actXH+2
                lda #$80
                sta actXL+2
                lda #4
                sta actYH+2
                lda #ACT_INACTIVEPLAYER
                sta actT+2
                lda #
                lda #WPN_PISTOL
                sta actWpn+2

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
                include sounddata.s
                include data.s

        ; Disposable init part

                include init.s
