#define __SFR_OFFSET 0

#include <avr/io.h>

.section .text
.global main

;-----------------------------------------------------------
; Debounce counter. 10,000 = 2.5 milliseconds.
;-----------------------------------------------------------
.equ deBounce,10000

main:

;-----------------------------------------------------------
; Sets PB5/D13 as output.
; Sets PB0 as input, no pullup.
;-----------------------------------------------------------
pinMode:
    ldi r18,(1 << DDB5)|(0 << DDB0)
    out DDRB,r18

;-----------------------------------------------------------
; Ahem, the top of the loop. ;-)
;-----------------------------------------------------------
loop:

;-----------------------------------------------------------
; Wait here until the switch is pressed. PINB0 in PINB is
; set when the switch is pressed. When detected, delay for 
; 2.5 milliseconds for debouncing.
;-----------------------------------------------------------
waitSwitchPress:
    sbis PINB,PINB0
    rjmp waitSwitchPress

    ldi r24,lo8(deBounce)
    ldi r25,hi8(deBounce)

;-----------------------------------------------------------
; This is the debounce delay.
;-----------------------------------------------------------
pressedLoop:
    sbiw r24,1
    brne pressedLoop

;-----------------------------------------------------------
; After the delay, check if the switch is still pressed and
; ifso, carry on to toggle the LED pin. If not, we are still
; bouncing so start the switch scan all over again.
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

    ldi r24,lo8(deBounce)
    ldi r25,hi8(deBounce)

;-----------------------------------------------------------
; This is the debounce delay for the switch release. This is
; not strictly necessary.
;-----------------------------------------------------------
releasedLoop:
    sbiw r24,1
    brne releasedLoop

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
