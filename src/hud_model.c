#include "hud_model.h"

#ifndef __SDCC

static u8 count_ideas(u16 pieces) {
   u8 count = 0;
   u8 index;
   u16 mask = 1;
   for (index = 0; index < BH_HUD_MAX_IDEAS; ++index) {
      if (pieces & mask) ++count;
      mask <<= 1;
   }
   return count;
}

void bh_hud_model_build(BHHudModel* output,
                        const BHCampaignState* campaign,
                        u8 carga_limit) {
   if (carga_limit > BH_HUD_MAX_CARGA) carga_limit = BH_HUD_MAX_CARGA;
   output->idea_count = count_ideas(campaign->pieces);
   output->carga_limit = carga_limit;
   output->carga = campaign->carga > carga_limit ? carga_limit : campaign->carga;
   output->cafes = campaign->cafes > BH_HUD_MAX_CAFES ? BH_HUD_MAX_CAFES : campaign->cafes;
   output->score = campaign->score;
}

#endif

void bh_hud_digits2(u8* output, u8 value) {
   output[0] = '0';
   while (value >= 10) { ++output[0]; value -= 10; }
   output[1] = '0' + value;
}

void bh_hud_digits5(u8* output, u16 value) {
   output[0] = '0'; while (value >= 10000) { ++output[0]; value -= 10000; }
   output[1] = '0'; while (value >= 1000) { ++output[1]; value -= 1000; }
   output[2] = '0'; while (value >= 100) { ++output[2]; value -= 100; }
   output[3] = '0'; while (value >= 10) { ++output[3]; value -= 10; }
   output[4] = '0' + (u8)value;
   output[5] = 0;
}
