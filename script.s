SCRIPT_TITLE    = 0

EP_TITLE        = $0000
EP_RESTART      = $0001

        ; Execute a script
        ;
        ; Parameters: Y script file, A script entrypoint, X parameter (optional)
        ; Returns: -
        ; Modifies: A,X,Y,temp vars,actor ZP temp vars

ExecScript:     asl
                sta temp1
                stx temp2
ES_LoadedScriptFile:
                cpy #$ff                        ;Check if same file already loaded
                beq ES_SameFile
                sty ES_LoadedScriptFile+1
                tya
                ldx #F_SCRIPT
                jsr MakeFileName
                lda #<scriptCodeStart
                ldx #>scriptCodeStart
                jsr LoadFileRetry
                jsr PostLoad
ES_SameFile:    ldx temp1
                lda scriptCodeStart,x
                sta ES_ScriptJump+1
                lda scriptCodeStart+1,x
                sta ES_ScriptJump+2
                ldx temp2
ES_ScriptJump:  jmp $1000

