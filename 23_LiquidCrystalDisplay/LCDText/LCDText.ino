//============================================================
// LCDText.ino
//
// Testing the LCDLibrary with a LCD 16x2 display in 4 bit 
// mode. Connections are as follows:
//
// PORTD: PD5--PD2 are the data lines, PD2 is the lowest bit.
// Arduino pins are D5--D2 to correspond.
//
// CONNECT:
//      PD2/D2 to LCD pin DB7
//      PD3/D3 to LCD pin DB6
//      PD4/D4 to LCD pin DB5
//      PD5/D5 to LCD pin DB4

// 
// PORTB: PB4 = RS. PB3 = E. PB2 = R/W.
// Arduino pins are D12 = RS, D11 = E, D10 = R/W
//
// CONNECT:
//      GND     to LCD pin 5 = R/W pin.
//      PB3/D11 to LCD pin 6 = Enable pin.
//      PB4/D12 to LCD pin 4 = RS pin
// 
// The R/W pin, by default D10/PB2, is not used. Pin 5 of the
// LCD should be tied to GND.
//
// *****  This  library  is  for  Assembly  code  only!  *****
//
// Norman Dunbar.
// 20 June 2025.
//============================================================

//------------------------------------------------------------
// This sketch demonstrates sending text strings to the LCD. 
// The text can be sent from the .code section using 
// LCDSendZText or from the .data section using LCDSendXText.
//------------------------------------------------------------
