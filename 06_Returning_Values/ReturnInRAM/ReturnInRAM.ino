/*=========================================================
 * A silly example of code that returns a longish result of
 * more than eight bytes from a function.
 *
 * This is a demonstration for the purpose of showing how
 * to access the return pinbArray in an Assembly function.
 *
 * Norman Dunbar.
 * February 27 2024.
 *=======================================================*/



typedef struct params {
    uint8_t pinbArray[6];
    uint32_t pindValue;
} params_t;

params_t *testParams;

params_t returnInRAM() {
    testParams = new(params_t);

    if (testParams) {
        for (int y = 0; y < 6; y++) {
            testParams->pinbArray[y] = PINB;
        }
        testParams->pindValue = PIND;
        return *testParams;
    }
}


void setup() {
  params_t params = returnInRAM();
  uint32_t pindVal = params.pindValue;

    Serial.begin(9600);
    Serial.println(pindVal);
    for (int y = 0; y < 6;y++) 
        Serial.println(params.pinbArray[y]);

    // Make sure we free the allocated RAM.
    if (testParams)
        delete(testParams);
}

void loop() {
  // put your main code here, to run repeatedly:

}
