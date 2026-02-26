;--------------------------------------------------------------------
; Some binary to hexadecimal conversion routines. These handle 8, 16
; or 32 bit values. The hexadecimal (ASCII) output is written to the
; data location pointed to by the X register.
;
; Norman Dunbar.
; 24 April 2024.
;--------------------------------------------------------------------

.global hex32
.global hex16
.global hex8

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
hex32:
    rcall hex16         ; Convert the high word in R24:R25.
    exg r24,r22         ; Exchange R22 and R24.
    exg r25,r23         ; Exchange R23 and R25.
                        ; Drop in to convert the low word.


;--------------------------------------------------------------------
; Expects X to point at the destination in .data section.
; Expects value in R24:R25 with R24 the low byte.
;
; Swap bytes in R25 and R24.
; Call hex8.
; Swap back.
; Drop into hex8.
;--------------------------------------------------------------------
hex16:
    exg r24,r25         ; Exchange R24 and R25.
    rcall hex8          ; Convert high byte.
    exg r24,r25         ; Exchange R24 and R25 back.
                        ; Drop in to convert the low byte.
                        
;--------------------------------------------------------------------
; Expects X to point at the destination in .data section.
; Expects value in R24.
;
; Swap nibbles in R24.
; Call hex4.
; Swap nibbles.
; Drop into hex4.
;--------------------------------------------------------------------
hex8:
    swap r24            ; Swap nibbles around.
    rcall hex4          ; Convert high nibble.
    swap r24            ; Swap nibbles back.
                        ; Drop in to convert the low nibble.

;--------------------------------------------------------------------
; Expects X to point at the destination in .data section.
; Expects value in R24.
;
; Save byte on stack
; Mask out high nibble.
; Convert to hexadecimal.
; Store at X+.
; Restore byte from stack.
; Return to caller.
;--------------------------------------------------------------------
hex4:  
    push r24            ; Save current byte.
    andi r24,0x0f       ; Mask off top nibble.
    subi r24,-'0'       ; Convert to ASCII digit.
    cpi r24,10+'0'      ; Need adjusting?
    brlo storeX         ; No.
    subi r24,-7         ; Yes, add adjustment.
    
storeX:
    st X+,r24           ; Store ASCII character at X. 
    pop r24             ; Restore current byte. 
    ret                 ; Done.
