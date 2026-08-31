#ifndef BANTERHOUSE_GAME_STATE_H
#define BANTERHOUSE_GAME_STATE_H

#include "bh_types.h"

typedef struct {
   u8 level;
   u8 room;
   u8 carga;
   u8 cafes;
   u8 coffee_available;
   u16 pieces;
   u16 score;
   u16 ticks;
} BHCampaignState;

typedef struct {
   u8 x;
   u8 y;
   u8 left;
   u8 walking;
} BHPlayerState;

typedef struct {
   u8 x;
   u8 y;
   u8 left;
   u8 active;
   u8 clock;
   u8 entry_grace;
   u8 warning_ticks;
   u8 cooldown_ticks;
   u8 noise_ticks;
} BHAlbertoState;

typedef struct {
   u8 active;
   u8 x;
   u8 y;
   i8 dx;
   i8 dy;
} BHProjectileState;

typedef struct {
   u8 phase;
   u8 progress;
   u8 phone;
   u8 timer;
} BHBossState;

typedef struct {
   u8 action_was_down;
   u8 esc_was_down;
   u8 paused;
   u8 game_over;
   u8 game_won;
   u8 message_timer;
} BHControlState;

typedef struct {
   BHCampaignState campaign;
   BHPlayerState player;
   BHAlbertoState alberto;
   BHProjectileState projectile;
   BHBossState boss;
   BHControlState control;
} BHGameState;

#if defined(BH_QA_STATE_HASH) || !defined(__SDCC)
u16 bh_game_state_hash(const BHGameState* state, u8 difficulty);
#endif

#endif
