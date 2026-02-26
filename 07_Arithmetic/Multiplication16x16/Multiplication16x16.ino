//=========================================================
// This is the test sketch for the 16 bit multiplication
// routines written in Assembler. 
//
// Norman Dunbar.
// 27 January 2024.
//=========================================================

#ifdef __cplusplus
extern "C" {
#endif
    // Value range: 0x0000 to 0xFFFF.
    uint32_t mult16x16(uint16_t a, uint16_t b);

    // Value range: 0x8000 to 0x7FFF.
    int32_t smult16x16(int16_t a, int16_t b);
ifdef __cplusplus
}
#endif

void setup() {
    uint32_t unsignedResult;
    int32_t signedResult;

    Serial.begin(9600);

     // Unsigned 0x1234 * 0x2468 = 0x0296B520.
     // Unsigned 4660 * 9320 = 43,431,200
    unsignedResult = mult16x16(0x1234, 0x2468);
    Serial.print(0x1234, DEC);
    Serial.print(" * ");
    Serial.print(0x2468, DEC);
    Serial.print(" = ");
    Serial.println(unsignedResult, DEC);
    
    // Signed -0x1234 * -0x2468 = 0x0296B520.
    // Signed -4660 * 9320 = -43,431,200
    signedResult = smult16x16(-0x1234, -0x2468);
    Serial.print(-0x1234, DEC);
    Serial.print(" * ");
    Serial.print(-0x2468, DEC);
    Serial.print(" = ");
    Serial.println(signedResult, DEC);
    
    // Signed -0x1234 * 0x2468 = 0xFD694AE0.
    // Signed 4660 * -9320 = -43,431,200
    signedResult = smult16x16(-0x1234, 0x2468);
    Serial.print(-0x1234, DEC);
    Serial.print(" * ");
    Serial.print(0x2468, DEC);
    Serial.print(" = ");
    Serial.println(signedResult, DEC);
}

void loop() {
}
