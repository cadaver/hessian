                include macros.s
                include mainsym.s

CHUNK_DURATION = 40

        ; Script 7, lower labs interactions

                org scriptCodeStart

                dc.w DisconnectSubnet
                dc.w InstallFilter

        ; Subnet router script
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

DisconnectSubnet:
                jsr AddQuestScore
                lda #<txtDisconnected
                ldx #>txtDisconnected
                ldy #REQUIREMENT_TEXT_DURATION
                jsr PrintPanelText
                lda lvlObjB+$4d
                bpl DS_NotBoth
                lda lvlObjB+$4e
                bpl DS_NotBoth
                lda #SFX_POWERUP
                jsr PlaySfx
                lda #PLOT_ELEVATOR1
                jmp SetPlotBit                  ;Todo: other stuff, more prominent effect
DS_NotBoth:     rts

        ; Surgery station script (TODO: remove and replace with proper story elements)
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

InstallFilter:  ldy #ITEM_LUNGFILTER
                jsr FindItem
                bcc IF_NotFound
                jsr RemoveItem
                lda #SFX_POWERUP
                jsr PlaySfx
                lda upgrade
                ora #UPG_TOXINFILTER
                sta upgrade
IF_NotFound:    rts

        ; Messages

txtDisconnected:dc.b "SUBNET ISOLATED",0

                checkscriptend