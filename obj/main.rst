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
   672B                      30 _mem_start::
   672B                      31 	.ds 2
   672D                      32 _mem_page::
   672D                      33 	.ds 1
   672E                      34 _swap_memvideo::
   672E                      35 	.ds 1
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
   5FA6                      64 _main::
                             65 ;src/main.c:34: cpct_setStackLocation ((u8*) 0x7FFF);        //Move stack to right before double buffer 0X8000
   5FA6 21 FF 7F      [10]   66 	ld	hl, #0x7fff
   5FA9 CD D8 64      [17]   67 	call	_cpct_setStackLocation
                             68 ;src/main.c:35: cpct_disableFirmware();
   5FAC CD 37 65      [17]   69 	call	_cpct_disableFirmware
                             70 ;src/main.c:37: cpct_setVideoMode(0); //160x200; 16 colors in screen
   5FAF 2E 00         [ 7]   71 	ld	l, #0x00
   5FB1 CD F7 64      [17]   72 	call	_cpct_setVideoMode
                             73 ;src/main.c:38: cpct_setPalette(paleta,16);
   5FB4 21 10 00      [10]   74 	ld	hl, #0x0010
   5FB7 E5            [11]   75 	push	hl
   5FB8 21 DA 5F      [10]   76 	ld	hl, #_paleta
   5FBB E5            [11]   77 	push	hl
   5FBC CD BA 62      [17]   78 	call	_cpct_setPalette
                             79 ;src/main.c:40: while (1) {
   5FBF                      80 00102$:
                             81 ;src/main.c:43: swap_memvideo = 0;                        //set DB switch to "zero" (upper VMEM page first)
   5FBF 21 2E 67      [10]   82 	ld	hl,#_swap_memvideo + 0
   5FC2 36 00         [10]   83 	ld	(hl), #0x00
                             84 ;src/main.c:44: mem_start = (u8*) CPCT_VMEM_START;        //upper, standard VMEM page first
   5FC4 21 00 C0      [10]   85 	ld	hl, #0xc000
   5FC7 22 2B 67      [16]   86 	ld	(_mem_start), hl
                             87 ;src/main.c:45: mem_page = cpct_pageC0;                   //upper, C0 page
   5FCA 21 2D 67      [10]   88 	ld	hl,#_mem_page + 0
   5FCD 36 30         [10]   89 	ld	(hl), #0x30
                             90 ;src/main.c:47: menu();
   5FCF CD EA 5F      [17]   91 	call	_menu
                             92 ;src/main.c:48: init_game();
   5FD2 CD DF 42      [17]   93 	call	_init_game
                             94 ;src/main.c:49: game();
   5FD5 CD 5E 43      [17]   95 	call	_game
   5FD8 18 E5         [12]   96 	jr	00102$
   5FDA                      97 _paleta:
   5FDA 14                   98 	.db #0x14	; 20
   5FDB 0B                   99 	.db #0x0b	; 11
   5FDC 17                  100 	.db #0x17	; 23
   5FDD 13                  101 	.db #0x13	; 19
   5FDE 1B                  102 	.db #0x1b	; 27
   5FDF 00                  103 	.db #0x00	; 0
   5FE0 12                  104 	.db #0x12	; 18
   5FE1 19                  105 	.db #0x19	; 25
   5FE2 03                  106 	.db #0x03	; 3
   5FE3 1C                  107 	.db #0x1c	; 28
   5FE4 05                  108 	.db #0x05	; 5
   5FE5 0F                  109 	.db #0x0f	; 15
   5FE6 0E                  110 	.db #0x0e	; 14
   5FE7 07                  111 	.db #0x07	; 7
   5FE8 1E                  112 	.db #0x1e	; 30
   5FE9 04                  113 	.db #0x04	; 4
                            114 	.area _CODE
                            115 	.area _INITIALIZER
                            116 	.area _CABS (ABS)
