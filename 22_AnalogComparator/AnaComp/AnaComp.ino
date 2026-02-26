//============================================================
// AnaComp.ino
//
// A sketch to configure the Analog Comparator with AIN0 and
// AIN1 as its input pins and to trigger an interrupt when the
// light level on an LDR is darker than a preset level set by
// a small potentiometer. While the interrupt has not been
// triggered, the board will be in Idle Sleep mode. This is
// the only sleep mode that the Analog Comparator can use to
// wake the board.
//
//
// Norman Dunbar.
// 30 May 2025.
//============================================================

// Nothing to be seen here, it's all happening in code.S.
