This directory contains the following Sketches to use and abuse 
the EEPROM built into the ATMega328P microcontroller.


DataTypes

A sketch to read and printout the EEPROM data. There will
be 10 bytes, 10 uint16_t and 10 uint32_t values and a 
small piece of text, zero terminated.


DataTypes_bootloader

A sketch to initialise the EEPROM data. There will
be 10 bytes, 10 uint16_t and 10 uint32_t values and a 
small piece of text, zero terminated.

This sketch assumes only the bootloader is available to 
initialise the EEPROM data.


EepromRead

A sketch to read the test data, written to the EEPROM,using . 
Assembly. There will be 10 bytes, 10 uint16_t and 10 uint32_t 
values and a small piece of text, zero terminated. The bytes 
will be displayed on the Serial Monitor.


EepromWrite

A sketch to write the test EEPROM data using Assembly. 
There will be 10 bytes, 10 uint16_t and 10 uint32_t values
and a small piece of text, zero terminated.

This sketch is similar to DataTypes_bootloader, but writes the 
data directly from Assembly Language.


EepromUpdate

A sketch to update some of the previously written EEPROM data. 
There will be 10 bytes, 10 uint16_t and 10 uint32_t values
and a small piece of text, zero terminated. The bytes will
be displayed on the Serial Monitor.

The sketch will only update *some* of the data, not all. This 
saves "wear and tear" on the limited life of the EEPROM cells.

