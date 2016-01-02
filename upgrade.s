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

PS              = $ff
AM              = $0f
bl              = $00
VE              = $01
HO              = $02
BR              = $03
BL              = $04
TL              = $05
TR              = $06
CR              = $07
SV              = $09
SH              = $0a
SR              = $0b
SD              = $0c
SL              = $0d
SU              = $0e

upgrade1:       dc.w nameMovement
                dc.w descMovement
                dc.b %00110000
                dc.b bl,bl,bl,VE,bl,bl,bl,bl,bl,VE,bl,bl,bl
                dc.b bl,bl,TL,SU,HO,TR,bl,TL,HO,SU,TR,bl,bl
                dc.b PS,SV,BR,VE,bl,SL,bl,VE,bl,AM,SU,HO,HO
                dc.b bl,bl,bl,AM,HO,SL,AM,SR,HO,HO,SL,bl,bl
                dc.b PS,SV,TR,VE,bl,SL,bl,VE,bl,AM,SD,HO,HO
                dc.b bl,bl,BL,SD,HO,BR,bl,BL,HO,SD,BR,bl,bl
                dc.b bl,bl,bl,VE,bl,bl,bl,bl,bl,VE,bl,bl,bl

upgrade2:       dc.w nameStrength
                dc.w descStrength
                dc.b %00001100
                dc.b bl,bl,bl,bl,VE,bl,bl,bl,VE,bl,bl,bl,bl
                dc.b bl,bl,TL,HO,SD,HO,SR,HO,SD,HO,TR,bl,bl
                dc.b bl,bl,VE,bl,VE,bl,VE,bl,VE,bl,VE,bl,bl
                dc.b PS,HO,SR,HO,SV,HO,AM,HO,SV,HO,SL,HO,HO
                dc.b bl,bl,VE,bl,VE,bl,VE,bl,VE,bl,VE,bl,bl
                dc.b bl,bl,BL,HO,SU,HO,SL,HO,SU,HO,BR,bl,bl
                dc.b bl,bl,bl,bl,VE,bl,bl,bl,VE,bl,bl,bl,bl

upgrade3:       dc.w nameFirearms
                dc.w descFirearms
                dc.b %00000101
                dc.b bl,bl,bl,bl,bl,bl,VE,bl,bl,bl,bl,bl,bl
                dc.b bl,bl,TL,HO,AM,HO,SU,HO,HO,HO,TR,bl,bl
                dc.b bl,bl,VE,bl,bl,bl,VE,bl,bl,bl,SL,HO,HO
                dc.b PS,HO,SR,bl,bl,bl,SR,HO,AM,HO,SR,bl,bl
                dc.b bl,bl,VE,bl,bl,bl,VE,bl,bl,bl,SL,HO,HO
                dc.b bl,bl,BL,HO,AM,HO,SD,HO,HO,HO,BR,bl,bl
                dc.b bl,bl,bl,bl,bl,bl,VE,bl,bl,bl,bl,bl,bl

upgrade4:       dc.w nameArmor
                dc.w descArmor
                dc.b %00111111
                dc.b bl,bl,TL,HO,BR,bl,VE,bl,VE,bl,BL,HO,TR
                dc.b PS,HO,SR,HO,SV,HO,SD,HO,SD,HO,SV,HO,AM
                dc.b bl,bl,VE,TL,HO,HO,SL,AM,SR,HO,HO,TR,VE
                dc.b bl,AM,SR,CR,HO,HO,SL,bl,SR,HO,HO,CR,SL
                dc.b bl,bl,VE,BL,HO,HO,SL,AM,SR,HO,HO,BR,VE
                dc.b PS,HO,SR,HO,SV,HO,SU,HO,SU,HO,SV,HO,AM
                dc.b bl,bl,BL,HO,TR,bl,VE,bl,VE,bl,TL,HO,BR

upgrade5:       dc.w nameHealing
                dc.w descHealing
                dc.b %00000010
                dc.b bl,bl,TL,HO,HO,HO,TR,TL,HO,CR,HO,TR,bl
                dc.b PS,HO,SR,AM,bl,bl,VE,VE,SL,AM,SR,VE,bl
                dc.b bl,bl,BL,HO,HO,TR,VE,VE,SR,SH,SL,VE,bl
                dc.b bl,bl,bl,bl,AM,SR,CR,SL,SR,CR,SL,CR,HO
                dc.b bl,bl,TL,HO,HO,BR,VE,VE,SR,SH,SL,VE,bl
                dc.b PS,HO,SR,AM,bl,bl,VE,VE,SL,AM,SR,VE,bl
                dc.b bl,bl,BL,HO,HO,HO,BR,BL,HO,CR,HO,BR,bl

upgrade6:       dc.w nameDrain
                dc.w descDrain
                dc.b %00000010
                dc.b bl,TL,CR,TR,TL,CR,TR,TL,CR,TR,TL,CR,TR
                dc.b bl,VE,AM,VE,VE,SV,VE,VE,SV,VE,VE,AM,VE
                dc.b bl,VE,bl,VE,VE,bl,VE,VE,bl,VE,VE,bl,VE
                dc.b PS,SR,bl,SL,SR,AM,SL,SR,AM,SL,SR,bl,SL
                dc.b bl,VE,bl,VE,VE,bl,VE,VE,bl,VE,VE,bl,VE
                dc.b bl,VE,AM,VE,VE,SV,VE,VE,SV,VE,VE,AM,VE
                dc.b bl,BL,CR,BR,BL,CR,BR,BL,CR,BR,BL,CR,BR

upgrade7:       dc.w nameRecharge
                dc.w descRecharge
                dc.b %00111100
                dc.b bl,bl,VE,bl,VE,bl,VE,bl,VE,bl,VE,bl,bl
                dc.b PS,SV,SD,HO,SD,HO,SD,HO,SD,HO,SD,SV,HO
                dc.b bl,bl,VE,SR,SU,SU,SU,SU,SU,SL,VE,bl,bl
                dc.b PS,SV,SR,SL,AM,SR,CR,SL,AM,SR,SL,SV,HO
                dc.b bl,bl,VE,SR,SD,SD,SD,SD,SD,SL,VE,bl,bl
                dc.b PS,SV,SU,HO,SU,HO,SU,HO,SU,HO,SU,SV,HO
                dc.b bl,bl,VE,bl,VE,bl,VE,bl,VE,bl,VE,bl,bl

                     ;0123456789012345678901234567
descMovement:   dc.b "IMPROVED TURNS, JUMPS AND",0
                dc.b "CLIMBING SPEED AT COST OF",0
                dc.b "EXTRA BATTERY DRAIN. CARRY",0
                dc.b "ONE MORE WEAPON",0,0

                     ;0123456789012345678901234567
descStrength:   dc.b "IMPROVED MELEE STRENGTH AT",0
                dc.b "COST OF EXTRA BATTERY DRAIN.",0
                dc.b "CARRY ONE MORE WEAPON AND",0
                dc.b "MORE AMMO",0,0

                     ;0123456789012345678901234567
descFirearms:   dc.b "IMPROVED FIREARMS PRECISION",0
                dc.b "(MORE STOPPING POWER) AND",0
                dc.b "REDUCED RELOAD TIME",0,0

                     ;0123456789012345678901234567
descArmor:      dc.b "REDUCED BLUNT AND PIERCING",0
                dc.b "TRAUMA OVER THE ENTIRE BODY",0,0

                     ;0123456789012345678901234567
descHealing:    dc.b "FASTER NANOMECHANICAL TISSUE",0
                dc.b "REGENERATION",0,0

                     ;0123456789012345678901234567
descDrain:      dc.b "INCREASED TIME OF OPERATION",0
                dc.b "BEFORE BATTERY RECHARGE IS",0
                dc.b "REQUIRED",0,0

                     ;0123456789012345678901234567
descRecharge:   dc.b "CONVERTS BODY ELECTRICITY",0
                dc.b "INTO BATTERY POWER AT COST",0
                dc.b "OF INCREASED METABOLIC ",0
                dc.b "STRAIN",0,0

                if * > screen2+SCROLLROWS*40
                    err
                endif