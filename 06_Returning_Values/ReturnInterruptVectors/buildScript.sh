 ## How to build with proper debug optimisation -O0.
 
 /home/norman/.arduino15/packages/arduino/tools/avr-gcc/7.3.0-atmel3.6.1-arduino7/bin/avr-g++ -c -g -O0 -std=gnu++11 -fpermissive -fno-exceptions -ffunction-sections -fdata-sections -fno-threadsafe-statics -Wno-error=narrowing -MMD -flto -mmcu=atmega328p -DF_CPU=16000000L -DARDUINO=10607 -DARDUINO_AVR_UNO -DARDUINO_ARCH_AVR -I/home/norman/.arduino15/packages/arduino/hardware/avr/1.8.6/cores/arduino -I/home/norman/.arduino15/packages/arduino/hardware/avr/1.8.6/variants/standard /tmp/arduino/sketches/A66A50D8ADF7D202D153B8A03BAF757C/sketch/ReturnInRAM.ino.cpp -o /tmp/arduino/sketches/A66A50D8ADF7D202D153B8A03BAF757C/sketch/ReturnInRAM.ino.cpp.o
 
 /home/norman/.arduino15/packages/arduino/tools/avr-gcc/7.3.0-atmel3.6.1-arduino7/bin/avr-gcc -O0 -g -flto -fuse-linker-plugin -Wl,--gc-sections -mmcu=atmega328p -o /tmp/arduino/sketches/A66A50D8ADF7D202D153B8A03BAF757C/ReturnInRAM.ino.elf /tmp/arduino/sketches/A66A50D8ADF7D202D153B8A03BAF757C/sketch/ReturnInRAM.ino.cpp.o /tmp/arduino/sketches/A66A50D8ADF7D202D153B8A03BAF757C/../../cores/arduino_avr_uno_dcac14cd8ce3554ee2f01dc9d0efe40e/core.a -L/tmp/arduino/sketches/A66A50D8ADF7D202D153B8A03BAF757C -lm
 

