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
                             30 ;--------------------------------------------------------
                             31 ; special function registers
                             32 ;--------------------------------------------------------
                             33 ;--------------------------------------------------------
                             34 ; ram data
                             35 ;--------------------------------------------------------
                             36 	.area _DATA
                             37 ;--------------------------------------------------------
                             38 ; ram data
                             39 ;--------------------------------------------------------
                             40 	.area _INITIALIZED
                             41 ;--------------------------------------------------------
                             42 ; absolute external ram data
                             43 ;--------------------------------------------------------
                             44 	.area _DABS (ABS)
                             45 ;--------------------------------------------------------
                             46 ; global & static initialisations
                             47 ;--------------------------------------------------------
                             48 	.area _HOME
                             49 	.area _GSINIT
                             50 	.area _GSFINAL
                             51 	.area _GSINIT
                             52 ;--------------------------------------------------------
                             53 ; Home
                             54 ;--------------------------------------------------------
                             55 	.area _HOME
                             56 	.area _HOME
                             57 ;--------------------------------------------------------
                             58 ; code
                             59 ;--------------------------------------------------------
                             60 	.area _CODE
                             61 ;src/game.c:14: void keyboard(){
                             62 ;	---------------------------------
                             63 ; Function keyboard
                             64 ; ---------------------------------
   43CC                      65 _keyboard::
                             66 ;src/game.c:17: sprites[0].moveV = sprites[0].moveH = 0; 							//start with no movement
   43CC 21 7E 6B      [10]   67 	ld	hl, #(_sprites + 0x0004)
   43CF 36 00         [10]   68 	ld	(hl), #0x00
   43D1 21 7D 6B      [10]   69 	ld	hl, #(_sprites + 0x0003)
   43D4 36 00         [10]   70 	ld	(hl), #0x00
                             71 ;src/game.c:20: cpct_scanKeyboard_f();
   43D6 CD 17 66      [17]   72 	call	_cpct_scanKeyboard_f
                             73 ;src/game.c:21: if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
   43D9 21 00 01      [10]   74 	ld	hl, #0x0100
   43DC CD 0B 66      [17]   75 	call	_cpct_isKeyPressed
   43DF 7D            [ 4]   76 	ld	a, l
   43E0 B7            [ 4]   77 	or	a, a
   43E1 20 14         [12]   78 	jr	NZ,00101$
   43E3 21 08 08      [10]   79 	ld	hl, #0x0808
   43E6 CD 0B 66      [17]   80 	call	_cpct_isKeyPressed
   43E9 7D            [ 4]   81 	ld	a, l
   43EA B7            [ 4]   82 	or	a, a
   43EB 20 0A         [12]   83 	jr	NZ,00101$
   43ED 21 09 01      [10]   84 	ld	hl, #0x0109
   43F0 CD 0B 66      [17]   85 	call	_cpct_isKeyPressed
   43F3 7D            [ 4]   86 	ld	a, l
   43F4 B7            [ 4]   87 	or	a, a
   43F5 28 05         [12]   88 	jr	Z,00102$
   43F7                      89 00101$:
                             90 ;src/game.c:22: sprites[0].moveV = -1;		
   43F7 21 7D 6B      [10]   91 	ld	hl, #(_sprites + 0x0003)
   43FA 36 FF         [10]   92 	ld	(hl), #0xff
   43FC                      93 00102$:
                             94 ;src/game.c:24: if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
   43FC 21 00 04      [10]   95 	ld	hl, #0x0400
   43FF CD 0B 66      [17]   96 	call	_cpct_isKeyPressed
   4402 7D            [ 4]   97 	ld	a, l
   4403 B7            [ 4]   98 	or	a, a
   4404 20 14         [12]   99 	jr	NZ,00105$
   4406 21 08 20      [10]  100 	ld	hl, #0x2008
   4409 CD 0B 66      [17]  101 	call	_cpct_isKeyPressed
   440C 7D            [ 4]  102 	ld	a, l
   440D B7            [ 4]  103 	or	a, a
   440E 20 0A         [12]  104 	jr	NZ,00105$
   4410 21 09 02      [10]  105 	ld	hl, #0x0209
   4413 CD 0B 66      [17]  106 	call	_cpct_isKeyPressed
   4416 7D            [ 4]  107 	ld	a, l
   4417 B7            [ 4]  108 	or	a, a
   4418 28 05         [12]  109 	jr	Z,00106$
   441A                     110 00105$:
                            111 ;src/game.c:25: sprites[0].moveV = 1;
   441A 21 7D 6B      [10]  112 	ld	hl, #(_sprites + 0x0003)
   441D 36 01         [10]  113 	ld	(hl), #0x01
   441F                     114 00106$:
                            115 ;src/game.c:27: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   441F 21 01 01      [10]  116 	ld	hl, #0x0101
   4422 CD 0B 66      [17]  117 	call	_cpct_isKeyPressed
                            118 ;src/game.c:29: sprites[0].turned = 1;
                            119 ;src/game.c:27: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   4425 7D            [ 4]  120 	ld	a, l
   4426 B7            [ 4]  121 	or	a, a
   4427 20 14         [12]  122 	jr	NZ,00109$
   4429 21 04 04      [10]  123 	ld	hl, #0x0404
   442C CD 0B 66      [17]  124 	call	_cpct_isKeyPressed
   442F 7D            [ 4]  125 	ld	a, l
   4430 B7            [ 4]  126 	or	a, a
   4431 20 0A         [12]  127 	jr	NZ,00109$
   4433 21 09 04      [10]  128 	ld	hl, #0x0409
   4436 CD 0B 66      [17]  129 	call	_cpct_isKeyPressed
   4439 7D            [ 4]  130 	ld	a, l
   443A B7            [ 4]  131 	or	a, a
   443B 28 0A         [12]  132 	jr	Z,00110$
   443D                     133 00109$:
                            134 ;src/game.c:28: sprites[0].moveH = -1;
   443D 21 7E 6B      [10]  135 	ld	hl, #(_sprites + 0x0004)
   4440 36 FF         [10]  136 	ld	(hl), #0xff
                            137 ;src/game.c:29: sprites[0].turned = 1;
   4442 21 91 6B      [10]  138 	ld	hl, #(_sprites + 0x0017)
   4445 36 01         [10]  139 	ld	(hl), #0x01
   4447                     140 00110$:
                            141 ;src/game.c:31: if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
   4447 21 00 02      [10]  142 	ld	hl, #0x0200
   444A CD 0B 66      [17]  143 	call	_cpct_isKeyPressed
   444D 7D            [ 4]  144 	ld	a, l
   444E B7            [ 4]  145 	or	a, a
   444F 20 14         [12]  146 	jr	NZ,00113$
   4451 21 03 08      [10]  147 	ld	hl, #0x0803
   4454 CD 0B 66      [17]  148 	call	_cpct_isKeyPressed
   4457 7D            [ 4]  149 	ld	a, l
   4458 B7            [ 4]  150 	or	a, a
   4459 20 0A         [12]  151 	jr	NZ,00113$
   445B 21 09 08      [10]  152 	ld	hl, #0x0809
   445E CD 0B 66      [17]  153 	call	_cpct_isKeyPressed
   4461 7D            [ 4]  154 	ld	a, l
   4462 B7            [ 4]  155 	or	a, a
   4463 28 0A         [12]  156 	jr	Z,00114$
   4465                     157 00113$:
                            158 ;src/game.c:32: sprites[0].moveH = 1;
   4465 21 7E 6B      [10]  159 	ld	hl, #(_sprites + 0x0004)
   4468 36 01         [10]  160 	ld	(hl), #0x01
                            161 ;src/game.c:33: sprites[0].turned = 0;
   446A 21 91 6B      [10]  162 	ld	hl, #(_sprites + 0x0017)
   446D 36 00         [10]  163 	ld	(hl), #0x00
   446F                     164 00114$:
                            165 ;src/game.c:37: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
   446F 21 7E 6B      [10]  166 	ld	hl, #(_sprites + 0x0004) + 0
   4472 4E            [ 7]  167 	ld	c, (hl)
                            168 ;src/game.c:38: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
   4473 11 85 6B      [10]  169 	ld	de, #_sprites + 11
   4476 1A            [ 7]  170 	ld	a, (de)
   4477 47            [ 4]  171 	ld	b, a
                            172 ;src/game.c:37: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
   4478 79            [ 4]  173 	ld	a, c
   4479 B7            [ 4]  174 	or	a, a
   447A 20 06         [12]  175 	jr	NZ,00117$
   447C 3A 7D 6B      [13]  176 	ld	a, (#(_sprites + 0x0003) + 0)
   447F B7            [ 4]  177 	or	a, a
   4480 28 05         [12]  178 	jr	Z,00118$
   4482                     179 00117$:
                            180 ;src/game.c:38: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
   4482 78            [ 4]  181 	ld	a, b
   4483 CB CF         [ 8]  182 	set	1, a
   4485 12            [ 7]  183 	ld	(de), a
   4486 C9            [10]  184 	ret
   4487                     185 00118$:
                            186 ;src/game.c:40: sprites[0].properties = sprites[0].properties & ~MASK_ANIMATE;	//unmark for animation;
   4487 CB 88         [ 8]  187 	res	1, b
   4489 78            [ 4]  188 	ld	a, b
   448A 12            [ 7]  189 	ld	(de), a
   448B C9            [10]  190 	ret
                            191 ;src/game.c:45: void AI(){
                            192 ;	---------------------------------
                            193 ; Function AI
                            194 ; ---------------------------------
   448C                     195 _AI::
                            196 ;src/game.c:46: }
   448C C9            [10]  197 	ret
                            198 ;src/game.c:50: void moveSprites() {
                            199 ;	---------------------------------
                            200 ; Function moveSprites
                            201 ; ---------------------------------
   448D                     202 _moveSprites::
   448D DD E5         [15]  203 	push	ix
   448F DD 21 00 00   [14]  204 	ld	ix,#0
   4493 DD 39         [15]  205 	add	ix,sp
   4495 21 F6 FF      [10]  206 	ld	hl, #-10
   4498 39            [11]  207 	add	hl, sp
   4499 F9            [ 6]  208 	ld	sp, hl
                            209 ;src/game.c:54: for (i=0; i < MAX_SPRITES; i++) {
   449A DD 36 F8 00   [19]  210 	ld	-8 (ix), #0x00
   449E                     211 00116$:
                            212 ;src/game.c:55: if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
   449E DD 4E F8      [19]  213 	ld	c,-8 (ix)
   44A1 06 00         [ 7]  214 	ld	b,#0x00
   44A3 69            [ 4]  215 	ld	l, c
   44A4 60            [ 4]  216 	ld	h, b
   44A5 29            [11]  217 	add	hl, hl
   44A6 09            [11]  218 	add	hl, bc
   44A7 29            [11]  219 	add	hl, hl
   44A8 29            [11]  220 	add	hl, hl
   44A9 29            [11]  221 	add	hl, hl
   44AA 01 7A 6B      [10]  222 	ld	bc,#_sprites
   44AD 09            [11]  223 	add	hl,bc
   44AE DD 75 F9      [19]  224 	ld	-7 (ix), l
   44B1 DD 74 FA      [19]  225 	ld	-6 (ix), h
   44B4 7E            [ 7]  226 	ld	a, (hl)
   44B5 DD 77 FD      [19]  227 	ld	-3 (ix), a
   44B8 B7            [ 4]  228 	or	a, a
   44B9 CA 8B 45      [10]  229 	jp	Z, 00117$
                            230 ;src/game.c:56: collision = 0;
   44BC DD 36 F6 00   [19]  231 	ld	-10 (ix), #0x00
                            232 ;src/game.c:58: x = sprites[i].x;
   44C0 DD 7E F9      [19]  233 	ld	a, -7 (ix)
   44C3 C6 01         [ 7]  234 	add	a, #0x01
   44C5 DD 77 FE      [19]  235 	ld	-2 (ix), a
   44C8 DD 7E FA      [19]  236 	ld	a, -6 (ix)
   44CB CE 00         [ 7]  237 	adc	a, #0x00
   44CD DD 77 FF      [19]  238 	ld	-1 (ix), a
   44D0 DD 6E FE      [19]  239 	ld	l,-2 (ix)
   44D3 DD 66 FF      [19]  240 	ld	h,-1 (ix)
   44D6 4E            [ 7]  241 	ld	c, (hl)
                            242 ;src/game.c:59: y = sprites[i].y;
   44D7 DD 7E F9      [19]  243 	ld	a, -7 (ix)
   44DA C6 02         [ 7]  244 	add	a, #0x02
   44DC DD 77 FB      [19]  245 	ld	-5 (ix), a
   44DF DD 7E FA      [19]  246 	ld	a, -6 (ix)
   44E2 CE 00         [ 7]  247 	adc	a, #0x00
   44E4 DD 77 FC      [19]  248 	ld	-4 (ix), a
   44E7 DD 6E FB      [19]  249 	ld	l,-5 (ix)
   44EA DD 66 FC      [19]  250 	ld	h,-4 (ix)
   44ED 46            [ 7]  251 	ld	b, (hl)
                            252 ;src/game.c:61: x = x + (sprites[i].moveH);
   44EE DD 6E F9      [19]  253 	ld	l,-7 (ix)
   44F1 DD 66 FA      [19]  254 	ld	h,-6 (ix)
   44F4 11 04 00      [10]  255 	ld	de, #0x0004
   44F7 19            [11]  256 	add	hl, de
   44F8 6E            [ 7]  257 	ld	l, (hl)
   44F9 09            [11]  258 	add	hl, bc
   44FA 4D            [ 4]  259 	ld	c, l
                            260 ;src/game.c:62: y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
   44FB DD 6E F9      [19]  261 	ld	l,-7 (ix)
   44FE DD 66 FA      [19]  262 	ld	h,-6 (ix)
   4501 23            [ 6]  263 	inc	hl
   4502 23            [ 6]  264 	inc	hl
   4503 23            [ 6]  265 	inc	hl
   4504 7E            [ 7]  266 	ld	a, (hl)
   4505 87            [ 4]  267 	add	a, a
   4506 87            [ 4]  268 	add	a, a
   4507 5F            [ 4]  269 	ld	e, a
   4508 68            [ 4]  270 	ld	l, b
   4509 19            [11]  271 	add	hl, de
   450A DD 75 F7      [19]  272 	ld	-9 (ix), l
                            273 ;src/game.c:65: if (x > (GAME_AREA_RIGHT - sprites[i].width))
   450D DD 6E F9      [19]  274 	ld	l,-7 (ix)
   4510 DD 66 FA      [19]  275 	ld	h,-6 (ix)
   4513 11 0A 00      [10]  276 	ld	de, #0x000a
   4516 19            [11]  277 	add	hl, de
   4517 5E            [ 7]  278 	ld	e, (hl)
   4518 16 00         [ 7]  279 	ld	d, #0x00
   451A 3E 50         [ 7]  280 	ld	a, #0x50
   451C 93            [ 4]  281 	sub	a, e
   451D 47            [ 4]  282 	ld	b, a
   451E 3E 00         [ 7]  283 	ld	a, #0x00
   4520 9A            [ 4]  284 	sbc	a, d
   4521 5F            [ 4]  285 	ld	e, a
   4522 69            [ 4]  286 	ld	l, c
   4523 16 00         [ 7]  287 	ld	d, #0x00
   4525 78            [ 4]  288 	ld	a, b
   4526 95            [ 4]  289 	sub	a, l
   4527 7B            [ 4]  290 	ld	a, e
   4528 9A            [ 4]  291 	sbc	a, d
   4529 E2 2E 45      [10]  292 	jp	PO, 00149$
   452C EE 80         [ 7]  293 	xor	a, #0x80
   452E                     294 00149$:
   452E F2 35 45      [10]  295 	jp	P, 00104$
                            296 ;src/game.c:66: collision = collision | RIGHT_COLLISION;
   4531 DD 36 F6 02   [19]  297 	ld	-10 (ix), #0x02
                            298 ;src/game.c:68: collision = collision | LEFT_COLLISION;
   4535                     299 00104$:
                            300 ;src/game.c:70: if (y > (GAME_AREA_BOTTOM - sprites[i].height))
   4535 DD 6E F9      [19]  301 	ld	l,-7 (ix)
   4538 DD 66 FA      [19]  302 	ld	h,-6 (ix)
   453B 11 09 00      [10]  303 	ld	de, #0x0009
   453E 19            [11]  304 	add	hl, de
   453F 5E            [ 7]  305 	ld	e, (hl)
   4540 16 00         [ 7]  306 	ld	d, #0x00
   4542 3E C8         [ 7]  307 	ld	a, #0xc8
   4544 93            [ 4]  308 	sub	a, e
   4545 5F            [ 4]  309 	ld	e, a
   4546 3E 00         [ 7]  310 	ld	a, #0x00
   4548 9A            [ 4]  311 	sbc	a, d
   4549 57            [ 4]  312 	ld	d, a
   454A DD 6E F7      [19]  313 	ld	l, -9 (ix)
   454D 26 00         [ 7]  314 	ld	h, #0x00
   454F 7B            [ 4]  315 	ld	a, e
   4550 95            [ 4]  316 	sub	a, l
   4551 7A            [ 4]  317 	ld	a, d
   4552 9C            [ 4]  318 	sbc	a, h
   4553 E2 58 45      [10]  319 	jp	PO, 00150$
   4556 EE 80         [ 7]  320 	xor	a, #0x80
   4558                     321 00150$:
   4558 F2 5F 45      [10]  322 	jp	P, 00106$
                            323 ;src/game.c:71: collision = collision | BOTTOM_COLLISION;
   455B DD CB F6 C6   [23]  324 	set	0, -10 (ix)
   455F                     325 00106$:
                            326 ;src/game.c:72: if (y < GAME_AREA_TOP)
   455F DD 7E F7      [19]  327 	ld	a, -9 (ix)
   4562 D6 10         [ 7]  328 	sub	a, #0x10
   4564 30 08         [12]  329 	jr	NC,00108$
                            330 ;src/game.c:73: collision = collision | TOP_COLLISION;
   4566 DD 7E F6      [19]  331 	ld	a, -10 (ix)
   4569 F6 05         [ 7]  332 	or	a, #0x05
   456B DD 77 F6      [19]  333 	ld	-10 (ix), a
   456E                     334 00108$:
                            335 ;src/game.c:77: if ((collision & LEFT_RIGHT_COLLISION) == 0)		//if not hitting right, move up/down
   456E DD CB F6 4E   [20]  336 	bit	1, -10 (ix)
   4572 20 07         [12]  337 	jr	NZ,00110$
                            338 ;src/game.c:78: sprites[i].x = x;								//keep x as it was
   4574 DD 6E FE      [19]  339 	ld	l,-2 (ix)
   4577 DD 66 FF      [19]  340 	ld	h,-1 (ix)
   457A 71            [ 7]  341 	ld	(hl), c
   457B                     342 00110$:
                            343 ;src/game.c:80: if ((collision & TOP_BOTTOM_COLLISION) == 0)		//if not hitting top, move sideways //
   457B DD CB F6 46   [20]  344 	bit	0, -10 (ix)
   457F 20 0A         [12]  345 	jr	NZ,00117$
                            346 ;src/game.c:81: sprites[i].y = y;								//keep y as it was
   4581 DD 6E FB      [19]  347 	ld	l,-5 (ix)
   4584 DD 66 FC      [19]  348 	ld	h,-4 (ix)
   4587 DD 7E F7      [19]  349 	ld	a, -9 (ix)
   458A 77            [ 7]  350 	ld	(hl), a
   458B                     351 00117$:
                            352 ;src/game.c:54: for (i=0; i < MAX_SPRITES; i++) {
   458B DD 34 F8      [23]  353 	inc	-8 (ix)
   458E DD 7E F8      [19]  354 	ld	a, -8 (ix)
   4591 D6 0A         [ 7]  355 	sub	a, #0x0a
   4593 DA 9E 44      [10]  356 	jp	C, 00116$
   4596 DD F9         [10]  357 	ld	sp, ix
   4598 DD E1         [14]  358 	pop	ix
   459A C9            [10]  359 	ret
                            360 ;src/game.c:89: void init_level() {
                            361 ;	---------------------------------
                            362 ; Function init_level
                            363 ; ---------------------------------
   459B                     364 _init_level::
                            365 ;src/game.c:95: cpct_memcpy((u8*)map, (u8*)g_map, g_map_W*g_map_H);
   459B 21 CC 01      [10]  366 	ld	hl, #0x01cc
   459E E5            [11]  367 	push	hl
   459F 21 00 40      [10]  368 	ld	hl, #_g_map
   45A2 E5            [11]  369 	push	hl
   45A3 21 AE 69      [10]  370 	ld	hl, #_map
   45A6 E5            [11]  371 	push	hl
   45A7 CD 08 69      [17]  372 	call	_cpct_memcpy
                            373 ;src/game.c:97: cpct_etm_setDrawTilemap4x8_ag( g_map_W, g_map_H, g_map_W, g_tileset_00); //3rd param (20,G_map_W) is how many tiles per line
   45AA 21 CC 41      [10]  374 	ld	hl, #_g_tileset_00
   45AD E5            [11]  375 	push	hl
   45AE 21 14 00      [10]  376 	ld	hl, #0x0014
   45B1 E5            [11]  377 	push	hl
   45B2 26 17         [ 7]  378 	ld	h, #0x17
   45B4 E5            [11]  379 	push	hl
   45B5 CD 6A 69      [17]  380 	call	_cpct_etm_setDrawTilemap4x8_ag
                            381 ;src/game.c:99: cpct_etm_drawTilemap4x8_ag( cpctm_screenPtr((u8*) CPCT_VMEM_START, GAME_AREA_LEFT, GAME_AREA_TOP), map );
   45B8 21 AE 69      [10]  382 	ld	hl, #_map
   45BB E5            [11]  383 	push	hl
   45BC 21 A0 C0      [10]  384 	ld	hl, #0xc0a0
   45BF E5            [11]  385 	push	hl
   45C0 CD D0 67      [17]  386 	call	_cpct_etm_drawTilemap4x8_ag
                            387 ;src/game.c:100: cpct_etm_drawTilemap4x8_ag( cpctm_screenPtr((u8*) CPCT_LVMEM_START, GAME_AREA_LEFT, GAME_AREA_TOP), map );
   45C3 21 AE 69      [10]  388 	ld	hl, #_map
   45C6 E5            [11]  389 	push	hl
   45C7 21 A0 80      [10]  390 	ld	hl, #0x80a0
   45CA E5            [11]  391 	push	hl
   45CB CD D0 67      [17]  392 	call	_cpct_etm_drawTilemap4x8_ag
   45CE C9            [10]  393 	ret
                            394 ;src/game.c:106: void collisions() {
                            395 ;	---------------------------------
                            396 ; Function collisions
                            397 ; ---------------------------------
   45CF                     398 _collisions::
                            399 ;src/game.c:107: }
   45CF C9            [10]  400 	ret
                            401 ;src/game.c:112: void init_game() {
                            402 ;	---------------------------------
                            403 ; Function init_game
                            404 ; ---------------------------------
   45D0                     405 _init_game::
                            406 ;src/game.c:115: sprites[0].id = 1;												//mark the sprite "alive" (non-zero)
   45D0 21 7A 6B      [10]  407 	ld	hl, #_sprites
   45D3 36 01         [10]  408 	ld	(hl), #0x01
                            409 ;src/game.c:116: sprites[0].x = GAME_AREA_LEFT;									//init position to 0,0
   45D5 21 7B 6B      [10]  410 	ld	hl, #(_sprites + 0x0001)
   45D8 36 00         [10]  411 	ld	(hl), #0x00
                            412 ;src/game.c:117: sprites[0].y = GAME_AREA_TOP;
   45DA 21 7C 6B      [10]  413 	ld	hl, #(_sprites + 0x0002)
   45DD 36 10         [10]  414 	ld	(hl), #0x10
                            415 ;src/game.c:118: sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
   45DF 21 7E 6B      [10]  416 	ld	hl, #(_sprites + 0x0004)
   45E2 36 00         [10]  417 	ld	(hl), #0x00
   45E4 21 7D 6B      [10]  418 	ld	hl, #(_sprites + 0x0003)
   45E7 36 00         [10]  419 	ld	(hl), #0x00
                            420 ;src/game.c:120: sprites[0].x_prev_A = sprites[0].x_prev_B = GAME_AREA_LEFT;		//init prev position to 0,0
   45E9 21 81 6B      [10]  421 	ld	hl, #(_sprites + 0x0007)
   45EC 36 00         [10]  422 	ld	(hl), #0x00
   45EE 21 7F 6B      [10]  423 	ld	hl, #(_sprites + 0x0005)
   45F1 36 00         [10]  424 	ld	(hl), #0x00
                            425 ;src/game.c:121: sprites[0].y_prev_A = sprites[0].y_prev_B = GAME_AREA_TOP;
   45F3 21 82 6B      [10]  426 	ld	hl, #(_sprites + 0x0008)
   45F6 36 10         [10]  427 	ld	(hl), #0x10
   45F8 21 80 6B      [10]  428 	ld	hl, #(_sprites + 0x0006)
   45FB 36 10         [10]  429 	ld	(hl), #0x10
                            430 ;src/game.c:122: sprites[0].height = G_PITU_H;
   45FD 21 83 6B      [10]  431 	ld	hl, #(_sprites + 0x0009)
   4600 36 20         [10]  432 	ld	(hl), #0x20
                            433 ;src/game.c:123: sprites[0].width = G_PITU_W;									//!?! /2: - M0, length in bytes = /2 in px
   4602 21 84 6B      [10]  434 	ld	hl, #(_sprites + 0x000a)
   4605 36 07         [10]  435 	ld	(hl), #0x07
                            436 ;src/game.c:124: sprites[0].properties = 0;										//bitmasked properties - init to 0
   4607 01 85 6B      [10]  437 	ld	bc, #_sprites + 11
   460A AF            [ 4]  438 	xor	a, a
   460B 02            [ 7]  439 	ld	(bc), a
                            440 ;src/game.c:125: sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render" on screen
   460C 0A            [ 7]  441 	ld	a, (bc)
   460D CB C7         [ 8]  442 	set	0, a
   460F 02            [ 7]  443 	ld	(bc), a
                            444 ;src/game.c:126: sprites[0].frames = 2;											//main sprite has two "moves" to animate
   4610 21 88 6B      [10]  445 	ld	hl, #(_sprites + 0x000e)
   4613 36 02         [10]  446 	ld	(hl), #0x02
                            447 ;src/game.c:127: sprites[0].sprite_f1 = (u8*)g_pitu; 							//first render for sprite. &G_pitu[0]
   4615 21 C6 46      [10]  448 	ld	hl, #_g_pitu
   4618 22 89 6B      [16]  449 	ld	((_sprites + 0x000f)), hl
                            450 ;src/game.c:128: sprites[0].sprite_f2 = (u8*)g_pitu_walk;
   461B 21 46 4A      [10]  451 	ld	hl, #_g_pitu_walk
   461E 22 8B 6B      [16]  452 	ld	((_sprites + 0x0011)), hl
                            453 ;src/game.c:129: sprites[0].sprite_f3 = (u8*)g_pitu_jump;
   4621 21 C6 4D      [10]  454 	ld	hl, #_g_pitu_jump
   4624 22 8D 6B      [16]  455 	ld	((_sprites + 0x0013)), hl
                            456 ;src/game.c:130: sprites[0].sprite_f3 = (u8*)g_blast;
   4627 21 46 58      [10]  457 	ld	hl, #_g_blast
   462A 22 8D 6B      [16]  458 	ld	((_sprites + 0x0013)), hl
                            459 ;src/game.c:131: sprites[0].turned = 0;											//start looking right/front
   462D 21 91 6B      [10]  460 	ld	hl, #(_sprites + 0x0017)
   4630 36 00         [10]  461 	ld	(hl), #0x00
                            462 ;src/game.c:134: for (i = 1; i < MAX_SPRITES; i++)
   4632 0E 01         [ 7]  463 	ld	c, #0x01
   4634                     464 00102$:
                            465 ;src/game.c:135: sprites[i].id=0;
   4634 06 00         [ 7]  466 	ld	b,#0x00
   4636 69            [ 4]  467 	ld	l, c
   4637 60            [ 4]  468 	ld	h, b
   4638 29            [11]  469 	add	hl, hl
   4639 09            [11]  470 	add	hl, bc
   463A 29            [11]  471 	add	hl, hl
   463B 29            [11]  472 	add	hl, hl
   463C 29            [11]  473 	add	hl, hl
   463D 11 7A 6B      [10]  474 	ld	de, #_sprites
   4640 19            [11]  475 	add	hl, de
   4641 36 00         [10]  476 	ld	(hl), #0x00
                            477 ;src/game.c:134: for (i = 1; i < MAX_SPRITES; i++)
   4643 0C            [ 4]  478 	inc	c
   4644 79            [ 4]  479 	ld	a, c
   4645 D6 0A         [ 7]  480 	sub	a, #0x0a
   4647 38 EB         [12]  481 	jr	C,00102$
                            482 ;src/game.c:137: anim_clock=1;
   4649 21 6A 6C      [10]  483 	ld	hl,#_anim_clock + 0
   464C 36 01         [10]  484 	ld	(hl), #0x01
   464E C9            [10]  485 	ret
                            486 ;src/game.c:143: void game(){
                            487 ;	---------------------------------
                            488 ; Function game
                            489 ; ---------------------------------
   464F                     490 _game::
                            491 ;src/game.c:145: cpct_setBorder(HW_WHITE);
   464F 21 10 00      [10]  492 	ld	hl, #0x0010
   4652 E5            [11]  493 	push	hl
   4653 CD 81 66      [17]  494 	call	_cpct_setPALColour
                            495 ;src/game.c:147: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
   4656 21 05 05      [10]  496 	ld	hl, #0x0505
   4659 E5            [11]  497 	push	hl
   465A CD EC 68      [17]  498 	call	_cpct_px2byteM0
   465D 45            [ 4]  499 	ld	b, l
   465E 21 00 80      [10]  500 	ld	hl, #0x8000
   4661 E5            [11]  501 	push	hl
   4662 C5            [11]  502 	push	bc
   4663 33            [ 6]  503 	inc	sp
   4664 2E 00         [ 7]  504 	ld	l, #0x00
   4666 E5            [11]  505 	push	hl
   4667 CD 10 69      [17]  506 	call	_cpct_memset
                            507 ;src/game.c:148: init_level();								//render first level background
   466A CD 9B 45      [17]  508 	call	_init_level
                            509 ;src/game.c:150: while (1) {
   466D                     510 00107$:
                            511 ;src/game.c:153: if (!swap_memvideo) { 					//switch
   466D 3A AD 69      [13]  512 	ld	a,(#_swap_memvideo + 0)
   4670 B7            [ 4]  513 	or	a, a
   4671 20 0D         [12]  514 	jr	NZ,00102$
                            515 ;src/game.c:154: mem_start = (u8*) CPCT_LVMEM_START;	//lower VMEM page
   4673 21 00 80      [10]  516 	ld	hl, #0x8000
   4676 22 AA 69      [16]  517 	ld	(_mem_start), hl
                            518 ;src/game.c:155: mem_page = cpct_page80;				//FIXME:: can probably delete??
   4679 21 AC 69      [10]  519 	ld	hl,#_mem_page + 0
   467C 36 20         [10]  520 	ld	(hl), #0x20
   467E 18 0B         [12]  521 	jr	00103$
   4680                     522 00102$:
                            523 ;src/game.c:157: mem_start = (u8*) CPCT_VMEM_START;	//upper,regular VMEM page
   4680 21 00 C0      [10]  524 	ld	hl, #0xc000
   4683 22 AA 69      [16]  525 	ld	(_mem_start), hl
                            526 ;src/game.c:158: mem_page = cpct_pageC0;
   4686 21 AC 69      [10]  527 	ld	hl,#_mem_page + 0
   4689 36 30         [10]  528 	ld	(hl), #0x30
   468B                     529 00103$:
                            530 ;src/game.c:162: keyboard(); 							//user movement
   468B CD CC 43      [17]  531 	call	_keyboard
                            532 ;src/game.c:164: moveSprites();
   468E CD 8D 44      [17]  533 	call	_moveSprites
                            534 ;src/game.c:165: deleteSprites();
   4691 CD 7C 65      [17]  535 	call	_deleteSprites
                            536 ;src/game.c:166: renderSprites();
   4694 CD F2 63      [17]  537 	call	_renderSprites
                            538 ;src/game.c:169: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
   4697 CD E4 68      [17]  539 	call	_cpct_waitVSYNC
                            540 ;src/game.c:170: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
   469A FD 21 AC 69   [14]  541 	ld	iy, #_mem_page
   469E FD 6E 00      [19]  542 	ld	l, 0 (iy)
   46A1 CD 7F 68      [17]  543 	call	_cpct_setVideoMemoryPage
                            544 ;src/game.c:171: swap_memvideo = ~swap_memvideo; 		//flip the switch
   46A4 FD 21 AD 69   [14]  545 	ld	iy, #_swap_memvideo
   46A8 FD 7E 00      [19]  546 	ld	a, 0 (iy)
   46AB 2F            [ 4]  547 	cpl
   46AC FD 77 00      [19]  548 	ld	0 (iy), a
                            549 ;src/game.c:173: anim_clock+=ANIM_SPEED;
   46AF FD 21 6A 6C   [14]  550 	ld	iy, #_anim_clock
   46B3 FD 34 00      [23]  551 	inc	0 (iy)
   46B6 FD 34 00      [23]  552 	inc	0 (iy)
                            553 ;src/game.c:174: if (anim_clock > ANIM_CYCLE)
   46B9 3E 10         [ 7]  554 	ld	a, #0x10
   46BB FD 96 00      [19]  555 	sub	a, 0 (iy)
   46BE 30 AD         [12]  556 	jr	NC,00107$
                            557 ;src/game.c:175: anim_clock=1;
   46C0 FD 36 00 01   [19]  558 	ld	0 (iy), #0x01
   46C4 18 A7         [12]  559 	jr	00107$
                            560 	.area _CODE
                            561 	.area _INITIALIZER
                            562 	.area _CABS (ABS)
