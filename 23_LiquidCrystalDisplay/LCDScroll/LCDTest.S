#include <avr/io.h>
#include <LCDLibrary.h>

.global main

;-------------------------------------------------------------
; A couple of useful constants for row and column positions,
; etc.
;-------------------------------------------------------------
.equ    ROW_0,0
.equ    ROW_1,1
.equ    COL_0,0
.equ    SCROLL,16

;-------------------------------------------------------------
; The demonstration starts here!
;-------------------------------------------------------------

.section    .text


main:
    call    LCDBegin            ; 16x2 LCD, 4 bit mode.

    ldi     r25,ROW_0           ; Ready to set cursor.
    ldi     r24,COL_0
    call    LCDCursorAt         ; Position cursor.
    ldi     ZH,hi8(someText)    ; Text to be displayed.
    ldi     ZL,lo8(someText)
    call    LCDSendZText        ; Print from Flash RAM.
    call    delay350            ; Delay a bit.

scrollLoop:
    ldi     r19,SCROLL

; Note, it is possible to scroll text completely off screen
; and then back on again, adjust SCROLL to see this.
scrollRightLoop:
    call    LCDScrollRight      ; Scroll text right.
    call    delay350            ; Delay a bit.
    dec     r19
    brne    scrollRightLoop

    ldi     r19,SCROLL

; Note, it is possible to scroll text completely off screen
; and then back on again, adjust SCROLL to see this.
scrollLeftLoop:
    call    LCDScrollLeft      ; Scroll text right.
    call    delay350           ; Delay a bit.
    dec     r19
    brne    scrollLeftLoop

    rjmp    scrollLoop


;-------------------------------------------------------------
; Delays for a short period of time. The inner loop delays for
; approximately 65 milliseconds. 
;-------------------------------------------------------------
delay350:
.equ    DELAY,65000
    ldi     r18,5

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
someText:
    .asciz  "<-Scroll->"
    .align 2
