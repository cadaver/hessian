SHOW_FREE_MEMORY = 0
SHOW_BATTERY = 0
SHOW_ACTOR_TIME = 0
SHOW_SPRITESORT_TIME = 0
SHOW_SCROLLWORK_TIME = 0
SHOW_PLAYROUTINE_TIME = 0
SHOW_LEVELUPDATE_TIME = 0
SHOW_SPRITEDEPACK_TIME = 0

DROP_ITEM_TEST  = 0                             ;Drop a copy of current item to test actor save
AMMO_CHEAT      = 0
ALLQUESTITEMS_CHEAT = 0
STARTITEM_CHEAT = 0                            ;Start with weapon & parts instead of empty inventory
FILTER_UPGRADE_CHEAT = 0
UPGRADE_CHEAT   = 0
GODMODE_CHEAT   = 0                             ;Whether health/battery cheat is on initially
SKIP_PLOT       = 0                             ;Various instant jumps to late game plot sequences
SKIP_PLOT2      = 0
SKIP_PLOT3      = 0

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
                include sound.s
                include input.s
                include file.s
                include math.s
                include actor.s
                include physics.s
                include player.s
                include enemy.s
                include weapon.s
                include bullet.s
                include item.s
                include panel.s
                include ai.s
                include script.s
                include level.s

randomAreaEnd:

        ; Disposable init part, overwritten by loadable script code

                include init.s

        ; Non-aligned data

                include sounddata.s
                include paneldata.s
                include aidata.s
                include itemdata.s
                include weapondata.s
                include actordata.s
                include text.s
                include leveldata.s

        ; Aligned data

                include aligneddata.s

        ; Dynamic allocation area begin

fileAreaStart: