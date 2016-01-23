                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 3

                rorg $0000

                dc.w text7_0
                dc.w text7_1
                dc.w text7_2

        ; Reordered to compress better
        
text7_1:        dc.b 34,"NO-ONE PAID ATTENTION, JUST BUSINESS AS USUAL, WHILE THE AI ORDERED HUGE SHIPMENTS TO BUILD THIS THING UNDERGROUND. "
                dc.b "WE THINK IT COULD BE RE-ENACTING THE RAGNAROK MYTH - JORMUNGANDR POISONING THE SKY. "
                dc.b "IF IT BURROWS WITHIN THE CRUST AND DISTURBS THE PLATE BOUNDARIES, IN THEORY IT COULD TRIGGER HUGE VOLCANIC ERUPTIONS "
                dc.b "THAT BLOT OUT THE SUN AND BEGIN A NEW ICE AGE. "
                dc.b "IT'S A LOT TO ASK, BUT OUR BELIEF IS THAT YOU MUST VENTURE BELOW AND DISABLE JORMUNGANDR. THERE'S "
                dc.b "NO KNOWING IF IT'S ALREADY READY TO ACT, SO WAITING FOR THE CAVALRY COULD BE TOO LATE.",34,0

text7_2:        dc.b "YOU'LL NEED A LUNG FILTER TO SURVIVE THE TUNNELS. THAT MEANS A SECOND SURGERY. WE NEED THE OPERATING ROOM ON THE LOWER LABS' "
                dc.b "RIGHT SIDE, AT THE VERY BOTTOM. PLEASE LEAD THE WAY.",34,0

text7_0:        dc.b 34,"THERE YOU ARE. I'LL LET LINDA EXPLAIN.",34,0

dataEnd:
                rend
