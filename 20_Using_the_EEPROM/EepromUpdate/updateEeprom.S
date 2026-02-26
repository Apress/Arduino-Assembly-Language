;============================================================
; UpdateEeprom.S is a small set of useful functions to make 
; reading and writing data from the EEPROM a lot easier in
; Assembly Language code.
;
; Functions exposed:
;
; NextAddress = readByte(address), data returned in R18.
; NextAddress = writeByte(address, dataByte)
; NextAddress = updateByte(address, dataByte)
;
; Norman Dunbar.
; 21 February 2025.
;============================================================

#define __SFR_OFFSET 0
#include <avr/io.h>

.global readByte
.global updateByte
.global writeByte


.section .text

;------------------------------------------------------------
; Updates a byte in the EEPROM. Only writes a new value if it
; is different from the byte in the EEPROM.
;------------------------------------------------------------
; Inputs: 
;   R25:R24 = Address to read from.
;   R19 = Data for the EEPROM.
; Outputs:
;   R25:R24 = Next address to read from.
; Corrupts:
;   R25:R24. All other registers are preserved.
;------------------------------------------------------------
updateByte:
    push r25                ; Save high address byte.
    sbr r25,7               ; Don't increment address.
    rcall readByte          ; Reads data into R18.
    pop r25                 ; Restore address.
    cp r19,r18              ; Same value?
    brne doUpdate           ; No, update the data.
    adiw r24,1              ; Manually increment the address.
    ret                     ; Done.

doUpdate:
    mov r18,r19             ; Copy new value to R18.
    rcall writeByte         ; Update EEPROM.
                            ; Increments address in R25:R24.
    ret

;------------------------------------------------------------
; Reads a byte from the EEPROM. Handles all the requirements
; to do so. This is the workhorse of all the readXXXX 
; functions in this library.
;------------------------------------------------------------
; Inputs: 
;   R25:R24 = Address to read from.
;   R25, bit 7 set = Do not increment address on return.
; Outputs:
;   R25:R24 = Next address to read from.
;   R18     = Data byte.
; Corrupts:
;   R18, R25:R24. All other registers are preserved.
;------------------------------------------------------------
readByte:
    sbic EECR,EEPE          ; Wait for EEPE to clear.
    rjmp readByte

eepromRdReady:
    out EEARH,r25           ; Setup read address.
    out EEARL,r24
    sbi EECR,EERE           ; Enable EEPROM reads.
    in r18,EEDR             ; Read a byte
    sbrs r25,7              ; Bit 7 is set? Don't increment.
    adiw r24,1              ; Increment address to next.
    ret
    
;------------------------------------------------------------
; Writes a byte to the EEPROM. Handles all the requirements
; to do so. This is the workhorse of all the writeXXXX 
; functions in this library.
;
; This function always uses mode 00 which erases the current
; byte and writes the new one.
;------------------------------------------------------------
; Inputs: 
;   R18 = byte to be written.
;   R25:R24 = Address to write to.
; Outputs:
;   R25:R24 = Next address to write to.
; Corrupts:
;   R25:R24. All other registers are preserved.
;------------------------------------------------------------
writeByte:
    sbic EECR,EEPE          ; Wait for EEPE to clear.
    rjmp writeByte
    push r22                ; Save working registers.
    push r23

waitSPM:
    lds r22,SPMCSR          ; Read Flash write status.
    sbrc r22,SELFPRGEN      ; Wait for Flash writes.
    rjmp waitSPM

eepromWrReady:
    in r22,EECR             ; Read EECR
    cbr r22,(1 << EEPM0)    ; Setup EEPROM mode.
    cbr r22,(1 << EEPM1)
    out EEARH,r25           ; Load EEPROM address.
    out EEARL,r24
    out EEDR,r18            ; Load data byte.
    in r23,SREG             ; Get interrupt status
    cli                     ; Disable interrupts.
    sbr r22,(1 << EEMPE)    ; Setup timed sequence bits.
    cbr r22,(1 << EEPE)
    out EECR,r22            ; Start timed sequence.
                            ; And set mode bits.
    sbr r22,(1 << EEPE)     ; Setup write enable.
    out EECR,r22            ; Write enabled.
    out SREG,r23            ; Reset interrupts  
    adiw r24,1              ; Increment address to next.
    pop r23                 ; Restore working registers.
    pop r22
    ret

