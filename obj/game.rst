                              1 ;--------------------------------------------------------
                              2 ; File Created by SDCC : free open source ANSI-C Compiler
                              3 ; Version 3.6.8 #9946 (Linux)
                              4 ;--------------------------------------------------------
                              5 	.module game
                              6 	.optsdcc -mz80
                              7 	
                              8 ;--------------------------------------------------------
                              9 ; Public variables in this module
                             10 ;--------------------------------------------------------
                             11 	.globl _game
                             12 	.globl _renderSprites
                             13 	.globl _renderDelete
                             14 	.globl _cpct_setVideoMemoryPage
                             15 	.globl _cpct_setPALColour
                             16 	.globl _cpct_waitVSYNC
                             17 	.globl _cpct_px2byteM0
                             18 	.globl _cpct_memset
                             19 	.globl _coord_x
                             20 ;--------------------------------------------------------
                             21 ; special function registers
                             22 ;--------------------------------------------------------
                             23 ;--------------------------------------------------------
                             24 ; ram data
                             25 ;--------------------------------------------------------
                             26 	.area _DATA
   5A46                      27 _coord_x::
   5A46                      28 	.ds 1
                             29 ;--------------------------------------------------------
                             30 ; ram data
                             31 ;--------------------------------------------------------
                             32 	.area _INITIALIZED
                             33 ;--------------------------------------------------------
                             34 ; absolute external ram data
                             35 ;--------------------------------------------------------
                             36 	.area _DABS (ABS)
                             37 ;--------------------------------------------------------
                             38 ; global & static initialisations
                             39 ;--------------------------------------------------------
                             40 	.area _HOME
                             41 	.area _GSINIT
                             42 	.area _GSFINAL
                             43 	.area _GSINIT
                             44 ;--------------------------------------------------------
                             45 ; Home
                             46 ;--------------------------------------------------------
                             47 	.area _HOME
                             48 	.area _HOME
                             49 ;--------------------------------------------------------
                             50 ; code
                             51 ;--------------------------------------------------------
                             52 	.area _CODE
                             53 ;src/game.c:8: void game(){
                             54 ;	---------------------------------
                             55 ; Function game
                             56 ; ---------------------------------
   4110                      57 _game::
                             58 ;src/game.c:9: cpct_setBorder(HW_BLACK);
   4110 21 10 14      [10]   59 	ld	hl, #0x1410
   4113 E5            [11]   60 	push	hl
   4114 CD 53 57      [17]   61 	call	_cpct_setPALColour
                             62 ;src/game.c:11: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
   4117 21 05 05      [10]   63 	ld	hl, #0x0505
   411A E5            [11]   64 	push	hl
   411B CD 19 59      [17]   65 	call	_cpct_px2byteM0
   411E 45            [ 4]   66 	ld	b, l
   411F 21 00 80      [10]   67 	ld	hl, #0x8000
   4122 E5            [11]   68 	push	hl
   4123 C5            [11]   69 	push	bc
   4124 33            [ 6]   70 	inc	sp
   4125 2E 00         [ 7]   71 	ld	l, #0x00
   4127 E5            [11]   72 	push	hl
   4128 CD 35 59      [17]   73 	call	_cpct_memset
                             74 ;src/game.c:13: coord_x = 0;
   412B 21 46 5A      [10]   75 	ld	hl,#_coord_x + 0
   412E 36 00         [10]   76 	ld	(hl), #0x00
                             77 ;src/game.c:15: while (1) {
   4130                      78 00107$:
                             79 ;src/game.c:17: if (!swap_memvideo) { 				//switch
   4130 3A 4A 5A      [13]   80 	ld	a,(#_swap_memvideo + 0)
   4133 B7            [ 4]   81 	or	a, a
   4134 20 0D         [12]   82 	jr	NZ,00102$
                             83 ;src/game.c:18: mem_start = (u8*) 0x8000;//CPCT_LVMEM_START;		//lower page
   4136 21 00 80      [10]   84 	ld	hl, #0x8000
   4139 22 47 5A      [16]   85 	ld	(_mem_start), hl
                             86 ;src/game.c:19: mem_page = cpct_page80;					//FIXME:: can probably delete??
   413C 21 49 5A      [10]   87 	ld	hl,#_mem_page + 0
   413F 36 20         [10]   88 	ld	(hl), #0x20
   4141 18 0B         [12]   89 	jr	00103$
   4143                      90 00102$:
                             91 ;src/game.c:21: mem_start = (u8*) 0xC000;//CPCT_VMEM_START;		//upper,regular VMEM page
   4143 21 00 C0      [10]   92 	ld	hl, #0xc000
   4146 22 47 5A      [16]   93 	ld	(_mem_start), hl
                             94 ;src/game.c:22: mem_page = cpct_pageC0;
   4149 21 49 5A      [10]   95 	ld	hl,#_mem_page + 0
   414C 36 30         [10]   96 	ld	(hl), #0x30
   414E                      97 00103$:
                             98 ;src/game.c:25: renderDelete();							//delete the sprites--- only the changed ones?
   414E CD A0 56      [17]   99 	call	_renderDelete
                            100 ;src/game.c:26: renderSprites();						//paint the new sprites???
   4151 CD 83 56      [17]  101 	call	_renderSprites
                            102 ;src/game.c:27: swap_memvideo = ~swap_memvideo; 		//flip the switch
   4154 FD 21 4A 5A   [14]  103 	ld	iy, #_swap_memvideo
   4158 FD 7E 00      [19]  104 	ld	a, 0 (iy)
   415B 2F            [ 4]  105 	cpl
   415C FD 77 00      [19]  106 	ld	0 (iy), a
                            107 ;src/game.c:29: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
   415F CD 11 59      [17]  108 	call	_cpct_waitVSYNC
                            109 ;src/game.c:30: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
   4162 FD 21 49 5A   [14]  110 	ld	iy, #_mem_page
   4166 FD 6E 00      [19]  111 	ld	l, 0 (iy)
   4169 CD AC 58      [17]  112 	call	_cpct_setVideoMemoryPage
                            113 ;src/game.c:32: coord_x++; 								//scroll right
   416C FD 21 46 5A   [14]  114 	ld	iy, #_coord_x
   4170 FD 34 00      [23]  115 	inc	0 (iy)
                            116 ;src/game.c:33: if (coord_x == 72) 						//end of screen
   4173 FD 7E 00      [19]  117 	ld	a, 0 (iy)
   4176 D6 48         [ 7]  118 	sub	a, #0x48
   4178 20 B6         [12]  119 	jr	NZ,00107$
                            120 ;src/game.c:34: break;
   417A C9            [10]  121 	ret
                            122 	.area _CODE
                            123 	.area _INITIALIZER
                            124 	.area _CABS (ABS)
