//===========================================================
// SleepMode Millis
//
// This sketch puts the Arduino to sleep in power down mode. 
// The watchdog timer is configured to wake the board after 
// four seconds to report the value of millis() and whether 
// it has changed during sleep.
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
    void setSleepMode();
    void setWatchdog();
    void goToSleep();
#ifdef __cplusplus
}
#endif

void setup() {
    Serial.begin(9600);
    setSleepMode();
    setWatchdog();
}

void loop() {
    uint32_t Milly_1 = millis();
    goToSleep();
    uint32_t Milly_2 = millis();
    Serial.print("Slept for = ");
    Serial.print(Milly_2 - Milly_1);
    Serial.println(" millis().");
    delay(100);
}
