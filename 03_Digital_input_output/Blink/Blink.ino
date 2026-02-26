//==========================================================
// Assembly Language version of the Blink Sketch.
//==========================================================

//----------------------------------------------------------
// Declare the Assembly Language functions setup and
// toggle as external and using the C calling convention.
//----------------------------------------------------------
#ifdef __cplusplus
  extern "C" {
#endif
    void setup();
    void toggle();
#ifdef __cplusplus
  }
#endif

void loop() {
  // Call the toggle assembly function.
  toggle();

  // Call the Arduino delay function.
  delay(1000);
}
