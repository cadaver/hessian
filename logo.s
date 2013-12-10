                include memory.s

                org chars

                incbin logo.chr
                incbin logoscr.dat
                
titlePageTbl:   dc.w txtPressFire
                dc.w txtInstructions
                dc.w txtInstructions2
                dc.w txtInstructions3
                dc.w txtInstructions4
                dc.w txtInstructions5

txtPressFire:   dc.b "A COVERT BITOPS PRODUCTION IN 2013",0
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
                dc.b $80+11,"H       USE MEDKIT",0
                dc.b "RUNSTOP PAUSE MENU",0
                dc.b 0

txtInstructions2:
                dc.b "MOVEMENT CONTROLS (NO FIRE PRESSED)",0
                dc.b 0
                dc.b "JUMP  JUMP/CLIMB UP/ACTIVATE  JUMP",0
                dc.b 0
                dc.b "GO LEFT   +   GO RIGHT",0
                dc.b 0
                dc.b "ROLL  DUCK/CLIMB DOWN/PICKUP  ROLL",0

txtInstructions3:
                dc.b "TO ATTACK, PRESS FIRE AND DIRECTION",0
                dc.b 0
                dc.b "HOLD FIRE FOR INVENTORY, THEN PRESS LEFT",0
                dc.b "OR RIGHT TO SELECT ITEMS, DOWN TO RELOAD",0
                dc.b "OR USE ITEM, AND UP TO VIEW SKILLS",0
                dc.b 0
                dc.b "HOLD FIRE LONGER FOR PAUSE MENU",0

txtInstructions4:
                dc.b "SKILLS (GAIN EXPERIENCE TO ADVANCE)",0
                dc.b 0
                dc.b $80,"AGILITY   TURN/CLIMB FASTER, JUMP HIGHER",0
                dc.b $80,"CARRYING  CARRY MORE WEAPONS + AMMO",0
                dc.b $80,"FIREARMS  MORE DAMAGE AND FASTER RELOAD",0
                dc.b $80,"MELEE     MORE MELEE DAMAGE",0
                dc.b $80,"VITALITY  RESIST DAMAGE, RECOVER FASTER",0

txtInstructions5:
                dc.b "TAKE CONTROL OF HESSIAN, AN EX-MILITARY",0
                dc.b "MEMBER OF A GROUP KNOWN AS 'SKEPTICS'",0
                dc.b "THAT INVESTIGATES POTENTIAL END-OF-THE-",0
                dc.b "WORLD SCENARIOS. AS A MYSTERIOUS ENERGY",0
                dc.b "BLAST ENGULFS ONE SECTOR OF THE GROUP'S",0
                dc.b "HOME CITY 'METROPOL' THEY MAY NO LONGER",0
                dc.b "BE ABLE TO REMAIN SKEPTICAL...",0
                
                if * > screen2+SCROLLROWS*40
                    err
                endif