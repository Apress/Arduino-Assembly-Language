; Meaningful name!
;------------------------------------------------------------
; 16 bit unsigned by 16 bit unsigned divide with an 16 bit 
; unsigned result and an 16 bit unsigned remainder.
; (uint16_t) R25:R24 / (uint16_t) R23:R22 = (uint16_t) R23:R22 
; remainder (uint16_t) R27:R26.
; Corrupts R0, R21 (will be zero).
;------------------------------------------------------------
#define Div_u16_u16 __udivmodhi4

.global main

.equ value_1,65534          ; U16
.equ value_2,12517          ; U16

.section .text

main:
    ;--------------------------------------------------------
    ; u16 by u16 divide = u16 result & u16 remainder.
    ; 65534 / 12517 = 5 remainder 2949.
    ; 
    ; Expected result:
    ;
    ; 5 = 0x0005, 361 = 0x0B85 
    ;
    ; R23:R22 = 0x0005
    ; R27:R26 = 0x0B85
    ;--------------------------------------------------------
    ldi r24,lo8(value_1)    ; U16 dividend in R25:R24.
    ldi r25,hi8(value_1)         
    ldi r22,lo8(value_2)    ; U16 divisor in R23:R22.
    ldi r23,hi8(value_2)
    push r0                 ; Save these if used in code.
    push r21
    call Div_u16_u16        ; __udivmodhi4
    pop r21
    pop r0

loop:
    rjmp loop

