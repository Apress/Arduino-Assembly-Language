//============================================================
// This example shows how to use SPI in controller mode, to
// talk to a SN74HC595 shift register from Assembly Code. The
// sketch simply sends 8 bit values to the SN74HC595 and gets
// it to light up the LEDs, of which, there are 8.
//
// Norman Dunbar.
// 18 July 2025.
//============================================================

//============================================================
// CONNECTIONS
//
//------------------------------------------------------------
// ARDUINO    SPI Func      SN74HC595         EXTRA Connection
//------------------------------------------------------------
// 5V         -             16/VCC
// -          -             15/QA/Q0          560R to LED+
// D11/PB3    COPI/MOSI     14/SER/DS          -
// D9/PB1     -             13/~OE            10K to VCC
// D8/PB0     -             12/RCLK/ST_CP      -
// D13/PB5    SCK           11/SRCLK/SH_CP     -
// -          -             10/~SRCLR/~MR     10K to VCC
// -          -              9/QH'/Q7'        Not connected
// GND        -              8/GND
// -          -              7/QH/Q7          560R to LED+
// -          -              6/QG/Q6          560R to LED+
// -          -              5/QF/Q5          560R to LED+
// -          -              4/QE/Q4          560R to LED+
// -          -              3/QD/Q3          560R to LED+
// -          -              2/QC/Q2          560R to LED+
// -          -              1/QB/Q1          560R to LED+
//
// -          -               -               All LED- to GND
//============================================================

//-------------------------------------------------------------
// Note that there are two naming conventions for the SN74HC595
// shift register. Both are used above in the connections list.
//
// Nobody said this was easy!!!! ;o)
//-------------------------------------------------------------

//-------------------------------------------------------------
// As for the 8 LEDs on the same port, there's a pin limit of 
// 20 mA but a port limit of 100 mA maximum. I've got red, amber
// and green LEDs. The reds have a forward voltage of 1.86V, 
// amber is 2.08V and green is 2.93V. For 8 LEDs with 560R
// resistors, we have:
//
// RED:   5V - 1.86 V = 3.14 V / 560 R = 5.6 mA * 8 = 44.8 mA total.
// AMBER: 5V - 2.08 V = 2.92 V / 560 R = 5.2 mA * 8 = 41.6 mA total.
// GREEN: 5V - 2.93 V = 2.07 V / 560 R = 3.7 mA * 8 = 29.6 mA total.
//-------------------------------------------------------------
