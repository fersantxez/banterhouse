#include "game_state.h"

#if defined(BH_QA_STATE_HASH) || !defined(__SDCC)
static u16 hash_byte(u16 hash, u8 value) {
   hash = (u16)((hash << 5) | (hash >> 11));
   return hash ^ value;
}

static u16 hash_word(u16 hash, u16 value) {
   hash = hash_byte(hash, (u8)value);
   return hash_byte(hash, (u8)(value >> 8));
}

u16 bh_game_state_hash(const BHGameState* state, u8 difficulty) {
   u16 hash = 0xB17E;

#define HASH_BYTE(value) hash = hash_byte(hash, (u8)(value))
#define HASH_WORD(value) hash = hash_word(hash, (u16)(value))
   HASH_BYTE(difficulty);
   HASH_BYTE(state->campaign.level);
   HASH_BYTE(state->campaign.room);
   HASH_BYTE(state->campaign.carga);
   HASH_BYTE(state->campaign.cafes);
   HASH_BYTE(state->campaign.coffee_available);
   HASH_WORD(state->campaign.pieces);
   HASH_WORD(state->campaign.score);
   HASH_WORD(state->campaign.ticks);
   HASH_BYTE(state->player.x);
   HASH_BYTE(state->player.y);
   HASH_BYTE(state->player.left);
   HASH_BYTE(state->player.walking);
   HASH_BYTE(state->alberto.x);
   HASH_BYTE(state->alberto.y);
   HASH_BYTE(state->alberto.left);
   HASH_BYTE(state->alberto.active);
   HASH_BYTE(state->alberto.clock);
   HASH_BYTE(state->alberto.entry_grace);
   HASH_BYTE(state->alberto.warning_ticks);
   HASH_BYTE(state->alberto.cooldown_ticks);
   HASH_BYTE(state->alberto.noise_ticks);
   HASH_BYTE(state->projectile.active);
   HASH_BYTE(state->projectile.x);
   HASH_BYTE(state->projectile.y);
   HASH_BYTE(state->projectile.dx);
   HASH_BYTE(state->projectile.dy);
   HASH_BYTE(state->boss.phase);
   HASH_BYTE(state->boss.progress);
   HASH_BYTE(state->boss.phone);
   HASH_BYTE(state->boss.timer);
   HASH_BYTE(state->control.action_was_down);
   HASH_BYTE(state->control.esc_was_down);
   HASH_BYTE(state->control.paused);
   HASH_BYTE(state->control.game_over);
   HASH_BYTE(state->control.game_won);
   HASH_BYTE(state->control.message_timer);
#undef HASH_WORD
#undef HASH_BYTE

   return hash;
}
#endif
