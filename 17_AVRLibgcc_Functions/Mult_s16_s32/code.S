; Meaningful name!
;------------------------------------------------------------
; 16 bit signed by 32 bit signed multiply with a 32 bit
; signed result.
; R25:R22 = (signed) R27:R26 * (signed) R21:R18.
; Corrupts R0.
;------------------------------------------------------------
#define Mult_s16_s32 __mulshisi3

.global main

.equ value_1,123            ; S16
.equ value_2,-12345         ; S32

.section .text

main:
;--------------------------------------------------------
; s16 x s32 multiply = s32 result.
; 123 * -12345 = -1,518,435
;
; Expected result:
;
; -1,518,435 = 0xFFE8D49D
;
; R25 = 0xFF
; R24 = 0xE8
; R23 = 0xD4
; R22 = 0x9D
;--------------------------------------------------------
    ldi r27,hi8(value_1)    ; S16 in R27:R26
    ldi r26,lo8(value_1)

    ldi r21,hhi8(value_2)   ; S32 in R21:R18
    ldi r20,hlo8(value_2)
    ldi r19,hi8(value_2)
    ldi r18,lo8(value_2)


    push r0                 ; Preserve corrupted register.
    call Mult_s16_s32       ; __mulshisi3
    pop r0                  ; And restore.

loop:
    rjmp loop