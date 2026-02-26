#define __SFR_OFFSET 0
#include <avr/io.h>

.global main

main:
    ldi r25,0x01            ; Start with 0x0102FF55
    ldi r24,0x02
    ldi r23,0xff
    ldi r22,0x55
    
quadruple:
    ldi r18,2               ; Counter, we need two doublings.

double:
    lsl r22                 ; Multiply by 2.
    rol r23                 ; Propagate to all 32 bits.
    rol r24
    rol r25
    dec r18                 ; Decrement counter.
    brne double             ; Do it twice.
                            ; Result = 0x040BFD54

loop:
    rjmp loop               ; Neverexit.