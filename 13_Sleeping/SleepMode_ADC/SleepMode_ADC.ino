//===========================================================
// Sleep Mode ADC
//
// This sketch puts the Arduino into ADC sleep which triggers  
// an ADC conversion. On wakeup, the result of this  
// conversion is available in the ADCL and ADCH registers.
//
// This mode is usable on an Arduino and we don't need to
// disable Timer 0's overflow interrupt as it has no effect
// in this mode. The ADC Conversion Complete Interrupt will4
// wake the board and ensure the result is ready.
//
// SLEEP MODES:
//
// SLEEP_MODE_IDLE
// SLEEP_MODE_ADC
// SLEEP_MODE_PWR_DOWN
// SLEEP_MODE_STANDBY
//
// Norman Dunbar.
// 15 September 2024.
//===========================================================

#ifdef __cplusplus
extern "C" {
#endif
    void goToSleep();
    void setSleepMode();
    uint16_t readADC();
    void configADC();
#ifdef __cplusplus
}
#endif


void setup() {
    Serial.begin(9600);
    configADC();
    setSleepMode();
}


void loop() {
    goToSleep();
    Serial.println(readADC());
    delay(100);
}