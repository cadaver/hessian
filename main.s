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
                
                ldx #ACTI_FIRSTITEM
                lda #5
                sta actXH,x
                lda #$80
                sta actXL,x
                lda #2
                sta actYH,x
                lda #ACT_ITEM
                sta actT,x
                lda #ITEM_KNIFE-1
                sta actF1,x
                lda #1
                sta actHp,x
                jsr SetActorSize

                inx
                lda #6
                sta actXH,x
                lda #$80
                sta actXL,x
                lda #2
                sta actYH,x
                lda #ACT_ITEM
                sta actT,x
                lda #ITEM_PISTOL-1
                sta actF1,x
                lda #1
                sta actHp,x
                jsr SetActorSize

                inx
                lda #7
                sta actXH,x
                lda #$80
                sta actXL,x
                lda #2
                sta actYH,x
                lda #ACT_ITEM
                sta actT,x
                lda #ITEM_GRENADE-1
                sta actF1,x
                lda #1
                sta actHp,x
                jsr SetActorSize

MainLoop:       jsr ScrollLogic
                jsr DrawActors
                jsr ScrollAndUpdateFrame
                jsr UpdatePanel
                jsr ScrollLogic
                jsr GetControls
                jsr UpdateActors
                jsr ScrollAndUpdateFrame
                jsr UpdatePanel

                lda keyType                     ;Test code for inventory switching, TODO remove
                ldy itemIndex
                beq NotPrevItem
                cmp #KEY_N
                bne NotPrevItem
                dey
                bpl NewSelectedItem
NotPrevItem:    cmp #KEY_M
                bne ItemSelectDone
                lda invType+1,y
                beq ItemSelectDone
                iny
NewSelectedItem:sty itemIndex
                lda invType,y
                tay
                lda itemNameLo-1,y
                ldx itemNameHi-1,y
                ldy #INVENTORY_TEXT_DURATION/2
                jsr PrintPanelText              ;Show name of new selected item
                jsr RefreshPlayerWeapon
ItemSelectDone:

                jmp MainLoop

                include actordata.s
                include itemdata.s
                include weapondata.s
                include sounddata.s
                include text.s
                include data.s

        ; Disposable init part

                include init.s
