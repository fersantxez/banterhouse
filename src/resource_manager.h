#ifndef BANTERHOUSE_RESOURCE_MANAGER_H
#define BANTERHOUSE_RESOURCE_MANAGER_H

#include "bh_types.h"

typedef u16 BHResourceId;

typedef enum {
   BH_RESOURCE_OK = 0,
   BH_RESOURCE_NOT_FOUND,
   BH_RESOURCE_BAD_TARGET,
   BH_RESOURCE_TOO_LARGE,
   BH_RESOURCE_BACKEND_ERROR,
   BH_RESOURCE_STALE_HANDLE,
   BH_RESOURCE_BAD_DESCRIPTOR
} BHResourceStatus;

typedef struct {
   BHResourceId id;
   u8 type;
   u8 bank;
   u16 address;
   u16 size;
   u16 first_sector;
   u8 sector_count;
   u16 crc16;
} BHResourceDescriptor;

typedef struct {
   BHResourceId id;
   u8 bank;
   u16 address;
   u16 size;
   u16 generation;
} BHResourceHandle;

typedef struct {
   BHResourceId owner;
   u8 bank;
   u16 address;
   u16 capacity;
   u16 size;
   u16 generation;
} BHResourceSlot;

typedef BHResourceStatus (*BHResourceBackend)(const BHResourceDescriptor* descriptor, void* context);

typedef struct {
   const BHResourceDescriptor* descriptors;
   u8 descriptor_count;
   BHResourceBackend backend;
   void* backend_context;
   BHResourceSlot slots[4];
} BHResourceManager;

BHResourceStatus bh_resource_manager_init(
   BHResourceManager* manager,
   const BHResourceDescriptor* descriptors,
   u8 descriptor_count,
   BHResourceBackend backend,
   void* backend_context
);
BHResourceStatus bh_resource_load(BHResourceManager* manager, BHResourceId id, BHResourceHandle* output);
BHResourceStatus bh_resource_preload(BHResourceManager* manager, BHResourceId id);
BHResourceStatus bh_resource_get(const BHResourceManager* manager, BHResourceId id, BHResourceHandle* output);
BHResourceStatus bh_resource_validate(const BHResourceManager* manager, const BHResourceHandle* handle);
BHResourceStatus bh_resource_unload(BHResourceManager* manager, BHResourceId id);

#endif
