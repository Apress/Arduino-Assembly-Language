//============================================================
// Assembly Language version of the Blink Sketch.
//
// In this version, we pass a byte sized parameter to the
// toggle code to determine the number of flashes, and, a 32
// bit delay period for the delay between blinks. The toggle
// code will call back to the delay() function. After
// the required number of blinks, a two long delay will be
// executed by the loop() function, before starting all over
// again.
//============================================================

//------------------------------------------------------------
// Declare  few constants, in case we want to change the flash
// count, delay or the delay between flash "sessions".
//------------------------------------------------------------
const uint8_t flashCount = 4;
const uint32_t flashDelay = 250;
const uint32_t longDelay = 2000;


//------------------------------------------------------------
// Declare the Assembly Language functions setup and
// toggle as external and using the C calling convention.
//------------------------------------------------------------
#ifdef __cplusplus
  extern "C" {
#endif
    void setup();
    void toggle(uint8_t blinkCount,
                uint32_t delayMillis);
#ifdef __cplusplus
  }
#endif


void loop() {
  // Call the toggle assembly function. Blinks flashCount
  // times, with a flashDelay millisecond delay between
  // blinks.
  toggle(flashCount, flashDelay);

  // Long delay between sessions.
  delay(longDelay);
}
