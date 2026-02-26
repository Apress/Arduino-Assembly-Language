#define __SFR_OFFSET 0

#include <avr/io.h>

.section .text
.global main

;-----------------------------------------------------------
; Debounce counter. 9.998 = 2.5 milliseconds.
;-----------------------------------------------------------
.equ deBounce,9998

;-----------------------------------------------------------
; A subroutine to count down the register pair r24:r25 until
; zero is reached. This is used to debounce a switch. On 
; entry the register pair r24:r25 should hold the required 
; count for the delay. 9,998 gives 2.5 milliseconds at 
; 16 MHz clock speed.
;
; ENTRY:
; r24:r25 = delay count as a 16 bit word.
;
; EXIT:
; r254:r25 = 0.
; Z flag set.
;-----------------------------------------------------------
delay:
    sbiw r24,1		; 2 clocks
    brne delay		; 2 clocks (branches), 1 clock (no branch)
    ret				; 4 clocks


;-----------------------------------------------------------
; The sketch entry point. Execution starts here.
;-----------------------------------------------------------
main:

;-----------------------------------------------------------
; Sets PB5/D13 as output.
; Sets PB0/D8 as input, no pullup.
;-----------------------------------------------------------
pinMode:
    ldi r18,(1 << DDB5)|(0 << DDB0)
    out DDRB,r18

;-----------------------------------------------------------
; Ahem, the top of the loop. ;-)
;-----------------------------------------------------------
loop:

;-----------------------------------------------------------
; Wait here until the switch is pressed. Bit PINB0 in PINB 
; is set when the switch is pressed. When detected, delay 
; for 2.5 milliseconds for debouncing.
;-----------------------------------------------------------
waitSwitchPress:
    sbis PINB,PINB0
    rjmp waitSwitchPress

;-----------------------------------------------------------
; This is the debounce delay.
;-----------------------------------------------------------
debouncePressed:
    ldi r24,lo8(deBounce)	; 1 clock
    ldi r25,hi8(deBounce)	; 1 clock
    rcall delay				; 3 clocks

;-----------------------------------------------------------
; After the delay, check if the switch is still pressed and 
; if so, carry on to toggle the LED pin. If not, we are 
; still bouncing so start the switch scan all over again.
;-----------------------------------------------------------
waitPressAgain:
    sbis PINB,PINB0
    rjmp waitSwitchPress

;-----------------------------------------------------------
; We have recognised and debounced the switch, it must be 
; pressed to get here, so toggle the LED pin.
;-----------------------------------------------------------
digitalWrite:
    sbi PINB,PINB5

;-----------------------------------------------------------
; If we missed this bit out and restarted the loop, the LED
; would just blink for as long as we hold the switch down. 
; We wait here for the switch to be released.
;-----------------------------------------------------------
waitSwitchRelease:
    sbic PINB,PINB0
    rjmp waitSwitchRelease

;-----------------------------------------------------------
; This is the debounce delay.
;-----------------------------------------------------------
debounceReleased:
    ldi r24,lo8(deBounce)	; 1 clock
    ldi r25,hi8(deBounce)	; 1 clock
    rcall delay				; 3 clocks

;-----------------------------------------------------------
; Test the switch has indeed been released properly.
;-----------------------------------------------------------
waitReleaseAgain:
    sbis PINB,PINB0
    rjmp waitSwitchRelease

;-----------------------------------------------------------
; Now we can do it all again.
;-----------------------------------------------------------
    rjmp loop 
