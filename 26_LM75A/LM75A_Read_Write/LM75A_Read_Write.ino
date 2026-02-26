//=============================================================
// LM75A_Read_Write.ino
//
// An Assembly Language I2C Temperature reader which uses the
// LM75A library and, beneath that, the I2C_ASM library. Both 
// are written in Assembly Language for ATmega328/168 boards.
//
// This sketch is a simple temperature watcher which shows how
// to write some config data that affects what the sketch reads
// back from the sensor. The config data selects the current 
// temperature register allowing the loop to read and display
// the current temperature.
//
//
// Norman Dunbar.
// 13 August 2025.
//=============================================================

// As before, there's nothing here, it all happens in the Assembly
// code.
