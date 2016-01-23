                processor 6502
                org $0000
                
                dc.w dataEnd
                dc.b 3

                rorg $0000

                dc.w text4_0
                dc.w text4_1
                dc.w text4_2

text4_0:        dc.b 34,"IT'S AMOS. EXCELLENT WORK. WITH LUCK, THESE CAVES LEAD YOU TO THE LOWER LABS. ONCE THERE, "
                dc.b "SEE IF YOU CAN UNLOCK THE ELEVATOR. DON'T BE ALARMED IF YOU SEE "
                dc.b "UNUSUAL CAVE DWELLERS. THERE HAVE BEEN LEAKS OF SOME STRONGLY MUTAGENIC CHEMICALS.",34,0

text4_1:        dc.b 34,"LINDA HERE. WE GOT JEFF TO HELP - HE MANAGED TO DECRYPT SOME OF THE MACHINE "
                dc.b "COMMUNICATIONS. THEIR ACTIVITY IS FOCUSED ON THE TUNNELS THAT LEAD FURTHER BELOW "
                dc.b "FROM THE LOWER LABS. THEY'VE BUILT SOMETHING CALLED "
                dc.b "'JORMUNGANDR.' THAT DOESN'T SOUND GOOD. THE AIR DOWN THERE IS TOXIC. "
                dc.b "WE MUST FIGURE OUT HOW TO PROCEED. MEANWHILE, YOU JUST GET THE ELEVATOR WORKING.",34,0

text4_2:        dc.b 34,"AMOS HERE. GREAT JOB FIXING THE ELEVATOR. WE'VE FIGURED OUT THE NEXT STEP. "
                dc.b "WILL TELL THE DETAILS IN PERSON. WE'RE NOW AT THE UPPER LABS RECYCLER, MEET US THERE.",34,0

dataEnd:
                rend