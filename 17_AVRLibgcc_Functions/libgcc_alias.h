#ifndef STUFF_H
#define STUFF_H

;============================================================
; This header redefines the internal libgcc function names
; with a more meaningful and user friendly vesion.
;============================================================

;------------------------------------------------------------
; MULT_S16_S16
;------------------------------------------------------------
; 16 bit signed by 16 bit signed multiply with a 32 bit 
; signed result.
; R25:R22 = (signed) R27:R26 * (signed) R19:R18.
; Corrupts R0.
#define Mult_s16_s16 __mulhisi3
;------------------------------------------------------------

;------------------------------------------------------------
; MULT_S16_U16
;------------------------------------------------------------
; 16 bit signed by 16 bit unsigned multiply with a 32 bit 
; signed result.
; R25:R22 = (signed) R27:R26 * (unsigned) R19:R18.
; Corrupts R0
#define Mult_s16_u16 __usmulhisi3
;------------------------------------------------------------


;------------------------------------------------------------
; MULT_U16_U16
;------------------------------------------------------------
; 16 bit unsigned by 16 bit unsigned multiply with a 32 bit 
; unsigned result.
; R25:R22 = (unsigned) R27:R26 * (unsigned) R19:R18.
; Corrupts R0.
#define Mult_u16_u16 __umulhisi3
;------------------------------------------------------------


;------------------------------------------------------------
; MULT_U16_U32
;------------------------------------------------------------
; 16 bit unsigned by 32 bit unsigned multiply with a 32 bit 
; unsigned result.
; R25:R22 = (unsigned) R27:R26 * (unsigned) R21:R18.
; Corrupts R0.
#define Mult_u16_u32 __muluhisi3
;------------------------------------------------------------


;------------------------------------------------------------
; MULT_S16_S32
;------------------------------------------------------------
; 16 bit signed by 32 bit unsigned multiply with a 32 bit 
; signed result.
; R25:R22 = (signed) R27:R26 * (unsigned) R21:R18.
; Corrupts R0.
#define Mult_s16_s32 __mulshisi3
;------------------------------------------------------------


;------------------------------------------------------------
; MULT_S32_S32
;------------------------------------------------------------
; 32 bit signed by 32 bit signed multiply with a 64 bit 
; signed result.
; R25:R18 = (signed) R25:R22 * (signed) R21:R18.
; Corrupts R0, R31, R30, R27, R26.
#define Mult_s32_s32 __mulsidi3
;------------------------------------------------------------


;------------------------------------------------------------
; MULT_U32_U32
;------------------------------------------------------------
; 32 bit unsigned by 32 bit unsigned multiply with a 64 bit 
; unsigned result.
; R25:R18 = (unsigned) R25:R22 * (unsigned) R21:R18.
; Corrupts R0, R31, R30, R27, R26.
#define Mult_u32_u32 __umulsidi3
;------------------------------------------------------------


;------------------------------------------------------------
; DIV_U8_U8
;------------------------------------------------------------
; 8 bit unsigned by 8 bit unsigned divide with an 8 bit 
; unsigned result and an 8 bit unsigned remainder.
; (uint8_t) R25 / (uint8_t) R24 = (uint8_t) R24 remainder 
; (uint8_t) R25.
; Corrupts R23.
#define Div_u8_u8 __udivmodqi4
;------------------------------------------------------------


;------------------------------------------------------------
; DIV_S8_S8
;------------------------------------------------------------
; 8 bit signed by 8 bit signed divide with an 8 bit 
; signed result and an 8 bit signed remainder.
; (int8_t) R25 / (int8_t) R24 = (int8_t) R24 rem (int8_t) R25.
; Corrupts R0, R22, R23.
#define Div_s8_s8 __divmodqi4
;------------------------------------------------------------


;------------------------------------------------------------
; DIV_U16_U16
;------------------------------------------------------------
; 16 bit unsigned by 16 bit unsigned divide with a 16 bit 
; unsigned result and an 16 bit unsigned remainder.
; (uint16_t) R25:R24 / (uint16_t) R23:R22 = (uint16_t) R23:R22 
; remainder (uint16_t) R27:R26.
; Corrupts R0, R22, R23.
#define Div_u16_u16 __udivmodhi4
;------------------------------------------------------------


;------------------------------------------------------------
; DIV_S16_S16
;------------------------------------------------------------
; 16 bit signed by 16 bit signed divide with a 16 bit 
; signed result and an 16 bit signed remainder.
; (int16_t) R25:R24 / (int16_t) R23:R22 = (int16_t) R23:R22 
; remainder (int16_t) R27:R26.
; Corrupts R0, R22, R23.
#define Div_s16_s16 __divmodhi4
;------------------------------------------------------------


;------------------------------------------------------------
; DIV_U32_U32
;------------------------------------------------------------
; 32 bit unsigned by 32 bit unsigned divide with a 32 bit 
; unsigned result and an 32 bit unsigned remainder.
; (uint32_t) R25:R22 / (uint32_t) R21:R18 = (uint32_t) R21:R18 
; remainder (uint32_t) R31:R30:R27:R26.
; All registers are preserved.
#define Div_u32_u32 ___udivmodsi4
;------------------------------------------------------------


;------------------------------------------------------------
; DIV_S32_S32
;------------------------------------------------------------
; 32 bit signed by 32 bit signed divide with a 32 bit 
; signed result and an 32 bit signed remainder.
; (int32_t) R25:R22 / (int32_t) R21:R18 = (int32_t) R21:R18 
; remainder (int32_t) R31:R30:R27:R26.
; All registers are preserved.
#define Div_s32_s32 __divmodsi4
;------------------------------------------------------------


;------------------------------------------------------------
; FFS_32
;------------------------------------------------------------
; Scans a 32 bit value from LSB to MSB, looking for a 1 bit.
; Returns 1+bit_number in R25:R24 if one is found, zero 
; otherwise.
; R25:R24 = FFS_32(R25:R22)
; Corrupts R22 and R26.
#define Ffs_32 __ffssi2
;------------------------------------------------------------


;------------------------------------------------------------
; FFS_16
;------------------------------------------------------------
; Scans a 16 bit value from LSB to MSB, looking for a 1 bit.
; Returns 1+bit_number in R25:R24 if one is found, zero 
; otherwise.
; R25:R24 = FFS_16(R25:R24)
; Corrupts R26.
#define Ffs_16 __ffshi2
;------------------------------------------------------------


;------------------------------------------------------------
; CLZ_16
;------------------------------------------------------------
; Counts the number of zero bits from the most significant
; bit downwards, in a 16 bit value in registers R25:R24. The
; result is returned in a 16 bit value in R25:R24. R25 will be
; zero.
; Corrupts R26.
#define Clz_16 __clzhi2
;------------------------------------------------------------


;------------------------------------------------------------
; CLZ_32
;------------------------------------------------------------
; Counts the number of zero bits from the most significant
; bit downwards, in a 32 bit value in registers R25:R22. The
; result is returned in a 16 bit value in R25:R24. R25 will be
; zero.
; Corrupts R26.
#define Clz_32 __clzsi2
;------------------------------------------------------------


;------------------------------------------------------------
; CTZ_16
;------------------------------------------------------------
; Counts the number of zero bits from the least significant
; bit upwards, in a 16 bit value in registers R25:R24. The
; result is returned in a 16 bit value in R25:R24. R25 will be
; zero.
; Corrupts R26.
#define Ctz_16 __ctzhi2
;------------------------------------------------------------


;------------------------------------------------------------
; CTZ_32
;------------------------------------------------------------
; Counts the number of zero bits from the least significant
; bit upwards, in a 32 bit value in registers R25:R22. The
; result is returned in a 16 bit value in R25:R24. R25 will be
; zero.
; Corrupts R22 and R26.
#define Ctz_32 __ctzsi2
;------------------------------------------------------------

#endif 
