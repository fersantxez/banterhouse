#ifndef BANTERHOUSE_HUD_MODEL_H
#define BANTERHOUSE_HUD_MODEL_H

#include "game_state.h"

#define BH_HUD_MAX_IDEAS 12
#define BH_HUD_MAX_CARGA  5
#define BH_HUD_MAX_CAFES  9

typedef struct {
   u8 idea_count;
   u8 carga;
   u8 carga_limit;
   u8 cafes;
   u16 score;
} BHHudModel;

#ifndef __SDCC
void bh_hud_model_build(BHHudModel* output,
                        const BHCampaignState* campaign,
                        u8 carga_limit);
#endif
void bh_hud_digits2(u8* output, u8 value);
void bh_hud_digits5(u8* output, u16 value);

#endif
