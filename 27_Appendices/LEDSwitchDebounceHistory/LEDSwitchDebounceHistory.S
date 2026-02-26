#define __SFR_OFFSET 0
#include <avr/io.h>

.section .text
.global main


;-----------------------------------------------------------
; Sketch starts here.
;-----------------------------------------------------------
main:

;-----------------------------------------------------------
; Setup.
;
; PB5/D13 is an output pin for the LED.
; PB0/D8 is an input pin without pullup. PB0/D8 is pulled
; down externally by a 10K resistor.
; R17 indicates the PORTB pin used for the switch. This is
; needed by the debounce subroutine.
;-----------------------------------------------------------
setup:
    ldi r17,(1 << DDB5)|(0 << DDB0)
    out DDRB,r17
    ldi r17,(1 << DDB0)     ; Switch bit for debouncing.

;-----------------------------------------------------------
; Loop.
;
; Reads the switch and debounces it. When we have a fully
; debounced press, we toggle the LED and must then wait for
; a fully debounced release before looping.
;-----------------------------------------------------------
loop:
    rcall debounce          ; Debounce switch. Z = pressed.
    brne loop               ; Switch not pressed.

switchPressed:
    sbi PINB,PINB5          ; Toggle D13/PB5 LED.

waitForRelease:
    rcall debounce          ; Wait for release.
    breq waitForRelease     ; Not released yet.

switchReleased:
    rjmp loop               ; Go around again.

