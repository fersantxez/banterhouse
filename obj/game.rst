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
                             13 	.globl _moveSprites
                             14 	.globl _AI
                             15 	.globl _keyboard
                             16 	.globl _deleteSprites
                             17 	.globl _renderSprites
                             18 	.globl _cpct_setVideoMemoryPage
                             19 	.globl _cpct_setPALColour
                             20 	.globl _cpct_waitVSYNC
                             21 	.globl _cpct_px2byteM0
                             22 	.globl _cpct_isKeyPressed
                             23 	.globl _cpct_scanKeyboard_f
                             24 	.globl _cpct_memset
                             25 	.globl _anim_clock
                             26 	.globl _sprites
                             27 ;--------------------------------------------------------
                             28 ; special function registers
                             29 ;--------------------------------------------------------
                             30 ;--------------------------------------------------------
                             31 ; ram data
                             32 ;--------------------------------------------------------
                             33 	.area _DATA
   5F24                      34 _sprites::
   5F24                      35 	.ds 250
   601E                      36 _anim_clock::
   601E                      37 	.ds 1
                             38 ;--------------------------------------------------------
                             39 ; ram data
                             40 ;--------------------------------------------------------
                             41 	.area _INITIALIZED
                             42 ;--------------------------------------------------------
                             43 ; absolute external ram data
                             44 ;--------------------------------------------------------
                             45 	.area _DABS (ABS)
                             46 ;--------------------------------------------------------
                             47 ; global & static initialisations
                             48 ;--------------------------------------------------------
                             49 	.area _HOME
                             50 	.area _GSINIT
                             51 	.area _GSFINAL
                             52 	.area _GSINIT
                             53 ;--------------------------------------------------------
                             54 ; Home
                             55 ;--------------------------------------------------------
                             56 	.area _HOME
                             57 	.area _HOME
                             58 ;--------------------------------------------------------
                             59 ; code
                             60 ;--------------------------------------------------------
                             61 	.area _CODE
                             62 ;src/game.c:14: void keyboard(){
                             63 ;	---------------------------------
                             64 ; Function keyboard
                             65 ; ---------------------------------
   4110                      66 _keyboard::
                             67 ;src/game.c:17: sprites[0].moveV = sprites[0].moveH = 0; 							//start with no movement
   4110 21 28 5F      [10]   68 	ld	hl, #(_sprites + 0x0004)
   4113 36 00         [10]   69 	ld	(hl), #0x00
   4115 21 27 5F      [10]   70 	ld	hl, #(_sprites + 0x0003)
   4118 36 00         [10]   71 	ld	(hl), #0x00
                             72 ;src/game.c:20: cpct_scanKeyboard_f();
   411A CD 89 5B      [17]   73 	call	_cpct_scanKeyboard_f
                             74 ;src/game.c:21: if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
   411D 21 00 01      [10]   75 	ld	hl, #0x0100
   4120 CD 7D 5B      [17]   76 	call	_cpct_isKeyPressed
   4123 7D            [ 4]   77 	ld	a, l
   4124 B7            [ 4]   78 	or	a, a
   4125 20 14         [12]   79 	jr	NZ,00101$
   4127 21 08 08      [10]   80 	ld	hl, #0x0808
   412A CD 7D 5B      [17]   81 	call	_cpct_isKeyPressed
   412D 7D            [ 4]   82 	ld	a, l
   412E B7            [ 4]   83 	or	a, a
   412F 20 0A         [12]   84 	jr	NZ,00101$
   4131 21 09 01      [10]   85 	ld	hl, #0x0109
   4134 CD 7D 5B      [17]   86 	call	_cpct_isKeyPressed
   4137 7D            [ 4]   87 	ld	a, l
   4138 B7            [ 4]   88 	or	a, a
   4139 28 05         [12]   89 	jr	Z,00102$
   413B                      90 00101$:
                             91 ;src/game.c:22: sprites[0].moveV = -1;		
   413B 21 27 5F      [10]   92 	ld	hl, #(_sprites + 0x0003)
   413E 36 FF         [10]   93 	ld	(hl), #0xff
   4140                      94 00102$:
                             95 ;src/game.c:24: if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
   4140 21 00 04      [10]   96 	ld	hl, #0x0400
   4143 CD 7D 5B      [17]   97 	call	_cpct_isKeyPressed
   4146 7D            [ 4]   98 	ld	a, l
   4147 B7            [ 4]   99 	or	a, a
   4148 20 14         [12]  100 	jr	NZ,00105$
   414A 21 08 20      [10]  101 	ld	hl, #0x2008
   414D CD 7D 5B      [17]  102 	call	_cpct_isKeyPressed
   4150 7D            [ 4]  103 	ld	a, l
   4151 B7            [ 4]  104 	or	a, a
   4152 20 0A         [12]  105 	jr	NZ,00105$
   4154 21 09 02      [10]  106 	ld	hl, #0x0209
   4157 CD 7D 5B      [17]  107 	call	_cpct_isKeyPressed
   415A 7D            [ 4]  108 	ld	a, l
   415B B7            [ 4]  109 	or	a, a
   415C 28 05         [12]  110 	jr	Z,00106$
   415E                     111 00105$:
                            112 ;src/game.c:25: sprites[0].moveV = 1;
   415E 21 27 5F      [10]  113 	ld	hl, #(_sprites + 0x0003)
   4161 36 01         [10]  114 	ld	(hl), #0x01
   4163                     115 00106$:
                            116 ;src/game.c:27: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   4163 21 01 01      [10]  117 	ld	hl, #0x0101
   4166 CD 7D 5B      [17]  118 	call	_cpct_isKeyPressed
   4169 7D            [ 4]  119 	ld	a, l
   416A B7            [ 4]  120 	or	a, a
   416B 20 14         [12]  121 	jr	NZ,00109$
   416D 21 04 04      [10]  122 	ld	hl, #0x0404
   4170 CD 7D 5B      [17]  123 	call	_cpct_isKeyPressed
   4173 7D            [ 4]  124 	ld	a, l
   4174 B7            [ 4]  125 	or	a, a
   4175 20 0A         [12]  126 	jr	NZ,00109$
   4177 21 09 04      [10]  127 	ld	hl, #0x0409
   417A CD 7D 5B      [17]  128 	call	_cpct_isKeyPressed
   417D 7D            [ 4]  129 	ld	a, l
   417E B7            [ 4]  130 	or	a, a
   417F 28 05         [12]  131 	jr	Z,00110$
   4181                     132 00109$:
                            133 ;src/game.c:28: sprites[0].moveH = -1;
   4181 21 28 5F      [10]  134 	ld	hl, #(_sprites + 0x0004)
   4184 36 FF         [10]  135 	ld	(hl), #0xff
   4186                     136 00110$:
                            137 ;src/game.c:31: if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
   4186 21 00 02      [10]  138 	ld	hl, #0x0200
   4189 CD 7D 5B      [17]  139 	call	_cpct_isKeyPressed
   418C 7D            [ 4]  140 	ld	a, l
   418D B7            [ 4]  141 	or	a, a
   418E 20 14         [12]  142 	jr	NZ,00113$
   4190 21 03 08      [10]  143 	ld	hl, #0x0803
   4193 CD 7D 5B      [17]  144 	call	_cpct_isKeyPressed
   4196 7D            [ 4]  145 	ld	a, l
   4197 B7            [ 4]  146 	or	a, a
   4198 20 0A         [12]  147 	jr	NZ,00113$
   419A 21 09 08      [10]  148 	ld	hl, #0x0809
   419D CD 7D 5B      [17]  149 	call	_cpct_isKeyPressed
   41A0 7D            [ 4]  150 	ld	a, l
   41A1 B7            [ 4]  151 	or	a, a
   41A2 28 05         [12]  152 	jr	Z,00114$
   41A4                     153 00113$:
                            154 ;src/game.c:32: sprites[0].moveH = 1;
   41A4 21 28 5F      [10]  155 	ld	hl, #(_sprites + 0x0004)
   41A7 36 01         [10]  156 	ld	(hl), #0x01
   41A9                     157 00114$:
                            158 ;src/game.c:37: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
   41A9 21 28 5F      [10]  159 	ld	hl, #(_sprites + 0x0004) + 0
   41AC 4E            [ 7]  160 	ld	c, (hl)
                            161 ;src/game.c:38: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
   41AD 11 2F 5F      [10]  162 	ld	de, #_sprites + 11
   41B0 1A            [ 7]  163 	ld	a, (de)
   41B1 47            [ 4]  164 	ld	b, a
                            165 ;src/game.c:37: if (sprites[0].moveH !=0 || sprites[0].moveV !=0)					//sprite moved
   41B2 79            [ 4]  166 	ld	a, c
   41B3 B7            [ 4]  167 	or	a, a
   41B4 20 06         [12]  168 	jr	NZ,00117$
   41B6 3A 27 5F      [13]  169 	ld	a, (#(_sprites + 0x0003) + 0)
   41B9 B7            [ 4]  170 	or	a, a
   41BA 28 05         [12]  171 	jr	Z,00118$
   41BC                     172 00117$:
                            173 ;src/game.c:38: sprites[0].properties = sprites[0].properties | MASK_ANIMATE; 	//mark for animation
   41BC 78            [ 4]  174 	ld	a, b
   41BD CB CF         [ 8]  175 	set	1, a
   41BF 12            [ 7]  176 	ld	(de), a
   41C0 C9            [10]  177 	ret
   41C1                     178 00118$:
                            179 ;src/game.c:40: sprites[0].properties = sprites[0].properties & ~MASK_ANIMATE;	//unmark for animation;
   41C1 CB 88         [ 8]  180 	res	1, b
   41C3 78            [ 4]  181 	ld	a, b
   41C4 12            [ 7]  182 	ld	(de), a
   41C5 C9            [10]  183 	ret
                            184 ;src/game.c:45: void AI(){
                            185 ;	---------------------------------
                            186 ; Function AI
                            187 ; ---------------------------------
   41C6                     188 _AI::
                            189 ;src/game.c:46: }
   41C6 C9            [10]  190 	ret
                            191 ;src/game.c:50: void moveSprites() {
                            192 ;	---------------------------------
                            193 ; Function moveSprites
                            194 ; ---------------------------------
   41C7                     195 _moveSprites::
   41C7 DD E5         [15]  196 	push	ix
   41C9 DD 21 00 00   [14]  197 	ld	ix,#0
   41CD DD 39         [15]  198 	add	ix,sp
   41CF 21 F6 FF      [10]  199 	ld	hl, #-10
   41D2 39            [11]  200 	add	hl, sp
   41D3 F9            [ 6]  201 	ld	sp, hl
                            202 ;src/game.c:54: for (i=0; i < MAX_SPRITES; i++) {
   41D4 DD 36 F8 00   [19]  203 	ld	-8 (ix), #0x00
   41D8                     204 00112$:
                            205 ;src/game.c:55: if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
   41D8 DD 4E F8      [19]  206 	ld	c,-8 (ix)
   41DB 06 00         [ 7]  207 	ld	b,#0x00
   41DD 69            [ 4]  208 	ld	l, c
   41DE 60            [ 4]  209 	ld	h, b
   41DF 29            [11]  210 	add	hl, hl
   41E0 09            [11]  211 	add	hl, bc
   41E1 29            [11]  212 	add	hl, hl
   41E2 29            [11]  213 	add	hl, hl
   41E3 29            [11]  214 	add	hl, hl
   41E4 09            [11]  215 	add	hl, bc
   41E5 01 24 5F      [10]  216 	ld	bc,#_sprites
   41E8 09            [11]  217 	add	hl,bc
   41E9 DD 75 F9      [19]  218 	ld	-7 (ix), l
   41EC DD 74 FA      [19]  219 	ld	-6 (ix), h
   41EF 7E            [ 7]  220 	ld	a, (hl)
   41F0 DD 77 FF      [19]  221 	ld	-1 (ix), a
   41F3 B7            [ 4]  222 	or	a, a
   41F4 CA B7 42      [10]  223 	jp	Z, 00113$
                            224 ;src/game.c:56: collision = 0;
   41F7 DD 36 F6 00   [19]  225 	ld	-10 (ix), #0x00
                            226 ;src/game.c:58: x = sprites[i].x;
   41FB DD 7E F9      [19]  227 	ld	a, -7 (ix)
   41FE C6 01         [ 7]  228 	add	a, #0x01
   4200 DD 77 FD      [19]  229 	ld	-3 (ix), a
   4203 DD 7E FA      [19]  230 	ld	a, -6 (ix)
   4206 CE 00         [ 7]  231 	adc	a, #0x00
   4208 DD 77 FE      [19]  232 	ld	-2 (ix), a
   420B DD 6E FD      [19]  233 	ld	l,-3 (ix)
   420E DD 66 FE      [19]  234 	ld	h,-2 (ix)
   4211 46            [ 7]  235 	ld	b, (hl)
                            236 ;src/game.c:59: y = sprites[i].y;
   4212 DD 7E F9      [19]  237 	ld	a, -7 (ix)
   4215 C6 02         [ 7]  238 	add	a, #0x02
   4217 DD 77 FB      [19]  239 	ld	-5 (ix), a
   421A DD 7E FA      [19]  240 	ld	a, -6 (ix)
   421D CE 00         [ 7]  241 	adc	a, #0x00
   421F DD 77 FC      [19]  242 	ld	-4 (ix), a
   4222 DD 6E FB      [19]  243 	ld	l,-5 (ix)
   4225 DD 66 FC      [19]  244 	ld	h,-4 (ix)
   4228 4E            [ 7]  245 	ld	c, (hl)
                            246 ;src/game.c:61: y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
   4229 DD 6E F9      [19]  247 	ld	l,-7 (ix)
   422C DD 66 FA      [19]  248 	ld	h,-6 (ix)
   422F 23            [ 6]  249 	inc	hl
   4230 23            [ 6]  250 	inc	hl
   4231 23            [ 6]  251 	inc	hl
   4232 7E            [ 7]  252 	ld	a, (hl)
   4233 87            [ 4]  253 	add	a, a
   4234 87            [ 4]  254 	add	a, a
   4235 6F            [ 4]  255 	ld	l, a
   4236 09            [11]  256 	add	hl, bc
   4237 4D            [ 4]  257 	ld	c, l
                            258 ;src/game.c:62: x = x + (sprites[i].moveH);
   4238 DD 6E F9      [19]  259 	ld	l,-7 (ix)
   423B DD 66 FA      [19]  260 	ld	h,-6 (ix)
   423E 11 04 00      [10]  261 	ld	de, #0x0004
   4241 19            [11]  262 	add	hl, de
   4242 5E            [ 7]  263 	ld	e, (hl)
   4243 68            [ 4]  264 	ld	l, b
   4244 19            [11]  265 	add	hl, de
   4245 DD 75 F7      [19]  266 	ld	-9 (ix), l
                            267 ;src/game.c:65: if (y > (GAME_AREA_BOTTOM - sprites[i].height))
   4248 DD 6E F9      [19]  268 	ld	l,-7 (ix)
   424B DD 66 FA      [19]  269 	ld	h,-6 (ix)
   424E 11 09 00      [10]  270 	ld	de, #0x0009
   4251 19            [11]  271 	add	hl, de
   4252 5E            [ 7]  272 	ld	e, (hl)
   4253 16 00         [ 7]  273 	ld	d, #0x00
   4255 3E C8         [ 7]  274 	ld	a, #0xc8
   4257 93            [ 4]  275 	sub	a, e
   4258 47            [ 4]  276 	ld	b, a
   4259 3E 00         [ 7]  277 	ld	a, #0x00
   425B 9A            [ 4]  278 	sbc	a, d
   425C 5F            [ 4]  279 	ld	e, a
   425D 69            [ 4]  280 	ld	l, c
   425E 16 00         [ 7]  281 	ld	d, #0x00
   4260 78            [ 4]  282 	ld	a, b
   4261 95            [ 4]  283 	sub	a, l
   4262 7B            [ 4]  284 	ld	a, e
   4263 9A            [ 4]  285 	sbc	a, d
   4264 E2 69 42      [10]  286 	jp	PO, 00141$
   4267 EE 80         [ 7]  287 	xor	a, #0x80
   4269                     288 00141$:
   4269 F2 70 42      [10]  289 	jp	P, 00102$
                            290 ;src/game.c:66: collision = collision | TOP_BOTTOM_COLLISION; //signal top collision w/bitmask
   426C DD 36 F6 01   [19]  291 	ld	-10 (ix), #0x01
   4270                     292 00102$:
                            293 ;src/game.c:68: if (x > (GAME_AREA_RIGHT - sprites[i].width))
   4270 DD 6E F9      [19]  294 	ld	l,-7 (ix)
   4273 DD 66 FA      [19]  295 	ld	h,-6 (ix)
   4276 11 0A 00      [10]  296 	ld	de, #0x000a
   4279 19            [11]  297 	add	hl, de
   427A 5E            [ 7]  298 	ld	e, (hl)
   427B 16 00         [ 7]  299 	ld	d, #0x00
   427D 3E 50         [ 7]  300 	ld	a, #0x50
   427F 93            [ 4]  301 	sub	a, e
   4280 5F            [ 4]  302 	ld	e, a
   4281 3E 00         [ 7]  303 	ld	a, #0x00
   4283 9A            [ 4]  304 	sbc	a, d
   4284 57            [ 4]  305 	ld	d, a
   4285 DD 6E F7      [19]  306 	ld	l, -9 (ix)
   4288 26 00         [ 7]  307 	ld	h, #0x00
   428A 7B            [ 4]  308 	ld	a, e
   428B 95            [ 4]  309 	sub	a, l
   428C 7A            [ 4]  310 	ld	a, d
   428D 9C            [ 4]  311 	sbc	a, h
   428E E2 93 42      [10]  312 	jp	PO, 00142$
   4291 EE 80         [ 7]  313 	xor	a, #0x80
   4293                     314 00142$:
   4293 F2 9A 42      [10]  315 	jp	P, 00104$
                            316 ;src/game.c:69: collision = collision | LEFT_RIGHT_COLLISION; //signal right collision w/bitmask
   4296 DD CB F6 CE   [23]  317 	set	1, -10 (ix)
   429A                     318 00104$:
                            319 ;src/game.c:74: if ((collision & TOP_BOTTOM_COLLISION) == 0)		//if not hitting top, move sideways
   429A DD CB F6 46   [20]  320 	bit	0, -10 (ix)
   429E 20 07         [12]  321 	jr	NZ,00106$
                            322 ;src/game.c:75: sprites[i].y = y;
   42A0 DD 6E FB      [19]  323 	ld	l,-5 (ix)
   42A3 DD 66 FC      [19]  324 	ld	h,-4 (ix)
   42A6 71            [ 7]  325 	ld	(hl), c
   42A7                     326 00106$:
                            327 ;src/game.c:76: if ((collision & LEFT_RIGHT_COLLISION) == 0)		//if not hitting right, move up/down
   42A7 DD CB F6 4E   [20]  328 	bit	1, -10 (ix)
   42AB 20 0A         [12]  329 	jr	NZ,00113$
                            330 ;src/game.c:77: sprites[i].x = x;
   42AD DD 6E FD      [19]  331 	ld	l,-3 (ix)
   42B0 DD 66 FE      [19]  332 	ld	h,-2 (ix)
   42B3 DD 7E F7      [19]  333 	ld	a, -9 (ix)
   42B6 77            [ 7]  334 	ld	(hl), a
   42B7                     335 00113$:
                            336 ;src/game.c:54: for (i=0; i < MAX_SPRITES; i++) {
   42B7 DD 34 F8      [23]  337 	inc	-8 (ix)
   42BA DD 7E F8      [19]  338 	ld	a, -8 (ix)
   42BD D6 0A         [ 7]  339 	sub	a, #0x0a
   42BF DA D8 41      [10]  340 	jp	C, 00112$
   42C2 DD F9         [10]  341 	ld	sp, ix
   42C4 DD E1         [14]  342 	pop	ix
   42C6 C9            [10]  343 	ret
                            344 ;src/game.c:85: void init_game() {
                            345 ;	---------------------------------
                            346 ; Function init_game
                            347 ; ---------------------------------
   42C7                     348 _init_game::
                            349 ;src/game.c:88: sprites[0].id = 1;												//mark the sprite "alive" (non-zero)
   42C7 21 24 5F      [10]  350 	ld	hl, #_sprites
   42CA 36 01         [10]  351 	ld	(hl), #0x01
                            352 ;src/game.c:89: sprites[0].x = sprites[0].y = 0;								//init position to 0,0
   42CC 21 26 5F      [10]  353 	ld	hl, #(_sprites + 0x0002)
   42CF 36 00         [10]  354 	ld	(hl), #0x00
   42D1 21 25 5F      [10]  355 	ld	hl, #(_sprites + 0x0001)
   42D4 36 00         [10]  356 	ld	(hl), #0x00
                            357 ;src/game.c:90: sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
   42D6 21 28 5F      [10]  358 	ld	hl, #(_sprites + 0x0004)
   42D9 36 00         [10]  359 	ld	(hl), #0x00
   42DB 21 27 5F      [10]  360 	ld	hl, #(_sprites + 0x0003)
   42DE 36 00         [10]  361 	ld	(hl), #0x00
                            362 ;src/game.c:92: sprites[0].x_prev_A = sprites[0].y_prev_A = sprites[0].x_prev_B = sprites[0].y_prev_B = 0;
   42E0 21 2C 5F      [10]  363 	ld	hl, #(_sprites + 0x0008)
   42E3 36 00         [10]  364 	ld	(hl), #0x00
   42E5 21 2B 5F      [10]  365 	ld	hl, #(_sprites + 0x0007)
   42E8 36 00         [10]  366 	ld	(hl), #0x00
   42EA 21 2A 5F      [10]  367 	ld	hl, #(_sprites + 0x0006)
   42ED 36 00         [10]  368 	ld	(hl), #0x00
   42EF 21 29 5F      [10]  369 	ld	hl, #(_sprites + 0x0005)
   42F2 36 00         [10]  370 	ld	(hl), #0x00
                            371 ;src/game.c:93: sprites[0].height = G_PITU_H;
   42F4 21 2D 5F      [10]  372 	ld	hl, #(_sprites + 0x0009)
   42F7 36 20         [10]  373 	ld	(hl), #0x20
                            374 ;src/game.c:94: sprites[0].width = G_PITU_W;									//!?! /2: - M0, length in bytes = /2 in px
   42F9 21 2E 5F      [10]  375 	ld	hl, #(_sprites + 0x000a)
   42FC 36 08         [10]  376 	ld	(hl), #0x08
                            377 ;src/game.c:95: sprites[0].properties = 0;										//bitmasked properties - init to 0
   42FE 01 2F 5F      [10]  378 	ld	bc, #_sprites + 11
   4301 AF            [ 4]  379 	xor	a, a
   4302 02            [ 7]  380 	ld	(bc), a
                            381 ;src/game.c:96: sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render" on screen
   4303 0A            [ 7]  382 	ld	a, (bc)
   4304 CB C7         [ 8]  383 	set	0, a
   4306 02            [ 7]  384 	ld	(bc), a
                            385 ;src/game.c:97: sprites[0].frames = 2;											//main sprite has two "moves" to animate
   4307 21 32 5F      [10]  386 	ld	hl, #(_sprites + 0x000e)
   430A 36 02         [10]  387 	ld	(hl), #0x02
                            388 ;src/game.c:98: sprites[0].sprite_f1 = (u8*)G_pitu; 							//first render for sprite. &G_pitu[0]
   430C 21 B9 43      [10]  389 	ld	hl, #_G_pitu
   430F 22 33 5F      [16]  390 	ld	((_sprites + 0x000f)), hl
                            391 ;src/game.c:99: sprites[0].sprite_f2 = (u8*)G_pitu_walk;
   4312 21 B9 45      [10]  392 	ld	hl, #_G_pitu_walk
   4315 22 35 5F      [16]  393 	ld	((_sprites + 0x0011)), hl
                            394 ;src/game.c:100: sprites[0].sprite_f3 = (u8*)G_pitu_jump;
   4318 21 B9 47      [10]  395 	ld	hl, #_G_pitu_jump
   431B 22 37 5F      [16]  396 	ld	((_sprites + 0x0013)), hl
                            397 ;src/game.c:101: sprites[0].sprite_f3 = (u8*)G_blast;
   431E 21 B9 4D      [10]  398 	ld	hl, #_G_blast
   4321 22 37 5F      [16]  399 	ld	((_sprites + 0x0013)), hl
                            400 ;src/game.c:102: sprites[0].turned = 0;											//start looking right/front
   4324 21 00 00      [10]  401 	ld	hl, #0x0000
   4327 22 3B 5F      [16]  402 	ld	((_sprites + 0x0017)), hl
                            403 ;src/game.c:105: for (i = 1; i < MAX_SPRITES; i++)
   432A 0E 01         [ 7]  404 	ld	c, #0x01
   432C                     405 00102$:
                            406 ;src/game.c:106: sprites[i].id=0;
   432C 06 00         [ 7]  407 	ld	b,#0x00
   432E 69            [ 4]  408 	ld	l, c
   432F 60            [ 4]  409 	ld	h, b
   4330 29            [11]  410 	add	hl, hl
   4331 09            [11]  411 	add	hl, bc
   4332 29            [11]  412 	add	hl, hl
   4333 29            [11]  413 	add	hl, hl
   4334 29            [11]  414 	add	hl, hl
   4335 09            [11]  415 	add	hl, bc
   4336 11 24 5F      [10]  416 	ld	de, #_sprites
   4339 19            [11]  417 	add	hl, de
   433A 36 00         [10]  418 	ld	(hl), #0x00
                            419 ;src/game.c:105: for (i = 1; i < MAX_SPRITES; i++)
   433C 0C            [ 4]  420 	inc	c
   433D 79            [ 4]  421 	ld	a, c
   433E D6 0A         [ 7]  422 	sub	a, #0x0a
   4340 38 EA         [12]  423 	jr	C,00102$
                            424 ;src/game.c:108: anim_clock=1;
   4342 21 1E 60      [10]  425 	ld	hl,#_anim_clock + 0
   4345 36 01         [10]  426 	ld	(hl), #0x01
   4347 C9            [10]  427 	ret
                            428 ;src/game.c:114: void game(){
                            429 ;	---------------------------------
                            430 ; Function game
                            431 ; ---------------------------------
   4348                     432 _game::
                            433 ;src/game.c:116: cpct_setBorder(HW_WHITE);
   4348 21 10 00      [10]  434 	ld	hl, #0x0010
   434B E5            [11]  435 	push	hl
   434C CD 31 5C      [17]  436 	call	_cpct_setPALColour
                            437 ;src/game.c:118: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
   434F 21 05 05      [10]  438 	ld	hl, #0x0505
   4352 E5            [11]  439 	push	hl
   4353 CD F7 5D      [17]  440 	call	_cpct_px2byteM0
   4356 45            [ 4]  441 	ld	b, l
   4357 21 00 80      [10]  442 	ld	hl, #0x8000
   435A E5            [11]  443 	push	hl
   435B C5            [11]  444 	push	bc
   435C 33            [ 6]  445 	inc	sp
   435D 2E 00         [ 7]  446 	ld	l, #0x00
   435F E5            [11]  447 	push	hl
   4360 CD 13 5E      [17]  448 	call	_cpct_memset
                            449 ;src/game.c:120: while (1) {
   4363                     450 00107$:
                            451 ;src/game.c:123: if (!swap_memvideo) { 					//switch
   4363 3A 22 60      [13]  452 	ld	a,(#_swap_memvideo + 0)
   4366 B7            [ 4]  453 	or	a, a
   4367 20 0D         [12]  454 	jr	NZ,00102$
                            455 ;src/game.c:124: mem_start = (u8*) CPCT_LVMEM_START;	//lower VMEM page
   4369 21 00 80      [10]  456 	ld	hl, #0x8000
   436C 22 1F 60      [16]  457 	ld	(_mem_start), hl
                            458 ;src/game.c:125: mem_page = cpct_page80;				//FIXME:: can probably delete??
   436F 21 21 60      [10]  459 	ld	hl,#_mem_page + 0
   4372 36 20         [10]  460 	ld	(hl), #0x20
   4374 18 0B         [12]  461 	jr	00103$
   4376                     462 00102$:
                            463 ;src/game.c:127: mem_start = (u8*) CPCT_VMEM_START;	//upper,regular VMEM page
   4376 21 00 C0      [10]  464 	ld	hl, #0xc000
   4379 22 1F 60      [16]  465 	ld	(_mem_start), hl
                            466 ;src/game.c:128: mem_page = cpct_pageC0;
   437C 21 21 60      [10]  467 	ld	hl,#_mem_page + 0
   437F 36 30         [10]  468 	ld	(hl), #0x30
   4381                     469 00103$:
                            470 ;src/game.c:132: keyboard(); 							//user movement
   4381 CD 10 41      [17]  471 	call	_keyboard
                            472 ;src/game.c:134: moveSprites();
   4384 CD C7 41      [17]  473 	call	_moveSprites
                            474 ;src/game.c:135: deleteSprites();
   4387 CD 78 5A      [17]  475 	call	_deleteSprites
                            476 ;src/game.c:136: renderSprites();
   438A CD C4 58      [17]  477 	call	_renderSprites
                            478 ;src/game.c:139: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
   438D CD EF 5D      [17]  479 	call	_cpct_waitVSYNC
                            480 ;src/game.c:140: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
   4390 FD 21 21 60   [14]  481 	ld	iy, #_mem_page
   4394 FD 6E 00      [19]  482 	ld	l, 0 (iy)
   4397 CD 8A 5D      [17]  483 	call	_cpct_setVideoMemoryPage
                            484 ;src/game.c:141: swap_memvideo = ~swap_memvideo; 		//flip the switch
   439A FD 21 22 60   [14]  485 	ld	iy, #_swap_memvideo
   439E FD 7E 00      [19]  486 	ld	a, 0 (iy)
   43A1 2F            [ 4]  487 	cpl
   43A2 FD 77 00      [19]  488 	ld	0 (iy), a
                            489 ;src/game.c:143: anim_clock+=ANIM_SPEED;
   43A5 FD 21 1E 60   [14]  490 	ld	iy, #_anim_clock
   43A9 FD 34 00      [23]  491 	inc	0 (iy)
                            492 ;src/game.c:144: if (anim_clock > ANIM_CYCLE)
   43AC 3E 10         [ 7]  493 	ld	a, #0x10
   43AE FD 96 00      [19]  494 	sub	a, 0 (iy)
   43B1 30 B0         [12]  495 	jr	NC,00107$
                            496 ;src/game.c:145: anim_clock=1;
   43B3 FD 36 00 01   [19]  497 	ld	0 (iy), #0x01
   43B7 18 AA         [12]  498 	jr	00107$
                            499 	.area _CODE
                            500 	.area _INITIALIZER
                            501 	.area _CABS (ABS)
