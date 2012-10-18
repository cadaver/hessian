                include macros.s
                include mainsym.s

                org scriptCodeStart

                dc.w TitleScreen
                dc.w RestartGame

TitleScreen:    jsr BlankScreen
                lda fileHi+C_COMMON             ;If not loaded yet, load the always
                bne SpritesLoaded               ;resident sprites
                ldy #C_COMMON
                jsr LoadSpriteFile
                ldy #C_WEAPON
                jsr LoadSpriteFile
                lda #HP_PLAYER                  ;Init health & fists item immediately
                sta actHp+ACTI_PLAYER           ;even before starting the game so that
                lda #ITEM_FISTS                 ;the panel looks nice
                sta invType
SpritesLoaded:  ldx #$00
CopyLogoLoop:   lda logoChars,x
                sta textChars+$300,x
                lda logoChars+$100,x
                sta textChars+$400,x
                lda logoChars+$200,x
                sta textChars+$500,x
                inx
                bne CopyLogoLoop
                lda #$00
                sta Irq1_Bg1+1
                sta scrollY
                lda #$02
                sta screen
                lda #$0f
                sta scrollX
                ldx #$00
                lda #$20
ClearScreenLoop:sta screen1,x
                sta screen1+$100,x
                sta screen1+$200,x
                sta screen1+$270,x
                inx
                bne ClearScreenLoop
                ldx #23
PrintLogoLoop:
M               set 0
                repeat 7
                lda logoScreen+M*24,x
                sta screen1+M*40+8+3*40,x
                lda #$00
                sta colors+M*40+8+3*40,x
M               set M+1
                repend
                dex
                bpl PrintLogoLoop

                lda #$00                        ;Play the title song
                jsr PlaySong

TitleWait:      jsr FinishFrame_NoScroll
                jsr FadeInLogo
                jsr GetControls
                jsr GetFireClick
                bcc TitleWait

FadeOutWait:    jsr FinishFrame_NoScroll
                jsr FadeOutLogo
                lda logoFade
                bne FadeOutWait

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

FadeOutLogo:    lda logoFade
                beq UpdateLogo
                dec logoFade
                bpl UpdateLogo

FadeInLogo:     lda logoFade
                cmp #15
                bcs UpdateLogo
                inc logoFade

UpdateLogo:     jsr WaitBottom
                lda logoFade
                lsr
                lsr
                tax
                lda logoFadeBg2Tbl,x
                sta Irq1_Bg2+1
                lda logoFadeBg3Tbl,x
                sta Irq1_Bg3+1
                lda logoFade
                asl
                and #$f8
                sta temp1
                ldx #23
UpdateLogoColors:
M               set 0
                repeat 7
                lda logoColors+M*24,x
                and #$07
                ora temp1
                tay
                lda logoFadeCharTbl,y
                sta colors+M*40+8+3*40,x
M               set M+1
                repend
                dex
                bpl UpdateLogoColors
                rts

logoFade:       dc.b 0

logoFadeBg2Tbl: dc.b $00,$00,$06,$0e
logoFadeBg3Tbl: dc.b $00,$06,$0e,$03
logoFadeCharTbl:dc.b $08,$08,$08,$08,$08,$08,$08,$08
                dc.b $08,$0e,$08,$08,$08,$08,$08,$08
                dc.b $08,$0b,$08,$0e,$08,$08,$08,$0b
                dc.b $08,$09,$0a,$0b,$0c,$0d,$0e,$0f


logoChars:      incbin bg/logo.chr
logoScreen:     incbin bg/logoscr.bin
logoColors:     incbin bg/logocol.bin
