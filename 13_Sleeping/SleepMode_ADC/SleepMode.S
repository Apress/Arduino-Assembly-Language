#define __SFR_OFFSET 0
#include <avr/io.h>

.global setSleepMode
.global goToSleep
.global readADC
.global configADC
.global ADC_vect


setSleepMode:
    ; Sets sleep mode, but doesn't sleep yet.
    ldi r18,SLEEP_MODE_ADC
    out SMCR,r18
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

.equ adcRef,1
.equ adcPsc,(1 << ADPS2) | (1 << ADPS1) | (1 << ADPS0)
.equ adcA0,0
configADC:
    ; Power on ADC.
    lds r18,PRR             ; Fetch PRR contents.    
    cbr r18,(1 << PRADC)    ; Ensure ADC is powered on.
    sts PRR,r18             ; And write back to PRR.

    ; For 16 MHz Arduino, set the ADC prescalar.
    lds r18,ADCSRA          ; Fetch ADCSRA contents.
    sbr r18,adcPsc          ; Divide by 128.
    sts ADCSRA,r18          ; Write back to ADCSRA.

    ; Use A0/PC0 as input pin & AVCC as reference voltage.
    ldi r18,(adcRef << 6) | adcA0
    sts ADMUX,r18

    ; Disable Digital Input Buffer for A0/PC0.
    lds r18,DIDR0           ; Fetch DIDR0 value.
    sbr r18,(1 << ADC0D)    ; Disable A0/PC0.
    sts DIDR0,r18           ; Write back.

    ; Enable ADC interrupt.
    lds r18,ADCSRA          ; Read ADCSRA again.
    sbr r18,(1 << ADIE)|(1 << ADEN)
    sts ADCSRA,r18          ; Enable interrupt and the ADC.
    ret
    
readADC:
    ; Read ADCL/ADCH into R24/R25 and return to C++.
    lds r24,ADCL            ; Fetch result, low byte first!
    lds r25,ADCH
    ret

ADC_vect:
    ; ADC Interrupt handler. Does nothing.
    reti
