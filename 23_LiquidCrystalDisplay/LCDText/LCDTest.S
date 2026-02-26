#include <LCDLibrary.h>

.global main

;-------------------------------------------------------------
; A couple of useful constants for row and column positions.
;-------------------------------------------------------------
.equ    ROW_0,0
.equ    ROW_1,1
.equ    COL_0,0

;-------------------------------------------------------------
; The .data section simply reserves 50 bytes for the text to  
; be copied in from the .code section.
;-------------------------------------------------------------
.section    .data

DataText:
    .space  50


;-------------------------------------------------------------
; The demonstration starts here!
;-------------------------------------------------------------

.section    .text


main:
    call    copyText            ; Copy text into .data section
    call    LCDBegin            ; 16x2 LCD, 4 bit mode.

    ldi     r25,ROW_0           ; Ready to set cursor.
    ldi     r24,COL_0
    call    LCDCursorAt         ; Position cursor.
    ldi     ZH,hi8(PGMText)     ; Text to be displayed.
    ldi     ZL,lo8(PGMText)
    call    LCDSendZText        ; Print from Flash RAM.

    ldi     r25,ROW_1           ; Ready to set cursor.
    ldi     r24,COL_0
    call    LCDCursorAt         ; Position cursor.
    ldi     XH,hi8(DataText)    ; Text to be displayed.
    ldi     XL,lo8(DataText)
    call    LCDSendXText        ; Print from Data RAM.

loop:
    rjmp    loop

;-------------------------------------------------------------
; The text here must be shorter than 17 characters. Also, odd
; text lengths will mess up the code alignment and give lots
; of compiler errors like "internal error: out of range error"
; Comment out the ".align 2" line below and try compiling! 
;
; Code must be aligned to even addresses, so the ".align 2" 
; will ensure that the following code will be correctly 
; aligned if odd sized text is specified.
;-------------------------------------------------------------
PGMText:
    .asciz  "ZZ text here ZZ"
    .align 2


;-------------------------------------------------------------
; Copy the text to display from .text to .data. On the way
; over, change 'Z' to 'X' so that they are different when on
; the LCD display.
;-------------------------------------------------------------
copyText:
    ldi     ZH,hi8(PGMText)     ; Text in .text section.
    ldi     ZL,lo8(PGMText)
    ldi     XH,hi8(DataText)    ; Copy to .data section.
    ldi     XL,lo8(DataText)

copyLoop:
    lpm     r24,Z+              ; Fetch one character.
    cpi     r24,'Z'             ; Got a 'Z' character?
    brne    copyByte            ; No, copy it unchanged.
    ldi     r24,'X'             ; Yes, alter it slightly.

copyByte:
    st      X+,r24              ; Store in .data section.
    cpi     r24,0               ; Done yet?
    brne    copyLoop            ; No, do some more.
    ret