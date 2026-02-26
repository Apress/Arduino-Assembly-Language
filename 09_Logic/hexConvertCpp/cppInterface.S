;--------------------------------------------------------------------
; Some binary to hexadecimal conversion routines. These handle 8, 16
; or 32 bit values. The hexadecimal (ASCII) output is written to the
; data location pointed to by the X register.
;
; Norman Dunbar.
; 24 April 2024.
;--------------------------------------------------------------------

#define __SFR_OFFSET 0
#include <avr/io.h>


.global hex32Convert
.global hex16Convert
.global hex8Convert

;------------------------------------------------------------
; Reserve space for the ASCII buffer.
; 13 bytes is enough for "0x", a 32 bit conversion 
; plus cr/lf and a final zero byte, for C++ purposes.
;------------------------------------------------------------

.section .data 

hex32Buffer:
    .space 12+1        ; Eg 0xABCD0123 cr/lf plus terminator.

.section .text

;------------------------------------------------------------
; Hex32Convert does 32 bit convesions. The 32 bit value is
; passed in registers R22:R25 by C++. This is useful, as it
; is where we expect it to be.
; On exit, R24:R25 are set to the address of hex32Buffer and
; this is not visible to external code, only here can it be
; seen. Thus, it can't interfere with other variables of the
; same name.
;------------------------------------------------------------
hex32Convert:
    ; Save the function register and call hex32.
    push r18            ; Save the working register.
    ldi r18,3           ; 3 means hex32 is required.      
    rcall doConversion  ; Do the conversion.
    pop r18             ; Restore working register.
    ret

;------------------------------------------------------------
; Hex16Convert does 16 bit convesions. The 16 bit value is
; passed in registers R24:R25 by C++. This is useful, as it
; is where we expect it to be.
; On exit, R24:R25 are set to the address of hex32Buffer.
;------------------------------------------------------------
hex16Convert:
    ; Save the function register and call hex16.
    push r18            ; Save the working register.
    ldi r18,2           ; 2 means hex16 is required.      
    rcall doConversion  ; Do the conversion.
    pop r18             ; Restore working register.
    ret    

;------------------------------------------------------------
; Hex8Convert does 8 bit convesions. The 8 bit value is
; passed in register R24 by C++. This is useful, as it
; is where we expect it to be.
; On exit, R24:R25 are set to the address of hex32Buffer.
;------------------------------------------------------------
hex8Convert:
    ; Save the function register and call hex8.
    push r18            ; Save the working register.
    ldi r18,1           ; 1 means hex8 is required.      
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
    push XL
    push XH

    ; And those that C++ needs. Just the SREG.
    in XL,SREG
    push XL

    ; Initialise the X register.
    ldi XL,lo8(hex32Buffer)
    ldi XH,hi8(hex32Buffer)

    ; Save the X register for return to C++.
    push XL
    push XH

    ; Perform the conversion and drop in below to terminate.
    ; We determine the function to call by the value in R18.
    ; It is assumed to be 1, 2 or 3 for hex8, hex16 or hex32
    ; however, although unlikely, any higher values will be
    ; assumed to be 3 for hex32.
tryHex8:
    dec r18             ; 1 = hex8, 2 = hex16, 3 = hex32
    brne tryHex16       ; Must have been 2 or 3.
    rcall hex8          ; Definitely was 1 for hex8.
    rjmp hexExit

tryHex16:
    dec r18             ; 2 = hex16, 3 = hex32
    brne tryHex32       ; Must have been 3.
    rcall hex16         ; Definitely 2 for hex16.
    rjmp hexExit

tryHex32:
    rcall hex32         ; Must have been 3, or higher!!!

;------------------------------------------------------------
; Common code to all three conversion routines. Adds a zero 
; byte to the buffer and then restores the X and SREG 
; registers. Initialises R24:R25 with the address of the 
; hex32Buffer for return to C++. 
;------------------------------------------------------------
hexExit:
    ; Terminate the conversion buffer.
    clr r18             ; R18 = zero.
    st X+,r18           ; Store zero byte at X.

    ; Pointer to the result for return to C++.
    pop r25             ; R24:R25 return the buffer address.
    pop r24

    ; Restore SREG.
    pop XL
    out SREG,XL

    ; And restore the X register.
    pop XH 
    pop XL
    ret
