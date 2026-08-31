#include <cpctelera.h>

#include "main.h"
#include "graphics.h"
#include "game.h"
#include "audio.h"
#include "font.h"

#define BH_NONE             255
#define BH_ENTRY_GRACE       45
#define BH_PHONE_X           12
#define BH_PHONE_Y          118
#define BH_COFFEE_X          62
#define BH_COFFEE_Y          42
#define BH_IDEA_X            37
#define BH_IDEA_Y           106
#define BH_TRAY_X            38
#define BH_TRAY_Y           112

typedef struct {
   u8 ai_mask;
   u8 vision;
   u8 warning;
   u8 cooldown;
   u8 follow_rooms;
   u8 carga_limit;
   u8 cafes;
   u8 boss_window;
} BHProfile;

static const BHProfile profiles[BH_DIFFICULTY_COUNT] = {
   { 0x55, 16, 32, 75, 0, 5, 5, 100 },
   { 0x6D, 20, 28, 65, 1, 4, 4,  85 },
   { 0x77, 24, 24, 55, 2, 3, 3,  70 },
   { 0xF7, 28, 20, 48, 3, 3, 2,  60 },
   { 0xFF, 32, 18, 40, 3, 2, 2,  50 }
};

static const u8* const level_names[BH_LEVELS] = {
   "TODO CLARISIMO", "UNA PALABRA MENOS", "ROJO DISCRETO",
   "FINAL BUENO", "REUNION PREVIA", "PREMIO A NOSOTROS",
   "PARA AYER", "EL RANKING", "DEFINITIVA 12", "EL CONSEJO"
};

static const u8 small_label[] = {
   'P', 'E', 'Q', 'U', 'E', BH_CHAR_NTILDE, 'O', 0
};

static const u8 boss_x[4] = { 10, 29, 49, 67 };
static const u8 boss_y[4] = { 43, 84, 43, 84 };

static u8 level;
static u8 room;
static u8 pitu_x;
static u8 pitu_y;
static u8 pitu_left;
static u8 pitu_walking;
static u8 alberto_x;
static u8 alberto_y;
static u8 alberto_left;
static u8 alberto_active;
static u8 ai_clock;
static u8 entry_grace;
static u8 warning_ticks;
static u8 cooldown_ticks;
static u8 noise_ticks;
static u8 carga;
static u8 cafes;
static u8 coffee_available;
static u8 projectile_active;
static u8 projectile_x;
static u8 projectile_y;
static i8 projectile_dx;
static i8 projectile_dy;
static u8 action_was_down;
static u8 esc_was_down;
static u8 paused;
static u8 game_over;
static u8 game_won;
static u8 boss_phase;
static u8 boss_progress;
static u8 boss_phone;
static u8 boss_timer;
static u16 pieces;
static u16 score;
static u16 ticks;
static u8 message_timer;
static const u8* message;

#ifdef BH_AUTOTEST
/* The release never defines this.  It drives the ordinary state machine,
 * providing a deterministic, unattended campaign regression on real Z80. */
#ifndef BH_AUTOTEST_DIFFICULTY
#define BH_AUTOTEST_DIFFICULTY BH_NORMAL
#endif
static u8 autotest_delay;
volatile u8 bh_autotest_result;
static void autotest_input(void);
#endif

static u8 key_down(u8 row, u8 bit) {
   return (cpct_keyboardStatusBuffer[row] & bit) == 0;
}

static u8 abs_diff(u8 a, u8 b) {
   return a > b ? a - b : b - a;
}

static void box(u8* page, u8 x, u8 y, u8 w, u8 h, u8 colour) {
   cpct_drawSolidBox(cpct_getScreenPtr(page, x, y), cpct_px2byteM0(colour, colour), w, h);
}

static void text(u8* page, const u8* value, u8 x, u8 y, u8 ink, u8 paper) {
   bh_font_set_colours(ink, paper);
   bh_font_draw_string(value, cpct_getScreenPtr(page, x, y));
}

static void centred_text(u8* page, const u8* value, u8 y, u8 ink, u8 paper) {
   u8 width = bh_font_measure(value);
   text(page, value, (BH_SCREEN_W - width) >> 1, y, ink, paper);
}

static void number2(u8* out, u8 value) {
   out[0] = '0';
   while (value >= 10) {
      ++out[0];
      value -= 10;
   }
   out[1] = '0' + value;
}

static u8 count_pieces(void) {
   u8 i;
   u8 count = 0;
   u16 mask = 1;
   for (i = 0; i < 12; ++i) {
      if (pieces & mask) ++count;
      mask <<= 1;
   }
   return count;
}

static u8 pickup_id(void) {
   if (level == 0) {
      if (room < 2) return room;
      return BH_NONE;
   }
   if (level < 9) {
      if (room == 1) return level + 1;
      return BH_NONE;
   }
   return BH_NONE;
}

static u8 level_ready(void) {
   u16 required;
   if (level == 0) return (pieces & 3) == 3;
   if (level < 9) {
      required = ((u16)1) << (level + 1);
      return (pieces & required) != 0;
   }
   return 0;
}

static u8 near(u8 x, u8 y, u8 tx, u8 ty, u8 radius_x, u8 radius_y) {
   return abs_diff(x, tx) <= radius_x && abs_diff(y, ty) <= radius_y;
}

/* All decoration that looks solid is solid.  The outer aisles deliberately
 * remain clear so every room has a readable, always-solvable route. */
static u8 hits_box(u8 x, u8 y, u8 bx, u8 by, u8 bw, u8 bh) {
   return x + BH_PLAYER_W > bx && x < bx + bw &&
          y + BH_PLAYER_H > by && y < by + bh;
}

static u8 blocked(u8 x, u8 y) {
   u8 variant = (level + room) & 3;
   /* One pixel beyond each horizontal edge is a door trigger. */
   if (x > BH_MAX_X + 1 || y < BH_PLAY_TOP || y > BH_PLAY_BOTTOM - BH_PLAYER_H)
      return 1;
   if (level == 9) return 0;
   if (hits_box(x, y, 10 + (variant << 2), 36, 15, 10)) return 1;
   if (hits_box(x, y, 45 - (variant << 1), 72, 18, 9)) return 1;
   if (hits_box(x, y, 18 + (variant << 1), 140, 12, 9)) return 1;
   return 0;
}

static void set_message(const u8* new_message, u8 duration) {
   message = new_message;
   message_timer = duration;
}

static void reset_room(void) {
   pitu_x = 4;
   pitu_y = 122;
   pitu_left = 0;
   pitu_walking = 0;
   alberto_x = 64;
   alberto_y = 42 + (room << 4);
   alberto_left = 1;
   alberto_active = level == 0 && room == 0 ? 0 : 1;
   ai_clock = 0;
   entry_grace = BH_ENTRY_GRACE;
   warning_ticks = 0;
   cooldown_ticks = 0;
   noise_ticks = 0;
   projectile_active = 0;
   coffee_available = 1;
   if (level == 9) {
      room = 0;
      pitu_x = 6;
      pitu_y = 126;
      alberto_x = 66;
      alberto_y = 42;
      alberto_active = 1;
   }
}

static void begin_level(void) {
   room = 0;
   coffee_available = 1;
   if (level == 9) {
      bh_audio_scene(BH_AUDIO_BOSS);
      boss_phase = 1;
      boss_progress = 0;
      boss_phone = 0;
      boss_timer = profiles[bh_difficulty].boss_window;
      set_message("PRESIDENTE ESPERA", 100);
   } else {
      set_message(level_names[level], 80);
   }
   reset_room();
}

static void reset_game(void) {
#define BH_SPRITE_BYTES (16 * 32)
   cpct_memcpy(g_pitu_rev, g_pitu, BH_SPRITE_BYTES);
   cpct_hflipSpriteMaskedM0(G_PITU_W, G_PITU_H, g_pitu_rev);
   cpct_memcpy(g_pitu_walk_rev, g_pitu_walk, BH_SPRITE_BYTES);
   cpct_hflipSpriteMaskedM0(G_PITU_WALK_W, G_PITU_WALK_H, g_pitu_walk_rev);
   cpct_memcpy(g_alberto_rev, g_alberto, BH_SPRITE_BYTES);
   cpct_hflipSpriteMaskedM0(G_ALBERTO_W, G_ALBERTO_H, g_alberto_rev);
   cpct_memcpy(g_alberto_walk_rev, g_alberto_walk, BH_SPRITE_BYTES);
   cpct_hflipSpriteMaskedM0(G_ALBERTO_WALK_W, G_ALBERTO_WALK_H, g_alberto_walk_rev);
#undef BH_SPRITE_BYTES
#ifdef BH_AUTOTEST
   bh_difficulty = BH_AUTOTEST_DIFFICULTY;
   autotest_delay = 75;
   bh_autotest_result = 0;
#endif
   level = 0;
   pieces = 0;
   score = 0;
   ticks = 0;
   carga = 0;
   cafes = profiles[bh_difficulty].cafes;
   paused = 0;
   game_over = 0;
   game_won = 0;
   action_was_down = 0;
   esc_was_down = 0;
   begin_level();
}

static void draw_hud(u8* page) {
   u8 line[18];
   u8 count = count_pieces();

   box(page, 0, 0, BH_SCREEN_W, BH_HUD_H, 0);
   line[0] = 'L'; number2(&line[1], level + 1);
   line[3] = 'R'; line[4] = '0' + room + 1;
   line[5] = ' '; line[6] = 'I'; number2(&line[7], count);
   line[9] = '/'; line[10] = '1'; line[11] = '2'; line[12] = 0;
   text(page, line, 0, 4, 5, 0);
   line[0] = 'C'; line[1] = '0' + carga; line[2] = '/'; line[3] = '0' + profiles[bh_difficulty].carga_limit;
   line[4] = ' '; line[5] = 'F'; line[6] = '0' + cafes; line[7] = 0;
   text(page, line, 52, 4, 8, 0);
}

/* Each creative pickup is a small, readable CPC icon rather than a generic
 * block.  The shapes deliberately differ as well as their colours so they
 * remain identifiable on monochrome displays and composite video. */
static void draw_idea_icon(u8* page, u8 id) {
   u8 x = BH_IDEA_X;
   u8 y = BH_IDEA_Y - ((ticks >> 4) & 1);
   u8 ink = 14;

   while (id >= 6) id -= 6;

   box(page, x, y + 10, 5, 2, 0);  /* common floating shadow */
   switch (id) {
      case 0:                       /* light bulb */
         box(page, x + 1, y,     3, 5, 14);
         box(page, x,     y + 1, 5, 3, 14);
         box(page, x + 2, y + 5, 1, 3, 1);
         box(page, x + 1, y + 8, 3, 1, 8);
         break;
      case 1:                       /* pencil */
         box(page, x,     y + 7, 1, 2, 1);
         box(page, x + 1, y + 5, 1, 2, 9);
         box(page, x + 2, y + 3, 1, 2, 14);
         box(page, x + 3, y + 1, 1, 2, 9);
         box(page, x + 4, y,     1, 2, 1);
         break;
      case 2:                       /* creative spark */
         ink = 10;
         box(page, x + 2, y,     1, 9, ink);
         box(page, x,     y + 4, 5, 1, ink);
         box(page, x + 1, y + 2, 3, 5, ink);
         box(page, x + 2, y + 3, 1, 3, 5);
         break;
      case 3:                       /* speech bubble */
         ink = 13;
         box(page, x,     y + 1, 5, 6, ink);
         box(page, x + 1, y + 2, 3, 3, 5);
         box(page, x + 1, y + 7, 1, 2, ink);
         break;
      case 4:                       /* eye / insight */
         ink = 12;
         box(page, x,     y + 3, 5, 4, ink);
         box(page, x + 1, y + 2, 3, 6, ink);
         box(page, x + 2, y + 3, 1, 4, 0);
         break;
      default:                      /* mini colour palette */
         box(page, x,     y + 1, 5, 7, 1);
         box(page, x + 1, y + 2, 1, 2, 9);
         box(page, x + 3, y + 2, 1, 2, 10);
         box(page, x + 1, y + 5, 1, 2, 14);
         box(page, x + 3, y + 5, 1, 2, 13);
         box(page, x + 4, y + 7, 1, 2, 5);
         break;
   }

   /* One blinking pixel gives every icon the arcade "collect me" signal. */
   if (ticks & 8) box(page, x + 6, y + 1, 1, 2, ink);
}

static void draw_office(u8* page) {
   u8 variant = (level + room) & 3;
   u8 piece = pickup_id();
   u16 bit;

   cpct_memset(page, cpct_px2byteM0(5, 5), 0x4000);
   draw_hud(page);
   box(page, 0, BH_HUD_H, BH_SCREEN_W, 2, 0);
   box(page, 0, 18, 2, 160, 0);
   box(page, 78, 18, 2, 160, 0);
   box(page, 0, 176, BH_SCREEN_W, 2, 0);

   /* Furniture varies every room while preserving clear routes along the edges. */
   box(page, 10 + (variant << 2), 36, 15, 7, 1);
   box(page, 12 + (variant << 2), 43, 11, 3, 8);
   box(page, 45 - (variant << 1), 72, 18, 6, 1);
   box(page, 47 - (variant << 1), 78, 14, 3, 10);
   box(page, 18 + (variant << 1), 140, 12, 6, 1);
   box(page, 20 + (variant << 1), 146, 8, 3, 7);
   box(page, 70, 82, 6, 30, 2);
   box(page, 4, 82, 4, 30, room ? 2 : 1);
   text(page, level_names[level], 5, 22, 1, 5);

   /* Phone creates a deterministic distraction; coffee removes one Carga. */
   box(page, BH_PHONE_X, BH_PHONE_Y, 5, 6, 10);
   box(page, BH_PHONE_X + 1, BH_PHONE_Y + 2, 3, 2, 0);
   text(page, "TEL", BH_PHONE_X - 1, BH_PHONE_Y + 7, 10, 5);
   if (coffee_available) {
      box(page, BH_COFFEE_X, BH_COFFEE_Y, 4, 7, 9);
      text(page, "CAFE", BH_COFFEE_X - 2, BH_COFFEE_Y + 8, 9, 5);
   }

   if (piece != BH_NONE) {
      bit = ((u16)1) << piece;
      if (!(pieces & bit)) {
         draw_idea_icon(page, piece);
      }
   }
   if (room == 2 && level < 9) text(page, level_ready() ? "SALIDA" : "FALTA IDEA", 39, 116, 6, 5);
}

static void draw_boss(u8* page) {
   u8 target_x;
   u8 target_y;
   u8 label[20];

   cpct_memset(page, cpct_px2byteM0(5, 5), 0x4000);
   draw_hud(page);
   box(page, 0, BH_HUD_H, BH_SCREEN_W, 2, 0);
   box(page, 2, 18, 76, 160, 0);
   box(page, 8, 27, 64, 26, 1);
   box(page, 18, 32, 44, 18, 8);
   text(page, "EL PRESIDENTE", 23, 36, 0, 8);
   text(page, "APROBADO [ ][ ][ ]", 4, 56, 1, 5);
   box(page, 9, 132, 62, 17, 1);
   box(page, BH_PHONE_X, BH_PHONE_Y, 5, 6, 10);
   text(page, "FAX", BH_PHONE_X - 1, BH_PHONE_Y + 7, 10, 5);
   box(page, BH_TRAY_X, BH_TRAY_Y, 9, 7, 9);
   text(page, "BANDEJA", BH_TRAY_X - 2, BH_TRAY_Y + 8, 9, 5);

   label[0] = 'F'; label[1] = 'A'; label[2] = 'S'; label[3] = 'E'; label[4] = ' '; label[5] = '0' + boss_phase; label[6] = 0;
   text(page, label, 4, 22, 1, 5);

   if (boss_phase == 1) {
      target_x = boss_x[boss_progress]; target_y = boss_y[boss_progress];
      box(page, target_x, target_y, 6, 8, 14);
      text(page, "PANEL", target_x < 54 ? target_x : 54, target_y + 9, 14, 5);
   } else if (boss_phase == 2) {
      target_x = boss_progress ? 58 : 16; target_y = boss_progress ? 86 : 82;
      box(page, target_x, target_y, 7, 8, 12);
      text(page, boss_progress ? small_label : "GRANDE", boss_progress ? 45 : 13, target_y + 9, 12, 5);
   } else if (!boss_phone) {
      text(page, "USA EL FAX", 27, 104, 10, 5);
   } else if (boss_timer) {
      text(page, "ALBERTO LANZA", 22, 104, 9, 5);
   } else {
      text(page, "ENTREGA ORIGINAL", 8, 104, 14, 5);
      box(page, BH_TRAY_X + 2, BH_TRAY_Y - 11, 5, 8, 14);
   }
}

static void draw_entities(u8* page) {
   const u8* pitu = pitu_walking
      ? (pitu_left ? g_pitu_walk_rev : g_pitu_walk)
      : (pitu_left ? g_pitu_rev : g_pitu);
   const u8* alberto = (ai_clock & 8)
      ? (alberto_left ? g_alberto_walk_rev : g_alberto_walk)
      : (alberto_left ? g_alberto_rev : g_alberto);
   cpct_drawSpriteMasked((u8*)pitu, cpct_getScreenPtr(page, pitu_x, pitu_y), G_PITU_W, G_PITU_H);
   if (alberto_active) cpct_drawSpriteMasked((u8*)alberto, cpct_getScreenPtr(page, alberto_x, alberto_y), G_ALBERTO_W, G_ALBERTO_H);
   if (projectile_active) box(page, projectile_x, projectile_y, 2, 4, 9);
   if (message_timer) text(page, message, 4, 184, 1, 5);
   if (paused) text(page, "PAUSA ESC", 22, 160, 0, 14);
}

static void draw_frame(u8* page) {
   if (level == 9) draw_boss(page);
   else draw_office(page);
   draw_entities(page);
}

static void draw_result(const u8* title, const u8* subtitle, const u8* subtitle2) {
   u8* page = (u8*)CPCT_VMEM_START;
   cpct_memset(page, cpct_px2byteM0(5, 5), 0x4000);
   cpct_drawSprite(g_logo, cpct_getScreenPtr(page, (80 - G_LOGO_W) / 2, 32), G_LOGO_W, G_LOGO_H);
   centred_text(page, title, 105, 0, 5);
   centred_text(page, subtitle, 124, 10, 5);
   if (subtitle2) centred_text(page, subtitle2, 136, 10, 5);
   centred_text(page, "PULSA S", 154, 13, 5);
   cpct_setVideoMemoryPage(cpct_pageC0);
#ifdef BH_CAPTURE_RESULT
   cpct_waitVSYNC();
   bh_audio_tick();
   __asm
      di
   003$:
      jr 003$
   __endasm;
#elif defined(BH_AUTOTEST)
   /* The host regression waits for a printer-port success record, which is
    * emitted only after the ordinary ten-level state machine reaches victory. */
   cpct_waitVSYNC();
   bh_audio_tick();
   __asm
      ; Caprice32 captures printer bytes with bit 7 inverted.  This writes
      ; BH_PASS followed by LF, only after all ten levels and the boss succeed.
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
#else
   do { cpct_scanKeyboard(); } while (cpct_isAnyKeyPressed());
   while (1) {
      cpct_waitVSYNC();
      bh_audio_tick();
      cpct_scanKeyboard();
      if (key_down(7, 0x10) || key_down(5, 0x80) || key_down(9, 0x10)) {
         bh_audio_stop();
         return;
      }
   }
#endif
}

static void burnout(void) {
   if (cafes) {
      --cafes;
      carga = 0;
      set_message("BURNOUT: REINTENTO", 100);
      reset_room();
   } else {
      game_over = 1;
   }
}

static void player_hit(void) {
   if (entry_grace) return;
   projectile_active = 0;
   bh_audio_sfx(BH_SFX_CONTACT);
   ++carga;
   set_message("BRIEFING RECIBIDO", 70);
   if (carga >= profiles[bh_difficulty].carga_limit) burnout();
}

static void launch_briefing(void) {
   projectile_active = 1;
   projectile_x = alberto_x;
   projectile_y = alberto_y + 12;
   projectile_dx = 0;
   projectile_dy = 0;
   if (abs_diff(pitu_x, alberto_x) > abs_diff(pitu_y, alberto_y)) {
      projectile_dx = pitu_x > alberto_x ? 1 : -1;
   } else {
      projectile_dy = pitu_y > alberto_y ? 1 : -1;
   }
   cooldown_ticks = profiles[bh_difficulty].cooldown;
   bh_audio_sfx(BH_SFX_SHOT);
   set_message("VIENE UN BRIEFING", 40);
}

static void update_projectile(void) {
   if (!projectile_active) return;
   if (projectile_dx > 0) projectile_x += 2;
   else if (projectile_dx < 0) projectile_x -= 2;
   if (projectile_dy > 0) projectile_y += 4;
   else if (projectile_dy < 0) projectile_y -= 4;
   if (projectile_x > BH_MAX_X || projectile_y < BH_PLAY_TOP || projectile_y > BH_PLAY_BOTTOM) {
      projectile_active = 0;
      return;
   }
   if (near(pitu_x, pitu_y + 12, projectile_x, projectile_y, 6, 15)) player_hit();
}

static void move_alberto_toward(u8 target_x, u8 target_y) {
   if (!(profiles[bh_difficulty].ai_mask & (((u8)1) << (ai_clock & 7)))) return;
   if (alberto_x < target_x) { ++alberto_x; alberto_left = 0; }
   else if (alberto_x > target_x) { --alberto_x; alberto_left = 1; }
   else if (alberto_y < target_y) alberto_y += 2;
   else if (alberto_y > target_y) alberto_y -= 2;
}

static void update_alberto(void) {
   u8 aligned;
   u8 target_x = pitu_x;
   u8 target_y = pitu_y;

#ifdef BH_AUTOTEST
   if (autotest_delay) return;
#endif

   ++ai_clock;
   if (entry_grace) {
      --entry_grace;
      return;
   }
   if (noise_ticks) {
      --noise_ticks;
      target_x = BH_PHONE_X;
      target_y = BH_PHONE_Y;
   }
   if (!alberto_active) {
      if (ticks > 90) alberto_active = 1;
      else return;
   }
   move_alberto_toward(target_x, target_y);
   if (cooldown_ticks) --cooldown_ticks;
   if (warning_ticks) {
      --warning_ticks;
      if (!warning_ticks) launch_briefing();
   } else if (!cooldown_ticks && !projectile_active) {
      aligned = (abs_diff(pitu_x, alberto_x) < 5) || (abs_diff(pitu_y, alberto_y) < 10);
      if (aligned && abs_diff(pitu_x, alberto_x) + (abs_diff(pitu_y, alberto_y) >> 1) < profiles[bh_difficulty].vision)
      {
         warning_ticks = profiles[bh_difficulty].warning;
         bh_audio_sfx(BH_SFX_ALERT);
      }
   }
   update_projectile();
}

static void collect_piece(void) {
   u8 id = pickup_id();
   if (id == BH_NONE) return;
   if (!(pieces & (((u16)1) << id)) && near(pitu_x, pitu_y, BH_IDEA_X, BH_IDEA_Y, 7, 14)) {
      pieces |= ((u16)1) << id;
      score += 100;
      bh_audio_sfx(BH_SFX_PICKUP);
      set_message("IDEA RECUPERADA", 80);
   }
}

static void boss_action(void) {
   u8 tx;
   u8 ty;
   if (boss_phase == 1) {
      tx = boss_x[boss_progress]; ty = boss_y[boss_progress];
      if (near(pitu_x, pitu_y, tx, ty, 7, 14)) {
         ++boss_progress;
         bh_audio_sfx(BH_SFX_PICKUP);
         set_message("PANEL ACTIVADO", 50);
         if (boss_progress == 4) {
            pieces |= ((u16)1) << 10;
            boss_phase = 2;
            boss_progress = 0;
            boss_timer = profiles[bh_difficulty].boss_window;
            set_message("SELLO 1: EL PITCH", 80);
         }
      }
   } else if (boss_phase == 2) {
      tx = boss_progress ? 58 : 16; ty = boss_progress ? 86 : 82;
      if (near(pitu_x, pitu_y, tx, ty, 8, 14)) {
         ++boss_progress;
         bh_audio_sfx(BH_SFX_PICKUP);
         if (boss_progress == 2) {
            pieces |= ((u16)1) << 11;
            boss_phase = 3;
            boss_progress = 0;
            boss_phone = 0;
            set_message("SELLO 2: CAMBIO", 80);
         }
      }
   } else if (!boss_phone && near(pitu_x, pitu_y, BH_PHONE_X, BH_PHONE_Y, 8, 14)) {
      boss_phone = 1;
      boss_timer = 48;
      noise_ticks = 80;
      bh_audio_sfx(BH_SFX_ALERT);
      set_message("FAX: ALBERTO VIENE", 70);
   } else if (boss_phone && !boss_timer && near(pitu_x, pitu_y, BH_TRAY_X, BH_TRAY_Y, 10, 14)) {
      game_won = 1;
   }
}

static void interact(void) {
   if (level == 9) {
      boss_action();
      return;
   }
   if (coffee_available && near(pitu_x, pitu_y, BH_COFFEE_X, BH_COFFEE_Y, 8, 14)) {
      coffee_available = 0;
      if (carga) --carga;
      bh_audio_sfx(BH_SFX_ACTION);
      set_message("CAFE: CARGA -1", 70);
   } else if (near(pitu_x, pitu_y, BH_PHONE_X, BH_PHONE_Y, 8, 14)) {
      noise_ticks = 100;
      bh_audio_sfx(BH_SFX_ACTION);
      set_message("ALBERTO AL TEL", 70);
   }
}

static void room_edge(void) {
   if (level == 9) {
      if (pitu_x < 2) pitu_x = 2;
      if (pitu_x > BH_MAX_X - 2) pitu_x = BH_MAX_X - 2;
      return;
   }
   if (pitu_x == 0) {
      if (room) {
         --room;
         reset_room();
         pitu_x = BH_MAX_X - 2;
         bh_audio_sfx(BH_SFX_SCREEN);
      } else pitu_x = 1;
   } else if (pitu_x >= BH_MAX_X) {
      if (room < 2) {
         ++room;
         reset_room();
         bh_audio_sfx(BH_SFX_SCREEN);
      } else if (level_ready()) {
         ++level;
         if (level == BH_LEVELS) {
            game_won = 1;
         } else {
            begin_level();
            bh_audio_sfx(BH_SFX_SCREEN);
         }
      } else {
         pitu_x = BH_MAX_X - 2;
         set_message("FALTA UNA IDEA", 70);
      }
   }
}

static void update_input(void) {
   u8 action;
   u8 esc;
   pitu_walking = 0;
#ifdef BH_AUTOTEST
   if (autotest_delay) {
      --autotest_delay;
      return;
   }
   autotest_input();
   return;
#endif
   cpct_scanKeyboard();
   esc = key_down(8, 0x04);
   if (esc && !esc_was_down) {
      paused = !paused;
      bh_audio_pause(paused);
   }
   esc_was_down = esc;
   if (paused) return;

   if (key_down(0, 0x01) || key_down(8, 0x08) || key_down(9, 0x01)) {
      if (!blocked(pitu_x, pitu_y - 2)) pitu_y -= 2;
      pitu_walking = 1;
   }
   if (key_down(0, 0x04) || key_down(8, 0x20) || key_down(9, 0x02)) {
      if (!blocked(pitu_x, pitu_y + 2)) pitu_y += 2;
      pitu_walking = 1;
   }
   if (key_down(1, 0x01) || key_down(4, 0x04) || key_down(9, 0x04)) {
      if (!blocked(pitu_x - 1, pitu_y)) --pitu_x;
      pitu_left = 1;
      pitu_walking = 1;
   }
   if (key_down(0, 0x02) || key_down(3, 0x08) || key_down(9, 0x08)) {
      if (!blocked(pitu_x + 1, pitu_y)) ++pitu_x;
      pitu_left = 0;
      pitu_walking = 1;
   }
   action = key_down(5, 0x80) || key_down(9, 0x10);
   if (action && !action_was_down) interact();
   action_was_down = action;
   room_edge();
}

#ifdef BH_AUTOTEST
static void autotest_input(void) {
   u8 id;

   /* Objectives and exits are reached through exactly the same pickup,
    * transition and boss functions used by a player.  Direct placement keeps
    * the regression fast while collision itself is separately guarded here. */
   if (level < 9) {
      id = pickup_id();
      if (id != BH_NONE && !(pieces & (((u16)1) << id))) {
         pitu_x = BH_IDEA_X;
         pitu_y = BH_IDEA_Y;
      } else {
         pitu_x = BH_MAX_X;
         room_edge();
      }
      return;
   }

   if (boss_phase == 1) {
      pitu_x = boss_x[boss_progress];
      pitu_y = boss_y[boss_progress];
      boss_action();
   } else if (boss_phase == 2) {
      pitu_x = boss_progress ? 58 : 16;
      pitu_y = boss_progress ? 86 : 82;
      boss_action();
   } else if (!boss_phone) {
      pitu_x = BH_PHONE_X;
      pitu_y = BH_PHONE_Y;
      boss_action();
   } else if (!boss_timer) {
      pitu_x = BH_TRAY_X;
      pitu_y = BH_TRAY_Y;
      boss_action();
   }
}
#endif

void bh_game(void) {
   u8 use_lower = 0;
   u8* page;
   u8 page_id;

   bh_audio_scene(BH_AUDIO_GAME);
   reset_game();
#ifdef BH_AUTOTEST_DEFEAT
   /* Reach defeat through the ordinary damage/burnout path while keeping the
    * visual regression deterministic and independent of keyboard timing. */
   entry_grace = 0;
   cafes = 0;
   carga = profiles[bh_difficulty].carga_limit - 1;
   player_hit();
#endif
   while (!game_over && !game_won) {
      cpct_waitVSYNC();
      bh_audio_tick();
      ++ticks;
      update_input();
      if (!paused) {
         collect_piece();
         update_alberto();
         if (message_timer) --message_timer;
         if (level == 9 && boss_phone && boss_timer) --boss_timer;
      }
      page = use_lower ? (u8*)BH_LVMEM_START : (u8*)CPCT_VMEM_START;
      page_id = use_lower ? cpct_page80 : cpct_pageC0;
      draw_frame(page);
      cpct_setVideoMemoryPage(page_id);
#if defined(BH_CAPTURE_HUD) || defined(BH_CAPTURE_BOSS)
      if (
#ifdef BH_CAPTURE_HUD
         level == 0 && ticks > 2 && use_lower == BH_CAPTURE_HUD_PAGE
#else
         level == 9
#endif
      ) {
         cpct_waitVSYNC();
         __asm
            di
         002$:
            jr 002$
         __endasm;
      }
#endif
      use_lower = !use_lower;
   }
   if (game_won) {
#ifdef BH_AUTOTEST
      /* The Caprice32 regression reads this byte from a machine snapshot. */
      bh_autotest_result = 0xB0 | bh_difficulty;
#endif
      bh_audio_scene(BH_AUDIO_VICTORY);
      draw_result("APROBADO", "PITU SALVA LA IDEA", (const u8*)0);
   } else {
      bh_audio_scene(BH_AUDIO_DEFEAT);
      draw_result("BURNOUT", "ALBERTO GANA", "ESTA RONDA");
   }
}
