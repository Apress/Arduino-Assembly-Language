;==========================================================
; The code in this file presents an interface for C++ to be
; able to call the udivide and sdivide functions defined in
; Division.S which makes up part of this sketch, but can be
; used stand-alone in pure assembly code as the AVR doesn't 
; provide any division instruction. Note that you may have
; to adjust the syntax of some instructions to match your
; assemblers required syntax. ADIW/SBIW perhaps.
; Avr-as uses a slightly different syntax for some 
; instructions.
;
; The C++ functions defined here are:
;
; div8x8 - Unsigned 8 bit division.
; rem8x8 - Unsigned 8 bit remainder from a division.
; sdiv8x8 - Signed 8 bit division.
; srem8x8 - Signed 8 bit remainder from a signed division.
;
; Norman Dunbar.
; 27 January 2024.
;==========================================================

#define __SFR_OFFSET 0
#include <avr/io.h>

.global div8x8
.global sdiv8x8
.global rem8x8
.global srem8x8

;----------------------------------------------------------
; Div8x8. Unsigned eight bit division.
;----------------------------------------------------------
div8x8:
    ; Preserve registers for C++.
    push r0
    push r1
    in r0,SREG
    push r0

    ; Do division & retrieve result.
    rcall udivide       ; Do unsigned division.
    mov r24,r0          ; Result
    clr r25             ; Clear high byte.

    ; Restore preserved C++ registers.
    pop r1
    out SREG,r1
    pop r1
    pop r0
    ret

;----------------------------------------------------------
; rem8x8. Unsigned eight bit remainder.
;----------------------------------------------------------
rem8x8:
    ; Preserve registers for C++.
    push r0
    push r1
    in r0,SREG
    push r0

    ; Do division & retrieve result.
    rcall udivide       ; R0 = result, R1 = remainder.
    mov r24,r1          ; Remainder to result register.
    clr r25             ; Clear high byte.

    ; Restore preserved C++ registers.
    pop r0
    out SREG,r0
    pop r1
    pop r0
    ret


;----------------------------------------------------------
; Sdiv8x8. Signed eight bit division.
;----------------------------------------------------------
sdiv8x8:
    ; Preserve registers for C++.
    push r0
    push r1
    in r0,SREG
    push r0

    ; Do division & retrieve result.
    rcall sdivide       ; Do signed division.
    mov r24,r0          ; Result
;    clr r25             ; Clear high byte.

    ; Restore preserved registers.
    pop r0
    out SREG,r0
    pop r1
    pop r0
    ret




;----------------------------------------------------------
; Srem8x8. Signed eight bit remainder.
;----------------------------------------------------------
srem8x8:
    ; Preserve registers for C++.
    push r0
    push r1
    in r0,SREG
    push r0

    ; Do division & retrieve result.
    rcall sdivide       ; R0 = result, R1 = remainder.
    mov r24,r1          ; Remainder to result register.
    clr r25             ; Clear high byte.

    ; Restore preserved C++ registers.
    pop r0
    out SREG,r0
    pop r1
    pop r0
    ret
