;==========================================================
; The code in this file presents an interface for C++ to be
; able to call the multiply16x16 and smultiply16x16 
; functions defined in Multiplication16x16-code.S which 
; makes up part of this sketch, but can be used stand-alone
; in pure assembly code as the AVR with the caveat that you
; might have to adjust the syntax of some instructions to 
; match your assemblers required syntax. ADIW/SBIW perhaps.
; Avr-as uses a slightly different syntax for some 
; instructions.
;
; The C++ functions defined here are:
;
; mult16x16 - Unsigned 16 bit multiplication.
; smult16x16 - Signed 16 bit multiplication
;
; Norman Dunbar.
; 27 January 2024.
;==========================================================

#define __SFR_OFFSET 0
#include <avr/io.h>

.global mult16x16
.global smult16x16

;----------------------------------------------------------
; Mult16x16. Unsigned 16 bit multiplication.
;----------------------------------------------------------
mult16x16:
    ; Preserve C++ registers.
    push r0
    push r1
    in r0,SREG
    push r0

    ; Perform unsigned multiply.
    ; Destroys R18:R19:R20:R21!
    rcall multiply16x16

    ; The result has to be in R22--R25.
    movw r22,r20        ; Return low 16 bits.
    movw r24,r18        ; Return high 16 bits.

    ; Restore preserved C++ registers.
    pop r1
    out SREG,r1
    pop r1
    pop r0
    ret


;----------------------------------------------------------
; Smult16x16. Signed 16 bit multiplication.
;----------------------------------------------------------
smult16x16:
    ; Preserve C++ registers.
    push r0
    push r1
    in r0,SREG
    push r0

    ; Perform signed multiply.
    ; Destroys R18:R19:R20:R21!
    rcall smultiply16x16

    ; The result has to be in R22--R25.
    movw r22,r20        ; Return low 16 bits.
    movw r24,r18        ; Return high 16 bits.
    
    ; Restore preserved C++ registers.
    pop r1
    out SREG,r1
    pop r1
    pop r0
    ret