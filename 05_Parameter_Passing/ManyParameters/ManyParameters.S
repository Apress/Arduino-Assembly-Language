;==========================================================
; ManyParameters demonstrates how the avr-gcc compiler
; system passes parameters on the stack, when there are too
; many to fit in registers.
;
; This function takes 8 uint32_t parameters and only 4 fit
; in registers, the other 4 are on the stack.
;
; The avr-gcc docs mention that the Y register is set up as
; a stack frame pointer and can be used to access the
; stacked parameters --- not exactly true! The Y register
; is not set up, at least in AVR code, as a stack frame 
; pointer --- unless we do it ourselves in code.
;
; Norman Dunbar.
; 20 February 2024.
;==========================================================

#define __SFR_OFFSET 0
#include <avr/io.h>

.global manyParameters

;----------------------------------------------------------
; If we assume we are called with 1,2,3,4,5,6,7,8 as the
; parameters, then:
;
; R22:R23:R24:R25 = 1:0:0:0.
; R18:R19:R20:R21 = 2:0:0:0.
; R14:R15:R16:R17 = 3:0:0:0.
; R10:R11:R12:R13 = 4:0:0:0.
;
; The C++ code pushes the "missing" variables, 5, 6, 7, 8 
; onto the stack. They are pushed on the stack in MSB->LSB 
; order. The value 5, for example, is on the stack as:
;
; 5,0,0,0
;
; The 5 is at the lowest address and is the first available
; to "pop" off the stack.
;
manyParameters:
     push r28           ; Save Y register.
     push r29
     in r28,SPL         ; Y = SP
     in r29,SPH

    ; The stack at this point:

    ; 0008 <---- Y+17, Y+18, Y+19, Y+20
    ; 0007 <---- Y+13, Y+14, Y+15, Y+16
    ; 0006 <---- Y+9, Y+10, Y+11, Y+12
    ; 0005 <---- Y+5, Y+6, Y+7, Y+8
    ; RR <------ Y+3, Y+4
    ; R29 <----- Y+2
    ; R28 <----- Y+1
    ; ? <------- SP & Y point here.

     adiw r28,5         ; Y = parameters

addRegisters:
    ; Here we add the parameters passed in 
    ; registers to the registers used to return
    ; the 32 bit result.
    add r22,r18         ; Adding a + b
    adc r23,r19
    adc r24,r20
    adc r25,r21

    add r22,r14         ; Adding (a + b) + c
    adc r23,r15
    adc r24,r16
    adc r25,r17

    add r22,r10         ; Adding (a + b + c) + d
    adc r23,r11
    adc r24,r12
    adc r25,r13

addStackParams:
    ; Here we add the parameters passed on 
    ; the stack to the registers used to return
    ; the 32 bit result. We use R18 here.

    ; There are 4 parameters to add.
    ldi r19,4           ; Loop counter.

addLoop:
    ld r18,Y+           ; Adding next parameter.
    add r22,r18         ; LSB
    ld r18,Y+
    adc r23,r18
    ld r18,Y+
    adc r24,r18
    ld r18,Y+
    adc r25,r18         ; MSB

    dec r19             ; Reduce loop counter.
    brne addLoop        ; Add 4 parameters in total.

    pop r29             ; Restore Y register.
    pop r28
    ret
