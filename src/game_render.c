#include <cpctelera.h>

#include "difficulty.h"
#include "font.h"
#include "game_render.h"
#include "graphics.h"
#include "main.h"
#include "room_visuals.h"
#include "world_data.h"

#ifdef __SDCC
#pragma constseg BH_GFX
#endif

static const u8 small_label[] = {'P', 'E', 'Q', 'U', 'E', BH_CHAR_NTILDE, 'O', 0};

typedef struct {
   u8 valid, x, y;
} BHSaveUnder;

typedef struct {
   u8 level, room, carga, cafes, coffee, difficulty;
   u16 pieces;
   u8 boss_phase, boss_progress, boss_phone, boss_expired;
   u8 message_visible, paused;
   const u8* message;
   u8* page;
} BHRenderKey;

/* The gallery exposed the cost of redrawing 16 KiB of panel art every game
 * tick.  These RAM buffers preserve only the pixels hidden by moving actors,
 * allowing the static comic panel to be composed once per state change.  SDCC
 * places them in the now-hidden 0x8000 video page; gameplay displays 0xC000. */
#ifdef __SDCC
static __at (0x8000) u8 pitu_under[G_PITU_W * G_PITU_H];
static __at (0x8100) u8 alberto_under[G_ALBERTO_W * G_ALBERTO_H];
static __at (0x8200) u8 projectile_under[2 * 4];
static __at (0x8208) BHSaveUnder pitu_saved;
static __at (0x820B) BHSaveUnder alberto_saved;
static __at (0x820E) BHSaveUnder projectile_saved;
static __at (0x8220) BHRenderKey render_key;
static __at (0x8240) u8 render_key_valid;
#else
static u8 pitu_under[G_PITU_W * G_PITU_H];
static u8 alberto_under[G_ALBERTO_W * G_ALBERTO_H];
static u8 projectile_under[2 * 4];
static BHSaveUnder pitu_saved;
static BHSaveUnder alberto_saved;
static BHSaveUnder projectile_saved;
static BHRenderKey render_key;
static u8 render_key_valid;
#endif

static void box(u8* page, u8 x, u8 y, u8 w, u8 h, u8 colour) {
   u8 pattern = cpct_px2byteM0(colour, colour);
   /* CPCtelera's optimized solid-box primitive accepts at most 64 bytes.
    * Full-width comic rules are split explicitly instead of relying on its
    * self-modifying jump wrapping around. */
   if (w > 64) {
      cpct_drawSolidBox(cpct_getScreenPtr(page, x, y), pattern, 64, h);
      x += 64;
      w -= 64;
   }
   cpct_drawSolidBox(cpct_getScreenPtr(page, x, y), pattern, w, h);
}

static void text(u8* page, const u8* value, u8 x, u8 y, u8 ink, u8 paper) {
   bh_font_set_colours(ink, paper);
   bh_font_draw_string(value, cpct_getScreenPtr(page, x, y));
}

static void centred_text(u8* page, const u8* value, u8 y, u8 ink, u8 paper) {
   text(page, value, (BH_SCREEN_W - bh_font_measure(value)) >> 1, y, ink, paper);
}

static void restore_pixels(const u8* input, u8* page, BHSaveUnder* saved, u8 width, u8 height) {
   if (!saved->valid) return;
   cpct_drawSprite((u8*)input, cpct_getScreenPtr(page, saved->x, saved->y), width, height);
   saved->valid = 0;
}

static void remember_pixels(u8* output, u8* page, BHSaveUnder* saved,
                            u8 x, u8 y, u8 width, u8 height) {
   cpct_getScreenToSprite(cpct_getScreenPtr(page, x, y), output, width, height);
   saved->x = x;
   saved->y = y;
   saved->valid = 1;
}

static void number2(u8* output, u8 value) {
   output[0] = '0';
   while (value >= 10) { ++output[0]; value -= 10; }
   output[1] = '0' + value;
}

static const BHRoomVisual* room_visual(u8 level, u8 room) {
   return &bh_room_visuals[level * BH_ROOMS_PER_LEVEL + room];
}

static void draw_backdrop(u8* page, u8 level, u8 room) {
   const BHRoomVisual* visual = room_visual(level, room);
   const BHBackdropRect* rect = &bh_backdrop_rects[visual->first_rect];
   u8 count = visual->rect_count;
   u8 index = level * BH_ROOMS_PER_LEVEL + room;

   cpct_memset(page, cpct_px2byteM0(visual->paper, visual->paper), 0x4000);
   /* A room is a comic panel: the outer frame and two gutters make negative
    * space deliberate while retaining the clear perimeter escape route. */
   box(page, 0, BH_HUD_H, BH_SCREEN_W, 2, visual->ink);
   box(page, 0, 18, 2, 160, visual->ink);
   box(page, 78, 18, 2, 160, visual->ink);
   box(page, 0, 176, BH_SCREEN_W, 2, visual->ink);
   box(page, 2, 64, 76, 1, visual->shadow);
   box(page, 2, 132, 76, 1, visual->shadow);
   while (count--) {
      box(page, rect->x, rect->y, rect->width, rect->height, rect->colour);
      ++rect;
   }
   text(page, bh_room_labels[index], 5, 22, visual->ink, visual->paper);
}

static void draw_hud(u8* page, const BHGameState* state) {
   u8 line[18];
   u8 count = bh_world_count_pieces(state->campaign.pieces);
   box(page, 0, 0, BH_SCREEN_W, BH_HUD_H, 0);
   line[0] = 'L'; number2(&line[1], state->campaign.level + 1);
   line[3] = 'R'; line[4] = '0' + state->campaign.room + 1;
   line[5] = ' '; line[6] = 'I'; number2(&line[7], count);
   line[9] = '/'; line[10] = '1'; line[11] = '2'; line[12] = 0;
   text(page, line, 0, 4, 5, 0);
   line[0] = 'C'; line[1] = '0' + state->campaign.carga; line[2] = '/';
   line[3] = '0' + bh_profiles[bh_difficulty].carga_limit;
   line[4] = ' '; line[5] = 'F'; line[6] = '0' + state->campaign.cafes; line[7] = 0;
   text(page, line, 52, 4, 8, 0);
}

static void draw_idea_icon(u8* page, u8 id, u16 ticks) {
   u8 x = BH_IDEA_X;
   u8 y = BH_IDEA_Y - ((ticks >> 4) & 1);
   u8 ink = 14;
   while (id >= 6) id -= 6;
   box(page, x, y + 10, 5, 2, 0);
   switch (id) {
      case 0:
         box(page, x + 1, y, 3, 5, 14); box(page, x, y + 1, 5, 3, 14);
         box(page, x + 2, y + 5, 1, 3, 1); box(page, x + 1, y + 8, 3, 1, 8); break;
      case 1:
         box(page, x, y + 7, 1, 2, 1); box(page, x + 1, y + 5, 1, 2, 9);
         box(page, x + 2, y + 3, 1, 2, 14); box(page, x + 3, y + 1, 1, 2, 9);
         box(page, x + 4, y, 1, 2, 1); break;
      case 2:
         ink = 10; box(page, x + 2, y, 1, 9, ink); box(page, x, y + 4, 5, 1, ink);
         box(page, x + 1, y + 2, 3, 5, ink); box(page, x + 2, y + 3, 1, 3, 5); break;
      case 3:
         ink = 13; box(page, x, y + 1, 5, 6, ink); box(page, x + 1, y + 2, 3, 3, 5);
         box(page, x + 1, y + 7, 1, 2, ink); break;
      case 4:
         ink = 12; box(page, x, y + 3, 5, 4, ink); box(page, x + 1, y + 2, 3, 6, ink);
         box(page, x + 2, y + 3, 1, 4, 0); break;
      default:
         box(page, x, y + 1, 5, 7, 1); box(page, x + 1, y + 2, 1, 2, 9);
         box(page, x + 3, y + 2, 1, 2, 10); box(page, x + 1, y + 5, 1, 2, 14);
         box(page, x + 3, y + 5, 1, 2, 13); box(page, x + 4, y + 7, 1, 2, 5); break;
   }
   if (ticks & 8) box(page, x + 6, y + 1, 1, 2, ink);
}

static void draw_office(u8* page, const BHGameState* state) {
   u8 level = state->campaign.level;
   u8 room = state->campaign.room;
   u8 variant = (level + room) & 3;
   u8 piece = bh_world_pickup_id(level, room);
   const BHRoomVisual* visual = room_visual(level, room);
   draw_backdrop(page, level, room);
   draw_hud(page, state);
   /* The three gameplay obstacles retain their exact collision geometry, but
    * inherit the room's paper/ink/accent instead of looking like placeholders. */
   box(page, 10 + (variant << 2), 36, 15, 7, visual->ink);
   box(page, 12 + (variant << 2), 43, 11, 3, visual->accent);
   box(page, 45 - (variant << 1), 72, 18, 6, visual->ink);
   box(page, 47 - (variant << 1), 78, 14, 3, visual->shadow);
   box(page, 18 + (variant << 1), 140, 12, 6, visual->ink);
   box(page, 20 + (variant << 1), 146, 8, 3, visual->accent);
   box(page, 70, 82, 6, 30, visual->shadow);
   box(page, 4, 82, 4, 30, room ? visual->shadow : visual->accent);
   box(page, BH_PHONE_X, BH_PHONE_Y, 5, 6, 10); box(page, BH_PHONE_X + 1, BH_PHONE_Y + 2, 3, 2, 0);
   text(page, "TEL", BH_PHONE_X - 1, BH_PHONE_Y + 7, 10, visual->paper);
   if (state->campaign.coffee_available) {
      box(page, BH_COFFEE_X, BH_COFFEE_Y, 4, 7, 9);
      text(page, "CAFE", BH_COFFEE_X - 2, BH_COFFEE_Y + 8, 9, visual->paper);
   }
   if (piece != BH_NONE && !(state->campaign.pieces & (((u16)1) << piece)))
      draw_idea_icon(page, piece, 0);
   if (room == 2 && level < 9)
      text(page, bh_world_level_ready(level, state->campaign.pieces) ? "SALIDA" : "FALTA IDEA", 39, 116, 6, visual->paper);
}

static void draw_boss(u8* page, const BHGameState* state) {
   u8 target_x;
   u8 target_y;
   u8 label[20];
   const BHBossState* boss = &state->boss;
   u8 visual_room = boss->phase ? boss->phase - 1 : 0;
   const BHRoomVisual* visual = room_visual(9, visual_room);
   draw_backdrop(page, 9, visual_room);
   draw_hud(page, state);
   box(page, 8, 67, 64, 22, visual->ink); box(page, 18, 71, 44, 14, visual->shadow);
   text(page, "EL PRESIDENTE", 23, 75, visual->ink, visual->shadow);
   text(page, "APROBADO [ ][ ][ ]", 4, 92, 1, visual->paper);
   box(page, 9, 132, 62, 17, visual->ink); box(page, BH_PHONE_X, BH_PHONE_Y, 5, 6, 10);
   text(page, "FAX", BH_PHONE_X - 1, BH_PHONE_Y + 7, 10, visual->paper);
   box(page, BH_TRAY_X, BH_TRAY_Y, 9, 7, 9); text(page, "BANDEJA", BH_TRAY_X - 2, BH_TRAY_Y + 8, 9, visual->paper);
   label[0] = 'F'; label[1] = 'A'; label[2] = 'S'; label[3] = 'E'; label[4] = ' ';
   label[5] = '0' + boss->phase; label[6] = 0; text(page, label, 55, 22, visual->accent, visual->paper);
   if (boss->phase == 1) {
      target_x = bh_boss_x[boss->progress]; target_y = bh_boss_y[boss->progress];
      box(page, target_x, target_y, 6, 8, 14); text(page, "PANEL", target_x < 54 ? target_x : 54, target_y + 9, 14, visual->paper);
   } else if (boss->phase == 2) {
      target_x = boss->progress ? 58 : 16; target_y = boss->progress ? 86 : 82;
      box(page, target_x, target_y, 7, 8, 12);
      text(page, boss->progress ? small_label : "GRANDE", boss->progress ? 45 : 13, target_y + 9, 12, visual->paper);
   } else if (!boss->phone) text(page, "USA EL FAX", 27, 104, 10, visual->paper);
   else if (boss->timer) text(page, "ALBERTO LANZA", 22, 104, 9, visual->paper);
   else {
      text(page, "ENTREGA ORIGINAL", 8, 104, 14, visual->paper);
      box(page, BH_TRAY_X + 2, BH_TRAY_Y - 11, 5, 8, 14);
   }
}

static void draw_static_overlays(u8* page, const BHGameState* state, const u8* message) {
   if (state->control.message_timer) text(page, message, 4, 184, 1, 5);
   if (state->control.paused) text(page, "PAUSA ESC", 22, 160, 0, 14);
}

static void draw_entities(u8* page, const BHGameState* state) {
   const BHPlayerState* player = &state->player;
   const BHAlbertoState* alberto_state = &state->alberto;
   const u8* pitu = player->walking ? (player->left ? g_pitu_walk_rev : g_pitu_walk) :
      (player->left ? g_pitu_rev : g_pitu);
   const u8* alberto = (alberto_state->clock & 8) ?
      (alberto_state->left ? g_alberto_walk_rev : g_alberto_walk) :
      (alberto_state->left ? g_alberto_rev : g_alberto);
   /* Unwind in reverse drawing order so overlapping actors restore cleanly. */
   restore_pixels(projectile_under, page, &projectile_saved, 2, 4);
   restore_pixels(alberto_under, page, &alberto_saved, G_ALBERTO_W, G_ALBERTO_H);
   restore_pixels(pitu_under, page, &pitu_saved, G_PITU_W, G_PITU_H);

   remember_pixels(pitu_under, page, &pitu_saved, player->x, player->y, G_PITU_W, G_PITU_H);
   cpct_drawSpriteMasked((u8*)pitu, cpct_getScreenPtr(page, player->x, player->y), G_PITU_W, G_PITU_H);
   if (alberto_state->active) {
      remember_pixels(alberto_under, page, &alberto_saved, alberto_state->x,
                      alberto_state->y, G_ALBERTO_W, G_ALBERTO_H);
      cpct_drawSpriteMasked((u8*)alberto, cpct_getScreenPtr(page, alberto_state->x, alberto_state->y), G_ALBERTO_W, G_ALBERTO_H);
   }
   if (state->projectile.active) {
      remember_pixels(projectile_under, page, &projectile_saved,
                      state->projectile.x, state->projectile.y, 2, 4);
      box(page, state->projectile.x, state->projectile.y, 2, 4, 9);
   }
}

static void make_render_key(BHRenderKey* key, u8* page,
                            const BHGameState* state, const u8* message) {
   key->page = page;
   key->level = state->campaign.level;
   key->room = state->campaign.room;
   key->carga = state->campaign.carga;
   key->cafes = state->campaign.cafes;
   key->coffee = state->campaign.coffee_available;
   key->difficulty = (u8)bh_difficulty;
   key->pieces = state->campaign.pieces;
   key->boss_phase = state->boss.phase;
   key->boss_progress = state->boss.progress;
   key->boss_phone = state->boss.phone;
   key->boss_expired = state->boss.timer == 0;
   key->message_visible = state->control.message_timer != 0;
   key->paused = state->control.paused;
   key->message = message;
}

static u8 different_render_key(const BHRenderKey* left, const BHRenderKey* right) {
   const u8* a = (const u8*)left;
   const u8* b = (const u8*)right;
   u8 count = sizeof(BHRenderKey);
   while (count--) if (*a++ != *b++) return 1;
   return 0;
}

void bh_game_render_invalidate(void) {
   render_key_valid = 0;
   pitu_saved.valid = 0;
   alberto_saved.valid = 0;
   projectile_saved.valid = 0;
}

void bh_game_render_frame(u8* page, const BHGameState* state, const u8* message) {
   BHRenderKey next_key;
   make_render_key(&next_key, page, state, message);
   if (!render_key_valid || different_render_key(&render_key, &next_key)) {
      if (state->campaign.level == 9) draw_boss(page, state);
      else draw_office(page, state);
      draw_static_overlays(page, state, message);
      cpct_memcpy(&render_key, &next_key, sizeof(BHRenderKey));
      render_key_valid = 1;
      pitu_saved.valid = 0;
      alberto_saved.valid = 0;
      projectile_saved.valid = 0;
   }
   draw_entities(page, state);
}

void bh_game_render_result(u8* page, const u8* title, const u8* subtitle, const u8* subtitle2) {
   bh_game_render_invalidate();
   cpct_memset(page, cpct_px2byteM0(5, 5), 0x4000);
   cpct_drawSprite(g_logo, cpct_getScreenPtr(page, (80 - G_LOGO_W) / 2, 32), G_LOGO_W, G_LOGO_H);
   centred_text(page, title, 105, 0, 5); centred_text(page, subtitle, 124, 10, 5);
   if (subtitle2) centred_text(page, subtitle2, 136, 10, 5);
   centred_text(page, "PULSA S", 154, 13, 5);
}
