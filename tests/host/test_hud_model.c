#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "hud_model.h"

static void expect_digits5(u16 value, const char* expected) {
   u8 output[6];
   bh_hud_digits5(output, value);
   assert(strcmp((const char*)output, expected) == 0);
}

static void test_digits(void) {
   u8 output[3];
   expect_digits5(0, "00000");
   expect_digits5(9, "00009");
   expect_digits5(10, "00010");
   expect_digits5(99, "00099");
   expect_digits5(100, "00100");
   expect_digits5(999, "00999");
   expect_digits5(1000, "01000");
   expect_digits5(9999, "09999");
   expect_digits5(10000, "10000");
   expect_digits5(65535, "65535");
   bh_hud_digits2(output, 0);
   output[2] = 0;
   assert(strcmp((const char*)output, "00") == 0);
   bh_hud_digits2(output, 12);
   output[2] = 0;
   assert(strcmp((const char*)output, "12") == 0);
   bh_hud_digits2(output, 99);
   output[2] = 0;
   assert(strcmp((const char*)output, "99") == 0);
}

static void test_model(void) {
   BHCampaignState campaign;
   BHHudModel model;
   memset(&campaign, 0, sizeof(campaign));
   campaign.pieces = 0x0A55;
   campaign.carga = 4;
   campaign.cafes = 12;
   campaign.score = 65535;
   bh_hud_model_build(&model, &campaign, 3);
   assert(model.idea_count == 6);
   assert(model.carga == 3);
   assert(model.carga_limit == 3);
   assert(model.cafes == 9);
   assert(model.score == 65535);

   campaign.pieces = 0xFFFF;
   campaign.carga = 9;
   campaign.cafes = 2;
   bh_hud_model_build(&model, &campaign, 8);
   assert(model.idea_count == 12);
   assert(model.carga == BH_HUD_MAX_CARGA);
   assert(model.carga_limit == BH_HUD_MAX_CARGA);
   assert(model.cafes == 2);
}

int main(void) {
   test_digits();
   test_model();
   puts("Host HUD model tests: PASS");
   return 0;
}
