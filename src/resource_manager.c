#include "resource_manager.h"

static const u16 slot_capacities[4] = {14336, 14336, 12288, 14336};

static const BHResourceDescriptor* find_descriptor(const BHResourceManager* manager, BHResourceId id) {
   u8 index;
   for (index = 0; index < manager->descriptor_count; ++index) {
      if (manager->descriptors[index].id == id) return &manager->descriptors[index];
   }
   return 0;
}

static BHResourceSlot* slot_for_bank(BHResourceManager* manager, u8 bank) {
   if (bank < 4 || bank > 7) return 0;
   return &manager->slots[bank - 4];
}

static const BHResourceSlot* const_slot_for_bank(const BHResourceManager* manager, u8 bank) {
   if (bank < 4 || bank > 7) return 0;
   return &manager->slots[bank - 4];
}

static void fill_handle(const BHResourceSlot* slot, BHResourceHandle* output) {
   output->id = slot->owner;
   output->bank = slot->bank;
   output->address = slot->address;
   output->size = slot->size;
   output->generation = slot->generation;
}

BHResourceStatus bh_resource_manager_init(
   BHResourceManager* manager,
   const BHResourceDescriptor* descriptors,
   u8 descriptor_count,
   BHResourceBackend backend,
   void* backend_context
) {
   u8 index;
   u8 other;
   if (!manager || !descriptors || !descriptor_count || !backend) return BH_RESOURCE_BAD_DESCRIPTOR;
   for (index = 0; index < descriptor_count; ++index) {
      if (!descriptors[index].id || descriptors[index].bank < 4 || descriptors[index].bank > 7 ||
          descriptors[index].address < 0x4000 || descriptors[index].address >= 0x8000 ||
          !descriptors[index].size) return BH_RESOURCE_BAD_DESCRIPTOR;
      for (other = index + 1; other < descriptor_count; ++other) {
         if (descriptors[index].id == descriptors[other].id) return BH_RESOURCE_BAD_DESCRIPTOR;
      }
   }
   manager->descriptors = descriptors;
   manager->descriptor_count = descriptor_count;
   manager->backend = backend;
   manager->backend_context = backend_context;
   for (index = 0; index < 4; ++index) {
      manager->slots[index].owner = 0;
      manager->slots[index].bank = index + 4;
      manager->slots[index].address = 0x4000;
      manager->slots[index].capacity = slot_capacities[index];
      manager->slots[index].size = 0;
      manager->slots[index].generation = 1;
   }
   return BH_RESOURCE_OK;
}

BHResourceStatus bh_resource_get(const BHResourceManager* manager, BHResourceId id, BHResourceHandle* output) {
   u8 index;
   if (!output) return BH_RESOURCE_BAD_DESCRIPTOR;
   for (index = 0; index < 4; ++index) {
      if (manager->slots[index].owner == id) {
         fill_handle(&manager->slots[index], output);
         return BH_RESOURCE_OK;
      }
   }
   return BH_RESOURCE_NOT_FOUND;
}

BHResourceStatus bh_resource_load(BHResourceManager* manager, BHResourceId id, BHResourceHandle* output) {
   const BHResourceDescriptor* descriptor;
   BHResourceSlot* slot;
   BHResourceStatus status;
   if (!output) return BH_RESOURCE_BAD_DESCRIPTOR;
   if (bh_resource_get(manager, id, output) == BH_RESOURCE_OK) return BH_RESOURCE_OK;
   descriptor = find_descriptor(manager, id);
   if (!descriptor) return BH_RESOURCE_NOT_FOUND;
   slot = slot_for_bank(manager, descriptor->bank);
   if (!slot) return BH_RESOURCE_BAD_TARGET;
   if (descriptor->address != slot->address || descriptor->size > slot->capacity) return BH_RESOURCE_TOO_LARGE;

   /* Backend contract: failure leaves the destination slot unchanged (normally
    * by validating in staging). Ownership/generation commit only on success. */
   status = manager->backend(descriptor, manager->backend_context);
   if (status != BH_RESOURCE_OK) return BH_RESOURCE_BACKEND_ERROR;
   ++slot->generation;
   if (!slot->generation) ++slot->generation;
   slot->owner = descriptor->id;
   slot->size = descriptor->size;
   fill_handle(slot, output);
   return BH_RESOURCE_OK;
}

BHResourceStatus bh_resource_preload(BHResourceManager* manager, BHResourceId id) {
   BHResourceHandle ignored;
   return bh_resource_load(manager, id, &ignored);
}

BHResourceStatus bh_resource_validate(const BHResourceManager* manager, const BHResourceHandle* handle) {
   const BHResourceSlot* slot;
   if (!handle) return BH_RESOURCE_STALE_HANDLE;
   slot = const_slot_for_bank(manager, handle->bank);
   if (!slot || slot->owner != handle->id || slot->generation != handle->generation ||
       slot->address != handle->address || slot->size != handle->size) return BH_RESOURCE_STALE_HANDLE;
   return BH_RESOURCE_OK;
}

BHResourceStatus bh_resource_unload(BHResourceManager* manager, BHResourceId id) {
   u8 index;
   for (index = 0; index < 4; ++index) {
      if (manager->slots[index].owner == id) {
         manager->slots[index].owner = 0;
         manager->slots[index].size = 0;
         ++manager->slots[index].generation;
         if (!manager->slots[index].generation) ++manager->slots[index].generation;
         return BH_RESOURCE_OK;
      }
   }
   return BH_RESOURCE_NOT_FOUND;
}
