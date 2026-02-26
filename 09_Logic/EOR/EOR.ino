/*============================================================
 * A sketch to demonstrate the use of the EOR instruction. In
 * this sketch, we have a switch on pin D11/PB3 and the LED on 
 * pin D13/PB5. We toggle the LED on and off using the switch,
 * but we use the EOR instruction to flip the D13/PB5 bit each
 * time. There is no need for the code to retain the current 
 * LED state.
 *
 * Norman Dunbar
 * 10 August 2024.
 *==========================================================*/

 // Nothing to see here, it all happens in the EOR.S file.