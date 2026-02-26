#ifndef ASM_USART_H
#define ASM_USART_H

// NOTE: We cannot define __SFR_OFFSET 0 in a library as this
// will mess up the use of ATmega328 registers and such like in
// C++ code. We have to use the macros _SFR_IO_ADDR and 
// _SFR_MEM_ADDR.

#include <avr/io.h>

#endif // ASM_USART_H

