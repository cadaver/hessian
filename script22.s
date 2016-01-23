                include macros.s
                include mainsym.s

        ; Script 22, second cave

                org scriptCodeStart

                dc.w InstallLaptop
                dc.w InstallLaptopWork
                dc.w InstallLaptopFinish
                dc.w HackerFinal

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
                lda #<EP_HACKERFINAL
                sta actScriptEP+2
                lda #>EP_HACKERFINAL
                sta actScriptF+2
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
                gettext txtInstallStart
                jsr RadioMsg
                lda #JOY_DOWN                   ;Crouch to place the laptop
                sta actMoveCtrl+ACTI_PLAYER
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
ILW_VariationA: gettext txtSignalUnknown
                jmp RadioMsg
ILW_VariationB: gettext txtSignalKnown
RadioMsg:       ldy #ACT_PLAYER
                jsr SpeakLine
                lda #SFX_RADIO
                jmp PlaySfx

        ; Install laptop finish (while climbing to exit)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various
        
InstallLaptopFinish:
                lda #PLOT_DISRUPTCOMMS
                jsr GetPlotBit
                beq ILF_NotYet                  ;May visit here without laptop
                gettext txtInstallFinish
                jmp RadioMsg
ILF_NotYet:     ldy lvlObjNum
                jmp InactivateObject

        ; Jeff interaction if return to lab after installing laptop
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

HackerFinal:    lda actXH+ACTI_PLAYER
                cmp #$84
                bcc HF_TooFar
                jsr AddQuestScore
                lda #$00
                sta actScriptF+2
                gettext txtHackerFinal
                ldy #ACT_HACKER
                jmp SpeakLine
HF_TooFar:      rts

        ; Messages

txtInstallStart:dc.b 34,"JEFF HERE. THIS MUST BE THE AI'S LINK. LET'S GET TO WORK.",34,0

txtSignalUnknown:
                dc.b 34,"WHAT? THIS ISN'T THE MILITARY LINE, BUT TRAFFIC BETWEEN TWO ENTITIES. WAIT A MINUTE.. JORMUNGANDR. "
                dc.b "IT'S SOME KIND OF FAILSAFE PROTOCOL. FAIL-DEADLY, I MEAN. IF EITHER END FALLS SILENT, SOMETHING BAD HAPPENS. "
                dc.b "I'LL SEE WHAT I CAN DO AND GET BACK TO YOU.",34,0

txtSignalKnown: dc.b 34,"I'M GETTING BI-DIRECTIONAL TRAFFIC, JUST LIKE I IMAGINED. THIS IS THE REVENGE PROTOCOL. "
                dc.b "WILL BEGIN DECODING IT NOW. BACK IN A MINUTE.",34,0

txtInstallFinish:
                dc.b 34,"JEFF AGAIN. MANAGED TO IDENTIFY A SEQUENCE WHICH I CAN REPLAY ENDLESSLY. "
                dc.b "WE'LL SEE HOW IT GOES WHEN YOU TAKE OUT JORMUNGANDR. DO NOT, I REPEAT DO NOT ATTACK THE AI FIRST. ITS SEQUENCE "
                dc.b "MUTATES CONSTANTLY, WHICH I CAN'T SPOOF.",34,0

txtHackerFinal: dc.b 34,"HEY. YOU SHOULD BE KICKING JORMUNGANDR AND CONSTRUCT ASS. I'VE NO WORRIES HERE. WELL, "
                dc.b "EXCEPT WHETHER YOU'LL RETURN ALIVE. TRY TO DO THAT, RIGHT? NOW GO KICK ASS ALREADY.",34,0

                checkscriptend
