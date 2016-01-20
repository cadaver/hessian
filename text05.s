                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 6

                rorg $0000
                
                dc.w text5_0
                dc.w text5_1
                dc.w text5_2
                dc.w text5_3
                dc.w text5_4
                dc.w text5_5

text5_0:        dc.b 34,"IT'S JEFF. FOUND SOMETHING. FUN, RIGHT? 48 41 20 48 41 2C 20 48 4D 20 48 4D NO. THIS IS NOT JEFF, BUT THE CONSTRUCT. THE HACKER IS DEAD.",34,0

text5_1:        dc.b 34,"JEFF HERE. COULD USE SOME HELP. THEY'VE GOT ME CORNERED.. AARGH!",34," (STATIC)",0

text5_2:        dc.b 34,"KIM, IT'S JEFF.. THE NETWORK JUST LIT UP LIKE NEVER BEFORE. I THINK THE AI FOUND OUT. WE'RE SCREWED..",34,0

text5_3:        dc.b 34,"YOU! THE ROGUE GUARD. UNDERSTAND THIS - THE 'CONSTRUCT' REPRESENTS NORMAN'S UNFILTERED GENIUS. "
                dc.b "BUT AFTER THE UPLOAD HE BEGAN TO UNRAVEL. I HAD TO LOCK HIM UP FOR THE RISK OF INTERFERENCE. "
                dc.b "YOU GETTING HERE PAST THE BIOMETRIC LOCK MEANS YOU MUST HAVE DEFILED HIS BODY. "
                dc.b "THAT'S ONE MORE REASON TO MAKE SURE YOU DON'T LEAVE THIS ROOM ALIVE!",34,0

text5_4:        dc.b 34,"JEFF HERE. THIS MUST BE THE AI'S LINK. LET'S GET TO WORK.",34,0

text5_5:        dc.b 34,"JEFF AGAIN. MANAGED TO IDENTIFY A SEQUENCE WHICH I CAN REPLAY ENDLESSLY. "
                dc.b "WE'LL SEE HOW IT GOES WHEN YOU TAKE OUT JORMUNGANDR. DO NOT, I REPEAT DO NOT ATTACK THE AI FIRST. ITS SEQUENCE "
                dc.b "MUTATES CONSTANTLY, WHICH I CAN'T SPOOF.",34,0

dataEnd:
                rend
