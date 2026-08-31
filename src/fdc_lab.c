#include <cpctelera.h>

#include "audio.h"
#include "fdc_lab.h"
#include "font.h"
#include "main.h"
#include "storage.h"

#ifdef BH_FDC_LAB
#include "../generated/resource_ids.h"

#define BH_FDC_LAB_TRACK  0
#define BH_FDC_LAB_SECTOR 0xC5
#define BH_FDC_LAB_SKIP   128
#ifndef BH_FDC_LAB_CYCLES
#define BH_FDC_LAB_CYCLES 1
#endif

u8 bh_fdc_lab_emit_status;

extern u8* bh_fdc_destination;
extern u8 bh_fdc_track;
extern u8 bh_fdc_sector;
extern u8 bh_fdc_eot;
extern u16 bh_fdc_transfer_size;
extern u8 bh_fdc_result[7];
extern void bh_fdc_motor_on(void);
extern void bh_fdc_motor_off(void);
extern u8 bh_fdc_read_request(void);

static u16 crc16_byte(u16 crc, u8 value) {
   u8 bit;
   crc ^= ((u16)value) << 8;
   for (bit = 0; bit < 8; ++bit) {
      crc = (crc & 0x8000) ? (crc << 1) ^ 0x1021 : crc << 1;
   }
   return crc;
}

static u8 header_is_valid(const u8* data) {
   u8 i;
   u8 count;
   u16 crc = 0xFFFF;
   u16 stored_crc;
   u16 index_end;
   u16 dependency_end = 0;
   u16 dependency_start;
   const u8* entry;

   data += BH_FDC_LAB_SKIP;
   if (data[0] != 'B' || data[1] != 'H' || data[2] != 'R' || data[3] != 'S') return 0;
   if (data[4] != BH_RESOURCE_FORMAT_VERSION || data[5] != 0) return 0;
   count = data[6] | ((u16)data[7] << 8);
   if (count != BH_RESOURCE_COUNT) return 0;
   if (data[8] != 20 || data[9] || data[10]) return 0;
   if (data[14] != BH_RESOURCE_BUILD_ID_B0 || data[15] != BH_RESOURCE_BUILD_ID_B1 ||
       data[16] != BH_RESOURCE_BUILD_ID_B2 || data[17] != BH_RESOURCE_BUILD_ID_B3) return 0;

   stored_crc = data[18] | ((u16)data[19] << 8);
   index_end = 20 + ((u16)count * 20);
   for (i = 0; i < count; ++i) {
      entry = data + 20 + ((u16)i * 20);
      dependency_start = entry[13] | ((u16)entry[14] << 8);
      dependency_start += entry[15];
      if (dependency_start > dependency_end) dependency_end = dependency_start;
   }
   index_end += dependency_end * 2;
   for (i = 0; i < index_end; ++i) {
      crc = crc16_byte(crc, (i == 18 || i == 19) ? 0 : data[i]);
   }
   return crc == stored_crc;
}

static u16 crc16_block(const u8* data, u16 size) {
   u16 crc = 0xFFFF;
   while (size--) crc = crc16_byte(crc, *data++);
   return crc;
}

static u8 load_screen(u16 file_sector, u8* destination, u16 expected_crc) {
   BHStorageStatus status = bh_storage_read_range(
      BH_STORAGE_BHRES_FIRST_LOGICAL_SECTOR + file_sector,
      32,
      destination
   );
   if (status != BH_STORAGE_OK) return (u8)status;
   status = crc16_block(destination, 0x4000) == expected_crc ? 0 : 8;
   return status;
}

static void emit_pass(void) {
   __asm
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
   __endasm;
}

static void emit_fail(u8 status) {
   bh_fdc_lab_emit_status = status;
   __asm
      ld bc, #0xEF00
      ld a, #0xC2
      out (c), a
      ld a, #0xC8
      out (c), a
      ld a, #0xDF
      out (c), a
      ld a, #0xC6
      out (c), a
      ld a, #0xC1
      out (c), a
      ld a, #0xC9
      out (c), a
      ld a, #0xCC
      out (c), a
      ld a, (_bh_fdc_lab_emit_status)
      add a, #0xB0
      out (c), a
      ld a, #0xBA
      out (c), a
      ld hl, #_bh_fdc_result
      ld d, #7
   101$:
      ld a, (hl)
      rrca
      rrca
      rrca
      rrca
      call 103$
      ld a, (hl)
      call 103$
      inc hl
      dec d
      jr z, 102$
      ld a, #0xAC
      out (c), a
      jr 101$
   102$:
      ld a, #0x8A
      out (c), a
      jr 104$
   103$:
      and a, #0x0F
      cp a, #10
      jr c, 105$
      add a, #7
   105$:
      add a, #0xB0
      out (c), a
      ret
   104$:
   __endasm;
}

void bh_fdc_lab_run(void) {
   u8 frame;
   u8 cycle;
   u8 status;
   u8 valid;
   u8* page = (u8*)BH_LVMEM_START;
   u8 status_text[2];

   bh_audio_stop();
   bh_fdc_destination = page;
   bh_fdc_track = BH_FDC_LAB_TRACK;
   bh_fdc_sector = BH_FDC_LAB_SECTOR;
   bh_fdc_eot = BH_FDC_LAB_SECTOR;
   bh_fdc_transfer_size = BH_STORAGE_SECTOR_SIZE;
   bh_fdc_motor_on();
   for (frame = 0; frame < 100; ++frame) cpct_waitVSYNC();
   status = bh_fdc_read_request();
   valid = !status && header_is_valid((const u8*)BH_LVMEM_START);

   if (valid) {
      for (cycle = 0; cycle < BH_FDC_LAB_CYCLES; ++cycle) {
         status = load_screen(RESOURCE_LAB_PAPER_FILE_SECTOR, (u8*)BH_LVMEM_START, RESOURCE_LAB_PAPER_CRC16);
         if (status) { valid = 0; break; }
         cpct_setVideoMemoryPage(cpct_page80);
         status = load_screen(RESOURCE_LAB_INK_FILE_SECTOR, (u8*)CPCT_VMEM_START, RESOURCE_LAB_INK_CRC16);
         if (status) { valid = 0; break; }
         cpct_setVideoMemoryPage(cpct_pageC0);
      }
   }
   bh_fdc_motor_off();

   if (valid) {
      emit_pass();
   } else {
      if (!status) status = 7;
      page = (u8*)BH_LVMEM_START;
      cpct_memset(page, cpct_px2byteM0(5, 5), 0x4000);
      cpct_drawSolidBox(cpct_getScreenPtr(page, 2, 18), cpct_px2byteM0(9, 9), 76, 160);
      bh_font_set_colours(0, 9);
      status_text[0] = '0' + status;
      status_text[1] = 0;
      bh_font_draw_string("FDC RESOURCE FAIL", cpct_getScreenPtr(page, 8, 82));
      bh_font_draw_string(status_text, cpct_getScreenPtr(page, 36, 100));
      emit_fail(status);
      cpct_setVideoMemoryPage(cpct_page80);
   }
   __asm
      di
   001$:
      halt
      jr 001$
   __endasm;
}
#endif
