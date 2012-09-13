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
                include item.s
                include panel.s

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

CreatePlayer:   ldx #ACTI_PLAYER
                lda #6
                sta actXH,x
                lda #$80
                sta actXL,x
                lda #4
                sta actYH,x
                lda #ACT_PLAYER
                sta actT,x
                lda #WPN_KNIFE
                sta actWpn,x
                lda #HP_PLAYER
                sta actHp,x
                lda #GRP_HEROES
                sta actGrp,x
                jsr SetActorSize

                inx
                lda #7
                sta actXH,x
                lda #$80
                sta actXL,x
                lda #4
                sta actYH,x
                lda #ACT_INACTIVEPLAYER
                sta actT,x
                lda #WPN_PISTOL
                sta actWpn,x
                lda #10
                sta actHp,x
                lda #GRP_VILLAINS
                sta actGrp,x
                lda #$02
                sta actC,x
                jsr SetActorSize

                inx
                lda #5
                sta actXH,x
                lda #$80
                sta actXL,x
                lda #4
                sta actYH,x
                lda #ACT_INACTIVEPLAYER
                sta actT,x
                lda #WPN_PISTOL
                sta actWpn,x
                lda #10
                sta actHp,x
                lda #GRP_VILLAINS
                sta actGrp,x
                lda #$08
                sta actC,x
                jsr SetActorSize

MainLoop:       jsr ScrollLogic
                jsr DrawActors
                jsr ScrollPlayer
                jsr UpdateFrame
                jsr UpdatePanel
                jsr ScrollLogic
                jsr GetControls
                jsr UpdateActors
                jsr InterpolateActors
                jsr ScrollPlayer
                jsr UpdateFrame
                jsr UpdatePanel
                
                lda keyType                     ;Test code for weapon switch, to be removed
                cmp #KEY_SPACE
                bne MainLoop
                lda actWpn
                adc #$00
                cmp #WPN_GRENADE+1
                bcc WeaponOk
                lda #WPN_KNIFE
WeaponOk:       sta actWpn

                jmp MainLoop

                include actordata.s
                include weapondata.s
                include sounddata.s
                include data.s

        ; Disposable init part

                include init.s
