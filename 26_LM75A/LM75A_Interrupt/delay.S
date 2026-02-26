.global shortDelay
.global longDelay

.section .text

;--------------------------------------------------------------
; Delay for 10 milliseconds before starting another scan.
;
; Corrupts R24, R25 and R20.
;--------------------------------------------------------------
shortDelay:
.equ    DELAY,10000
    ldi     r20,1               ; 10 milliseconds.
    rjmp    dLoop


;--------------------------------------------------------------
; Delay for 2,500 milliseconds before starting another scan.
;
; Corrupts R24, R25 and R20.
;--------------------------------------------------------------
longDelay:
    ldi     r20,250               ; 2,500 milliseconds.

dLoop:
    ldi     r25,hi8(DELAY)      ; Load up the delay period.
    ldi     r24,lo8(DELAY)
    rcall   delayUSecs          ; Delay for 50 milliseconds
    dec     r20                 ; Decrease the counter.
    brne    dLoop               ; More to do?
    ret

;-------------------------------------------------------------
; Delay for R25:R24 microseconds. Only accurate at 16 MHz.
; R1 must be cleared before calling here.
;-------------------------------------------------------------
delayUSecs:
    cpi     r24,2               ; Less than 2 uSecs requested?
    cpc     r25,r1
    brcs    delayExit           ; Yes, quick exit. (0.75 uSec)

    sbiw    r24,1               ; Minus 1 uSec call overhead.

delayHere:
    ; The loop takes 16 clocks on each pass, except the final
    ; one, which only takes 15.
    sbiw    r24,1               ; 2 clocks.
    push    r24                 ; 2 clocks.
    push    r24                 ; 2 clocks.
    push    r24                 ; 2 clocks.
    pop     r24                 ; 2 clocks.
    pop     r24                 ; 2 clocks.
    pop     r24                 ; 2 clocks.
    brne    delayHere           ; 2 clocks, final pass, 1 clock.

delayExit:
    ret                         ; 4 Clocks.

