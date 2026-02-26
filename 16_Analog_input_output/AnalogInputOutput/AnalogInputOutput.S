#define __SFR_OFFSET 0
#include <avr/io.h>

.section .text

.global ADC_vect
.global setupPWM
.global setupADC
.global startADC

;------------------------------------------------------------
; Timer 1 constants.
;------------------------------------------------------------

; Prescalar: F_CPU/64.
.equ div64,(1 << CS11)|(1 << CS10)

; Phase correct PWM + Pin OC1A toggles on compare match
; D9/OC1A is on when upcounting and off when downcounting.
.equ pcPWM,(1 << WGM11)|(1 << WGM10)|(1 << COM1A1)

;------------------------------------------------------------
; ADC Constants.
;------------------------------------------------------------

; ADMUX gives:
;               Input pin A0/ADC0 + 
;               Right aligned result +
;               AVCC reference voltage. 
.equ muxADC,(1 << REFS0)

; ADCSRA gives:
;               Prescaler F_CPU/128 +
;               ADC interrupt enabled +
;               Pending interrupts cleared +
;               Auto trigger +
;               Free running mode +
;               Enable, but don't start, the ADC.                
.equ sraADC,~(1 << ADSC)

;------------------------------------------------------------
; Configure Timer 1 in phase correct PWM mode with TOP
; = 1023. The prescalar will be 64. Pin D9/PB1/OC1A will 
; toggle on match with OCR1A.
;------------------------------------------------------------
setupPWM:
    ldi r18,(1 << DDB1)
    out DDRB,r18            ; Pin D9/PB1/OC1A is output.
    clr r18
    sts TCCR1C,r18          ; We don't need TCCR1C.
    ldi r18,div64
    sts TCCR1B,r18          ; Set prescalar.
    ldi r18,pcPWM
    sts TCCR1A,r18          ; 10 bit, phase correct PWM.
    ret


;------------------------------------------------------------
; Power on the ADC and configure its clock to 125 KHz. The 
; result will be right aligned in ADCH and ADCL 10 bits
; only though. The interrupt will be enabled. The input pin
; will be A0/ADC0/PC0 and its digital input buffer will be
; disabled. The ADC will be running in auto trigger mode so a
; new conversion will start when this one finishes. Any 
; pending interrupts will be cleared.
;------------------------------------------------------------
setupADC:
    ; ADCSRB config is not required.
    clr r18
    sts ADCSRB,r18          ; Clear ADCSRB's configuration.          

power:
    ; Power on the ADC.
    lds r18,PRR             ; Get current power settings.
    cbr r18,(1 << PRADC)    ; Make sure ADC is powered.
    sts PRR,r18             ; Update power settinmgs.

diBuffer:
    ; Disable A0/ADC0's digital input buffer.
    lds r18,DIDR0           ; Current buffer states.
    cbr r18,(1 << ADC0D)    ; Disable A0/ADC0.
    sts DIDR0,r18           ; Update buffer states.

mux:
    ; Configure the ADMUX.
    ldi r18,muxADC          ; Configure bits for ADMUX.
    sts ADMUX,r18           ; Update ADMUX.

sra:
    ; Configure ADCSRA.
    ldi r18,sraADC          ; Configure bits for ADCSRA.
    sts ADCSRA,r18          ; Update ADCSRA.
    ret


;------------------------------------------------------------
; Kick start the ADC. No matter what mode, it always
; needs to be manually started.
;------------------------------------------------------------
startADC:
    lds r18,ADCSRA          ; Need to set ADSC bit.
    sbr r18,(1 << ADSC)     ; Set it.
    sts ADCSRA,r18          ; Start the ADC running.
    ret


;------------------------------------------------------------
; ADC Interrupt handler. When a new value is ready, write it
; to OCR1A to adjust the timer's duty cycle.
;
; Remember, OCR1A and ADC are 16 bit registers so we need to
; read low then high, and, write high then low.
;------------------------------------------------------------
ADC_vect:
    push r18                ; Save working registers.
    push r19
    lds r18,ADCL            ; Get ADC result, low byte first.
    lds r19,ADCH
    sts OCR1AH,r19          ; Write to OCR1A, high byte first.
    sts OCR1AL,r18
    pop r19                 ; Restore working registers.
    pop r18
    reti
