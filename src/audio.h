#ifndef BANTERHOUSE_AUDIO_H
#define BANTERHOUSE_AUDIO_H

#include <types.h>

typedef enum {
   BH_AUDIO_MENU = 0,
   BH_AUDIO_GAME,
   BH_AUDIO_BOSS,
   BH_AUDIO_VICTORY,
   BH_AUDIO_DEFEAT
} BHAudioScene;

typedef enum {
   BH_SFX_SCREEN = 0,
   BH_SFX_PICKUP,
   BH_SFX_SHOT,
   BH_SFX_ALERT,
   BH_SFX_CONTACT,
   BH_SFX_ACTION,
   BH_SFX_VICTORY,
   BH_SFX_DEFEAT,
   BH_SFX_COUNT
} BHSfx;

/* Arkos Player is clocked exactly once per 50 Hz PAL frame. */
void bh_audio_init(void);
void bh_audio_tick(void);
void bh_audio_scene(BHAudioScene scene);
void bh_audio_sfx(BHSfx effect);
void bh_audio_pause(u8 paused);
void bh_audio_stop(void);

#endif
