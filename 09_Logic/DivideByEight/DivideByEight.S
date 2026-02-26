#define __SFR_OFFSET 0
#include <avr/io.h>

.global main

main:
    ldi r25,0x12            ; 0x1221FF08 to start with.
    ldi r24,0x21
    ldi r23,0xff
    ldi r22,0x08

divideByEight:
    ldi r18,3               ; Counter, we need three halvings.

halve:
    lsr r25                 ; Divide by 2.
    ror r24                 ; Propagate to all 32 bits.
    ror r23
    ror r22
    dec r18                 ; Decrement counter.
    brne halve              ; Do it three times.
                            ; Result = 0x02443FE1

loop:
    rjmp loop               ; Never exit.