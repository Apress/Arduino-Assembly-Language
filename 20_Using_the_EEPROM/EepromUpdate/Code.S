#define __SFR_OFFSET 0
#include <avr/io.h>

; Get my mini USART library.
#include <ASM_Usart.h>

.global main

.equ CR,0x0D
.equ LF,0x0A

;------------------------------------------------------------
.section .text 
;------------------------------------------------------------


;------------------------------------------------------------
; Read through the EEPROM data. When we read a byte of data
; with the format 0x1x, then change it to a new value.
; Update the EEPROM with the possibly adjusted value. If the
; new value isn't the same as the old value, it will be 
; written. If they are the same, then nothing happens.
; Stop when we read the "." after the text data at the end
; of the EEPROM data we have written. 
;------------------------------------------------------------
main:
    ldi r25,0x80            ; EEPROM start = 0 with bit 7 set.
    clr r24                 ; Skip first (zero) byte.        

updateLoop:
    rcall readByte          ; Get a byte into R18.
                            ; Doesn't increment R25:R24.
    cpi r18,'.'             ; Last byte of text data?
    breq upDone             ; Yes, we are done.
    mov r19,r18             ; Copy the data byte to R19.
    andi r18,0xF0           ; Mask off the lower nibble.
    cpi r18,0x10            ; Was the data 0x1x?
    brne doUpdate           ; No? Skip.

oddByte:
    ldi r19,0xEE            ; New value for all 0x1x bytes.

doUpdate:
    rcall updateByte        ; Update EEPROM with R19.
    rjmp updateLoop         ; And keep going.

upDone:
    rjmp upDone             ; Loop until reset.

