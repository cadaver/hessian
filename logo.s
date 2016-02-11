                include memory.s

                org chars

                incbin logo.chr
                incbin logoscr.dat

titlePageTbl:   dc.w txtPressFire
                dc.w txtAdditionalCredits
                dc.w txtInstructions
                dc.w txtInstructions2
                dc.w txtInstructions3
                dc.w txtMainMenu
                dc.w txtOptions

txtPressFire:   dc.b "A COVERT BITOPS PRODUCTION IN 2016",0
                dc.b 0
                dc.b "CODE, GFX, SOUND: LASSE __RNI",0
                dc.b 0
                dc.b "MUSIC: LASSE __RNI & PETER NAGY-MIKLOS",0
                dc.b 0
                dc.b "PRESS FIRE FOR MENU",0

txtAdditionalCredits:
                dc.b 0
                dc.b "ADDITIONAL LOADER CODE: PER OLOFSSON,",0
                dc.b 0
                dc.b "WOLFRAM SANG, CHRISTOPH THELEN",0
                dc.b 0
                dc.b "EXOMIZER COMPRESSOR: MAGNUS LIND",0
                dc.b 0

txtInstructions:
                dc.b "USE JOYSTICK IN PORT 2 FOR CONTROL",0
                dc.b 0
                dc.b "JUMP  CLIMB/OPERATE  JUMP",0
                dc.b 0
                dc.b "GO LEFT      +     GO RIGHT",0
                dc.b 0
                dc.b "ROLL DUCK/CLIMB/PICK ROLL",0

txtInstructions2:
                dc.b "TO ATTACK, PRESS FIRE AND DIRECTION",0
                dc.b 0
                dc.b "HOLD FIRE TO ENTER INVENTORY. WHILE FIRE",0
                dc.b "IS HELD, PRESS LEFT OR RIGHT TO SELECT",0
                dc.b "ITEMS AND DOWN TO RELOAD OR USE ITEM",0
                dc.b 0
                dc.b "HOLD FIRE LONGER FOR PAUSE MENU",0

txtInstructions3:
                dc.b "KEYBOARD CONTROLS",0
                dc.b 0
                dc.b ", .     SELECT ITEM",0
                dc.b $80+11,"R       RELOAD/USE",0
                dc.b $80+11,"H       USE MEDKIT",0
                dc.b $80+11,"B       USE BATTERY",0
                dc.b "RUNSTOP PAUSE MENU",0
                dc.b 0

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

                org screen2
                
levelNamesTbl:  dc.b 0,$28,$00,levelWarehouses-levelNames
                dc.b 0+$80,levelCourtyard-levelNames
                dc.b 1,$00,$18,levelCarPark-levelNames
                dc.b 1+$80,levelCourtyard-levelNames
                dc.b 2+$80,levelServiceTunnels-levelNames
                dc.b 3+$80,levelEntrance-levelNames
                dc.b 4+$80,levelServiceTunnels-levelNames
                dc.b 5+$80,levelSecurityCenter-levelNames
                dc.b 6+$80,levelUpperLabs-levelNames
                dc.b 7+$80,levelUnderground-levelNames
                dc.b 8+$80,levelLowerLabs-levelNames
                dc.b 9+$80,levelSecurityCenter-levelNames
                dc.b 10+$80,levelNetherTunnel-levelNames
                dc.b 11,$50,$00,levelBioDome-levelNames
                dc.b 11+$80,levelCourtyard-levelNames
                dc.b 12+$80,levelThroneSuite-levelNames
                dc.b 13+$80,levelServerVault-levelNames
                dc.b 14+$80,levelUnderground-levelNames
                dc.b 15+$80,levelOldTunnels-levelNames

                org screen2+$40

levelNames:
levelWarehouses:dc.b "WAREHOUSE",0
levelCourtyard: dc.b "COURTYARD",0
levelCarPark:   dc.b "PARKING GARAGE",0
levelServiceTunnels:dc.b "SERVICE TUNNELS",0
levelEntrance:  dc.b "ENTRANCE",0
levelSecurityCenter:dc.b "SECURITY CENTER",0
levelUpperLabs: dc.b "UPPER LABS",0
levelUnderground:dc.b "UNDERGROUND",0
levelLowerLabs: dc.b "LOWER LABS",0
levelNetherTunnel:dc.b "NETHER TUNNEL",0
levelBioDome:   dc.b "BIO-DOME",0
levelThroneSuite:dc.b "THRONE SUITE",0
levelServerVault:dc.b "SERVER VAULT",0
levelOldTunnels: dc.b "OLD TUNNELS",0

                org screen2+$100

txtCancel:      dc.b "CANCEL",0

                org screen2+$108

txtEndWithoutSaving:
                dc.b "ABANDON GAME",0

