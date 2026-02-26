#define __SFR_OFFSET 0

#include <avr/io.h>

.section .text
.global main

main:
    ; We need a 1 in bit 0 to keep pullups enabled.
    ldi r19,(1 << PORTB0)

pinMode:
    ; PB5 = output, PB0 = input
    ldi r18,(1 << DDB5)|(0 << DDB0)
    out DDRB,r18

    ; PB0 now input pullup
    sbi PORTB,PORTB0

loop:
    ; Clear only bit 5 of r19, leave bit 0 set. This assumes
    ; the switch is not pressed.
    cbr r19,(1 << PORTB5)
    
digitalRead:
    ; Read the switch on PB0, a 1 in PINB0 indicates unpressed.
    in r18,PINB
    sbrs r18,PINB0   

digitalWrite:
    ; Set bit 5 if switch pressed.
    sbr r19,(1 << PORTB5)  

    ; Light/extinguish the LED.
    out PORTB,r19
    rjmp loop
