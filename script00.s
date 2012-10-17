                include macros.s
                include mainsym.s

                org scriptCodeStart

                dc.w TitleScreen
                dc.w RestartGame

TitleScreen:    lda fileHi+C_COMMON             ;If not loaded yet, load the always
                bne SpritesLoaded               ;resident sprites
                ldy #C_COMMON
                jsr LoadSpriteFile
                ldy #C_WEAPON
                jsr LoadSpriteFile
SpritesLoaded:

RestartGame:    lda #0
                jsr LoadLevel
                jsr ClearActors

InitPlayer:     lda #0
                ldx #NUM_SKILLS-1
IP_XPSkillLoop: sta xpLo,x
                sta plrSkills,x
                dex
                bpl IP_XPSkillLoop
                stx lvlObjNum                   ;No levelobject found
                ldx #MAX_INVENTORYITEMS-1
IP_InvLoop:     sta invType,x
                sta invCount,x
                sta invMag,x
                dex
                bpl IP_InvLoop
                sta itemIndex
                sta lastReceivedXP
                sta levelUp
                lda #<FIRST_XPLIMIT
                sta xpLimitLo
                lda #1
                sta xpLevel
                sta invType                     ;1 = fists
                jsr ApplySkills
                jsr SetPanelRedrawItemAmmo

CreatePlayer:   ldy #ACTI_PLAYER
                jsr GFA_Found
                ldx #ACTI_PLAYER
                lda #$00
                sta actD,x
                sta actYL,x
                lda #6
                sta actXH,x
                lda #$80
                sta actXL,x
                lda #2
                sta actYH,x
                lda #ACT_PLAYER
                sta actT,x
                lda #GRP_HEROES
                sta actGrp,x
                jsr InitActor
                lda #ORG_NONE                   ;Player has no leveldata origin
                sta actLvlOrg,x

JumpToGame:     jsr CenterPlayer
                jmp MainLoop
