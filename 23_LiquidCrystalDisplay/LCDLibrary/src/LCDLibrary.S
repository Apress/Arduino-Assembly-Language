;=============================================================
; An attempt at writing an LCD library in Assembly for the
; ATmega328P. This version is only for 4 bit mode, less wires!
;
; ASSUMPTIONS:
;
; PORTD: PD5--PD2 are the data lines, PD2 is the lowest bit.
; Arduino pins are D5--D2 to correspond.
;
; PORTB: PB4 = RS. PB3 = E. PB2 = R/W.
; Arduino pins are D12 = RS, D11 = E, D10 = R/W
;
; The R/W pin, by default D10/PB2, is not used. Pin 5 of the
; LCD should be tied to GND.
;
; Oh yes, because this is a library, I'll have to use those
; horrible macros I suppose! :o(
;
;
; Norman Dunbar.
; 3 June 2025.
;=============================================================

#include <avr/io.h>
#include "LCDLibrary.h"

.global LCDBegin
.global LCDDisplayOn
.global LCDDisplayOff
.global LCDCursorOn
.global LCDCursorOff
.global LCDCursorAt
.global LCDBlinkOn
.global LCDBlinkOff
.global LCDScrollLeft
.global LCDScrollRight
.global LCDLeftToRight
.global LCDRightToLeft
.global LCDNoAutoScroll
.global LCDAutoScroll
.global LCDClearDisplay
.global LCDHomeCursor
.global LCDSend
.global LCDSendZText
.global LCDSendXText
.global delayUSecs



;-------------------------------------------------------------
; Equates for the various LCD pins & modes in use.
;-------------------------------------------------------------
; Control Pins.
;-------------------------------------------------------------
.equ RS,PB4
.equ E,PB3
.equ RW,PB2

;-------------------------------------------------------------
; Data Pins.
;-------------------------------------------------------------
.equ DB7,PD2
.equ DB6,PD3
.equ DB5,PD4
.equ DB4,PD5

;-------------------------------------------------------------
; Data and Control ports.
;-------------------------------------------------------------
.equ DATAPort,PORTD
.equ DATAConfigPort,DDRD
.equ CTRLPort,PORTB
.equ CTRLConfigPort,DDRB

;-------------------------------------------------------------
; Various modes etc.
;-------------------------------------------------------------
.equ displayMode,LCD_4BITMODE | LCD_1LINE | LCD_5x8DOTS
.equ displayControl,LCD_DISPLAYON | LCD_CURSOROFF | LCD_BLINKOFF
.equ entryMode,LCD_ENTRYLEFT | LCD_ENTRYSHIFTDECREMENT


.section .text
  
        
;=============================================================
; User level stuff here.
;=============================================================

;-------------------------------------------------------------
; LCDBegin.
;
; Defines output pins, and initialises the LCD to 16 columns,
; 2 rows, with a 5 by 8 dot pattern and 4 bit mode.
;
; See Hitachi HD44780 data sheet, Figure 24 - 4 bit interface
; on page 46 for details on the sequence of commands required
; for 4 bit mode.
;
; All registers preserved.
;-------------------------------------------------------------
LCDBegin:
    push r18
    push r24
    push r25

    ; Set data and control pins as outputs.
    ldi r18,0b00111100          ; PD5--PD2 are output.
    out _SFR_IO_ADDR(DATAConfigPort),r18

    ldi r18,(1 << RS) | (1 << RW) | (1 << E) ; PB4--PB2 also.
    out _SFR_IO_ADDR(CTRLConfigPort),r18

    ; Wait more than 40 mS after power reaches 2.7V.
    ldi r25,hi8(42500)
    ldi r24,lo8(42500)
    call delayUSecs

    ; Set control pins low.
    in r18,_SFR_IO_ADDR(CTRLPort)
    cbr r18,(1 << RS) | (1 << E) | (1 << RW) ; RS, E and RW are low.
    out _SFR_IO_ADDR(CTRLPort),r18  ; Set all control pins low.

    ; Setting 4 bit  mode is strange!
    ldi r24,0x03
    rcall LCDWrite4             ; Write 0x03 first.
    ldi r25,hi8(4500)           
    ldi r24,lo8(4500)
    call delayUSecs             ; Wait more than 4.1 mS

    ldi r24,0x03
    rcall LCDWrite4             ; Write 0x03 again.
    ldi r25,hi8(150)
    ldi r24,lo8(150)
    call delayUSecs             ; Wait more than 100 uS.

    ldi r24,0x03
    rcall LCDWrite4             ; Write 0x03 a third time.
                                ; With no delay.

    ldi r24,0x02                ; Send Function Set only.
    rcall LCDWrite4             ; Do it.

    ; Set lines and columns
    ldi r24,LCD_FUNCTIONSET | displayMode | LCD_2LINE
    rcall LCDCommand            ; Set display mode.

    ; Turn display on, cursor off, no blinking.
    rcall LCDDisplayOn

    ; Clear initial garbage from display.
    rcall LCDClearDisplay

    ; Set LeftToRight text direction.
    rcall LCDLeftToRight

    pop r25
    pop r24
    pop r18
    ret

;-------------------------------------------------------------
; LCDDisplayOn.
;
; Turns on the display, turns off the cursor and blinking.
; All registers preserved.
;-------------------------------------------------------------
LCDDisplayOn:
    push r24
    ldi r24,LCD_DISPLAYCONTROL | displayControl
    rcall LCDCommand
    pop r24
    ret

;-------------------------------------------------------------
; LCDDisplayOff.
;
; Turns off the display.
; All registers preserved.
;-------------------------------------------------------------
LCDDisplayOff:
    push r24
    ldi r24,LCD_DISPLAYCONTROL | (displayControl & ~LCD_DISPLAYON)
    rcall LCDCommand
    pop r24
    ret

;-------------------------------------------------------------
; LCDCursorOn.
;
; Turns on the underline cursor, no blinking and the display
; is on if previously off.
;
; All registers preserved.
;-------------------------------------------------------------
LCDCursorOn:
    push r24
    ldi r24,LCD_DISPLAYCONTROL | LCD_CURSORON | displayControl
    rcall LCDCommand
    pop r24
    ret

;-------------------------------------------------------------
; LCDCursorOff.
;
; Turns off the underline cursor.
; All registers preserved.
;-------------------------------------------------------------
LCDCursorOff:
    push r24
    ldi r24,LCD_DISPLAYCONTROL | (displayControl & ~LCD_CURSORON)
    rcall LCDCommand
    pop r24
    ret

;-------------------------------------------------------------
; LCDBlinkOn.
;
; Turns on blinking, enables the cursor and the display.
; All registers preserved.
;-------------------------------------------------------------
LCDBlinkOn:
    push r24
    ldi r24,LCD_DISPLAYCONTROL | LCD_BLINKON | displayControl
    rcall LCDCommand
    pop r24
    ret

;-------------------------------------------------------------
; LCDBlinkOff.
;
; Turns off the blinking cursor.
; All registers preserved.
;-------------------------------------------------------------
LCDBlinkOff:
    push r24
    ldi r24,LCD_DISPLAYCONTROL | (displayControl & ~LCD_BLINKON)
    rcall LCDCommand
    pop r24
    ret

;-------------------------------------------------------------
; LCDScrollLeft.
;
; Scrolls the display left one character. Text may be scrolled
; completely off the screen.
;
; All registers preserved.
;-------------------------------------------------------------
LCDScrollLeft:
    push r24
    ldi r24,LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVELEFT
    rcall LCDCommand
    pop r24
    ret

;-------------------------------------------------------------
; LCDScrollRight.
;
; Scrolls the display right one character. Text may be 
; scrolled completely off the screen.
;
; All registers preserved.
;-------------------------------------------------------------
LCDScrollRight:
    push r24
    ldi r24,LCD_CURSORSHIFT | LCD_DISPLAYMOVE | LCD_MOVERIGHT
    rcall LCDCommand
    pop r24
    ret

;-------------------------------------------------------------
; LCDLeftToRight.
;
; Set text direction left to right. The cursor must be set to
; the rightmost print position for the text in this mode.
;
; All registers preserved.
;-------------------------------------------------------------
LCDLeftToRight:
    push r24
    ldi r24,LCD_ENTRYMODESET | entryMode
    rcall LCDCommand
    pop r24
    ret

;-------------------------------------------------------------
; LCDRightToLeft.
;
; Set text direction left to right.
; All registers preserved.
;-------------------------------------------------------------
LCDRightToLeft:
    push r24
    ldi r24,LCD_ENTRYMODESET | (entryMode & ~LCD_ENTRYLEFT)
    rcall LCDCommand
    pop r24
    ret

;-------------------------------------------------------------
; LCDNoAutoScroll.
;
; Turns off autoscrolling.
; All registers preserved.
;-------------------------------------------------------------
LCDNoAutoScroll:
    push r24
    ldi r24,LCD_ENTRYMODESET | LCD_ENTRYSHIFTDECREMENT | LCD_ENTRYLEFT
    rcall LCDCommand
    pop r24
    ret

;-------------------------------------------------------------
; LCDAutoScroll
;
; Turns on autoscrolling.
; All registers preserved.
;-------------------------------------------------------------
LCDAutoScroll:
    push r24
    ldi r24,LCD_ENTRYMODESET | LCD_ENTRYSHIFTINCREMENT | LCD_ENTRYLEFT
    rcall LCDCommand
    pop r24
    ret

;-------------------------------------------------------------
; LCDClearDisplay.
;
; Clears the display.
; All registers preserved.
;-------------------------------------------------------------
LCDClearDisplay:
    push r24
    push r25
    ldi r24,LCD_CLEARDISPLAY
    rcall LCDCommand
    ldi r25,hi8(2000)
    ldi r24,lo8(2000)
    call delayUSecs
    pop r25
    pop r24
    ret

;-------------------------------------------------------------
; LCDHomeCursor.
;
; Homes the cursor.
; All registers preserved.
;-------------------------------------------------------------
LCDHomeCursor:
    push r24
    push r25
    ldi r24,LCD_RETURNHOME  
    rcall LCDCommand
    ldi r25,hi8(2000)
    ldi r24,lo8(2000)
    call delayUSecs
    pop r25
    pop r24
    ret

;-------------------------------------------------------------
; LCDCursorAt.
;
; Sets the cursor to a given row and column. Row must be 0 or 
; 1. Column must be 0--15. Anything outside this range will
; be adjusted.
;
; R25 = Row, R24 = column.
; All registers preserved.
;-------------------------------------------------------------
LCDCursorAt:
    push r24
    push r25

    ; LCD 16x2 offsets:
    ; Row 0: R24 = Column + LCD_SETDDRAMADDR.
    ; Row 1: R24 = Column + LCD_SETDDRAMADDR + 0x40.

    andi r24,0x0F               ; Column is 0--15 only.
    andi r25,0x01               ; Row is 0 or 1 only.
    breq RowOK                  ; Row 0, no offset required.
    subi r24,-0x40              ; Row 1, Offset 0x40 required.

RowOK:
    ori r24,LCD_SETDDRAMADDR
    rcall LCDCommand

    pop r25
    pop r24
    ret


;=============================================================
; Low level stuff from here on.
;=============================================================

;-------------------------------------------------------------
; LCDPulse.
;
; Pulses the E pin to enable comands etc.
;
; The E pin is pin PB3/D11.
; All registers preserved.
;-------------------------------------------------------------
LCDPulse:
    push r18 
    push r24
    push r25

    in r18,_SFR_IO_ADDR(CTRLPort)
    sbr r18,(1 << E)
    out _SFR_IO_ADDR(CTRLPort),r18 ; E goes HIGH.
    ldi r25,hi8(10)
    ldi r24,lo8(10)
    call delayUSecs

    cbr r18,(1 << E)
    out _SFR_IO_ADDR(CTRLPort),r18 ; E goes low.
    ldi r25,hi8(100)
    ldi r24,lo8(100)
    call delayUSecs

    pop r25
    pop r24
    pop r18
    ret


;-------------------------------------------------------------
; LCDWrite4.
;
; The 8 bit value passed in R24 will be written to the data
; pins for the LCD but only the 4 low bits of R24 will be
; written. Data bits 3--0 are written to pins PD5--PD2 with:
;
; Data bit 3 going to DB7 = PD2.
; Data bit 2 going to DB6 = PD3.
; Data bit 1 going to DB5 = PD4.
; Data bit 0 going to DB4 = PD5.
;
; Unused bits of PORTD are preserved.
;
; The RS pin should be in the correct state prior to this call
; low for commands, high for data.
;
; All registers preserved.
;-------------------------------------------------------------
LCDWrite4:
    push r18
    
    in r18,_SFR_IO_ADDR(DATAPort)
    andi r18,0b11000011         ; Clear 4 data bits.

    sbrc r24,3
    sbr r18,(1 << PORTD2)

    sbrc r24,2
    sbr r18,(1 << PORTD3)

    sbrc r24,1
    sbr r18,(1 << PORTD4)

    sbrc r24,0
    sbr r18,(1 << PORTD5)

    out _SFR_IO_ADDR(DATAPort),r18 ; Write 4 data bits.
    rcall LCDPulse              ; Pulse E pin.

    pop r18
    ret


;-------------------------------------------------------------
; LCDCommand.
;
; The 8 bit command value passed in R24 will be written to the
; data pins for the LCD with the RS pin held low. All 8 bits
; of the command are written. 
;
; RS must be low to send commands.
;
; RS = PB4/D12.
; All registers preserved.
;-------------------------------------------------------------
LCDCommand:
    push r18
    push r24
    push r24
    in r18,_SFR_IO_ADDR(CTRLPort)
    cbr r18,(1 << RS)           ; RS = 0 for commands.
    out _SFR_IO_ADDR(CTRLPort),r18
    swap r24                    ; High nibble into low nibble.
    rcall LCDWrite4             ; Send high 4 bits first.
    rjmp LCDsendLowBits         ; Send the low 4 bits.



;-------------------------------------------------------------
; LCDSend.
;
; The 8 bit data value passed in R24 will be written to the
; data pins for the LCD with the RS pin held high. All 8 bits
; of the data are written, high 4 bits first, then low 4 bits.
;
; RS must be high to send data.
;
; RS = PB4/D12.
; All registers preserved.
;-------------------------------------------------------------
LCDSend:
    push r18
    push r24                    ; Save data byte
    push r24                    ; And again!
    in r18,_SFR_IO_ADDR(CTRLPort)  ; Current setting.
    sbr r18,(1 << RS)           ; RS = 1 for data.
    out _SFR_IO_ADDR(CTRLPort),r18 ; Set mode.

LCDSendHighBits:
    swap r24                    ; Get high nibble into low nibble.
    rcall LCDWrite4             ; Send high 4 bits first.

LCDsendLowBits:
    pop r24                     ; Retrieve data byte.
    rcall LCDWrite4             ; Write low 4 bits now.
    pop r24
    pop r18
    ret


;-------------------------------------------------------------
; LCDSendZText.
;
; The Z register points at some constant text in the Flash RAM
; which will be terminated by a zero byte. This text will be
; displayed upon the LCD.
;
; All registers preserved.
;-------------------------------------------------------------
LCDSendZText:
    push ZH                     ; Save working registers.
    push ZL
    push r24

LCDZLoop:
    lpm r24,Z+                  ; Grab a character.
    cpi r24,0                   ; Test for done.
    breq LCDZEndLoop            ; We are done.
    rcall LCDSend               ; Display this character.
    rjmp LCDZLoop               ; Do some more.

LCDZEndLoop:
    pop r24                     ; Restore working registers.
    pop ZL
    pop ZH
    ret


;-------------------------------------------------------------
; LCDSendXText.
;
; The X register points at some constant text in the Static RAM
; which will be terminated by a zero byte. This text will be
; displayed upon the LCD.
;
; All registers preserved.
;-------------------------------------------------------------
LCDSendXText:
    push XH                     ; Save working registers.
    push XL
    push r24

LCDXLoop:
    ld r24,X+                   ; Grab a character.
    cpi r24,0                   ; Test for done.
    breq LCDXEndLoop            ; We are done.
    rcall LCDSend               ; Display this character.
    rjmp LCDXLoop               ; Do some more.

LCDXEndLoop:
    pop r24                     ; Restore working registers.
    pop XL
    pop XH
    ret


;=============================================================
; Arduino delayUSecs in Assembly!
;=============================================================

;-------------------------------------------------------------
; delayUSecs.
;
; Delay for the specified number of microseconds passed in
; registers R25:R24. The shortest period for a delay, zero,
; will result in a theoretical delay of 0.75 uSecond.
;
; R1 must be zero.
; Delay in microSeconds in R25:R24. 1--65,535.
; Corrupts R25 and R24. All others are preserved.
;
; RCALL delayUSecs = 3 clocks.
; CALL delayUSecs  = 4 clocks.
;
; At 16 MHz, 16 clocks = 1 microsecond.
;             1 clock  = 1/16th of a microsecond.
;-------------------------------------------------------------
delayUSecs:
    cpi     r24,2               ; Less than 2 uSecs requested?
    cpc     r25,r1
    brcs    delayExit           ; Yes, quick exit. (0.75 uSec)


    ; Overheads:
    ; CALL       = 4 (or 6) clocks.
    ; < 2 checks = 3 clocks.
    ; RET        = 3 clocks.
    ; SBIW       = 2 clocks.
    ; Total      = 12 (or 14) clocks, subtract 1 loop pass.
    sbiw    r24,1

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
    ; Adds another 4 clocks to the total delay.
    ret