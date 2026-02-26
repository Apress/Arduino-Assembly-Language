;==========================================================
; A function to return the entire (all 26) interrupt vector
; table to the C++ caller. No parameters are passed but the
; destination buffer address is passed in R24:R25 with R24
; as the low byte as normal.
;
; Norman Dunbar.
; March 2 2024.
;==========================================================

#define __SFR_OFFSET 0
#include <avr/io.h>
#include "constants.h"

.global getInterruptTable


;----------------------------------------------------------
; Returns the interrupt table. Uses Z as the destination
; passed in in R24:R25 and X as the source. R18 counts the
; loop index. On the ATmega328P, there are 26 interrupt 
; vectors.
;----------------------------------------------------------
getInterruptTable:
    push r30            ; Save Z register.
    push r31
    push r26            ; Save X register.
    push r27
    in r18,SREG         ; R18 is expendible!
    push r18            ; Save SREG.

    movw r26,r24        ; Copy destination to X.
    ldi r30,pm_lo8(0)   ; Source address WORD is zero.
    ldi r31,pm_hi8(0)         
    ldi r18,interruptCount  ; How many vectors?

allVectors:
    ldi r19,4           ; Four bytes per vector.

oneVector:
    ; Hint, LPM! Don't use LD here it's program memory
    ;       not, data memory! 
    lpm r20,Z+          ; Fetch one program byte.
    st X+,r20           ; Save it into data memory.
    dec r19             ; One less to copy.
    brne oneVector      ; Not finished yet.

    dec r18             ; Vector done, any more?
    brne allVectors     ; Not finished yet.

    pop r18             ; Restore SREG.
    out SREG,r18
    pop r27             ; Restore X register.
    pop r26
    pop r31             ; Restore Z register.
    pop r30
    ret
