                include memory.s

                org chars
                dc.w upgrade1
                dc.w upgrade2
                dc.w upgrade3
                dc.w upgrade4
                dc.w upgrade5
                dc.w upgrade6
                dc.w upgrade7

nameMovement:   dc.b "LOWER BODY EXOSKELETON",0
nameStrength:   dc.b "UPPER BODY EXOSKELETON",0

                org chars+$40
                incbin spr/sight.spr

                org chars+$80

nameFirearms:   dc.b "MOTOR SKILL COPROCESSOR",0
nameArmor:      dc.b "SUBDERMAL ARMOR",0
nameHealing:    dc.b "RECOVERY BOOSTER",0
nameDrain:      dc.b "AUXILIARY BATTERY",0
nameRecharge:   dc.b "BIOELECTRIC RECHARGER",0

                org chars+$100
                dc.b 0                          ;Text chars will be copied here

                org chars+$400
                incbin bg/upgrade.chr

upgrade1:       dc.w nameMovement
                dc.w descMovement
                dc.b %00110000
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

upgrade2:       dc.w nameStrength
                dc.w descStrength
                dc.b %00001100
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

upgrade3:       dc.w nameFirearms
                dc.w descFirearms
                dc.b %00000101
                dc.b $00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00
                dc.b $00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00
                dc.b $fc,$02,$02,$09,$02,$09,$09,$02,$08,$02,$02,$02
                dc.b $00,$00,$00,$09,$02,$0e,$0e,$02,$08,$00,$00,$00
                dc.b $00,$00,$00,$09,$02,$0e,$0e,$02,$08,$00,$00,$00
                dc.b $fc,$02,$02,$09,$02,$09,$09,$02,$08,$02,$02,$02
                dc.b $00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00
                dc.b $00,$00,$00,$01,$00,$00,$00,$00,$01,$00,$00,$00

upgrade4:       dc.w nameArmor
                dc.w descArmor
                dc.b %00111111
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

upgrade5:       dc.w nameHealing
                dc.w descHealing
                dc.b %00000010
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

upgrade6:       dc.w nameDrain
                dc.w descDrain
                dc.b %00000010
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

upgrade7:       dc.w nameRecharge
                dc.w descRecharge
                dc.b %00111111
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00
                dc.b $00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00

                     ;0123456789012345678901234567
descMovement:   dc.b "ENHANCED MANEUVERABILITY,",0
                dc.b "HIGH JUMPS AND FAST CLIMBING",0
                dc.b "AT THE COST OF EXTRA BATTERY",0
                dc.b "DRAIN",0,0

                     ;0123456789012345678901234567
descStrength:   dc.b "IMPROVED UNARMED OR MELEE",0
                dc.b "STRENGTH AND LOAD CAPACITY",0
                dc.b "AT THE COST OF EXTRA BATTERY",0
                dc.b "DRAIN",0,0

                     ;0123456789012345678901234567
descFirearms:   dc.b "IMPROVED FIREARMS PRECISION",0
                dc.b "(BETTER STOPPING POWER) AND",0
                dc.b "REDUCED RELOAD TIMES",0,0

                     ;0123456789012345678901234567
descArmor:      dc.b "REDUCED BLUNT AND PIERCING",0
                dc.b "TRAUMA OVER THE ENTIRE BODY",0,0

                     ;0123456789012345678901234567
descHealing:    dc.b "FASTER NANOMECHANICAL TISSUE",0
                dc.b "RESTORATION",0,0

                     ;0123456789012345678901234567
descDrain:      dc.b "INCREASED TIME OF OPERATION",0
                dc.b "BEFORE BATTERY RECHARGE IS",0
                dc.b "REQUIRED",0,0

                     ;0123456789012345678901234567
descRecharge:   dc.b "CONVERTS BODY ELECTRICITY",0
                dc.b "INTO BATTERY POWER AT THE",0
                dc.b "COST OF INCREASED METABOLIC",0
                dc.b "STRAIN",0,0

                if * > screen2+SCROLLROWS*40
                    err
                endif