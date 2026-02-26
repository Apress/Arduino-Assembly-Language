;==========================================================
; The code in this file makes up the two 16 bit by 16bit
; multiplication routines.
;
; multiply16x16 is a 16x16 unsigned multiplication.
; smultiply16x16 is a 16x16 signed multiplication.
;
; Both routines multiply the value in R24:R25 by the value 
; in R22:R23 and return the result in R18:R19:R20:R21.
;
; These functions accept two 16 bit values in the above
; registers as those are the ones that C++ would pass the
; parameters in. This reduces the amount of work and code
; we would have to write to interface these with C++.
;
; But, why would you call this from C++? C++ can do the 
; multiplication for you! ;o)
;
; Norman Dunbar.
; 27 January 2024.
;==========================================================

#define __SFR_OFFSET 0
#include <avr/io.h>

.global multiply16x16
.global smultiply16x16


;----------------------------------------------------------
; Multiply16x16. Unsigned 16 bit multiplication.
;----------------------------------------------------------
multiply16x16:
    ; Value 1 is in R24:R25 with r24 = low byte.
    ; Value 2 is in R22:R23 with r22 = low byte.

multLL:
    ; Multiply the low bytes of both values. Then
    ; move the result to R20,R21 with R20 as the 
    ; Lowest significant byte.
    mul r24,r22
    movw r20,r0         ; R21 = 256^1.
                        ; R20 = 256^0 = LSB.

multHH:
    ; Multiply the high bytes of both values. Then
    ; move the result to R18:R19 with R18 as the 
    ; lowest significant byte.
    mul r25,r23
    movw r18,r0         ; R19 = 256^3 = MSB.
                        ; R18 = 256^2.

multL1H2:
    ; Multiply value 1 low with value 2 high byte.
    ; Then add the result to R21--R19.
    mul r22,r25         ; R22=L, R25=H.
    add r21,r0          ; Add 256^1.
    adc r18,r1          ; Add 256^2
    clr r1              ; For ADC, C not changed.
    adc r19,r1          ; ADC 256^3 = MSB.

multH1L2:
    ; Multiply value 1 high byte with value 2 low byte.
    ; Then add the result to R21--R19.   
    mul r23,r24
    add r21,r0          ; Add 256^1.
    adc r18,r1          ; Add 256^2
    clr r1              ; For ADC, C not changed.
    adc r19,r1          ; ADC 256^3 = MSB.

result:
    ; The high word of the result is now in R18:R19, the
    ; low word is in R20:R21 with the even numbered 
    ; registers holding the low byte of the word.
    ret


;----------------------------------------------------------
; Smultiply16x16. Signed 16 bit multiplication.
;----------------------------------------------------------
smultiply16x16:
    ; Assume both same sign.
    push R26
    ldi r26,1           ; 1 = Result will be positive.

testA:
    ; Test high byte of first value. Because we are
    ; using R24:R25, we can use COM and ADIW.
    tst r25
    brpl testB          ; Skip, it's positive.
    com r25             ; Invert the bits.
    com r24
    adiw r24,1          ; Add 1 to the value.
    neg r26             ; Adjust negative flag.

testB:
    ; Test high byte of second value. Because we are
    ; using R22:R23, we cannot use ADIW.
    tst r23
    brpl doMult         ; Skip, it's positive.
    com r23             ; Invert the bits.
    com r22
    subi r22,lo8(-1)    ; Add 1 to low byte.
    sbci r23,hi8(-1)    ; And the carry, if required.
    neg r26             ; Adjust negative flag.

doMult:
    ; Perform unsigned multiply.
    rcall multiply16x16 ; Unsigned multiply.

    ; The high word of the result is now in R18:R19, the
    ; low word is in R20:R21 with the even numbered 
    ; registers holding the low byte of the word.

    tst r26             ; Is result to be negative?
    brpl doneMult       ; No, skip.

negResult:
    ; Result must be negative. Invert and add 1.
    ; Have to invert and subtract 0xFFFFFF as
    ; that is what -1 is in hex.
    com r21
    com r20
    com r19
    com r18
    subi r20,lo8(-1)
    sbci r21,hi8(-1)
    sbci r18,hlo8(-1)
    sbci r19,hhi8(-1)

doneMult:
    ; We are finished.
    pop r26
    ret
