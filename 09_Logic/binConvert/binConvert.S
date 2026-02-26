;--------------------------------------------------------------------
; Some binary to ASCII conversion routines. These handle 8, 16
; or 32 bit values. The binary (ASCII) output is written to the
; data location pointed to by the X register.
;
; Norman Dunbar.
; 24 April 2024.
;--------------------------------------------------------------------

.global bin32
.global bin16
.global bin8

.section .text

;--------------------------------------------------------------------
; A macro to generate code to exchange the values in a pair of 
; registers. Simply call with "exg Rx,Ry" as required and the value
; in Rx will be moved to Ry and vice versa.
;--------------------------------------------------------------------
; WARNING: Changes the status flags in SREG, beware.
;--------------------------------------------------------------------
.macro exg Rd,Rs
    eor \Rd,\Rs
    eor \Rs,\Rd
    eor \Rd,\Rs
.endm

;--------------------------------------------------------------------
; Expects X to point at the destination in .data section.
; Expects value in R22:R25 with R22:R23 the low word.
;
; Call hex16. R25:R25 is the high word.
; Swap words in R24:R25 and R22:R23.
; Drop into hex16.
;--------------------------------------------------------------------
bin32:
    rcall bin16         ; Convert the high word in R24:R25.
    exg r24,r22         ; Exchange R22 and R24.
    exg r25,r23         ; Exchange R23 and R25.
                        ; Drop in to convert the low word.


;--------------------------------------------------------------------
; Expects X to point at the destination in .data section.
; Expects value in R24:R25 with R24 the low byte. Converts R25 first
; then R24.
;
; Swap bytes in R25 and R24.
; Call hex8.
; Swap back.
; Drop into hex8.
;--------------------------------------------------------------------
bin16:
    exg r24,r25         ; Exchange R24 and R25.
    rcall bin8          ; Convert high byte.
    exg r24,r25         ; Exchange R24 and R25 back.
                        ; Drop in to convert the low byte.
                        
;--------------------------------------------------------------------
; Expects X to point at the destination in .data section.
; Expects a data value in R24.
;--------------------------------------------------------------------
bin8:
    push r19            ; R19 is the ASCII 1 or 0 character.
    push r18            ; R18 counts the bits to convert.
    ldi r18,8           ; Eight bits to convert.

binBits:
    ldi r19,'0'         ; Assume a zero bit.
    lsl r24             ; Bit 7 into Carry flag.
    brcc bitStore       ; Must be a zero bit.
    inc r19             ; Must be a one bit.

bitStore:
    st x+,r19           ; Add ASCII 1/0 to buffer.
    dec r18             ; One less bits to be converted.
    brne binBits        ; Not yet finished? Do more.
    pop r18             ; Restore working registers.
    pop r19
    ret                 ; Done.
