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
                             12 	.globl _game
                             13 	.globl _init_game
                             14 	.globl _menu
                             15 	.globl _cpct_setPalette
                             16 	.globl _cpct_setVideoMode
                             17 	.globl _cpct_setStackLocation
                             18 	.globl _cpct_disableFirmware
                             19 	.globl _anim_clock
                             20 	.globl _sprites
                             21 	.globl _map
                             22 	.globl _swap_memvideo
                             23 	.globl _mem_page
                             24 	.globl _mem_start
                             25 	.globl _paleta
                             26 ;--------------------------------------------------------
                             27 ; special function registers
                             28 ;--------------------------------------------------------
                             29 ;--------------------------------------------------------
                             30 ; ram data
                             31 ;--------------------------------------------------------
                             32 	.area _DATA
   69AA                      33 _mem_start::
   69AA                      34 	.ds 2
   69AC                      35 _mem_page::
   69AC                      36 	.ds 1
   69AD                      37 _swap_memvideo::
   69AD                      38 	.ds 1
   69AE                      39 _map::
   69AE                      40 	.ds 460
   6B7A                      41 _sprites::
   6B7A                      42 	.ds 240
   6C6A                      43 _anim_clock::
   6C6A                      44 	.ds 1
                             45 ;--------------------------------------------------------
                             46 ; ram data
                             47 ;--------------------------------------------------------
                             48 	.area _INITIALIZED
                             49 ;--------------------------------------------------------
                             50 ; absolute external ram data
                             51 ;--------------------------------------------------------
                             52 	.area _DABS (ABS)
                             53 ;--------------------------------------------------------
                             54 ; global & static initialisations
                             55 ;--------------------------------------------------------
                             56 	.area _HOME
                             57 	.area _GSINIT
                             58 	.area _GSFINAL
                             59 	.area _GSINIT
                             60 ;--------------------------------------------------------
                             61 ; Home
                             62 ;--------------------------------------------------------
                             63 	.area _HOME
                             64 	.area _HOME
                             65 ;--------------------------------------------------------
                             66 ; code
                             67 ;--------------------------------------------------------
                             68 	.area _CODE
                             69 ;src/main.c:38: void main(void) {
                             70 ;	---------------------------------
                             71 ; Function main
                             72 ; ---------------------------------
   629A                      73 _main::
                             74 ;src/main.c:41: cpct_setStackLocation ((u8*) 0x7FFF);        //Move stack to right before double buffer 0X8000
   629A 21 FF 7F      [10]   75 	ld	hl, #0x7fff
   629D CD B7 68      [17]   76 	call	_cpct_setStackLocation
                             77 ;src/main.c:42: cpct_disableFirmware();
   62A0 CD 1E 69      [17]   78 	call	_cpct_disableFirmware
                             79 ;src/main.c:44: cpct_setVideoMode(0); //160x200; 16 colors in screen
   62A3 2E 00         [ 7]   80 	ld	l, #0x00
   62A5 CD D6 68      [17]   81 	call	_cpct_setVideoMode
                             82 ;src/main.c:45: cpct_setPalette(paleta,16);
   62A8 21 10 00      [10]   83 	ld	hl, #0x0010
   62AB E5            [11]   84 	push	hl
   62AC 21 CE 62      [10]   85 	ld	hl, #_paleta
   62AF E5            [11]   86 	push	hl
   62B0 CD F4 65      [17]   87 	call	_cpct_setPalette
                             88 ;src/main.c:47: while (1) {
   62B3                      89 00102$:
                             90 ;src/main.c:50: swap_memvideo = 0;                        //set DB switch to "zero" (upper VMEM page first)
   62B3 21 AD 69      [10]   91 	ld	hl,#_swap_memvideo + 0
   62B6 36 00         [10]   92 	ld	(hl), #0x00
                             93 ;src/main.c:51: mem_start = (u8*) CPCT_VMEM_START;        //upper, standard VMEM page first
   62B8 21 00 C0      [10]   94 	ld	hl, #0xc000
   62BB 22 AA 69      [16]   95 	ld	(_mem_start), hl
                             96 ;src/main.c:52: mem_page = cpct_pageC0;                   //upper, C0 page
   62BE 21 AC 69      [10]   97 	ld	hl,#_mem_page + 0
   62C1 36 30         [10]   98 	ld	(hl), #0x30
                             99 ;src/main.c:54: menu();
   62C3 CD DE 62      [17]  100 	call	_menu
                            101 ;src/main.c:55: init_game();
   62C6 CD D0 45      [17]  102 	call	_init_game
                            103 ;src/main.c:56: game();
   62C9 CD 4F 46      [17]  104 	call	_game
   62CC 18 E5         [12]  105 	jr	00102$
   62CE                     106 _paleta:
   62CE 14                  107 	.db #0x14	; 20
   62CF 0B                  108 	.db #0x0b	; 11
   62D0 17                  109 	.db #0x17	; 23
   62D1 13                  110 	.db #0x13	; 19
   62D2 1B                  111 	.db #0x1b	; 27
   62D3 00                  112 	.db #0x00	; 0
   62D4 12                  113 	.db #0x12	; 18
   62D5 19                  114 	.db #0x19	; 25
   62D6 03                  115 	.db #0x03	; 3
   62D7 1C                  116 	.db #0x1c	; 28
   62D8 05                  117 	.db #0x05	; 5
   62D9 0F                  118 	.db #0x0f	; 15
   62DA 0E                  119 	.db #0x0e	; 14
   62DB 07                  120 	.db #0x07	; 7
   62DC 1E                  121 	.db #0x1e	; 30
   62DD 04                  122 	.db #0x04	; 4
                            123 	.area _CODE
                            124 	.area _INITIALIZER
                            125 	.area _CABS (ABS)
