#ifdef __cplusplus
extern "C" {
#endif
    uint32_t manyParameters(uint32_t a, uint32_t b, uint32_t c,
                            uint32_t d, uint32_t e, uint32_t f,
                            uint32_t g, uint32_t h);
#ifdef __cplusplus
}
#endif

void setup() {
    Serial.begin(9600);
    uint32_t a = 0x01234567;

    // x = 36 * 19,088,743 = 687,194,748.
    uint32_t x = manyParameters(a,   a*2, a*3, a*4, 
    							a*5, a*6, a*7, a*8);
    Serial.println(x);

}

void loop() {
}
