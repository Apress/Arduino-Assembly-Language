/*============================================================
 * A sketch to demonstrate the LSL and LSR instructions.
 * Requires 8 Red LEDs for the data bits. The red LEDs are on
 * PORTD (D0 to D7 in Arduino speak).
 *
 * NOTE: If the Arduino has a bootloader instealled, the LEDs
 * on D0 and D1 will light while the bootloader is checking 
 * for any incoming new code. This occurs at power on and 
 * reset. This is not a bug! This "problem" will not be seen
 * if the Arduino has been programmed with an ICSP device.
 * This code differs from the rotate version as the LEDs are
 * never all extinguished by the two loops.
 *
 *
 * Norman Dunbar.
 * 5 August 2024.
 *==========================================================*/

#define __SFR_OFFSET 0
#include <avr/io.h>

.global setup
.global loop

.section .text

;-------------------------------------------------------------
; Setup sets all of PORTD as output and turns all pins off.
; Equivalent to setting D0 through D7 as OUTPUT using pinMode
; then calling digitalWrite(pin, LOW) for each pin. This is
; much smaller, far quicker and easier to type.
;-------------------------------------------------------------
setup:
    ; Set PORTD as all outputs.
    ldi r18,0xFF        ; All PORTD pins are output. (D0--D7)
    out DDRD,r18        ; Set the pinMode.

    ; Turn off all PORTD pins.
    clr r18             ; Zero in R18.
    out PORTD,r18       ; Ensure all PORTD pins are off.
    ret


;-------------------------------------------------------------
; The loop function does everything, and never returns. The C
; bit in the Status Register is rotated into R18, bit zero and
; used to light up an LED. In each pass of the lsl_loop, it is
; rotated into the next higher bit position and the next LED
; is lit up. Repeat until the C flag is set when the 1 bit is
; rotated out of bit 7.
;
; When that occurs, all the LEDs are off. The C flag i then 
; rotated rightwards, back into bit 7 of R18 and again the LED
; is illuminated. The lsr_loop rotates that 1 bit rightwards
; until it drops out of bit 0 and back into the C flag. At 
; this point, we jump back to the loop label and do it all
; over again.
;-------------------------------------------------------------
loop:
    ldi r18,1           ; Make sure R18 has bit 0 set.

;-------------------------------------------------------------
; This loop shifts the 1 bit in the carry flag left through
; all the bits of R18 and thus, through all the LEDs on
; PORTD. It exits when the C flag is set once again when
; the 1 bit shifts out of bit 7 of R18.
;-------------------------------------------------------------
lsl_loop:
    out PORTD,r18       ; Light up one LED berfore shifting.
    lsl r18             ; Shift the 1 bit one place left.
    rcall delay200      ; Call delay(200).
    brcc lsl_loop       ; Do all 8 bits going left.

    ldi r18,0x80        ; Make sure R18 has bit 7 set.
    
;-------------------------------------------------------------
; This loop shifts the 1 bit in the carry flag right through
; all the bits of R18 and thus, through all the LEDs on
; PORTD. It exits when the C flag is set once again when
; the 1 bit shifts out of bit 0 of R18.
;
; NOTE: ROR R18 is NOT a pseudo instruction.
;-------------------------------------------------------------
rsl_loop:
    out PORTD,r18       ; Light up one LED before shifting.
    lsr r18             ; Shift the 1 bit one place right.
    rcall delay200      ; Call delay(200).
    brcc rsl_loop       ; Do all 8 bits going right.

    rjmp loop           ; Let's go round again. 
                        ; Loop never exits back to C++.

;-------------------------------------------------------------
; Subroutine to call delay(200), the value in R22:R25.
; We have to preserve R18 and the SREG otherwise things get a
; bit messy. (They don't work!) The C flag in the SREG is
; corrupted by delay() so testing it on return does not do
; what is expected.
;-------------------------------------------------------------
delay200:
    ; Save working registers from C++ corruption.
    push r18            ; C++ may use these registers.
    in r18,SREG         ; delay() corrupts the SREG flags
    push r18

    ; Initialise parameter registers for delay(200) call.
    ldi r22,200         ; Delay nees a uint32_t in R22:R25
    clr r23             ; with R22 as the lowest byte and
    clr r24             ; R25 the highest.
    clr r25
    call delay          ; Call C++ delay() function.

    ; Restore the working registers on return from C++.
    pop r18
    out SREG,r18        ; Restore my SREG
    pop r18
    ret                 ; Done, return to caller.
