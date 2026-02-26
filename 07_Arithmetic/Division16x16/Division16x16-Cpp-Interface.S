;==========================================================
; The code in this file presents an interface for C++ to be
; able to call the udivide16 and sdivide16 functions defined
; in Division16x16-code.S which makes up part of this sketch
; but can be used stand-alone in pure assembly code as the 
; AVR doesn't provide any division instruction. 
; Note that you may have to adjust the syntax of some 
; instructions to match your assemblers required syntax. 
; ADIW/SBIW perhaps.
; Avr-as uses a slightly different syntax for some 
; instructions.
;
; The C++ functions defined here are:
;
; div16x16 - Unsigned 16 bit division.
; rem16x16 - Unsigned 16 bit remainder from a division.
; sdiv16x16 - Signed 16 bit division.
; srem16x16 - Signed 16 bit remainder from a signed division.
;
; Norman Dunbar.
; 27 January 2024.
;==========================================================

#define __SFR_OFFSET 0
#include <avr/io.h>

.global div16x16
.global sdiv16x16
.global rem16x16
.global srem16x16

;----------------------------------------------------------
; Div16x16. Unsigned 16 bit division.
;----------------------------------------------------------
div16x16:
    ; Preserve registers for C++.
    push r26
    push r27
    in r27,SREG
    push r27

    ; Do division & retrieve result.
    rcall udivide16     ; Do unsigned division.

    ; Restore preserved C++ registers.
    pop r27
    out SREG,r27
    pop r27
    pop r26
    ret

;----------------------------------------------------------
; rem16x16. Unsigned 16 bit remainder.
;----------------------------------------------------------
rem16x16:
    ; Preserve registers for C++.
    push r26
    push r27
    in r27,SREG
    push r27

    ; Do division & retrieve result.
    rcall udivide16     ; R0 = result, R1 = remainder.
    mov r24,r26         ; Remainder to result register.
    mov r25,r27

    ; Restore preserved C++ registers.
    pop r27
    out SREG,r27
    pop r27
    pop r26
    ret


;----------------------------------------------------------
; Sdiv16x16. Signed 16 bit division.
;----------------------------------------------------------
sdiv16x16:
    ; Preserve registers for C++.
    push r26
    push r27
    push r28
    in r28,SREG
    push r28

    ; Do division & retrieve result.
    rcall sdivide16     ; Do signed division.

    ; Restore preserved registers.
    pop r28
    out SREG,r28
    pop r28
    pop r27
    pop r26
    ret




;----------------------------------------------------------
; Srem16x16. Signed 16 bit remainder.
;----------------------------------------------------------
srem16x16:
    ; Preserve registers for C++.
    push r26
    push r27
    push r28
    in r28,SREG
    push r28

    ; Do division & retrieve result.
    rcall sdivide16
    mov r24,r26         ; Remainder to result register.
    mov r25,r27
	
    ; Restore preserved C++ registers.
    pop r28
    out SREG,r28
    pop r28
    pop r27
    pop r26
    ret
