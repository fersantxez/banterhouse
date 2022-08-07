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
                             19 	.globl _swap_memvideo
                             20 	.globl _mem_page
                             21 	.globl _mem_start
                             22 	.globl _paleta
                             23 ;--------------------------------------------------------
                             24 ; special function registers
                             25 ;--------------------------------------------------------
                             26 ;--------------------------------------------------------
                             27 ; ram data
                             28 ;--------------------------------------------------------
                             29 	.area _DATA
   5EB3                      30 _mem_start::
   5EB3                      31 	.ds 2
   5EB5                      32 _mem_page::
   5EB5                      33 	.ds 1
   5EB6                      34 _swap_memvideo::
   5EB6                      35 	.ds 1
                             36 ;--------------------------------------------------------
                             37 ; ram data
                             38 ;--------------------------------------------------------
                             39 	.area _INITIALIZED
                             40 ;--------------------------------------------------------
                             41 ; absolute external ram data
                             42 ;--------------------------------------------------------
                             43 	.area _DABS (ABS)
                             44 ;--------------------------------------------------------
                             45 ; global & static initialisations
                             46 ;--------------------------------------------------------
                             47 	.area _HOME
                             48 	.area _GSINIT
                             49 	.area _GSFINAL
                             50 	.area _GSINIT
                             51 ;--------------------------------------------------------
                             52 ; Home
                             53 ;--------------------------------------------------------
                             54 	.area _HOME
                             55 	.area _HOME
                             56 ;--------------------------------------------------------
                             57 ; code
                             58 ;--------------------------------------------------------
                             59 	.area _CODE
                             60 ;src/main.c:31: void main(void) {
                             61 ;	---------------------------------
                             62 ; Function main
                             63 ; ---------------------------------
   57D1                      64 _main::
                             65 ;src/main.c:34: cpct_setStackLocation ((u8*) 0x7FFF);        //Move stack to right before double buffer 0X8000
   57D1 21 FF 7F      [10]   66 	ld	hl, #0x7fff
   57D4 CD 73 5C      [17]   67 	call	_cpct_setStackLocation
                             68 ;src/main.c:35: cpct_disableFirmware();
   57D7 CD D2 5C      [17]   69 	call	_cpct_disableFirmware
                             70 ;src/main.c:37: cpct_setVideoMode(0); //160x200; 16 colors in screen
   57DA 2E 00         [ 7]   71 	ld	l, #0x00
   57DC CD 92 5C      [17]   72 	call	_cpct_setVideoMode
                             73 ;src/main.c:38: cpct_setPalette(paleta,16);
   57DF 21 10 00      [10]   74 	ld	hl, #0x0010
   57E2 E5            [11]   75 	push	hl
   57E3 21 05 58      [10]   76 	ld	hl, #_paleta
   57E6 E5            [11]   77 	push	hl
   57E7 CD 55 5A      [17]   78 	call	_cpct_setPalette
                             79 ;src/main.c:40: while (1) {
   57EA                      80 00102$:
                             81 ;src/main.c:43: swap_memvideo = 0;                        //set DB switch to "zero" (upper VMEM page first)
   57EA 21 B6 5E      [10]   82 	ld	hl,#_swap_memvideo + 0
   57ED 36 00         [10]   83 	ld	(hl), #0x00
                             84 ;src/main.c:44: mem_start = (u8*) CPCT_VMEM_START;        //upper, standard VMEM page first
   57EF 21 00 C0      [10]   85 	ld	hl, #0xc000
   57F2 22 B3 5E      [16]   86 	ld	(_mem_start), hl
                             87 ;src/main.c:45: mem_page = cpct_pageC0;                   //upper, C0 page
   57F5 21 B5 5E      [10]   88 	ld	hl,#_mem_page + 0
   57F8 36 30         [10]   89 	ld	(hl), #0x30
                             90 ;src/main.c:47: menu();
   57FA CD 15 58      [17]   91 	call	_menu
                             92 ;src/main.c:48: init_game();
   57FD CD 85 42      [17]   93 	call	_init_game
                             94 ;src/main.c:49: game();
   5800 CD FB 42      [17]   95 	call	_game
   5803 18 E5         [12]   96 	jr	00102$
   5805                      97 _paleta:
   5805 14                   98 	.db #0x14	; 20
   5806 0B                   99 	.db #0x0b	; 11
   5807 17                  100 	.db #0x17	; 23
   5808 13                  101 	.db #0x13	; 19
   5809 1B                  102 	.db #0x1b	; 27
   580A 00                  103 	.db #0x00	; 0
   580B 12                  104 	.db #0x12	; 18
   580C 19                  105 	.db #0x19	; 25
   580D 03                  106 	.db #0x03	; 3
   580E 1C                  107 	.db #0x1c	; 28
   580F 05                  108 	.db #0x05	; 5
   5810 0F                  109 	.db #0x0f	; 15
   5811 0E                  110 	.db #0x0e	; 14
   5812 07                  111 	.db #0x07	; 7
   5813 1E                  112 	.db #0x1e	; 30
   5814 04                  113 	.db #0x04	; 4
                            114 	.area _CODE
                            115 	.area _INITIALIZER
                            116 	.area _CABS (ABS)
