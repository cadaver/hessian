SHOW_FREE_MEMORY = 0
SHOW_BATTERY = 0
SHOW_ACTOR_TIME = 0
SHOW_SPRITESORT_TIME = 0
SHOW_SCROLLWORK_TIME = 0
SHOW_PLAYROUTINE_TIME = 0
SHOW_LEVELUPDATE_TIME = 0
SHOW_SPRITEDEPACK_TIME = 0

DROP_ITEM_TEST  = 0                             ;Drop (D key) a copy of current item to test actor save
PURGE_TEST      = 0                             ;Purge (P key) the oldest chunk-file to test for memory use
AMMO_CHEAT      = 1
ALLQUESTITEMS_CHEAT = 0
STARTITEM_CHEAT = 1                             ;Start with weapon & parts instead of empty inventory
FILTER_UPGRADE_CHEAT = 0
UPGRADE_CHEAT   = 0
GODMODE_CHEAT   = 1                             ;Whether health/battery cheat is on initially
CODE_CHEAT      = 0                             ;All codes all zeroes
SKIP_PLOT       = 0                             ;Various instant jumps to late game plot sequences
SKIP_PLOT2      = 0

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
                include panel.s
                include script.s
                include level.s
                include physics.s
                include player.s
                include weapon.s
                include bullet.s
                include item.s
                include ai.s
                include enemy.s

randomAreaEnd:

        ; Disposable init part, overwritten by loadable script code

                include init.s

        ; Aligned data & game state

                include leveldata.s
                include aligneddata.s

        ; Non-aligned data

                include sounddata.s
                include paneldata.s
                include aidata.s
                include itemdata.s
                include weapondata.s
                include actordata.s
                include text.s

        ; Preloaded spritefiles that will never be purged

sprCommon:      incbin sprcommon.dat
sprItem:        incbin spritem.dat
sprWeapon:      incbin sprweapon.dat

        ; Dynamic allocation area begin

fileAreaStart: