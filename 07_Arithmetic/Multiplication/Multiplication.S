#define __SFR_OFFSET 0

.global setup

setup:

; Multiply R18, 100, by R17 also 100. 
; The result in R0:R1 should be 0x2710
; with R0 = 0x10 and R1 = 0x27.
mul_1:
    ldi r18,100
    mov r17,r18
    mul r18,r17


; Square the value, 125, in R18. 
; The result in R0:R1 should be 0x3D09
; with R0 = 0x09 and R1 = 0x3D.
; Carry should be 0.
mul_2:
    ldi r18,125
    mul r18,r18

; Square the value, 255, in R18. 
; The result in R0:R1 should be 0xFE01
; with R0 = 0x01 and R1 = 0xFE.
; Carry should be 1.
mul_3:
    ldi r18,255
    mul r18,r18

; Multiply R0 by R1 to show it does work!
; LDI cannot be used, so R18 helps out!
; The result is 75 * 32 = 2400 or 0x0960.
; with R0 = 0x60 and R1 = 0x09.
; Carry should be 0.
mul_4:
    ldi r18,75
    mov r0,r18
    ldi r18,32
    mov r1,r18
    mul r0,r1

; Multiply two positive signed values.
; The result should be the same as using MUL
; except the maximum positive value is 127.
; The result is 75 * 32 = 2400 or 0x0960.
; with R0 = 0x60 and R1 = 0x09.
; Carry should be 0.
muls_1:
    ldi r18,75
    ldi r17,32
    muls r18,r17

; Multiply two negative signed values.
; The result is -15 * -42 = 630 or 0x0276.
; with R0 = 0x76 and R1 = 0x02.
; Carry should be 0.
muls_2:
    ldi r18,-15
    ldi r17,-42
    muls r18,r17


; Just for fun!
; Multiply a negative and a positive value.
; The result is 15 * -42 = -630 or 0xFD8A.
; with R0 = 0x8A and R1 = 0xFD.
; Carry should be 1.
muls_3:
    ldi r18,15
    ldi r17,-42
    muls r18,r17


; Multiply -128 by 250 to get -32000. (0x8300).
; R0 will hold 0x00 and R1 will hold 0x83.
; Carry will be bit 7 of R1, = 1.
mulsu_1:
    ldi r18,-128
    ldi r17,250
    mulsu r18,r17


; More fun! Attempt to get the registers the
; wrong way around!
; Use the same values as above, but in the other
; register.
; Will actually equal -6 * 128 = -768 = 0xFD00.
; Carry will be 1.
mulsu_2:
    ldi r17,-128        ; Actually +128!
    ldi r18,250         ; Actually -6!
    mulsu r18,r17

    ret
