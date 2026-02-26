; Meaningful name!
;------------------------------------------------------------
; 32 bit Signed by 32 bit Signed multiply with a 64 bit
; result.
; R25:R18 = (signed) R25:R22 * (signed) R21:R18.
; Corrupts R0, R31, R30, R27, R26.
;------------------------------------------------------------
#define Mult_s32_s32 __mulsidi3

.global main

.equ value_1,123456         ; S32
.equ value_2,-1234          ; S32

.section .text

main:
    ;--------------------------------------------------------
    ; s32 x s32 multiply = 64 bit signed result.
    ; 123456 * -1234 = -152,344,704
    ; 
    ; Expected result:
    ;
    ; -152,344,704 = FFFFFFFFF6EB6780
    ;
    ; R25:R22 = 0xFF
    ; R21 = 0xF6
    ; R20 = 0xEB
    ; R19 = 0x67
    ; R18 = 0x80
    ;--------------------------------------------------------
    ldi r25,hhi8(value_1)   ; S32 in R25:R22.
    ldi r24,hlo8(value_1)
    ldi r23,hi8(value_1)
    ldi r22,lo8(value_1)

    ldi r21,hhi8(value_2)   ; S32 in R21:R18.
    ldi r20,hlo8(value_2)
    ldi r19,hi8(value_2)
    ldi r18,lo8(value_2)

    push r0                 ; Preserve corrupted registers.
    push r31
    push r30
    push r27
    push r26
    call Mult_s32_s32       ; __mulsidi3
    pop r26                 ; And restore.
    pop r27
    pop r30
    pop r31
    pop r0

loop:
    rjmp loop

