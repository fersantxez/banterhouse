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
                             11 	.globl _deleteSprites
                             12 	.globl _renderSprites
                             13 	.globl _redrawTile
                             14 	.globl _cpct_etm_drawTilemap4x8_ag
                             15 	.globl _cpct_etm_setDrawTilemap4x8_ag
                             16 	.globl _cpct_getScreenPtr
                             17 	.globl _cpct_drawSpriteMasked
                             18 ;--------------------------------------------------------
                             19 ; special function registers
                             20 ;--------------------------------------------------------
                             21 ;--------------------------------------------------------
                             22 ; ram data
                             23 ;--------------------------------------------------------
                             24 	.area _DATA
                             25 ;--------------------------------------------------------
                             26 ; ram data
                             27 ;--------------------------------------------------------
                             28 	.area _INITIALIZED
                             29 ;--------------------------------------------------------
                             30 ; absolute external ram data
                             31 ;--------------------------------------------------------
                             32 	.area _DABS (ABS)
                             33 ;--------------------------------------------------------
                             34 ; global & static initialisations
                             35 ;--------------------------------------------------------
                             36 	.area _HOME
                             37 	.area _GSINIT
                             38 	.area _GSFINAL
                             39 	.area _GSINIT
                             40 ;--------------------------------------------------------
                             41 ; Home
                             42 ;--------------------------------------------------------
                             43 	.area _HOME
                             44 	.area _HOME
                             45 ;--------------------------------------------------------
                             46 ; code
                             47 ;--------------------------------------------------------
                             48 	.area _CODE
                             49 ;src/render.c:12: void redrawTile(u8* mem_start, u8 x, u8 y, u8 width, u8 height) {
                             50 ;	---------------------------------
                             51 ; Function redrawTile
                             52 ; ---------------------------------
   6345                      53 _redrawTile::
   6345 DD E5         [15]   54 	push	ix
   6347 DD 21 00 00   [14]   55 	ld	ix,#0
   634B DD 39         [15]   56 	add	ix,sp
   634D F5            [11]   57 	push	af
   634E F5            [11]   58 	push	af
   634F 3B            [ 6]   59 	dec	sp
                             60 ;src/render.c:20: new_x = x - (x % 4);									//x is bytes not pixels - M0
   6350 DD 7E 06      [19]   61 	ld	a, 6 (ix)
   6353 E6 03         [ 7]   62 	and	a, #0x03
   6355 4F            [ 4]   63 	ld	c, a
   6356 DD 7E 06      [19]   64 	ld	a, 6 (ix)
   6359 91            [ 4]   65 	sub	a, c
   635A DD 77 FD      [19]   66 	ld	-3 (ix), a
                             67 ;src/render.c:21: new_y = y - (y % 8) - GAME_AREA_TOP;					//remove the space for scoreboard
   635D DD 7E 07      [19]   68 	ld	a, 7 (ix)
   6360 E6 07         [ 7]   69 	and	a, #0x07
   6362 4F            [ 4]   70 	ld	c, a
   6363 DD 7E 07      [19]   71 	ld	a, 7 (ix)
   6366 91            [ 4]   72 	sub	a, c
   6367 C6 F0         [ 7]   73 	add	a, #0xf0
   6369 5F            [ 4]   74 	ld	e, a
                             75 ;src/render.c:25: new_width = (width / 4) + 1; //FIXME: that +1 is artificially added b/c this code is "leaving a trail"
   636A DD 4E 08      [19]   76 	ld	c, 8 (ix)
   636D CB 39         [ 8]   77 	srl	c
   636F CB 39         [ 8]   78 	srl	c
   6371 0C            [ 4]   79 	inc	c
                             80 ;src/render.c:26: if (width % 4)
   6372 DD 7E 08      [19]   81 	ld	a, 8 (ix)
   6375 E6 03         [ 7]   82 	and	a, #0x03
   6377 28 01         [12]   83 	jr	Z,00102$
                             84 ;src/render.c:27: new_width++;
   6379 0C            [ 4]   85 	inc	c
   637A                      86 00102$:
                             87 ;src/render.c:29: new_height = (height / 8) + 1;
   637A DD 7E 09      [19]   88 	ld	a, 9 (ix)
   637D 0F            [ 4]   89 	rrca
   637E 0F            [ 4]   90 	rrca
   637F 0F            [ 4]   91 	rrca
   6380 E6 1F         [ 7]   92 	and	a, #0x1f
   6382 47            [ 4]   93 	ld	b, a
   6383 04            [ 4]   94 	inc	b
                             95 ;src/render.c:30: if (height % 8)
   6384 DD 7E 09      [19]   96 	ld	a, 9 (ix)
   6387 E6 07         [ 7]   97 	and	a, #0x07
   6389 28 01         [12]   98 	jr	Z,00104$
                             99 ;src/render.c:31: new_height++;
   638B 04            [ 4]  100 	inc	b
   638C                     101 00104$:
                            102 ;src/render.c:34: first_tile = (new_y / 8) * 20 + (new_x / 4); 				//from "coords" to tiles
   638C 7B            [ 4]  103 	ld	a, e
   638D 0F            [ 4]  104 	rrca
   638E 0F            [ 4]  105 	rrca
   638F 0F            [ 4]  106 	rrca
   6390 E6 1F         [ 7]  107 	and	a, #0x1f
   6392 D5            [11]  108 	push	de
   6393 5F            [ 4]  109 	ld	e,a
   6394 16 00         [ 7]  110 	ld	d,#0x00
   6396 6B            [ 4]  111 	ld	l, e
   6397 62            [ 4]  112 	ld	h, d
   6398 29            [11]  113 	add	hl, hl
   6399 29            [11]  114 	add	hl, hl
   639A 19            [11]  115 	add	hl, de
   639B 29            [11]  116 	add	hl, hl
   639C 29            [11]  117 	add	hl, hl
   639D D1            [10]  118 	pop	de
   639E DD 7E FD      [19]  119 	ld	a, -3 (ix)
   63A1 0F            [ 4]  120 	rrca
   63A2 0F            [ 4]  121 	rrca
   63A3 E6 3F         [ 7]  122 	and	a, #0x3f
   63A5 DD 77 FE      [19]  123 	ld	-2 (ix), a
   63A8 DD 36 FF 00   [19]  124 	ld	-1 (ix), #0x00
   63AC 7D            [ 4]  125 	ld	a, l
   63AD DD 86 FE      [19]  126 	add	a, -2 (ix)
   63B0 6F            [ 4]  127 	ld	l, a
   63B1 7C            [ 4]  128 	ld	a, h
   63B2 DD 8E FF      [19]  129 	adc	a, -1 (ix)
   63B5 67            [ 4]  130 	ld	h, a
   63B6 33            [ 6]  131 	inc	sp
   63B7 33            [ 6]  132 	inc	sp
   63B8 E5            [11]  133 	push	hl
                            134 ;src/render.c:36: cpct_etm_setDrawTilemap4x8_ag( new_width, new_height, 20, G_tileset_00 );
   63B9 D5            [11]  135 	push	de
   63BA 21 CC 41      [10]  136 	ld	hl, #_G_tileset_00
   63BD E5            [11]  137 	push	hl
   63BE 21 14 00      [10]  138 	ld	hl, #0x0014
   63C1 E5            [11]  139 	push	hl
   63C2 C5            [11]  140 	push	bc
   63C3 CD 6A 69      [17]  141 	call	_cpct_etm_setDrawTilemap4x8_ag
   63C6 D1            [10]  142 	pop	de
                            143 ;src/render.c:37: cpct_etm_drawTilemap4x8_ag( (u8*)cpct_getScreenPtr( mem_start, new_x, new_y + GAME_AREA_TOP), &map[first_tile] );
   63C7 DD 7E FB      [19]  144 	ld	a, -5 (ix)
   63CA C6 9B         [ 7]  145 	add	a, #<(_map)
   63CC 4F            [ 4]  146 	ld	c, a
   63CD DD 7E FC      [19]  147 	ld	a, -4 (ix)
   63D0 CE 6A         [ 7]  148 	adc	a, #>(_map)
   63D2 47            [ 4]  149 	ld	b, a
   63D3 7B            [ 4]  150 	ld	a, e
   63D4 C6 10         [ 7]  151 	add	a, #0x10
   63D6 67            [ 4]  152 	ld	h, a
   63D7 DD 5E 04      [19]  153 	ld	e,4 (ix)
   63DA DD 56 05      [19]  154 	ld	d,5 (ix)
   63DD C5            [11]  155 	push	bc
   63DE E5            [11]  156 	push	hl
   63DF 33            [ 6]  157 	inc	sp
   63E0 DD 7E FD      [19]  158 	ld	a, -3 (ix)
   63E3 F5            [11]  159 	push	af
   63E4 33            [ 6]  160 	inc	sp
   63E5 D5            [11]  161 	push	de
   63E6 CD 54 69      [17]  162 	call	_cpct_getScreenPtr
   63E9 E5            [11]  163 	push	hl
   63EA CD D0 67      [17]  164 	call	_cpct_etm_drawTilemap4x8_ag
   63ED DD F9         [10]  165 	ld	sp, ix
   63EF DD E1         [14]  166 	pop	ix
   63F1 C9            [10]  167 	ret
                            168 ;src/render.c:40: void renderSprites(){
                            169 ;	---------------------------------
                            170 ; Function renderSprites
                            171 ; ---------------------------------
   63F2                     172 _renderSprites::
   63F2 DD E5         [15]  173 	push	ix
   63F4 DD 21 00 00   [14]  174 	ld	ix,#0
   63F8 DD 39         [15]  175 	add	ix,sp
   63FA 21 F6 FF      [10]  176 	ld	hl, #-10
   63FD 39            [11]  177 	add	hl, sp
   63FE F9            [ 6]  178 	ld	sp, hl
                            179 ;src/render.c:45: for (i = 0; i < MAX_SPRITES; i++) {
   63FF DD 36 F6 00   [19]  180 	ld	-10 (ix), #0x00
   6403                     181 00126$:
                            182 ;src/render.c:46: if (sprites[i].id !=0) {							//only live and renderable sprites
   6403 DD 4E F6      [19]  183 	ld	c,-10 (ix)
   6406 06 00         [ 7]  184 	ld	b,#0x00
   6408 69            [ 4]  185 	ld	l, c
   6409 60            [ 4]  186 	ld	h, b
   640A 29            [11]  187 	add	hl, hl
   640B 09            [11]  188 	add	hl, bc
   640C 29            [11]  189 	add	hl, hl
   640D 29            [11]  190 	add	hl, hl
   640E 29            [11]  191 	add	hl, hl
   640F 01 AA 69      [10]  192 	ld	bc,#_sprites
   6412 09            [11]  193 	add	hl,bc
   6413 DD 75 FD      [19]  194 	ld	-3 (ix), l
   6416 DD 74 FE      [19]  195 	ld	-2 (ix), h
   6419 7E            [ 7]  196 	ld	a, (hl)
   641A B7            [ 4]  197 	or	a, a
   641B CA 6C 65      [10]  198 	jp	Z, 00127$
                            199 ;src/render.c:47: if (sprites[i].properties & MASK_RENDER) {
   641E DD 6E FD      [19]  200 	ld	l,-3 (ix)
   6421 DD 66 FE      [19]  201 	ld	h,-2 (ix)
   6424 11 0B 00      [10]  202 	ld	de, #0x000b
   6427 19            [11]  203 	add	hl, de
   6428 4E            [ 7]  204 	ld	c, (hl)
                            205 ;src/render.c:76: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   6429 DD 7E FD      [19]  206 	ld	a, -3 (ix)
   642C C6 02         [ 7]  207 	add	a, #0x02
   642E DD 77 F7      [19]  208 	ld	-9 (ix), a
   6431 DD 7E FE      [19]  209 	ld	a, -2 (ix)
   6434 CE 00         [ 7]  210 	adc	a, #0x00
   6436 DD 77 F8      [19]  211 	ld	-8 (ix), a
   6439 DD 7E FD      [19]  212 	ld	a, -3 (ix)
   643C C6 01         [ 7]  213 	add	a, #0x01
   643E DD 77 FB      [19]  214 	ld	-5 (ix), a
   6441 DD 7E FE      [19]  215 	ld	a, -2 (ix)
   6444 CE 00         [ 7]  216 	adc	a, #0x00
   6446 DD 77 FC      [19]  217 	ld	-4 (ix), a
                            218 ;src/render.c:47: if (sprites[i].properties & MASK_RENDER) {
   6449 CB 41         [ 8]  219 	bit	0, c
   644B CA 1B 65      [10]  220 	jp	Z,00119$
                            221 ;src/render.c:62: sprite = sprites[i].sprite_f1; 
   644E DD 7E FD      [19]  222 	ld	a, -3 (ix)
   6451 C6 0F         [ 7]  223 	add	a, #0x0f
   6453 DD 77 F9      [19]  224 	ld	-7 (ix), a
   6456 DD 7E FE      [19]  225 	ld	a, -2 (ix)
   6459 CE 00         [ 7]  226 	adc	a, #0x00
   645B DD 77 FA      [19]  227 	ld	-6 (ix), a
                            228 ;src/render.c:49: if (sprites[i].properties & MASK_ANIMATE) {
   645E CB 49         [ 8]  229 	bit	1, c
   6460 28 55         [12]  230 	jr	Z,00114$
                            231 ;src/render.c:57: if (anim_clock > 7) num_frame=2;
   6462 3E 07         [ 7]  232 	ld	a, #0x07
   6464 FD 21 9A 6A   [14]  233 	ld	iy, #_anim_clock
   6468 FD 96 00      [19]  234 	sub	a, 0 (iy)
   646B 30 04         [12]  235 	jr	NC,00102$
   646D 3E 02         [ 7]  236 	ld	a, #0x02
   646F 18 02         [12]  237 	jr	00103$
   6471                     238 00102$:
                            239 ;src/render.c:58: else num_frame=1;
   6471 3E 01         [ 7]  240 	ld	a, #0x01
   6473                     241 00103$:
                            242 ;src/render.c:61: if (num_frame == 1) {
   6473 FE 01         [ 7]  243 	cp	a, #0x01
   6475 20 0B         [12]  244 	jr	NZ,00111$
                            245 ;src/render.c:62: sprite = sprites[i].sprite_f1; 
   6477 DD 6E F9      [19]  246 	ld	l,-7 (ix)
   647A DD 66 FA      [19]  247 	ld	h,-6 (ix)
   647D 4E            [ 7]  248 	ld	c, (hl)
   647E 23            [ 6]  249 	inc	hl
   647F 46            [ 7]  250 	ld	b, (hl)
   6480 18 3E         [12]  251 	jr	00115$
   6482                     252 00111$:
                            253 ;src/render.c:63: } else if (num_frame == 2) {
   6482 FE 02         [ 7]  254 	cp	a, #0x02
   6484 20 0F         [12]  255 	jr	NZ,00108$
                            256 ;src/render.c:64: sprite = sprites[i].sprite_f2;
   6486 DD 6E FD      [19]  257 	ld	l,-3 (ix)
   6489 DD 66 FE      [19]  258 	ld	h,-2 (ix)
   648C 11 11 00      [10]  259 	ld	de, #0x0011
   648F 19            [11]  260 	add	hl, de
   6490 4E            [ 7]  261 	ld	c, (hl)
   6491 23            [ 6]  262 	inc	hl
   6492 46            [ 7]  263 	ld	b, (hl)
   6493 18 2B         [12]  264 	jr	00115$
   6495                     265 00108$:
                            266 ;src/render.c:65: } else if (num_frame == 3) { 
   6495 D6 03         [ 7]  267 	sub	a, #0x03
   6497 20 0F         [12]  268 	jr	NZ,00105$
                            269 ;src/render.c:66: sprite = sprites[i].sprite_f3; 
   6499 DD 6E FD      [19]  270 	ld	l,-3 (ix)
   649C DD 66 FE      [19]  271 	ld	h,-2 (ix)
   649F 11 13 00      [10]  272 	ld	de, #0x0013
   64A2 19            [11]  273 	add	hl, de
   64A3 4E            [ 7]  274 	ld	c, (hl)
   64A4 23            [ 6]  275 	inc	hl
   64A5 46            [ 7]  276 	ld	b, (hl)
   64A6 18 18         [12]  277 	jr	00115$
   64A8                     278 00105$:
                            279 ;src/render.c:67: } else sprite = sprites[i].sprite_f4;
   64A8 DD 6E FD      [19]  280 	ld	l,-3 (ix)
   64AB DD 66 FE      [19]  281 	ld	h,-2 (ix)
   64AE 11 15 00      [10]  282 	ld	de, #0x0015
   64B1 19            [11]  283 	add	hl, de
   64B2 4E            [ 7]  284 	ld	c, (hl)
   64B3 23            [ 6]  285 	inc	hl
   64B4 46            [ 7]  286 	ld	b, (hl)
   64B5 18 09         [12]  287 	jr	00115$
   64B7                     288 00114$:
                            289 ;src/render.c:68: } else sprite = sprites[i].sprite_f1;
   64B7 DD 6E F9      [19]  290 	ld	l,-7 (ix)
   64BA DD 66 FA      [19]  291 	ld	h,-6 (ix)
   64BD 4E            [ 7]  292 	ld	c, (hl)
   64BE 23            [ 6]  293 	inc	hl
   64BF 46            [ 7]  294 	ld	b, (hl)
   64C0                     295 00115$:
                            296 ;src/render.c:70: if (sprites[i].turned)							//turn sprite around
   64C0 DD 6E FD      [19]  297 	ld	l,-3 (ix)
   64C3 DD 66 FE      [19]  298 	ld	h,-2 (ix)
   64C6 11 17 00      [10]  299 	ld	de, #0x0017
   64C9 19            [11]  300 	add	hl, de
   64CA 7E            [ 7]  301 	ld	a, (hl)
   64CB B7            [ 4]  302 	or	a, a
   64CC 28 06         [12]  303 	jr	Z,00117$
                            304 ;src/render.c:72: sprite = sprite + ((G_PITU_W*2)*G_PITU_H);	//find next sprite in memory, "rev" version
   64CE 21 C0 01      [10]  305 	ld	hl, #0x01c0
   64D1 09            [11]  306 	add	hl,bc
   64D2 4D            [ 4]  307 	ld	c, l
   64D3 44            [ 4]  308 	ld	b, h
   64D4                     309 00117$:
                            310 ;src/render.c:77: sprites[i].width, sprites[i].height);
   64D4 DD 6E FD      [19]  311 	ld	l,-3 (ix)
   64D7 DD 66 FE      [19]  312 	ld	h,-2 (ix)
   64DA 11 09 00      [10]  313 	ld	de, #0x0009
   64DD 19            [11]  314 	add	hl, de
   64DE 7E            [ 7]  315 	ld	a, (hl)
   64DF DD 77 F9      [19]  316 	ld	-7 (ix), a
   64E2 DD 6E FD      [19]  317 	ld	l,-3 (ix)
   64E5 DD 66 FE      [19]  318 	ld	h,-2 (ix)
   64E8 11 0A 00      [10]  319 	ld	de, #0x000a
   64EB 19            [11]  320 	add	hl, de
   64EC 7E            [ 7]  321 	ld	a, (hl)
   64ED DD 77 FF      [19]  322 	ld	-1 (ix), a
                            323 ;src/render.c:76: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   64F0 DD 6E F7      [19]  324 	ld	l,-9 (ix)
   64F3 DD 66 F8      [19]  325 	ld	h,-8 (ix)
   64F6 5E            [ 7]  326 	ld	e, (hl)
   64F7 DD 6E FB      [19]  327 	ld	l,-5 (ix)
   64FA DD 66 FC      [19]  328 	ld	h,-4 (ix)
   64FD 56            [ 7]  329 	ld	d, (hl)
   64FE FD 2A 67 6C   [20]  330 	ld	iy, (_mem_start)
   6502 C5            [11]  331 	push	bc
   6503 7B            [ 4]  332 	ld	a, e
   6504 F5            [11]  333 	push	af
   6505 33            [ 6]  334 	inc	sp
   6506 D5            [11]  335 	push	de
   6507 33            [ 6]  336 	inc	sp
   6508 FD E5         [15]  337 	push	iy
   650A CD 54 69      [17]  338 	call	_cpct_getScreenPtr
   650D EB            [ 4]  339 	ex	de,hl
   650E C1            [10]  340 	pop	bc
                            341 ;src/render.c:74: cpct_drawSpriteMasked(sprite,
   650F DD 66 F9      [19]  342 	ld	h, -7 (ix)
   6512 DD 6E FF      [19]  343 	ld	l, -1 (ix)
   6515 E5            [11]  344 	push	hl
   6516 D5            [11]  345 	push	de
   6517 C5            [11]  346 	push	bc
   6518 CD 88 68      [17]  347 	call	_cpct_drawSpriteMasked
   651B                     348 00119$:
                            349 ;src/render.c:76: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   651B DD 6E FB      [19]  350 	ld	l,-5 (ix)
   651E DD 66 FC      [19]  351 	ld	h,-4 (ix)
   6521 4E            [ 7]  352 	ld	c, (hl)
                            353 ;src/render.c:82: if (!swap_memvideo) {
   6522 3A 6A 6C      [13]  354 	ld	a,(#_swap_memvideo + 0)
   6525 B7            [ 4]  355 	or	a, a
   6526 20 23         [12]  356 	jr	NZ,00121$
                            357 ;src/render.c:83: sprites[i].x_prev_B = sprites[i].x;
   6528 DD 7E FD      [19]  358 	ld	a, -3 (ix)
   652B C6 07         [ 7]  359 	add	a, #0x07
   652D 6F            [ 4]  360 	ld	l, a
   652E DD 7E FE      [19]  361 	ld	a, -2 (ix)
   6531 CE 00         [ 7]  362 	adc	a, #0x00
   6533 67            [ 4]  363 	ld	h, a
   6534 71            [ 7]  364 	ld	(hl), c
                            365 ;src/render.c:84: sprites[i].y_prev_B = sprites[i].y;
   6535 DD 7E FD      [19]  366 	ld	a, -3 (ix)
   6538 C6 08         [ 7]  367 	add	a, #0x08
   653A 4F            [ 4]  368 	ld	c, a
   653B DD 7E FE      [19]  369 	ld	a, -2 (ix)
   653E CE 00         [ 7]  370 	adc	a, #0x00
   6540 47            [ 4]  371 	ld	b, a
   6541 DD 6E F7      [19]  372 	ld	l,-9 (ix)
   6544 DD 66 F8      [19]  373 	ld	h,-8 (ix)
   6547 7E            [ 7]  374 	ld	a, (hl)
   6548 02            [ 7]  375 	ld	(bc), a
   6549 18 21         [12]  376 	jr	00127$
   654B                     377 00121$:
                            378 ;src/render.c:86: sprites[i].x_prev_A = sprites[i].x;
   654B DD 7E FD      [19]  379 	ld	a, -3 (ix)
   654E C6 05         [ 7]  380 	add	a, #0x05
   6550 6F            [ 4]  381 	ld	l, a
   6551 DD 7E FE      [19]  382 	ld	a, -2 (ix)
   6554 CE 00         [ 7]  383 	adc	a, #0x00
   6556 67            [ 4]  384 	ld	h, a
   6557 71            [ 7]  385 	ld	(hl), c
                            386 ;src/render.c:87: sprites[i].y_prev_A = sprites[i].y;
   6558 DD 7E FD      [19]  387 	ld	a, -3 (ix)
   655B C6 06         [ 7]  388 	add	a, #0x06
   655D 4F            [ 4]  389 	ld	c, a
   655E DD 7E FE      [19]  390 	ld	a, -2 (ix)
   6561 CE 00         [ 7]  391 	adc	a, #0x00
   6563 47            [ 4]  392 	ld	b, a
   6564 DD 6E F7      [19]  393 	ld	l,-9 (ix)
   6567 DD 66 F8      [19]  394 	ld	h,-8 (ix)
   656A 7E            [ 7]  395 	ld	a, (hl)
   656B 02            [ 7]  396 	ld	(bc), a
   656C                     397 00127$:
                            398 ;src/render.c:45: for (i = 0; i < MAX_SPRITES; i++) {
   656C DD 34 F6      [23]  399 	inc	-10 (ix)
   656F DD 7E F6      [19]  400 	ld	a, -10 (ix)
   6572 D6 0A         [ 7]  401 	sub	a, #0x0a
   6574 DA 03 64      [10]  402 	jp	C, 00126$
   6577 DD F9         [10]  403 	ld	sp, ix
   6579 DD E1         [14]  404 	pop	ix
   657B C9            [10]  405 	ret
                            406 ;src/render.c:93: void deleteSprites(){
                            407 ;	---------------------------------
                            408 ; Function deleteSprites
                            409 ; ---------------------------------
   657C                     410 _deleteSprites::
   657C DD E5         [15]  411 	push	ix
   657E DD 21 00 00   [14]  412 	ld	ix,#0
   6582 DD 39         [15]  413 	add	ix,sp
   6584 F5            [11]  414 	push	af
                            415 ;src/render.c:98: for (i = 0; i < MAX_SPRITES; i++) {
   6585 0E 00         [ 7]  416 	ld	c, #0x00
   6587                     417 00107$:
                            418 ;src/render.c:99: if (sprites[i].id !=0) {
   6587 06 00         [ 7]  419 	ld	b,#0x00
   6589 69            [ 4]  420 	ld	l, c
   658A 60            [ 4]  421 	ld	h, b
   658B 29            [11]  422 	add	hl, hl
   658C 09            [11]  423 	add	hl, bc
   658D 29            [11]  424 	add	hl, hl
   658E 29            [11]  425 	add	hl, hl
   658F 29            [11]  426 	add	hl, hl
   6590 EB            [ 4]  427 	ex	de,hl
   6591 21 AA 69      [10]  428 	ld	hl, #_sprites
   6594 19            [11]  429 	add	hl,de
   6595 EB            [ 4]  430 	ex	de,hl
   6596 1A            [ 7]  431 	ld	a, (de)
   6597 B7            [ 4]  432 	or	a, a
   6598 28 4F         [12]  433 	jr	Z,00108$
                            434 ;src/render.c:100: if (!swap_memvideo){
   659A 3A 6A 6C      [13]  435 	ld	a,(#_swap_memvideo + 0)
   659D B7            [ 4]  436 	or	a, a
   659E 20 14         [12]  437 	jr	NZ,00102$
                            438 ;src/render.c:101: x = sprites[i].x_prev_B;
   65A0 D5            [11]  439 	push	de
   65A1 FD E1         [14]  440 	pop	iy
   65A3 FD 7E 07      [19]  441 	ld	a, 7 (iy)
   65A6 DD 77 FE      [19]  442 	ld	-2 (ix), a
                            443 ;src/render.c:102: y = sprites[i].y_prev_B;
   65A9 D5            [11]  444 	push	de
   65AA FD E1         [14]  445 	pop	iy
   65AC FD 7E 08      [19]  446 	ld	a, 8 (iy)
   65AF DD 77 FF      [19]  447 	ld	-1 (ix), a
   65B2 18 12         [12]  448 	jr	00103$
   65B4                     449 00102$:
                            450 ;src/render.c:105: x = sprites[i].x_prev_A;
   65B4 D5            [11]  451 	push	de
   65B5 FD E1         [14]  452 	pop	iy
   65B7 FD 7E 05      [19]  453 	ld	a, 5 (iy)
   65BA DD 77 FE      [19]  454 	ld	-2 (ix), a
                            455 ;src/render.c:106: y = sprites[i].y_prev_A;
   65BD D5            [11]  456 	push	de
   65BE FD E1         [14]  457 	pop	iy
   65C0 FD 7E 06      [19]  458 	ld	a, 6 (iy)
   65C3 DD 77 FF      [19]  459 	ld	-1 (ix), a
   65C6                     460 00103$:
                            461 ;src/render.c:113: redrawTile(mem_start, x, y, sprites[i].width, sprites[i].height);
   65C6 D5            [11]  462 	push	de
   65C7 FD E1         [14]  463 	pop	iy
   65C9 FD 7E 09      [19]  464 	ld	a, 9 (iy)
   65CC EB            [ 4]  465 	ex	de,hl
   65CD 11 0A 00      [10]  466 	ld	de, #0x000a
   65D0 19            [11]  467 	add	hl, de
   65D1 5E            [ 7]  468 	ld	e, (hl)
   65D2 C5            [11]  469 	push	bc
   65D3 57            [ 4]  470 	ld	d,a
   65D4 D5            [11]  471 	push	de
   65D5 DD 66 FF      [19]  472 	ld	h, -1 (ix)
   65D8 DD 6E FE      [19]  473 	ld	l, -2 (ix)
   65DB E5            [11]  474 	push	hl
   65DC 2A 67 6C      [16]  475 	ld	hl, (_mem_start)
   65DF E5            [11]  476 	push	hl
   65E0 CD 45 63      [17]  477 	call	_redrawTile
   65E3 21 06 00      [10]  478 	ld	hl, #6
   65E6 39            [11]  479 	add	hl, sp
   65E7 F9            [ 6]  480 	ld	sp, hl
   65E8 C1            [10]  481 	pop	bc
   65E9                     482 00108$:
                            483 ;src/render.c:98: for (i = 0; i < MAX_SPRITES; i++) {
   65E9 0C            [ 4]  484 	inc	c
   65EA 79            [ 4]  485 	ld	a, c
   65EB D6 0A         [ 7]  486 	sub	a, #0x0a
   65ED 38 98         [12]  487 	jr	C,00107$
   65EF DD F9         [10]  488 	ld	sp, ix
   65F1 DD E1         [14]  489 	pop	ix
   65F3 C9            [10]  490 	ret
                            491 	.area _CODE
                            492 	.area _INITIALIZER
                            493 	.area _CABS (ABS)
