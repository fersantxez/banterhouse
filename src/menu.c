#include <cpctelera.h>

#include "main.h"
#include "graphics.h"
#include "game.h"
#include "audio.h"
#include "font.h"

#ifdef __SDCC
#pragma constseg BH_GFX
#endif

BHDifficulty bh_difficulty;

static const u8* const difficulty_names[BH_DIFFICULTY_COUNT] = {
   "MUY FACIL", "FACIL", "NORMAL", "DIFICIL", "MUY DIFICIL"
};

static u8 key_down(u8 row, u8 bit) {
   return (cpct_keyboardStatusBuffer[row] & bit) == 0;
}

static void draw_text(u8* page, const u8* value, u8 x, u8 y, u8 ink, u8 paper) {
   bh_font_set_colours(ink, paper);
   bh_font_draw_string(value, cpct_getScreenPtr(page, x, y));
}

void bh_menu(void) {
   u8 changed;
   u8* page = (u8*)CPCT_VMEM_START;

   cpct_memset(page, cpct_px2byteM0(5, 5), 0x4000);
   cpct_drawSprite(g_logo, cpct_getScreenPtr(page, (80 - G_LOGO_W) / 2, 34), G_LOGO_W, G_LOGO_H);
   draw_text(page, "EL PITCH IMPOSIBLE", 4, 86, 1, 5);
   draw_text(page, "O/P: DIFICULTAD", 8, 118, 10, 5);
   draw_text(page, "S O FUEGO: EMPEZAR", 2, 142, 13, 5);
   draw_text(page, difficulty_names[bh_difficulty], 18, 128, 9, 5);
   cpct_setVideoMemoryPage(cpct_pageC0);
   /* Start only after the expensive first draw, immediately before 50 Hz play. */
   bh_audio_scene(BH_AUDIO_MENU);

#ifdef BH_CAPTURE_MENU
   cpct_waitVSYNC();
   __asm
      di
   001$:
      jr 001$
   __endasm;
#endif

#ifdef BH_AUTOTEST
   return;
#endif

   /* AMSDOS' RUN command may still be releasing O/P/Return as the menu
    * appears.  Debounce at PAL rate so those loader keys neither alter the
    * difficulty nor freeze Arkos before its first audible row. */
   do {
      cpct_waitVSYNC();
      bh_audio_tick();
      cpct_scanKeyboard();
   } while (cpct_isAnyKeyPressed());

   while (1) {
      cpct_waitVSYNC();
      bh_audio_tick();
      changed = 0;
      cpct_scanKeyboard();
      if (key_down(4, 0x04) || key_down(1, 0x01)) {
         if (bh_difficulty == BH_VERY_EASY) bh_difficulty = BH_VERY_HARD;
         else --bh_difficulty;
         changed = 1;
      }
      if (key_down(3, 0x08) || key_down(0, 0x02)) {
         ++bh_difficulty;
         if (bh_difficulty == BH_DIFFICULTY_COUNT) bh_difficulty = BH_VERY_EASY;
         changed = 1;
      }
      if (changed) {
         cpct_drawSolidBox(cpct_getScreenPtr(page, 18, 128), cpct_px2byteM0(5, 5), 44, 8);
         draw_text(page, difficulty_names[bh_difficulty], 18, 128, 9, 5);
         do {
            cpct_waitVSYNC();
            bh_audio_tick();
            cpct_scanKeyboard();
         } while (cpct_isAnyKeyPressed());
      }
      if (key_down(7, 0x10) || key_down(5, 0x80) || key_down(9, 0x10))
         return;
   }
}
