;--------------------------------------------------------------------
; Some binary to ASCII conversion routines. These handle 8, 16
; or 32 bit values. The functions' (ASCII) output is written to the
; data location pointed to by the X register.
;
; Norman Dunbar.
; 24 April 2024.
;--------------------------------------------------------------------

#define __SFR_OFFSET 0
#include <avr/io.h>


.global bin32Convert
.global bin16Convert
.global bin8Convert

;------------------------------------------------------------
; Reserve space for the ASCII buffer.
; 37 bytes is enough for "0x", a 32 bit conversion 
; plus cr/lf and a final zero byte, for C++ purposes.
;------------------------------------------------------------

.section .data 

bin32Buffer:
    .space 2+32+2+1     ; "0b", 32 bits, CR/LF, \0.

.section .text

;------------------------------------------------------------
; bin32Convert does 32 bit conversions. The 32 bit value is
; passed in registers R22:R25 by C++.
;
; On exit, R24:R25 are set to the address of bin32Buffer and
; this is not visible to external code, only here can it be
; seen. Thus, it can't interfere with other variables of the
; same name.
;------------------------------------------------------------
bin32Convert:
    ; Save the function register and call bin32.
    push r18            ; Save the working register.
    ldi r18,3           ; 3 means bin32 is required.      
    rcall doConversion  ; Do the conversion.
    pop r18             ; Restore working register.
    ret

;------------------------------------------------------------
; bin16Convert does 16 bit conversions. The 16 bit value is
; passed in registers R24:R25 by C++. 
;
; On exit, R24:R25 are set to the address of bin32Buffer.
;------------------------------------------------------------
bin16Convert:
    ; Save the function register and call bin16.
    push r18            ; Save the working register.
    ldi r18,2           ; 2 means bin16 is required.      
    rcall doConversion  ; Do the conversion.
    pop r18             ; Restore working register.
    ret    

;------------------------------------------------------------
; bin8Convert does 8 bit conversions. The 8 bit value is
; passed in register R24 by C++.
;
; On exit, R24:R25 are set to the address of bin32Buffer.
;------------------------------------------------------------
bin8Convert:
    ; Save the function register and call bin8.
    push r18            ; Save the working register.
    ldi r18,1           ; 1 means bin8 is required.      
    rcall doConversion  ; Do the conversion.
    pop r18             ; Restore working register.
    ret
    
;------------------------------------------------------------
; This is where the work gets done! We save the X register
; plus those that C++ requires, only SREG in this case. The
; X register is then pointed at our buffer and this address
; is saved, as the function return value, on the stack. The
; required conversion function is called and the various 
; registers and stack are restored before returning to the 
; caller.
;
; This code saved a lot of repetition by using R18 as a flag
; for the function we wanted to call.
;------------------------------------------------------------
doConversion:
    ; Preserve the X register as we must!
    push r26
    push r27

    ; And those that C++ needs. Just the SREG.
    in r26,SREG
    push r26

    ; Initialise the X register.
    ldi r26,lo8(bin32Buffer)
    ldi r27,hi8(bin32Buffer)

    ; Save the X register for return to C++.
    push r26
    push r27

    ; Perform the conversion and drop in below to terminate.
    ; We determine the function to call by the value in R18.
    ; It is assumed to be 1, 2 or 3 for bin8, bin16 or bin32
    ; however, although unlikely, any higher values will be
    ; assumed to be 3 for bin32.
tryBin8:
    dec r18             ; 1 = bin8, 2 = bin16, 3 = bin32
    brne tryBin16       ; Must have been 2 or 3.
    rcall bin8          ; Definitely was 1 for bin8.
    rjmp binExit

tryBin16:
    dec r18             ; 2 = bin16, 3 = bin32
    brne tryBin32       ; Must have been 3.
    rcall bin16         ; Definitely 2 for bin16.
    rjmp binExit

tryBin32:
    rcall bin32         ; Must have been 3, or higher!!!

;------------------------------------------------------------
; Common code to all three conversion routines. Adds a zero 
; byte to the buffer and then restores the X and SREG 
; registers. Initialises R24:R25 with the address of the 
; bin32Buffer for return to C++. 
;------------------------------------------------------------
binExit:
    ; Terminate the conversion buffer.
    clr r18             ; R18 = zero.
    st X+,r18           ; Store zero byte at X.

    ; Pointer to the result for return to C++.
    pop r25             ; R24:R25 return the buffer address.
    pop r24

    ; Restore SREG.
    pop r26
    out SREG,r26

    ; And restore the X register.
    pop r27 
    pop r26
    ret
