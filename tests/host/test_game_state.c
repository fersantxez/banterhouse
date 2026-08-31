#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "difficulty.h"
#include "game_state.h"
#include "world_data.h"

static void test_profiles(void) {
   u8 i;

   assert(BH_DIFFICULTY_COUNT == 5);
   for (i = 1; i < BH_DIFFICULTY_COUNT; ++i) {
      assert(bh_profiles[i].vision > bh_profiles[i - 1].vision);
      assert(bh_profiles[i].warning < bh_profiles[i - 1].warning);
      assert(bh_profiles[i].cooldown < bh_profiles[i - 1].cooldown);
      assert(bh_profiles[i].follow_rooms >= bh_profiles[i - 1].follow_rooms);
      assert(bh_profiles[i].carga_limit <= bh_profiles[i - 1].carga_limit);
      assert(bh_profiles[i].initial_cafes <= bh_profiles[i - 1].initial_cafes);
      assert(bh_profiles[i].boss_window < bh_profiles[i - 1].boss_window);
   }
}

static void test_state_hash(void) {
   BHGameState first;
   BHGameState second;
   u16 baseline;

   memset(&first, 0, sizeof(first));
   first.campaign.level = 4;
   first.campaign.room = 2;
   first.campaign.carga = 1;
   first.campaign.cafes = 3;
   first.campaign.coffee_available = 1;
   first.campaign.pieces = 0x02A5;
   first.campaign.score = 1200;
   first.campaign.ticks = 4321;
   first.player.x = 37;
   first.player.y = 106;
   first.player.left = 1;
   first.alberto.x = 61;
   first.alberto.y = 72;
   first.alberto.active = 1;
   first.alberto.warning_ticks = 12;
   first.projectile.active = 1;
   first.projectile.x = 44;
   first.projectile.y = 88;
   first.projectile.dx = -1;
   first.boss.phase = 2;
   first.boss.progress = 1;
   first.control.message_timer = 17;

   second = first;
   baseline = bh_game_state_hash(&first, BH_NORMAL);
   assert(baseline == bh_game_state_hash(&second, BH_NORMAL));
   assert(baseline != bh_game_state_hash(&second, BH_HARD));

   second.player.x++;
   assert(baseline != bh_game_state_hash(&second, BH_NORMAL));
   second = first;
   second.campaign.pieces ^= 0x0100;
   assert(baseline != bh_game_state_hash(&second, BH_NORMAL));
   second = first;
   second.alberto.cooldown_ticks++;
   assert(baseline != bh_game_state_hash(&second, BH_NORMAL));
   second = first;
   second.projectile.dy = 1;
   assert(baseline != bh_game_state_hash(&second, BH_NORMAL));
   second = first;
   second.boss.timer++;
   assert(baseline != bh_game_state_hash(&second, BH_NORMAL));
   second = first;
   second.control.paused = 1;
   assert(baseline != bh_game_state_hash(&second, BH_NORMAL));
}

static void test_world_rules(void) {
   assert(bh_world_pickup_id(0, 0) == 0);
   assert(bh_world_pickup_id(0, 1) == 1);
   assert(bh_world_pickup_id(0, 2) == BH_NONE);
   assert(bh_world_pickup_id(4, 1) == 5);
   assert(bh_world_level_ready(0, 3));
   assert(!bh_world_level_ready(0, 1));
   assert(bh_world_level_ready(4, ((u16)1) << 5));
   assert(!bh_world_level_ready(4, ((u16)1) << 4));
   assert(bh_world_count_pieces(0x0A55) == 6);
}

int main(void) {
   test_profiles();
   test_state_hash();
   test_world_rules();
   puts("Host state/profile tests: PASS");
   return 0;
}
