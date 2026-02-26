/*============================================================
 * A sketch to blink an LED a few times, then configure the
 * watchdog to reset the board after a couple of seconds.
 *
 * WARNING WARNING WARNING WARNING WARNING WARNING WARNING !!
 *
 * This sketch may cause boot loops if the bootloader on your
 * Arduino board is too slow to disable the WDT on a restart.
 * The Uno, running Optiboot - the default bootloader - does
 * not have a problem. The Duemilanove does!
 *
 * WARNING WARNING WARNING WARNING WARNING WARNING WARNING !!
 *
 * Norman Dunbar
 * 27 September 2024
 *==========================================================*/

#include "WDT.h"

void blink(uint8_t count, uint16_t delayMs) {
    for (uint8_t x = 0; x < 2 * count; x++) {
        PINB |= (1 << PINB5);
        delay(delayMs);
    }
}

void setup() {
    pinMode(13, OUTPUT);
    Serial.begin(9600);
    wdtEnable((wdtTO_2S << 8)|(wdtMode_Reset));
    Serial.println("In Setup() -- Watchdog enabled.");
}

void loop() {
    for (uint8_t x = 1; x < 6; x++) {
        Serial.print("Blink...");
        Serial.println(x);
        blink(1, 1000);
        wdtReset();
    }

    for (uint8_t x = 1; x < 6; x++) {
        Serial.print("Blink...");
        Serial.println(x);
        blink(1, 1000);
    }
}
