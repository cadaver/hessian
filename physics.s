        ; Move actor in a straight line and return charinfo from final position
        ;
        ; Parameters: X actor index
        ; Returns: A charinfo
        ; Modifies: A,X,Y,temp vars

MoveProjectile: lda actSX,x
                jsr MoveActorX
                lda actSY,x
                jsr MoveActorY
                jmp GetCharInfoActor