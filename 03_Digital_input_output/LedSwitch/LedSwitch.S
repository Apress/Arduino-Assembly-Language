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
    cbr r19,(1 << PORTB5)
    
digitalRead:
    in r18,PINB
    sbrc r18,PINB0   

digitalWrite:
    sbr r19,(1 << PORTB5)   
    out PORTB,r19
    rjmp loop
