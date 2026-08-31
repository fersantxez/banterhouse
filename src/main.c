#include <cpctelera.h>

#include "main.h"
#include "game.h"
#include "audio.h"
#include "font_test.h"

/* Pen 4 is the dark olive-green shadow from Pitu's canonical artwork. */
const u8 bh_palette[16] = {
   HW_BLACK, HW_BRIGHT_WHITE, HW_SKY_BLUE, HW_BRIGHT_CYAN,
   HW_GREEN, HW_WHITE, HW_BRIGHT_GREEN, HW_PASTEL_GREEN,
   HW_PASTEL_YELLOW, HW_RED, HW_PURPLE, HW_PASTEL_MAGENTA,
   HW_ORANGE, HW_PINK, HW_YELLOW, HW_BLUE
};

void main(void) {
#ifdef BH_AUDIO_LIFECYCLE_TEST
   u16 frame;
   u8 effect;
#endif
   cpct_setStackLocation((u8*)0x7FFF);
   cpct_disableFirmware();
   cpct_setVideoMode(0);
   cpct_setPalette(bh_palette, 16);
   /* Explicit runtime initialization: this project deliberately has no CRT. */
   bh_difficulty = BH_NORMAL;
   bh_audio_init();

#ifdef BH_AUDIO_LIFECYCLE_TEST
   bh_audio_scene(BH_AUDIO_MENU);
   /* 2688 frames are one complete 14-pattern first pass.  Extra frames prove
    * that the pattern-13 cuts return cleanly to loop pattern 2. */
   for (frame = 0; frame < 2750; ++frame) {
      cpct_waitVSYNC();
      bh_audio_tick();
   }
   /* Audible event reel: every dedicated SFX, then a high/low priority
    * collision.  The theme must recover channel C after each effect. */
   for (effect = 0; effect < BH_SFX_COUNT; ++effect) {
      bh_audio_sfx((BHSfx)effect);
      for (frame = 0; frame < 35; ++frame) {
         cpct_waitVSYNC();
         bh_audio_tick();
      }
   }
   bh_audio_sfx(BH_SFX_SCREEN);
   bh_audio_sfx(BH_SFX_CONTACT);
   bh_audio_sfx(BH_SFX_SCREEN);
   for (frame = 0; frame < 50; ++frame) {
      cpct_waitVSYNC();
      bh_audio_tick();
   }
   bh_audio_pause(1);
   for (frame = 0; frame < 50; ++frame) cpct_waitVSYNC();
   bh_audio_pause(0);
   for (frame = 0; frame < 200; ++frame) {
      cpct_waitVSYNC();
      bh_audio_tick();
   }
   bh_audio_stop();
   __asm
      ; Caprice32 printer capture: BH_PASS followed by LF (bit 7 inverted).
      ld bc, #0xEF00
      ld a, #0xC2
      out (c), a
      ld a, #0xC8
      out (c), a
      ld a, #0xDF
      out (c), a
      ld a, #0xD0
      out (c), a
      ld a, #0xC1
      out (c), a
      ld a, #0xD3
      out (c), a
      out (c), a
      ld a, #0x8A
      out (c), a
      di
   001$:
      halt
      jr 001$
   __endasm;
#elif defined(BH_FONT_TEST)
   bh_font_test_screen();
   while (1) {
      cpct_waitVSYNC();
      bh_audio_tick();
   }
#else
   while (1) {
      bh_menu();
      bh_game();
   }
#endif
}
