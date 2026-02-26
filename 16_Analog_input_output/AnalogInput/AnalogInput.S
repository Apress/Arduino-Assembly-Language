#define __SFR_OFFSET 0
#include <avr/io.h>

.section .text

.global setupADC
.global setupSleep
.global gotoSleep

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
;               No Auto trigger +
;               No Free running mode +
;               Enable, but don't start, the ADC.                
.equ sraADC,~((1 << ADSC)|(1 << ADATE))


;------------------------------------------------------------
; Power on the ADC and configure its clock to 125 KHz. The 
; result will be right aligned in ADCH and ADCL 10 bits
; only though. The interrupt will be enabled. The input pin
; will be A0/ADC0/PC0 and its digital input buffer will be
; disabled. The ADC will be running in single shot mode so a
; new conversion will be manually started on sleeping.
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
    sbr r18,(1 << ADC0D)    ; Disable A0/ADC0.
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
; Sets up the board to allow it  to sleep in ADC Noise 
; Reduction mode. 
;------------------------------------------------------------
setupSleep:
    ; Configure the board to sleep for ADC readings.
    ldi r18,(1 << SM0)      ; ADC Noise Reduction mode.
    out SMCR,r18            ; Sets mode, but doesn't sleep.
    ret


;------------------------------------------------------------
; Put the board to sleep in ADC mode. Wakes up when the ADC
; has a new converion value ready, or any other non-Timer
; interrupt - apart from an Async Timer 2 interrupt which is
; unusable on Arduino boards.
;------------------------------------------------------------
gotoSleep:
    in r18,SMCR             ; Get the sleep configuration.
    sbr r18,(1 << SE)       ; Set the Sleep Enable (SE) bit.
    out SMCR,r18            ; Write the new configuration.
    sleep                   ; Go to sleep and trigger the ADC.

wakeUp:
    cbr r18,(1 << SE)       ; I'm awake! Clear the SE bit.
    out SMCR,r18            ; Write new configuration.
    ret
