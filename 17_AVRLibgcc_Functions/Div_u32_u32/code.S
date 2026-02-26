; Meaningful name!
;------------------------------------------------------------
; 32 bit unsigned by 32 bit unsigned divide with a 32 bit 
; unsigned result and a 32 bit unsigned remainder.
; (uint32_t) R25:R22 / (uint32_t) R21:R18 = (uint32_t) R21:R18 
; remainder (uint32_t) R31:R30:R27:R26.
; Function uses R0, but returns it as zero, so unchanged.
;------------------------------------------------------------
#define Div_u32_u32 __udivmodsi4

.global main

.equ value_1,0xFE00123D     ; U32 = 4,261,417,533
.equ value_2,0x0012DBB3     ; U32 = 1,235,891

.section .text

main:
    ;--------------------------------------------------------
    ; u32 by u32 divide = u32 result & u32 remainder.
    ; 4,261,417,533 / 1,235,891 = 3,448 remainder 65,365.
    ; 
    ; Expected result:
    ;
    ; 3,448 = 0x0D78, 65,365 = 0xFF55 
    ;
    ;         R21:R18 = 0x0000 0D78
    ; R31:R30:R27:R26 = 0x0000 FF55
    ;--------------------------------------------------------
    ldi r22,lo8(value_1)    ; U32 dividend in R25:R22.
    ldi r23,hi8(value_1)  
    ldi r24,hlo8(value_1)
    ldi r25,hhi8(value_1) 

    ldi r18,lo8(value_2)    ; U32 divisor in R21:R18.
    ldi r19,hi8(value_2)
    ldi r20,hlo8(value_2)
    ldi r21,hhi8(value_2) 
    ;push r0                 ; Save these if used in code.
    ;push r21
    call Div_u32_u32        ; __udivmodsi4
    ;pop r21
    ;pop r0

loop:
    rjmp loop

