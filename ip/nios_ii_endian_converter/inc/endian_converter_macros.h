#include "system.h"

#define ENDIAN_SWAP_16(A) ALT_CI_NIOS_II_ENDIAN_CONVERTER_0(1,A)
#define ENDIAN_SWAP_32(A) ALT_CI_NIOS_II_ENDIAN_CONVERTER_0(0,A)
#define ENDIAN_SWAP_64(A) (((long long int) ENDIAN_SWAP_32((int)A)) << 32) | ((long long int)(ENDIAN_SWAP_32((int)(A>>32))))
