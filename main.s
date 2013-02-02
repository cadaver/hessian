SHOW_FREE_RASTERTIME = 0
SHOW_COLORSCROLL_WAIT = 0
REDUCE_CONTROL_LATENCY = 1
OPTIMIZE_SPRITEIRQS = 1

GODMODE_CHEAT = 0
ITEM_CHEAT = 1
AMMO_CHEAT = 0

DISABLE_MUSIC = 0

        ; Memory configuration & loader symbols

                include memory.s
                include loadsym.s

                org loaderCodeEnd

        ; Entry point. Jump to disposable init

                jmp InitAll

randomAreaStart:

                include raster.s
                include sound.s
                include input.s
                include screen.s
                include sprite.s
                include file.s
                include math.s
                include actor.s
                include physics.s
                include weapon.s
                include bullet.s
                include player.s
                include item.s
                include panel.s
                include level.s
                include script.s
                include ai.s

        ; Main loop

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

                include text.s
                include data.s

        ; Disposable init part

                include init.s
