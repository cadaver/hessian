SHOW_FREE_TIME = 0
SHOW_FREE_MEMORY = 1
SHOW_FRAME_DROP = 0
SHOW_PLAYROUTINE_TIME = 0
SHOW_LEVELUPDATE_TIME = 0
SHOW_SPRITEDEPACK_TIME = 0
SHOW_NAVIGATION_TIME = 0
SHOW_NAVIGATION_TARGET = 0
REDUCE_CONTROL_LATENCY = 0
OPTIMIZE_SPRITEIRQS = 1
SHOW_STACKPOINTER = 0

ITEM_CHEAT      = 1
AMMO_CHEAT      = 0
SKILL_CHEAT     = 0
OPTIMIZE_SAVE   = 1                             ;Clean up temporary actors when saving/continuing

        ; Memory configuration & loader symbols

                include memory.s
                include loadsym.s

        ; Aligned code and data

                org loaderCodeEnd

                include raster.s
                include aligneddata.s
                include leveldata.s

        ; Non-aligned data

                include sounddata.s
                include paneldata.s
                include aidata.s
                include itemdata.s
                include weapondata.s
                include actordata.s
                include text.s

        ; Non-aligned game code

randomAreaStart:

                include math.s
                include sound.s
                include input.s
                include screen.s
                include sprite.s
                include file.s
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

        ; Disposable init part, overwritten by loadable (script code)

                include init.s
