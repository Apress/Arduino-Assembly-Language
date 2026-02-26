//============================================================
// Yet another Assembly Language version of the Blink Sketch.
//
// In this version, we pass a byte sized parameter to the
// toggle code to determine the number of flashes, and, a 32
// bit delay period for the delay between blinks. The toggle
// code will call back to the delay() function. After
// the required number of blinks, a two long delay will be
// executed by the loop() function, before starting all over
// again.I will not be discussing the entire sketch this time
// as there are only a couple of small changes that need to be
// made to update the sketch.
//
// In this sketch, however, the blink counter is obtained from
// another Assembly function, getFlashCount(). Each time it is
// called, it increases the number of flashes by 1 until we
// reach 8 whereupon, it goes back to 1 on the next call.
//============================================================

//------------------------------------------------------------
// Declare few constants, in case we want to change the delay
// or the delay between flash "sessions".
//------------------------------------------------------------
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
    uint8_t getFlashCount();
#ifdef __cplusplus
  }
#endif


void loop() {
  // Call the toggle assembly function. Blinks the number of
  // times getFlashCounter() returns, with a flashDelay 
  // millisecond delay between blinks. (1 to 8 blinks.)
  toggle(getFlashCount(), flashDelay);

  // Long delay between sessions.
  delay(longDelay);
}
