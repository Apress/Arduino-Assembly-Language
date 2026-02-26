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
; Read through the EEPROM converting everything to hex and
; sending it to the USART at 9600 baud. There will be:
;
; 10 Eight bit data values.
; 10 sixteen bit data values.
; 10 thirty two bit data values.
; Some text, terminated by a zero byte.
;------------------------------------------------------------
main:
    call UsartTX9600        ; 9600, 8-N-1, double speed.
    clr r25                 ; EEPROM start address = zero.
    clr r24

;------------------------------------------------------------
; DoBytes prints the first 10 EEPROM addresses and the
; byte of data located at that address.
;------------------------------------------------------------
doBytes:
    ldi r22,10              ; 10 bytes to print.

byteLoop:
    rcall printAddress      ; Print address in R25:R24.
    rcall readByte          ; Read a byte at R25:R24 -> R18.
    rcall hexR18            ; Convert to hex and print. 
    rcall crlf              ; CR/LF after each one.
    dec r22                 ; Done yet?
    brne byteLoop           ; Not yet.
    rcall crlf              ; And a blank line to finsh.

;------------------------------------------------------------
; DoWords prints out 10 16 bit values and the EEPROM 
; addresses that are found at. The ATmega328P is "litte
; endian" so the first byte read is the low byte so we will
; save that on the stack until we read and print the high 
; byte of the 16 bit data values.
;------------------------------------------------------------
doWords:
    ldi r22,10              ; 10 Words to print.

wordLoop:
    rcall printAddress      ; Print address in R25:R24.
    rcall readWord          ; Reads a word into R19:R18.
                            ; Also, increments R25:R24.
    push r18                ; Save low byte.
    mov r18,r19             ; Fetch high byte.
    rcall hexR18            ; Print it.
    pop r18                 ; Retrieve low byte.
    rcall hexR18            ; Print it.
    rcall crlf              ; Print CR/LF.
    dec r22                 ; More to do?
    brne wordLoop           ; Yes, go do them.
    rcall crlf              ; Done. Extra CR/LF required.

;------------------------------------------------------------
; DoLongs prints out 10 32 bit values and the EEPROM 
; addresses that are found at.  The ATmega328P is "litte
; endian" so the first byte read is the low byte so we will
; save that on the stack until we read and print the high 
; byte of the 32 bit data values. This means reading and
; saving 4 bytes on the stack before printing them on the
; Serial Monitor.
;------------------------------------------------------------
doLongs:
    ldi r22,10              ; 10 Long words to print.

longLoop:
    rcall printAddress      ; Print address in R25:R24.
    rcall readLong          ; Fetch long -> R21:R18.
    push r18                ; Save low byte.
    mov r18,r21             ; Fetch high byte.
    rcall hexR18            ; Print it.
    mov r18,r20             ; Next MSB.
    rcall hexR18                
    mov r18,r19             ; Next MSB
    rcall hexR18
    pop r18                 ; Retrieve low byte.
    rcall hexR18            ; Print it.
    rcall crlf              ; Print CR/LF.
    dec r22                 ; More to do?
    brne longLoop           ; Yes, go do them.
    rcall crlf              ; Done. Extra CR/LF required.



;------------------------------------------------------------
; Do test simply loops around, reading one byte of textual
; data from the EEPROM and printing it out. The loop stops
; when a byte of zero is read, which will not be printed.
;------------------------------------------------------------
doText:
    rcall readByte          ; Read a byte -> R18
    tst r18                 ; Got the zero byte?
    breq txtDone            ; Yes, done.
    mov r19,r18             ; Copy to R19 for printout.
    call transmitByte       ; Print the data byte.
    rjmp doText             ; Loop until zero byte.     

txtDone:
    rjmp txtDone

;------------------------------------------------------------
; Print 0xAAAA<TAB> to display the EEPROM address for each
; line of output. 
;
; Inputs:
;   R25:R24 - the address of the EEPROM concerned.
; Outputs:  None.
;
; Preserves all registers.
;------------------------------------------------------------
printAddress:
    push r18
    push r19
    ldi r19,'0'             ; Print "0x" first.
    call transmitByte
    ldi r19,'x'
    call transmitByte
    mov r18,r25             ; High address byte.
    rcall hexR18            ; Print it.
    mov r18,r24             ; Low address byte.
    rcall hexR18            ; Print it too.
    ldi r19,'\t'            ; TAB.
    rcall transmitByte
    pop r19
    pop r18
    ret

;------------------------------------------------------------
; Sends the CR/LF pair to the USART.
;
; Inputs:   None.
; Outputs:  None.
;------------------------------------------------------------
crlf:
    push r19
    ldi r19,CR              ; CR/LF next.
    call transmitByte  
    ldi r19,LF
    call transmitByte  
    pop r19
    ret

;------------------------------------------------------------
; Convert R18 to hex and send it to the USART to print it on
; the Serial Monitor.
; 
; Inputs:
;   Expects a data value in R18.
; 
; Preserves all working registers.
;------------------------------------------------------------
hexR18:
    swap    r18             ; Swap nibbles.
    rcall   hex4            ; Print high nibble.
    swap    r18             ; Swap back again.
    rcall   hex4            ; Print low nibble.
    ret

hex4:
    push    r19
    push    r18            ; Save byte value.
    andi    r18,0x0f       ; Keep low nibble only.
    subi    r18,-'0'       ; Convert to ASCII - Add '0'.
    cpi     r18,10+'0'     ; Not a digit?
    brlo    sendNibble     ; It was a digit.
    subi    r18,-7         ; Adjust A-F only here.

sendNibble:
    mov     r19,r18         ; Copy to R19 for USART.
    call    transmitByte    ; Send hex nibble to USART.
    pop     r18             ; Retrieve original byte value.
    pop     r19             ; And R19 too.
    ret