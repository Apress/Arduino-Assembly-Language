/*============================================================
 * The standard Blink sketch converted to pure Assembly code
 * and utilising the "ASM Timer Functions" to replace the
 * millis() and delay() Arduino functions.
 *
 * The timer functions make use of Timer 2 as the Arduino 
 * uses Timer 0, however, as we are not using the Arduino 
 * language here, it makes no actual difference and we could
 * use Timer 0 ourselves.
 *
 * Norman Dunbar.
 * 13 August 2024.
 *==========================================================*/

#define __SFR_OFFSET 0
#include <avr/io.h>

.global main

.equ DELAY_MS,1000          ; 1000 millisecond delay.

main:
    call ASMinitTimer2      ; Start Timer 2.
    ldi r18,(1 << DDB5)     ; D13/PB5.
    out DDRB,r18            ; Make D13/PB5 an OUTPUT pin.
    ldi r25,hhi8(DELAY_MS)  ; MSB of delay.
    ldi r24,hlo8(DELAY_MS)
    ldi r23,hi8(DELAY_MS)
    ldi r22,lo8(DELAY_MS)   ; LSB of delay.

loop:
    out PINB,r18            ; Toggle D13/PB5
    push r22                ; Save the delay count.
    push r23
    push r24
    push r25
    call ASMdelay           ; Delay for DELAY_MS milliseconds.
    pop r25                 ; REstore the delay count.
    pop r24
    pop r23
    pop r22
    rjmp loop               ; Loop forever.