#define __SFR_OFFSET 0
#include <avr/io.h>

.section .text
.global main


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
; Program entry point.
;-----------------------------------------------------------
main:


;-----------------------------------------------------------
; We need to be sure that the USART is powered on. Clear bit
; PRUSART0 in the PRR register. We must do this without any
; other bits being changed.
;-----------------------------------------------------------
powerUp:
    lds r18,PRR               ; Fetch current PRR settings.
    cbr r18,(1 << PRUSART0)   ; Clear the USART's bit.
    sts PRR,r18               ; Update PRR settings.


;-----------------------------------------------------------
; We usually run in double speed mode, however, if the clock 
; speed is 16MHz and 57600 baud is needed, switch to single 
; speed. For most baud rates, the error% is lower in double
; speed mode. The data sheet error% values are not accurate!
;
; Single: USCR0A bit U2X0 is clear.
; Double: USCR0A bit U2X0 is set.
;-----------------------------------------------------------
doubleSpeed:
    ldi r18,(1 << U2X0)       ; Double speed mode.
    sts UCSR0A,r18            ; Sets double speed.


;-----------------------------------------------------------
; We need to configure 8 bits of data. The remaining bits of
; USCR0C will give us no parity and 1 stop bit for free! The
; power on default is 5 data bits.
;
; No parity: Clear UCSR0C bits UPM00 and UPM01.
; Even parity: Set UCSR0C bit UPM01 only.
; Odd parity: Set UCSR0C bits UPM00 and UPM01.
;
; One stop bit: Clear UCSR0C bit USBS0.
; Two stop bits: Set UCSR0C bit USBS0.
;-----------------------------------------------------------
partityDataStop:
    ; Default to 8 bit data, no parity, 1 stop bit.
    ldi r18,(1 << UCSZ01) | (1 << UCSZ00)
    sts UCSR0C,r18


;-----------------------------------------------------------
; In double speed mode:
;-----------------------------------------------------------
; UBRR0 = (F_CPU / (8 * baud)) - 1.
; BAUD = F_CPU / 8 * (UBRR0 + 1).
;
; For 9600 baud, UBRR0 is 207.
; For 115200 baud, UBRR0 is 16.
;
;-----------------------------------------------------------
; In single speed mode:
;-----------------------------------------------------------
; UBRR0 = (F_CPU / (16 * baud)) - 1.
; BAUD = F_CPU / 16 * (UBRR0 + 1).
;
; For 9600 baud, UBRR0 is 103.
; For 115200 baud, UBRR0 is 7.
;
; We must write the high byte (4 bits) of UBRR0 first, then the
; low 8 bits or we get glitches.
;-----------------------------------------------------------
baud9600:
    clr r18
    sts UBRR0H,r18            ; UBRR0 high 4 bits. 
    ldi r18,207
    sts UBRR0L,r18            ; UBRR0 low 8 bits.
  
  
;-----------------------------------------------------------
; The USART is configured, enable transmission only. We are
; not ready to receive yet.
;-----------------------------------------------------------
enableTx:
    lds r18,UCSR0B
    sbr r18,(1 << TXEN0)      ; Enable TX only.
    sts UCSR0B,r18


;-----------------------------------------------------------
; Normal Situation:
;
; The data are in Flash RAM, so we have to multiply the Z
; values by 2 to get byte addresses. We cannot multiply in the
; LDI instruction as the assembler can't handle that!
;-----------------------------------------------------------
; Avr-as situation:
;
; The data are in Flash RAM, but we DO NOT have to multiply
; by two! AVR-AS loads Z with a BYTE address in Flash RAM
; and not a WORD address, which would need the multiplication.
;-----------------------------------------------------------
transmit:
    ldi ZH,hi8(helloWorld)    ; R31.
    ldi ZL,lo8(helloWorld)    ; R30.

;-----------------------------------------------------------
; Loop around printing out the characters of the message. 
; Then when done, do it again!
;-----------------------------------------------------------
txNext:
    lpm r19,Z+                ; Fetch character for USART.
    tst r19                   ; Done yet?
    breq transmit             ; Yes, do it all again!

txWait:
    lds r18,UCSR0A            ; Fetch UCSR0A
    sbrs r18,UDRE0            ; UDR0 empty yet?
    rjmp txWait               ; Loop until set.
    ldi r18,(1 << U2X0)|(1 << UDRE0) ; Clear flag.
    sts UCSR0A,r18            ; Reset intrrupt flag.

txByte:
    sts UDR0,r19              ; Write to USART.
    rjmp txNext               ; Do next character


;-----------------------------------------------------------
; The message to be printed to the USART repeatedly.
;-----------------------------------------------------------
helloWorld:
    .asciz "Hello World!\r\n"

