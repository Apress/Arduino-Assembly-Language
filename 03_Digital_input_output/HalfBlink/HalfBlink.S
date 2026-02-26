#define __SFR_OFFSET 0

#include <avr/io.h>

.section .text
.global main

main:

pinMode:
    ldi r18,(1 << DDB5)
    out DDRB,r18

digitalWrite:
    out PORTB,r18

loop:
    rjmp loop
