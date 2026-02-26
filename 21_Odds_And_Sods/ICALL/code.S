#define __SFR_OFFSET 0
#include <avr/io.h>

.global setup
.global loop

; Default delay is 1 second.
.equ DELAY_1S,1000

.section .text

setup:
    ldi r18,(1 << DDB5)     ; D13/PB5 is an output.
    out DDRB,r18
    ret

loop:
    ldi ZH,pm_hi8(blink)       ; Z = address of blink divided by 2!
    ldi ZL,pm_lo8(blink)       ; Z must be a word address, not byte!
    icall                      ; Call blink via Z.
    ret

blink:
    ldi r18,(1 << PINB5)    ; Toggle D13/PB5.
    out PINB,r18
    ldi r22,lo8(DELAY_1S)   ; Delay(1000)
    ldi r23,hi8(DELAY_1S)
    ldi r24,hlo8(DELAY_1S)
    ldi r25,hhi8(DELAY_1S)
    call delay
    ret