#define __SFR_OFFSET 0

.global setup

setup:

; Adding an immediate value without carry.
addi_1:
    ldi r18,42
    subi r18,-21
    ; R18 now contains 63.

; Adding an immediate value with carry.
; WARNING: Doesn't work as expected!
addi_2:
    ldi r18,42
    sec             ; Carry  = 1
    sbci r18,-21
    ; R18 now contains 62, NOT 64!


; Adding an immediate value with carry.
; Needs an extra register.
addi_3:
    ldi r18,42
    sec             ; Carry  = 1
    clr r17
    adc r18,r17
    sbci r18,-21
    ; R18 now contains 64.

; Adding an immediate value with carry.
; Needs a branch instruction.
addi_4:
    ldi r18,42
    sec             ; Carry  = 1
    brcc addi_4b
    inc r18         ; R18 = 43

addi_4b:
    subi r18,-21
    ; R18 now contains 64.


; Adding a 16 bit immediate value to
; a 16 bit register pair.
addi_5:
    ; 0x13D6 + 0x002c = 0x1402.
    ldi r18,lo8(0x13D6)
    ldi r19,hi8(0x13D6)
    subi r18,lo8(-0x002C)
    sbci r19,hi8(-0x002C)
    ; R18:R19 now contains 0x1402.

    ret
