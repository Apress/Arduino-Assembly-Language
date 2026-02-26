/*===========================================================
 * Analog Input
 *
 * This sketch configures the ADC in single shot mode with 
 * the ADC Interrupt enabled. The ADC reading is displayed on
 * the Serial Monitor.
 *
 * Norman Dunbar.
 * 11 October 2024. 
 *=========================================================*/


#ifdef __cplusplus
extern "C" {
#endif 
    void setupADC();
    void setupSleep();
    void gotoSleep();
#ifdef __cplusplus
}
#endif 

// Global variable for ADC interrupt.
volatile uint16_t ADCReading;


// Configures Serial and ADC and sets ADC sleep mode.
void setup() {
    Serial.begin(9600);
    setupADC();
    setupSleep();
}


void loop() {
    static uint16_t lastReading = 0xFFFF;

    // Put the board to sleep and start the ADC.
    gotoSleep();

    // We have a new reading if we get here.
    // Try to prevent too much output.
    if (ADCReading != lastReading) {
        Serial.println(ADCReading);
        lastReading = ADCReading;
    }

    // Prevents Serial corruption!!
    // Might need adjusting if you twist too quickly.
    delay(20);
}

// Copies the ADC reading into ADCReading!
ISR(ADC_vect) {
    ADCReading = ADCW;
}
