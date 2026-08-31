#ifdef BH_FONT_TEST

#include <cpctelera.h>

#include "font.h"

static void test_line(u8* page, const u8* value, u8 y, u8 ink) {
   bh_font_set_colours(ink, 5);
   bh_font_draw_string(value, cpct_getScreenPtr(page, 0, y));
}

void bh_font_test_screen(void) {
   static const u8 punctuation[] = {
      BH_CHAR_INV_QUESTION, '?', ' ', BH_CHAR_INV_EXCLAMATION, '!', 0
   };
   static const u8 ntilde[] = { BH_CHAR_NTILDE, 0 };
   static const u8 euro[] = { BH_CHAR_EURO, 0 };
   u8* page = (u8*)0xC000;

   cpct_memset(page, cpct_px2byteM0(5, 5), 0x4000);
   /* 26 eight-pixel glyphs cannot fit in Mode 0's 160-pixel width, so the
    * requested alphabet specimen is continued verbatim on the next row. */
   test_line(page, "ABCDEFGHIJKLM", 4, 1);
   test_line(page, "NOPQRSTUVWXYZ", 14, 1);
   test_line(page, "0123456789", 26, 10);
   test_line(page, punctuation, 38, 13);
   test_line(page, ntilde, 50, 14);
   test_line(page, euro, 62, 14);
   test_line(page, "MUY FACIL", 74, 9);
   test_line(page, "MUY DIFICIL", 86, 9);
   test_line(page, "EL PITCH IMPOSIBLE", 98, 1);
   test_line(page, "CARGANDO...", 110, 10);
   test_line(page, "IDEAS 00/12", 122, 13);
   test_line(page, "NIVEL 10", 134, 14);
   cpct_setVideoMemoryPage(cpct_pageC0);
#ifdef BH_CAPTURE_FONT
   cpct_waitVSYNC();
   __asm
      di
   001$:
      jr 001$
   __endasm;
#endif
}

#endif
