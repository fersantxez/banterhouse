#ifndef BANTERHOUSE_GAME_RENDER_H
#define BANTERHOUSE_GAME_RENDER_H

#include "game_state.h"

void bh_game_render_frame(u8* page, const BHGameState* state, const u8* message);
void bh_game_render_result(u8* page, const u8* title, const u8* subtitle, const u8* subtitle2);
void bh_game_render_invalidate(void);

#endif
