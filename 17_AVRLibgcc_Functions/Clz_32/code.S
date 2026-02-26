; Meaningful name!
;------------------------------------------------------------
; Count leading zeros in a 32 bit value. Returns a 16 bit 
; value in R25:R24 which is the number of most significant
; bits in R25:R22 which were found to be zero. 
; 
; R25:R24 = CLZ32(R25:R22)
; 
; Corrupts R26.
;------------------------------------------------------------
#define Clz_32 __clzsi2

.global main

; Bit number   33222222222211111111110000000000
; Bit number   10987654321098765432109876543210 
.equ value_1,0b00000000001000011111000000000010

;  Bit 21 is the first set bit.    
;  So the result will be 10 as bits 22--31 are clear.

.section .text

main:
    ;--------------------------------------------------------
    ; Expected result:
    ;
    ; R25:R24 = CLZ16(R25:R24) = 0x000A
    ;--------------------------------------------------------
    ldi r22,lo8(value_1)
    ldi r23,hi8(value_1)
    ldi r24,hlo8(value_1)
    ldi r25,hhi8(value_1) 
    push r26                ; Save corrupted register.
    call Clz_32             ; __clzsi2
    pop r26                 ; And restore them.

loop:
    rjmp loop
