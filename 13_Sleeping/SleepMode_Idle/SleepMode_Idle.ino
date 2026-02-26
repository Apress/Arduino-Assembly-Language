//===========================================================
// Sleep Mode Idle
//
// This sketch puts the Arduino to sleep.On wakeup, the LED
// on pin D13/PB5 will be toggled.
//
// This mode is pretty useless on an Arduino unless we first
// disable Timer 0's overflow interrupt as it will trigger
// every 1.024 milliseconds, and in doing so, wake us up.
//
// The LED will appear to be constantly on but my Labrador
// oscilloscope shows a frequency of 488 Hz which has a
// period of 0.00204918 seconds, or 2.048 milliseconds ---
// toggling the LED at roughly the same frequency and 
// period of the interrupt.
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
