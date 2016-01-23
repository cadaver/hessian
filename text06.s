                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 4

                rorg $0000

                dc.w text6_0
                dc.w text6_1
                dc.w text6_2

        ; Reordered to compress better

text6_2:        dc.b "ALSO TAKE THIS LAPTOP. IF YOU CAN FIND THE DEDICATED LINK, I'D LIKE TO ANALYZE THE TRAFFIC, TO "
                dc.b "SEE IF WE CAN JUST SAFELY CUT THE AI'S ACCESS.",34,0

text6_1:        dc.b 34,"THEY JAMMED THE RADIO AND FOOLED THE DOOR CAMERA TO GET IN. ONE MORE SECOND AND.. "
                dc.b "I'D HUG YOU, BUT THOSE GUNS ARE IN THE WAY. WILL SET A HARD LOCK-DOWN NOW, "
                dc.b "SO USE THE RECYCLER IF YOU NEED.",0

text6_0:        dc.b 34,"IT'S JEFF. SAW YOU FOUND ACCESS TO THE BIO-DOME. NASTY. IT'S POSSIBLE THE AI IS SITUATED SOMEWHERE INSIDE. "
                dc.b "FOUND ALSO SOMETHING MORE. THERE'S A BLACKOUT TO THE OUTSIDE, RIGHT? BUT A DEDICATED LINK "
                dc.b "WAS INSTALLED FOR THE MILITARY PROJECT. I CAN SEE THAT THERE'S TRAFFIC ON IT, BUT CAN'T SEE WHAT WITHOUT "
                dc.b "PHYSICAL ACCESS. I BET IT'S THE AI. HMM.. WHAT? I'M SEEING MOVE-",34," (STATIC)",0

text6_3:        dc.b 34,"SUCKS IT HAPPENED LIKE THIS. BUT BETTER WITH YOU HERE. JUST.. PROMISE TO KICK THEIR ASS.",34,0

dataEnd:
                rend