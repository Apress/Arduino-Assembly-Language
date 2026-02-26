//===========================================================
// Sleep Mode POWERDOWN
//
// This sketch puts the Arduino to sleep. On wakeup, the LED
// on pin D13/PB5 will be toggled.
//
// This mode is usable on an Arduino as we don't need to
// disable Timer 0's overflow interrupt as it has no effect
// in this mode.
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
    void setup();
    void loop();
#ifdef __cplusplus
}
#endif
