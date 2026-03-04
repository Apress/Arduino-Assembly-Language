//============================================================
// A very simple example of how NULL parameters are passed to
// Assembly Language functions.
//
// In summary, they are passed as zero, regardless of whether
// the parameter is a string or otherwise. This will maybe
// make it difficult when dealing with numerics, to tell if
// the parameter is zero or is NULL.
//
// Norman Dunbar.
// 19 May 2025.
//============================================================

#ifdef __cplusplus
extern "C" {
#endif
    void test(uint16_t Dummy_1, char *Dummy_2, uint16_t Dummy_3);
#ifdef __cplusplus
}
#endif


void setup() {
    // Test with a NULL string pointer.
    test(0x1234, NULL, 0xDEAD);

    // Test with a NULL numeric.
    test(0x2468, "Hello", NULL);
}

void loop() {
}
