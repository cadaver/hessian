SHOW_FREE_RASTERTIME = 0
SHOW_COLORSCROLL_WAIT = 0
REDUCE_CONTROL_LATENCY = 1

        ; Memory configuration & loader symbols

                include memory.s
                include loadsym.s

                org loaderCodeEnd

        ; Entry point. Jump to disposable init
        
                jmp InitAll

        ; Memory alignment of raster interrupt code is critical, so include first

randomAreaStart:

                include raster.s
                include sound.s
                include input.s
                include math.s
                include file.s
                include sprite.s
                include screen.s
                include panel.s
                include level.s
                include actor.s
                include physics.s
                include player.s
                include item.s
                include weapon.s
                include bullet.s
                include ai.s

        ; Test initialization code, will be removed

Main:           lda #0
                jsr LoadMusic
                lda #0
                jsr InitMusic
                ldy #C_COMMON                   ;Load the always resident sprites
                jsr LoadSpriteFile
                ldy #C_WEAPON
                jsr LoadSpriteFile

Restart:        lda #0
                jsr LoadLevel
                jsr ClearActors

CreatePlayer:   ldy #ACTI_PLAYER
                jsr GFA_Found
                ldx #ACTI_PLAYER
                lda #$00
                sta actD,x
                sta actYL,x
                lda #6
                sta actXH,x
                lda #$80
                sta actXL,x
                lda #2
                sta actYH,x
                lda #ACT_PLAYER
                sta actT,x
                lda #GRP_HEROES
                sta actGrp,x
                jsr InitActor
                lda #ORG_NONE                   ;Player has no leveldata origin
                sta actLvlOrg,x
                jsr InitPlayer
                jsr CenterPlayer

MainLoop:       jsr ScrollLogic
                jsr DrawActors
                jsr FinishFrame
                jsr ScrollLogic
                jsr GetControls
                jsr UpdateMenu
                jsr UpdateActors
                jsr FinishFrame
                jsr UpdateLevelObjects
                jmp MainLoop

randomAreaEnd:

                include text.s
                include data.s

        ; Disposable init part

                include init.s
