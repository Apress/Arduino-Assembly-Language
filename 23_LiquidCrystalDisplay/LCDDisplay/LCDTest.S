#include <LCDLibrary.h>

.global main

;-------------------------------------------------------------
; A couple of useful constants for row and column positions.
;-------------------------------------------------------------
.equ    ROW_0,0
.equ    ROW_1,1
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
    ldi     ZH,hi8(OffText)     ; Text to be displayed.
    ldi     ZL,lo8(OffText)
    call    LCDSendZText        ; Print from Flash RAM.
    call    delay1000           ; Delay.
    call    LCDDisplayOff       ; Turn LCD off.

    call    delay1000           ; Delay again.
    call    LCDDisplayOn        ; Turn LCD back on.

    ldi     r25,ROW_0           ; Ready to set cursor.
    ldi     r24,COL_0
    call    LCDCursorAt         ; Position cursor.
    ldi     ZH,hi8(OnText)      ; Text to be displayed.
    ldi     ZL,lo8(OnText)
    call    LCDSendZText        ; Print from Flash RAM.


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
OffText:
    .asciz  "Display off soon"
    .align 2

OnText:
    .asciz  "Display on again"
    .align 2
