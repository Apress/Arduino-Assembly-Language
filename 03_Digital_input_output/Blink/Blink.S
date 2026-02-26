#define __SFR_OFFSET 0
#include <avr/io.h>

.global setup
.global toggle

.section .text

setup:
    sbi DDRB,DDB5
    ret

toggle:
    sbi PINB,PINB5
    ret