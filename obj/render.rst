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
                             48 ;src/render.c:11: void renderSprites(){
                             49 ;	---------------------------------
                             50 ; Function renderSprites
                             51 ; ---------------------------------
   630D                      52 _renderSprites::
   630D DD E5         [15]   53 	push	ix
   630F DD 21 00 00   [14]   54 	ld	ix,#0
   6313 DD 39         [15]   55 	add	ix,sp
   6315 21 F6 FF      [10]   56 	ld	hl, #-10
   6318 39            [11]   57 	add	hl, sp
   6319 F9            [ 6]   58 	ld	sp, hl
                             59 ;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
   631A DD 36 F6 00   [19]   60 	ld	-10 (ix), #0x00
   631E                      61 00126$:
                             62 ;src/render.c:17: if (sprites[i].id !=0) {						//only live and renderable sprites
   631E DD 4E F6      [19]   63 	ld	c,-10 (ix)
   6321 06 00         [ 7]   64 	ld	b,#0x00
   6323 69            [ 4]   65 	ld	l, c
   6324 60            [ 4]   66 	ld	h, b
   6325 29            [11]   67 	add	hl, hl
   6326 09            [11]   68 	add	hl, bc
   6327 29            [11]   69 	add	hl, hl
   6328 29            [11]   70 	add	hl, hl
   6329 29            [11]   71 	add	hl, hl
   632A 01 F6 68      [10]   72 	ld	bc,#_sprites
   632D 09            [11]   73 	add	hl,bc
   632E DD 75 F8      [19]   74 	ld	-8 (ix), l
   6331 DD 74 F9      [19]   75 	ld	-7 (ix), h
   6334 7E            [ 7]   76 	ld	a, (hl)
   6335 B7            [ 4]   77 	or	a, a
   6336 CA 79 64      [10]   78 	jp	Z, 00127$
                             79 ;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
   6339 C1            [10]   80 	pop	bc
   633A E1            [10]   81 	pop	hl
   633B E5            [11]   82 	push	hl
   633C C5            [11]   83 	push	bc
   633D 11 0B 00      [10]   84 	ld	de, #0x000b
   6340 19            [11]   85 	add	hl, de
   6341 4E            [ 7]   86 	ld	c, (hl)
                             87 ;src/render.c:47: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   6342 DD 7E F8      [19]   88 	ld	a, -8 (ix)
   6345 C6 02         [ 7]   89 	add	a, #0x02
   6347 DD 77 FA      [19]   90 	ld	-6 (ix), a
   634A DD 7E F9      [19]   91 	ld	a, -7 (ix)
   634D CE 00         [ 7]   92 	adc	a, #0x00
   634F DD 77 FB      [19]   93 	ld	-5 (ix), a
   6352 DD 7E F8      [19]   94 	ld	a, -8 (ix)
   6355 C6 01         [ 7]   95 	add	a, #0x01
   6357 DD 77 FE      [19]   96 	ld	-2 (ix), a
   635A DD 7E F9      [19]   97 	ld	a, -7 (ix)
   635D CE 00         [ 7]   98 	adc	a, #0x00
   635F DD 77 FF      [19]   99 	ld	-1 (ix), a
                            100 ;src/render.c:18: if (sprites[i].properties & MASK_RENDER) {
   6362 CB 41         [ 8]  101 	bit	0, c
   6364 CA 28 64      [10]  102 	jp	Z,00119$
                            103 ;src/render.c:33: sprite = sprites[i].sprite_f1; 
   6367 DD 7E F8      [19]  104 	ld	a, -8 (ix)
   636A C6 0F         [ 7]  105 	add	a, #0x0f
   636C DD 77 FC      [19]  106 	ld	-4 (ix), a
   636F DD 7E F9      [19]  107 	ld	a, -7 (ix)
   6372 CE 00         [ 7]  108 	adc	a, #0x00
   6374 DD 77 FD      [19]  109 	ld	-3 (ix), a
                            110 ;src/render.c:20: if (sprites[i].properties & MASK_ANIMATE) {
   6377 CB 49         [ 8]  111 	bit	1, c
   6379 28 4F         [12]  112 	jr	Z,00114$
                            113 ;src/render.c:28: if (anim_clock > 7) num_frame=2;
   637B 3E 07         [ 7]  114 	ld	a, #0x07
   637D FD 21 E6 69   [14]  115 	ld	iy, #_anim_clock
   6381 FD 96 00      [19]  116 	sub	a, 0 (iy)
   6384 30 04         [12]  117 	jr	NC,00102$
   6386 3E 02         [ 7]  118 	ld	a, #0x02
   6388 18 02         [12]  119 	jr	00103$
   638A                     120 00102$:
                            121 ;src/render.c:29: else num_frame=1;
   638A 3E 01         [ 7]  122 	ld	a, #0x01
   638C                     123 00103$:
                            124 ;src/render.c:32: if (num_frame == 1) {
   638C FE 01         [ 7]  125 	cp	a, #0x01
   638E 20 0B         [12]  126 	jr	NZ,00111$
                            127 ;src/render.c:33: sprite = sprites[i].sprite_f1; 
   6390 DD 6E FC      [19]  128 	ld	l,-4 (ix)
   6393 DD 66 FD      [19]  129 	ld	h,-3 (ix)
   6396 4E            [ 7]  130 	ld	c, (hl)
   6397 23            [ 6]  131 	inc	hl
   6398 46            [ 7]  132 	ld	b, (hl)
   6399 18 38         [12]  133 	jr	00115$
   639B                     134 00111$:
                            135 ;src/render.c:34: } else if (num_frame == 2) {
   639B FE 02         [ 7]  136 	cp	a, #0x02
   639D 20 0D         [12]  137 	jr	NZ,00108$
                            138 ;src/render.c:35: sprite = sprites[i].sprite_f2;
   639F C1            [10]  139 	pop	bc
   63A0 E1            [10]  140 	pop	hl
   63A1 E5            [11]  141 	push	hl
   63A2 C5            [11]  142 	push	bc
   63A3 11 11 00      [10]  143 	ld	de, #0x0011
   63A6 19            [11]  144 	add	hl, de
   63A7 4E            [ 7]  145 	ld	c, (hl)
   63A8 23            [ 6]  146 	inc	hl
   63A9 46            [ 7]  147 	ld	b, (hl)
   63AA 18 27         [12]  148 	jr	00115$
   63AC                     149 00108$:
                            150 ;src/render.c:36: } else if (num_frame == 3) { 
   63AC D6 03         [ 7]  151 	sub	a, #0x03
   63AE 20 0D         [12]  152 	jr	NZ,00105$
                            153 ;src/render.c:37: sprite = sprites[i].sprite_f3; 
   63B0 C1            [10]  154 	pop	bc
   63B1 E1            [10]  155 	pop	hl
   63B2 E5            [11]  156 	push	hl
   63B3 C5            [11]  157 	push	bc
   63B4 11 13 00      [10]  158 	ld	de, #0x0013
   63B7 19            [11]  159 	add	hl, de
   63B8 4E            [ 7]  160 	ld	c, (hl)
   63B9 23            [ 6]  161 	inc	hl
   63BA 46            [ 7]  162 	ld	b, (hl)
   63BB 18 16         [12]  163 	jr	00115$
   63BD                     164 00105$:
                            165 ;src/render.c:38: } else sprite = sprites[i].sprite_f4;
   63BD C1            [10]  166 	pop	bc
   63BE E1            [10]  167 	pop	hl
   63BF E5            [11]  168 	push	hl
   63C0 C5            [11]  169 	push	bc
   63C1 11 15 00      [10]  170 	ld	de, #0x0015
   63C4 19            [11]  171 	add	hl, de
   63C5 4E            [ 7]  172 	ld	c, (hl)
   63C6 23            [ 6]  173 	inc	hl
   63C7 46            [ 7]  174 	ld	b, (hl)
   63C8 18 09         [12]  175 	jr	00115$
   63CA                     176 00114$:
                            177 ;src/render.c:39: } else sprite = sprites[i].sprite_f1;
   63CA DD 6E FC      [19]  178 	ld	l,-4 (ix)
   63CD DD 66 FD      [19]  179 	ld	h,-3 (ix)
   63D0 4E            [ 7]  180 	ld	c, (hl)
   63D1 23            [ 6]  181 	inc	hl
   63D2 46            [ 7]  182 	ld	b, (hl)
   63D3                     183 00115$:
                            184 ;src/render.c:41: if (sprites[i].turned)							//turn sprite around
   63D3 D1            [10]  185 	pop	de
   63D4 E1            [10]  186 	pop	hl
   63D5 E5            [11]  187 	push	hl
   63D6 D5            [11]  188 	push	de
   63D7 11 17 00      [10]  189 	ld	de, #0x0017
   63DA 19            [11]  190 	add	hl, de
   63DB 7E            [ 7]  191 	ld	a, (hl)
   63DC B7            [ 4]  192 	or	a, a
   63DD 28 06         [12]  193 	jr	Z,00117$
                            194 ;src/render.c:43: sprite = sprite + ((G_PITU_W*2)*G_PITU_H);	//find next sprite in memory, "rev" version
   63DF 21 C0 01      [10]  195 	ld	hl, #0x01c0
   63E2 09            [11]  196 	add	hl,bc
   63E3 4D            [ 4]  197 	ld	c, l
   63E4 44            [ 4]  198 	ld	b, h
   63E5                     199 00117$:
                            200 ;src/render.c:48: sprites[i].width, sprites[i].height);
   63E5 D1            [10]  201 	pop	de
   63E6 E1            [10]  202 	pop	hl
   63E7 E5            [11]  203 	push	hl
   63E8 D5            [11]  204 	push	de
   63E9 11 09 00      [10]  205 	ld	de, #0x0009
   63EC 19            [11]  206 	add	hl, de
   63ED 7E            [ 7]  207 	ld	a, (hl)
   63EE DD 77 FC      [19]  208 	ld	-4 (ix), a
   63F1 D1            [10]  209 	pop	de
   63F2 E1            [10]  210 	pop	hl
   63F3 E5            [11]  211 	push	hl
   63F4 D5            [11]  212 	push	de
   63F5 11 0A 00      [10]  213 	ld	de, #0x000a
   63F8 19            [11]  214 	add	hl, de
   63F9 7E            [ 7]  215 	ld	a, (hl)
   63FA DD 77 F7      [19]  216 	ld	-9 (ix), a
                            217 ;src/render.c:47: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   63FD DD 6E FA      [19]  218 	ld	l,-6 (ix)
   6400 DD 66 FB      [19]  219 	ld	h,-5 (ix)
   6403 5E            [ 7]  220 	ld	e, (hl)
   6404 DD 6E FE      [19]  221 	ld	l,-2 (ix)
   6407 DD 66 FF      [19]  222 	ld	h,-1 (ix)
   640A 56            [ 7]  223 	ld	d, (hl)
   640B FD 2A E7 69   [20]  224 	ld	iy, (_mem_start)
   640F C5            [11]  225 	push	bc
   6410 7B            [ 4]  226 	ld	a, e
   6411 F5            [11]  227 	push	af
   6412 33            [ 6]  228 	inc	sp
   6413 D5            [11]  229 	push	de
   6414 33            [ 6]  230 	inc	sp
   6415 FD E5         [15]  231 	push	iy
   6417 CD D0 68      [17]  232 	call	_cpct_getScreenPtr
   641A EB            [ 4]  233 	ex	de,hl
   641B C1            [10]  234 	pop	bc
                            235 ;src/render.c:45: cpct_drawSpriteMasked(sprite,
   641C DD 66 FC      [19]  236 	ld	h, -4 (ix)
   641F DD 6E F7      [19]  237 	ld	l, -9 (ix)
   6422 E5            [11]  238 	push	hl
   6423 D5            [11]  239 	push	de
   6424 C5            [11]  240 	push	bc
   6425 CD 65 67      [17]  241 	call	_cpct_drawSpriteMasked
   6428                     242 00119$:
                            243 ;src/render.c:47: cpct_getScreenPtr(mem_start, sprites[i].x, sprites[i].y),
   6428 DD 6E FE      [19]  244 	ld	l,-2 (ix)
   642B DD 66 FF      [19]  245 	ld	h,-1 (ix)
   642E 4E            [ 7]  246 	ld	c, (hl)
                            247 ;src/render.c:53: if (!swap_memvideo) {
   642F 3A EA 69      [13]  248 	ld	a,(#_swap_memvideo + 0)
   6432 B7            [ 4]  249 	or	a, a
   6433 20 23         [12]  250 	jr	NZ,00121$
                            251 ;src/render.c:54: sprites[i].x_prev_B = sprites[i].x;
   6435 DD 7E F8      [19]  252 	ld	a, -8 (ix)
   6438 C6 07         [ 7]  253 	add	a, #0x07
   643A 6F            [ 4]  254 	ld	l, a
   643B DD 7E F9      [19]  255 	ld	a, -7 (ix)
   643E CE 00         [ 7]  256 	adc	a, #0x00
   6440 67            [ 4]  257 	ld	h, a
   6441 71            [ 7]  258 	ld	(hl), c
                            259 ;src/render.c:55: sprites[i].y_prev_B = sprites[i].y;
   6442 DD 7E F8      [19]  260 	ld	a, -8 (ix)
   6445 C6 08         [ 7]  261 	add	a, #0x08
   6447 4F            [ 4]  262 	ld	c, a
   6448 DD 7E F9      [19]  263 	ld	a, -7 (ix)
   644B CE 00         [ 7]  264 	adc	a, #0x00
   644D 47            [ 4]  265 	ld	b, a
   644E DD 6E FA      [19]  266 	ld	l,-6 (ix)
   6451 DD 66 FB      [19]  267 	ld	h,-5 (ix)
   6454 7E            [ 7]  268 	ld	a, (hl)
   6455 02            [ 7]  269 	ld	(bc), a
   6456 18 21         [12]  270 	jr	00127$
   6458                     271 00121$:
                            272 ;src/render.c:57: sprites[i].x_prev_A = sprites[i].x;
   6458 DD 7E F8      [19]  273 	ld	a, -8 (ix)
   645B C6 05         [ 7]  274 	add	a, #0x05
   645D 6F            [ 4]  275 	ld	l, a
   645E DD 7E F9      [19]  276 	ld	a, -7 (ix)
   6461 CE 00         [ 7]  277 	adc	a, #0x00
   6463 67            [ 4]  278 	ld	h, a
   6464 71            [ 7]  279 	ld	(hl), c
                            280 ;src/render.c:58: sprites[i].y_prev_A = sprites[i].y;
   6465 DD 7E F8      [19]  281 	ld	a, -8 (ix)
   6468 C6 06         [ 7]  282 	add	a, #0x06
   646A 4F            [ 4]  283 	ld	c, a
   646B DD 7E F9      [19]  284 	ld	a, -7 (ix)
   646E CE 00         [ 7]  285 	adc	a, #0x00
   6470 47            [ 4]  286 	ld	b, a
   6471 DD 6E FA      [19]  287 	ld	l,-6 (ix)
   6474 DD 66 FB      [19]  288 	ld	h,-5 (ix)
   6477 7E            [ 7]  289 	ld	a, (hl)
   6478 02            [ 7]  290 	ld	(bc), a
   6479                     291 00127$:
                            292 ;src/render.c:16: for (i = 0; i < MAX_SPRITES; i++) {
   6479 DD 34 F6      [23]  293 	inc	-10 (ix)
   647C DD 7E F6      [19]  294 	ld	a, -10 (ix)
   647F D6 0A         [ 7]  295 	sub	a, #0x0a
   6481 DA 1E 63      [10]  296 	jp	C, 00126$
   6484 DD F9         [10]  297 	ld	sp, ix
   6486 DD E1         [14]  298 	pop	ix
   6488 C9            [10]  299 	ret
                            300 ;src/render.c:64: void deleteSprites(){
                            301 ;	---------------------------------
                            302 ; Function deleteSprites
                            303 ; ---------------------------------
   6489                     304 _deleteSprites::
   6489 DD E5         [15]  305 	push	ix
   648B DD 21 00 00   [14]  306 	ld	ix,#0
   648F DD 39         [15]  307 	add	ix,sp
   6491 21 F5 FF      [10]  308 	ld	hl, #-11
   6494 39            [11]  309 	add	hl, sp
   6495 F9            [ 6]  310 	ld	sp, hl
                            311 ;src/render.c:69: for (i = 0; i < MAX_SPRITES; i++) {
   6496 DD 36 F5 00   [19]  312 	ld	-11 (ix), #0x00
   649A                     313 00107$:
                            314 ;src/render.c:70: if (sprites[i].id !=0) {
   649A DD 4E F5      [19]  315 	ld	c,-11 (ix)
   649D 06 00         [ 7]  316 	ld	b,#0x00
   649F 69            [ 4]  317 	ld	l, c
   64A0 60            [ 4]  318 	ld	h, b
   64A1 29            [11]  319 	add	hl, hl
   64A2 09            [11]  320 	add	hl, bc
   64A3 29            [11]  321 	add	hl, hl
   64A4 29            [11]  322 	add	hl, hl
   64A5 29            [11]  323 	add	hl, hl
   64A6 01 F6 68      [10]  324 	ld	bc,#_sprites
   64A9 09            [11]  325 	add	hl,bc
   64AA DD 75 FD      [19]  326 	ld	-3 (ix), l
   64AD DD 74 FE      [19]  327 	ld	-2 (ix), h
   64B0 7E            [ 7]  328 	ld	a, (hl)
   64B1 DD 77 FF      [19]  329 	ld	-1 (ix), a
   64B4 B7            [ 4]  330 	or	a, a
   64B5 CA 66 65      [10]  331 	jp	Z, 00108$
                            332 ;src/render.c:71: if (!swap_memvideo){
   64B8 3A EA 69      [13]  333 	ld	a,(#_swap_memvideo + 0)
   64BB B7            [ 4]  334 	or	a, a
   64BC 20 1E         [12]  335 	jr	NZ,00102$
                            336 ;src/render.c:72: x = sprites[i].x_prev_B;
   64BE DD 6E FD      [19]  337 	ld	l,-3 (ix)
   64C1 DD 66 FE      [19]  338 	ld	h,-2 (ix)
   64C4 11 07 00      [10]  339 	ld	de, #0x0007
   64C7 19            [11]  340 	add	hl, de
   64C8 7E            [ 7]  341 	ld	a, (hl)
   64C9 DD 77 FF      [19]  342 	ld	-1 (ix), a
                            343 ;src/render.c:73: y = sprites[i].y_prev_B;
   64CC DD 6E FD      [19]  344 	ld	l,-3 (ix)
   64CF DD 66 FE      [19]  345 	ld	h,-2 (ix)
   64D2 11 08 00      [10]  346 	ld	de, #0x0008
   64D5 19            [11]  347 	add	hl, de
   64D6 7E            [ 7]  348 	ld	a, (hl)
   64D7 DD 77 FC      [19]  349 	ld	-4 (ix), a
   64DA 18 1C         [12]  350 	jr	00103$
   64DC                     351 00102$:
                            352 ;src/render.c:76: x = sprites[i].x_prev_A;
   64DC DD 6E FD      [19]  353 	ld	l,-3 (ix)
   64DF DD 66 FE      [19]  354 	ld	h,-2 (ix)
   64E2 11 05 00      [10]  355 	ld	de, #0x0005
   64E5 19            [11]  356 	add	hl, de
   64E6 7E            [ 7]  357 	ld	a, (hl)
   64E7 DD 77 FF      [19]  358 	ld	-1 (ix), a
                            359 ;src/render.c:77: y = sprites[i].y_prev_A;
   64EA DD 6E FD      [19]  360 	ld	l,-3 (ix)
   64ED DD 66 FE      [19]  361 	ld	h,-2 (ix)
   64F0 11 06 00      [10]  362 	ld	de, #0x0006
   64F3 19            [11]  363 	add	hl, de
   64F4 7E            [ 7]  364 	ld	a, (hl)
   64F5 DD 77 FC      [19]  365 	ld	-4 (ix), a
   64F8                     366 00103$:
                            367 ;src/render.c:82: sprites[i].width, sprites[i].height);
   64F8 DD 7E FD      [19]  368 	ld	a, -3 (ix)
   64FB DD 77 FA      [19]  369 	ld	-6 (ix), a
   64FE DD 7E FE      [19]  370 	ld	a, -2 (ix)
   6501 DD 77 FB      [19]  371 	ld	-5 (ix), a
   6504 DD 6E FA      [19]  372 	ld	l,-6 (ix)
   6507 DD 66 FB      [19]  373 	ld	h,-5 (ix)
   650A 11 09 00      [10]  374 	ld	de, #0x0009
   650D 19            [11]  375 	add	hl, de
   650E 7E            [ 7]  376 	ld	a, (hl)
   650F DD 77 FA      [19]  377 	ld	-6 (ix), a
   6512 DD 6E FD      [19]  378 	ld	l,-3 (ix)
   6515 DD 66 FE      [19]  379 	ld	h,-2 (ix)
   6518 11 0A 00      [10]  380 	ld	de, #0x000a
   651B 19            [11]  381 	add	hl, de
   651C 7E            [ 7]  382 	ld	a, (hl)
   651D DD 77 FD      [19]  383 	ld	-3 (ix), a
                            384 ;src/render.c:81: cpct_px2byteM0(5,5),						//background color
   6520 21 05 05      [10]  385 	ld	hl, #0x0505
   6523 E5            [11]  386 	push	hl
   6524 CD C9 67      [17]  387 	call	_cpct_px2byteM0
   6527 DD 75 F8      [19]  388 	ld	-8 (ix), l
   652A DD 36 F9 00   [19]  389 	ld	-7 (ix), #0x00
                            390 ;src/render.c:80: cpct_getScreenPtr(mem_start, x, y),
   652E 2A E7 69      [16]  391 	ld	hl, (_mem_start)
   6531 DD 75 F6      [19]  392 	ld	-10 (ix), l
   6534 DD 74 F7      [19]  393 	ld	-9 (ix), h
   6537 DD 66 FC      [19]  394 	ld	h, -4 (ix)
   653A DD 6E FF      [19]  395 	ld	l, -1 (ix)
   653D E5            [11]  396 	push	hl
   653E DD 6E F6      [19]  397 	ld	l,-10 (ix)
   6541 DD 66 F7      [19]  398 	ld	h,-9 (ix)
   6544 E5            [11]  399 	push	hl
   6545 CD D0 68      [17]  400 	call	_cpct_getScreenPtr
   6548 DD 74 F7      [19]  401 	ld	-9 (ix), h
   654B DD 75 F6      [19]  402 	ld	-10 (ix), l
   654E DD 66 FA      [19]  403 	ld	h, -6 (ix)
   6551 DD 6E FD      [19]  404 	ld	l, -3 (ix)
   6554 E5            [11]  405 	push	hl
   6555 DD 6E F8      [19]  406 	ld	l,-8 (ix)
   6558 DD 66 F9      [19]  407 	ld	h,-7 (ix)
   655B E5            [11]  408 	push	hl
   655C DD 6E F6      [19]  409 	ld	l,-10 (ix)
   655F DD 66 F7      [19]  410 	ld	h,-9 (ix)
   6562 E5            [11]  411 	push	hl
   6563 CD 03 68      [17]  412 	call	_cpct_drawSolidBox
   6566                     413 00108$:
                            414 ;src/render.c:69: for (i = 0; i < MAX_SPRITES; i++) {
   6566 DD 34 F5      [23]  415 	inc	-11 (ix)
   6569 DD 7E F5      [19]  416 	ld	a, -11 (ix)
   656C D6 0A         [ 7]  417 	sub	a, #0x0a
   656E DA 9A 64      [10]  418 	jp	C, 00107$
   6571 DD F9         [10]  419 	ld	sp, ix
   6573 DD E1         [14]  420 	pop	ix
   6575 C9            [10]  421 	ret
                            422 	.area _CODE
                            423 	.area _INITIALIZER
                            424 	.area _CABS (ABS)
