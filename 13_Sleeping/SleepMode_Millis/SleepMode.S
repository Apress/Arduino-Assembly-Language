#define __SFR_OFFSET 0
#include <avr/io.h>


.global setSleepMode
.global setWatchdog
.global goToSleep
.global WDT_vect

setSleepMode:
    ; Sets sleep mode, but doesn't sleep yet.
    ldi r18,SLEEP_MODE_EXT_STANDBY
    out SMCR,r18
    ret

setWatchdog:
    ; Configure the WDT Interrupt to trigger every 4 seconds.
    cli                     ; Disable interrupts, essential!
    wdr                     ; Reset the watchdog, if running.

    ; Clear interrupt flag, set timed sequence parameters.
    ldi r18,(1 << WDIF)|(1 << WDCE)|(1 << WDE) ; Special setting required.
    sts WDTCSR,r18          ; Start timed sequence.

    ; Configure the WDT Interrupt.
    ldi r18,32 | (1 << WDIE) ; 4s timeout & enable interrupt.
    sts WDTCSR,r18          ; Set timeout & enable interrupt.
    sei                     ; Enable interrupts again.
    ret

 
goToSleep:
    ; Goes to sleep here.
    in r18,SMCR             ; Get current setting.
    sbr r18,(1 << SE)       ; Set Sleep Enable bit.
    out SMCR,r18            ; Write back to SMCR.
    sleep                   ; Snooze, until awake.

wakeUp:
    ; Wakes up here.
    cbr r18,(1 << SE)       ; Clear SE bit.
    out SMCR,r18            ; Write back to SMCR.
    ret

WDT_vect:
    ; The Watchdog Timer Interrupt handler.
    reti                    ; Just return, nothing to do!
