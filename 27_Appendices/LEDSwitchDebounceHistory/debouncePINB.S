;===========================================================
; A routine to debounce a switch on PORTB by repeatedly
; reading it until we get enough identical readings in the
; numerous history registers. (In C++ this only required 32 
; identical readings!)
;-----------------------------------------------------------
; Inputs.
; R17 holds the switch bit.
;-----------------------------------------------------------
; Outputs.
; Z set   = switch pressed.
; Z clear = switch unpressed.
;-----------------------------------------------------------
; Preserves all registers.
;===========================================================
; Instructions for use.
;
; Add this file, debouncePINB.S, to your Assembly sketch.
; Set R17 to the appropriate bit in PORTB for the switch.
; CALL debounce. (RCALL may also work if sketch is short.)
; Test Z on return.
;
; Debounce uses PORTB as the port where the switch is found.
; R17 must hold a 1 in the bit position of the switch in 
; PORTB/PINB.
;
;===========================================================

#define __SFR_OFFSET 0
#include <avr/io.h>

.section .text
.global debounce

;-----------------------------------------------------------
; Constants for testing switch pressed or released history
; and to use when clearing the history registers.
;-----------------------------------------------------------
.equ PRESSED,0xFF
.equ RELEASED,0x00
.equ EMPTY,0xAA


;-----------------------------------------------------------
; The debounce code. All registers are preserved. More can
; be added, where indicated, if your switches are worse than
; mine. Unlikely!
;-----------------------------------------------------------
debounce:
    push r18                ; Save working registers.
    push r19
    push r20
    push r21
    push r22
    push r23
    push r24
    ; ** Add more registers here if you have bad switches.

dbClearHistory:
    ldi r19,EMPTY           ; Clear all history registers.
    mov r20,r19
    mov r21,r19
    mov r22,r19
    mov r23,r19
    mov r24,r19
    ; ** Add more registers here if you have bad switches.

dbDebounceLoop:
    lsl r19                 ; Shift history 1 bit left and...
    rol r20                 ; ... assume bit 0 = not pressed.
    rol r21
    rol r22
    rol r23
    rol r24
    ; ** Add more registers here if you have bad switches.

    in r18,PINB             ; Read switch.
    and r18,r17             ; Keep only the switch bit.
    tst r18                 ; Zero = switch not pressed.
    breq dbCheckReleased    ; Check switch history.
    ori r19,1               ; R19, bit 0 = pressed.

;-----------------------------------------------------------
; Check history for all 0x00 which indicates that the switch
; has been released and remains so after bouncing stopped.
;-----------------------------------------------------------
dbCheckReleased:
    ldi r18,RELEASED        ; Checking for unpressed.
    cp r19,r18
    cpc r20,r18
    cpc r21,r18
    cpc r22,r18
    cpc r23,r18
    cpc r24,r18
    ; Add more registers here if you have bad switches.
    brne dbCheckPressed     ; If Z=0, all registers != R18.

dbSwitchReleased:
    clz                     ; Switch is not pressed.
    rjmp dbExit             ; Set Z and exit.

;-----------------------------------------------------------
; Check history for all 0xFF which indicates that the switch
; has been pressed and remained so after the bouncing 
; stopped.
;-----------------------------------------------------------
dbCheckPressed:
    ldi r18,PRESSED         ; Checking for pressed.
    cp r19,r18
    cpc r20,r18
    cpc r21,r18
    cpc r22,r18
    cpc r23,r18
    cpc r24,r18
    ; ** Add more registers here if you have bad switches.
    brne dbDebounceLoop      ; If Z=0, all registers != R18.
    
dbExit:
    ; ** Add more registers here if you have bad switches.
    pop r24                 ; Restore working registers
    pop r23
    pop r22
    pop r21
    pop r20
    pop r19
    pop r18
    ret