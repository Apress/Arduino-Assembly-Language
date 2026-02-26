; Meaningful name!
;------------------------------------------------------------
; 16 bit signed by 16 bit unsigned multiply with a 32 bit
; signed result.
; R25:R22 = (signed) R27:R26 * (unsigned) R19:R18.
; Corrupts R0.
;------------------------------------------------------------
#define Mult_s16_u16 __usmulhisi3

.global main

.equ value_1,-12345         ; S16
.equ value_2,11             ; U16

.section .text

main:
    ;--------------------------------------------------------
    ; s16 x u16 multiply = s32 result.
    ; -12345 * 11 = -135,795
    ; 
    ; Expected result:
    ;
    ; -135,795 = 0xFFFDED8D
    ;
    ; R25 = 0xFF
    ; R24 = 0xFD
    ; R23 = 0xED
    ; R22 = 0x8D
    ;--------------------------------------------------------
    ldi r27,hi8(value_1)    ; S16 in R27:R26
    ldi r26,lo8(value_1)

    ldi r19,hi8(value_2)    ; U16 in R19:R18
    ldi r18,lo8(value_2)

    push r0                 ; Preserve corrupted register.
    call Mult_s16_u16       ; __usmulhisi3
    pop r0                  ; And restore.

loop:
    rjmp loop

