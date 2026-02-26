//=============================================================
// LM75A_Interrupt.ino
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
// The LED will come on when the temperature rises above T_OS
// and go off again when it drops below T_HYST. Similar to 
// comparator mode but necessitating the reset each time the 
// interrupt triggers. (Comparator mode is far easier!)
//
// NOTE: In interrupt mode, the OS pin remains active once
// triggered until either a read from the LM75A is carried out
// or the sensor is put into shutdown mode. This will deactivate
// OS until the nect interrupt, otherwise, it remains active
// forever!
//
// D13/PB5's LED will be lit on over temperature situations.
// D2/PD2 is connected to the OS pin via a "FALLING" INT0 
// interrupt.
//
//
// Norman Dunbar.
// 13 August 2025.
//=============================================================

// As before, there's nothing here, it all happens in the Assembly
// code.
