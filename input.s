JOY_UP          = 1
JOY_DOWN        = 2
JOY_LEFT        = 4
JOY_RIGHT       = 8
JOY_FIRE        = 16
JOY_JUMP        = 32

KEY_DEL         = 0
KEY_RETURN      = 1
KEY_CURSORLR    = 2
KEY_F7          = 3
KEY_F1          = 4
KEY_F3          = 5
KEY_F5          = 6
KEY_CURSORUD    = 7
KEY_3           = 8
KEY_W           = 9
KEY_A           = 10
KEY_4           = 11
KEY_Z           = 12
KEY_S           = 13
KEY_E           = 14
KEY_SHIFT1      = 15
KEY_5           = 16
KEY_R           = 17
KEY_D           = 18
KEY_6           = 19
KEY_C           = 20
KEY_F           = 21
KEY_T           = 22
KEY_X           = 23
KEY_7           = 24
KEY_Y           = 25
KEY_G           = 26
KEY_8           = 27
KEY_B           = 28
KEY_H           = 29
KEY_U           = 30
KEY_V           = 31
KEY_9           = 32
KEY_I           = 33
KEY_J           = 34
KEY_0           = 35
KEY_M           = 36
KEY_K           = 37
KEY_O           = 38
KEY_N           = 39
KEY_PLUS        = 40
KEY_P           = 41
KEY_L           = 42
KEY_MINUS       = 43
KEY_COLON       = 44
KEY_DOUBLECOLON = 45
KEY_AT          = 46
KEY_COMMA       = 47
KEY_POUND       = 48
KEY_ASTERISK    = 49
KEY_SEMICOLON   = 50
KEY_HOME        = 51
KEY_SHIFT2      = 52
KEY_EQUALS      = 53
KEY_ARROWU      = 54
KEY_SLASH       = 55
KEY_1           = 56
KEY_ARROWL      = 57
KEY_CTRL        = 58
KEY_2           = 59
KEY_SPACE       = 60
KEY_CBM         = 61
KEY_Q           = 62
KEY_RUNSTOP     = 63
KEY_NONE        = $ff

        ; Reads joystick + scans the keyboard.
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A

GetControls:    
                if REDUCE_CONTROL_LATENCY > 0   ;In control latency reduction mode, wait here
GC_Wait:        lda newFrame                    ;until sprite IRQ is done with the current sprites
                bmi GC_Wait                     ;to ensure we don't get controls two frames ahead
                endif
                lda #$ff
                sta $dc00
                lda joystick
                sta prevJoy
                lda $dc00
                eor #$ff
                and #JOY_UP|JOY_DOWN|JOY_LEFT|JOY_RIGHT|JOY_FIRE
                sta joystick

        ; Reads keyboard.
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y,temp1

ScanKeys:       lda #$ff
                sta keyType
                ldy #$07
SK_RowLoop:     ldx keyRowBit,y
                stx $dc00
                ldx $dc01
                stx keyRowTbl,y
                cpx #$ff
                beq SK_RowEmpty
                tya
SK_RowEmpty:    dey
                bpl SK_RowLoop
                tax
                bmi SK_NoKey
                asl
                asl
                asl
                sta temp1
                ldy #$07
                lda keyRowTbl,x
SK_ColLoop:     asl
                bcc SK_KeyFound
                dey
                bpl SK_ColLoop
SK_KeyFound:    tya
                ora temp1
                cmp keyPress
                beq SK_SameKey
                sta keyType
                sta keyPress
SK_SameKey:

        ; "Joystick" control with keyboard, with keys Q W E and SHIFT for fire.
        ;                                             A   D
        ;                                             Z X C
        ;
        ; Parameters: -
        ; Returns: -
        ; Modifies: A,X,Y

KeyControl:     ldx #$09
KC_Loop:        ldy kcRowNum,x
                lda keyRowTbl,y
                and kcRowAnd,x
                beq KC_Pressed
KC_Next:        dex
                bpl KC_Loop
                rts
KC_Pressed:     lda joystick
                ora kcJoyBits,x
                sta joystick
                bne KC_Next
SK_NoKey:       sta keyPress
                rts

        ; Checks if fire button has been pressed on this frame
        ;
        ; Parameters: -
        ; Returns: C=0 not pressed, C=1 pressed
        ; Modifies: A

GetFireClick:   clc
                lda prevJoy
                and #JOY_FIRE
                bne GFC_Not
                lda joystick
                and #JOY_FIRE
                beq GFC_Not
                sec
GFC_Not:        rts
