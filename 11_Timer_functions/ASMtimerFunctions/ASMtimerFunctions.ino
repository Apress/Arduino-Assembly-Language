/*============================================================
 * A useful set of assembly routines to replace the Arduino
 * micros(), millis(), delay() functions with similar ones 
 * that can be called from Assembly code, without needing to
 * call out to C++.
 *
 * Shows the use of Timer 2's overflow Interrupt.
 *
 * ASMmillis() = same as millis().
 * ASMmicros() = same as micros().
 * ASMdelay(x) = same as delay(x).
 * ASMdelayMicros(x) = same as delayMicroseconds(x).
 * ASMinitTimer2 = initiaises the system to allow the above
 *                 functions to work. Must be called as part
 *                 of the sketch initialisation.
 *
 * Obviously, if these are required to be called from C++
 * a cppInterface will be required, in the usual manner. 
 * However, the routines are expected to be used in Assembly
 * code, not C++, as C++ already has them.
 *
 * WARNING ---------------------------------------------------
 * It is not possible to use Timer 0 here, as the Arduino
 * already uses it, and we would get duplicate errors for
 * the ISR as the Arduino software defines it.
 * -----------------------------------------------------------
 *
 * Norman Dunbar.
 * 13 August 2024.
 *==========================================================*/

#ifdef __cplusplus
extern "C" {
#endif
    void ASMinitTimer2();
    uint32_t ASMmicros();
    uint32_t ASMmillis();
    void ASMdelay(uint32_t);
    void ASMdelayMicroseconds(uint32_t);
#ifdef __cplusplus
}
#endif


void setup() {
    ASMinitTimer2();
    Serial.begin(9600);
    Serial.println("Hello ASM Timer Functions.");
}

void loop() {
    // Random delay to get better figures.
    ASMdelay(analogRead(A2));

    Serial.print("\nASMmicros = ");
    Serial.print(ASMmicros());

    Serial.print(", ASMmillis = ");
    Serial.println(ASMmillis());

    // A loop to display a "*" after a delay of 1 second
    // and a "!" after a delay of 1.5 seconds.
    while (1) {
        ASMdelay(1000);
        Serial.println("*");
        ASMdelayMicroseconds(1500000);
        Serial.println("!");
    }

    // Example output:
    //
    // 16:13:12.426 -> !
    // 16:13:13.427 -> *
    // Delay is 1.001 seconds.

    // 16:13:14.913 -> !
    // Delay is 1.486 seconds.

    // 16:13:15.912 -> *
    // Delay is 0.999 seconds.

    // 16:13:17.429 -> !
    // Delay is 1.517 seconds.
}