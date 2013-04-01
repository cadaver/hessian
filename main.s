SHOW_FREE_TIME = 0
SHOW_FREE_MEMORY = 0
SHOW_COLORSCROLL_WAIT = 0
SHOW_PLAYROUTINE_TIME = 0
SHOW_LEVELUPDATE_TIME = 0
SHOW_SPRITEDEPACK_TIME = 0
REDUCE_CONTROL_LATENCY = 0
OPTIMIZE_SPRITEIRQS = 1
SHOW_STACKPOINTER = 0
USE_FLIPDISK_PROMPT = 0

GODMODE_CHEAT   = 0
ITEM_CHEAT      = 1
AMMO_CHEAT      = 0
SKILL_CHEAT     = 0

        ; Memory configuration & loader symbols

                include memory.s
                include loadsym.s

                org loaderCodeEnd

randomAreaStart:

                include raster.s
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

        ; Disposable init part

                include init.s

        ; Static data and variables

                include data.s

