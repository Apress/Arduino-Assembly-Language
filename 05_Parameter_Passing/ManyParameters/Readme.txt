ManyParameters.ino

This sketch shows how to pass a lot of parameters from C++ to the 
Assembly code we have written. 

The code passes eight 32 bit parameters, unsigned, from C++ to 
an Assembly function. This demonstrates how the parameters will
be passed on the stack when we run out of registers to use to 
pass the parameters. 4 will be passed in registers and 4 on 
the stack.

The code shows how to set up the Y register to use as a stack 
frame to make accessing the stacked parameters "easy".

The sketch also demonstrates how to return a result from 
Assembly code back to C++.

