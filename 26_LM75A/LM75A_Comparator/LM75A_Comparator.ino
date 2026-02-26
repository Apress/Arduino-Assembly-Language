//=============================================================
// LM75A_Comparator.ino
//
// An Assembly Language I2C Temperature reader which uses the
// LM75A library and, beneath that, the I2C_ASM library. Both 
// are written in Assembly Language for ATmega328/168 boards.
//
// This sketch is a simple temperature watcher but with an 
// alarm with will trigger once when the current temperature
// rises above T_OS and again when it falls below T_HYST. These
// can be set in the sketch to suit the temperature where you
// are!
//
// Unlike interrupt mode, there's no need to reset the LM75A's
// OS pin when it gets triggered. The comparator controls the
// pin's state. Also, we can freely read the LM75A's registers
// without affecting the OS pin's state.
//
// D13/PB5's LED will be lit on over temperature situations and
// will go out when the temperature drops again.
// D2/PD2 is connected to the OS pin via a "CHANGE" INT0 
// interrupt.
//
//
// Norman Dunbar.
// 13 August 2025.
//=============================================================

// As before, there's nothing here, it all happens in the Assembly
// code.
