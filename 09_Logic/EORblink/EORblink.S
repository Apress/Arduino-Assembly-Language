#define __SFR_OFFSET 0
#include <avr/io.h>

.global setup
.global loop

.equ DELAY,1000

.section .text

setup:
    ldi r18,(1 << DDB5)     ; 0b0010 0000
    out DDRB,r18            ; PB5 = output
    mov r19,r18             ; 0b0010 0000

loop:
    out PORTB,r18           ; Toggle LED.
    push r18                ; Save working registers.
    push r19
    ldi r25,hhi8(DELAY)     ; Delay parameters.
    ldi r24,hlo8(DELAY)
    ldi r23,hi8(DELAY)
    ldi r22,lo8(DELAY)
    call delay              ; delay(DELAY)
    pop r19                 ; Restore working registers.
    pop r18
    eor r18,r19             ;     0b0010 0000 = R18.
                            ; EOR 0b0010 0000 = R19.
                            ;   = 0b0000 0000 = LED off.
                            ;
                            ;     0b0000 0000 = R18.
                            ; EOR 0b0010 0000 = R19.
                            ;   = 0b0010 0000 = LED on.
    rjmp loop