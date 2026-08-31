#include <cpctelera.h>

#include "input.h"

static u8 key_down(u8 row, u8 bit) {
   return (cpct_keyboardStatusBuffer[row] & bit) == 0;
}

u8 bh_input_scan(void) {
   u8 input = 0;

   cpct_scanKeyboard();
   if (key_down(0, 0x01) || key_down(8, 0x08) || key_down(9, 0x01)) input |= BH_INPUT_UP;
   if (key_down(0, 0x04) || key_down(8, 0x20) || key_down(9, 0x02)) input |= BH_INPUT_DOWN;
   if (key_down(1, 0x01) || key_down(4, 0x04) || key_down(9, 0x04)) input |= BH_INPUT_LEFT;
   if (key_down(0, 0x02) || key_down(3, 0x08) || key_down(9, 0x08)) input |= BH_INPUT_RIGHT;
   if (key_down(5, 0x80) || key_down(9, 0x10)) input |= BH_INPUT_ACTION;
   if (key_down(8, 0x04)) input |= BH_INPUT_PAUSE;

   return input;
}
