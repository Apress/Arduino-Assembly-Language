; Meaningful name!
;------------------------------------------------------------
; 16 bit signed by 16 bit signed multiply with a 32 bit
; signed result.
; R25:R22 = (signed) R27:R26 * (signed) R19:R18.
; Corrupts R0.
;------------------------------------------------------------
#define Mult_s16_s16 __mulhisi3

.global main

.equ value_1,12345          ; S16
.equ value_2,-10            ; S16

.section .text

main:
    ;--------------------------------------------------------
    ; s16 x s16 multiply = s32 result.
    ; 12345 * -10 = -123,450
    ; 
    ; Expected result:
    ;
    ; -123,450 = 0xFFFE1DC6
    ;
    ; R25 = 0xFF
    ; R24 = 0xFE
    ; R23 = 0x1D
    ; R22 = 0xC6
    ;--------------------------------------------------------
    ldi r27,hi8(value_1)    ; S16 in R27:R26
    ldi r26,lo8(value_1)

    ldi r19,hi8(value_2)    ; S16 in R19:R18
    ldi r18,lo8(value_2)

    push r0                 ; Preserve corrupted register.
    call Mult_s16_s16       ; __mulhisi3
    pop r0                  ; And restore.

loop:
    rjmp loop

