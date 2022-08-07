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
   604F                      30 _mem_start::
   604F                      31 	.ds 2
   6051                      32 _mem_page::
   6051                      33 	.ds 1
   6052                      34 _swap_memvideo::
   6052                      35 	.ds 1
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
   5823                      64 _main::
                             65 ;src/main.c:34: cpct_setStackLocation ((u8*) 0x7FFF);        //Move stack to right before double buffer 0X8000
   5823 21 FF 7F      [10]   66 	ld	hl, #0x7fff
   5826 CD FC 5D      [17]   67 	call	_cpct_setStackLocation
                             68 ;src/main.c:35: cpct_disableFirmware();
   5829 CD 5B 5E      [17]   69 	call	_cpct_disableFirmware
                             70 ;src/main.c:37: cpct_setVideoMode(0); //160x200; 16 colors in screen
   582C 2E 00         [ 7]   71 	ld	l, #0x00
   582E CD 1B 5E      [17]   72 	call	_cpct_setVideoMode
                             73 ;src/main.c:38: cpct_setPalette(paleta,16);
   5831 21 10 00      [10]   74 	ld	hl, #0x0010
   5834 E5            [11]   75 	push	hl
   5835 21 57 58      [10]   76 	ld	hl, #_paleta
   5838 E5            [11]   77 	push	hl
   5839 CD A0 5B      [17]   78 	call	_cpct_setPalette
                             79 ;src/main.c:40: while (1) {
   583C                      80 00102$:
                             81 ;src/main.c:43: swap_memvideo = 0;                        //set DB switch to "zero" (upper VMEM page first)
   583C 21 52 60      [10]   82 	ld	hl,#_swap_memvideo + 0
   583F 36 00         [10]   83 	ld	(hl), #0x00
                             84 ;src/main.c:44: mem_start = (u8*) CPCT_VMEM_START;        //upper, standard VMEM page first
   5841 21 00 C0      [10]   85 	ld	hl, #0xc000
   5844 22 4F 60      [16]   86 	ld	(_mem_start), hl
                             87 ;src/main.c:45: mem_page = cpct_pageC0;                   //upper, C0 page
   5847 21 51 60      [10]   88 	ld	hl,#_mem_page + 0
   584A 36 30         [10]   89 	ld	(hl), #0x30
                             90 ;src/main.c:47: menu();
   584C CD 67 58      [17]   91 	call	_menu
                             92 ;src/main.c:48: init_game();
   584F CD D0 42      [17]   93 	call	_init_game
                             94 ;src/main.c:49: game();
   5852 CD 4F 43      [17]   95 	call	_game
   5855 18 E5         [12]   96 	jr	00102$
   5857                      97 _paleta:
   5857 14                   98 	.db #0x14	; 20
   5858 0B                   99 	.db #0x0b	; 11
   5859 17                  100 	.db #0x17	; 23
   585A 13                  101 	.db #0x13	; 19
   585B 1B                  102 	.db #0x1b	; 27
   585C 00                  103 	.db #0x00	; 0
   585D 12                  104 	.db #0x12	; 18
   585E 19                  105 	.db #0x19	; 25
   585F 03                  106 	.db #0x03	; 3
   5860 1C                  107 	.db #0x1c	; 28
   5861 05                  108 	.db #0x05	; 5
   5862 0F                  109 	.db #0x0f	; 15
   5863 0E                  110 	.db #0x0e	; 14
   5864 07                  111 	.db #0x07	; 7
   5865 1E                  112 	.db #0x1e	; 30
   5866 04                  113 	.db #0x04	; 4
                            114 	.area _CODE
                            115 	.area _INITIALIZER
                            116 	.area _CABS (ABS)
