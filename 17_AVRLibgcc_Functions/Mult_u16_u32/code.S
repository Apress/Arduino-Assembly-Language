; Meaningful name!
;------------------------------------------------------------
; 16 bit unsigned by 32 bit unsigned multiply with a 32 bit
; unsigned result.
; R25:R22 = (unsigned) R27:R26 * (unsigned) R21:R18.
; Corrupts R0.
;------------------------------------------------------------
#define Mult_u16_u32 __umulhisi3

.global main

.equ value_1,12345          ; U16
.equ value_2,102            ; U32

.section .text

main:
    ;--------------------------------------------------------
    ; u16 x u32 multiply = u32 result.
    ; 12345 * 102 = 1,259,190
    ; 
    ; Expected result:
    ;
    ; 1,259,190 = 0x001336B6
    ;
    ; R25 = 0x00
    ; R24 = 0x13
    ; R23 = 0x36
    ; R22 = 0xB6
    ;--------------------------------------------------------
    ldi r27,hi8(value_1)    ; U16 in R27:R26
    ldi r26,lo8(value_1)

    ldi r21,hhi8(value_2)   ; U32 in R21:R18
    ldi r20,hlo8(value_2)
    ldi r19,hi8(value_2)
    ldi r18,lo8(value_2)

    push r0                 ; Preserve corrupted register.
    call Mult_u16_u32       ; __umulhisi3
    pop r0                  ; And restore.

loop:
    rjmp loop

