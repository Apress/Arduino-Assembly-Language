#define __SFR_OFFSET 0
#include <avr/io.h>

.section .text
.global main

;-------------------------------------------------------------
; Setting OCR1A to 62499 gets us a 250 mS blink rate which
; the timer controls, not the CPU. The CPU can do other things
; instead! Blink frequency is 1/(F_CPU/64)*(62499+1) which is
; 250 mS.
;-------------------------------------------------------------
#define FLASH_RATE 62499

main:
    ; Main just drops into setup and then, into the loop.

;-------------------------------------------------------------
; SETUP:
;
; Configures D9/PB1 as an OUTPUT pin for the LED. 
; Configures D11/PB3 as INPUT_PULLUP for the switch.
; Configures Timer1 for a quarter second blink rate on D9/PB1.
; Clear Timer on Compare (CTC) mode, but does not start the 
; timer. 
;-------------------------------------------------------------
setup:


;-------------------------------------------------------------
; Here we set D9/PB1 as an OUTPUT pin.
; The switch pin, D11/PB3, is configured as INPUT, initially,
; then the internal PULLUP resistor is enabled. You can avoid
; this latter part by commenting out the noted code lines
; below if you are using an external pullup resistor.
;-------------------------------------------------------------
LED_Button:
    ; Set D9/PB1 as OUTPUT for the LED.
    ; Set D11/PB3 as INPUT for the switch.
	ldi r18,(1 << DDB1)
	out DDRB, r18

    ; Make D11/PB3 PULLUP now. 
    ; ***** Comment out these two lines if     *****
    ; ***** using an external pullup resistor. *****
    ldi r18,(1 << PORTB3)
    out PORTB,r18
	
;-------------------------------------------------------------
; Partaily configure Timer 1, but don't start it.
; We enable CTC mode of Timer 1. We only use this mode to
; enable us to use OCR1A to get close to a 250 mS blink.
; We could use NORMAL mode, and get a blink rate of 262
; milliseconds instead.
;-------------------------------------------------------------
Timer_1:
    ; Set a 250 mS flash rate.
	ldi r18, hi8(FLASH_RATE)  ; Configure OCR1A for 250 mS.
	sts OCR1AH,r18            ; Always write high byte first!
	ldi r18,lo8(FLASH_RATE)
	sts OCR1AL,r18
	ldi r18,(1 << WGM12)    ; WGM12 = 1 = CTC mode.
	sts TCCR1B,r18          ; CTC with a reset at OCR1A.

;-------------------------------------------------------------
; LOOP:
;
; Wait for the switch to be pressed. Test if the switch bit is
; clear indicating a press. Switch must be pulled up. We don't
; do anything until the finger is removed from the switch. If
; you press and hold, the current state of the timer/LED will
; continue untl you release, then it will toggle.
;-------------------------------------------------------------
loop:

readSwitch:
    ; Read PINB and extract switch state. Loop until pressed.
    in r18,PINB             ; Read the switch.
    sbrc r18,PINB3          ; Wait for PINB3 = 0, pressed.
    rjmp readSwitch         ; Loop until switch pressed.

waitForRelease:
    in r18,PINB             ; Read the switch.
    sbrs r18,PINB3          ; Wait for PINB3 = 1, released.
    rjmp waitForRelease     ; Loop until switch released.


;-------------------------------------------------------------
; The switch was pressed. If the CS11 bit in R18 is set, the
; LED is currently flashing. Turn the timer off if so, 
; otherwise, turn the timer on.
;-------------------------------------------------------------
switchPressed:
    ; If LED on, turn timer off, else turn timer on.
    lds r18,TCCR1B          ; Read prescaler bits.

    ; LED is blinking if CS11 is 1. We are Ignoring CS10.
    sbrs r18,CS11           ; Skip the RJMP if timer 1 is on.
    rjmp enableTimer        ; CS11 off, turn timer 1 on.

    ; LED must be blinking, so disable the timer.
    rcall stopTimer         ; Shut down timer 1.
    rjmp loop               ; Go around.

enableTimer:
    rcall startTimer        ; Start timer 1.
    rjmp loop               ; And go around.

;-------------------------------------------------------------
; Turns off the timer by clearing the prescalar bits and then
; make sure that the LED is turned off. The timer takes over
; the pin when COM1A0 is set by the startTimer code. We can't
; control the pin while the timer has it.
;-------------------------------------------------------------
.equ prescale64,(1 << CS11)|(1 << CS10)

stopTimer:
    ; Disconnect LED from timer 1.
	clr r19                 ; All bits, not just COM1A0.
	sts TCCR1A,r19

    ; Make sure LED (actually, all pins on PORTB) is off.
    out PORTB,r19           ; Turn LED off.

    ; Turn prescalar off. Uses AND instead of ANDI for demo.
    ldi r19,~prescale64     ; Divide by 64, bits inverted.
    and r18,r19             ; Could use ANDI of course!
    rjmp setTimer           ; Turn off timer 1's prescalar.

;-------------------------------------------------------------
; Starts timer 1 by setting prescalar bits to a frequency of 
; F_CPU/64 = 250,000 Hz giving a Period of 4 uS. As we have
; OCR1A set to 62499, we have a blink rate of 4*(62499+1) uS
; which happens to be 250 mS. 
;-------------------------------------------------------------
startTimer:
    ; Connect the LED to the timer.
	ldi r18,(1 << COM1A0)
	sts TCCR1A,r18
    
    ; Set prescalar to 64. Uses OR instead of ORI for demo.
    ldi r19,prescale64      ; Divide by 64 bit.
    or r18,r19              ; Could use ORI too.

;-------------------------------------------------------------
; Turns timer 1 on or off according to R18. R18 is used to set
; the prescalar bits in TCCR1B.
;-------------------------------------------------------------
setTimer:
    sts TCCR1B,r18          ; Reconfigure the timer.  
    ret 
	