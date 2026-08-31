#include "storage.h"

#ifdef BH_FDC_LAB
u8* bh_fdc_destination;
u8 bh_fdc_track;
u8 bh_fdc_sector;
u8 bh_fdc_eot;
u16 bh_fdc_transfer_size;
u8 bh_fdc_result[7];
u8 bh_storage_last_fdc_status;

extern u8 bh_fdc_prepare(void);
extern u8 bh_fdc_seek_track(void);
extern u8 bh_fdc_read_sector(void);

static void logical_sector_to_chs(u16 logical_sector) {
   bh_fdc_track = 0;
   while (logical_sector >= BH_STORAGE_SECTORS_PER_TRACK) {
      logical_sector -= BH_STORAGE_SECTORS_PER_TRACK;
      ++bh_fdc_track;
   }
   bh_fdc_sector = BH_STORAGE_FIRST_SECTOR_ID + (u8)logical_sector;
}

BHStorageStatus bh_storage_read_range(u16 first_logical_sector, u8 sector_count, u8* destination) {
   u8 current_track = 0;
   u8 sectors_this_command;
   u16 transfer_size;
   u8 attempt;
   u8 status;

   if (!sector_count) return BH_STORAGE_OK;
   status = bh_fdc_prepare();
   if (status) {
      bh_storage_last_fdc_status = status;
      return (BHStorageStatus)status;
   }
   logical_sector_to_chs(first_logical_sector);
   if (bh_fdc_track) {
      status = bh_fdc_seek_track();
      if (status) {
         bh_storage_last_fdc_status = status;
         return BH_STORAGE_SEEK_ERROR;
      }
      current_track = bh_fdc_track;
   }

   while (sector_count) {
      sectors_this_command = (0xC9 - bh_fdc_sector) + 1;
      if (sectors_this_command > sector_count) sectors_this_command = sector_count;
      transfer_size = ((u16)sectors_this_command) << 9;
      bh_fdc_eot = bh_fdc_sector + sectors_this_command - 1;
      bh_fdc_transfer_size = transfer_size;
      bh_fdc_destination = destination;
      status = BH_STORAGE_FDC_STATUS;
      for (attempt = 0; attempt < BH_STORAGE_MAX_ATTEMPTS; ++attempt) {
         status = bh_fdc_read_sector();
         if (!status) break;
      }
      if (status) {
         bh_storage_last_fdc_status = status;
         return BH_STORAGE_RETRY_EXHAUSTED;
      }
      destination += transfer_size;
      first_logical_sector += sectors_this_command;
      sector_count -= sectors_this_command;
      if (sector_count) {
         logical_sector_to_chs(first_logical_sector);
         if (bh_fdc_track != current_track) {
            status = bh_fdc_seek_track();
            if (status) {
               bh_storage_last_fdc_status = status;
               return BH_STORAGE_SEEK_ERROR;
            }
            current_track = bh_fdc_track;
         }
      }
   }
   bh_storage_last_fdc_status = BH_STORAGE_OK;
   return BH_STORAGE_OK;
}
#endif
