#include <ASM_Usart.h>

;--------------------------------------------------------------------
; Some binary to ASCII conversion routines. These handle 8, 16
; or 32 bit values. The binary (ASCII) output is written to the
; data location pointed to by the X register.
;
; Norman Dunbar.
; 24 April 2024.
;--------------------------------------------------------------------

#define __SFR_OFFSET 0
#include <avr/io.h>
#include "ASM_Usart.h"

.global main
.global hex32Buffer

;------------------------------------------------------------
; Reserve space for the ASCII buffer.
; 13 bytes is enough for "0x", a 32 bit conversion 
; plus cr/lf and a final zero byte, for C++ purposes.
;
; Hex32Buffer is at address 0x0100 as it's first in 
; the data section. C++ variables come afterwards.
;------------------------------------------------------------

.section .data 

bin32Buffer:
    .space 2+32+3       ; Eg 0b0101...1001 cr/lf plus \0 terminator.


.section .text

;------------------------------------------------------------
; Main is the program entry point.
;------------------------------------------------------------
main:
    ; Sets up a 32 bit value 0xcoffee01 and converts it.
    ldi r25,0xc0
    ldi r24,0xff
    ldi r23,0xee
    ldi r22,0x01

    ; Initialise the X register.
    ldi r26,lo8(bin32Buffer)
    ldi r27,hi8(bin32Buffer)

    ; Save the X register for printing later.
    push r26
    push r27

; Some "magic" numbers.
.equ CR,0x0d
.equ LF,0x0A

    ; Add "0b" to the buffer. 
    ldi r18,'0'
    st X+,r18
    ldi r18,'b'
    st X+,r18

    ; Convert R22:R25 to ASCII.
    rcall bin32

    ; Add a CR/LF and a zero byte to the buffer. 
    ldi r18,CR
    st X+,r18
    ldi r18,LF
    st X+,r18
    clr r18
    st X,r18

    ; Print out result.
    call UsartTX9600   ; 9600 baud, 8-N-1, double speed.
    pop r27            ; Get X buffer start address.
    pop r26

    call transmit_x     ; Print buffer at X until 0 found.

loop:
    rjmp loop           ; Nothing for loop to do here.
