/*===========================================================
 * An example of setting up the various hexadecimal 
 * conversion functions so that they can be called from C++.
 *
 * Norman Dunbar.
 * 24 April 2024.
 *=========================================================*/

#ifdef __cplusplus
    extern "C" {
#endif

    char *hex32Convert(uint32_t value);
    char *hex16Convert(uint16_t value);
    char *hex8Convert(uint8_t value);

#ifdef __cplusplus
    }
#endif

void setup() {
    pinMode(LED_BUILTIN, OUTPUT);
    Serial.begin(9600);
    Serial.println("Hexadecimal Conversion Examples");
}

void loop() {
    for(uint32_t value = analogRead(A2); value < 0xffffff; value *= 2) {
        Serial.print(value);
        Serial.print(" = Ox");

        Serial.print(hex8Convert(value));
        Serial.print(", 0x");
        Serial.print(hex16Convert(value));
        Serial.print(", 0x");
        Serial.println(hex32Convert(value));
        delay(250);
    }

    // Hang up!
    while (1) {
        digitalWrite(LED_BUILTIN, HIGH);
        delay(500);
        digitalWrite(LED_BUILTIN, LOW);
        delay(500);
    }
}