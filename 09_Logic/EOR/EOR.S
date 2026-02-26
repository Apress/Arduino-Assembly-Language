#define __SFR_OFFSET 0
#include <avr/io.h>

.section .text
.global main

main:
    ; Main just drops into setup and then, into the loop.

;-------------------------------------------------------------
; SETUP:
;
;-------------------------------------------------------------
setup:


;-------------------------------------------------------------
; Here we set D13/PB5 as an OUTPUT pin.
; The switch pin, D11/PB3, is configured initially as INPUT.
; The internal PULLUP resistor is enabled later. You can avoid
; this latter part by commenting out the noted code lines
; below if you are using an external pullup resistor.
;-------------------------------------------------------------
LED_Button:
    ; Set D13/PB5 as OUTPUT, D11/PB3 as INPUT.
	ldi r18,(1 << DDB5)
	out DDRB, r18

    ; Make D11/PB3 PULLUP now. 
    ; ***** Comment out these two lines if     *****
    ; ***** using an external pullup resistor. *****
    ldi r18,(1 << PORTB3)
    out PORTB,r18

    ; Set up the bitmask for the EOR instruction. This
    ; has a 1 in the LED's bit position, PORTB5. (Bit 5.)
    ldi r19,(1 << PORTB5)
    	
;-------------------------------------------------------------
; LOOP:
;
; Wait for the switch to be pressed. Test if the switch bit is
; clear indicating a press. Switch must be pulled up. We don't
; do anything until the finger is removed from the switch.
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
; The switch was pressed and released. Toggle the LED pin's 
; state. If it was on, it will now go off and vice versa. We
; MUST keep a 1 in bit position PORTB3 or the switch pin will
; no longer be in PULLUP mode and the sketch will stop working
; after the first button press. (Ask me how I know!)
;-------------------------------------------------------------
.equ bitMask,(1 << PORTB5)|(1 << PORTB3)
switchPressed:
    ; If LED on, turn off, else turn LED on.
    in r18,PINB             ; Read current state.
    andi r18,bitMask        ; Keep only bits 3 & 5. (Optional.)
    eor r18,r19             ; Toggle bit 5.
    out PORTB,r18           ; Set LED on or off.

    rjmp loop               ; And go around.

