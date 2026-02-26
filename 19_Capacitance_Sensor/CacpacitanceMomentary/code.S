#define __SFR_OFFSET 0
#include <avr/io.h>

;------------------------------------------------------------
; Assumes both touch and LED pins are on PORTB.
;------------------------------------------------------------
.equ touchPin,0                 ; Pin D8/PB0.
.equ ledPin,5                   ; Pin D13/PB5.

.global main

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
    clr r24                     ; Rise time is zero.
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
    ; Configure pin & grab the touch threshold.
    ;--------------------------------------------------------
    sbi DDRB,ledPin             ; LED pin is output.
    lds r18,noTouch             ; Get the untouched value.


;------------------------------------------------------------
; Loop to read the sensor and toggle the LED if touched. Then
; we must wait for the sensor to be released before looping.
;------------------------------------------------------------
loop:

untouched:
    rcall touchSense            ; Test sensor. C = touched.
    brcc untouched              ; Not touched.

touched:
    sbi PORTB,ledPin            ; LED on.

waitRelease:
    rcall touchSense            ; Wait for release...
    brcs waitRelease            ; Still touched...

released:    
    cbi PORTB,ledPin            ; LED off.

    rjmp loop                   ; And repeat.