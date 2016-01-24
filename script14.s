                include macros.s
                include mainsym.s

        ; Script 14, escort scientists begins

                org scriptCodeStart

                dc.w EscortScientistsStart

        ; Start escort scientists sequence
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: various

EscortScientistsStart:
                ldy #C_SCIENTIST                ;Ensure sprite file on the same frame as first script exec
                jsr EnsureSpriteFile
                ldx actIndex
                lda actXH,x
                sec
                sbc actXH+ACTI_PLAYER
                cmp #$03
                bcs ESS_WaitUntilClose
                lda scriptVariable
                asl
                tay
                lda ESS_JumpTbl,y
                sta ESS_Jump+1
                lda ESS_JumpTbl+1,y
                sta ESS_Jump+2
ESS_Jump:       jmp $1000

ESS_JumpTbl:    dc.w ESS_1
                dc.w ESS_2
                dc.w ESS_3

ESS_1:          inc scriptVariable
                jsr AddQuestScore
                ldy #ACT_SCIENTIST2
                gettext txtEscortStart1
                jmp SpeakLine

ESS_2:          inc scriptVariable
                ldy #ACT_SCIENTIST3
                gettext txtEscortStart2
                jmp SpeakLine

ESS_3:          inc scriptVariable
                ldy #ACT_SCIENTIST2
                gettext txtEscortStart3
                jsr SpeakLine
                lda #<EP_ESCORTSCIENTISTSREFRESH
                ldx #>EP_ESCORTSCIENTISTSREFRESH
                sta actScriptEP
                stx actScriptF
                sta actScriptEP+1
                stx actScriptF+1
ESS_WaitUntilClose:
                rts

        ; Messages
        ; Reordered to compress better
        
txtEscortStart2:dc.b 34,"NO-ONE TOOK NOTICE WHILE THE AI ORDERED HUGE SHIPMENTS TO BUILD THIS THING UNDERGROUND. "
                dc.b "I BELIEVE IT'S RE-ENACTING THE RAGNAROK MYTH - JORMUNGANDR POISONING THE SKY. "
                dc.b "IF IT BURROWS WITHIN THE CRUST AND DISTURBS THE PLATE BOUNDARIES, IN THEORY IT COULD TRIGGER HUGE VOLCANIC ERUPTIONS "
                dc.b "THAT BLOT OUT THE SUN AND BEGIN A NEW ICE AGE. "
                dc.b "IT'S A LOT TO ASK, BUT OUR BELIEF IS THAT YOU MUST VENTURE BELOW AND DISABLE JORMUNGANDR. THERE'S "
                dc.b "NO KNOWING IF IT'S ALREADY READY TO ACT, SO WAITING FOR THE CAVALRY COULD BE TOO LATE.",34,0

txtEscortStart3:dc.b 34,"YOU'LL NEED A LUNG FILTER TO SURVIVE THE TUNNELS. THAT MEANS A SECOND SURGERY. THIS REQUIRES THE OPERATING ROOM ON THE LOWER LABS' "
                dc.b "RIGHT SIDE, AT THE VERY BOTTOM. PLEASE LEAD THE WAY.",34,0

txtEscortStart1:dc.b 34,"THERE YOU ARE. I'LL LET LINDA EXPLAIN.",34,0

                checkscriptend