#include <LCDLibrary.h>

.global main

;-------------------------------------------------------------
; A couple of useful constants for row and column positions.
;-------------------------------------------------------------
.equ    ROW_0,0
.equ    ROW_1,1
.equ    COL_0,0
.equ    COL_10,10

;-------------------------------------------------------------
; The demonstration starts here!
;-------------------------------------------------------------

.section    .text


main:
    call    LCDBegin            ; 16x2 LCD, 4 bit mode.

loop:
    call    LCDClearDisplay     ; Clear display for new loop.
    ldi     r25,ROW_0           ; Set cursor to leftmost 
    ldi     r24,COL_0           ; position.
    call    LCDCursorAt         ; Position cursor.
    call    LCDNoAutoScroll     ; Turn off autoscrolling.
    rcall   digitLoop           ; Write some digits.
    

    ldi     r25,ROW_1           ; Set cursor to Rightmost 
    ldi     r24,15              ; position.
    call    LCDCursorAt         ; Position cursor.
    call    LCDAutoScroll       ; Turn off autoscrolling.
    rcall   digitLoop           ; Write some digits.

    rjmp    loop


;-------------------------------------------------------------
; Display the digits 0 to 9 at the current cursor position. In
; NOAUTOSCROLL mode, the display remains fixed and the digits
; arrive at the next character position.
; In AUTOSCROLL, the *entire* display scrolls left and each
; digit appears on the far right character position.
;-------------------------------------------------------------
digitLoop:
    ldi     r19,'0'             ; Start from zero.

innerLoop:
    mov     r24,r19             ; Copy to r24 for LCDSend.
    call    LCDSend             ; Send to LCD.
    rcall   delay1000           ; Wait a bit.
    inc     r19                 ; Next digit.
    cpi     r19,'9'+1           ; Done yet?
    brne    innerLoop           ; Nope.
    ret


;-------------------------------------------------------------
; Delays for a short period of time. The inner loop delays for
; approximately 6.5 milliseconds. 
;-------------------------------------------------------------
delay1000:
.equ    DELAY,65000
    ldi     r18,50

dLoop:
    ldi     r25,hi8(DELAY)
    ldi     r24,lo8(DELAY)
    call    delayUSecs
    dec     r18
    brne    dLoop
    ret
