#!/bin/bash

#=============================================================
# A small script to get around the problem in the Arduino IDE 
# where it is not permitted to use output redirection as part
# of a recipe.
#
# See: https://forum.arduino.cc/t/is-redirection-sign-allowed-
# in-platform-txt-recipes/1084718/1  (All on one line!)
#
# This file MUST BE FOUND ON THE PATH. 
#-------------------------------------------------------------
# Norman Dunbar
# 9 February 2025.
#-------------------------------------------------------------
# Expects three parameters:
#
# $1 = Full path to Arduino supplied avr-objdumpo utility.
# $2 = Path to the Sketch.ino.elf. (The compiled sketch)
# $3 = Path to the assembly listing file. Sketch.ino.asm.
#
#=============================================================
echo "Generating assembly dump file..."
echo "${1}  --source --disassemble ${2} > ${3}"
${1}  --source --disassemble ${2} > ${3}
exit 0


