#define __SFR_OFFSET 0
#include <avr/io.h>
#include <I2C_ASM.h>
#include <ASM_Usart.h>

.global main

; When should I stop canning addresses?;
.equ endAddress,0x80        ; First invalid address.

;-------------------------------------------------------------
.section .text
;-------------------------------------------------------------


;--------------------------------------------------------------
; Scans the TWI bus for devices in range 1--127. Any that get
; an ACK when SLA_W'd are valid devices on the bus. When all
; device addresses have been checked, delays 5 seconds before
; scanning the bus again. This gives you a chance to poke some
; wires or fiddle with your breadboard without having to 
; reboot the Arduino to get another scan.
;
; The process is:
;
; For each address 1 to 127:
;   Start a write transaction.
;   If Z is set, we have a device, report it's 7 bit address.
;   End the transaction.
; End of loop.
; Wait 5 seconds.
; Start the loop again from the top.
;
; Reports devices found to the Serial Monitor.
;--------------------------------------------------------------
main:
    ldi     r24,TWI2C_200KHZ ; 200 KHz SCL clock setting.
    call    twi2c_init      ; Initialise I2C to 200 KHz.

    call    UsartTX9600     ; USART = 9600, 8-N-1.
    ldi     ZH,hi8(signOn)  ; Sign on prompt.
    ldi     ZL,lo8(signOn)
    call    transmit_z      ; Print signon message.

; Start of a new scan loop.
scanLoop:
    ldi     ZH,hi8(scanning)
    ldi     ZL,lo8(scanning)
    call    transmit_z      ; Print "Scanning..."
    clr     r24             ; 7 bit address in R24.

; Start a scan of the next 7 bit address.
nextScan:
    inc     r24             ; Next valid 7 bit address.
    cpi     r24,endAddress  ; Are we done yet?
    breq    loopDone        ; Yes, skip further processing.
    push    r24             ; Save 7 bit address.
    call    twi2c_begin_tx  ; Start a write transaction.
                            ; Z set if all ok.
    pop     r24             ; Restore 7 bit address.
    brne    nextScan        ; Nothing at this address.

; We have a device at this 7 bit address.
deviceFound:
    ldi     ZH,hi8(devFound)
    ldi     ZL,lo8(devFound)
    call    transmit_z      ; Print "Device found ..."
    rcall   hexR24          ; Print address in hex.
    ldi     ZH,hi8(crlf)
    ldi     ZL,lo8(crlf)  
    call    transmit_z      ; Print CR/LF
    call    twi2c_end_tx    ; Send stop. No status returned!
    rjmp    nextScan        ; Keep scanning.

; End of loop, report finished, delay a bit, start a new scan.
loopDone:
    ldi     ZH,hi8(scanDone)
    ldi     ZL,lo8(scanDone)
    call    transmit_z      ; Print "Scan ends".
    rcall   longDelay       ; Wait 2500 milliseconds.
    rcall   longDelay       ; And another 2500.
    rjmp    scanLoop        ; Lets go round again.

;--------------------------------------------------------------
; Prints out an 8 bit hexadecimal number.
;
; Expects the value to be printed in R24.
;
; Preserves all registers.
;--------------------------------------------------------------
hexR24:
    swap    r24             ; Swap nibbles.
    rcall   hex4            ; Print high nibble.
    swap    r24             ; Swap back again.
    rcall   hex4            ; Print low nibble.
    ret

;--------------------------------------------------------------
; Convert a nibble to hexadecimal and print it to the USART.
; R24 holds the byte to be converted.
;
; Preserves all registers.
;--------------------------------------------------------------
hex4:
    push    r19
    push    r24             ; Save byte value.
    andi    r24,0x0f        ; Keep low nibble only.
    subi    r24,-'0'        ; Convert to ASCII - Add '0'.
    cpi     r24,10+'0'      ; Not a digit?
    brlo    sendNibble      ; It was a digit.
    subi    r24,-7          ; Adjust A-F only here.

sendNibble:
    mov     r19,r24         ; Copy to R19 for USART.
    call    transmitByte    ; Send hex nibble to USART.
    pop     r24             ; Retrieve original byte value.
    pop     r19             ; And R19 too.
    ret

