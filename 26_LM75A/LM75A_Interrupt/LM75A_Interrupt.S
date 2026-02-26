#define __SFR_OFFSET 0
#include <avr/io.h>
#include <LM75A_Lib.h>
#include <ASM_Usart.h>

.global main
.global INT0_vect

; Where does my LM75A sensor live? 7 bit address.
.equ LM75_Address,0x4F

;-------------------------------------------------------------
.section .data
;-------------------------------------------------------------

;-------------------------------------------------------------
; Data space for two bytes, received in the loop from the LM75
; temperature sensor. We only need this to keep an eye on the
; current temperature to check if the alarm is working!
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

setupPins:
    ldi     r24,(1 << DDB5)     ; PB5/D13 is output.
    out     DDRB,r24            ; Make it so.
    in      r24,DDRD
    cbr     r24,(1 << DDD2)     
    out     DDRD,r24            ; PB2/D2 is input       
    ldi     r24,(1 << DDD2)     ; PB2/D2 needs pullup.
    out     PORTD,r24           ; Enable pullup. 

; NOTE: EICRA is STS, the others are OUT. Most annoying!
; Also, if you STS EIMSK it won't work, it has to be OUT.
setupInterrupt:
    cli                         ; Interrupts off.
    ldi     r24,(1 << ISC01)    ; ISC01 has to be set.
    sts     EICRA,r24           ; INT0 interrupt on FALLING.
    ldi     r24,(1 << INTF0)    ; We write a 1 to clear a flag!
    out     EIFR,r24            ; Clear flag.
    ldi     r24,(1 << INT0)     ; Set the bit to enable INT0.
    out     EIMSK,r24           ; Enabled.
    sei                         ; Interrupts back on.

;-------------------------------------------------------------
; Here we set the alarm temperature to current plus 3 degrees
; and the alarm off temperature to current plus 1. Then set
; the LM75A into interrupt mode.
;
; By default, the LM75A is in comparator mode and OS is active
; low and must be pulled up. I use the D2/PB2 pin's pullup for
; this.
;
; NOTE: It seems, on my LM75A anyawy, that some config
; occasionally "stick" so calling a reset here clears those
; problems.
;-------------------------------------------------------------
setLM75Alarm:
    call    resetConfig         ; Ensure known state.
    ldi     XH,hi8(tempData)    ; Data buffer.
    ldi     XL,lo8(tempData)    
    call    getCurrentTemperature ; What temp is it now?
    brne    readError           ; Oops!
    ld      r24,X               ; Grab current degrees.
    subi    r24,-1              ; Plus 1 for low limit.
    call    setOSHyst           ; Set min temperature.
    ld      r24,X               ; Grab current degrees.
    subi    r24,-3              ; Add 3 degrees.
    call    setOSTemp           ; Set max temperature.
    call    setInterrupt        ; Set mode.

; In interrupt mode, we can't read from the LM75A or 
; we will clear the OS pin back to inactive. From the NXP
; and TI data sheets:
;
; In interrupt mode, once it has been activated either
; by exceeding T_os or dropping below T_hyst, the OS output
; will remain active indefinitely until reading a 
; register, then the OS output is reset.
;
; In Interrupt mode exceeding TOS also makes OS active
; but OS will remain active indefinitely until reset by
; reading any register via the I2C interface. Once OS has
; been activated by crossing TOS, then reset, it can be
; activated again only by Temperature going below THYST.
;  Again, it will remain active indefinitely until being
; reset by a read. 
;
; Placing the LM75A in shutdown mode also resets the OS
; Output.

loop:
    rjmp    loop                ; Spin wait forever...

;-------------------------------------------------------------
; Failed to read data. Report error and the status. Blink the
; LED also.
;-------------------------------------------------------------
readError:
    push    r24             ; Save the status code.
    ldi     ZH,hi8(noRead)
    ldi     ZL,lo8(noRead)
    call    transmit_z      ; Print "Failed to start ...".
    
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
; Sends a CR/LF to the USART.
;-------------------------------------------------------------
printCRLF:
    ldi     ZH,hi8(crlf)
    ldi     ZL,lo8(crlf)  
    call    transmit_z          ; Print CR/LF
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

;--------------------------------------------------------------
; Interrupt handler. Pin D2 will go low when an interrupt is
; triggered by the LM75A. We need to check if the LED is on or
; off before changing it's state. Luckily, we can simply toggle
; the LED on interrupt to be correctly set. 
;
; For interrupt mode, we need to reset the LM75A's OS pin or it
; will stay enabled forever.
;
; Here we light the LED on over temperature and reset. Then,
; when the temperature drops below T_HYST, we get another 
; interrupt which turns the LED off and resets the OS pin. 
;
; WARNING: In LM75A interrupt mode, we must always reset the OS
; pin, or we will *never* see the LED go out! 
;
; Repeat until bored or the world ends!
;--------------------------------------------------------------
INT0_vect:
    push    r24             ; Preserve R24
    in      r24,SREG        ; Must preserve SREG too.
    push    r24             ; That's done now.
    ldi     r24,(1 << PINB5) ; D13/PB5 LED needs toggling.
    out     PINB,r24        ; Do it.

    ; Comment out the next line and the LED never goes out
    ; as there isn't a second interrupt on the OS pin to
    ; turn it off. Uncommented, there are two interrupts:
    ; The first lights the LED, the interrupt is cleared.
    ; The second dims the LED and again, clears the interrupt.
    call    getCurrentTemperature ; Reset OS pin.
    pop     r24             ; Retrieve SREG setting.
    out     SREG,r24        ; Restore it.
    pop     r24             ; Restore R24.
    reti                    ; Note, RETI not RET.
