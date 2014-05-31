                include macros.s
                include mainsym.s

        ; Script 1, testing

                org scriptCodeStart

                dc.w ActorTrigger0100
                dc.w ActorTrigger0101
                dc.w TestContinuous0102

ActorTrigger0100:
                settrigger ACT_TESTNPC,$0101,AT_NEAR
                speak ACT_TESTNPC,Line1
                rts

ActorTrigger0101:
                checkitem ITEM_SHIV
                bcc AT0101_NoShiv
                removetrigger ACT_TESTNPC
                removeitem ITEM_SHIV
                speak ACT_TESTNPC,Line2
                setscript $0102
AT0101_NoShiv:  rts

Line1:          dc.b 34,"FETCH ME THE SHIV.",34,0
Line2:          dc.b 34,"YOU HAVE DONE WELL.",34,0

TestContinuous0102:
                inc $d020
                rts

                checkscriptend
