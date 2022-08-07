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
                             12 	.globl _init_game
                             13 	.globl _menu
                             14 	.globl _cpct_setPalette
                             15 	.globl _cpct_setVideoMode
                             16 	.globl _cpct_setStackLocation
                             17 	.globl _cpct_disableFirmware
                             18 	.globl _swap_memvideo
                             19 	.globl _mem_page
                             20 	.globl _mem_start
                             21 	.globl _paleta
                             22 ;--------------------------------------------------------
                             23 ; special function registers
                             24 ;--------------------------------------------------------
                             25 ;--------------------------------------------------------
                             26 ; ram data
                             27 ;--------------------------------------------------------
                             28 	.area _DATA
   5E8B                      29 _mem_start::
   5E8B                      30 	.ds 2
   5E8D                      31 _mem_page::
   5E8D                      32 	.ds 1
   5E8E                      33 _swap_memvideo::
   5E8E                      34 	.ds 1
                             35 ;--------------------------------------------------------
                             36 ; ram data
                             37 ;--------------------------------------------------------
                             38 	.area _INITIALIZED
                             39 ;--------------------------------------------------------
                             40 ; absolute external ram data
                             41 ;--------------------------------------------------------
                             42 	.area _DABS (ABS)
                             43 ;--------------------------------------------------------
                             44 ; global & static initialisations
                             45 ;--------------------------------------------------------
                             46 	.area _HOME
                             47 	.area _GSINIT
                             48 	.area _GSFINAL
                             49 	.area _GSINIT
                             50 ;--------------------------------------------------------
                             51 ; Home
                             52 ;--------------------------------------------------------
                             53 	.area _HOME
                             54 	.area _HOME
                             55 ;--------------------------------------------------------
                             56 ; code
                             57 ;--------------------------------------------------------
                             58 	.area _CODE
                             59 ;src/main.c:37: void main(void) {
                             60 ;	---------------------------------
                             61 ; Function main
                             62 ; ---------------------------------
   57A9                      63 _main::
                             64 ;src/main.c:40: cpct_setStackLocation ((u8*) 0x7FFF); //Move stack to right before double buffer 0X8000
   57A9 21 FF 7F      [10]   65 	ld	hl, #0x7fff
   57AC CD 4B 5C      [17]   66 	call	_cpct_setStackLocation
                             67 ;src/main.c:41: cpct_disableFirmware();
   57AF CD AA 5C      [17]   68 	call	_cpct_disableFirmware
                             69 ;src/main.c:43: cpct_setVideoMode(0); //160x200; 16 colors in screen
   57B2 2E 00         [ 7]   70 	ld	l, #0x00
   57B4 CD 6A 5C      [17]   71 	call	_cpct_setVideoMode
                             72 ;src/main.c:44: cpct_setPalette(paleta,16);
   57B7 21 10 00      [10]   73 	ld	hl, #0x0010
   57BA E5            [11]   74 	push	hl
   57BB 21 DD 57      [10]   75 	ld	hl, #_paleta
   57BE E5            [11]   76 	push	hl
   57BF CD 2D 5A      [17]   77 	call	_cpct_setPalette
                             78 ;src/main.c:46: while (1) {
   57C2                      79 00102$:
                             80 ;src/main.c:48: swap_memvideo = 0;
   57C2 21 8E 5E      [10]   81 	ld	hl,#_swap_memvideo + 0
   57C5 36 00         [10]   82 	ld	(hl), #0x00
                             83 ;src/main.c:49: mem_start = (u8*) CPCT_VMEM_START;
   57C7 21 00 C0      [10]   84 	ld	hl, #0xc000
   57CA 22 8B 5E      [16]   85 	ld	(_mem_start), hl
                             86 ;src/main.c:50: mem_page = cpct_pageC0; //this likely can be obtained from above, but...
   57CD 21 8D 5E      [10]   87 	ld	hl,#_mem_page + 0
   57D0 36 30         [10]   88 	ld	(hl), #0x30
                             89 ;src/main.c:52: menu();
   57D2 CD ED 57      [17]   90 	call	_menu
                             91 ;src/main.c:53: init_game();
   57D5 CD 10 41      [17]   92 	call	_init_game
                             93 ;src/main.c:54: game();
   57D8 CD D3 42      [17]   94 	call	_game
   57DB 18 E5         [12]   95 	jr	00102$
   57DD                      96 _paleta:
   57DD 14                   97 	.db #0x14	; 20
   57DE 0B                   98 	.db #0x0b	; 11
   57DF 17                   99 	.db #0x17	; 23
   57E0 13                  100 	.db #0x13	; 19
   57E1 1B                  101 	.db #0x1b	; 27
   57E2 00                  102 	.db #0x00	; 0
   57E3 12                  103 	.db #0x12	; 18
   57E4 19                  104 	.db #0x19	; 25
   57E5 03                  105 	.db #0x03	; 3
   57E6 1C                  106 	.db #0x1c	; 28
   57E7 05                  107 	.db #0x05	; 5
   57E8 0F                  108 	.db #0x0f	; 15
   57E9 0E                  109 	.db #0x0e	; 14
   57EA 07                  110 	.db #0x07	; 7
   57EB 1E                  111 	.db #0x1e	; 30
   57EC 04                  112 	.db #0x04	; 4
                            113 	.area _CODE
                            114 	.area _INITIALIZER
                            115 	.area _CABS (ABS)
