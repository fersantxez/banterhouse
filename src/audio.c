#include <cpctelera.h>

#include "audio.h"
#include "banterhouse-theme.h"
#include "banterhouse-sfx.h"

#define BH_SFX_CHANNEL AY_CHANNEL_C

static u8 current_priority;
static u8 current_scene;

typedef struct {
   u8 instrument;
   u8 priority;
   u8 note;
   u8 volume;
   u8 speed;
   u16 pitch;
} BHSfxDescriptor;

/* Keep this table const: the no-CRT build never copies _INITIALIZER data. */
static const BHSfxDescriptor sfx_table[BH_SFX_COUNT] = {
   { 2, 1, 50, 13, 0, 0 }, /* successful room/level transition */
   { 1, 2, 60, 15, 0, 0 }, /* idea, panel or object pickup */
   { 3, 2, 38, 15, 0, 0 }, /* Alberto launches a briefing */
   { 4, 3, 50, 15, 0, 0 }, /* pre-shot warning / boss alarm */
   { 5, 4, 34, 15, 0, 0 }, /* briefing makes contact with Pitu */
   { 6, 1, 55, 12, 0, 0 }, /* coffee or telephone action */
   { 7, 5, 55, 15, 0, 0 }, /* campaign victory */
   { 8, 5, 43, 15, 0, 0 }  /* campaign defeat */
};

static void restart_song(void) {
   current_priority = 0;
   cpct_akp_stop();
   cpct_akp_SFXStopAll();
   cpct_akp_SFXInit((void*)bh_sfx_address);
   cpct_akp_musicInit((void*)bh_theme_address);
}

void bh_audio_init(void) {
   /* The first scene is selected after its initial framebuffer has been drawn. */
   current_scene = 0xFF;
   current_priority = 0;
   cpct_akp_SFXInit((void*)bh_sfx_address);
   cpct_akp_musicInit((void*)bh_theme_address);
}

void bh_audio_tick(void) {
   cpct_akp_musicPlay();
   if (!cpct_akp_SFXGetInstrument(BH_SFX_CHANNEL)) current_priority = 0;
}

void bh_audio_sfx(BHSfx effect) {
   const BHSfxDescriptor* descriptor;
   if (effect >= BH_SFX_COUNT) return;
   descriptor = &sfx_table[effect];
   if (descriptor->priority < current_priority) return;
   cpct_akp_SFXPlay(descriptor->instrument, descriptor->volume,
                    descriptor->note, descriptor->speed,
                    descriptor->pitch, BH_SFX_CHANNEL);
   current_priority = descriptor->priority;
}

void bh_audio_scene(BHAudioScene scene) {
   if (scene == current_scene) return;
   current_scene = scene;
   if (scene == BH_AUDIO_MENU || scene == BH_AUDIO_GAME) {
      restart_song();
   } else if (scene == BH_AUDIO_BOSS) {
      bh_audio_sfx(BH_SFX_ALERT);
   } else if (scene == BH_AUDIO_VICTORY) {
      cpct_akp_SFXStopAll();
      current_priority = 0;
      bh_audio_sfx(BH_SFX_VICTORY);
   } else {
      cpct_akp_SFXStopAll();
      current_priority = 0;
      bh_audio_sfx(BH_SFX_DEFEAT);
   }
}

void bh_audio_pause(u8 paused) {
   if (paused) {
      cpct_akp_SFXStopAll();
      current_priority = 0;
      cpct_akp_stop();
   }
   else restart_song();
}

void bh_audio_stop(void) {
   cpct_akp_SFXStopAll();
   cpct_akp_stop();
   current_priority = 0;
}
