#define __SFR_OFFSET 0
#include <avr/io.h>
#include <LM75A_Lib.h>
#include <ASM_Usart.h>

.global main

; Where does my LM75A sensor live? 7 bit address.
.equ LM75_Address,0x4F

;-------------------------------------------------------------
.section .data
;-------------------------------------------------------------

;-------------------------------------------------------------
; Data space for two bytes, received in the loop from the LM75
; temperature sensor.
;-------------------------------------------------------------
tempData:
    .space  2

;-------------------------------------------------------------
.section .text
;-------------------------------------------------------------

main:
setupI2C:
    ldi     r24,TWI2C_200KHZ    ; 200 KHz SCL clock setting.
    call    twi2c_init          ; Initialise I2C to 200 KHz.

setupUSART:
    call    UsartTX9600         ; USART = 9600, 8-N-1.
    ldi     ZH,hi8(signOn)      ; Sign on prompt.
    ldi     ZL,lo8(signOn)
    call    transmit_z          ; Print sign on message.

setupLM75A:
    ldi     r24,LM75_Address    ; 7 bit LM75 address.
    call    LM75AInit           ; No errors.
    ldi     r24,LM75A_SHUTDOWN_ENABLE ; Shutdown mode required.
    call    setShutdown         ; Set shutdown mode.
    brne    writeError          ; Oops, cant set shutdown mode.

readTempLoop:
    ldi     XH,hi8(tempData)    ; Data buffer.
    ldi     XL,lo8(tempData)
    call    getCurrentTemperature
    brne    readError           ; Read failed.
    rcall   printTemperature    ; Guess!
    rcall   longDelay           ; Wait 2500 milliseconds.
    rcall   longDelay           ; Another 2500 milliseconds.
    rjmp    readTempLoop

;-------------------------------------------------------------
; Failed to read data. Report error and the status. Blink the
; LED also.
;-------------------------------------------------------------
readError:
    push    r24             ; Save the status code.
    ldi     ZH,hi8(noRead)
    ldi     ZL,lo8(noRead)
    call    transmit_z      ; Print "Failed to start ...".
    rjmp    errorStatus     ; Print status and blink LED.

;-------------------------------------------------------------
; Failed to write data. Report error and the status. Blink the
; LED also.
;-------------------------------------------------------------
writeError:
    push    r24             ; Save the status code.
    ldi     ZH,hi8(noWrite)
    ldi     ZL,lo8(noWrite)
    call    transmit_z      ; Print "Failed to start ...".
    rjmp    errorStatus     ; Print status and blink LED.
    
;-------------------------------------------------------------
; Unable to process a transaction. Blink the PB5/D13
; LED once every 2,500 milliseconds.
;-------------------------------------------------------------
errorStatus:
    pop     r24             ; Retrieve the status code.
    rcall   hexR24          ; Print status in hexadecimal.
    rcall   printCRLF       ; New line.

    ldi     r24,(1 << DDB5) ; PB5/D13 is the error LED.    
    out     DDRB,r24        ; Make it output.

errorLoop:
    ldi     r24,(1 << PINB5) ; R24 corrupted by longDelay.
    out     PINB,r24        ; Toggle PB5/D13.
    rcall   longDelay       ; 2,500 millisecond delay.
    rcall   longDelay       ; Another 2,500 milliseconds.
    rjmp    errorLoop       ; Lets's go round again.

;-------------------------------------------------------------
; Helper to print data byte in R24 in decimal.
;-------------------------------------------------------------
printData:
    push    XH
    push    XL
    ldi     XH,hi8(tempData)    ; Data buffer.
    ldi     XL,lo8(tempData)
    st      X+,r24              ; Save data byte.
    clr     r24
    st      X,r24
    ldi     XH,hi8(tempData)    ; Data buffer.
    ldi     XL,lo8(tempData)
    rcall   printTemperature    ; Print the data in decimal.  
    pop     XL
    pop     XH
    ret

;-------------------------------------------------------------
; Sends a CR/LF to the USART.
;-------------------------------------------------------------
printCRLF:
    ldi     ZH,hi8(crlf)
    ldi     ZL,lo8(crlf)  
    call    transmit_z          ; Print CR/LF
    ret
    
;-------------------------------------------------------------
; Prints out the temperature in Celcius. X points at the data.
; Call at printAlarmTemp to print a temperature value in R25,
; NOTE: The fractions are random in this case! See text.
;
; Corrupts R19, R20, R25, Z.
;-------------------------------------------------------------
printTemperature:
    ld      r25,X+              ; Fetch degrees data.
    rcall   DecimalR25          ; Convert to decimal & print.
    ldi     r19,'.'
    call    transmitByte        ; Print decimal point.
    ldi     r19,'0'             ; Assume exact degrees.
    ld      r25,X               ; Fetch degree fractions.
    sbrc    r25,7               ; Bit 7 = 0.0 or 0.5.
    ldi     r19,'5'             ; 0.5 it is then.
    call    transmitByte        ; Print fraction.
    ldi     r19,'C'             ; In case of confusion!
    call    transmitByte        ; Print scale.
    rjmp    printCRLF           ; Exit via printCRLF.
    
;--------------------------------------------------------------
; Convert R25, which might be negative, to decimal. Doesn't 
; print leading zeros. This is a quick and dirty conversion to
; decimal for a one byte signed value.
;
; Corrupts R18, R19, R25.
;--------------------------------------------------------------
DecimalR25:
    tst     r25             ; Negative?
    brge    start100        ; No, get converting.
    ldi     r19,'-'         ; Negative number.
    call    transmitByte    ; Print it.
    neg     r25             ; Make positive.

start100:
    ldi     r19,'0'         ; Hundreds digit.
    clr     r18             ; Digits printed so far count.

loop100:
    subi    r25,100         ; Subtract 100
    brlt    end100          ; Done.
    inc     r19             ; Increment hundreds digit.
    rjmp    loop100

end100:
    cpi     r19,'0'         ; Zero hundreds?
    breq    start10         ; Yes, ignore it.
    call    transmitByte    ; Print hundreds digit.
    inc     r18             ; We have printed a digit.

start10:
    subi    r25,-100        ; Add hundred back.
    ldi     r19,'0'         ; Tens digit.

loop10:
    subi    r25,10          ; Subtract 10.
    brlt    end10           ; Done.
    inc     r19             ; Increment 10s digit.
    rjmp    loop10

end10:
    cpi     r19,'0'         ; Zero tens?
    brne    print10         ; No, print the digit.

    tst     r18             ; Any digits printed yet?
    brne    print10         ; Yes, we need this zero.

print10:
    call    transmitByte    ; Print the tens digit.
    inc     r18             ; And count it.

start1:
    subi    r25,-10         ; Add back the extra 10.
    ldi     r19,'0'         ; Units digits.
    add     r19,r25         ; Convert to actual value.
    call    transmitByte    ; Print units digit.
    ret

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
    push    r24            ; Save byte value.
    andi    r24,0x0f       ; Keep low nibble only.
    subi    r24,-'0'       ; Convert to ASCII - Add '0'.
    cpi     r24,10+'0'     ; Not a digit?
    brlo    sendNibble     ; It was a digit.
    subi    r24,-7         ; Adjust A-F only here.

sendNibble:
    mov     r19,r24         ; Copy to R19 for USART.
    call    transmitByte    ; Send hex nibble to USART.
    pop     r24             ; Retrieve original byte value.
    pop     r19             ; And R19 too.
    ret