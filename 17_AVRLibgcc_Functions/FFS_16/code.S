; Meaningful name!
;------------------------------------------------------------
; Find First Set bit in a 16 bit value. Returns a 16 bit value
; in R25:R24 which is 1 plus the first bit set, from the LSB,
; in R25:R24. R25 will be zero.
; 
; R25:R24 = FFS32(R25:R24)
; 
; Corrupts R26.
;------------------------------------------------------------
#define Ffs_16 __ffshi2

.global main

; Bit number   1111110000000000
; Bit number   5432109876543210
.equ value_1,0b0001111000100000
;            Bit 5 is the first set bit.    
;            So the result will be 6.

.section .text

main:
    ;--------------------------------------------------------
    ; Expected result:
    ;
    ; R25:R24 = FFS16(R25:R24) = 0x0006
    ;--------------------------------------------------------
    ldi r24,lo8(value_1)
    ldi r25,hi8(value_1) 
    push r26                ; Save corrupted register.
    call Ffs_16             ; __ffshi2
    pop r26                 ; And restore them.

loop:
    rjmp loop

