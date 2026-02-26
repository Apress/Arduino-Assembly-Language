#ifdef __cplusplus
extern "C" {
#endif
    uint16_t div16x16(uint16_t a, uint16_t b);
    int16_t sdiv16x16(int16_t a, int16_t b);
    uint16_t rem16x16(uint16_t a, uint16_t b);
    int16_t srem16x16(int16_t a, int16_t b);
}#ifdef __cplusplus
}
#endif

void testSigned(int16_t a, int16_t b) {
    Serial.print("Signed: ");
    Serial.print(a, DEC);
    Serial.print('/');
    Serial.print(b, DEC);
    Serial.print(" = ");
    if (b) {
        Serial.print(sdiv16x16(a, b), DEC);
        Serial.print(" remainder ");
        Serial.println(srem16x16(a, b));
    } else {
        Serial.println("Division by zero attempted!");
    } 
}

void testUnsigned(uint16_t a, uint16_t b) {
    Serial.print("Unsigned: ");
    Serial.print(a, DEC);
    Serial.print('/');
    Serial.print(b, DEC);
    Serial.print(" = ");
    if (b) {
        Serial.print(div16x16(a, b), DEC);
        Serial.print(" remainder ");
        Serial.println(rem16x16(a, b));
    } else {
        Serial.println("Division by zero attempted!");
    } 
}


void setup() {
    uint16_t unsignedResult;
    int16_t signedResult;
    

    Serial.begin(9600);
    
    // Large unsigned values.
    testUnsigned(4568, 1234);    // 3 r 866.
    testUnsigned(9972, 4000);    // 2 r 1972.

    // Large & small unsigned values.
    testUnsigned(4568, 23);      // 198 r 14.
    testUnsigned(9972, 4);       // 2493 r 0.

    // Large signed values.
    testSigned(-2666, 619);      // -4 r -190.
    testSigned(-1234, -256);     // 4 r 210.

    // Large & small  signed values.
    testSigned(-1290, 29);      // -44 r -14.
    testSigned(-1234, -42);     // 29 r 16.

    // Small signed values.
    testSigned(68, 12);         // 5 r 8.
    testSigned(-68, 12);        // -5 r -8.
    testSigned(72, -12);        // -6 r 0.
    testSigned(-72, 12);        // -6 r 0.

    // Don't divide by zero.
    testSigned(3642, 0);        // Error!
}

void loop() {
 
}
