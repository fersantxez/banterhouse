                              1 ;--------------------------------------------------------
                              2 ; File Created by SDCC : free open source ANSI-C Compiler
                              3 ; Version 3.6.8 #9946 (Linux)
                              4 ;--------------------------------------------------------
                              5 	.module render
                              6 	.optsdcc -mz80
                              7 	
                              8 ;--------------------------------------------------------
                              9 ; Public variables in this module
                             10 ;--------------------------------------------------------
                             11 	.globl _renderDelete
                             12 	.globl _renderSprites
                             13 	.globl _cpct_getScreenPtr
                             14 	.globl _cpct_drawSpriteMasked
                             15 	.globl _cpct_drawSolidBox
                             16 	.globl _cpct_px2byteM0
                             17 ;--------------------------------------------------------
                             18 ; special function registers
                             19 ;--------------------------------------------------------
                             20 ;--------------------------------------------------------
                             21 ; ram data
                             22 ;--------------------------------------------------------
                             23 	.area _DATA
                             24 ;--------------------------------------------------------
                             25 ; ram data
                             26 ;--------------------------------------------------------
                             27 	.area _INITIALIZED
                             28 ;--------------------------------------------------------
                             29 ; absolute external ram data
                             30 ;--------------------------------------------------------
                             31 	.area _DABS (ABS)
                             32 ;--------------------------------------------------------
                             33 ; global & static initialisations
                             34 ;--------------------------------------------------------
                             35 	.area _HOME
                             36 	.area _GSINIT
                             37 	.area _GSFINAL
                             38 	.area _GSINIT
                             39 ;--------------------------------------------------------
                             40 ; Home
                             41 ;--------------------------------------------------------
                             42 	.area _HOME
                             43 	.area _HOME
                             44 ;--------------------------------------------------------
                             45 ; code
                             46 ;--------------------------------------------------------
                             47 	.area _CODE
                             48 ;src/render.c:6: void renderSprites(){
                             49 ;	---------------------------------
                             50 ; Function renderSprites
                             51 ; ---------------------------------
   5683                      52 _renderSprites::
                             53 ;src/render.c:8: cpct_drawSpriteMasked(G_pitu, cpct_getScreenPtr( mem_start, coord_x, 0), G_PITU_W/2, G_PITU_H);
   5683 ED 4B 47 5A   [20]   54 	ld	bc, (_mem_start)
   5687 AF            [ 4]   55 	xor	a, a
   5688 F5            [11]   56 	push	af
   5689 33            [ 6]   57 	inc	sp
   568A 3A 46 5A      [13]   58 	ld	a, (_coord_x)
   568D F5            [11]   59 	push	af
   568E 33            [ 6]   60 	inc	sp
   568F C5            [11]   61 	push	bc
   5690 CD 20 5A      [17]   62 	call	_cpct_getScreenPtr
   5693 01 7B 41      [10]   63 	ld	bc, #_G_pitu+0
   5696 11 08 20      [10]   64 	ld	de, #0x2008
   5699 D5            [11]   65 	push	de
   569A E5            [11]   66 	push	hl
   569B C5            [11]   67 	push	bc
   569C CD B5 58      [17]   68 	call	_cpct_drawSpriteMasked
   569F C9            [10]   69 	ret
                             70 ;src/render.c:13: void renderDelete(){
                             71 ;	---------------------------------
                             72 ; Function renderDelete
                             73 ; ---------------------------------
   56A0                      74 _renderDelete::
                             75 ;src/render.c:14: cpct_drawSolidBox(cpct_getScreenPtr( mem_start, coord_x-2, 0), cpct_px2byteM0(5,5), G_PITU_W/2, G_PITU_H);
   56A0 21 05 05      [10]   76 	ld	hl, #0x0505
   56A3 E5            [11]   77 	push	hl
   56A4 CD 19 59      [17]   78 	call	_cpct_px2byteM0
   56A7 4D            [ 4]   79 	ld	c, l
   56A8 06 00         [ 7]   80 	ld	b, #0x00
   56AA 21 46 5A      [10]   81 	ld	hl,#_coord_x + 0
   56AD 5E            [ 7]   82 	ld	e, (hl)
   56AE 1D            [ 4]   83 	dec	e
   56AF 1D            [ 4]   84 	dec	e
   56B0 2A 47 5A      [16]   85 	ld	hl, (_mem_start)
   56B3 C5            [11]   86 	push	bc
   56B4 AF            [ 4]   87 	xor	a, a
   56B5 57            [ 4]   88 	ld	d,a
   56B6 D5            [11]   89 	push	de
   56B7 E5            [11]   90 	push	hl
   56B8 CD 20 5A      [17]   91 	call	_cpct_getScreenPtr
   56BB C1            [10]   92 	pop	bc
   56BC 11 08 20      [10]   93 	ld	de, #0x2008
   56BF D5            [11]   94 	push	de
   56C0 C5            [11]   95 	push	bc
   56C1 E5            [11]   96 	push	hl
   56C2 CD 53 59      [17]   97 	call	_cpct_drawSolidBox
   56C5 C9            [10]   98 	ret
                             99 	.area _CODE
                            100 	.area _INITIALIZER
                            101 	.area _CABS (ABS)
