#define __SFR_OFFSET 0
#include <avr/io.h>

;-----------------------------------------------------------
; Some meaningful names for various bit and flag settings so
; if necessary, I can change them once here.
;-----------------------------------------------------------
.equ tx_rx,(1 << RXEN0)|(1 << TXEN0)  ; Enable TX and RX.
.equ txFlags,(1 << U2X0)|(1 << UDRE0) ; TX bits to write.
.equ rxFlags,(1 << U2X0)|(1 << RXC0)  ; RX bits to write.

.equ rxErrorFlags,(1 << FE0)|(1 << DOR0)|(1 << UPE0) ;Errors
.equ newLine,0x0A             ; New line = end of input.
    

;-----------------------------------------------------------
; Reserve 64 bytes of space in the .data section to store 
; user input, their typed name, plus an extra for the 
; terminating byte.
;-----------------------------------------------------------
.section .data

yourName:
     .space 64+1

;-----------------------------------------------------------
; Switch back to the code section again and define our entry
; point, main, as global.
;-----------------------------------------------------------
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
; Always use a baud rate where the error% is in range -0.5% to
; +0.5% unless unavoidable.
;
; Always use single speed for baudrate 57,600 at 16 MHz. The
; Arduino software specifically checks for these settings. it
; is confusing as the error rate in single mode is higher than
; in double.
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
    cbr r18,(1<<PRUSART0)     ; Clear the USART's bit.
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
    ldi r18,(1<<U2X0)         ; Double speed mode.
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
;-----------------------------------------------------------
; In single speed mode:
;-----------------------------------------------------------
; UBRR0 = (F_CPU / (16 * baud)) - 1.
; BAUD = F_CPU / 16 * (UBRR0 + 1).
;
; For 9600 baud, UBRR0 is 103.
; For 115200 baud, UBRR0 is 7.
;
; WARNING: We must write the high byte (4 bits) of UBRR0 
; first, then the low 8 bits or we get glitches.
;-----------------------------------------------------------
baud9600:
    clr r18
    sts UBRR0H,r18            ; UBRR0 high 4 bits. 
    ldi r18,207
    sts UBRR0L,r18            ; UBRR0 low 8 bits.
  
  
;-----------------------------------------------------------
; The USART is configured, enable transmission and reception.
;-----------------------------------------------------------
enableTxRx:
    lds r18,UCSR0B
    sbr r18,tx_rx
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
printPrompt:
    ldi ZH,hi8(prompt)
    ldi ZL,lo8(prompt)
    rcall transmitZ            ; Print the prompt.

;-----------------------------------------------------------
; Receive one byte from the USART into r18 and stores it in 
; the buffer <yourName>. The Y register (pair) points at the
; data section, not the code section as Z does.
;-----------------------------------------------------------
getName:
    ldi YH,hi8(yourName)
    ldi YL,lo8(yourName)      ; Y points to data buffer.
    rcall rxName              ; Fetch name in buffer at Y.

printHello:
    ldi ZH,hi8(hello)
    ldi ZL,lo8(hello)
    rcall transmitZ            ; Print the hello message.

printName:
    ldi YH,hi8(yourName)
    ldi YL,lo8(yourName)      ; Y points to data buffer.
    rcall transmitY           ; Print your name.

again:
    rjmp printPrompt          ; Prompt for a name again.

;-----------------------------------------------------------
; Subroutine to print out the text pointed to by the Z 
; register. Returns when a zero byte is detected. Updates the
; Z register.
;
; NOTE: The text pointed to by Z is located in the .code 
; section, not in the .data section.
;-----------------------------------------------------------
; NOTE: Using LD instead of LPM works fine here so we could 
; use LD and use the Z register for both program and data 
; memory, however, the instruction reference manual states 
; that we should use LPM for program memory and Z, so I am.
; UPDATE: See second warning below!
;-----------------------------------------------------------
; WARNING: Use LD and not LDD as the latter doesn't work here
; assuming I'm going against the instruction manual of course!
; Invalid instructions are executed as NOP!
;-----------------------------------------------------------
; WARNING: If you do use LD and not LPM, when the user input
; is around 20-30 characters -- it varies -- the prompt is 
; corrupted somehow. This never happens when LPM is used.
; Even worse, it seems to corrupt the program memory too as a
; reset doesn't cause the correct prompt to be displayed.
; It also makes no difference if the <yourName> buffer is made
; bigger. Weird!
;-----------------------------------------------------------
transmitZ:
txZNext:
    lpm r18,Z+                ; Fetch next character for USART.
    tst r18                   ; Are we done yet?
    breq txzDone              ; Zero = Done.
    rcall txByte              ; Transmit the data byte in r18.
    rjmp txZNext              ; Do some more bytes.
    
txzDone:
    ret


;-----------------------------------------------------------
; Subroutine to print out the data in SRAM  pointed to by the
; Y register. Returns when a zero byte is detected. Updates
; the Y register.
;
; NOTE: The text pointed to by Y is located in the .data 
; section, not in the .code section.
;-----------------------------------------------------------
; WARNING: Use LD and not LDD as the latter doesn't work here.
; The Data Sheet advises that the only LDD Rd,Y+q is valid on
; the ATmega328. Likewise ST and STD.  Invalid instructions 
; are executed as NOP!
;-----------------------------------------------------------
transmitY:
txYNext:
    ld r18,Y+                 ; Fetch next character for USART.
    tst r18                   ; Are we done yet?
    breq txyDone              ; Zero = Done.
    rcall txByte              ; Transmit the data byte in r18.
    rjmp txYNext              ; Do some more bytes.

txyDone:
    ret


;-----------------------------------------------------------
; Subroutine to print out the byte in r18. The byte will be 
; loaded into the UDR0 register no matter what value it has,
; so binary data can be transmitted as well as character or
; printable.
;-----------------------------------------------------------
txByte:
    push r19                  ; Save working register

txWait:
    lds r19,UCSR0A            ; Fetch UCSR0A
    sbrs r19,UDRE0            ; UDR0 empty yet?
    rjmp txWait               ; Loop until set.
    ldi r19,txFlags           ; Clear UDRE0 flag.
    sts UDR0,r18              ; Write to USART.
    sts UCSR0A,r19            ; Reset intrrupt flag.
    pop r19                   ; Restore working register.   
    ret


;-----------------------------------------------------------
; Fetches the user's typed input, which must be terminated by
; a linefeed (character 0x0A), and stores in in a buffer in 
; data space, pointed to by the Y register. The buffer will be
; NULL terminated in a C like manner. If CR is present it, and
; the LF character will be stored in the buffer.
;
; ALTERS: SREG flags.
;-----------------------------------------------------------
; WARNING: Use ST and not STD as the latter is only valid for
; STD Y+q,Rd instructions on the ATmega328. Likewise LD and 
; LDD. Invalid instructions are executed as NOP!
;-----------------------------------------------------------
rxName:
    push r19                  ; Save working register
    
rxNext:   
    rcall rxByte              ; Fetch a byte from USART.
                              ; Will set Z if no errors
    breq rxSaveByte           ; No errors, skip handling.

;-----------------------------------------------------------
; If an error occurred, handle it. In this demo, we simply 
; write a message to the USART as we are using it for output.
; Other applications need to handle errors accordingly.
;
; r19 holds the status byte with the error bits set for any
; of the detected errors.
;
; For Partity error, r19, bit 2 is set.
; For Data overrun, r19, bit 3 is set
; For Frame error, r19, bit 4 is set.
;-----------------------------------------------------------
rxErrors:
    push ZH                   ; Save Z register.
    push ZL
    ldi ZH,hi8(rxErrorMessage)  ; Error message
    ldi ZL,lo8(rxErrorMessage)
    rcall transmitZ           ; Print error message.
    pop ZL                    ; Restore Z register.
    pop ZH
    rjmp rxNext               ; Try again, but beware, this
                              ; could cause loops if we got
                              ; errors on the N/L character.

rxErrorMessage:
    .asciz "USART receive error detected.\r\n"

;-----------------------------------------------------------
; No errors were detected, save the received byte in the next
; available space in the buffer.
;-----------------------------------------------------------
rxSaveByte:
    st Y+,r18                 ; Save in buffer.
    cpi r18,newLine           ; End of input yet?
    brne rxNext               ; Not yet, get more bytes.    
    ldi r18,0                 ; Terminator byte.
    st Y,r18                  ; Store in buffer
    pop r19                   ; Restore working register.
    ret


;-----------------------------------------------------------
; Receive one byte from the USART into r18. Also uses r19.
; Waits until a byte is available before returning the 
; received byte in r18. r19 will be zero if no RX errors were
; detected, otherwise, it holds the three error flags from 
; UCSR0A. These can be checked using:
;
; For Partity error, test r19, bit 2. Set is error condition.
; For Data overrun, test r19, bit 3. Set is error condition.
; For Frame error, test r19, bit 4. Set is error condition.
;
; Z flag will be set if no RX errors occurred, set otherwise.
;-----------------------------------------------------------
rxByte:

rxWait:
    lds r19,UCSR0A            ; Fetch status from UCSR0A.
    sbrs r19,RXC0             ; Byte received yet?
    rjmp rxWait               ; No, loop until so.
    
    push r19                  ; Save status register.     
    lds r18,UDR0              ; Fetch received byte.    
    ldi r19,rxFlags           ; Clear RXC0 flag.
    sts UCSR0A,r19            ; Reset interrupt flag.
    pop r19                   ; Retrieve status register.
    andi r19,rxErrorFlags     ; Z will be clear if error(s).
    ret                       ; Done.    
    
    
;-----------------------------------------------------------
; The messages to be printed to the USART repeatedly.
;-----------------------------------------------------------
prompt:
    .asciz "Type your name: \r\n"
    
hello:
    .asciz "Hello "
