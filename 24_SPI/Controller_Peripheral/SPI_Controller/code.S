#define __SFR_OFFSET 0
#include <avr/io.h>

.global main
.global SPI_STC_vect

;-------------------------------------------------------------
; SPI Pins on the Arduino.
;-------------------------------------------------------------
.equ DDB_SCK,DDB5
.equ DDB_COPI,DDB3
.equ DDB_SS,DDB2

;-------------------------------------------------------------
; Constant(s).
;-------------------------------------------------------------
; SPCR = 0xFF, this gives an SPI configuration of:
;
;   SPIE -> Interrupt enabled.              Bit 7.
;   SPE  -> SPI enabled.                    Bit 6.
;   DORD -> Shift MSB first.                Bit 5.
;   MSTR -> SPI in Controller mode.         Bit 4.
;   CPOL -> Polarity = 0.                   Bit 3.
;   CPHA -> Phase = 0.                      Bit 2.
;   SPR1 -> F_CPU / 128 -> 125 KHz Clock.   Bit 1.
;   SPR0 -> F_CPU / 128 -> 125 KHz Clock.   Bit 0.
;
.equ SPIsettingsMSB,(1<<SPIE)|(1<<SPE)|(1<<DORD)|(1<<SPR1)|(1<<SPR0)|(1<<MSTR)
.equ SPIsettingsLSB,(1<<SPIE)|(1<<SPE)|(1<<SPR1)|(1<<SPR0)|(1<<MSTR)

;-------------------------------------------------------------
; DDRB = 0x2F, which gives the following output pins:
;
;   DDB5 = DDB_SCK  -> SPI Clock pin.       D13
;   DDB3 = DDB_COPI -> SPI COPI/MOSI pin.   D11
;   DDB2 = DDB_SS   -> SPI_SS pin.          D10
;
.equ outputPins,(1<<DDB_SCK)|(1<<DDB_COPI)|(1<<DDB_SS)

.section .text

;-------------------------------------------------------------
; The code starts here.
;-------------------------------------------------------------


;-------------------------------------------------------------
; Set up the SPI communications with the peripheral. We will 
; be using controller mode with data shifted out MSB first, 
; clock is F_CPU / 128 = 125 KHz, SPI interrupt is enabled,
; phase and polarity are 0:0 but can be anything we like.
;
; COPI/MOSI, SCK and SS need to be OUTPUT pins as per the data 
; sheet. The SS pin is connected to the peripheral Arduino's
; SS pin, so will act as the CS pin for the peripheral.
;-------------------------------------------------------------
main:
setupPins:
    ldi     r18,outputPins      ; Setup output pins for SPI.
    out     DDRB,r18            ; Configure pins as outputs.

    ldi     r18,(1 << DDB_SS)   ; Pull up the peripheral's SS.
    out     PORTB,r18           ; Disable peripheral.

;-------------------------------------------------------------
; Use SPIsettingsLSB if you wish. Depends on which side
; you view the 8 LEDs. View from the LED side of the
; breadboard = SPIsettingsLSB; view from the other side
; and it's SPIsettingsMSB. This way, the LSB is always
; on the right, just like in a register.
;-------------------------------------------------------------
setupSPI:
    cli                         ; We dont want interrupts.
    ldi     r18,SPIsettingsMSB  ; SPI config settings.
    out     SPCR,r18
    in      r18,SPSR            ; Clear SPI interrupt flag.
    in      r18,SPDR            ; Clear data register.
    sei                         ; Interrupts are fine now.

    clr     r19                 ; Data values for SPI.
    clr     r1                  ; Rquired by delayUSecs.

loop:
    in      r18,PORTB
    cbr     r18,(1 << DDB_SS)   ; Select the peripheral.
    out     PORTB,r18
    out     SPDR,r19            ; Send the value to the LEDS.
    rcall   delay100            ; Short delay between values.
    inc     r19                 ; Next value.
    rjmp    loop                ; Keep on looping.


delay100:
.equ    DELAY,50000             ; 50 milliseconds...
    ldi     r20,2               ; ... times two.

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


;-------------------------------------------------------------
; This interrupt will fire every time a byte of data has been
; written to the SN74HC595 *and* a byte has been received from
; it. Technically, no data are actually transmitted from the 
; peripheral board, so the received data are ignored.
;-------------------------------------------------------------
SPI_STC_vect:
    push    r18                 ; Must save working  registers.
    in      r18,SREG            ; Read SREG in order to save it.
    push    r18                 ; And save.

    ; Read and ignore data from peripheral.
    in      r18,SPDR            ; Read "received" data.

    ; Disable peripheral from SPI. This synchronises the device.
    in      r18,PORTB           ; Read PORTB.
    sbr     r18,(1 << DDB_SS)   ; Will Disable the peripheral.
    out     PORTB,r18           ; Disable.

    pop     r18                 ; Must restore SREG.
    out     SREG,r18            ; Restore it.
    pop     r18                 ; Must restore working registers.
    reti                        ; Exit from interrupt handler.
