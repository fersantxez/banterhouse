#ifndef BANTERHOUSE_INPUT_H
#define BANTERHOUSE_INPUT_H

#include "bh_types.h"

typedef enum {
   BH_INPUT_UP     = 0x01,
   BH_INPUT_DOWN   = 0x02,
   BH_INPUT_LEFT   = 0x04,
   BH_INPUT_RIGHT  = 0x08,
   BH_INPUT_ACTION = 0x10,
   BH_INPUT_PAUSE  = 0x20
} BHInputBits;

u8 bh_input_scan(void);

#endif
