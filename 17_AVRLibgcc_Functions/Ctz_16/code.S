; Meaningful name!
;------------------------------------------------------------
; Count trailing zeros in a 16 bit value. Returns a 16 bit 
; value in R25:R24 which is the number of least significant
; bits in R25:R24 which were found to be zero. 
; 
; R25:R24 = CTZ16(R25:R24)
; 
; Corrupts R26.
;------------------------------------------------------------
#define Ctz_16 __ctzhi2

.global main

; Bit number   1111110000000000
; Bit number   5432109876543210 
.equ value_1,0b0001111000100000

;   Bit 5 is the first least significant set bit.    
;   So the result will be 5 as bits 4--0 are clear.

.section .text

main:
    ;--------------------------------------------------------
    ; Expected result:
    ;
    ; R25:R24 = CLZ16(R25:R24) = 0x0003
    ;--------------------------------------------------------
    ldi r24,lo8(value_1)
    ldi r25,hi8(value_1) 
    push r26                ; Save corrupted register.
    call Ctz_16             ; __ctzhi2
    pop r26                 ; And restore them.

loop:
    rjmp loop
