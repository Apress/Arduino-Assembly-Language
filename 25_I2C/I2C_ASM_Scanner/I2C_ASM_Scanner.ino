//=============================================================
// I2C_ASM_Scanner.ino
//
// An Assembly Language I2C Scanner which should find devices
// on the I2C bus.
//
// How It Works
//
// Initialise TWI at 200 KHz speed.
// Initialise USART to 9600 baud, 8-N-1.
//
// In The loop:
//
// For each address 1 to 127:
//   Start a write transaction.
//   If Z is set, we have a device, report it's 7 bit address.
//   End the transaction.
// End of loop.
//
// Norman Dunbar.
// 27 July 2025.
//=============================================================

// As before, there's nothing here, it all happens in the Assembly
// code.
