                              1 ;--------------------------------------------------------
                              2 ; File Created by SDCC : free open source ANSI-C Compiler
                              3 ; Version 3.6.8 #9946 (Linux)
                              4 ;--------------------------------------------------------
                              5 	.module main
                              6 	.optsdcc -mz80
                              7 	
                              8 ;--------------------------------------------------------
                              9 ; Public variables in this module
                             10 ;--------------------------------------------------------
                             11 	.globl _main
                             12 	.globl _menu
                             13 	.globl _cpct_setPalette
                             14 	.globl _cpct_setVideoMode
                             15 	.globl _cpct_setStackLocation
                             16 	.globl _cpct_disableFirmware
                             17 	.globl _swap_memvideo
                             18 	.globl _mem_page
                             19 	.globl _mem_start
                             20 	.globl _paleta
                             21 ;--------------------------------------------------------
                             22 ; special function registers
                             23 ;--------------------------------------------------------
                             24 ;--------------------------------------------------------
                             25 ; ram data
                             26 ;--------------------------------------------------------
                             27 	.area _DATA
   5A47                      28 _mem_start::
   5A47                      29 	.ds 2
   5A49                      30 _mem_page::
   5A49                      31 	.ds 1
   5A4A                      32 _swap_memvideo::
   5A4A                      33 	.ds 1
                             34 ;--------------------------------------------------------
                             35 ; ram data
                             36 ;--------------------------------------------------------
                             37 	.area _INITIALIZED
                             38 ;--------------------------------------------------------
                             39 ; absolute external ram data
                             40 ;--------------------------------------------------------
                             41 	.area _DABS (ABS)
                             42 ;--------------------------------------------------------
                             43 ; global & static initialisations
                             44 ;--------------------------------------------------------
                             45 	.area _HOME
                             46 	.area _GSINIT
                             47 	.area _GSFINAL
                             48 	.area _GSINIT
                             49 ;--------------------------------------------------------
                             50 ; Home
                             51 ;--------------------------------------------------------
                             52 	.area _HOME
                             53 	.area _HOME
                             54 ;--------------------------------------------------------
                             55 ; code
                             56 ;--------------------------------------------------------
                             57 	.area _CODE
                             58 ;src/main.c:36: void main(void) {
                             59 ;	---------------------------------
                             60 ; Function main
                             61 ; ---------------------------------
   55DB                      62 _main::
                             63 ;src/main.c:39: cpct_setStackLocation ((u8*) 0x7FFF); //Move stack to right before double buffer 0X8000
   55DB 21 FF 7F      [10]   64 	ld	hl, #0x7fff
   55DE CD E4 58      [17]   65 	call	_cpct_setStackLocation
                             66 ;src/main.c:40: cpct_disableFirmware();
   55E1 CD 43 59      [17]   67 	call	_cpct_disableFirmware
                             68 ;src/main.c:42: cpct_setVideoMode(0); //160x200; 16 colors in screen
   55E4 2E 00         [ 7]   69 	ld	l, #0x00
   55E6 CD 03 59      [17]   70 	call	_cpct_setVideoMode
                             71 ;src/main.c:43: cpct_setPalette(paleta,16);
   55E9 21 10 00      [10]   72 	ld	hl, #0x0010
   55EC E5            [11]   73 	push	hl
   55ED 21 0C 56      [10]   74 	ld	hl, #_paleta
   55F0 E5            [11]   75 	push	hl
   55F1 CD 3C 57      [17]   76 	call	_cpct_setPalette
                             77 ;src/main.c:45: while (1) {
   55F4                      78 00102$:
                             79 ;src/main.c:47: swap_memvideo = 0;
   55F4 21 4A 5A      [10]   80 	ld	hl,#_swap_memvideo + 0
   55F7 36 00         [10]   81 	ld	(hl), #0x00
                             82 ;src/main.c:48: mem_start = (u8*) 0xC000; //CPCT_VMEM_START
   55F9 21 00 C0      [10]   83 	ld	hl, #0xc000
   55FC 22 47 5A      [16]   84 	ld	(_mem_start), hl
                             85 ;src/main.c:49: mem_page = cpct_pageC0; //this likely can be obtained from above, but...
   55FF 21 49 5A      [10]   86 	ld	hl,#_mem_page + 0
   5602 36 30         [10]   87 	ld	(hl), #0x30
                             88 ;src/main.c:51: menu();
   5604 CD 1C 56      [17]   89 	call	_menu
                             90 ;src/main.c:52: game();
   5607 CD 10 41      [17]   91 	call	_game
   560A 18 E8         [12]   92 	jr	00102$
   560C                      93 _paleta:
   560C 14                   94 	.db #0x14	; 20
   560D 0B                   95 	.db #0x0b	; 11
   560E 17                   96 	.db #0x17	; 23
   560F 13                   97 	.db #0x13	; 19
   5610 1B                   98 	.db #0x1b	; 27
   5611 00                   99 	.db #0x00	; 0
   5612 12                  100 	.db #0x12	; 18
   5613 19                  101 	.db #0x19	; 25
   5614 03                  102 	.db #0x03	; 3
   5615 1C                  103 	.db #0x1c	; 28
   5616 05                  104 	.db #0x05	; 5
   5617 0F                  105 	.db #0x0f	; 15
   5618 0E                  106 	.db #0x0e	; 14
   5619 07                  107 	.db #0x07	; 7
   561A 1E                  108 	.db #0x1e	; 30
   561B 04                  109 	.db #0x04	; 4
                            110 	.area _CODE
                            111 	.area _INITIALIZER
                            112 	.area _CABS (ABS)
