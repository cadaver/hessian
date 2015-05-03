                include memory.s

                org chars

                incbin logo.chr
                incbin logoscr.dat

titlePageTbl:   dc.w txtPressFire
                dc.w txtInstructions
                dc.w txtInstructions2
                dc.w txtInstructions3
                dc.w txtMainMenu
                dc.w txtOptions

txtPressFire:   dc.b "A COVERT BITOPS PRODUCTION IN 2015",0
                dc.b 0
                dc.b "CODE, GFX, SOUND: LASSE __RNI",0
                dc.b 0
                dc.b "MUSIC: LASSE __RNI & PETER NAGY-MIKLOS",0
                dc.b 0
                dc.b "PRESS FIRE FOR MENU",0

txtInstructions:dc.b "USE JOYSTICK IN PORT 2 AND KEYS",0
                dc.b 0
                dc.b ", .     SELECT ITEM",0
                dc.b $80+11,"R       RELOAD",0
                dc.b $80+11,"M       USE MEDKIT",0
                dc.b $80+11,"B       USE BATTERY",0
                dc.b "RUNSTOP PAUSE MENU",0
                dc.b 0

txtInstructions2:
                dc.b "MOVEMENT CONTROLS - FIRE NOT PRESSED",0
                dc.b 0
                dc.b "JUMP  JUMP/CLIMB UP/ACTIVATE  JUMP",0
                dc.b 0
                dc.b "GO LEFT   +   GO RIGHT",0
                dc.b 0
                dc.b "ROLL  DUCK/CLIMB DOWN/PICKUP  ROLL",0

txtInstructions3:
                dc.b "TO ATTACK, PRESS FIRE AND DIRECTION",0
                dc.b 0
                dc.b "HOLD FIRE TO ENTER INVENTORY. WHILE FIRE",0
                dc.b "IS HELD, PRESS LEFT OR RIGHT TO SELECT",0
                dc.b "ITEMS. PRESS DOWN TO RELOAD OR USE ITEM",0
                dc.b 0
                dc.b "HOLD FIRE LONGER FOR PAUSE MENU",0

txtMainMenu:    dc.b 0
                dc.b $80+13,"START NEW GAME",0
                dc.b 0
                dc.b $80+13,"CONTINUE GAME",0
                dc.b 0
                dc.b $80+13,"OPTIONS",0
                dc.b 0

txtOptions:     dc.b $80+12,"SKILL",0
                dc.b 0
                dc.b $80+12,"MUSIC",0
                dc.b 0
                dc.b $80+12,"SOUND FX",0
                dc.b 0
                dc.b $80+12,"BACK",0

                if * > screen2+SCROLLROWS*40
                    err
                endif