#define __SFR_OFFSET 0
#include <avr/io.h>

.global setup
.global loop

setup:
    ; D13/PB5 is output.
    ldi r18,(1 << DDB5);
    out DDRB,r18

setSleepMode:
    ; Sets sleep mode, but doesn't sleep yet.
    ldi r18,SLEEP_MODE_IDLE
    out SMCR,r18
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

    ; Enable Timer 0 Overfloe.
    lds r18,TIMSK0
    sbr r18,(1 << TOIE0)
    sts TIMSK0,r18
    ret
