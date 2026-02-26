#include <WDT.h>

/*============================================================
 * A sketch to blink an LED - what else - every second by
 * using the Watchdog in WDI mode to do the blinking.
 * WDI = Watchdog Interrupt.
 *
 * Norman Dunbar
 * 27 September 2024
 *==========================================================*/

void setup() {
    pinMode(13, OUTPUT);
    wdtEnable((wdtTO_1S << 8)|(wdtMode_Interrupt));
}

void loop() {
    // Nothing to do here. Ideally, the board
    // would be put to sleep.
}


ISR(WDT_vect) {
    // Toggle D13/PB5.
    PINB |= (1 << PINB5);
}