#define __SFR_OFFSET 0

.global setup

setup:

; Multiply 1.5 by 0.5. The result should be 0.75
fmul_1:
    ldi r18,0b11000000
    ldi r17,0b01000000
    fmul r18,r17
    ; Result in r0:r1 is 0xC000 = 0b01100000 00000000.
    ; R0 is the low byte.
    ; 0.110 0000 = 0 + 0.5 + 0.25 = 0.75.
    ; Carry = 0.


; Multiply 1.5 by 1.75. The result should be 2.625,
; but this will be incorrect!
fmul_2:
    ldi r18,0b11000000
    ldi r17,0b11100000
    fmul r18,r17
    ; Result in r0:r1 is 0x5000 = 0b01010000 00000000.
    ; R0 is the low byte.
    ; 0.101 0000 = 0 + 0.5 + 0.125 = 0.625
    ; 2.625 would be 10.101000, so we've dropped the 1.
    ; Carry = 1.


; Multiply +0.5 by +0.5. The result should be +0.25
fmuls_1:
    ldi r18,0b01000000      ; +0.5
    ldi r17,0b01000000      ; +0.5
    fmuls r18,r17
    ; Result in r0:r1 is 0x2000 = 0b00100000 00000000.
    ; R0 is the low byte.
    ; 0.001 0000 = 0 + 0.25 = 0.25.
    ; Carry = 0.


; Multiply +0.5 by -0.5. The result should be -0.25
fmuls_2:
    ldi r18,0b01000000      ; +0.5
    ldi r17,0b11000000      ; -0.5
    fmuls r18,r17
    ; Result in r0:r1 is 0xE000 = 0b11100000 00000000.
    ; R0 is the low byte.
    ; 1.110 0000 = -1 + 0.5 + 0.25 = -0.25
    ; Carry = 1.


; Multiply -1 by -0.5. The result should be 0.5
fmuls_3:
    ldi r18,0b10000000      ; -1.0
    ldi r17,0b11000000      ; -0.5
    fmuls r18,r17
    ; Result in r0:r1 is 0x4000 = 0b01000000 00000000.
    ; R0 is the low byte.
    ; 0.100 0000 = 0 + 0.5 = 0.5.
    ; Carry = 0.


    ret