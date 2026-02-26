; Meaningful name!
;------------------------------------------------------------
; 16 bit unsigned by 16 bit unsigned multiply with a 32 bit
; unsigned result.
; R25:R22 = (unsigned) R27:R26 * (unsigned) R19:R18.
; Corrupts R0.
;------------------------------------------------------------
#define Mult_u16_u16 __umulhisi3

.global main

.equ value_1,12345          ; U16
.equ value_2,10             ; U16

.section .text

main:
    ;--------------------------------------------------------
    ; u16 x u16 multiply = u32 result.
    ; 12345 * 10 = 123,450
    ; 
    ; Expected result:
    ;
    ; 123,450 = 0x0001E23A
    ;
    ; R25 = 0x00
    ; R24 = 0x01
    ; R23 = 0xE2
    ; R22 = 0x3A
    ;--------------------------------------------------------
    ldi r27,hi8(value_1)    ; U16 in R27:R26
    ldi r26,lo8(value_1)

    ldi r19,hi8(value_2)    ; U16 in R19:R18
    ldi r18,lo8(value_2)

    push r0                 ; Preserve corrupted register.
    call Mult_u16_u16       ; __umulhisi3
    pop r0                  ; And restore.

loop:
    rjmp loop

