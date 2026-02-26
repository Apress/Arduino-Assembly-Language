// A switch is attached to D8, the other side is connected to ground. The pin is declared
// as INPUT_PULLUP. When the switch is pressed, the built in LED illuminates.
//
// D8 ----> SW1 --+-----------> GND
//
// This sketch tests whether or not I need to keep the PORTx pin set
// to keep the switch pulled up, or if it is only required at setup.
//
//
// Norman Dunbar
// 29 November 2022.

void setup() {
    DDRB |= (1 << DDB5)|(0<<DDB0); // D8 = INPUT. D13 = output.
    PORTB |= (1 << PORTB0);        // D8 now input_pullup.
    Serial.begin(9600);
    Serial.print("Setup: ");
    Serial.println(digitalRead(8));
    delay(1000);   
}


void loop() {
    if (digitalRead(8)) {
        Serial.print("LOOP: ");
        Serial.println(1);
    } else {
        Serial.print("LOOP: ");
        Serial.println(0);
    }
}