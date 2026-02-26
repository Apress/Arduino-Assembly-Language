; Meaningful name!
;------------------------------------------------------------
; Find First Set bit in a 32 bit value. Returns a 16 bit value
; in R25:R24 which is 1 plus the first bit set, from the LSB, 
; in R25:R22. R25 will be zero.
; 
; R25:R24 = FFS32(R25:R22)
; 
; Corrupts R22, R26.
;------------------------------------------------------------
#define Ffs_32 __ffssi2

.global main

; Bit number   33222222222211111111110000000000
; Bit number   10987654321098765432109876543210 
.equ value_1,0b00011110001000011111000000000010
;            Bit 1 is the first set bit.    
;            So the result will be 2.

.section .text

main:
    ;--------------------------------------------------------
    ; Expected result:
    ;
    ; R25:R24 = FFS32(0x1E21F003) = 0x0001
    ;--------------------------------------------------------
    ldi r22,lo8(value_1)
    ldi r23,hi8(value_1) 
    ldi r24,hlo8(value_1)
    ldi r25,hhi8(value_1) 
    push r22                ; Save corrupted registers.
    push r26
    call Ffs_32             ; __ffssi2
    pop r26                 ; And restore them.
    pop r22

loop:
    rjmp loop

