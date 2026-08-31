#include <cpctelera.h>

#include "main.h"
#include "graphics.h"
#include "game.h"
#include "audio.h"
#include "font.h"
#include "game_state.h"
#include "game_render.h"
#include "input.h"
#include "world_data.h"

#ifdef __SDCC
#pragma constseg BH_GFX
#endif

#define BH_ENTRY_GRACE       45

static BHGameState game_state;
static const u8* message;

#define level             game_state.campaign.level
#define room              game_state.campaign.room
#define carga             game_state.campaign.carga
#define cafes             game_state.campaign.cafes
#define coffee_available  game_state.campaign.coffee_available
#define pieces            game_state.campaign.pieces
#define score             game_state.campaign.score
#define ticks             game_state.campaign.ticks
#define pitu_x            game_state.player.x
#define pitu_y            game_state.player.y
#define pitu_left         game_state.player.left
#define pitu_walking      game_state.player.walking
#define alberto_x         game_state.alberto.x
#define alberto_y         game_state.alberto.y
#define alberto_left      game_state.alberto.left
#define alberto_active    game_state.alberto.active
#define ai_clock          game_state.alberto.clock
#define entry_grace       game_state.alberto.entry_grace
#define warning_ticks     game_state.alberto.warning_ticks
#define cooldown_ticks    game_state.alberto.cooldown_ticks
#define noise_ticks       game_state.alberto.noise_ticks
#define projectile_active game_state.projectile.active
#define projectile_x      game_state.projectile.x
#define projectile_y      game_state.projectile.y
#define projectile_dx     game_state.projectile.dx
#define projectile_dy     game_state.projectile.dy
#define boss_phase        game_state.boss.phase
#define boss_progress     game_state.boss.progress
#define boss_phone        game_state.boss.phone
#define boss_timer        game_state.boss.timer
#define action_was_down   game_state.control.action_was_down
#define esc_was_down      game_state.control.esc_was_down
#define paused            game_state.control.paused
#define game_over         game_state.control.game_over
#define game_won          game_state.control.game_won
#define message_timer     game_state.control.message_timer

#ifdef BH_QA_STATE_HASH
volatile u16 bh_qa_state_hash;
#endif

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

#ifdef BH_VISUAL_GALLERY
#ifndef BH_VISUAL_GALLERY_START
#define BH_VISUAL_GALLERY_START 0
#endif
/* Emulator-only visual acceptance mode.  Each marker is written after the
 * corresponding room has reached the visible page; Caprice32 removes bit 7
 * when it records printer bytes, so the host receives the exact room index. */
volatile u8 bh_gallery_marker;
static void gallery_print_marker(void) {
   __asm
      ld bc, #0xEF00
      ld a, (_bh_gallery_marker)
      or #0x80
      out (c), a
   __endasm;
}

static void gallery_run(void) {
   u8 index = 0;
   u8 gallery_level;
   u8 gallery_room;
   u8 frame;
   u8* page = (u8*)CPCT_VMEM_START;

   bh_audio_stop();
   message_timer = 0;
   paused = 0;
   projectile_active = 0;
   pitu_x = 7;
   pitu_y = 119;
   pitu_walking = 0;
   alberto_x = 65;
   alberto_y = 40;
   alberto_active = 1;
   for (gallery_level = 0; gallery_level < 10; ++gallery_level) {
      for (gallery_room = 0; gallery_room < 3; ++gallery_room) {
         if (index < BH_VISUAL_GALLERY_START) {
            ++index;
            continue;
         }
         level = gallery_level;
         room = gallery_room;
         if (level == 9) {
            boss_phase = room + 1;
            boss_progress = room == 2 ? 1 : 0;
            boss_phone = 0;
            boss_timer = bh_profiles[bh_difficulty].boss_window;
         }
         for (frame = 0; frame < 150; ++frame) {
            cpct_waitVSYNC();
            ++ticks;
            bh_game_render_frame(page, &game_state, message);
            cpct_setVideoMemoryPage(cpct_pageC0);
            if (frame == 0) {
               bh_gallery_marker = index;
               gallery_print_marker();
            }
         }
         ++index;
      }
   }
   __asm
      di
   004$:
      halt
      jr 004$
   __endasm;
}
#endif

static u8 key_down(u8 row, u8 bit) {
   return (cpct_keyboardStatusBuffer[row] & bit) == 0;
}

static u8 abs_diff(u8 a, u8 b) {
   return a > b ? a - b : b - a;
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
      boss_timer = bh_profiles[bh_difficulty].boss_window;
      set_message("PRESIDENTE ESPERA", 100);
   } else {
      set_message(bh_level_names[level], 80);
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
   cafes = bh_profiles[bh_difficulty].initial_cafes;
   paused = 0;
   game_over = 0;
   game_won = 0;
   action_was_down = 0;
   esc_was_down = 0;
   begin_level();
}

static void draw_result(const u8* title, const u8* subtitle, const u8* subtitle2) {
   u8* page = (u8*)CPCT_VMEM_START;
   bh_game_render_result(page, title, subtitle, subtitle2);
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
   if (carga >= bh_profiles[bh_difficulty].carga_limit) burnout();
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
   cooldown_ticks = bh_profiles[bh_difficulty].cooldown;
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
   if (!(bh_profiles[bh_difficulty].ai_mask & (((u8)1) << (ai_clock & 7)))) return;
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
      if (aligned && abs_diff(pitu_x, alberto_x) + (abs_diff(pitu_y, alberto_y) >> 1) < bh_profiles[bh_difficulty].vision)
      {
         warning_ticks = bh_profiles[bh_difficulty].warning;
         bh_audio_sfx(BH_SFX_ALERT);
      }
   }
   update_projectile();
}

static void collect_piece(void) {
   u8 id = bh_world_pickup_id(level, room);
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
      tx = bh_boss_x[boss_progress]; ty = bh_boss_y[boss_progress];
      if (near(pitu_x, pitu_y, tx, ty, 7, 14)) {
         ++boss_progress;
         bh_audio_sfx(BH_SFX_PICKUP);
         set_message("PANEL ACTIVADO", 50);
         if (boss_progress == 4) {
            pieces |= ((u16)1) << 10;
            boss_phase = 2;
            boss_progress = 0;
            boss_timer = bh_profiles[bh_difficulty].boss_window;
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
      } else if (bh_world_level_ready(level, pieces)) {
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
   u8 input;
   pitu_walking = 0;
#ifdef BH_AUTOTEST
   if (autotest_delay) {
      --autotest_delay;
      return;
   }
   autotest_input();
   return;
#endif
   input = bh_input_scan();
   esc = (input & BH_INPUT_PAUSE) != 0;
   if (esc && !esc_was_down) {
      paused = !paused;
      bh_audio_pause(paused);
   }
   esc_was_down = esc;
   if (paused) return;

   if (input & BH_INPUT_UP) {
      if (!blocked(pitu_x, pitu_y - 2)) pitu_y -= 2;
      pitu_walking = 1;
   }
   if (input & BH_INPUT_DOWN) {
      if (!blocked(pitu_x, pitu_y + 2)) pitu_y += 2;
      pitu_walking = 1;
   }
   if (input & BH_INPUT_LEFT) {
      if (!blocked(pitu_x - 1, pitu_y)) --pitu_x;
      pitu_left = 1;
      pitu_walking = 1;
   }
   if (input & BH_INPUT_RIGHT) {
      if (!blocked(pitu_x + 1, pitu_y)) ++pitu_x;
      pitu_left = 0;
      pitu_walking = 1;
   }
   action = (input & BH_INPUT_ACTION) != 0;
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
      id = bh_world_pickup_id(level, room);
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
      pitu_x = bh_boss_x[boss_progress];
      pitu_y = bh_boss_y[boss_progress];
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
   u8* page = (u8*)CPCT_VMEM_START;

   bh_audio_scene(BH_AUDIO_GAME);
   reset_game();
   bh_game_render_invalidate();
#ifdef BH_VISUAL_GALLERY
   gallery_run();
#endif
#ifdef BH_AUTOTEST_DEFEAT
   /* Reach defeat through the ordinary damage/burnout path while keeping the
    * visual regression deterministic and independent of keyboard timing. */
   entry_grace = 0;
   cafes = 0;
   carga = bh_profiles[bh_difficulty].carga_limit - 1;
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
#ifdef BH_QA_STATE_HASH
      bh_qa_state_hash = bh_game_state_hash(&game_state, (u8)bh_difficulty);
#endif
      bh_game_render_frame(page, &game_state, message);
      cpct_setVideoMemoryPage(cpct_pageC0);
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
