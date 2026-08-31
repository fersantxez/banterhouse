#ifndef BANTERHOUSE_STORAGE_H
#define BANTERHOUSE_STORAGE_H

#include "bh_types.h"

typedef enum {
   BH_STORAGE_OK = 0,
   BH_STORAGE_COMMAND_TIMEOUT = 1,
   BH_STORAGE_SEEK_ERROR = 2,
   BH_STORAGE_EARLY_RESULT = 3,
   BH_STORAGE_DATA_TIMEOUT = 4,
   BH_STORAGE_RESULT_TIMEOUT = 5,
   BH_STORAGE_FDC_STATUS = 6,
   BH_STORAGE_RETRY_EXHAUSTED = 7
} BHStorageStatus;

#define BH_STORAGE_SECTOR_SIZE 512
#define BH_STORAGE_SECTORS_PER_TRACK 9
#define BH_STORAGE_FIRST_SECTOR_ID 0xC1
#define BH_STORAGE_BHRES_FIRST_LOGICAL_SECTOR 4
#define BH_STORAGE_MAX_ATTEMPTS 3

extern u8 bh_storage_last_fdc_status;

BHStorageStatus bh_storage_read_range(u16 first_logical_sector, u8 sector_count, u8* destination);

#endif
