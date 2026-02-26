/*===========================================================
 * Analog Input Output
 *
 * This sketch configures Timer 1 in Phase Correct PWM in ten
 * bit mode. The duty cycle is controlled by register OCR1A1
 * which will take values between 0--1023. Spookily enough
 * this is the same range of values that the DC will supply!
 * The ADC interrupt is used to transfer the value from the
 * ADC to the Timer. D9/PB1 is an LED that will brighten and 
 * fade according to the potentiometer attached to pin A0 aka
 * ADC0.
 *
 * NOTE: This will not work with the analogWrite() function as
 * that can only write values between 0--255. I am using a 
 * better mode for Timer 1.
 *
 * NOTE: The response of the LED when the potentiometer is 
 * turned is not very great. It fades up rather quickly, and
 * seems to be a full brightness quite low on the scale. This
 * is because the LED is linear but the eye is logarithmic.
 *
 * Norman Dunbar.
 * 11 October 2024. 
 *=========================================================*/


#ifdef __cplusplus
extern "C" {
#endif 
    void setupADC();
    void setupPWM();
    void startADC();
#ifdef __cplusplus
}
#endif 


void setup() {
    setupPWM();
    setupADC();
    startADC();
}

void loop() {
    // Nothing to do here!
}
