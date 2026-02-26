;-------------------------------------------------------------
; This file contains all the messages that we will need to 
; send to the USART while the sketch is working. The trailing
; "align 2" line makes sure that any following code starts on
; an even BYTE address. If not, we get compiler "out of range"
; errors due to following code being on an odd address, which
; is a really bad thing as the code is not on word boundaries.
;-------------------------------------------------------------

.global     signOn
.global     scanning
.global     scanDone
.global     devFound
.global     noStart
.global     crlf

signOn:
    .asciz  "I2C/TWI Scanner\r\n"

scanning:
    .asciz  "Scanning...\r\n"

scanDone:
    .asciz  "Scan ends.\r\n\r\n"

devFound:
    .asciz  "Device found at address 0x"

noStart:
    .asciz  "Failed to start a write transaction. Status: 0x"

crlf:
    .asciz  "\r\n"

;-------------------------------------------------------------
; *****  Do not add messages after the following line!   *****
;-------------------------------------------------------------
.align 2
