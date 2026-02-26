#define __SFR_OFFSET 0
#include <avr/io.h>

.global setup
.global toggle
.global getFlashCount

//------------------------------------------------------------
// getFlashCount needs a variable in the data section. This is
// incremented on every call to getFlashCount. The data size
// is byte/uint8_t but will be extended to uint16_t by C++.
//------------------------------------------------------------
.section .data

flashCntr:
    .byte 0             ; Reserve one byte. It DOESN'T get
                        ; initialised to zero! The BSS zeroing
                        ; code skips over this byte.

.section .text

//------------------------------------------------------------
// Setup defines D13 as an OUTPUT pin. It also initialises
// the flashCntr variable in SRAM. The .byte 0 for flashCntr
// SHOULD initialise it, and appears to do so in the ELF file
// but flashCntr is 0xAA (170) unless explicitly initialised
// here.
//
// Try commenting out the clr and sts instructions below if 
// you want to see the difference.
//------------------------------------------------------------
setup:
    sbi DDRB,DDB5       ; D13 is OUTPUT.
    clr r18             ; Use R18 to initialise the counter.
    sts flashCntr,r18   ; Initialise flashCntr to zero.
    ret


//------------------------------------------------------------
// Toggle blinks the LED and calls delay()
//
// R24 = Toggle count.
// R25 = Undefined!
// R20:R23 = Flash delay. R20 = low byte.
//------------------------------------------------------------
toggle:
    clr r25             ; We need this register to be zero.
    movw r30,r24        ; Copy R24:R25 blink count to R30:R31.

                        ; WARNING: avr-gas syntax!
                        ; movw r31:r30,r25:r24 usually.

    //--------------------------------------------------------
    // Now double the blink counter to toggle LED correctly.
    // Remember, it takes two toggles to blink the LED.
    //--------------------------------------------------------
    add r30,r30         ; Sets or clears the C flag correctly.
    adc r31,r1          ; Ensure carry is included. R1 = 0.

    //--------------------------------------------------------
    // Copy the delay time into R22:R25 from R20:R23.
    //--------------------------------------------------------
    movw r24,r22        ; R22:R23->R24:R25 = upper word.
    movw r22,r20        ; R20:R21->R22:R23 = lower word.

togLoop:
    //--------------------------------------------------------
    // Preserve the counter registers.
    //--------------------------------------------------------
    push r31            ; Must save any used R18:R27.
    push r30            ; and R30:R31 registers when.

    //--------------------------------------------------------
    // Toggle the LED, and delay.
    //--------------------------------------------------------
    sbi PINB,PINB5      ; Toggle LED on D13/PB5.
    push r25            ; The delay() function trashes the 
    push r24            ; delay count registers so we must
    push r23            ; keep them safe over the delay()
    push r22            ; call.
    call delay          ; Call delay(), back in C++.
    pop r22             ; And restore all those registers.
    pop r23
    pop r24
    pop r25

    //--------------------------------------------------------
    // Restore the counter registers.
    //--------------------------------------------------------
    pop r30
    pop r31

    //--------------------------------------------------------
    // Are we done yet?
    //--------------------------------------------------------
    sbiw r30,1          ; Reduce toggle counter.

                        ; WARNING: avr-gas syntax!
                        ; sbiw r31:r30,1 usually.

    brne togLoop        ; And do all requested blinks.
    ret


//------------------------------------------------------------
// getFlashCount returns the next number in the sequence 1..8
// as the number of flashes the LED will blink.
// Return the value in R24:R25. FlashCntr has been set to zero
// in setup().
//------------------------------------------------------------
getFlashCount:
    clr r25             ; Make sure R25 is zero.
    lds r24,flashCntr
    andi r24,0x07       ; Limit values to 0..7.
    inc r24             ; Values now 1..8. Zero not allowed!
    sts flashCntr,r24   ; Save current value.
    ret
