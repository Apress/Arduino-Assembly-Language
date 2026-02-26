;-----------------------------------------------------------
; A couple of USART functions which can be #included to make
; them available to other Assembly source files.
;
; Norman Dunbar. 
;-----------------------------------------------------------

#include "ASM_Usart.h"

.section .text

.global UsartTX9600
.global transmit_x
.global transmit_z
.global transmitByte


;-----------------------------------------------------------
; Data Sheet Baud Rate Settings for UBRR0 at 16 MHz.
;-----------------------------------------------------------
;    BAUD   Single  Error    |   Double    Error 
;-----------------------------------------------------------
;    9600      103    0.2%   |      207    0.2%
;  192000       51    0.2%   |      103    0.2%
;  384000       25    0.2%   |       51    0.2%
;  576000       16   -0.8%   |       34    2.1%
;  115200        8    2.1%   |       16   -3.5%   AVOID!
;  230400        3   -3.5%   |        8    8.5%   AVOID!
;  500000        1    0.0%   |        3    0.0%
;
; Notes:
;
; Always use double speed communications, unless otherwise
; advised.
;
; Always use a baud rate where the error% is in range -0.5% 
; to +0.5% unless unavoidable.
;
; Always use single speed for baudrate 57,600 at 16 MHz. The
; Arduino software specifically checks for these settings. 
; it is confusing as the error rate in single mode is higher 
; than in double.
;
; 115,200 is not the best baud rate to use in either speed
; mode! The errors are high. (But it seems to be popular and
; works?)
;-----------------------------------------------------------

;-----------------------------------------------------------
; UsartTX9600 sets the USART to transmit, only, at 9600 baud
; and 8-N-1 in double speed mode.
;
; Preserves all registers.
;-----------------------------------------------------------

.equ baud_9600,207     ; Constant for 9600 baud.

UsartTX9600:
    push r18           ; Preserve working register.

powerUp:
    lds r18,_SFR_MEM_ADDR(PRR) ; Fetch current PRR settings.
    cbr r18,(1<<PRUSART0)      ; Clear the USART's bit.
    sts _SFR_MEM_ADDR(PRR),r18 ; Update PRR settings.

doubleSpeed:
    ldi r18,(1<<U2X0)              ; Double speed mode.
    sts _SFR_MEM_ADDR(UCSR0A),r18  ; Sets double speed.

d8_n_s1:
    ldi r18,(1 << UCSZ01) | (1 << UCSZ00)
    sts _SFR_MEM_ADDR(UCSR0C),r18

b9600:
    clr r18
    sts _SFR_MEM_ADDR(UBRR0H),r18  ; UBRR0 high 4 bits. 
    ldi r18,baud_9600              ; 9600 baud.
    sts _SFR_MEM_ADDR(UBRR0L),r18  ; UBRR0 low 8 bits.

enableTx:
    lds r18,_SFR_MEM_ADDR(UCSR0B)
    sbr r18,(1 << TXEN0) ; Enable TX only.
    sts _SFR_MEM_ADDR(UCSR0B),r18

    pop r18            ; Restore working register.
    ret                ; USART is initialised.              



;-----------------------------------------------------------
; Transmit_x sends all bytes from where X regisignOnster is 
; pointing and keeps going until it sees a byte of zero.
;
; Preserves all registers except X.
; Updates X to one byte past the terminating 0 byte.
;-----------------------------------------------------------
transmit_x:
    push r18           ; Preserve working registers.                 
    push r19

;-----------------------------------------------------------
; Loop around printing out the characters of the message. 
; Then when done, do it again! This function blocks.
;-----------------------------------------------------------
txNext:
    ld r19,X+          ; Fetch character from buffer.
    tst r19            ; Done yet?
    breq txExit        ; Yes, exit.

txWait:
    rcall transmitByte ; Print it
    rjmp txNext        ; Do next character.

txExit:
    pop r19            ; Restore working registers.
    pop r18
    ret                ; Done.


;-----------------------------------------------------------
; Transmit_z sends all bytes from where Z register is 
; pointing and keeps going until it sees a byte of zero.
;
; Preserves all registers except Z.
; Updates Z to one byte past the terminating 0 byte.
;-----------------------------------------------------------
transmit_z:
    push r18           ; Preserve working registers.                 
    push r19

;-----------------------------------------------------------
; Loop around printing out the characters of the message. 
; Then when done, do it again! This function blocks.
;-----------------------------------------------------------
tyNext:
    lpm r19,Z+         ; Fetch character from Flash RAM.
    tst r19            ; Done yet?
    breq tyExit        ; Yes, exit.

tyWait:
    rcall transmitByte ; Print it
    rjmp tyNext        ; Do next character.

tyExit:
    pop r19            ; Restore working registers.
    pop r18
    ret                ; Done.


;-----------------------------------------------------------
; transmitByte sends the byte in R19 to the USART when the 
; UDR0 is free to take another byte. This code blocks. 
;
; Preserves all registers.
;-----------------------------------------------------------
transmitByte:
    push r18

trWait:
    lds r18,_SFR_MEM_ADDR(UCSR0A)    ; Fetch UCSR0A
    sbrs r18,UDRE0     			     ; UDR0 empty yet?
    rjmp trWait                      ; Loop until set.
    ldi r18,(1 << U2X0)|(1 << UDRE0) ; Clear interrupt flag.
    sts _SFR_MEM_ADDR(UCSR0A),r18    ; Reset interrupt flag.
    sts _SFR_MEM_ADDR(UDR0),r19      ; Write to USART.
    pop r18
    ret
