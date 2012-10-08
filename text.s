        ; Item names

itemNameLo:     dc.b <txtFists
                dc.b <txtKnife
                dc.b <txtPistol
                dc.b <txtGrenade
                dc.b <txtFirstAidKit

itemNameHi:     dc.b >txtFists
                dc.b >txtKnife
                dc.b >txtPistol
                dc.b >txtGrenade
                dc.b >txtFirstAidKit

txtFists:       dc.b "FISTS",0
txtKnife:       dc.b "KNIFE",0
txtPistol:      dc.b "PISTOL",0
txtGrenade:     dc.b "GRENADES",0
txtFirstAidKit: dc.b "MEDKIT",0

        ; Skill names

skillNameLo:    dc.b <txtAgility
                dc.b <txtCarrying
                dc.b <txtFirearms
                dc.b <txtMelee
                dc.b <txtVitality


skillNameHi:    dc.b >txtAgility
                dc.b >txtCarrying
                dc.b >txtFirearms
                dc.b >txtMelee
                dc.b >txtVitality

txtAgility:     dc.b "AGILITY",0
txtCarrying:    dc.b "CARRYING",0
txtFirearms:    dc.b "FIREARMS",0
txtMelee:       dc.b "MELEE",0
txtVitality:    dc.b "VITALITY",0

        ; Game messages

txtPickedUp:    dc.b "GOT ",0
txtInf:         dc.b "*INF"
txtLoad:        dc.b "LOAD"
txtXP:          dc.b "XP, LV."
txtLevelUp:     dc.b "LEVELED UP TO LV."
txtLevelUpLevel:dc.b "    PICK SKILL TO IMPROVE",0
txtRestart:     dc.b "PRESS FIRE TO CONTINUE",0
