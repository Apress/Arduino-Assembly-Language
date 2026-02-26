; Meaningful name!
;------------------------------------------------------------
; 16 bit signed by 16 bit signed divide with an 16 bit 
; signed result and an 16 bit signed remainder.
; (int16_t) R25:R24 / (int16_t) R23:R22 = (int16_t) R23:R22 
; remainder (int16_t) R27:R26.
; Corrupts R0, R21 (will be zero).
;------------------------------------------------------------
#define Div_s16_s16 __divmodhi4

.global main

.equ value_1,-12345         ; S16
.equ value_2,-856           ; S16

.section .text

main:
    ;--------------------------------------------------------
    ; S16 by S16 divide = S16 result & U16 remainder.
    ; -12345 / -856 = 14 remainder 361.
    ; 
    ; Expected result:
    ;
    ; 14 = 0x000E, 361 = 0x0169 
    ;
    ; R23:R22 = 0x000E
    ; R27:R26 = 0x0169
    ;--------------------------------------------------------
    ldi r24,lo8(value_1)    ; S16 dividend in R25:R24.
    ldi r25,hi8(value_1)         
    ldi r22,lo8(value_2)    ; S16 divisor in R23:R22.
    ldi r23,hi8(value_2)
    push r0                 ; Save these if used in code.
    push r21
    call Div_s16_s16        ; __divmodhi4
    pop r21
    pop r0

loop:
    rjmp loop

