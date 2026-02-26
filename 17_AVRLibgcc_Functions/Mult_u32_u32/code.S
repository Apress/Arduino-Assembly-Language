; Meaningful name!
;------------------------------------------------------------
; 32 bit Unsigned by 32 bit Unsigned multiply with a 64 bit
; result.
; R25:R18 = (unsigned) R25:R22 * (unsigned) R21:R18.
; Corrupts R0, R31, R30, R27, R26.
;------------------------------------------------------------
#define Mult_u32_u32 __umulsidi3

.global main

.equ value_1,123456         ; U32
.equ value_2,123            ; U32

.section .text

main:
    ;--------------------------------------------------------
    ; u32 x u32 multiply = 64 bit unsigned result.
    ; 123456 * 123 = 15,185,088
    ; 
    ; Expected result:
    ;
    ; 15,185,088 = 0000000000E7B4C0
    ;
    ; R25:R21 = 0x00
    ; R20 = 0xE7
    ; R19 = 0xB4
    ; R18 = 0xC0
    ;--------------------------------------------------------
    ldi r25,hhi8(value_1)   ; U32 in R25:R22.
    ldi r24,hlo8(value_1)
    ldi r23,hi8(value_1)
    ldi r22,lo8(value_1)

    ldi r21,hhi8(value_2)   ; U32 in R21:R18.
    ldi r20,hlo8(value_2)
    ldi r19,hi8(value_2)
    ldi r18,lo8(value_2)

    push r0                 ; Preserve corrupted registers.
    push r31
    push r30
    push r27
    push r26
    call Mult_u32_u32       ; __umulsidi3
    pop r26                 ; And restore.
    pop r27
    pop r30
    pop r31
    pop r0

loop:
    rjmp loop

