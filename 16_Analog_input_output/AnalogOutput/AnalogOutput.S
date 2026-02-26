#define __SFR_OFFSET 0
#include <avr/io.h>

.section .text

.global TIMER1_OVF_vect
.global setupPWM


;------------------------------------------------------------
; Timer 1 constants.
;------------------------------------------------------------

; Prescalar: F_CPU/64.
.equ div64,(1 << CS11)|(1 << CS10)

; Phase correct PWM + Pin OC1A toggles on compare match
; D9/OC1A is on when upcounting and off when downcounting.
.equ pcPWM,(1 << WGM11)|(1 << WGM10)|(1 << COM1A1)

;------------------------------------------------------------
; Configure Timer 1 in phase correct PWM mode with TOP
; = 1023. The prescalar will be 64. Pin D9/PB1 will 
; toggle on match with OCR1A.
; Also configures D9/PB1/OC1A as output. (Saves 100+ bytes
; doing it here instead of in setup().)
;------------------------------------------------------------
setupPWM:
    ldi r18,(1 << DDB1)
    out DDRB,r18            ; D9/PB1/OC1A = output.
    clr r18
    sts TCCR1C,r18          ; We don't need TCCR1C.
    ldi r18,div64
    sts TCCR1B,r18          ; Set prescalar.
    ldi r18,pcPWM
    sts TCCR1A,r18          ; 10 bit, phase correct PWM.

    ; TOIE1 and TOV1 have the same bit position, 0. Handy!
    ldi r18,(1 << TOIE1)
    sts TIMSK1,r18          ; Enable Overflow interrupt.
    sts TIFR1,r18           ; Clear pending interrupt.
    ret



;------------------------------------------------------------
; Timer 1 Overflow Interrupt Handler.
;
; When Timer 1 reaches 1023 and increments, it will rollover
; to 0. This will trigger the overflow interrupt and control
; will come here. 
;
; Here we grab the current OCR1A value, increment it and
; write it back. This changes the duty cycle and the LED 
; fades up to full brightness then goes out and fades up
; again, over and over.
;
; Remember, OCR1A is a 16 bit register so we need to read the
; low byte then the high byte; and, write the high byte first
; then the low byte.
;------------------------------------------------------------
TIMER1_OVF_vect:
    push r24                ; Save working registers.
    push r25
    lds r24,OCR1AL          ; Fetch current duty cycle.
    lds r25,OCR1AH
    adiw r24,1              ; Increment it a little.
    sts OCR1AH,r25          ; Update the duty cycle.
    sts OCR1AL,r24
    pop r25                 ; Restore working registers.
    pop r24
    reti
