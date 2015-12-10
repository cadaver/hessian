        ; Loader depacker

                include kernal.s
                include memory.s

                org exomizerCodeStart

tablBi          = depackBuffer
tablLo          = depackBuffer + 52
tablHi          = depackBuffer + 104

; -------------------------------------------------------------------
; This source code is altered and is not the original version found on
; the Exomizer homepage.
; It contains modifications made by Krill/Plush to depack a packed file
; crunched forward and to work with his loader.
;
; Modified for Hessian (optimizations, max. sequence 255 bytes) by
; Lasse Oorni
; -------------------------------------------------------------------
;
; Copyright (c) 2002 - 2005 Magnus Lind.
;
; This software is provided 'as-is', without any express or implied warranty.
; In no event will the authors be held liable for any damages arising from
; the use of this software.
;
; Permission is granted to anyone to use this software for any purpose,
; including commercial applications, and to alter it and redistribute it
; freely, subject to the following restrictions:
;
;   1. The origin of this software must not be misrepresented; you must not
;   claim that you wrote the original software. If you use this software in a
;   product, an acknowledgment in the product documentation would be
;   appreciated but is not required.
;
;   2. Altered source versions must be plainly marked as such, and must not
;   be misrepresented as being the original software.
;
;   3. This notice may not be removed or altered from any distribution.
;
;   4. The names of this software and/or it's copyright holders may not be
;   used to endorse or promote products derived from this software without
;   specific prior written permission.

; -------------------------------------------------------------------
; get bits (29 bytes)
;
; args:
;   x = number of bits to get
; returns:
;   a = #bits_lo
;   x = #0
;   c = 0
;   z = 1
;   zpBitsHi = #bits_hi
; notes:
;   y is untouched
; -------------------------------------------------------------------
get_bits:
  lda #$00
  sta zpBitsHi
  cpx #$01
  bcc bits_done
bits_next:
  lsr zpBitBuf
  bne bits_ok
  pha
  stx loadTempReg
  jsr GetByte
  ldx loadTempReg
  bcs loaderror3
  sec
  ror
  sta zpBitBuf
  pla
bits_ok:
  rol
  rol zpBitsHi
  dex
  bne bits_next
bits_done:
  rts

loaderror3:
  pla
  pla
  pla
loaderror:
  rts

        ; Load file packed with Exomizer 2 forward mode
        ;
        ; Parameters: A,X load address, fileNumber
        ; Returns: C=0 if loaded OK, or C=1 and error code in A (see GetByte)
        ; Modifies: A,X,Y

LoadFile:       sta zpDestLo
                stx zpDestHi
                jsr OpenFile

; -------------------------------------------------------------------
; init zeropage, x and y regs.
;
init_zp:
  jsr GetByte
  ;bcs loaderror  ;Error will be caught later
  sta zpBitBuf
  ldy #0

; -------------------------------------------------------------------
; calculate tables
; x and y must be #0 when entering
;
nextone:
  ldx #1
  tya
  and #$0f
  beq shortcut    ; start with new sequence

  txa          ; this clears reg a
  lsr          ; and sets the carry flag
  ldx tablBi-1,y
rolle:
  rol
  rol zpBitsHi
  dex
  bpl rolle    ; c = 0 after this (rol zpBitsHi)

  adc tablLo-1,y
  tax

  lda zpBitsHi
  adc tablHi-1,y
shortcut:
  sta tablHi,y
  txa
  sta tablLo,y

  ldx #4
  jsr get_bits    ; clears x-reg.
  sta tablBi,y
  iny
  cpy #52
  bne nextone

begin:
  ldy #$ff

; -------------------------------------------------------------------
; decruncher entry point, needs calculated tables
;
getgamma:
  lsr zpBitBuf
  bne norefill
  jsr GetByte
  bcs loaderror
  sec
  ror
  sta zpBitBuf
norefill:
  iny
  bcc getgamma
  bne sequence

literal:
  jsr GetByte
  ;bcs loaderror ;Error will be caught later
  sta (zpDestLo),y
  inc zpDestLo
  bne begin
inchi:
  inc zpDestHi
  bne begin

sequence:
  cpy #$11
  beq eof   ; gamma = 17   : end of file

; -------------------------------------------------------------------
; calculate length of sequence (zp_len)
;
  ldx tablBi-1,y
  jsr get_bits
  adc tablLo-1,y  ; we have now calculated zpLenLo
  sta zpLenLo
; -------------------------------------------------------------------
; here we decide what offset table to use
; x is 0 here
;
  ldy zpLenLo
  cpy #$04
  bcc size123
nots123:
  ldy #$03
size123:
  ldx tablBit-1,y
  jsr get_bits
  adc tablOff-1,y  ; c = 0 after this.
  tay      ; 1 <= y <= 52 here

; -------------------------------------------------------------------
; calulate absolute offset (zp_src)
;
  ldx tablBi,y
  jsr get_bits
  adc tablLo,y
  bcc skipcarry
  inc zpBitsHi
skipcarry:
  sec
  eor #$ff
  adc zpDestLo
  sta zpSrcLo
  lda zpDestHi
  sbc zpBitsHi
  sbc tablHi,y
  sta zpSrcHi

; -------------------------------------------------------------------
; main copy loop
; y = length lo
;
copy_start:
  ldy #$00
copy_next:
  lda (zpSrcLo),y
  sta (zpDestLo),y
  iny
  cpy zpLenLo
  bne copy_next
  tya
  clc
  adc zpDestLo
  sta zpDestLo
  bcc begin
  bcs inchi

eof:
  clc
  rts

tablBit:        dc.b 2,4,4                      ;Exomizer static tables
tablOff:        dc.b 48,32,16

; -------------------------------------------------------------------
; end of decruncher
; -------------------------------------------------------------------

OpenFile:       sei
                lda #$35
                sta $01
                rts

SaveFile        = OpenFile+3

                org OpenFile+6

GetByte:        inc $01
                jsr ChrIn
                sei
                dec $01
                clc
                rts

packedLoaderStart:
                incbin loader.pak