; Meaningful name!
;------------------------------------------------------------
; Count leading zeros in a 16 bit value. Returns a 16 bit 
; value in R25:R24 which is the number of most significant
; bits in R25:R24 which were found to be zero. 
; 
; R25:R24 = CLZ16(R25:R24)
; 
; Corrupts R26.
;------------------------------------------------------------
#define Clz_16 __clzhi2

.global main

; Bit number   1111110000000000
; Bit number   5432109876543210 
.equ value_1,0b0001111000100000
;   Bit 12 is the first most significant set bit.    
;   So the result will be 3 as bits 15--13 are clear.

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
    call Clz_16             ; __clzhi2
    pop r26                 ; And restore them.

loop:
    rjmp loop
