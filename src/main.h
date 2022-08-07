
//Double Buffer config

//lower "double buffer" page start
#define CPCT_LVMEM_START 0x8000

extern u8* mem_start; //current vmem_start - 0xC000/CPCT_VMEM_START or 0x8000/CPCT_LVMEM_START for "page" 0 or 1
extern u8 mem_page;   //used for CRTC to know which page to start on - can be deduced from above
extern u8 swap_memvideo; //boolean switch one to the other

