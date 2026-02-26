; Meaningful name!
;------------------------------------------------------------
; 32 bit signed by 32 bit signed divide with a 32 bit 
; signed result and a 32 bit signed remainder.
; (int32_t) R25:R22 / (int32_t) R21:R18 = (int32_t) R21:R18 
; remainder (int32_t) R31:R30:R27:R26.
; Function uses R0, but returns it as zero, so unchanged.
;------------------------------------------------------------
#define Div_s32_s32 __divmodsi4

.global main

.equ value_1,0x7FFFFFFF     ; S32 = 2,147,483,647
.equ value_2,-10            ; S32 = -10

.section .text

main:
    ;--------------------------------------------------------
    ; S32 by S32 divide = S32 result & U32 remainder.
    ; 2,147,483,647 / -10 = -214,748,364 remainder 7.
    ; 
    ; Expected result:
    ;
    ; -214,748,364 = 0xF333 3334, 7 = 0X0007 
    ;
    ;         R21:R18 = 0xF333 3334
    ; R31:R30:R27:R26 = 0x0000 0007
    ;--------------------------------------------------------
    ldi r22,lo8(value_1)    ; S32 dividend in R25:R22.
    ldi r23,hi8(value_1)  
    ldi r24,hlo8(value_1)
    ldi r25,hhi8(value_1) 

    ldi r18,lo8(value_2)    ; S32 divisor in R21:R18.
    ldi r19,hi8(value_2)
    ldi r20,hlo8(value_2)
    ldi r21,hhi8(value_2) 
    call Div_s32_s32        ; __divmodsi4

loop:
    rjmp loop

