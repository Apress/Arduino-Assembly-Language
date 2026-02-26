#define __SFR_OFFSET 0
#include <avr/io.h>

.global ASMinitTimer2
.global ASMmicros
.global ASMmillis
.global ASMdelay
.global ASMdelayMicroseconds

; If you forget this one, no errors, but nothing works!
.global TIMER2_OVF_vect

;-------------------------------------------------------------
; .Data section.
;
; Here we have reserved space for:
;
; T2_overflows uint32_t
; T2_millis    uint32_t
; T2_fractions uint8_t
;
; These will have to be initialised before use.
;-------------------------------------------------------------
.section .data

T2_fractions:
    .byte 0

T2_overflows:
    .long 0

T2_millis:
    .long 0

.section .text


;-------------------------------------------------------------
; Interrupt handler for Timer 0's Overflow Interrupt which is
; executed once every 1024 microseconds.
;-------------------------------------------------------------
TIMER2_OVF_vect:

preserve:
    ; Store used registers and SREG or else!
    push r18                ; Preserve all working registers.
    in r18,SREG
    push r18
    push r19
    push r24                ; Allows ADIW usage!
    push r25
    push r26
    push r27

overflows:
    ; Fetch T2_overflows counter and increment it.
    ldi r18,0               ; We need this for the ADC.
    lds r24,T2_overflows+0  ; Fetch current count.
    lds r25,T2_overflows+1
    lds r26,T2_overflows+2
    lds r27,T2_overflows+3
    adiw r24,1              ; Increment the overflow counter.
    adc r26,r18
    adc r27,r18
    sts T2_overflows+0,r24  ; Store new count.
    sts T2_overflows+1,r25
    sts T2_overflows+2,r26
    sts T2_overflows+3,r27

fractions:
    ; Increment the fractions of a milli counter.
    ldi r19,3               ; Goes up by 3 each time.
    lds r24,T2_fractions    ; Current fraction count
    add r24,r19             ; Fractional increment.

    ldi r19,1               ; Ready to increment T2_millis.
    cpi r24,125             ; No higher than 125 allowed.
    brcs storeFractions     ; Store if still less than 125.
                            ; Carry = 1 until r24 > 125.

    inc r19                 ; More than 125, extra milli reqd.
    subi r24,125            ; Adjust fractions.

storeFractions:
    sts T2_fractions,r24    ; And save new value.

millis:
    ; Fractions may have accumulated an extra milli.
    ; R19 will be 2 if so, otherwise, 1.

    ; Increment T2_millis counter.
    lds r24,T2_millis+0     ; Fetch millis count into R25:R22.
    lds r25,T2_millis+1
    lds r26,T2_millis+2
    lds r27,T2_millis+3
    add r24,r19             ; Millis +1 or +2.
    adc r25,r18
    adc r26,r18
    adc r27,r18
    sts T2_millis+0,r24     ; Store new count.
    sts T2_millis+1,r25
    sts T2_millis+2,r26
    sts T2_millis+3,r27

restore:
    pop r27                 ; Restore all working registers.
    pop r26
    pop r25
    pop r24
    pop r19
    pop r18
    out SREG,r18
    pop r18
    reti


;-------------------------------------------------------------
; Initialise the support variables. Set Timer 0 to have a
; prescalar of 64 and fast PWM mode, which may not be actually
; necessary but mimics the Arduino, and enable the overflow
; interrupt as well as global interrupts.
;-------------------------------------------------------------
ASMinitTimer2:
    ; Initialise all support variables to zero.
    push XH
    push XL
    ldi XH,hi8(T2_fractions) ; Start of my data area.
    ldi XL,lo8(T2_fractions)
    ldi r18,9               ; 9 bytes to be cleared.
    clr r19                 ; Zero required in each byte.

clrLoop:
    st X+,r19               ; Zero a byte. 
    dec r18                 ; Reduce the count of bytes.
    brne clrLoop            ; Do the remainder.

    pop XL                  ; Restore X register.
    pop XH


; Some useful equates to help setting the timer.
.equ mode,(1 << WGM21)|(1 << WGM20)
.equ div64,(1 << CS22)
.equ ovfInt,(1 << TOIE2)

initTimer:
    ; Initialise Timer 0. TCCR0x have initial values of zero.
    ldi r18,mode            ; Timer mode is Fast PWM.
    sts TCCR2A,r18          ; Set the timer mode.

    ldi r18,div64           ; Divide by 64 prescalar.
    sts TCCR2B,r18          ; Start the clock running.

    lds r18,TIMSK2          ; Interrupt mask.
    ori r18,ovfInt          ; Overflow interrupt required.
    sts TIMSK2,r18          ; Enable overflow interrupt.
    sei                     ; Enable global interrupts.
    ret

;-------------------------------------------------------------
; uint32_t ASMmicros().
;
; Returns the count of microseconds which have passed since we
; called ASMinitTimer0 in R25:R22 with R22 being the LSB.
;-------------------------------------------------------------
ASMmicros:
    push r19                ; Save working registers.
    push r18
    in r18,SREG             ; Get interrupt state.
    push r18                ; Save it too.
    cli                     ; Disable interrupts.

    lds r22,T2_overflows+0  ; Overflow counter into R25:R22.
    lds r23,T2_overflows+1
    lds r24,T2_overflows+2
    lds r25,T2_overflows+3
    

    sbis TIFR0,TOV0         ; Interrupt is set, don't rjmp.
    rjmp exitMicros         ; Branch if interrupt flag clear.

    clr r18                 ; For ADC.
    ldi r19,1               ; Increment.
    add r22,r19             ; Increment the overflow counter.
    adc r23,r18
    adc r24,r18
    adc r25,r18             ; Final overflow value.


exitMicros:    
    in r19,TCNT0            ; Fetch timer value.
    pop r18                 ; Get interrupt state again.
    out SREG,r18            ; Restore it.

    ; Convert overflow counter to microseconds.
    ; ((overflows << 8) + timer_count) << 2.
    mov r25,r24             ; Same as shift left 8.
    mov r24,r23
    mov r23,r22
    mov r22,r19             ; Add timer count.

    ldi r18,2               ; Need to do this twice.

double:
    lsl r22                 ; Multiply by 2.
    rol r23                 ; Propagate to all 32 bits.
    rol r24
    rol r25
    dec r18
    brne double             ; Do it twice.

    pop r18                 ; Restore r18.
    pop r19                 ; And r19 too.
    ret                     ; Done.


;-------------------------------------------------------------
; uint32_t ASMmillis().
;
; Returns the count of milliseconds which have passed since we
; called ASMinitTimer0 in R25:R22 with R22 being the LSB.
;-------------------------------------------------------------
ASMmillis:
    push r18                ; Save working register.
    in r18,SREG             ; Get interrupt state.
    push r18                ; Save it too.
    cli                     ; Disable interrupts.

    lds r22,T2_millis+0     ; Millis counter into R25:R22.
    lds r23,T2_millis+1
    lds r24,T2_millis+2
    lds r25,T2_millis+3

    
    pop r18                 ; Get interrupt state again.
    out SREG,r18            ; Restore it.
    pop r18                 ; Restore r18
    ret                     ; Done.

;-------------------------------------------------------------
; void ASMdelay(uint32_t ms).
;
; Delays, in a spin loop, until "ms" milliseconds have passed.
; Basically, it's doing this:
;
;  uint32_t start = millis();       ; R29:R26.
;  while (1) {
;      uint32_t now = millis();     ; R25:R22
;      if (ms < (now - start))      ; R21:R18 < R25:R22-R29:R26.
;          break;
;  }
;
; ms is passed in R25:R22 but kept in R21:R18.
; start is read into R25:R22 but kept in R29:R26.
; now is read into R25:R22.
; now - start is calculated in R25:R22.
;-------------------------------------------------------------
ASMdelay:
    push r18                ; Save working registers.
    push r19
    push r20
    push r21
    push r26
    push r27
    push r28
    push r29

    ; Ms passed in R25:R22, move to R21:R18.
    movw r18,r22
    movw r20,r24

    ; Get start in R25:R22, move to R29:R26.
    rcall ASMmillis
    movw r26,r22
    movw r28,r24

delayLoop:
    ; Now in R25:R22, then subtract start.
    rcall ASMmillis
    sub r22,r26
    sbc r23,r27
    sbc r24,r28
    sbc r25,r29

    ; Multi-register comparison - these are fun!
    ; If Z=0 at end, R21:R18 != R25:R22
    ; If Z=1 at end, R21:R18 == R25:R22
    ; If C=0 at end, R21:R18 >  R25:R22
    ; If C=1 at end, R21:R18 <= R25:R22

    cp r18,r22              ; if ms < (now-start) C = 1.
    cpc r19,r23
    cpc r20,r24
    cpc r21,r25
    brcc delayLoop

    pop r29                 ; Restore working registers.
    pop r28
    pop r27
    pop r26
    pop r21
    pop r20
    pop r19
    pop r18
    ret


;-------------------------------------------------------------
; void ASMdelayMicroseconds(uint32_t us).
;
; Delays, in a spin loop, until "us" microseconds have passed.
; Basically, it's doing this:
;
;  uint32_t start = millis();       ; R29:R26.
;  while (1) {
;      uint32_t now = millis();     ; R25:R22
;      if (ms < (now - start))      ; R21:R18 < R25:R22-R29:R26.
;          break;
;  }
;
; us is passed in R25:R22 but kept in R21:R18.
; start is read into R25:R22 but kept in R29:R26.
; now is read into R25:R22.
; now - start is calculated in R25:R22.
;-------------------------------------------------------------
ASMdelayMicroseconds:
    push r18                ; Save working registers.
    push r19
    push r20
    push r21
    push r26
    push r27
    push r28
    push r29

    ; Us passed in R25:R22, move to R21:R18.
    movw r18,r22
    movw r20,r24

    ; Get start in R25:R22, move to R29:R26.
    rcall ASMmicros
    movw r26,r22
    movw r28,r24

delayUsLoop:
    ; Now in R25:R22, then subtract start.
    rcall ASMmicros
    sub r22,r26
    sbc r23,r27
    sbc r24,r28
    sbc r25,r29

    ; Multi-register comparison - these are fun!
    ; If Z=0 at end, R21:R18 != R25:R22
    ; If Z=1 at end, R21:R18 == R25:R22
    ; If C=0 at end, R21:R18 >  R25:R22
    ; If C=1 at end, R21:R18 <= R25:R22

    cp r18,r22              ; if us < (now-start) C = 1.
    cpc r19,r23
    cpc r20,r24
    cpc r21,r25
    brcc delayUsLoop

    pop r29                 ; Restore working registers.
    pop r28
    pop r27
    pop r26
    pop r21
    pop r20
    pop r19
    pop r18
    ret
