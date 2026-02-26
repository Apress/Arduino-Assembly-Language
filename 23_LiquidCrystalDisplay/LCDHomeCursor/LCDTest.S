#include <avr/io.h>
#include <LCDLibrary.h>

.global main

;-------------------------------------------------------------
; A couple of useful constants for row and column positions.
;-------------------------------------------------------------
.equ    ROW_0,0
.equ    COL_0,0

;-------------------------------------------------------------
; The demonstration starts here!
;-------------------------------------------------------------

.section    .text


main:
    call    LCDBegin            ; 16x2 LCD, 4 bit mode.

    ldi     r25,ROW_0           ; Ready to set cursor.
    ldi     r24,COL_0
    call    LCDCursorAt         ; Position cursor.
    ldi     ZH,hi8(onText)      ; Text to be displayed.
    ldi     ZL,lo8(onText)
    call    LCDSendZText        ; Print from Flash RAM.
    call    LCDCursorOn         ; Turn cursor on, not blinking.
    call    LCDBlinkOn          ; Now cursor is blinking.
    call    delay1000           ; Delay a bit.
    call    delay1000           ; Delay again.

    ldi     r25,ROW_0           ; Ready to set cursor.
    ldi     r24,COL_0
    call    LCDCursorAt         ; Position cursor.
    ldi     ZH,hi8(homeText)    ; Text to be displayed.
    ldi     ZL,lo8(homeText)
    call    LCDSendZText        ; Print from Flash RAM.
    call    LCDHomeCursor       ; Home the cursor.

loop:
    rjmp    loop


;-------------------------------------------------------------
; Delays for a short period of time. The inner loop delays for
; approximately 65 milliseconds. 
;-------------------------------------------------------------
delay1000:
.equ    DELAY,65000
    ldi     r18,30

dLoop:
    ldi     r25,hi8(DELAY)
    ldi     r24,lo8(DELAY)
    call    delayUSecs
    dec     r18
    brne    dLoop
    ret

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
onText:
    .asciz  "Cursor here->"
    .align 2

homeText:
    .asciz  " <-Cursor Homed."
    .align 2
