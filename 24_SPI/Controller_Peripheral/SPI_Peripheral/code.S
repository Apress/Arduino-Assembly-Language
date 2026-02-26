#define __SFR_OFFSET 0
#include <avr/io.h>

.global main
.global SPI_STC_vect

;-------------------------------------------------------------
; SPI Pins on the Arduino.
;-------------------------------------------------------------
.equ DDB_SCK,DDB5
.equ DDB_CIPO,DDB4
.equ DDB_COPI,DDB3
.equ DDB_SS,DDB2

;-------------------------------------------------------------
; Constant(s).
;-------------------------------------------------------------
; SPCR = 0xEF, this gives an SPI configuration of:
;
;   SPIE -> Interrupt enabled.              Bit 7.
;   SPE  -> SPI enabled.                    Bit 6.
;   DORD -> Shift MSB first.                Bit 5.
;   MSTR -> SPI in peripheral mode. (0)     Bit 4.
;   CPOL -> Polarity = 0.                   Bit 3.
;   CPHA -> Phase = 0.                      Bit 2.
;   SPR1 -> F_CPU / 128 -> 125 KHz Clock.   Bit 1.
;   SPR0 -> F_CPU / 128 -> 125 KHz Clock.   Bit 0.
;
.equ SPIsettingsMSB,(1<<SPE)|(1<<DORD)|(1<<SPR1)|(1<<SPR0)|(1<<SPIE)
.equ SPIsettingsLSB,(1<<SPE)|(1<<SPR1)|(1<<SPR0)|(1<<SPIE)

;-------------------------------------------------------------
; DDRD = 0xFF, which makes all PD pins outputs.
; DDRB = 0x10, which gives the following configuration:
;
;   DDB5 = DDB_SCK  -> SPI Clock pin. (Input)
;   DDB4 = DDB_CIPO -> SPI CIPO/MISO pin (Output)
;   DDB3 = DDB_COPI -> SPI COPI/MOSI pin. (Input)
;   DDB2 = DDB_SS   -> SPI_SS pin. (Input)
;
.equ outputPinsPD,0xFF
.equ outputPinsPB,(1 << DDB_CIPO)

.section .text

;-------------------------------------------------------------
; The code starts here.
;-------------------------------------------------------------

;-------------------------------------------------------------
; Setup the output pins for the LEDs on PORTD, then set up the
; SPI communications. We will be using peripheral mode with
; data shifted in from the controller MSB first, 
; clock is F_CPU / 128 = 125 KHz, SPI interrupt is enabled,
; phase and polarity are 0:0 but can be anything in this case.
;
; COPI/MOSI, SCK and SS need to be INPUT pins as per the data 
; sheet, and will automatically be configured as such by SPI
; when we are connected to the bus by the controller. CIPO is
; required to be configured as an output manually.
;-------------------------------------------------------------
main:
setupPins:
    ldi     r18,outputPinsPB    ; Setup output pins for SPI.
    out     DDRB,r18            ; Configure SPI outputs.

    ldi     r18,outputPinsPD    ; PORTD = all output pins.
    out     DDRD,r18            ; Configure PORTD pins.

;-------------------------------------------------------------
; Use SPIsettingsMSB if you wish. Depends on which side
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

loop:
    rjmp    loop                ; Keep on looping.


;-------------------------------------------------------------
; This interrupt will fire every time a byte of data has been
; received from the controller. Copy that byte to PORTD to
; light up the LEDs. We must also disable sleep mode too.
;-------------------------------------------------------------
SPI_STC_vect:
    push    r18                 ; Must save working  registers.
    in      r18,SREG            ; Read SREG in order to save it.
    push    r18                 ; And save.

    ; Read the data byte from the controller.
    in      r18,SPDR            ; Read "received" data.
    out     PORTD,r18           ; Light up the LEDs.

    pop     r18                 ; Must restore SREG.
    out     SREG,r18            ; Restore it.
    pop     r18                 ; Must restore working registers.
    reti                        ; Exit from interrupt handler.
