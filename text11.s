                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 4

                rorg $0000
                
                dc.w text11_0
                dc.w text11_1
                dc.w text11_2
                dc.w text11_3

text11_0:       dc.b 34,"JEFF HERE. THIS MUST BE THE AI'S LINK. LET'S GET TO WORK.",34,0

text11_1:       dc.b 34,"WHAT? THIS ISN'T THE MILITARY LINE, BUT TRAFFIC BETWEEN TWO ENTITIES. WAIT A MINUTE.. JORMUNGANDR. "
                dc.b "IT'S SOME KIND OF FAILSAFE PROTOCOL. FAIL-DEADLY, I MEAN. IF EITHER END FALLS SILENT, SOMETHING BAD HAPPENS. "
                dc.b "I'LL SEE WHAT I CAN DO AND GET BACK TO YOU.",34,0

text11_2:       dc.b 34,"I'M GETTING BI-DIRECTIONAL TRAFFIC, JUST LIKE I IMAGINED. THIS IS THE REVENGE PROTOCOL. "
                dc.b "WILL BEGIN DECODING IT NOW. BACK IN A MINUTE.",34,0

text11_3:       dc.b 34,"JEFF AGAIN. MANAGED TO IDENTIFY A SEQUENCE WHICH I CAN REPLAY ENDLESSLY. "
                dc.b "WE'LL SEE HOW IT GOES WHEN YOU TAKE OUT JORMUNGANDR. DO NOT, I REPEAT DO NOT ATTACK THE AI FIRST. ITS SEQUENCE "
                dc.b "MUTATES CONSTANTLY, WHICH I CAN'T SPOOF.",34,0

dataEnd:
                rend
