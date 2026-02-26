/*===========================================================
 * Analog Output
 *
 * This sketch configures Timer 1 in Phase Correct PWM in ten
 * bit mode. The duty cycle is controlled by register OCR1A1
 * which will take values between 0--1023. The code will use
 * the timer's Overflow Interrupt to increase the duty cycle
 * every time the counter overflows back to zero. This will 
 * cause the attached LED---Pin D9/PB1/OC1A---to fade up.
 *
 * Norman Dunbar.
 * 11 October 2024. 
 *=========================================================*/
 
#ifdef __cplusplus
extern "C" {
#endif 
    void setupPWM();
#ifdef __cplusplus
}
#endif 


void setup() {
    setupPWM();
}

void loop() {
    // Nothing to do here!
}
