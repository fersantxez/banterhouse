#include "difficulty.h"

#ifdef __SDCC
#pragma constseg BH_GFX
#endif

const BHProfile bh_profiles[BH_DIFFICULTY_COUNT] = {
   { 0x55, 16, 32, 75, 0, 5, 5, 100 },
   { 0x6D, 20, 28, 65, 1, 4, 4,  85 },
   { 0x77, 24, 24, 55, 2, 3, 3,  70 },
   { 0xF7, 28, 20, 48, 3, 3, 2,  60 },
   { 0xFF, 32, 18, 40, 3, 2, 2,  50 }
};
