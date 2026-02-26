#define __SFR_OFFSET 0
#include <avr/io.h>

.global setup
.global loop
.global WDT_vect

setup:
    ; D13/PB5 is output.
    ldi r18,(1 << DDB5);
    out DDRB,r18

setSleepMode:
    ; Sets sleep mode, but doesn't sleep yet.
    ldi r18,SLEEP_MODE_IDLE
    out SMCR,r18

setWatchdog:
    ; Configure the WDT Interrupt to trigger every 2 seconds.
    cli                     ; Disable interrupts, essential!
    wdr                     ; Reset the watchdog, if running.
    in r18,MCUSR            ; Fetch MCUSR value.
    cbr r18,(1 << WDRF)     ; Clear the "reset by WDT" bit.
    out MCUSR,r18           ; Write back to MCUSR.

    ; Clear interrupt flag, set timed sequence parameters.
    ldi r18,(1 << WDIF)|(1 << WDCE)|(1 << WDE) ; Special setting required.
    sts WDTCSR,r18          ; Start timed sequence.

    ; Configure the WDT Interrupt.
    ldi r18,7 | (1 << WDIE) ; 2s timeout & enable interrupt.
    sts WDTCSR,r18          ; Set timeout & enable interrupt.
    sei                     ; Enable interrupts again.
    ret

loop:
    rcall goToSleep
    sbi PINB,PINB5
    rjmp loop
   
goToSleep:
    ; Disable Timer 0 Oveflow.
    lds r18,TIMSK0
    cbr r18,(1 << TOIE0)
    sts TIMSK0,r18

    ; Goes to sleep here.
    in r18,SMCR             ; Get current setting.
    sbr r18,(1 << SE)       ; Set Sleep Enable bit.
    out SMCR,r18            ; Write back to SMCR.
    sleep                   ; Snooze, until awake.

wakeUp:
    ; Wakes up here.
    cbr r18,(1 << SE)       ; Clear SE bit.
    out SMCR,r18            ; Write back to SMCR.

    ; Enable Timer 0 Overflow.
    lds r18,TIMSK0
    sbr r18,(1 << TOIE0)
    sts TIMSK0,r18
    ret

WDT_vect:
    ; The Watchdog Timer Interrupt handler.
    reti                    ; Just return, nothing to do!
