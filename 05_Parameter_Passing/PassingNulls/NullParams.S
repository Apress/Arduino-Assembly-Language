.global test

.section .text

; text(uint16_t, char *,  uint16_t)
;      R25:R24,  R23,R22, R21:R20 
; How is NULL handled?
test:
    ret