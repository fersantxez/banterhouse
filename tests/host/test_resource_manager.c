#include <assert.h>
#include <stdio.h>
#include <string.h>

#include "resource_manager.h"

typedef struct {
   u16 calls;
   BHResourceId fail_id;
   u8 banks[4][14336];
} FakeBackend;

static BHResourceStatus fake_load(const BHResourceDescriptor* descriptor, void* context) {
   FakeBackend* backend = (FakeBackend*)context;
   ++backend->calls;
   if (descriptor->id == backend->fail_id) return BH_RESOURCE_BACKEND_ERROR;
   memset(backend->banks[descriptor->bank - 4], descriptor->id & 0xFF, descriptor->size);
   return BH_RESOURCE_OK;
}

int main(void) {
   static const BHResourceDescriptor descriptors[] = {
      {0x0301, 4, 4, 0x4000, 4096, 10, 8, 0x1111},
      {0x0201, 2, 5, 0x4000, 8192, 20, 16, 0x2222},
      {0x0601, 8, 6, 0x4000, 6144, 40, 12, 0x3333},
      {0x0501, 7, 7, 0x4000, 2048, 60, 4, 0x4444},
      {0x0302, 4, 4, 0x4000, 2048, 70, 4, 0x5555},
      {0x0303, 4, 4, 0x4000, 15000, 80, 30, 0x6666}
   };
   BHResourceManager manager;
   FakeBackend backend;
   BHResourceHandle handle;
   BHResourceHandle stale;
   u16 cycle;
   u8 index;
   static const BHResourceId ids[4] = {0x0301, 0x0201, 0x0601, 0x0501};

   memset(&backend, 0, sizeof(backend));
   assert(bh_resource_manager_init(&manager, descriptors, 6, fake_load, &backend) == BH_RESOURCE_OK);
   for (index = 0; index < 4; ++index) {
      for (cycle = 0; cycle < 100; ++cycle) {
         assert(bh_resource_load(&manager, ids[index], &handle) == BH_RESOURCE_OK);
         assert(handle.bank == index + 4);
         assert(bh_resource_validate(&manager, &handle) == BH_RESOURCE_OK);
         stale = handle;
         assert(bh_resource_unload(&manager, ids[index]) == BH_RESOURCE_OK);
         assert(bh_resource_validate(&manager, &stale) == BH_RESOURCE_STALE_HANDLE);
      }
   }
   assert(backend.calls == 400);
   assert(bh_resource_load(&manager, 0xFFFF, &handle) == BH_RESOURCE_NOT_FOUND);
   assert(bh_resource_load(&manager, 0x0303, &handle) == BH_RESOURCE_TOO_LARGE);

   assert(bh_resource_load(&manager, 0x0301, &handle) == BH_RESOURCE_OK);
   stale = handle;
   backend.fail_id = 0x0302;
   assert(bh_resource_load(&manager, 0x0302, &handle) == BH_RESOURCE_BACKEND_ERROR);
   assert(bh_resource_validate(&manager, &stale) == BH_RESOURCE_OK);
   assert(bh_resource_get(&manager, 0x0301, &handle) == BH_RESOURCE_OK);

   puts("Host resource manager/handle tests: PASS (400 load/unload cycles)");
   return 0;
}
