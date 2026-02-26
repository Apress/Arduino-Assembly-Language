;============================================================
; WriteEeprom.S is a small set of useful functions to make 
; writing data to and from the EEPROM a lot easier in  
; Assembly Language code.
;
; Functions exposed:
;
; NextAddress = writeByte(address, dataByte)
; NextAddress = writeWord(address, dataWord)
; NextAddress = writeLong(address, dataLong)
; NextAddress = writePText(address)
; NextAddress = writeDText(address)
;
; Norman Dunbar.
; 21 February 2025.
;============================================================

#define __SFR_OFFSET 0
#include <avr/io.h>

.global writeByte
.global writeWord
.global writeLong
.global writePText
.global writeDText

.section .text

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
    cbr r22,(1 << EEPM0)    ; Erase then write.
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
    

;------------------------------------------------------------
; Writes a word to the EEPROM in little endian format.
;------------------------------------------------------------
; Inputs: 
;   R19:R18 = word to be written.
;   R25:R24 = Address to write to.
; Outputs:
;   R25:R24 = Next address to write to.
; Corrupts:
;   R25, R24. All other registers are preserved.
;------------------------------------------------------------
writeWord:
    push r18
    rcall writeByte         ; Write low byte.
    mov r18,r19             ; Swap bytes over.
    rcall writeByte         ; Write high byte.
    pop r18
    ret

;------------------------------------------------------------
; Writes a long to the EEPROM in little endian format.
;------------------------------------------------------------
; Inputs: 
;   R21:R18 = long to be written.
;   R25:R24 = Address to write to.
; Outputs:
;   R25:R24 = Next address to write to.
; Corrupts:
;   R25, R24. All other registers are preserved.
;------------------------------------------------------------
writeLong:
    push r18
    push r19
    rcall writeWord         ; Write low word.
    mov r18,r20             ; Swap words over.
    mov r19,r21
    rcall writeWord         ; Write high word.
    pop r19
    pop r18
    ret


;------------------------------------------------------------
; Writes a text string to the EEPROM including the zero byte
; used to terminate the string. The text must be in the .text
; section, not the .data section.
;------------------------------------------------------------
; Inputs: 
;   R25:R24 = Address to write to.
; Outputs:
;   R25:R24 = Next address to write to.
; Corrupts:
;   R25:R24. All other registers are preserved.
;------------------------------------------------------------
writePText:
    push ZH                 ; Preserve working registers.
    push ZL
    push r18

textLoop:
    lpm r18,Z+              ; Fetch a text byte.
    rcall writeByte         ; Write it to EEPROM.
    tst r18                 ; Are we done yet?
    brne textLoop           ; No.

    pop r18                 ; Restore working registers.
    pop ZL
    pop ZH
    ret

;------------------------------------------------------------
; Unused in this sketch, but still handy!
;------------------------------------------------------------
; Writes a text string to the EEPROM including the zero byte
; used to terminate the string. The text must be in the .data
; section, not the .text section.
;------------------------------------------------------------
; Inputs: 
;   R25:R24 = Address to write to.
; Outputs:
;   R25:R24 = Next address to write to.
; Corrupts:
;   R25:R24. All other registers are preserved.
;------------------------------------------------------------
writeDText:
    push YH                 ; Preserve working registers.
    push YL
    push r18

dataLoop:
    ld r18,Y+               ; Fetch a text byte.
    rcall writeByte         ; Write it to EEPROM.
    tst r18                 ; Are we done yet?
    brne textLoop           ; No.

    pop r18                 ; Restore working registers.
    pop YL
    pop YH
    ret