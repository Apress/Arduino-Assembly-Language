; Meaningful name!
;------------------------------------------------------------
; 8 bit signed by 8 bit signed divide with an 8 bit 
; signed result and an 8 bit signed remainder.
; (int8_t) R25 / (int8_t) R24 = (int8_t) R24 rem (int8_t) R25.
; Corrupts R0, R22, R23.
;------------------------------------------------------------
#define Div_s8_s8 __divmodqi4

.global main

.equ value_1,125            ; S8
.equ value_2,-7             ; S8

.section .text

main:
    ;--------------------------------------------------------
    ; S8 by S8 divide = S8 result & U8 remainder.
    ; 125 / -7 = -17 remainder 6.
    ; 
    ; Expected result:
    ;
    ; -17 = 0xEF, 6 = 0x06 
    ;
    ; R25 = 0x06
    ; R24 = 0xEF
    ;--------------------------------------------------------
    ldi r24,value_1         ; S8 dividend in R24. 
    ldi r22,value_2         ; S8 divisor in R22.
    push r0                 ; Save these if used in code.
    push r22
    push r23
    call Div_s8_s8          ; __udivmodqi4
    pop r23
    pop r22
    pop r0

loop:
    rjmp loop

