/*===========================================================
 * This sketch is a simple variant of the Blink sketch. It
 * includes the simple USART library header, explained in the
 * book. 
 *
 * With the define __SFR_OFFSET 0 line commented out, it will
 * work perfectly. Howebver, uncomment that line and it will
 * stop working because DDRB/PINB are now using the wrong
 * address.
 *
 *
 * Norman Dunbar
 * 29 July 2025.
*/


//Uncomment the next line to stop things working!
//#define __SFR_OFFSET 0

#include <ASM_Usart.h>

#ifdef __cplusplus
  extern "C" void UsartTX9600();
#endif

// Use direct SFR access to set pinmode on D13/PB5.
void setup() {
    DDRB = (1 << DDB5);
    UsartTX9600();        // Ensure library loaded.
}

// Use direct SFR access to toggle D13/PB5.
void loop() {
    PINB |= (1 << PINB5);
    delay(1000);
}