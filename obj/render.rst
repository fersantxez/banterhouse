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
                             75 ;src/render.c:25: new_width = (width / 4);
   636A DD 4E 08      [19]   76 	ld	c, 8 (ix)
   636D CB 39         [ 8]   77 	srl	c
   636F CB 39         [ 8]   78 	srl	c
                             79 ;src/render.c:26: if (width % 4)
   6371 DD 7E 08      [19]   80 	ld	a, 8 (ix)
   6374 E6 03         [ 7]   81 	and	a, #0x03
   6376 28 01         [12]   82 	jr	Z,00102$
                             83 ;src/render.c:27: new_width++;
   6378 0C            [ 4]   84 	inc	c
   6379                      85 00102$:
                             86 ;src/render.c:29: new_height = (height / 8);
   6379 DD 46 09      [19]   87 	ld	b, 9 (ix)
   637C CB 38         [ 8]   88 	srl	b
   637E CB 38         [ 8]   89 	srl	b
   6380 CB 38         [ 8]   90 	srl	b
                             91 ;src/render.c:30: if (height % 8)
   6382 DD 7E 09      [19]   92 	ld	a, 9 (ix)
   6385 E6 07         [ 7]   93 	and	a, #0x07
   6387 28 01         [12]   94 	jr	Z,00104$
                             95 ;src/render.c:31: new_height++;
   6389 04            [ 4]   96 	inc	b
   638A                      97 00104$:
                             98 ;src/render.c:34: first_tile = (new_y / 8) * 20 + (new_x / 4); 				//from "coords" to tiles
   638A 7B            [ 4]   99 	ld	a, e
   638B 0F            [ 4]  100 	rrca
   638C 0F            [ 4]  101 	rrca
   638D 0F            [ 4]  102 	rrca
   638E E6 1F         [ 7]  103 	and	a, #0x1f
   6390 D5            [11]  104 	push	de
   6391 5F            [ 4]  105 	ld	e,a
   6392 16 00         [ 7]  106 	ld	d,#0x00
   6394 6B            [ 4]  107 	ld	l, e
   6395 62            [ 4]  108 	ld	h, d
   6396 29            [11]  109 	add	hl, hl
   6397 29            [11]  110 	add	hl, hl
   6398 19            [11]  111 	add	hl, de
   6399 29            [11]  112 	add	hl, hl
   639A 29            [11]  113 	add	hl, hl
   639B D1            [10]  114 	pop	de
   639C DD 7E FD      [19]  115 	ld	a, -3 (ix)
   639F 0F            [ 4]  116 	rrca
   63A0 0F            [ 4]  117 	rrca
   63A1 E6 3F         [ 7]  118 	and	a, #0x3f
   63A3 DD 77 FE      [19]  119 	ld	-2 (ix), a
   63A6 DD 36 FF 00   [19]  120 	ld	-1 (ix), #0x00
   63AA 7D            [ 4]  121 	ld	a, l
   63AB DD 86 FE      [19]  122 	add	a, -2 (ix)
   63AE 6F            [ 4]  123 	ld	l, a
   63AF 7C            [ 4]  124 	ld	a, h
   63B0 DD 8E FF      [19]  125 	adc	a, -1 (ix)
   63B3 67            [ 4]  126 	ld	h, a
   63B4 33            [ 6]  127 	inc	sp
   63B5 33            [ 6]  128 	inc	sp
   63B6 E5            [11]  129 	push	hl
                            130 ;src/render.c:36: cpct_etm_setDrawTilemap4x8_ag( new_width, new_height, 20, G_tileset_00 );
   63B7 D5            [11]  131 	push	de
   63B8 21 CC 41      [10]  132 	ld	hl, #_G_tileset_00
   63BB E5            [11]  133 	push	hl
   63BC 21 14 00      [10]  134 	ld	hl, #0x0014
   63BF E5            [11]  135 	push	hl
   63C0 C5            [11]  136 	push	bc
   63C1 CD 68 69      [17]  137 	call	_cpct_etm_setDrawTilemap4x8_ag
   63C4 D1            [10]  138 	pop	de
                            139 ;src/render.c:37: cpct_etm_drawTilemap4x8_ag( (u8*)cpct_getScreenPtr( mem_start, new_x, new_y + GAME_AREA_TOP), &map[first_tile] );
   63C5 DD 7E FB      [19]  140 	ld	a, -5 (ix)
   63C8 C6 99         [ 7]  141 	add	a, #<(_map)
   63CA 4F            [ 4]  142 	ld	c, a
   63CB DD 7E FC      [19]  143 	ld	a, -4 (ix)
   63CE CE 6A         [ 7]  144 	adc	a, #>(_map)
   63D0 47            [ 4]  145 	ld	b, a
   63D1 7B            [ 4]  146 	ld	a, e
   63D2 C6 10         [ 7]  147 	add	a, #0x10
   63D4 67            [ 4]  148 	ld	h, a
   63D5 DD 5E 04      [19]  149 	ld	e,4 (ix)
   63D8 DD 56 05      [19]  150 	ld	d,5 (ix)
   63DB C5            [11]  151 	push	bc
   63DC E5            [11]  152 	push	hl
   63DD 33            [ 6]  153 	inc	sp
   63DE DD 7E FD      [19]  154 	ld	a, -3 (ix)
   63E1 F5            [11]  155 	push	af
   63E2 33            [ 6]  156 	inc	sp
   63E3 D5            [11]  157 	push	de
   63E4 CD 52 69      [17]  158 	call	_cpct_getScreenPtr
   63E7 E5            [11]  159 	push	hl
   63E8 CD CE 67      [17]  160 	call	_cpct_etm_drawTilemap4x8_ag
   63EB DD F9         [10]  161 	ld	sp, ix
   63ED DD E1         [14]  162 	pop	ix
   63EF C9            [10]  163 	ret
                            164 ;src/render.c:40: void renderSprites(){
                            165 ;	---------------------------------
                            166 ; Function renderSprites
                            167 ; ---------------------------------
   63F0                     168 _renderSprites::
   63F0 DD E5         [15]  169 	push	ix
   63F2 DD 21 00 00   [14]  170 	ld	ix,#0
   63F6 DD 39         [15]  171 	add	ix,sp
   63F8 21 F6 FF      [10]  172 	ld	hl, #-10
   63FB 39            [11]  173 	add	hl, sp
   63FC F9            [ 6]  174 	ld	sp, hl
                            175 ;src/render.c:45: for (i = 0; i < MAX_SPRITES; i++) {
   63FD DD 36 F6 00   [19]  176 	ld	-10 (ix), #0x00
   6401                     177 00126$:
                            178 ;src/render.c:46: if (sprites[i].id !=0) {							//only live and renderable sprites
   6401 DD 4E F6      [19]  179 	ld	c,-10 (ix)
   6404 06 00         [ 7]  180 	ld	b,#0x00
   6406 69            [ 4]  181 	ld	l, c
   6407 60            [ 4]  182 	ld	h, b
   6408 29            [11]  183 	add	hl, hl
   6409 09            [11]  184 	add	hl, bc
   640A 29            [11]  185 	add	hl, hl
   640B 29            [11]  186 	add	hl, hl
   640C 29            [11]  187 	add	hl, hl
   640D 01 A8 69      [10]  188 	ld	bc,#_sprites
   6410 09            [11]  189 	add	hl,bc
   6411 DD 75 FC      [19]  190 	ld	-4 (ix), l
   6414 DD 74 FD      [19]  191 	ld	-3 (ix), h
   6417 7E            [ 7]  192 	ld	a, (hl)
   6418 B7            [ 4]  193 	or	a, a
   6419 CA 6A 65      [10]  194 	jp	Z, 00127$
                            195 ;src/render.c:47: if (sprites[i].properties & MASK_RENDER) {
   641C DD 6E FC      [19]  196 	ld	l,-4 (ix)
   641F DD 66 FD      [19]  197 	ld	h,-3 (ix)
   6422 11 0B 00      [10]  198 	ld	de, #0x000b
   6425 19            [11]  199 	add	hl, de
   6426 4E            [ 7]  200 	ld	c, (hl)
                            201 ;src/render.c:76: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   6427 DD 7E FC      [19]  202 	ld	a, -4 (ix)
   642A C6 02         [ 7]  203 	add	a, #0x02
   642C DD 77 FA      [19]  204 	ld	-6 (ix), a
   642F DD 7E FD      [19]  205 	ld	a, -3 (ix)
   6432 CE 00         [ 7]  206 	adc	a, #0x00
   6434 DD 77 FB      [19]  207 	ld	-5 (ix), a
   6437 DD 7E FC      [19]  208 	ld	a, -4 (ix)
   643A C6 01         [ 7]  209 	add	a, #0x01
   643C DD 77 F8      [19]  210 	ld	-8 (ix), a
   643F DD 7E FD      [19]  211 	ld	a, -3 (ix)
   6442 CE 00         [ 7]  212 	adc	a, #0x00
   6444 DD 77 F9      [19]  213 	ld	-7 (ix), a
                            214 ;src/render.c:47: if (sprites[i].properties & MASK_RENDER) {
   6447 CB 41         [ 8]  215 	bit	0, c
   6449 CA 19 65      [10]  216 	jp	Z,00119$
                            217 ;src/render.c:62: sprite = sprites[i].sprite_f1; 
   644C DD 7E FC      [19]  218 	ld	a, -4 (ix)
   644F C6 0F         [ 7]  219 	add	a, #0x0f
   6451 DD 77 FE      [19]  220 	ld	-2 (ix), a
   6454 DD 7E FD      [19]  221 	ld	a, -3 (ix)
   6457 CE 00         [ 7]  222 	adc	a, #0x00
   6459 DD 77 FF      [19]  223 	ld	-1 (ix), a
                            224 ;src/render.c:49: if (sprites[i].properties & MASK_ANIMATE) {
   645C CB 49         [ 8]  225 	bit	1, c
   645E 28 55         [12]  226 	jr	Z,00114$
                            227 ;src/render.c:57: if (anim_clock > 7) num_frame=2;
   6460 3E 07         [ 7]  228 	ld	a, #0x07
   6462 FD 21 98 6A   [14]  229 	ld	iy, #_anim_clock
   6466 FD 96 00      [19]  230 	sub	a, 0 (iy)
   6469 30 04         [12]  231 	jr	NC,00102$
   646B 3E 02         [ 7]  232 	ld	a, #0x02
   646D 18 02         [12]  233 	jr	00103$
   646F                     234 00102$:
                            235 ;src/render.c:58: else num_frame=1;
   646F 3E 01         [ 7]  236 	ld	a, #0x01
   6471                     237 00103$:
                            238 ;src/render.c:61: if (num_frame == 1) {
   6471 FE 01         [ 7]  239 	cp	a, #0x01
   6473 20 0B         [12]  240 	jr	NZ,00111$
                            241 ;src/render.c:62: sprite = sprites[i].sprite_f1; 
   6475 DD 6E FE      [19]  242 	ld	l,-2 (ix)
   6478 DD 66 FF      [19]  243 	ld	h,-1 (ix)
   647B 4E            [ 7]  244 	ld	c, (hl)
   647C 23            [ 6]  245 	inc	hl
   647D 46            [ 7]  246 	ld	b, (hl)
   647E 18 3E         [12]  247 	jr	00115$
   6480                     248 00111$:
                            249 ;src/render.c:63: } else if (num_frame == 2) {
   6480 FE 02         [ 7]  250 	cp	a, #0x02
   6482 20 0F         [12]  251 	jr	NZ,00108$
                            252 ;src/render.c:64: sprite = sprites[i].sprite_f2;
   6484 DD 6E FC      [19]  253 	ld	l,-4 (ix)
   6487 DD 66 FD      [19]  254 	ld	h,-3 (ix)
   648A 11 11 00      [10]  255 	ld	de, #0x0011
   648D 19            [11]  256 	add	hl, de
   648E 4E            [ 7]  257 	ld	c, (hl)
   648F 23            [ 6]  258 	inc	hl
   6490 46            [ 7]  259 	ld	b, (hl)
   6491 18 2B         [12]  260 	jr	00115$
   6493                     261 00108$:
                            262 ;src/render.c:65: } else if (num_frame == 3) { 
   6493 D6 03         [ 7]  263 	sub	a, #0x03
   6495 20 0F         [12]  264 	jr	NZ,00105$
                            265 ;src/render.c:66: sprite = sprites[i].sprite_f3; 
   6497 DD 6E FC      [19]  266 	ld	l,-4 (ix)
   649A DD 66 FD      [19]  267 	ld	h,-3 (ix)
   649D 11 13 00      [10]  268 	ld	de, #0x0013
   64A0 19            [11]  269 	add	hl, de
   64A1 4E            [ 7]  270 	ld	c, (hl)
   64A2 23            [ 6]  271 	inc	hl
   64A3 46            [ 7]  272 	ld	b, (hl)
   64A4 18 18         [12]  273 	jr	00115$
   64A6                     274 00105$:
                            275 ;src/render.c:67: } else sprite = sprites[i].sprite_f4;
   64A6 DD 6E FC      [19]  276 	ld	l,-4 (ix)
   64A9 DD 66 FD      [19]  277 	ld	h,-3 (ix)
   64AC 11 15 00      [10]  278 	ld	de, #0x0015
   64AF 19            [11]  279 	add	hl, de
   64B0 4E            [ 7]  280 	ld	c, (hl)
   64B1 23            [ 6]  281 	inc	hl
   64B2 46            [ 7]  282 	ld	b, (hl)
   64B3 18 09         [12]  283 	jr	00115$
   64B5                     284 00114$:
                            285 ;src/render.c:68: } else sprite = sprites[i].sprite_f1;
   64B5 DD 6E FE      [19]  286 	ld	l,-2 (ix)
   64B8 DD 66 FF      [19]  287 	ld	h,-1 (ix)
   64BB 4E            [ 7]  288 	ld	c, (hl)
   64BC 23            [ 6]  289 	inc	hl
   64BD 46            [ 7]  290 	ld	b, (hl)
   64BE                     291 00115$:
                            292 ;src/render.c:70: if (sprites[i].turned)							//turn sprite around
   64BE DD 6E FC      [19]  293 	ld	l,-4 (ix)
   64C1 DD 66 FD      [19]  294 	ld	h,-3 (ix)
   64C4 11 17 00      [10]  295 	ld	de, #0x0017
   64C7 19            [11]  296 	add	hl, de
   64C8 7E            [ 7]  297 	ld	a, (hl)
   64C9 B7            [ 4]  298 	or	a, a
   64CA 28 06         [12]  299 	jr	Z,00117$
                            300 ;src/render.c:72: sprite = sprite + ((G_PITU_W*2)*G_PITU_H);	//find next sprite in memory, "rev" version
   64CC 21 C0 01      [10]  301 	ld	hl, #0x01c0
   64CF 09            [11]  302 	add	hl,bc
   64D0 4D            [ 4]  303 	ld	c, l
   64D1 44            [ 4]  304 	ld	b, h
   64D2                     305 00117$:
                            306 ;src/render.c:77: sprites[i].width, sprites[i].height);
   64D2 DD 6E FC      [19]  307 	ld	l,-4 (ix)
   64D5 DD 66 FD      [19]  308 	ld	h,-3 (ix)
   64D8 11 09 00      [10]  309 	ld	de, #0x0009
   64DB 19            [11]  310 	add	hl, de
   64DC 7E            [ 7]  311 	ld	a, (hl)
   64DD DD 77 FE      [19]  312 	ld	-2 (ix), a
   64E0 DD 6E FC      [19]  313 	ld	l,-4 (ix)
   64E3 DD 66 FD      [19]  314 	ld	h,-3 (ix)
   64E6 11 0A 00      [10]  315 	ld	de, #0x000a
   64E9 19            [11]  316 	add	hl, de
   64EA 7E            [ 7]  317 	ld	a, (hl)
   64EB DD 77 F7      [19]  318 	ld	-9 (ix), a
                            319 ;src/render.c:76: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   64EE DD 6E FA      [19]  320 	ld	l,-6 (ix)
   64F1 DD 66 FB      [19]  321 	ld	h,-5 (ix)
   64F4 5E            [ 7]  322 	ld	e, (hl)
   64F5 DD 6E F8      [19]  323 	ld	l,-8 (ix)
   64F8 DD 66 F9      [19]  324 	ld	h,-7 (ix)
   64FB 56            [ 7]  325 	ld	d, (hl)
   64FC FD 2A 65 6C   [20]  326 	ld	iy, (_mem_start)
   6500 C5            [11]  327 	push	bc
   6501 7B            [ 4]  328 	ld	a, e
   6502 F5            [11]  329 	push	af
   6503 33            [ 6]  330 	inc	sp
   6504 D5            [11]  331 	push	de
   6505 33            [ 6]  332 	inc	sp
   6506 FD E5         [15]  333 	push	iy
   6508 CD 52 69      [17]  334 	call	_cpct_getScreenPtr
   650B EB            [ 4]  335 	ex	de,hl
   650C C1            [10]  336 	pop	bc
                            337 ;src/render.c:74: cpct_drawSpriteMasked(sprite,
   650D DD 66 FE      [19]  338 	ld	h, -2 (ix)
   6510 DD 6E F7      [19]  339 	ld	l, -9 (ix)
   6513 E5            [11]  340 	push	hl
   6514 D5            [11]  341 	push	de
   6515 C5            [11]  342 	push	bc
   6516 CD 86 68      [17]  343 	call	_cpct_drawSpriteMasked
   6519                     344 00119$:
                            345 ;src/render.c:76: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   6519 DD 6E F8      [19]  346 	ld	l,-8 (ix)
   651C DD 66 F9      [19]  347 	ld	h,-7 (ix)
   651F 4E            [ 7]  348 	ld	c, (hl)
                            349 ;src/render.c:82: if (!swap_memvideo) {
   6520 3A 68 6C      [13]  350 	ld	a,(#_swap_memvideo + 0)
   6523 B7            [ 4]  351 	or	a, a
   6524 20 23         [12]  352 	jr	NZ,00121$
                            353 ;src/render.c:83: sprites[i].x_prev_B = sprites[i].x;
   6526 DD 7E FC      [19]  354 	ld	a, -4 (ix)
   6529 C6 07         [ 7]  355 	add	a, #0x07
   652B 6F            [ 4]  356 	ld	l, a
   652C DD 7E FD      [19]  357 	ld	a, -3 (ix)
   652F CE 00         [ 7]  358 	adc	a, #0x00
   6531 67            [ 4]  359 	ld	h, a
   6532 71            [ 7]  360 	ld	(hl), c
                            361 ;src/render.c:84: sprites[i].y_prev_B = sprites[i].y;
   6533 DD 7E FC      [19]  362 	ld	a, -4 (ix)
   6536 C6 08         [ 7]  363 	add	a, #0x08
   6538 4F            [ 4]  364 	ld	c, a
   6539 DD 7E FD      [19]  365 	ld	a, -3 (ix)
   653C CE 00         [ 7]  366 	adc	a, #0x00
   653E 47            [ 4]  367 	ld	b, a
   653F DD 6E FA      [19]  368 	ld	l,-6 (ix)
   6542 DD 66 FB      [19]  369 	ld	h,-5 (ix)
   6545 7E            [ 7]  370 	ld	a, (hl)
   6546 02            [ 7]  371 	ld	(bc), a
   6547 18 21         [12]  372 	jr	00127$
   6549                     373 00121$:
                            374 ;src/render.c:86: sprites[i].x_prev_A = sprites[i].x;
   6549 DD 7E FC      [19]  375 	ld	a, -4 (ix)
   654C C6 05         [ 7]  376 	add	a, #0x05
   654E 6F            [ 4]  377 	ld	l, a
   654F DD 7E FD      [19]  378 	ld	a, -3 (ix)
   6552 CE 00         [ 7]  379 	adc	a, #0x00
   6554 67            [ 4]  380 	ld	h, a
   6555 71            [ 7]  381 	ld	(hl), c
                            382 ;src/render.c:87: sprites[i].y_prev_A = sprites[i].y;
   6556 DD 7E FC      [19]  383 	ld	a, -4 (ix)
   6559 C6 06         [ 7]  384 	add	a, #0x06
   655B 4F            [ 4]  385 	ld	c, a
   655C DD 7E FD      [19]  386 	ld	a, -3 (ix)
   655F CE 00         [ 7]  387 	adc	a, #0x00
   6561 47            [ 4]  388 	ld	b, a
   6562 DD 6E FA      [19]  389 	ld	l,-6 (ix)
   6565 DD 66 FB      [19]  390 	ld	h,-5 (ix)
   6568 7E            [ 7]  391 	ld	a, (hl)
   6569 02            [ 7]  392 	ld	(bc), a
   656A                     393 00127$:
                            394 ;src/render.c:45: for (i = 0; i < MAX_SPRITES; i++) {
   656A DD 34 F6      [23]  395 	inc	-10 (ix)
   656D DD 7E F6      [19]  396 	ld	a, -10 (ix)
   6570 D6 0A         [ 7]  397 	sub	a, #0x0a
   6572 DA 01 64      [10]  398 	jp	C, 00126$
   6575 DD F9         [10]  399 	ld	sp, ix
   6577 DD E1         [14]  400 	pop	ix
   6579 C9            [10]  401 	ret
                            402 ;src/render.c:93: void deleteSprites(){
                            403 ;	---------------------------------
                            404 ; Function deleteSprites
                            405 ; ---------------------------------
   657A                     406 _deleteSprites::
   657A DD E5         [15]  407 	push	ix
   657C DD 21 00 00   [14]  408 	ld	ix,#0
   6580 DD 39         [15]  409 	add	ix,sp
   6582 F5            [11]  410 	push	af
                            411 ;src/render.c:98: for (i = 0; i < MAX_SPRITES; i++) {
   6583 0E 00         [ 7]  412 	ld	c, #0x00
   6585                     413 00107$:
                            414 ;src/render.c:99: if (sprites[i].id !=0) {
   6585 06 00         [ 7]  415 	ld	b,#0x00
   6587 69            [ 4]  416 	ld	l, c
   6588 60            [ 4]  417 	ld	h, b
   6589 29            [11]  418 	add	hl, hl
   658A 09            [11]  419 	add	hl, bc
   658B 29            [11]  420 	add	hl, hl
   658C 29            [11]  421 	add	hl, hl
   658D 29            [11]  422 	add	hl, hl
   658E EB            [ 4]  423 	ex	de,hl
   658F 21 A8 69      [10]  424 	ld	hl, #_sprites
   6592 19            [11]  425 	add	hl,de
   6593 EB            [ 4]  426 	ex	de,hl
   6594 1A            [ 7]  427 	ld	a, (de)
   6595 B7            [ 4]  428 	or	a, a
   6596 28 4F         [12]  429 	jr	Z,00108$
                            430 ;src/render.c:100: if (!swap_memvideo){
   6598 3A 68 6C      [13]  431 	ld	a,(#_swap_memvideo + 0)
   659B B7            [ 4]  432 	or	a, a
   659C 20 14         [12]  433 	jr	NZ,00102$
                            434 ;src/render.c:101: x = sprites[i].x_prev_B;
   659E D5            [11]  435 	push	de
   659F FD E1         [14]  436 	pop	iy
   65A1 FD 7E 07      [19]  437 	ld	a, 7 (iy)
   65A4 DD 77 FE      [19]  438 	ld	-2 (ix), a
                            439 ;src/render.c:102: y = sprites[i].y_prev_B;
   65A7 D5            [11]  440 	push	de
   65A8 FD E1         [14]  441 	pop	iy
   65AA FD 7E 08      [19]  442 	ld	a, 8 (iy)
   65AD DD 77 FF      [19]  443 	ld	-1 (ix), a
   65B0 18 12         [12]  444 	jr	00103$
   65B2                     445 00102$:
                            446 ;src/render.c:105: x = sprites[i].x_prev_A;
   65B2 D5            [11]  447 	push	de
   65B3 FD E1         [14]  448 	pop	iy
   65B5 FD 7E 05      [19]  449 	ld	a, 5 (iy)
   65B8 DD 77 FE      [19]  450 	ld	-2 (ix), a
                            451 ;src/render.c:106: y = sprites[i].y_prev_A;
   65BB D5            [11]  452 	push	de
   65BC FD E1         [14]  453 	pop	iy
   65BE FD 7E 06      [19]  454 	ld	a, 6 (iy)
   65C1 DD 77 FF      [19]  455 	ld	-1 (ix), a
   65C4                     456 00103$:
                            457 ;src/render.c:113: redrawTile(mem_start, x, y, sprites[i].width, sprites[i].height);
   65C4 D5            [11]  458 	push	de
   65C5 FD E1         [14]  459 	pop	iy
   65C7 FD 7E 09      [19]  460 	ld	a, 9 (iy)
   65CA EB            [ 4]  461 	ex	de,hl
   65CB 11 0A 00      [10]  462 	ld	de, #0x000a
   65CE 19            [11]  463 	add	hl, de
   65CF 5E            [ 7]  464 	ld	e, (hl)
   65D0 C5            [11]  465 	push	bc
   65D1 57            [ 4]  466 	ld	d,a
   65D2 D5            [11]  467 	push	de
   65D3 DD 66 FF      [19]  468 	ld	h, -1 (ix)
   65D6 DD 6E FE      [19]  469 	ld	l, -2 (ix)
   65D9 E5            [11]  470 	push	hl
   65DA 2A 65 6C      [16]  471 	ld	hl, (_mem_start)
   65DD E5            [11]  472 	push	hl
   65DE CD 45 63      [17]  473 	call	_redrawTile
   65E1 21 06 00      [10]  474 	ld	hl, #6
   65E4 39            [11]  475 	add	hl, sp
   65E5 F9            [ 6]  476 	ld	sp, hl
   65E6 C1            [10]  477 	pop	bc
   65E7                     478 00108$:
                            479 ;src/render.c:98: for (i = 0; i < MAX_SPRITES; i++) {
   65E7 0C            [ 4]  480 	inc	c
   65E8 79            [ 4]  481 	ld	a, c
   65E9 D6 0A         [ 7]  482 	sub	a, #0x0a
   65EB 38 98         [12]  483 	jr	C,00107$
   65ED DD F9         [10]  484 	ld	sp, ix
   65EF DD E1         [14]  485 	pop	ix
   65F1 C9            [10]  486 	ret
                            487 	.area _CODE
                            488 	.area _INITIALIZER
                            489 	.area _CABS (ABS)
