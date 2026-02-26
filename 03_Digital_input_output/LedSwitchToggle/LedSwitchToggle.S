#define __SFR_OFFSET 0

#include <avr/io.h>

.section .text
.global main

main:
    clr r19

pinMode:
    ldi r18,(1 << DDB5)|(0 << DDB0)
    out DDRB,r18

loop:
    cbr r19,(1 << PORTB5)       ; 1 cycle
    
digitalRead:
    in r18,PINB                 ; 1 cycle
    sbrc r18,PINB0              ; 1 if no skip, 2 if skip.

digitalWrite:
    sbr r19,(1 << PORTB5)       ; 1 cycle
    out PINB,r19                ; 1 cycle
    rjmp loop                   ; 2 cycles
