;==========================================================
; The code in this file makes up the pure assembly eight
; bit division routines. 
;
; Udivide is an 8x8 unsigned division.
; Sdivide is an 8x8 signed division.
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

.global udivide
.global sdivide

;----------------------------------------------------------
; Udivide. Unsigned eight bit division.
;----------------------------------------------------------
udivide:
    mov r1,r24          ; Copy to remainder.
    clr r0              ; Result.
    
subLoop:
    inc r0              ; Increment result.
    sub r1,r22          ; Subtract divisor.
    brcc subLoop        ; Not finished yet.
    
tooFar:
    ; We went negative.
    add r1,r22          ; Back up one.
    dec r0              ; We are one 'inc r0' too many.
    ret



;----------------------------------------------------------
; Sdivide. Signed eight bit division.
;----------------------------------------------------------
sdivide:
    ; Set the result flag.
    ldi r26,1			; Assume positive result.
    
testDividend:
    ; Is the dividend negative?
    tst r24				; Test dividend.
    brpl testDivisor	; It's positive, so skip.
    neg r26				; Negate result flag.
    neg r24				; Negate dividend.

testDivisor:
    ; Is the dividend negative?
    tst r22				; Test divisor.
    brpl doDivision     ; It's positive, so skip.
    neg r26				; Negate result flag.
    neg r22				; Negate divisor.

doDivision:
    ; Unsigned division, result in R0, remainder in R1.
    rcall udivide		; Do unsigned division.

testResult:
    ; Do we need to adjust the result?
    sbrs r26,7			; Test sign of result flag.
    rjmp gotResult      ; Skip if positive result expected.
    neg r0				; Negate result.
    neg r1				; Negate remainder.

gotResult:
    ; Finished.    
    ret