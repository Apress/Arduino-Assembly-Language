#define __SFR_OFFSET 0
#include <avr/io.h>

;------------------------------------------------------------
; Assumes both touch and LED pins are on PORTB.
;------------------------------------------------------------
.equ touchPin,0                 ; Pin D8/PB0.
.equ ledPin,5                   ; Pin D13/PB5.
.equ threshold,10               ; Adjust for better response.

.global main

;------------------------------------------------------------
; NOTE.
;------------------------------------------------------------
; Adjust threshold higher for a longer touch to light the LED. 
; Adjust lower for a shorter touch. 10-12 is good for 
; ATmega328P at 16 MHz clock.
;
; BEWARE: Reducing this below 3 will start to cause switch 
; "bounce" symptoms like flickering and irregular toggling.
;------------------------------------------------------------


.section .data

;------------------------------------------------------------
; Storage for a single byte. The rise time for the switch in
; its untouched state. 
;------------------------------------------------------------
noTouch:
    .byte 0


.section .text

;------------------------------------------------------------
; Calibrates the capacitance of an untouched wire at startup
; and reset. Returns the rise time in R24 as an 8 bit value.
;------------------------------------------------------------
riseTime:
    clr r24                     ; Initialise rise time.
    cbi DDRB,touchPin           ; TouchPin is input.

calibrate:
    sbi PORTB,touchPin          ; Pullup on.
    cbi PORTB,touchPin          ; Pullup off.
    inc r24                     ; Increment rise time.
    sbis PINB,touchPin          ; Until PINB.touchPin is set.
    rjmp calibrate
    sbi DDRB,touchPin           ; Discharge.
    ret                         ; R24 = uint8_t riseTime.


touchSense:
    ;--------------------------------------------------------
    ; If touched, R24 > R18 so C flag will be set, else C is
    ; clear. R18 is the threshold passed from the caller.
    ;--------------------------------------------------------
    rcall riseTime              ; Test the sensor.
    cp r18,r24                  ; C = touched.
    ret

main:
    ;--------------------------------------------------------
    ; Calibrate the rise time of the touch sensor.
    ;--------------------------------------------------------
    rcall riseTime              ; Ignore this one.
    rcall riseTime              ; Proper reading.
    sts noTouch,r24             ; Store the untouched rise time.

    ;--------------------------------------------------------
    ; Configure pin.
    ;--------------------------------------------------------
    sbi DDRB,ledPin             ; LED pin is output.


;------------------------------------------------------------
; Loop to read the sensor and invert the LED if touched. We 
; must wait for the sensor to be released. The bigger the 
; threshold, the longer the rise time.
;------------------------------------------------------------
loop:
    lds r18,noTouch             ; Get the untouched value.
    subi r18,-threshold         ; Add the threshold.

waitTouched:
    rcall touchSense            ; Test sensor. C = touched.
    brcc waitTouched            ; Not touched.
    sbi PINB,ledPin             ; Toggle LED.

    lds r18,noTouch             ; Get the untouched value.
    inc r18                     ; Add a reduced threshold.

waitRelease:
    rcall touchSense            ; Wait for release (C clear).
    brcs waitRelease            ; Still touched.
    rjmp loop                   ; And repeat.