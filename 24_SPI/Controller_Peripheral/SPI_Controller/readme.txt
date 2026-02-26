============================================================
 SPI_Controller.ino

 This example shows how to use SPI in controller mode, to
 talk to aanoter Arduino in peripheral mode. The sketch 
 simply sends 8 bit values to the peripheral board which
 lights up 8 LEDs on it's output pins.

 Norman Dunbar.
 22 July 2025.
============================================================

============================================================
 CONNECTIONS

------------------------------------------------------------
 Controller       Peripheral      Arduino Pin 
------------------------------------------------------------
 SS               SS              D10/PB2
 COPI/MOSI        COPI/MOSI       D11/PB3
 CIP)/MISO        CIPO/MISO       D12.PB4
 SCK              SCK             D13/PB5
 
 5V               5V
 GND              GND 
============================================================

