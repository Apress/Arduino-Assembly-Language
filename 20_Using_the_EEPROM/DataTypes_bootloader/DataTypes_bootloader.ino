//===========================================================
// A sketch to initialise the EEPROM data. There will
// be 10 bytes, 10 uint16_t and 10 uint32_t values and a 
// small piece of text, zero terminated.
//
// Norman Dunbar.
// 21 February 2025.
//===========================================================

// Uncomment this line to enable debugging output.
//#define DEBUGGING

#include <EEPROM.h>

// Write a single byte to the EEPROM.
EEPtr writeByte(EEPtr address, uint8_t value) {
#ifdef DEBUGGING
    Serial.print("Address\t");
    Serial.print(address);
    Serial.print("\tByte: ");
    Serial.println(value, HEX);
#endif

    // Only write the byte if it is different to current.
    EEPROM.update(address, value);
    return ++address;
}

EEPtr writeWord(EEPtr address, uint16_t value) {
    EEPtr addr = address;

    // Low byte first, little endian.
    addr = writeByte(addr, value & 0x00ff);
    addr = writeByte(addr, value >> 8);
    return addr;
}

EEPtr writeLong(EEPtr address, uint32_t value) {
    EEPtr addr = address;

    // Low word first, little endian.
    addr = writeWord(addr, value & 0xffff);
    addr = writeWord(addr, value >> 16);
    return addr;
}

void setup() {

#ifdef DEBUGGING
    // Enable debugging.
    Serial.begin(9600);
#endif

    uint16_t wordValues[] = {0x1112,0x2223,0x3334,0x4445,
                             0x5556,0x6667,0x7778,0x8889,
                             0x999A,0xAAAB};

    uint32_t longValues[] = {0x11111112,0x22222223,0x33333334,
                             0x44444445,0x55555556,0x66666667,
                             0x77777778,0x88888889,0x9999999A,
                             0xAAAAAAAB};

    const char *textValue {"EEPROM Data Ends."};


    // EEPROM addresses can be int, but let's use a class!
    EEPtr address = EEPROM.begin();

    // Write 10 Bytes.
    for (uint8_t byteValue = 0; byteValue < 10; byteValue++) {
        address = writeByte(address, byteValue);
    }

    // Write 10 Words.
    for (uint8_t wordValue = 0; wordValue < 10; wordValue++) {
        address = writeWord(address, wordValues[wordValue]);
    }

    // Write 10 Longs.
    for (uint8_t longValue = 0; longValue < 10; longValue++) {
        address = writeLong(address, longValues[longValue]);
    }

    // Write some text. Also writes terminating '\0'.
    char *p = (char *)textValue;
    do {
        address = writeByte(address, (uint8_t)*p);
    } while (*p++);
}

void loop() {

}