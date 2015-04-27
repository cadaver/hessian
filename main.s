SHOW_FREE_MEMORY = 0
SHOW_ACTOR_TIME = 1
SHOW_SPRITESORT_TIME = 1
SHOW_SCROLLWORK_TIME = 1
SHOW_PLAYROUTINE_TIME = 1
SHOW_LEVELUPDATE_TIME = 1
SHOW_SPRITEDEPACK_TIME = 0
SHOW_NAVIGATION_TIME = 0
SHOW_NAVIGATION_TARGET = 0
OPTIMIZE_SPRITEIRQS = 1

ITEM_CHEAT      = 1
AMMO_CHEAT      = 0
SKILL_CHEAT     = 0
OPTIMIZE_SAVE   = 1                             ;Clean up temporary actors when saving/continuing

        ; Memory configuration & loader symbols

                include memory.s
                include loadsym.s

        ; Aligned code

                org loaderCodeEnd

                include raster.s

        ; Non-aligned game code

randomAreaStart:

                include screen.s
                include sprite.s
                include input.s
                include sound.s
                include file.s
                include math.s
                include actor.s
                include physics.s
                include player.s
                include weapon.s
                include bullet.s
                include item.s
                include panel.s
                include ai.s
                include script.s
                include plot.s
                include level.s                 ;Note: must be last due to intentional fallthrough

        ; Game main loop

StartMainLoop:  ldx #$ff
                txs
MainLoop:       jsr ScrollLogic
                if SHOW_ACTOR_TIME > 0
                lda #$02
                sta $d020
                endif
                jsr DrawActors
                if SHOW_ACTOR_TIME > 0
                lda #$00
                sta $d020
                endif
                jsr FinishFrame
                jsr ScrollLogic
                jsr GetControlsWaitFrame
                jsr UpdateMenu
                if SHOW_ACTOR_TIME > 0
                lda #$02
                sta $d020
                endif
                jsr UpdateActors
                if SHOW_ACTOR_TIME > 0
                lda #$00
                sta $d020
                endif
                jsr FinishFrame
                jsr UpdateLevelObjects
                jmp MainLoop

randomAreaEnd:

        ; Disposable init part, overwritten by loadable script code

                include init.s

        ; Aligned & non-aligned data

                include aligneddata.s
                include leveldata.s
                include sounddata.s
                include paneldata.s
                include aidata.s
                include itemdata.s
                include weapondata.s
                include actordata.s
                include text.s

        ; Dynamic allocation area begin

fileAreaStart: