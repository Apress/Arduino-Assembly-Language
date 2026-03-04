A very simple example of how NULL parameters are passed to
Assembly Language functions.

In summary, they are passed as zero, regardless of whether
the parameter is a string or otherwise. This will maybe
make it difficult when dealing with numerics, to tell if
the parameter is zero or is NULL.
