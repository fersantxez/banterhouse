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
                             25 	.globl _cycle
                             26 	.globl _sprites
                             27 	.globl _coord_x
                             28 ;--------------------------------------------------------
                             29 ; special function registers
                             30 ;--------------------------------------------------------
                             31 ;--------------------------------------------------------
                             32 ; ram data
                             33 ;--------------------------------------------------------
                             34 	.area _DATA
   5DFA                      35 _coord_x::
   5DFA                      36 	.ds 1
   5DFB                      37 _sprites::
   5DFB                      38 	.ds 220
   5ED7                      39 _cycle::
   5ED7                      40 	.ds 1
                             41 ;--------------------------------------------------------
                             42 ; ram data
                             43 ;--------------------------------------------------------
                             44 	.area _INITIALIZED
                             45 ;--------------------------------------------------------
                             46 ; absolute external ram data
                             47 ;--------------------------------------------------------
                             48 	.area _DABS (ABS)
                             49 ;--------------------------------------------------------
                             50 ; global & static initialisations
                             51 ;--------------------------------------------------------
                             52 	.area _HOME
                             53 	.area _GSINIT
                             54 	.area _GSFINAL
                             55 	.area _GSINIT
                             56 ;--------------------------------------------------------
                             57 ; Home
                             58 ;--------------------------------------------------------
                             59 	.area _HOME
                             60 	.area _HOME
                             61 ;--------------------------------------------------------
                             62 ; code
                             63 ;--------------------------------------------------------
                             64 	.area _CODE
                             65 ;src/game.c:17: void keyboard(){
                             66 ;	---------------------------------
                             67 ; Function keyboard
                             68 ; ---------------------------------
   4110                      69 _keyboard::
                             70 ;src/game.c:20: sprites[0].moveV = sprites[0].moveH = 0; 						//start with no movement
   4110 21 FF 5D      [10]   71 	ld	hl, #(_sprites + 0x0004)
   4113 36 00         [10]   72 	ld	(hl), #0x00
   4115 21 FE 5D      [10]   73 	ld	hl, #(_sprites + 0x0003)
   4118 36 00         [10]   74 	ld	(hl), #0x00
                             75 ;src/game.c:22: cpct_scanKeyboard_f();											//read keyboard/joystick
   411A CD 9D 5A      [17]   76 	call	_cpct_scanKeyboard_f
                             77 ;src/game.c:23: if (cpct_isKeyPressed(Key_CursorUp) || cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	
   411D 21 00 01      [10]   78 	ld	hl, #0x0100
   4120 CD 91 5A      [17]   79 	call	_cpct_isKeyPressed
   4123 7D            [ 4]   80 	ld	a, l
   4124 B7            [ 4]   81 	or	a, a
   4125 20 14         [12]   82 	jr	NZ,00101$
   4127 21 08 08      [10]   83 	ld	hl, #0x0808
   412A CD 91 5A      [17]   84 	call	_cpct_isKeyPressed
   412D 7D            [ 4]   85 	ld	a, l
   412E B7            [ 4]   86 	or	a, a
   412F 20 0A         [12]   87 	jr	NZ,00101$
   4131 21 09 01      [10]   88 	ld	hl, #0x0109
   4134 CD 91 5A      [17]   89 	call	_cpct_isKeyPressed
   4137 7D            [ 4]   90 	ld	a, l
   4138 B7            [ 4]   91 	or	a, a
   4139 28 05         [12]   92 	jr	Z,00102$
   413B                      93 00101$:
                             94 ;src/game.c:24: sprites[0].moveV = -1;		
   413B 21 FE 5D      [10]   95 	ld	hl, #(_sprites + 0x0003)
   413E 36 FF         [10]   96 	ld	(hl), #0xff
   4140                      97 00102$:
                             98 ;src/game.c:26: if (cpct_isKeyPressed(Key_CursorDown) || cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){
   4140 21 00 04      [10]   99 	ld	hl, #0x0400
   4143 CD 91 5A      [17]  100 	call	_cpct_isKeyPressed
   4146 7D            [ 4]  101 	ld	a, l
   4147 B7            [ 4]  102 	or	a, a
   4148 20 14         [12]  103 	jr	NZ,00105$
   414A 21 08 20      [10]  104 	ld	hl, #0x2008
   414D CD 91 5A      [17]  105 	call	_cpct_isKeyPressed
   4150 7D            [ 4]  106 	ld	a, l
   4151 B7            [ 4]  107 	or	a, a
   4152 20 0A         [12]  108 	jr	NZ,00105$
   4154 21 09 02      [10]  109 	ld	hl, #0x0209
   4157 CD 91 5A      [17]  110 	call	_cpct_isKeyPressed
   415A 7D            [ 4]  111 	ld	a, l
   415B B7            [ 4]  112 	or	a, a
   415C 28 05         [12]  113 	jr	Z,00106$
   415E                     114 00105$:
                            115 ;src/game.c:27: sprites[0].moveV = 1;
   415E 21 FE 5D      [10]  116 	ld	hl, #(_sprites + 0x0003)
   4161 36 01         [10]  117 	ld	(hl), #0x01
   4163                     118 00106$:
                            119 ;src/game.c:29: if (cpct_isKeyPressed(Key_CursorLeft) || cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){
   4163 21 01 01      [10]  120 	ld	hl, #0x0101
   4166 CD 91 5A      [17]  121 	call	_cpct_isKeyPressed
   4169 7D            [ 4]  122 	ld	a, l
   416A B7            [ 4]  123 	or	a, a
   416B 20 14         [12]  124 	jr	NZ,00109$
   416D 21 04 04      [10]  125 	ld	hl, #0x0404
   4170 CD 91 5A      [17]  126 	call	_cpct_isKeyPressed
   4173 7D            [ 4]  127 	ld	a, l
   4174 B7            [ 4]  128 	or	a, a
   4175 20 0A         [12]  129 	jr	NZ,00109$
   4177 21 09 04      [10]  130 	ld	hl, #0x0409
   417A CD 91 5A      [17]  131 	call	_cpct_isKeyPressed
   417D 7D            [ 4]  132 	ld	a, l
   417E B7            [ 4]  133 	or	a, a
   417F 28 05         [12]  134 	jr	Z,00110$
   4181                     135 00109$:
                            136 ;src/game.c:30: sprites[0].moveH = -1;
   4181 21 FF 5D      [10]  137 	ld	hl, #(_sprites + 0x0004)
   4184 36 FF         [10]  138 	ld	(hl), #0xff
   4186                     139 00110$:
                            140 ;src/game.c:33: if (cpct_isKeyPressed(Key_CursorRight) || cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){
   4186 21 00 02      [10]  141 	ld	hl, #0x0200
   4189 CD 91 5A      [17]  142 	call	_cpct_isKeyPressed
   418C 7D            [ 4]  143 	ld	a, l
   418D B7            [ 4]  144 	or	a, a
   418E 20 13         [12]  145 	jr	NZ,00113$
   4190 21 03 08      [10]  146 	ld	hl, #0x0803
   4193 CD 91 5A      [17]  147 	call	_cpct_isKeyPressed
   4196 7D            [ 4]  148 	ld	a, l
   4197 B7            [ 4]  149 	or	a, a
   4198 20 09         [12]  150 	jr	NZ,00113$
   419A 21 09 08      [10]  151 	ld	hl, #0x0809
   419D CD 91 5A      [17]  152 	call	_cpct_isKeyPressed
   41A0 7D            [ 4]  153 	ld	a, l
   41A1 B7            [ 4]  154 	or	a, a
   41A2 C8            [11]  155 	ret	Z
   41A3                     156 00113$:
                            157 ;src/game.c:34: sprites[0].moveH = 1;
   41A3 21 FF 5D      [10]  158 	ld	hl, #(_sprites + 0x0004)
   41A6 36 01         [10]  159 	ld	(hl), #0x01
   41A8 C9            [10]  160 	ret
                            161 ;src/game.c:41: void AI(){
                            162 ;	---------------------------------
                            163 ; Function AI
                            164 ; ---------------------------------
   41A9                     165 _AI::
                            166 ;src/game.c:42: }
   41A9 C9            [10]  167 	ret
                            168 ;src/game.c:46: void moveSprites() {
                            169 ;	---------------------------------
                            170 ; Function moveSprites
                            171 ; ---------------------------------
   41AA                     172 _moveSprites::
   41AA DD E5         [15]  173 	push	ix
   41AC DD 21 00 00   [14]  174 	ld	ix,#0
   41B0 DD 39         [15]  175 	add	ix,sp
   41B2 21 F6 FF      [10]  176 	ld	hl, #-10
   41B5 39            [11]  177 	add	hl, sp
   41B6 F9            [ 6]  178 	ld	sp, hl
                            179 ;src/game.c:50: for (i=0; i < MAX_SPRITES; i++) {
   41B7 DD 36 F8 00   [19]  180 	ld	-8 (ix), #0x00
   41BB                     181 00112$:
                            182 ;src/game.c:51: if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
   41BB DD 4E F8      [19]  183 	ld	c,-8 (ix)
   41BE 06 00         [ 7]  184 	ld	b,#0x00
   41C0 69            [ 4]  185 	ld	l, c
   41C1 60            [ 4]  186 	ld	h, b
   41C2 29            [11]  187 	add	hl, hl
   41C3 29            [11]  188 	add	hl, hl
   41C4 09            [11]  189 	add	hl, bc
   41C5 29            [11]  190 	add	hl, hl
   41C6 09            [11]  191 	add	hl, bc
   41C7 29            [11]  192 	add	hl, hl
   41C8 01 FB 5D      [10]  193 	ld	bc,#_sprites
   41CB 09            [11]  194 	add	hl,bc
   41CC DD 75 F9      [19]  195 	ld	-7 (ix), l
   41CF DD 74 FA      [19]  196 	ld	-6 (ix), h
   41D2 7E            [ 7]  197 	ld	a, (hl)
   41D3 DD 77 FD      [19]  198 	ld	-3 (ix), a
   41D6 B7            [ 4]  199 	or	a, a
   41D7 CA 9A 42      [10]  200 	jp	Z, 00113$
                            201 ;src/game.c:52: collision = 0;
   41DA DD 36 F6 00   [19]  202 	ld	-10 (ix), #0x00
                            203 ;src/game.c:54: x = sprites[i].x;
   41DE DD 7E F9      [19]  204 	ld	a, -7 (ix)
   41E1 C6 01         [ 7]  205 	add	a, #0x01
   41E3 DD 77 FE      [19]  206 	ld	-2 (ix), a
   41E6 DD 7E FA      [19]  207 	ld	a, -6 (ix)
   41E9 CE 00         [ 7]  208 	adc	a, #0x00
   41EB DD 77 FF      [19]  209 	ld	-1 (ix), a
   41EE DD 6E FE      [19]  210 	ld	l,-2 (ix)
   41F1 DD 66 FF      [19]  211 	ld	h,-1 (ix)
   41F4 46            [ 7]  212 	ld	b, (hl)
                            213 ;src/game.c:55: y = sprites[i].y;
   41F5 DD 7E F9      [19]  214 	ld	a, -7 (ix)
   41F8 C6 02         [ 7]  215 	add	a, #0x02
   41FA DD 77 FB      [19]  216 	ld	-5 (ix), a
   41FD DD 7E FA      [19]  217 	ld	a, -6 (ix)
   4200 CE 00         [ 7]  218 	adc	a, #0x00
   4202 DD 77 FC      [19]  219 	ld	-4 (ix), a
   4205 DD 6E FB      [19]  220 	ld	l,-5 (ix)
   4208 DD 66 FC      [19]  221 	ld	h,-4 (ix)
   420B 4E            [ 7]  222 	ld	c, (hl)
                            223 ;src/game.c:57: y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
   420C DD 6E F9      [19]  224 	ld	l,-7 (ix)
   420F DD 66 FA      [19]  225 	ld	h,-6 (ix)
   4212 23            [ 6]  226 	inc	hl
   4213 23            [ 6]  227 	inc	hl
   4214 23            [ 6]  228 	inc	hl
   4215 7E            [ 7]  229 	ld	a, (hl)
   4216 87            [ 4]  230 	add	a, a
   4217 87            [ 4]  231 	add	a, a
   4218 6F            [ 4]  232 	ld	l, a
   4219 09            [11]  233 	add	hl, bc
   421A 4D            [ 4]  234 	ld	c, l
                            235 ;src/game.c:58: x = x + (sprites[i].moveH);
   421B DD 6E F9      [19]  236 	ld	l,-7 (ix)
   421E DD 66 FA      [19]  237 	ld	h,-6 (ix)
   4221 11 04 00      [10]  238 	ld	de, #0x0004
   4224 19            [11]  239 	add	hl, de
   4225 5E            [ 7]  240 	ld	e, (hl)
   4226 68            [ 4]  241 	ld	l, b
   4227 19            [11]  242 	add	hl, de
   4228 DD 75 F7      [19]  243 	ld	-9 (ix), l
                            244 ;src/game.c:61: if (y > (GAME_AREA_BOTTOM - sprites[i].height))
   422B DD 6E F9      [19]  245 	ld	l,-7 (ix)
   422E DD 66 FA      [19]  246 	ld	h,-6 (ix)
   4231 11 09 00      [10]  247 	ld	de, #0x0009
   4234 19            [11]  248 	add	hl, de
   4235 5E            [ 7]  249 	ld	e, (hl)
   4236 16 00         [ 7]  250 	ld	d, #0x00
   4238 3E C8         [ 7]  251 	ld	a, #0xc8
   423A 93            [ 4]  252 	sub	a, e
   423B 47            [ 4]  253 	ld	b, a
   423C 3E 00         [ 7]  254 	ld	a, #0x00
   423E 9A            [ 4]  255 	sbc	a, d
   423F 5F            [ 4]  256 	ld	e, a
   4240 69            [ 4]  257 	ld	l, c
   4241 16 00         [ 7]  258 	ld	d, #0x00
   4243 78            [ 4]  259 	ld	a, b
   4244 95            [ 4]  260 	sub	a, l
   4245 7B            [ 4]  261 	ld	a, e
   4246 9A            [ 4]  262 	sbc	a, d
   4247 E2 4C 42      [10]  263 	jp	PO, 00141$
   424A EE 80         [ 7]  264 	xor	a, #0x80
   424C                     265 00141$:
   424C F2 53 42      [10]  266 	jp	P, 00102$
                            267 ;src/game.c:62: collision = collision | TOP_BOTTOM_COLLISION; //signal top collision w/bitmask
   424F DD 36 F6 01   [19]  268 	ld	-10 (ix), #0x01
   4253                     269 00102$:
                            270 ;src/game.c:64: if (x > (GAME_AREA_RIGHT - sprites[i].width))
   4253 DD 6E F9      [19]  271 	ld	l,-7 (ix)
   4256 DD 66 FA      [19]  272 	ld	h,-6 (ix)
   4259 11 0A 00      [10]  273 	ld	de, #0x000a
   425C 19            [11]  274 	add	hl, de
   425D 5E            [ 7]  275 	ld	e, (hl)
   425E 16 00         [ 7]  276 	ld	d, #0x00
   4260 3E 50         [ 7]  277 	ld	a, #0x50
   4262 93            [ 4]  278 	sub	a, e
   4263 5F            [ 4]  279 	ld	e, a
   4264 3E 00         [ 7]  280 	ld	a, #0x00
   4266 9A            [ 4]  281 	sbc	a, d
   4267 57            [ 4]  282 	ld	d, a
   4268 DD 6E F7      [19]  283 	ld	l, -9 (ix)
   426B 26 00         [ 7]  284 	ld	h, #0x00
   426D 7B            [ 4]  285 	ld	a, e
   426E 95            [ 4]  286 	sub	a, l
   426F 7A            [ 4]  287 	ld	a, d
   4270 9C            [ 4]  288 	sbc	a, h
   4271 E2 76 42      [10]  289 	jp	PO, 00142$
   4274 EE 80         [ 7]  290 	xor	a, #0x80
   4276                     291 00142$:
   4276 F2 7D 42      [10]  292 	jp	P, 00104$
                            293 ;src/game.c:65: collision = collision | LEFT_RIGHT_COLLISION; //signal right collision w/bitmask
   4279 DD CB F6 CE   [23]  294 	set	1, -10 (ix)
   427D                     295 00104$:
                            296 ;src/game.c:70: if ((collision & TOP_BOTTOM_COLLISION) == 0)		//if not hitting top, move sideways
   427D DD CB F6 46   [20]  297 	bit	0, -10 (ix)
   4281 20 07         [12]  298 	jr	NZ,00106$
                            299 ;src/game.c:71: sprites[i].y = y;
   4283 DD 6E FB      [19]  300 	ld	l,-5 (ix)
   4286 DD 66 FC      [19]  301 	ld	h,-4 (ix)
   4289 71            [ 7]  302 	ld	(hl), c
   428A                     303 00106$:
                            304 ;src/game.c:72: if ((collision & LEFT_RIGHT_COLLISION) == 0)		//if not hitting right, move up/down
   428A DD CB F6 4E   [20]  305 	bit	1, -10 (ix)
   428E 20 0A         [12]  306 	jr	NZ,00113$
                            307 ;src/game.c:73: sprites[i].x = x;
   4290 DD 6E FE      [19]  308 	ld	l,-2 (ix)
   4293 DD 66 FF      [19]  309 	ld	h,-1 (ix)
   4296 DD 7E F7      [19]  310 	ld	a, -9 (ix)
   4299 77            [ 7]  311 	ld	(hl), a
   429A                     312 00113$:
                            313 ;src/game.c:50: for (i=0; i < MAX_SPRITES; i++) {
   429A DD 34 F8      [23]  314 	inc	-8 (ix)
   429D DD 7E F8      [19]  315 	ld	a, -8 (ix)
   42A0 D6 0A         [ 7]  316 	sub	a, #0x0a
   42A2 DA BB 41      [10]  317 	jp	C, 00112$
   42A5 DD F9         [10]  318 	ld	sp, ix
   42A7 DD E1         [14]  319 	pop	ix
   42A9 C9            [10]  320 	ret
                            321 ;src/game.c:81: void init_game() {
                            322 ;	---------------------------------
                            323 ; Function init_game
                            324 ; ---------------------------------
   42AA                     325 _init_game::
                            326 ;src/game.c:84: sprites[0].id = 1;												//mark the sprite "alive" (non-zero)
   42AA 21 FB 5D      [10]  327 	ld	hl, #_sprites
   42AD 36 01         [10]  328 	ld	(hl), #0x01
                            329 ;src/game.c:85: sprites[0].x = sprites[0].y = 0;								//init position to 0,0
   42AF 21 FD 5D      [10]  330 	ld	hl, #(_sprites + 0x0002)
   42B2 36 00         [10]  331 	ld	(hl), #0x00
   42B4 21 FC 5D      [10]  332 	ld	hl, #(_sprites + 0x0001)
   42B7 36 00         [10]  333 	ld	(hl), #0x00
                            334 ;src/game.c:86: sprites[0].moveV = sprites[0].moveH = 0;						//init movement to none
   42B9 21 FF 5D      [10]  335 	ld	hl, #(_sprites + 0x0004)
   42BC 36 00         [10]  336 	ld	(hl), #0x00
   42BE 21 FE 5D      [10]  337 	ld	hl, #(_sprites + 0x0003)
   42C1 36 00         [10]  338 	ld	(hl), #0x00
                            339 ;src/game.c:88: sprites[0].x_prev_A = sprites[0].y_prev_A = sprites[0].x_prev_B = sprites[0].y_prev_B = 0;
   42C3 21 03 5E      [10]  340 	ld	hl, #(_sprites + 0x0008)
   42C6 36 00         [10]  341 	ld	(hl), #0x00
   42C8 21 02 5E      [10]  342 	ld	hl, #(_sprites + 0x0007)
   42CB 36 00         [10]  343 	ld	(hl), #0x00
   42CD 21 01 5E      [10]  344 	ld	hl, #(_sprites + 0x0006)
   42D0 36 00         [10]  345 	ld	(hl), #0x00
   42D2 21 00 5E      [10]  346 	ld	hl, #(_sprites + 0x0005)
   42D5 36 00         [10]  347 	ld	(hl), #0x00
                            348 ;src/game.c:89: sprites[0].height = G_PITU_H;
   42D7 21 04 5E      [10]  349 	ld	hl, #(_sprites + 0x0009)
   42DA 36 20         [10]  350 	ld	(hl), #0x20
                            351 ;src/game.c:90: sprites[0].width = G_PITU_W;									//!?! /2: - M0, length in bytes = /2 in px
   42DC 21 05 5E      [10]  352 	ld	hl, #(_sprites + 0x000a)
   42DF 36 08         [10]  353 	ld	(hl), #0x08
                            354 ;src/game.c:91: sprites[0].properties = 0;										//bitmasked properties - init to 0
   42E1 01 06 5E      [10]  355 	ld	bc, #_sprites + 11
   42E4 AF            [ 4]  356 	xor	a, a
   42E5 02            [ 7]  357 	ld	(bc), a
                            358 ;src/game.c:92: sprites[0].properties = sprites[0].properties | MASK_RENDER;	//init to "render" on screen
   42E6 0A            [ 7]  359 	ld	a, (bc)
   42E7 CB C7         [ 8]  360 	set	0, a
   42E9 02            [ 7]  361 	ld	(bc), a
                            362 ;src/game.c:93: sprites[0].sprite_f1 = (u8*)G_pitu; //&G_pitu[0]				//first render for sprite
   42EA 21 96 43      [10]  363 	ld	hl, #_G_pitu
   42ED 22 09 5E      [16]  364 	ld	((_sprites + 0x000e)), hl
                            365 ;src/game.c:94: sprites[0].sprite_f2 = (u8*)G_pitu_walk;
   42F0 21 96 45      [10]  366 	ld	hl, #_G_pitu_walk
   42F3 22 0B 5E      [16]  367 	ld	((_sprites + 0x0010)), hl
                            368 ;src/game.c:95: sprites[0].sprite_f3 = (u8*)G_pitu_jump;
   42F6 21 96 47      [10]  369 	ld	hl, #_G_pitu_jump
   42F9 22 0D 5E      [16]  370 	ld	((_sprites + 0x0012)), hl
                            371 ;src/game.c:96: sprites[0].sprite_f3 = (u8*)G_blast;
   42FC 21 96 4D      [10]  372 	ld	hl, #_G_blast
   42FF 22 0D 5E      [16]  373 	ld	((_sprites + 0x0012)), hl
                            374 ;src/game.c:100: for (i = 1; i < MAX_SPRITES; i++)
   4302 0E 01         [ 7]  375 	ld	c, #0x01
   4304                     376 00102$:
                            377 ;src/game.c:101: sprites[i].id=0;
   4304 06 00         [ 7]  378 	ld	b,#0x00
   4306 69            [ 4]  379 	ld	l, c
   4307 60            [ 4]  380 	ld	h, b
   4308 29            [11]  381 	add	hl, hl
   4309 29            [11]  382 	add	hl, hl
   430A 09            [11]  383 	add	hl, bc
   430B 29            [11]  384 	add	hl, hl
   430C 09            [11]  385 	add	hl, bc
   430D 29            [11]  386 	add	hl, hl
   430E 11 FB 5D      [10]  387 	ld	de, #_sprites
   4311 19            [11]  388 	add	hl, de
   4312 36 00         [10]  389 	ld	(hl), #0x00
                            390 ;src/game.c:100: for (i = 1; i < MAX_SPRITES; i++)
   4314 0C            [ 4]  391 	inc	c
   4315 79            [ 4]  392 	ld	a, c
   4316 D6 0A         [ 7]  393 	sub	a, #0x0a
   4318 38 EA         [12]  394 	jr	C,00102$
                            395 ;src/game.c:103: cycle=0;
   431A 21 D7 5E      [10]  396 	ld	hl,#_cycle + 0
   431D 36 00         [10]  397 	ld	(hl), #0x00
   431F C9            [10]  398 	ret
                            399 ;src/game.c:110: void game(){
                            400 ;	---------------------------------
                            401 ; Function game
                            402 ; ---------------------------------
   4320                     403 _game::
                            404 ;src/game.c:112: cpct_setBorder(HW_WHITE);
   4320 21 10 00      [10]  405 	ld	hl, #0x0010
   4323 E5            [11]  406 	push	hl
   4324 CD 07 5B      [17]  407 	call	_cpct_setPALColour
                            408 ;src/game.c:114: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
   4327 21 05 05      [10]  409 	ld	hl, #0x0505
   432A E5            [11]  410 	push	hl
   432B CD CD 5C      [17]  411 	call	_cpct_px2byteM0
   432E 45            [ 4]  412 	ld	b, l
   432F 21 00 80      [10]  413 	ld	hl, #0x8000
   4332 E5            [11]  414 	push	hl
   4333 C5            [11]  415 	push	bc
   4334 33            [ 6]  416 	inc	sp
   4335 2E 00         [ 7]  417 	ld	l, #0x00
   4337 E5            [11]  418 	push	hl
   4338 CD E9 5C      [17]  419 	call	_cpct_memset
                            420 ;src/game.c:116: coord_x = 0;
   433B 21 FA 5D      [10]  421 	ld	hl,#_coord_x + 0
   433E 36 00         [10]  422 	ld	(hl), #0x00
                            423 ;src/game.c:118: while (1) {
   4340                     424 00107$:
                            425 ;src/game.c:121: if (!swap_memvideo) { 					//switch
   4340 3A DB 5E      [13]  426 	ld	a,(#_swap_memvideo + 0)
   4343 B7            [ 4]  427 	or	a, a
   4344 20 0D         [12]  428 	jr	NZ,00102$
                            429 ;src/game.c:122: mem_start = (u8*) CPCT_LVMEM_START;	//lower VMEM page
   4346 21 00 80      [10]  430 	ld	hl, #0x8000
   4349 22 D8 5E      [16]  431 	ld	(_mem_start), hl
                            432 ;src/game.c:123: mem_page = cpct_page80;				//FIXME:: can probably delete??
   434C 21 DA 5E      [10]  433 	ld	hl,#_mem_page + 0
   434F 36 20         [10]  434 	ld	(hl), #0x20
   4351 18 0B         [12]  435 	jr	00103$
   4353                     436 00102$:
                            437 ;src/game.c:125: mem_start = (u8*) CPCT_VMEM_START;	//upper,regular VMEM page
   4353 21 00 C0      [10]  438 	ld	hl, #0xc000
   4356 22 D8 5E      [16]  439 	ld	(_mem_start), hl
                            440 ;src/game.c:126: mem_page = cpct_pageC0;
   4359 21 DA 5E      [10]  441 	ld	hl,#_mem_page + 0
   435C 36 30         [10]  442 	ld	(hl), #0x30
   435E                     443 00103$:
                            444 ;src/game.c:130: keyboard(); 							//user movement
   435E CD 10 41      [17]  445 	call	_keyboard
                            446 ;src/game.c:132: moveSprites();
   4361 CD AA 41      [17]  447 	call	_moveSprites
                            448 ;src/game.c:133: deleteSprites();
   4364 CD 8C 59      [17]  449 	call	_deleteSprites
                            450 ;src/game.c:134: renderSprites();
   4367 CD A1 58      [17]  451 	call	_renderSprites
                            452 ;src/game.c:137: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
   436A CD C5 5C      [17]  453 	call	_cpct_waitVSYNC
                            454 ;src/game.c:138: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
   436D FD 21 DA 5E   [14]  455 	ld	iy, #_mem_page
   4371 FD 6E 00      [19]  456 	ld	l, 0 (iy)
   4374 CD 60 5C      [17]  457 	call	_cpct_setVideoMemoryPage
                            458 ;src/game.c:139: swap_memvideo = ~swap_memvideo; 		//flip the switch
   4377 FD 21 DB 5E   [14]  459 	ld	iy, #_swap_memvideo
   437B FD 7E 00      [19]  460 	ld	a, 0 (iy)
   437E 2F            [ 4]  461 	cpl
   437F FD 77 00      [19]  462 	ld	0 (iy), a
                            463 ;src/game.c:141: cycle++;
   4382 FD 21 D7 5E   [14]  464 	ld	iy, #_cycle
   4386 FD 34 00      [23]  465 	inc	0 (iy)
                            466 ;src/game.c:142: if (cycle == 16)
   4389 FD 7E 00      [19]  467 	ld	a, 0 (iy)
   438C D6 10         [ 7]  468 	sub	a, #0x10
   438E 20 B0         [12]  469 	jr	NZ,00107$
                            470 ;src/game.c:143: cycle=0;
   4390 FD 36 00 00   [19]  471 	ld	0 (iy), #0x00
   4394 18 AA         [12]  472 	jr	00107$
                            473 	.area _CODE
                            474 	.area _INITIALIZER
                            475 	.area _CABS (ABS)
