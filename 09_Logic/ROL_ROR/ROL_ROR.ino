/*============================================================
 * A sketch to demonstrate the ROL and ROR instructions.
 * Requires 8 Red LEDs for the data bits. The red LEDs are on
 * PORTD (D0 to D7 in Arduino speak).
 *
 * Norman Dunbar.
 * 5 August 2024.
 *==========================================================*/

/* NOTES:
 *
 * In order to get a call to delay() working from Assembly, we
 * need to set up the timers, and interrupts etc. It is far
 * easier to have the Arduino's init() function do all that 
 * for us! The delay() function calls the micros() function 
 * which means that Timer0 needs to be initialised as does  
 * it's overflow interrupt. It *is* doable, of course, but 
 * I'm a lazy programmer, plus, we have yet to discuss 
 * interrupts in assembly code.
 *
 * Alternatively, we could put the Arduino to sleep and use
 * a timer interrupt to wake it instead of burning CPU cycles
 * and (battery) power to do so.
 *
 * In the meantime, having the assembly code define setup() 
 * and loop() means that the Arduino Language will do the 
 * needful for us here. A later version of this sketch may  
 * well be written to do what must be done manually! (And 
 * in assembly!)
 *
 * The code is 686 bytes when we get the Arduino to do the 
 * hard work for us. That's not too bad really! But, it has 
 * to be said, there's more work being done that is required.
 */

#ifdef __cplusplus
extern "C" {
#endif
	void setup();
	void loop();
#ifdef __cplusplus
}
#endif
