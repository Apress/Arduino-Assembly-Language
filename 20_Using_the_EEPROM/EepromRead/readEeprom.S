;============================================================
; ReadEeprom.S is a small set of useful functions to make 
; reading data from the EEPROM a lot easier in Assembly
; Language code.
;
; Functions exposed:
;
; NextAddress = readByte(address), data returned in R18.
; NextAddress = readWord(address), data returned in R19:R18.
; NextAddress = readLong(address), data returned in R21:R18.
; NextAddress = readText(address), data returned at R25:R24.
;
; Norman Dunbar.
; 21 February 2025.
;============================================================

#define __SFR_OFFSET 0
#include <avr/io.h>

.global readByte
.global readWord
.global readLong
.global readText

.section .text

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
; Reads a word from the EEPROM.
;------------------------------------------------------------
; Inputs: 
;   R25:R24 = Address to read from.
; Outputs:
;   R25:R24 = Next address to read from.
;   R19:R18 = Data word read from address.
; Corrupts:
;   R25:R24, R19:R18. All other registers are preserved.
;------------------------------------------------------------
readWord:
    rcall readByte          ; Read low byte into R18.
    push r18                ; Save it.
    rcall readByte          ; Read high byte into R18.
    mov r19,r18             ; Swap high byte into R19.
    pop r18                 ; Retrieve the low byte.
    ret

;------------------------------------------------------------
; Reads a long from the EEPROM.
;------------------------------------------------------------
; Inputs: 
;   R25:R24 = Address to read from.
; Outputs:
;   R25:R24 = Next address to read from.
;   R21:R18 = Data long read from address.
; Corrupts:
;   R25:R24, R21:R18. All other registers are preserved.
;------------------------------------------------------------
readLong:
    rcall readWord          ; Read low word into R19:R18.
    push R19                ; Save low word.
    push r18
    rcall readWord          ; Read high word.
    mov r20,r18             ; Copy to correct return registers.
    mov r21,r19
    pop r18                 ; Retrieve low word.
    pop r19
    ret


;------------------------------------------------------------
; Unused in this sketch, but still handy!
;------------------------------------------------------------
; Reads a text string from the EEPROM including the zero byte
; used to terminate the string. The text will be copied to an
; address in the .data section pointed to by the Y register.
;------------------------------------------------------------
; Inputs: 
;   R25:R24 = Address to read from.
; Outputs:
;   R25:R24 = Next address to read from.
; Corrupts:
;   R25:R24. All other registers are preserved.
;------------------------------------------------------------
readText:
    push YH                 ; Preserve working registers.
    push YL
    push r18

readLoop:
    rcall readByte          ; Read from the EEPROM.
    st Y+,r18               ; Store in .data buffer.
    tst r18                 ; Are we done yet?
    brne readLoop           ; No.

    pop r18                 ; Restore working registers.
    pop YL
    pop YH
    ret