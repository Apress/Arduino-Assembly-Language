#define __SFR_OFFSET 0
#include <avr/io.h>

.global main

.section .text

myText:
    .asciz "EEPROM Data Ends."


main:
    ldi r18,0               ; Data to be written.
    clr r24                 ; EEPROM start address.
    clr r25

; Write 10 bytes, 0x00--0x09, to the start of the EEPROM.
byteLoop:
    rcall writeByte         ; R25:R24 = addr, R18 = data.
                            ; Updates R25:R24 to next address.
    inc r18                 ; Next data byte value.
    cpi r18,10              ; Done with bytes yet?
    brne byteLoop           ; No.

; Write 10 words, 0x1112--0xAAAB, incrementing by 0x1111, to the EEPROM.
words:
    ldi r22,10              ; Word counter
    ldi r18,0x12            ; First value = 0x1112.
    ldi r19,0x11

wordLoop:
    rcall writeWord         ; R25:R24 = addr, R19:R18 = data.
                            ; Updates R25:R24 to next address.
    subi r18,-0x11          ; Increment value by 0x1111.
    subi r19,-0x11
    dec r22                 ; Reduce the count.
    brne wordLoop           ; No.

; Write 10 words, 0x11111112--0xAAAAAAAB, incrementing by 
; 0x11111111, to the EEPROM.
longs:
    ldi r22,10              ; Long counter
    ldi r18,0x12            ; First value = 0x11111112.
    ldi r19,0x11
    ldi r20,0x11
    ldi r21,0x11

longLoop:
    rcall writeLong         ; R25:R24 = addr, R21:R18 = data.
                            ; Updates R25:R24 to next address.
    subi r18,-0x11          ; Increment value by 0x11111111.
    subi r19,-0x11
    subi r20,-0x11
    subi r21,-0x11
    dec r22                 ; Reduce counter.
    brne longLoop           ; No.

text:
    ldi ZL,lo8(myText)      ; Pointer to text data.
    ldi ZH,hi8(myText)
    rcall writePText        ; Write Flash text to EEPROM.


loop:
    rjmp loop



