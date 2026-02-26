#define __SFR_OFFSET 0

.global setup

setup:

; Subtract 44 from 86 with result in R18.
subtract_1:
    ldi r18,86
    ldi r17,44
    sub r18,r17
    ; Result in r18 is 86 - 44 = 42

; Subtract 86 from 44 with result in R17.
subtract_2:
    ldi r18,86
    ldi r17,44
    sub r17,r18
    ; Result in r18 is 44 - 86 = -42

; Subtract 0x1234 from 0x2468  with result in R19:R18.
subtract_3:
    ldi r18,lo8(0x2468)
    ldi r19,hi8(0x2468)
    ldi r16,lo8(0x1234)
    ldi r17,hi8(0x1234)
    
    ; Subtract low byte.
    sub r18,r16		; R18 = 0x68 - 0x34 = 0x34.
    
    ; Subtract the high byte.
    sbc r19,r17		; R19 = 0x24 - 0x12 = 0x12
    
    ; Result in R18:R19 is 0x1234 with R18 as the low byte (0x34).

; Subtract 7 from 0x42 with the result in R18, which will equal 0x3B.
subtract_4:
    ldi r18,0x42
    subi r18,7

; Subtract 77 from 0x1234 with the result, 0x11E7, in R16:R17. 
; R16 is the low byte.
subtract_5:
    ldi r17,hi8(0x1234)
    ldi r16,lo8(0x1234)
    subi r16,77
    sbci r17,0

; Subtract 63 from 0x1234 with the result, 0x11F5, in R30:R31. 
; R30 is the low byte.
subtract_6:
    ldi r31,hi8(0x1234)
    ldi r30,lo8(0x1234)
    sbiw r30,63				; Note: avr-as syntax.

; Subtract 42 and the Carry flag from R16.
subtract_7:
    ldi r16,234
    ; Set or clear the carry flag here, somehow. I'll
    ; simply set it.
    sec
    sbci r16,42				; R16 = 191.
    ret
