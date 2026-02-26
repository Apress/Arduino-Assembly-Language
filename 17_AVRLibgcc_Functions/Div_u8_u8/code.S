; Meaningful name!
;------------------------------------------------------------
; 8 bit unsigned by 8 bit unsigned divide with an 8 bit 
; unsigned result and an 8 bit unsigned remainder.
; (uint8_t) R24 / (uint8_t) R22 = (uint8_t) R24 remainder 
; (uint8_t) R25.
; Corrupts R23.
;------------------------------------------------------------
#define Div_u8_u8 __udivmodqi4

.global main

.equ value_1,250            ; U8
.equ value_2,8              ; U8

.section .text

main:
    ;--------------------------------------------------------
    ; u8 by u8 divide = u8 result & u8 remainder.
    ; 250 / 8 = 31 remainder 2.
    ; 
    ; Expected result:
    ;
    ; 31 = 0x1F, 2 = 0x02 
    ;
    ; R25 = 0x02
    ; R24 = 0x1F
    ;--------------------------------------------------------
    ldi r24,value_1         ; U8 dividend in R24. 
    ldi r22,value_2         ; U8 divisor in R22.
    push r23                ; Save, if used in code.
    call Div_u8_u8          ; __udivmodqi4
    pop r23

loop:
    rjmp loop

