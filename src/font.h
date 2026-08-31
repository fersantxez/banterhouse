#ifndef BANTERHOUSE_FONT_H
#define BANTERHOUSE_FONT_H

#include <types.h>

#define BH_FONT_WIDTH_PIXELS   8
#define BH_FONT_WIDTH_BYTES    4
#define BH_FONT_HEIGHT         8
#define BH_FONT_GLYPH_COUNT   97
#define BH_FONT_ASCII_FIRST 0x20
#define BH_FONT_ASCII_LAST  0x7E
#define BH_FONT_ASCII_COUNT   95
#define BH_FONT_SPECIAL_FIRST 0x80
#define BH_FONT_SPECIAL_COUNT    5
#define BH_FONT_DATA_ADDRESS  0x1B00
#define BH_FONT_DATA_SIZE        876
#define BH_FONT_WORK_ADDRESS  0x1E6C
#define BH_FONT_WORK_SIZE         38

/* Internal game encoding.  These bytes are deliberately not UTF-8 or CPC ROM
 * character codes, so strings remain deterministic after firmware is disabled. */
#define BH_CHAR_NTILDE          0x80
#define BH_CHAR_EURO            0x81
#define BH_CHAR_INV_QUESTION    0x82
#define BH_CHAR_INV_EXCLAMATION 0x83
#define BH_CHAR_NTILDE_LOWER    0x84

extern const u8 bh_font_glyphs[BH_FONT_GLYPH_COUNT][BH_FONT_HEIGHT];
extern const u8 bh_font_ascii_map[BH_FONT_ASCII_COUNT];
extern const u8 bh_font_special_map[BH_FONT_SPECIAL_COUNT];

void bh_font_set_colours(u8 ink, u8 paper) __z88dk_callee;
void bh_font_draw_char(u8* vmem, u16 character) __z88dk_callee;
void bh_font_draw_string(const u8* text, u8* vmem) __z88dk_callee;
u8 bh_font_measure(const u8* text) __z88dk_callee;
u8 bh_font_glyph_index(u16 character) __z88dk_callee;

#endif
