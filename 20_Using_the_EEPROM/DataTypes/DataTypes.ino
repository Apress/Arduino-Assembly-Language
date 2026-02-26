//===========================================================
// A sketch to read and printout the EEPROM data. There will
// be 10 bytes, 10 uint16_t and 10 uint32_t values and a 
// small piece of text, zero terminated.
//
// Norman Dunbar.
// 21 February 2025.
//===========================================================
/* Upload the EEPROM file with an ICSP devicve and this:

"${HOME}/.arduino15/packages/arduino/tools/avrdude/6.3.0-arduino17/bin/avrdude" \
"-C${HOME}/.arduino15/packages/arduino/tools/avrdude/6.3.0-arduino17/etc/avrdude.conf" \
-v -V -patmega328p -cusbtiny -D \
"-Ueeprom:w:${HOME}/.cache/arduino/sketches/746C28E84DE379F6BBE81FC62794C1E4/DataTypes.ino.eep:i"
   ^^^^^^                                                                                  ^^^
===========================================================*/

#include <EEPROM.h>

void setup() {
    Serial.begin(9600);

    uint8_t byteValue;
    uint16_t wordValue;
    uint32_t longValue;

    // EEPROM addresses can be int, but let's use a class!
    EEPtr address = EEPROM.begin();

    // Read 10 Bytes.
    for (uint8_t x = 0; x < 10; x++) {
        Serial.print("0x");
        Serial.print(address, HEX);
        EEPROM.get(address, byteValue);
        address = address + sizeof(byteValue);
        Serial.print("\t");
        Serial.println(byteValue, HEX);
    }
    Serial.println("\n");

    // Read 10 Words.
    for (uint8_t x = 0; x < 10; x++) {
        Serial.print("0x");
        Serial.print(address, HEX);
        EEPROM.get(address, wordValue);
        address = address + sizeof(wordValue);
        Serial.print("\t");
        Serial.println(wordValue, HEX);
    }
    Serial.println("\n");

    // Read 10 Longs.
    for (uint8_t x = 0; x < 10; x++) {
        Serial.print("0x");
        Serial.print(address, HEX);
        EEPROM.get(address, longValue);
        address = address + sizeof(longValue);
        Serial.print("\t");
        Serial.println(longValue, HEX);
    }
    Serial.println("\n");    

    // Read some text. Stop after '\0' if there's text in 
    // the EEPROM, or after 0xFF if EEPROM is  blank.
    Serial.print("0x");
    Serial.print(address, HEX);
    Serial.print("\t");
    while (((EEPROM.get(address, byteValue)) != 0) && 
            (byteValue != 0xFF)) {
        address = address + sizeof(byteValue);
        Serial.print((char)byteValue);
    }
    Serial.println();
}

void loop() {

}