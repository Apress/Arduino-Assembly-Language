/*=========================================================
 * A silly example of code that returns a longish result of
 * more than eight bytes from an Assembly Language function.
 *
 * This is a demonstration for the purpose of showing how
 * to access the return buffer in an Assembly function.
 *
 * The Assembly function returns an array of 26 uint32_t
 * values corresponding to the entire interrupt vector 
 * table in the ATmega328P, just for fun!
 *
 * Norman Dunbar.
 * March 2 2024.
 *=======================================================*/
#include "constants.h"

// Comment this line to use Serial commands.
#define USE_LIBPRINTF

#ifdef USE_LIBPRINTF
    #include"LibPrintf.h"
#endif

typedef struct interruptTable {
    uint8_t interruptVector[interruptCount][4];
} interruptTable_t;

#ifdef __cplusplus
extern "C" {
#endif
    interruptTable_t getInterruptTable();
#ifdef __cplusplus
}
#endif

void setup() {
    Serial.begin(9600);

    interruptTable_t Interrupts = getInterruptTable();

#ifdef USE_LIBPRINTF
    for (uint8_t v = 0; v < 26; v++) {
        printf("Vector[%2d] = ", v+1); 
        for (uint8_t b = 0; b < 4; b++) {
            printf("%02X ", Interrupts.interruptVector[v][b]);
        }    
        printf("\n"); 
    }
#else    
    for (uint8_t v = 0; v < 26; v++) {
        Serial.print("Vector[");
        Serial.print(v+1);  // Vectors number from 1 to 26.
        Serial.print("] = ");
        for (uint8_t b = 0; b < 4; b++) {
            uint8_t c = Interrupts.interruptVector[v][b];
            if (c < 16) {
                Serial.print("0");
            }
            Serial.print(c,HEX);
            Serial.print(" ");
        }
        Serial.println();
    }
#endif   
}

void loop() {
}
