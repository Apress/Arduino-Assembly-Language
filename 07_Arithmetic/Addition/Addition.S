#define __SFR_OFFSET 0

.global setup

setup:

; Add 44 to 86 with result in R18.
Add_1:
    ldi r18,86
    ldi r17,44
    add r18,r17
    ; Result in r18 is 86 + 44 = 130.

; Add 0x1234 to 0x2468 with result in R18:R19.
Add_2:
    ldi r18,lo8(0x2468)
    ldi r19,hi8(0x2468)
    ldi r16,lo8(0x1234)
    ldi r17,hi8(0x1234)
    
    ; Add low byte.
    add r18,r16		; R18 = 0x68 + 0x34 = 0x9C.
    
    ; Add the high byte.
    adc r19,r17		; R19 = 0x24 + 0x12 = 0x36
    
    ; Result in R18:R19 is 0x369C with R18 as the low byte (0x9C).


; Add 63 to 0x1234 with the result, 0x1273, in R30:R31. 
; R30 is the low byte.
Add_3:
    ldi r31,hi8(0x1234)
    ldi r30,lo8(0x1234)
    adiw r30,63				; Note: avr-as syntax.

    ret
