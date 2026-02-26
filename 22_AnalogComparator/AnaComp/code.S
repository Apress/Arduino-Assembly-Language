#define __SFR_OFFSET 0
#include <avr/io.h>

.global main
.global ANALOG_COMP_vect

.section .text

setup:

setupPins:
    ldi r18,(1 << DDB5) ; Pin D13/PB5 is output
    out DDRB,r18

setupAC:
    lds r18,ADCSRB      ; Get the current ADC settings.
    cbr r18,(1 << ACME) ; Clear ACME bit.
    sts ADCSRB,r18      ; And write new settings.
    lds r18,DIDR1       ; Current input disable settings.
    sbr r18,(1 << AIN0D) | (1 << AIN1D)
    sts DIDR1,r18       ; Disable D6/PD6, D7/PD7.
    
    ldi r18,(1 << ACI) | (1 << ACIE)
    out ACSR,r18        ; Interrupt enabled. (ACIE = 1)
                        ; Interrupt flag cleared. (ACI = 1)
                        ; Analog comparator enabled. (ACD = 0)
                        ; Positive input = AIN0. (ACBG = 0)
                        ; Input Capture disabled. (ACIC = 0)
                        ; Interrupt on Toggle. (ACIS1/ACIS0 = 0)

setupSleep:
    ldi r18,SLEEP_MODE_IDLE
    out SMCR,r18
    ret


main:
    rcall setup         ; Setup pins, sleep and Analog Comparator.

loop:
    cli                 ; Disable interrupts.
    in r18,SMCR
    sbr r18,(1 << SE)
    out SMCR,r18        ; Enable sleeping.
    sei                 ; Enable interrupts.
    sleep               ; Go to sleep.

wakeUp:
                        ; ISR executes here, first!
    rjmp loop           ; And do it all again!

ANALOG_COMP_vect:
    push r18            ; Preserve r18.
    in r18,SREG         ; Must preserve SREG.
    push r18

    in r18,SMCR         ; Read sleep mode status.
    cbr r18,(1 << SE)   ; Disable sleeping.
    out SMCR,r18

    in r18,ACSR         ; Read Analog Comparator status.
    andi r18,(1 << ACO) ; Keep the ACO bit only.
    out PORTB,r18       ; Turn LED on/off.
                        ; ACO = PORTB5 = bit 5. Useful!

    pop r18
    out SREG,r18        ; Restore SREG.
    pop r18             ; Restore r18.
    reti