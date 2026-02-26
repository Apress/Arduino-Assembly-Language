# Many Parameters setup function.

## Prologue

1. Push R2:r29, working registers.
1. Copy `SP` into Y register.
1. Subtract 20 from `Y`.
1. Disable interrupts, set `SP` = `Y`, reset interrupt state.

## Assign a Value to `a`

Local variable `a` is assigned the value 0x01234567.

1. Load 0x01234567 into R24:R27.
1. Stores R24:R27 at Y+1:4.

## Setup for Call to `manyParameters()`

Parameters a, b, c, d, e, f and g need to be set up in registers or on the stack frame pointed to by `Y`.

1. Read `a` from Y+1:4 into R24:R27.
1. Add R24:R27 to themselves = A*2.
1. Add R24:R27 to themselves = A*4.
1. Add R24:R27 to themselves = A*8.
1. Store R24:R27 at Y+9:12. 
   This is `a`*8 for parameter `h`.

1. Read `a` from Y+1:4 into R18:R21.
1. Copy `a` in R18:21 to R24:R27.
1. Add R24:R27 to themselves = A*2.
1. Add R24:R27 to themselves = A*4.
1. Add R24:R27 to themselves = A*8.
1. Copy `a`*8 in R24:R27 to R10:R13.
1. Subtract `a` in R18:R21 from `a`*8 in R10:R13 = `a`*7. 
   This is `a`*7 for parameter `g`.
   This is not stored on the stack frame, only in registers.
   Registers R10:R13 are not used again until function call.
   
1. Read `a` from Y+1:4 into R18:R21.
1. Copy `a` in R18:21 to R24:R27.
1. Add R24:R27 to themselves = A*2.
1. Add R18:R21 to R24:R27 = A*3.
1. Add R24:R27 to themselves = A*6.
1. Store R24:R27 at Y+13:16. 
   This is `a`*6 for parameter `f`.
   
1. Read `a` from Y+1:4 into R18:R21.
1. Copy `a` in R18:21 to R24:R27.
1. Add R24:R27 to themselves = A*2.
1. Add R24:R27 to themselves = A*4.
1. Copy `a`*4 in 24:R27 to R14:R17.
1. Add `a` in R18:R21 to `a`*4 in R14:R17 = `a`*5.
   This is `a`*5 for parameter `e`.
   This is not stored on the stack frame, only in registers.
   Registers R14:R17 are not used again until function call.

1. Read `a` from Y+1:4 into R24:R27.
1. Copy `a` in R24:R27 to R18:21.
1. Add R18:21 to themselves = A*2.
1. Add R18:21 to themselves = A*4.
1. Store R18:21 at Y+17:20. 
   This is `a`*4 for parameter `d`.
   
1. Read `a` from Y+1:4 into R18:R21.
1. Copy `a` in R18:21 to R24:R27.
1. Add R24:R27 to themselves = A*2.
1. Copy `a`*2 in R24:R27 to R2:R5.
1. Add `a` in R18:R21 to `a`*2 in R2:R5 = `a`*3.
   This is `a`*3 for parameter `c`.
   This is not stored on the stack frame, only in registers.
   Registers R2:R5 are not used again until function call.

1. Read `a` from Y+1:4 into R24:R27.
1. Copy `a` in R24:R27 to R18:21.
1. Add R18:21 to themselves = A*2.
   This is `a`*2 for parameter `b`.
   This is not stored on the stack frame, only in registers.
   Registers R18:21 are not used again until function call.
   
1. Read `a` from Y+1:4 into R6:R9.
   This is `a` for parameter `a`.
   This is not stored on the stack frame, only in registers.
   Registers R6:R9 are not used again until function call.
   
   
## So Far So Good!

At this point we have all 8 parameters scattered around the place

* Y+0:0 is unknown.
* Y+1:4 is local storage for the uint32_t `a` local variable.
* Y+5:8 is local storage for the uint32_t `x` local variable.
* Y+9:12 is parameter `h`, the value `a` * 8.
* Y+13:16 is parameter `f`, the value `a` * 6.
* Y+17:20 is parameter `d`, the value `a` * 4.

* R2:R5 is parameter `c`, the value `a` * 3.
* R6:R9 is parameter `a`, the value `a`. (Yes, same name, I'm sorry!)
* R10:R13 is parameter `g`, the value `a` * 7.
* R14:R17 is parameter `e`, the value `a` * 5.
* R18:R21 is parameter `b`, the value `a` * 2.
* R22:R23 is unknown.
* R24:R27 is the value `a`.
* R28:R29 is register `Y` and holds 0x08D3. This is the stack frame pointer.
* R30:R31 is register `Z`, and is unknown.

## Stacking the Parameters

At this point we can push onto the stack all those parameters that wouldn't fit into registers. They are stacked with the MSB first and LSB last.

1. Parameter `h`, `a` * 8, is loaded from Y+9:12 and pushed onto the stack with the MSB first.
1. Parameter `g`, `a` * 7, is loaded from R10:R13 and pushed onto the stack with the MSB first.
1. Parameter `f`, `a` * 6, is loaded from Y+13:16 and pushed onto the stack with the MSB first.
1. Parameter `e`, `a` * 5, is loaded from R14:R17 and pushed onto the stack with the MSB first.
1. Parameter `d`, `a` * 4, is loaded from Y+17:20 into R10:R13 with R10 holding the LSB.
1. Parameter `c`, `a` * 3, is loaded from R2:R5 into R14:R17 with R10 holding the LSB.
1. Parameter `b`, `a` * 2, is already present in registers R18:R21 with R18 holding the LSB.
1. Parameter `a`, `a`, is loaded from R6:R9 into R24:R27 with R24 holding the LSB.

At this point, the `manyParameters` function can be called. The result will be found in registers R22:R25 on return.

## Saving the Function Call Result.

On return, as noted, the result of the function call is found in registers R22:R25. This is assigned to the local variable `x`.

1. Copy the 32 bit result from registers R22:R25 into R24:R27.
1. Store the result now in R24:R27 to Y+5:8 for the `x` local variable.


## Stack tidyup

On return from `manyParameters()` there are still four uint32_t parameters---h, g, f and e---on the stack. These need to be tidied off.

1. The current SP is read into registers R20:R21. Both now have the value 0x08C3.
1. R20:R21-(-16) adds 16 to R20:R21. The is the space used by the four parameters.7
1. R20:R21 is written back to the SP in the usual manner, with interrupts off. 
   SP is now 0x08D3.


## Setup() Postamble.

Now it's all done, we need to tidy the stack frame and restore the working registers.

1. Add 20 to `Y` to reset it to the SP on entry. This wipes out the local variables and workspace.
1. Read SREG to get interrupt status.
1. Set the `SP` back to the original value, from `Y`. Both are now 0x08E8 and this is the stacked value of R29 from the preamble. See below for stack and stack frame details.
1. Restore interrupt state.
1. Restore a lot of working registers.
1. Return to caller.

# The Stack Frame, Y Register and SP

On entry to setup(), the SP has value 0x08F9. The first free slot on the stack.

R2, R3, R4, ... , R16, R17, R28, R29 are stacked. SP = 0x08E7.

SP is copied to Y. Y is now = 0x08E7.

20 is subtracted from Y and loaded back into SP. Both are now 0x08D3.

Y is now the stack frame for the setup() function, not for manyParameters()!

By the time we call into manyParameters(), the stack frame looks like this, with lowest address at the bottom:

|Addr	|Y+Offset	|Purpose|
|:---   | :---:     | :---  |
|0x08F9     | +38   | Pushed value of R2|
|0x08F8     | +37   | Pushed value of R3|
|0x08F7     | +36   | Pushed value of R4|
| ...       |       |       |
|0x08EA     | +23   | Pushed value of R17|
|0x08E9     | +22   | Pushed value of R28|
|0x08E8     | +21   | Pushed value of R29|
|0x08E4		| +17 	| Param_d|
|0x08E0		| +13 	| Param_f|
|0x08DC		| +09 	| Param_h|
|0x08D8		| +05 	| Local variable 'x'|
|0x08D4		| +01 	| Local variable 'a'|
|0x08D3		| +00 	| Y Points here|
|0x08D0     | -03   | Param_h|
|0x08CC     | -07   | Param_g|
|0x08C8     | -11   | Param_f|
|0x08C4     | -15   | Param_e|
|0x08C3     | -16   | Return address|
|0x08C2     | -17   | Return address|


