#include <LCDLibrary.h>

.global main

;-------------------------------------------------------------
; A couple of useful constants for row and column positions.
;-------------------------------------------------------------
.equ    ROW_0,0
.equ    ROW_1,1
.equ    COL_0,0
.equ    COL_4,4

;-------------------------------------------------------------
; The demonstration starts here!
;-------------------------------------------------------------

.section    .text


main:
    call    LCDBegin            ; 16x2 LCD, 4 bit mode.

    call    LCDRightToLeft      ; Set text input direction.
    ldi     r25,ROW_0           ; Set cursor to rightmost 
    ldi     r24,COL_4           ; position to start printing.
    call    LCDCursorAt         ; Position cursor.
    ldi     ZH,hi8(rightText)   ; Text to be displayed.
    ldi     ZL,lo8(rightText)
    call    LCDSendZText        ; Print "thgiR"!

    call    LCDLeftToRight      ; Set text input direction.
    ldi     r25,ROW_1           ; Set cursor to leftmost
    ldi     r24,COL_0           ; position to start printing.
    call    LCDCursorAt         ; Position cursor.
    ldi     ZH,hi8(leftText)    ; Text to be displayed.
    ldi     ZL,lo8(leftText)
    call    LCDSendZText        ; Print "Left""

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
rightText:
    .asciz  "Right"
    .align 2

leftText:
    .asciz  "Left"
    .align 2
