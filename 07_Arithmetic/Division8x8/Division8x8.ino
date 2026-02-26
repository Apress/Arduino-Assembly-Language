#ifdef __cplusplus
extern "C" {
#endif
    uint8_t div8x8(uint8_t a, uint8_t b);
    int8_t sdiv8x8(int8_t a, int8_t b);
    uint8_t rem8x8(uint8_t a, uint8_t b);
    int8_t srem8x8(int8_t a, int8_t b);
#ifdef __cplusplus
}
#endif

void testSigned(int8_t a, int8_t b) {
    Serial.print("Signed: ");
    Serial.print(a, DEC);
    Serial.print('/');
    Serial.print(b, DEC);
    Serial.print(" = ");
    if (b) {
        Serial.print(sdiv8x8(a, b), DEC);
        Serial.print(" remainder ");
        Serial.println(srem8x8(a, b));
    } else {
        Serial.println("Division by zero attempted!");
    } 
}

void testUnsigned(int8_t a, int8_t b) {
    Serial.print("Unsigned: ");
    Serial.print(a, DEC);
    Serial.print('/');
    Serial.print(b, DEC);
    Serial.print(" = ");
    if (b) {
        Serial.print(div8x8(a, b), DEC);
        Serial.print(" remainder ");
        Serial.println(rem8x8(a, b));
    } else {
        Serial.println("Division by zero attempted!");
    } 
}


void setup() {
    Serial.begin(9600);
    
    testUnsigned(68, 12);	// 5 r 8.
    testUnsigned(72, 12);	// 6 r 0.
    
    testSigned(68, 12);		// 5 r 8.
    testSigned(-68, 12);	// -5 r -8.
    testSigned(72, -12);	// -6 r 0.
    testSigned(-72, 12);	// -6 r 0.
    
    // Should be a compilation warning
    // and incorrect results.
    testSigned(-129, 29);   // 4 r 11 WRONG!
    
    // Don't divide by zero.
    testUnsigned(128, 0);   // Error.
}

void loop() {
 
}
