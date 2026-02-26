;==========================================================
; The code in this file makes up the pure assembly eight
; bit division routines. 
;
; Udivide is an 16x16 unsigned division.
; Sdivide is an 16x16 signed division.
;
; Both functions divide the value in R24 by the value in 
; R22 and return the result in R0 and the remainder in R1.
;
; These functions accept two 8 bit parameters in registers
; R24 and R22 and these registers are used as they are the
; ones that would be used by C++ to pass the parameters 
; over. This reduces the work required if calling the code
; from C++.
;
; But, why would you call this from C++? C++ can do the 
; division for you! ;o)
;
; Norman Dunbar.
; 27 January 2024.
;==========================================================

.global udivide16
.global sdivide16

;----------------------------------------------------------
; Udivide16. Unsigned 16 bit division.
;
; Dividend in R24:R25.
; Divisor in R22:R23.
; Result in R24:R25.
; Preserves R22:R23.
; Trashes R26:R27.
;----------------------------------------------------------
udivide16:
    mov r26,r24         ; Copy to remainder.
    mov r27,r25
    clr r24				; Clear result.
    clr r25
    
subLoop:
    adiw r24,1          ; Increment result.
    sub r26,r22         ; Subtract divisor.
    sbc r27,r23
    brcc subLoop        ; Not finished yet.
    
tooFar:
    ; We went negative.
    add r26,r22         ; Back up one.
    adc r27,r23
    sbiw r24,1          ; We are one subtraction too many.
    ret



;----------------------------------------------------------
; Sdivide16. Signed 16 bit division.
;
; Dividend in R24:R25.
; Divisor in R22:R23.
; Result in R24:R25.
; Trashes R26:R27, R28.
;----------------------------------------------------------
sdivide16:
    ; Set the result flag.
    ldi r28,1			; Assume positive result.
    
testDividend:
    ; Is the dividend negative?
    tst r25				; Test dividend high byte.
    brpl testDivisor	; It's positive, so skip.
    com r24				; Invert dividend.
    com r25
    adiw r24,1			; Negated.
    neg r28             ; And flagged negative.

testDivisor:
    ; Is the dividend negative?
    tst r23				; Test divisor high byte.
    brpl doDivision     ; It's positive, so skip.
    com r22				; Invert divisor.
    com r23
    subi r22,lo8(-1)    ; Negate divisor.
    sbci r23,hi8(-1)
    neg r28             ; And flagged negative.


doDivision:
    ; Unsigned division, result in R0, remainder in R1.
    rcall udivide16		; Do unsigned division.

testResult:
    ; Do we need to adjust the result?
    sbrs r28,7			; Test sign of result flag.
    rjmp gotResult      ; Skip if positive result expected.
    com r24				; Invert result.
    com r25
    adiw r24,1          ; Negate result.
    com r26				; Invert result.
    com r27
    adiw r26,1          ; Negate remainder.

gotResult:
    ; Finished.    
    ret
