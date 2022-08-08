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
                             12 	.globl _init_game
                             13 	.globl _collisions
                             14 	.globl _init_level
                             15 	.globl _moveSprites
                             16 	.globl _AI
                             17 	.globl _keyboard
                             18 	.globl _deleteSprites
                             19 	.globl _renderSprites
                             20 	.globl _cpct_etm_drawTilemap4x8_ag
                             21 	.globl _cpct_etm_setDrawTilemap4x8_ag
                             22 	.globl _cpct_setVideoMemoryPage
                             23 	.globl _cpct_setPALColour
                             24 	.globl _cpct_waitVSYNC
                             25 	.globl _cpct_px2byteM0
                             26 	.globl _cpct_isKeyPressed
                             27 	.globl _cpct_scanKeyboard_f
                             28 	.globl _cpct_memcpy
                             29 	.globl _cpct_memset
                             30 	.globl _map
                             31 	.globl _anim_clock
                             32 	.globl _sprites
                             33 ;--------------------------------------------------------
                             34 ; special function registers
                             35 ;--------------------------------------------------------
                             36 ;--------------------------------------------------------
                             37 ; ram data
                             38 ;--------------------------------------------------------
                             39 	.area _DATA
   6A19                      40 _sprites::
   6A19                      41 	.ds 240
   6B09                      42 _anim_clock::
   6B09                      43 	.ds 1
   6B0A                      44 _map::
   6B0A                      45 	.ds 460
                             46 ;--------------------------------------------------------
                             47 ; ram data
                             48 ;--------------------------------------------------------
                             49 	.area _INITIALIZED
                             50 ;--------------------------------------------------------
                             51 ; absolute external ram data
                             52 ;--------------------------------------------------------
                             53 	.area _DABS (ABS)
                             54 ;--------------------------------------------------------
                             55 ; global & static initialisations
                             56 ;--------------------------------------------------------
                             57 	.area _HOME
                             58 	.area _GSINIT
                             59 	.area _GSFINAL
                             60 	.area _GSINIT
                             61 ;--------------------------------------------------------
                             62 ; Home
                             63 ;--------------------------------------------------------
                             64 	.area _HOME
                             65 	.area _HOME
                             66 ;--------------------------------------------------------
                             67 ; code
                             68 ;--------------------------------------------------------
                             69 	.area _CODE
                             70 ;src/game.c:19: void keyboard(){
                             71 ;	---------------------------------
                             72 ; Function keyboard
                             73 ; ---------------------------------
   43CC                      74 _keyboard::
                             75 ;src/game.c:22: sprites[0].moveV = sprites[0].moveH = 0; 							//start with no movement
   43CC 21 1D 6A      [10]   76 	ld	hl, #(_sprites + 0x0004)
   43CF 36 00         [10]   77 	ld	(hl), #0x00
   43D1 21 1C 6A      [10]   78 	ld	hl, #(_sprites + 0x0003)
   43D4 36 00         [10]   79 	ld	(hl), #0x00
                             80 ;src/game.c:25: cpct_scanKeyboard_f();
   43D6 CD DF 65      [17]   81 	call	_cpct_scanKeyboard_f
                             82 ;src/game.c:26: if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
   43D9 21 00 01      [10]   83 	ld	hl, #0x0100
   43DC CD D3 65      [17]   84 	call	_cpct_isKeyPressed
   43DF 7D            [ 4]   85 	ld	a, l
   43E0 B7            [ 4]   86 	or	a, a
   43E1 20 14         [12]   87 	jr	NZ,00101$
   43E3 21 08 08      [10]   88 	ld	hl, #0x0808
   43E6 CD D3 65      [17]   89 	call	_cpct_isKeyPressed
   43E9 7D            [ 4]   90 	ld	a, l
   43EA B7            [ 4]   91 	or	a, a
   43EB 20 0A         [12]   92 	jr	NZ,00101$
   43ED 21 09 01      [10]   93 	ld	hl, #0x0109
   43F0 CD D3 65      [17]   94 	call	_cpct_isKeyPressed
   43F3 7D            [ 4]   95 	ld	a, l
   43F4 B7            [ 4]   96 	or	a, a
   43F5 28 05         [12]   97 	jr	Z,00102$
   43F7                      98 00101$:
                             99 ;src/game.c:27: sprites[0].moveV = -1;		
   43F7 21 1C 6A      [10]  100 	ld	hl, #(_sprites + 0x0003)
   43FA 36 FF         [10]  101 	ld	(hl), #0xff
   43FC                     102 00102$:
                            103 ;src/game.c:29: if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
   43FC 21 00 04      [10]  104 	ld	hl, #0x0400
   43FF CD D3 65      [17]  105 	call	_cpct_isKeyPressed
   4402 7D            [ 4]  106 	ld	a, l
   4403 B7            [ 4]  107 	or	a, a
   4404 20 14         [12]  108 	jr	NZ,00105$
   4406 21 08 20      [10]  109 	ld	hl, #0x2008
   4409 CD D3 65      [17]  110 	call	_cpct_isKeyPressed
   440C 7D            [ 4]  111 	ld	a, l
   440D B7            [ 4]  112 	or	a, a
   440E 20 0A         [12]  113 	jr	NZ,00105$
   4410 21 09 02      [10]  114 	ld	hl, #0x0209
   4413 CD D3 65      [17]  115 	call	_cpct_isKeyPressed
   4416 7D            [ 4]  116 	ld	a, l
   4417 B7            [ 4]  117 	or	a, a
   4418 28 05         [12]  118 	jr	Z,00106$
   441A                     119 00105$:
                            120 ;src/game.c:30: sprites[0].moveV = 1;
   441A 21 1C 6A      [10]  121 	ld	hl, #(_sprites + 0x0003)
   441D 36 01         [10]  122 	ld	(hl), #0x01
   441F                     123 00106$:
                            124 ;src/game.c:32: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   441F 21 01 01      [10]  125 	ld	hl, #0x0101
   4422 CD D3 65      [17]  126 	call	_cpct_isKeyPressed
                            127 ;src/game.c:34: sprites[0].turned = 1;
                            128 ;src/game.c:32: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   4425 7D            [ 4]  129 	ld	a, l
   4426 B7            [ 4]  130 	or	a, a
   4427 20 14         [12]  131 	jr	NZ,00109$
   4429 21 04 04      [10]  132 	ld	hl, #0x0404
   442C CD D3 65      [17]  133 	call	_cpct_isKeyPressed
   442F 7D            [ 4]  134 	ld	a, l
   4430 B7            [ 4]  135 	or	a, a
   4431 20 0A         [12]  136 	jr	NZ,00109$
   4433 21 09 04      [10]  137 	ld	hl, #0x0409
   4436 CD D3 65      [17]  138 	call	_cpct_isKeyPressed
   4439 7D            [ 4]  139 	ld	a, l
   443A B7            [ 4]  140 	or	a, a
   443B 28 0A         [12]  141 	jr	Z,00110$
   443D                     142 00109$:
                            143 ;src/game.c:33: sprites[0].moveH = -1;
   443D 21 1D 6A      [10]  144 	ld	hl, #(_sprites + 0x0004)
   4440 36 FF         [10]  145 	ld	(hl), #0xff
                            146 ;src/game.c:34: sprites[0].turned = 1;
   4442 21 30 6A      [10]  147 	ld	hl, #(_sprites + 0x0017)
   4445 36 01         [10]  148 	ld	(hl), #0x01
   4447                     149 00110$:
                            150 ;src/game.c:36: if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
   4447 21 00 02      [10]  151 	ld	hl, #0x0200
   444A CD D3 65      [17]  152 	call	_cpct_isKeyPressed
   444D 7D            [ 4]  153 	ld	a, l
   444E B7            [ 4]  154 	or	a, a
   444F 20 14         [12]  155 	jr	NZ,00113$
   4451 21 03 08      [10]  156 	ld	hl, #0x0803
   4454 CD D3 65      [17]  157 	call	_cpct_isKeyPressed
   4457 7D            [ 4]  158 	ld	a, l
   4458 B7            [ 4]  159 	or	a, a
   4459 20 0A         [12]  160 	jr	NZ,00113$
   445B 21 09 08      [10]  161 	ld	hl, #0x0809
   445E CD D3 65      [17]  162 	call	_cpct_isKeyPressed
   4461 7D            [ 4]  163 	ld	a, l
   4462 B7            [ 4]  164 	or	a, a
   4463 28 0A         [12]  165 	jr	Z,00114$
   4465                     166 00113$:
                            167 ;src/game.c:37: sprites[0].moveH = 1;
   4465 21 1D 6A      [10]  168 	ld	hl, #(_sprites + 0x0004)
   4468 36 01         [10]  169 	ld	(hl), #0x01
                            170 ;src/game.c:38: sprites[0].turned = 0;
   446A 21 30 6A      [10]  171 	ld	hl, #(_sprites + 0x0017)
   446D 36 00         [10]  172 	ld	(hl), #0x00
   446F                     173 00114$:
                            174 ;src/game.c:42: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
   446F 21 1D 6A      [10]  175 	ld	hl, #(_sprites + 0x0004) + 0
   4472 4E            [ 7]  176 	ld	c, (hl)
                            177 ;src/game.c:43: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
   4473 11 24 6A      [10]  178 	ld	de, #_sprites + 11
   4476 1A            [ 7]  179 	ld	a, (de)
   4477 47            [ 4]  180 	ld	b, a
                            181 ;src/game.c:42: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
   4478 79            [ 4]  182 	ld	a, c
   4479 B7            [ 4]  183 	or	a, a
   447A 20 06         [12]  184 	jr	NZ,00117$
   447C 3A 1C 6A      [13]  185 	ld	a, (#(_sprites + 0x0003) + 0)
   447F B7            [ 4]  186 	or	a, a
   4480 28 05         [12]  187 	jr	Z,00118$
   4482                     188 00117$:
                            189 ;src/game.c:43: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
   4482 78            [ 4]  190 	ld	a, b
   4483 CB CF         [ 8]  191 	set	1, a
   4485 12            [ 7]  192 	ld	(de), a
   4486 C9            [10]  193 	ret
   4487                     194 00118$:
                            195 ;src/game.c:45: sprites[0].properties = sprites[0].properties & ~MASK_ANIMATE;	//unmark for animation;
   4487 CB 88         [ 8]  196 	res	1, b
   4489 78            [ 4]  197 	ld	a, b
   448A 12            [ 7]  198 	ld	(de), a
   448B C9            [10]  199 	ret
                            200 ;src/game.c:50: void AI(){
                            201 ;	---------------------------------
                            202 ; Function AI
                            203 ; ---------------------------------
   448C                     204 _AI::
                            205 ;src/game.c:51: }
   448C C9            [10]  206 	ret
                            207 ;src/game.c:55: void moveSprites() {
                            208 ;	---------------------------------
                            209 ; Function moveSprites
                            210 ; ---------------------------------
   448D                     211 _moveSprites::
   448D DD E5         [15]  212 	push	ix
   448F DD 21 00 00   [14]  213 	ld	ix,#0
   4493 DD 39         [15]  214 	add	ix,sp
   4495 21 F6 FF      [10]  215 	ld	hl, #-10
   4498 39            [11]  216 	add	hl, sp
   4499 F9            [ 6]  217 	ld	sp, hl
                            218 ;src/game.c:59: for (i=0; i < MAX_SPRITES; i++) {
   449A DD 36 F6 00   [19]  219 	ld	-10 (ix), #0x00
   449E                     220 00116$:
                            221 ;src/game.c:60: if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
   449E DD 4E F6      [19]  222 	ld	c,-10 (ix)
   44A1 06 00         [ 7]  223 	ld	b,#0x00
   44A3 69            [ 4]  224 	ld	l, c
   44A4 60            [ 4]  225 	ld	h, b
   44A5 29            [11]  226 	add	hl, hl
   44A6 09            [11]  227 	add	hl, bc
   44A7 29            [11]  228 	add	hl, hl
   44A8 29            [11]  229 	add	hl, hl
   44A9 29            [11]  230 	add	hl, hl
   44AA 01 19 6A      [10]  231 	ld	bc,#_sprites
   44AD 09            [11]  232 	add	hl,bc
   44AE DD 75 FB      [19]  233 	ld	-5 (ix), l
   44B1 DD 74 FC      [19]  234 	ld	-4 (ix), h
   44B4 7E            [ 7]  235 	ld	a, (hl)
   44B5 DD 77 FD      [19]  236 	ld	-3 (ix), a
   44B8 B7            [ 4]  237 	or	a, a
   44B9 CA 8B 45      [10]  238 	jp	Z, 00117$
                            239 ;src/game.c:61: collision = 0;
   44BC DD 36 F8 00   [19]  240 	ld	-8 (ix), #0x00
                            241 ;src/game.c:63: x = sprites[i].x;
   44C0 DD 7E FB      [19]  242 	ld	a, -5 (ix)
   44C3 C6 01         [ 7]  243 	add	a, #0x01
   44C5 DD 77 FE      [19]  244 	ld	-2 (ix), a
   44C8 DD 7E FC      [19]  245 	ld	a, -4 (ix)
   44CB CE 00         [ 7]  246 	adc	a, #0x00
   44CD DD 77 FF      [19]  247 	ld	-1 (ix), a
   44D0 DD 6E FE      [19]  248 	ld	l,-2 (ix)
   44D3 DD 66 FF      [19]  249 	ld	h,-1 (ix)
   44D6 4E            [ 7]  250 	ld	c, (hl)
                            251 ;src/game.c:64: y = sprites[i].y;
   44D7 DD 7E FB      [19]  252 	ld	a, -5 (ix)
   44DA C6 02         [ 7]  253 	add	a, #0x02
   44DC DD 77 F9      [19]  254 	ld	-7 (ix), a
   44DF DD 7E FC      [19]  255 	ld	a, -4 (ix)
   44E2 CE 00         [ 7]  256 	adc	a, #0x00
   44E4 DD 77 FA      [19]  257 	ld	-6 (ix), a
   44E7 DD 6E F9      [19]  258 	ld	l,-7 (ix)
   44EA DD 66 FA      [19]  259 	ld	h,-6 (ix)
   44ED 46            [ 7]  260 	ld	b, (hl)
                            261 ;src/game.c:66: x = x + (sprites[i].moveH);
   44EE DD 6E FB      [19]  262 	ld	l,-5 (ix)
   44F1 DD 66 FC      [19]  263 	ld	h,-4 (ix)
   44F4 11 04 00      [10]  264 	ld	de, #0x0004
   44F7 19            [11]  265 	add	hl, de
   44F8 6E            [ 7]  266 	ld	l, (hl)
   44F9 09            [11]  267 	add	hl, bc
   44FA 4D            [ 4]  268 	ld	c, l
                            269 ;src/game.c:67: y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
   44FB DD 6E FB      [19]  270 	ld	l,-5 (ix)
   44FE DD 66 FC      [19]  271 	ld	h,-4 (ix)
   4501 23            [ 6]  272 	inc	hl
   4502 23            [ 6]  273 	inc	hl
   4503 23            [ 6]  274 	inc	hl
   4504 7E            [ 7]  275 	ld	a, (hl)
   4505 87            [ 4]  276 	add	a, a
   4506 87            [ 4]  277 	add	a, a
   4507 5F            [ 4]  278 	ld	e, a
   4508 68            [ 4]  279 	ld	l, b
   4509 19            [11]  280 	add	hl, de
   450A DD 75 F7      [19]  281 	ld	-9 (ix), l
                            282 ;src/game.c:70: if (x > (GAME_AREA_RIGHT - sprites[i].width))
   450D DD 6E FB      [19]  283 	ld	l,-5 (ix)
   4510 DD 66 FC      [19]  284 	ld	h,-4 (ix)
   4513 11 0A 00      [10]  285 	ld	de, #0x000a
   4516 19            [11]  286 	add	hl, de
   4517 5E            [ 7]  287 	ld	e, (hl)
   4518 16 00         [ 7]  288 	ld	d, #0x00
   451A 3E 50         [ 7]  289 	ld	a, #0x50
   451C 93            [ 4]  290 	sub	a, e
   451D 47            [ 4]  291 	ld	b, a
   451E 3E 00         [ 7]  292 	ld	a, #0x00
   4520 9A            [ 4]  293 	sbc	a, d
   4521 5F            [ 4]  294 	ld	e, a
   4522 69            [ 4]  295 	ld	l, c
   4523 16 00         [ 7]  296 	ld	d, #0x00
   4525 78            [ 4]  297 	ld	a, b
   4526 95            [ 4]  298 	sub	a, l
   4527 7B            [ 4]  299 	ld	a, e
   4528 9A            [ 4]  300 	sbc	a, d
   4529 E2 2E 45      [10]  301 	jp	PO, 00149$
   452C EE 80         [ 7]  302 	xor	a, #0x80
   452E                     303 00149$:
   452E F2 35 45      [10]  304 	jp	P, 00104$
                            305 ;src/game.c:71: collision = collision | RIGHT_COLLISION;
   4531 DD 36 F8 02   [19]  306 	ld	-8 (ix), #0x02
                            307 ;src/game.c:73: collision = collision | LEFT_COLLISION;
   4535                     308 00104$:
                            309 ;src/game.c:75: if (y > (GAME_AREA_BOTTOM - sprites[i].height))
   4535 DD 6E FB      [19]  310 	ld	l,-5 (ix)
   4538 DD 66 FC      [19]  311 	ld	h,-4 (ix)
   453B 11 09 00      [10]  312 	ld	de, #0x0009
   453E 19            [11]  313 	add	hl, de
   453F 5E            [ 7]  314 	ld	e, (hl)
   4540 16 00         [ 7]  315 	ld	d, #0x00
   4542 3E C8         [ 7]  316 	ld	a, #0xc8
   4544 93            [ 4]  317 	sub	a, e
   4545 5F            [ 4]  318 	ld	e, a
   4546 3E 00         [ 7]  319 	ld	a, #0x00
   4548 9A            [ 4]  320 	sbc	a, d
   4549 57            [ 4]  321 	ld	d, a
   454A DD 6E F7      [19]  322 	ld	l, -9 (ix)
   454D 26 00         [ 7]  323 	ld	h, #0x00
   454F 7B            [ 4]  324 	ld	a, e
   4550 95            [ 4]  325 	sub	a, l
   4551 7A            [ 4]  326 	ld	a, d
   4552 9C            [ 4]  327 	sbc	a, h
   4553 E2 58 45      [10]  328 	jp	PO, 00150$
   4556 EE 80         [ 7]  329 	xor	a, #0x80
   4558                     330 00150$:
   4558 F2 5F 45      [10]  331 	jp	P, 00106$
                            332 ;src/game.c:76: collision = collision | BOTTOM_COLLISION;
   455B DD CB F8 C6   [23]  333 	set	0, -8 (ix)
   455F                     334 00106$:
                            335 ;src/game.c:77: if (y < GAME_AREA_TOP)
   455F DD 7E F7      [19]  336 	ld	a, -9 (ix)
   4562 D6 10         [ 7]  337 	sub	a, #0x10
   4564 30 08         [12]  338 	jr	NC,00108$
                            339 ;src/game.c:78: collision = collision | TOP_COLLISION;
   4566 DD 7E F8      [19]  340 	ld	a, -8 (ix)
   4569 F6 05         [ 7]  341 	or	a, #0x05
   456B DD 77 F8      [19]  342 	ld	-8 (ix), a
   456E                     343 00108$:
                            344 ;src/game.c:82: if ((collision & LEFT_RIGHT_COLLISION) == 0)		//if not hitting right, move up/down
   456E DD CB F8 4E   [20]  345 	bit	1, -8 (ix)
   4572 20 07         [12]  346 	jr	NZ,00110$
                            347 ;src/game.c:83: sprites[i].x = x;								//keep x as it was
   4574 DD 6E FE      [19]  348 	ld	l,-2 (ix)
   4577 DD 66 FF      [19]  349 	ld	h,-1 (ix)
   457A 71            [ 7]  350 	ld	(hl), c
   457B                     351 00110$:
                            352 ;src/game.c:85: if ((collision & TOP_BOTTOM_COLLISION) == 0)		//if not hitting top, move sideways //
   457B DD CB F8 46   [20]  353 	bit	0, -8 (ix)
   457F 20 0A         [12]  354 	jr	NZ,00117$
                            355 ;src/game.c:86: sprites[i].y = y;								//keep y as it was
   4581 DD 6E F9      [19]  356 	ld	l,-7 (ix)
   4584 DD 66 FA      [19]  357 	ld	h,-6 (ix)
   4587 DD 7E F7      [19]  358 	ld	a, -9 (ix)
   458A 77            [ 7]  359 	ld	(hl), a
   458B                     360 00117$:
                            361 ;src/game.c:59: for (i=0; i < MAX_SPRITES; i++) {
   458B DD 34 F6      [23]  362 	inc	-10 (ix)
   458E DD 7E F6      [19]  363 	ld	a, -10 (ix)
   4591 D6 0A         [ 7]  364 	sub	a, #0x0a
   4593 DA 9E 44      [10]  365 	jp	C, 00116$
   4596 DD F9         [10]  366 	ld	sp, ix
   4598 DD E1         [14]  367 	pop	ix
   459A C9            [10]  368 	ret
                            369 ;src/game.c:94: void init_level() {
                            370 ;	---------------------------------
                            371 ; Function init_level
                            372 ; ---------------------------------
   459B                     373 _init_level::
                            374 ;src/game.c:100: cpct_memcpy((u8*)map, (u8*)G_map, G_map_W*G_map_H);
   459B 21 CC 01      [10]  375 	ld	hl, #0x01cc
   459E E5            [11]  376 	push	hl
   459F 21 00 40      [10]  377 	ld	hl, #_G_map
   45A2 E5            [11]  378 	push	hl
   45A3 21 0A 6B      [10]  379 	ld	hl, #_map
   45A6 E5            [11]  380 	push	hl
   45A7 CD D0 68      [17]  381 	call	_cpct_memcpy
                            382 ;src/game.c:102: cpct_etm_setDrawTilemap4x8_ag( G_map_W, G_map_H, G_map_W, G_tileset_00); //3rd param (20,G_map_W) is how many tiles per line
   45AA 21 CC 41      [10]  383 	ld	hl, #_G_tileset_00
   45AD E5            [11]  384 	push	hl
   45AE 21 14 00      [10]  385 	ld	hl, #0x0014
   45B1 E5            [11]  386 	push	hl
   45B2 26 17         [ 7]  387 	ld	h, #0x17
   45B4 E5            [11]  388 	push	hl
   45B5 CD D9 69      [17]  389 	call	_cpct_etm_setDrawTilemap4x8_ag
                            390 ;src/game.c:104: cpct_etm_drawTilemap4x8_ag( cpctm_screenPtr((u8*) CPCT_VMEM_START, GAME_AREA_LEFT, GAME_AREA_TOP), map );
   45B8 21 0A 6B      [10]  391 	ld	hl, #_map
   45BB E5            [11]  392 	push	hl
   45BC 21 A0 C0      [10]  393 	ld	hl, #0xc0a0
   45BF E5            [11]  394 	push	hl
   45C0 CD 98 67      [17]  395 	call	_cpct_etm_drawTilemap4x8_ag
                            396 ;src/game.c:105: cpct_etm_drawTilemap4x8_ag( cpctm_screenPtr((u8*) CPCT_LVMEM_START, GAME_AREA_LEFT, GAME_AREA_TOP), map );
   45C3 21 0A 6B      [10]  397 	ld	hl, #_map
   45C6 E5            [11]  398 	push	hl
   45C7 21 A0 80      [10]  399 	ld	hl, #0x80a0
   45CA E5            [11]  400 	push	hl
   45CB CD 98 67      [17]  401 	call	_cpct_etm_drawTilemap4x8_ag
   45CE C9            [10]  402 	ret
                            403 ;src/game.c:111: void collisions() {
                            404 ;	---------------------------------
                            405 ; Function collisions
                            406 ; ---------------------------------
   45CF                     407 _collisions::
                            408 ;src/game.c:112: }
   45CF C9            [10]  409 	ret
                            410 ;src/game.c:117: void init_game() {
                            411 ;	---------------------------------
                            412 ; Function init_game
                            413 ; ---------------------------------
   45D0                     414 _init_game::
                            415 ;src/game.c:120: sprites[0].id = 1;												//mark the sprite "alive" (non-zero)
   45D0 21 19 6A      [10]  416 	ld	hl, #_sprites
   45D3 36 01         [10]  417 	ld	(hl), #0x01
                            418 ;src/game.c:121: sprites[0].x = GAME_AREA_LEFT;									//init position to 0,0
   45D5 21 1A 6A      [10]  419 	ld	hl, #(_sprites + 0x0001)
   45D8 36 00         [10]  420 	ld	(hl), #0x00
                            421 ;src/game.c:122: sprites[0].y = GAME_AREA_TOP;
   45DA 21 1B 6A      [10]  422 	ld	hl, #(_sprites + 0x0002)
   45DD 36 10         [10]  423 	ld	(hl), #0x10
                            424 ;src/game.c:123: sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
   45DF 21 1D 6A      [10]  425 	ld	hl, #(_sprites + 0x0004)
   45E2 36 00         [10]  426 	ld	(hl), #0x00
   45E4 21 1C 6A      [10]  427 	ld	hl, #(_sprites + 0x0003)
   45E7 36 00         [10]  428 	ld	(hl), #0x00
                            429 ;src/game.c:125: sprites[0].x_prev_A = sprites[0].x_prev_B = GAME_AREA_LEFT;		//init prev position to 0,0
   45E9 21 20 6A      [10]  430 	ld	hl, #(_sprites + 0x0007)
   45EC 36 00         [10]  431 	ld	(hl), #0x00
   45EE 21 1E 6A      [10]  432 	ld	hl, #(_sprites + 0x0005)
   45F1 36 00         [10]  433 	ld	(hl), #0x00
                            434 ;src/game.c:126: sprites[0].y_prev_A = sprites[0].y_prev_B = GAME_AREA_TOP;
   45F3 21 21 6A      [10]  435 	ld	hl, #(_sprites + 0x0008)
   45F6 36 10         [10]  436 	ld	(hl), #0x10
   45F8 21 1F 6A      [10]  437 	ld	hl, #(_sprites + 0x0006)
   45FB 36 10         [10]  438 	ld	(hl), #0x10
                            439 ;src/game.c:127: sprites[0].height = G_PITU_H;
   45FD 21 22 6A      [10]  440 	ld	hl, #(_sprites + 0x0009)
   4600 36 20         [10]  441 	ld	(hl), #0x20
                            442 ;src/game.c:128: sprites[0].width = G_PITU_W;									//!?! /2: - M0, length in bytes = /2 in px
   4602 21 23 6A      [10]  443 	ld	hl, #(_sprites + 0x000a)
   4605 36 07         [10]  444 	ld	(hl), #0x07
                            445 ;src/game.c:129: sprites[0].properties = 0;										//bitmasked properties - init to 0
   4607 01 24 6A      [10]  446 	ld	bc, #_sprites + 11
   460A AF            [ 4]  447 	xor	a, a
   460B 02            [ 7]  448 	ld	(bc), a
                            449 ;src/game.c:130: sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render" on screen
   460C 0A            [ 7]  450 	ld	a, (bc)
   460D CB C7         [ 8]  451 	set	0, a
   460F 02            [ 7]  452 	ld	(bc), a
                            453 ;src/game.c:131: sprites[0].frames = 2;											//main sprite has two "moves" to animate
   4610 21 27 6A      [10]  454 	ld	hl, #(_sprites + 0x000e)
   4613 36 02         [10]  455 	ld	(hl), #0x02
                            456 ;src/game.c:132: sprites[0].sprite_f1 = (u8*)G_pitu; 							//first render for sprite. &G_pitu[0]
   4615 21 C6 46      [10]  457 	ld	hl, #_G_pitu
   4618 22 28 6A      [16]  458 	ld	((_sprites + 0x000f)), hl
                            459 ;src/game.c:133: sprites[0].sprite_f2 = (u8*)G_pitu_walk;
   461B 21 46 4A      [10]  460 	ld	hl, #_G_pitu_walk
   461E 22 2A 6A      [16]  461 	ld	((_sprites + 0x0011)), hl
                            462 ;src/game.c:134: sprites[0].sprite_f3 = (u8*)G_pitu_jump;
   4621 21 C6 4D      [10]  463 	ld	hl, #_G_pitu_jump
   4624 22 2C 6A      [16]  464 	ld	((_sprites + 0x0013)), hl
                            465 ;src/game.c:135: sprites[0].sprite_f3 = (u8*)G_blast;
   4627 21 46 58      [10]  466 	ld	hl, #_G_blast
   462A 22 2C 6A      [16]  467 	ld	((_sprites + 0x0013)), hl
                            468 ;src/game.c:136: sprites[0].turned = 0;											//start looking right/front
   462D 21 30 6A      [10]  469 	ld	hl, #(_sprites + 0x0017)
   4630 36 00         [10]  470 	ld	(hl), #0x00
                            471 ;src/game.c:139: for (i = 1; i < MAX_SPRITES; i++)
   4632 0E 01         [ 7]  472 	ld	c, #0x01
   4634                     473 00102$:
                            474 ;src/game.c:140: sprites[i].id=0;
   4634 06 00         [ 7]  475 	ld	b,#0x00
   4636 69            [ 4]  476 	ld	l, c
   4637 60            [ 4]  477 	ld	h, b
   4638 29            [11]  478 	add	hl, hl
   4639 09            [11]  479 	add	hl, bc
   463A 29            [11]  480 	add	hl, hl
   463B 29            [11]  481 	add	hl, hl
   463C 29            [11]  482 	add	hl, hl
   463D 11 19 6A      [10]  483 	ld	de, #_sprites
   4640 19            [11]  484 	add	hl, de
   4641 36 00         [10]  485 	ld	(hl), #0x00
                            486 ;src/game.c:139: for (i = 1; i < MAX_SPRITES; i++)
   4643 0C            [ 4]  487 	inc	c
   4644 79            [ 4]  488 	ld	a, c
   4645 D6 0A         [ 7]  489 	sub	a, #0x0a
   4647 38 EB         [12]  490 	jr	C,00102$
                            491 ;src/game.c:142: anim_clock=1;
   4649 21 09 6B      [10]  492 	ld	hl,#_anim_clock + 0
   464C 36 01         [10]  493 	ld	(hl), #0x01
   464E C9            [10]  494 	ret
                            495 ;src/game.c:148: void game(){
                            496 ;	---------------------------------
                            497 ; Function game
                            498 ; ---------------------------------
   464F                     499 _game::
                            500 ;src/game.c:150: cpct_setBorder(HW_WHITE);
   464F 21 10 00      [10]  501 	ld	hl, #0x0010
   4652 E5            [11]  502 	push	hl
   4653 CD 49 66      [17]  503 	call	_cpct_setPALColour
                            504 ;src/game.c:152: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
   4656 21 05 05      [10]  505 	ld	hl, #0x0505
   4659 E5            [11]  506 	push	hl
   465A CD B4 68      [17]  507 	call	_cpct_px2byteM0
   465D 45            [ 4]  508 	ld	b, l
   465E 21 00 80      [10]  509 	ld	hl, #0x8000
   4661 E5            [11]  510 	push	hl
   4662 C5            [11]  511 	push	bc
   4663 33            [ 6]  512 	inc	sp
   4664 2E 00         [ 7]  513 	ld	l, #0x00
   4666 E5            [11]  514 	push	hl
   4667 CD D8 68      [17]  515 	call	_cpct_memset
                            516 ;src/game.c:153: init_level();								//render first level background
   466A CD 9B 45      [17]  517 	call	_init_level
                            518 ;src/game.c:155: while (1) {
   466D                     519 00107$:
                            520 ;src/game.c:158: if (!swap_memvideo) { 					//switch
   466D 3A D9 6C      [13]  521 	ld	a,(#_swap_memvideo + 0)
   4670 B7            [ 4]  522 	or	a, a
   4671 20 0D         [12]  523 	jr	NZ,00102$
                            524 ;src/game.c:159: mem_start = (u8*) CPCT_LVMEM_START;	//lower VMEM page
   4673 21 00 80      [10]  525 	ld	hl, #0x8000
   4676 22 D6 6C      [16]  526 	ld	(_mem_start), hl
                            527 ;src/game.c:160: mem_page = cpct_page80;				//FIXME:: can probably delete??
   4679 21 D8 6C      [10]  528 	ld	hl,#_mem_page + 0
   467C 36 20         [10]  529 	ld	(hl), #0x20
   467E 18 0B         [12]  530 	jr	00103$
   4680                     531 00102$:
                            532 ;src/game.c:162: mem_start = (u8*) CPCT_VMEM_START;	//upper,regular VMEM page
   4680 21 00 C0      [10]  533 	ld	hl, #0xc000
   4683 22 D6 6C      [16]  534 	ld	(_mem_start), hl
                            535 ;src/game.c:163: mem_page = cpct_pageC0;
   4686 21 D8 6C      [10]  536 	ld	hl,#_mem_page + 0
   4689 36 30         [10]  537 	ld	(hl), #0x30
   468B                     538 00103$:
                            539 ;src/game.c:167: keyboard(); 							//user movement
   468B CD CC 43      [17]  540 	call	_keyboard
                            541 ;src/game.c:169: moveSprites();
   468E CD 8D 44      [17]  542 	call	_moveSprites
                            543 ;src/game.c:170: deleteSprites();
   4691 CD CF 64      [17]  544 	call	_deleteSprites
                            545 ;src/game.c:171: renderSprites();
   4694 CD 45 63      [17]  546 	call	_renderSprites
                            547 ;src/game.c:174: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
   4697 CD AC 68      [17]  548 	call	_cpct_waitVSYNC
                            549 ;src/game.c:175: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
   469A FD 21 D8 6C   [14]  550 	ld	iy, #_mem_page
   469E FD 6E 00      [19]  551 	ld	l, 0 (iy)
   46A1 CD 47 68      [17]  552 	call	_cpct_setVideoMemoryPage
                            553 ;src/game.c:176: swap_memvideo = ~swap_memvideo; 		//flip the switch
   46A4 FD 21 D9 6C   [14]  554 	ld	iy, #_swap_memvideo
   46A8 FD 7E 00      [19]  555 	ld	a, 0 (iy)
   46AB 2F            [ 4]  556 	cpl
   46AC FD 77 00      [19]  557 	ld	0 (iy), a
                            558 ;src/game.c:178: anim_clock+=ANIM_SPEED;
   46AF FD 21 09 6B   [14]  559 	ld	iy, #_anim_clock
   46B3 FD 34 00      [23]  560 	inc	0 (iy)
   46B6 FD 34 00      [23]  561 	inc	0 (iy)
                            562 ;src/game.c:179: if (anim_clock > ANIM_CYCLE)
   46B9 3E 10         [ 7]  563 	ld	a, #0x10
   46BB FD 96 00      [19]  564 	sub	a, 0 (iy)
   46BE 30 AD         [12]  565 	jr	NC,00107$
                            566 ;src/game.c:180: anim_clock=1;
   46C0 FD 36 00 01   [19]  567 	ld	0 (iy), #0x01
   46C4 18 A7         [12]  568 	jr	00107$
                            569 	.area _CODE
                            570 	.area _INITIALIZER
                            571 	.area _CABS (ABS)
