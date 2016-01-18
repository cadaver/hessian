                include macros.s
                include mainsym.s

        ; Script 13, second cave

                org scriptCodeStart

                dc.w InstallLaptop
                dc.w InstallLaptopWork
                dc.w InstallLaptopFinish

        ; Install laptop script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

InstallLaptop:  ldy #ITEM_LAPTOP
                jsr FindItem
                bcc IL_NoItem
                lda #ACT_HACKER                 ;Check for executing both of the plans: if Jeff is already
                jsr FindLevelActor              ;in hazmat suit, this plan is not available
                bcc IL_NoItem
                lda actMB+ACTI_PLAYER
                lsr
                bcc IL_NoItem                   ;Wait until not jumping
                jsr RemoveItem
                jsr AddQuestScore
                lda #PLOT_DISRUPTCOMMS
                jsr SetPlotBit
                lda #$00
                sta temp4
                lda #ITEM_LAPTOP
                jsr DI_ItemNumber
                ldx temp8
                lda #$80
                sta actXL,x                     ;Always center of block
                lda #$00
                sta actSY,x                     ;No speed
                lda #<EP_INSTALLLAPTOPWORK
                ldx #>EP_INSTALLLAPTOPWORK
                jsr SetScript
                lda #<txtRadioInstallLaptop
                ldx #>txtRadioInstallLaptop
                jsr RadioMsg
                lda #JOY_DOWN                   ;Crouch to place the laptop
                sta actMoveCtrl+ACTI_PLAYER
                rts
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx
IL_NoItem:      rts

        ; Install laptop in-progress script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

InstallLaptopWork:
                lda textTime
                bne IL_NoItem                   ;Wait until text finished
                inc scriptVariable
                lda scriptVariable
                cmp #75                         ;Some delay
                bcc IL_NoItem
                jsr StopScript
                lda #PLOT_OLDTUNNELSLAB2        ;Jeff in lab?
                jsr GetPlotBit
                bne ILW_VariationB
ILW_VariationA: lda #<txtRadioInstallA
                ldx #>txtRadioInstallA
                bne RadioMsg
ILW_VariationB: lda #<txtRadioInstallB
                ldx #>txtRadioInstallB
                bne RadioMsg

        ; Install laptop finish (while climbing to exit)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various
        
InstallLaptopFinish:
                lda #PLOT_DISRUPTCOMMS
                jsr SetPlotBit
                beq ILF_NotYet                  ;May visit here without laptop
                lda #<txtRadioInstallFinish
                ldx #>txtRadioInstallFinish
                bne RadioMsg
ILF_NotYet:     ldy lvlObjNum
                jmp InactivateObject

        ; Messages


txtRadioInstallLaptop:
                dc.b 34,"JEFF HERE. THIS MUST BE THE AI'S LINK. LET'S GET TO WORK.",34,0
txtRadioInstallA:
                dc.b 34,"WHAT? THIS ISN'T AN OUTSIDE LINE, BUT TRAFFIC BETWEEN TWO ENTITIES. WAIT A MINUTE.. JORMUNGANDR. "
                dc.b "IT'S SOME KIND OF FAILSAFE PROTOCOL. FAIL-DEADLY, I MEAN. IF EITHER END FALLS SILENT, SOMETHING BAD HAPPENS. "
                textjump txtRadioInstallCommon
txtRadioInstallB:
                dc.b 34,"I'M GETTING BI-DIRECTIONAL TRAFFIC, JUST LIKE I IMAGINED. THIS IS THE REVENGE PROTOCOL. "
txtRadioInstallCommon:
                dc.b "I'LL SEE WHAT I CAN DO AND GET BACK TO YOU.",34,0

txtRadioInstallFinish:
                dc.b 34,"JEFF AGAIN. MANAGED TO IDENTIFY A SEQUENCE WHICH I CAN REPLAY ENDLESSLY. "
                dc.b "WE'LL SEE HOW IT GOES WHEN YOU TAKE OUT JORMUNGANDR. DO NOT, I REPEAT DO NOT ATTACK THE AI FIRST. ITS SEQUENCE "
                dc.b "MUTATES CONSTANTLY, WHICH I CAN'T SPOOF.",34,0

                ;checkscriptend