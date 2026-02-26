; Meaningful name!
;------------------------------------------------------------
; Count trailing zeros in a 32 bit value. Returns a 16 bit 
; value in R25:R24 which is the number of least significant
; bits in R25:R22 which were found to be zero. 
; 
; R25:R24 = CTZ32(R25:R22)
; 
; Corrupts R22 and R26.
;------------------------------------------------------------
#define Ctz_32 __ctzsi2

.global main

; Bit number   33222222222211111111110000000000
; Bit number   10987654321098765432109876543210 
.equ value_1,0b00000000001000011111000000000000

;  Bit 12 is the first least significant set bit.    
;  So the result will be 12 as bits 11--0 are clear.

.section .text

main:
    ;--------------------------------------------------------
    ; Expected result:
    ;
    ; R25:R24 = CTZ32(R25:R22) = 0x000A
    ;--------------------------------------------------------
    ldi r22,lo8(value_1)
    ldi r23,hi8(value_1)
    ldi r24,hlo8(value_1)
    ldi r25,hhi8(value_1) 
    push r26                ; Save corrupted register.
    push r22
    call Ctz_32             ; __ctzsi2
    pop r22                 ; And restore them.
    pop r26

loop:
    rjmp loop
