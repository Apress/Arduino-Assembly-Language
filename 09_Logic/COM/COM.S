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
; Here we set D0/PD0--D7/PD7 as an OUTPUT pins.
; The switch pin, D11/PB3, is configured initially as INPUT.
; The internal PULLUP resistor is enabled later. You can avoid
; this latter part by commenting out the noted code lines
; below if you are using an external pullup resistor.
;-------------------------------------------------------------
LED_Button:
    ; Set D0/PD0--D7/PD7 as OUTPUT, D11/PB3 as INPUT.
	ldi r18,0xFF            ; All bits are OUTPUT
	out DDRD,r18            ; Set PORTD to all OUTPUT.
    inc r18                 ; R18 = 0
    out DDRB,r18            ; PORTB = all INPUT. (Optional.)

    ; Make D11/PB3 PULLUP now. 
    ; ***** Comment out these two lines if     *****
    ; ***** using an external pullup resistor. *****
    ldi r18,(1 << PORTB3)
    out PORTB,r18

    ; Set up the LEDs. Only even numbered LEDs will light.
    ldi r19,0b01010101
    	
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
switchPressed:
    ; Switch the LED states. NOTE: If bootloader used, D0/PD0
    ; never goes out!
    com r19                 ; Invert the bits in the LED mask.
    out PORTD,r19           ; Switch the LEDs.

    rjmp loop               ; And go around.

