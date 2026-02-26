;-------------------------------------------------------------
; This file contains all the messages that we will need to 
; send to the USART while the sketch is working. The trailing
; "align 2" line makes sure that any following code starts on
; an even BYTE address. If not, we get compiler "out of range"
; errors due to following code being on an odd address, which
; is a really bad thing as the code is not on word boundaries.
;-------------------------------------------------------------


;-------------------------------------------------------------
; Status Codes.
;
; Miscellaneous Codes
; -------------------
;
; 0x00 Bus error - illegal Start or Stop condition.
; 0xF8 No state information available as TWINT still = 0, wait!
;
; All Controller Modes
; --------------------
;
; 0x08 Start has been transmitted.
; 0x10 Repeated starts has been transmitted.
;
; Controller Transmitter Mode
; ---------------------------
;
; 0x18 SLA_W transmitted, ACK received.
; 0x20 SLA_W transmitted, NACK received.
; 0x28 Data byte tranmitted, ACK received.
; 0x30 Data byte tranmitted, NACK received.
; 0x38 Arbitration has been lost in SLA_W or data byte transmission.
;
; Controller Receiver Mode
; ------------------------
;
; 0x38 Arbitration has been lost in SLA_R or NACK transmission.
; 0x40 SLA_R transmitted, ACK received.
; 0x48 SLA_R transmitted, NACK received.
; 0x50 Data byte received, ACK transmitted.
; 0x58 Data byte received, NACK transmitted.
;
; Peripheral Transmitter Mode
; ---------------------------
;
; 0xA8 Own SLA_R received, ACK transmitted.
; 0xB0 Arbitration lost in SLA_R/SLA_W.
; 0xB8 Data byte transmitted, ACK received.
; 0xC0 Data byte transmitted, NACK received.
; 0xC8 Final Data byte transmitted, ACK received.
;
; Peripheral Receiver Mode
; ------------------------
;
; 0x60 Own SLA_W received, ACK transmitted.
; 0x68 Arbitration lost in SLA_R/SLA_W.
; 0x70 General call received, ACK transmitted.
; 0x78 Arbitration lost due to general call.
; 0x80 Data byte received, ACK transmitted.
; 0x88 Data byte received, NACK transmitted.
; 0x90 General call data received, ACK transmitted.
; 0x98 General call data received, NACK transmitted.
; 0xA0 Stop or repeated start received.
;
;-------------------------------------------------------------

.global     signOn
.global     noRead
.global     crlf

.section .text

signOn:
    .asciz  "LM75A Comparator Alarm\r\n"

noRead:
    .asciz  "Read failed. Status: 0x"

crlf:
    .asciz  "\r\n"

;-------------------------------------------------------------
; *****  Do not add messages after the following line!   *****
;-------------------------------------------------------------
.align 2
