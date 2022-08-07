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
                             12 	.globl _AI
                             13 	.globl _keyboard
                             14 	.globl _init_game
                             15 	.globl _deleteSprites
                             16 	.globl _renderSprites
                             17 	.globl _cpct_setVideoMemoryPage
                             18 	.globl _cpct_setPALColour
                             19 	.globl _cpct_waitVSYNC
                             20 	.globl _cpct_px2byteM0
                             21 	.globl _cpct_isKeyPressed
                             22 	.globl _cpct_scanKeyboard_f
                             23 	.globl _cpct_memset
                             24 	.globl _cycle
                             25 	.globl _sprites
                             26 	.globl _coord_x
                             27 	.globl _moveSprites
                             28 ;--------------------------------------------------------
                             29 ; special function registers
                             30 ;--------------------------------------------------------
                             31 ;--------------------------------------------------------
                             32 ; ram data
                             33 ;--------------------------------------------------------
                             34 	.area _DATA
   5DAD                      35 _coord_x::
   5DAD                      36 	.ds 1
   5DAE                      37 _sprites::
   5DAE                      38 	.ds 220
   5E8A                      39 _cycle::
   5E8A                      40 	.ds 1
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
                             65 ;src/game.c:11: void init_game() {
                             66 ;	---------------------------------
                             67 ; Function init_game
                             68 ; ---------------------------------
   4110                      69 _init_game::
                             70 ;src/game.c:15: sprites[0].id = 1;								//mark the sprite "alive"
   4110 21 AE 5D      [10]   71 	ld	hl, #_sprites
   4113 36 01         [10]   72 	ld	(hl), #0x01
                             73 ;src/game.c:16: sprites[0].x = sprites[0].y = 0;				//init position to 0,0
   4115 21 B0 5D      [10]   74 	ld	hl, #(_sprites + 0x0002)
   4118 36 00         [10]   75 	ld	(hl), #0x00
   411A 21 AF 5D      [10]   76 	ld	hl, #(_sprites + 0x0001)
   411D 36 00         [10]   77 	ld	(hl), #0x00
                             78 ;src/game.c:17: sprites[0].moveV = sprites[0].moveH = 0;		//init movement to none
   411F 21 B2 5D      [10]   79 	ld	hl, #(_sprites + 0x0004)
   4122 36 00         [10]   80 	ld	(hl), #0x00
   4124 21 B1 5D      [10]   81 	ld	hl, #(_sprites + 0x0003)
   4127 36 00         [10]   82 	ld	(hl), #0x00
                             83 ;src/game.c:18: sprites[0].x_prev_A = sprites[0].y_prev_A = sprites[0].x_prev_B = sprites[0].y_prev_B = 0;
   4129 21 B6 5D      [10]   84 	ld	hl, #(_sprites + 0x0008)
   412C 36 00         [10]   85 	ld	(hl), #0x00
   412E 21 B5 5D      [10]   86 	ld	hl, #(_sprites + 0x0007)
   4131 36 00         [10]   87 	ld	(hl), #0x00
   4133 21 B4 5D      [10]   88 	ld	hl, #(_sprites + 0x0006)
   4136 36 00         [10]   89 	ld	(hl), #0x00
   4138 21 B3 5D      [10]   90 	ld	hl, #(_sprites + 0x0005)
   413B 36 00         [10]   91 	ld	(hl), #0x00
                             92 ;src/game.c:19: sprites[0].height = G_PITU_H;
   413D 21 B7 5D      [10]   93 	ld	hl, #(_sprites + 0x0009)
   4140 36 20         [10]   94 	ld	(hl), #0x20
                             95 ;src/game.c:20: sprites[0].width = G_PITU_W/2;
   4142 21 B8 5D      [10]   96 	ld	hl, #(_sprites + 0x000a)
   4145 36 08         [10]   97 	ld	(hl), #0x08
                             98 ;src/game.c:21: sprites[0].properties = 0;
   4147 01 B9 5D      [10]   99 	ld	bc, #_sprites + 11
   414A AF            [ 4]  100 	xor	a, a
   414B 02            [ 7]  101 	ld	(bc), a
                            102 ;src/game.c:22: sprites[0].properties = sprites[0].properties | MASK_RENDER;
   414C 0A            [ 7]  103 	ld	a, (bc)
   414D CB C7         [ 8]  104 	set	0, a
   414F 02            [ 7]  105 	ld	(bc), a
                            106 ;src/game.c:23: sprites[0].sprite_f1 = (u8*)G_pitu; //&G_pitu[0]
   4150 21 49 43      [10]  107 	ld	hl, #_G_pitu
   4153 22 BC 5D      [16]  108 	ld	((_sprites + 0x000e)), hl
                            109 ;src/game.c:24: sprites[0].sprite_f2 = (u8*)G_pitu_walk;
   4156 21 49 45      [10]  110 	ld	hl, #_G_pitu_walk
   4159 22 BE 5D      [16]  111 	ld	((_sprites + 0x0010)), hl
                            112 ;src/game.c:25: sprites[0].sprite_f3 = (u8*)G_pitu_jump;
   415C 21 49 47      [10]  113 	ld	hl, #_G_pitu_jump
   415F 22 C0 5D      [16]  114 	ld	((_sprites + 0x0012)), hl
                            115 ;src/game.c:26: sprites[0].sprite_f3 = (u8*)G_blast;
   4162 21 49 4D      [10]  116 	ld	hl, #_G_blast
   4165 22 C0 5D      [16]  117 	ld	((_sprites + 0x0012)), hl
                            118 ;src/game.c:30: for (i = 1; i < MAX_SPRITES; i++)
   4168 0E 01         [ 7]  119 	ld	c, #0x01
   416A                     120 00102$:
                            121 ;src/game.c:31: sprites[i].id=0;
   416A 06 00         [ 7]  122 	ld	b,#0x00
   416C 69            [ 4]  123 	ld	l, c
   416D 60            [ 4]  124 	ld	h, b
   416E 29            [11]  125 	add	hl, hl
   416F 29            [11]  126 	add	hl, hl
   4170 09            [11]  127 	add	hl, bc
   4171 29            [11]  128 	add	hl, hl
   4172 09            [11]  129 	add	hl, bc
   4173 29            [11]  130 	add	hl, hl
   4174 11 AE 5D      [10]  131 	ld	de, #_sprites
   4177 19            [11]  132 	add	hl, de
   4178 36 00         [10]  133 	ld	(hl), #0x00
                            134 ;src/game.c:30: for (i = 1; i < MAX_SPRITES; i++)
   417A 0C            [ 4]  135 	inc	c
   417B 79            [ 4]  136 	ld	a, c
   417C D6 0A         [ 7]  137 	sub	a, #0x0a
   417E 38 EA         [12]  138 	jr	C,00102$
                            139 ;src/game.c:33: cycle=0;
   4180 21 8A 5E      [10]  140 	ld	hl,#_cycle + 0
   4183 36 00         [10]  141 	ld	(hl), #0x00
   4185 C9            [10]  142 	ret
                            143 ;src/game.c:37: void keyboard(){
                            144 ;	---------------------------------
                            145 ; Function keyboard
                            146 ; ---------------------------------
   4186                     147 _keyboard::
                            148 ;src/game.c:38: sprites[0].moveV = sprites[0].moveH = 0; 						//start with no movement
   4186 21 B2 5D      [10]  149 	ld	hl, #(_sprites + 0x0004)
   4189 36 00         [10]  150 	ld	(hl), #0x00
   418B 21 B1 5D      [10]  151 	ld	hl, #(_sprites + 0x0003)
   418E 36 00         [10]  152 	ld	(hl), #0x00
                            153 ;src/game.c:40: cpct_scanKeyboard_f();											//read keyboard/joystick
   4190 CD 50 5A      [17]  154 	call	_cpct_scanKeyboard_f
                            155 ;src/game.c:41: if (cpct_isKeyPressed(Key_Q) || cpct_isKeyPressed(Joy0_Up)){	//predefined Q=UP
   4193 21 08 08      [10]  156 	ld	hl, #0x0808
   4196 CD 44 5A      [17]  157 	call	_cpct_isKeyPressed
   4199 7D            [ 4]  158 	ld	a, l
   419A B7            [ 4]  159 	or	a, a
   419B 20 0A         [12]  160 	jr	NZ,00101$
   419D 21 09 01      [10]  161 	ld	hl, #0x0109
   41A0 CD 44 5A      [17]  162 	call	_cpct_isKeyPressed
   41A3 7D            [ 4]  163 	ld	a, l
   41A4 B7            [ 4]  164 	or	a, a
   41A5 28 05         [12]  165 	jr	Z,00102$
   41A7                     166 00101$:
                            167 ;src/game.c:42: sprites[0].moveV = -1;										//FIXME=UP = -1???
   41A7 21 B1 5D      [10]  168 	ld	hl, #(_sprites + 0x0003)
   41AA 36 FF         [10]  169 	ld	(hl), #0xff
   41AC                     170 00102$:
                            171 ;src/game.c:44: if (cpct_isKeyPressed(Key_A) || cpct_isKeyPressed(Joy0_Down)){	//predefined A=DOWN
   41AC 21 08 20      [10]  172 	ld	hl, #0x2008
   41AF CD 44 5A      [17]  173 	call	_cpct_isKeyPressed
   41B2 7D            [ 4]  174 	ld	a, l
   41B3 B7            [ 4]  175 	or	a, a
   41B4 20 0A         [12]  176 	jr	NZ,00104$
   41B6 21 09 02      [10]  177 	ld	hl, #0x0209
   41B9 CD 44 5A      [17]  178 	call	_cpct_isKeyPressed
   41BC 7D            [ 4]  179 	ld	a, l
   41BD B7            [ 4]  180 	or	a, a
   41BE 28 05         [12]  181 	jr	Z,00105$
   41C0                     182 00104$:
                            183 ;src/game.c:45: sprites[0].moveV = 1;
   41C0 21 B1 5D      [10]  184 	ld	hl, #(_sprites + 0x0003)
   41C3 36 01         [10]  185 	ld	(hl), #0x01
   41C5                     186 00105$:
                            187 ;src/game.c:47: if (cpct_isKeyPressed(Key_O) || cpct_isKeyPressed(Joy0_Left)){	//predefined O=LEFT
   41C5 21 04 04      [10]  188 	ld	hl, #0x0404
   41C8 CD 44 5A      [17]  189 	call	_cpct_isKeyPressed
   41CB 7D            [ 4]  190 	ld	a, l
   41CC B7            [ 4]  191 	or	a, a
   41CD 20 0A         [12]  192 	jr	NZ,00107$
   41CF 21 09 04      [10]  193 	ld	hl, #0x0409
   41D2 CD 44 5A      [17]  194 	call	_cpct_isKeyPressed
   41D5 7D            [ 4]  195 	ld	a, l
   41D6 B7            [ 4]  196 	or	a, a
   41D7 28 05         [12]  197 	jr	Z,00108$
   41D9                     198 00107$:
                            199 ;src/game.c:48: sprites[0].moveH = -1;
   41D9 21 B2 5D      [10]  200 	ld	hl, #(_sprites + 0x0004)
   41DC 36 FF         [10]  201 	ld	(hl), #0xff
   41DE                     202 00108$:
                            203 ;src/game.c:51: if (cpct_isKeyPressed(Key_P) || cpct_isKeyPressed(Joy0_Right)){ //predefined P=RIGHT
   41DE 21 03 08      [10]  204 	ld	hl, #0x0803
   41E1 CD 44 5A      [17]  205 	call	_cpct_isKeyPressed
   41E4 7D            [ 4]  206 	ld	a, l
   41E5 B7            [ 4]  207 	or	a, a
   41E6 20 09         [12]  208 	jr	NZ,00110$
   41E8 21 09 08      [10]  209 	ld	hl, #0x0809
   41EB CD 44 5A      [17]  210 	call	_cpct_isKeyPressed
   41EE 7D            [ 4]  211 	ld	a, l
   41EF B7            [ 4]  212 	or	a, a
   41F0 C8            [11]  213 	ret	Z
   41F1                     214 00110$:
                            215 ;src/game.c:52: sprites[0].moveH = -1;										//FIXME=RIGHT = -1???
   41F1 21 B2 5D      [10]  216 	ld	hl, #(_sprites + 0x0004)
   41F4 36 FF         [10]  217 	ld	(hl), #0xff
   41F6 C9            [10]  218 	ret
                            219 ;src/game.c:57: void AI(){
                            220 ;	---------------------------------
                            221 ; Function AI
                            222 ; ---------------------------------
   41F7                     223 _AI::
                            224 ;src/game.c:58: }
   41F7 C9            [10]  225 	ret
                            226 ;src/game.c:60: void moveSprites() {
                            227 ;	---------------------------------
                            228 ; Function moveSprites
                            229 ; ---------------------------------
   41F8                     230 _moveSprites::
   41F8 DD E5         [15]  231 	push	ix
   41FA DD 21 00 00   [14]  232 	ld	ix,#0
   41FE DD 39         [15]  233 	add	ix,sp
   4200 21 F3 FF      [10]  234 	ld	hl, #-13
   4203 39            [11]  235 	add	hl, sp
   4204 F9            [ 6]  236 	ld	sp, hl
                            237 ;src/game.c:63: for (i=0; i < MAX_SPRITES; i++) {
   4205 DD 36 F4 00   [19]  238 	ld	-12 (ix), #0x00
   4209                     239 00108$:
                            240 ;src/game.c:64: if (sprites[i].id !=0) {			//check only live sprites to optimize CPU (non-zero)
   4209 DD 4E F4      [19]  241 	ld	c,-12 (ix)
   420C 06 00         [ 7]  242 	ld	b,#0x00
   420E 69            [ 4]  243 	ld	l, c
   420F 60            [ 4]  244 	ld	h, b
   4210 29            [11]  245 	add	hl, hl
   4211 29            [11]  246 	add	hl, hl
   4212 09            [11]  247 	add	hl, bc
   4213 29            [11]  248 	add	hl, hl
   4214 09            [11]  249 	add	hl, bc
   4215 29            [11]  250 	add	hl, hl
   4216 01 AE 5D      [10]  251 	ld	bc,#_sprites
   4219 09            [11]  252 	add	hl,bc
   421A DD 75 F9      [19]  253 	ld	-7 (ix), l
   421D DD 74 FA      [19]  254 	ld	-6 (ix), h
   4220 7E            [ 7]  255 	ld	a, (hl)
   4221 DD 77 FD      [19]  256 	ld	-3 (ix), a
   4224 B7            [ 4]  257 	or	a, a
   4225 CA C3 42      [10]  258 	jp	Z, 00109$
                            259 ;src/game.c:67: x = sprites[i].x;
   4228 DD 7E F9      [19]  260 	ld	a, -7 (ix)
   422B C6 01         [ 7]  261 	add	a, #0x01
   422D DD 77 F7      [19]  262 	ld	-9 (ix), a
   4230 DD 7E FA      [19]  263 	ld	a, -6 (ix)
   4233 CE 00         [ 7]  264 	adc	a, #0x00
   4235 DD 77 F8      [19]  265 	ld	-8 (ix), a
   4238 DD 6E F7      [19]  266 	ld	l,-9 (ix)
   423B DD 66 F8      [19]  267 	ld	h,-8 (ix)
   423E 7E            [ 7]  268 	ld	a, (hl)
   423F DD 77 FD      [19]  269 	ld	-3 (ix), a
                            270 ;src/game.c:68: y = sprites[i].y;
   4242 DD 7E F9      [19]  271 	ld	a, -7 (ix)
   4245 C6 02         [ 7]  272 	add	a, #0x02
   4247 DD 77 FB      [19]  273 	ld	-5 (ix), a
   424A DD 7E FA      [19]  274 	ld	a, -6 (ix)
   424D CE 00         [ 7]  275 	adc	a, #0x00
   424F DD 77 FC      [19]  276 	ld	-4 (ix), a
   4252 DD 6E FB      [19]  277 	ld	l,-5 (ix)
   4255 DD 66 FC      [19]  278 	ld	h,-4 (ix)
   4258 7E            [ 7]  279 	ld	a, (hl)
   4259 DD 77 F6      [19]  280 	ld	-10 (ix), a
                            281 ;src/game.c:70: y = y + (4*sprites[i].moveV);	//vertical movement: Y is *px, X is *byte. M0 so Y is 4 times slower
   425C DD 7E F9      [19]  282 	ld	a, -7 (ix)
   425F DD 77 FE      [19]  283 	ld	-2 (ix), a
   4262 DD 7E FA      [19]  284 	ld	a, -6 (ix)
   4265 DD 77 FF      [19]  285 	ld	-1 (ix), a
   4268 DD 6E FE      [19]  286 	ld	l,-2 (ix)
   426B DD 66 FF      [19]  287 	ld	h,-1 (ix)
   426E 23            [ 6]  288 	inc	hl
   426F 23            [ 6]  289 	inc	hl
   4270 23            [ 6]  290 	inc	hl
   4271 7E            [ 7]  291 	ld	a, (hl)
   4272 DD 77 FE      [19]  292 	ld	-2 (ix), a
   4275 87            [ 4]  293 	add	a, a
   4276 87            [ 4]  294 	add	a, a
   4277 DD 77 FE      [19]  295 	ld	-2 (ix), a
   427A DD 7E F6      [19]  296 	ld	a, -10 (ix)
   427D DD 86 FE      [19]  297 	add	a, -2 (ix)
   4280 DD 77 FE      [19]  298 	ld	-2 (ix), a
   4283 DD 77 F5      [19]  299 	ld	-11 (ix), a
                            300 ;src/game.c:71: x = x + (sprites[i].moveH);
   4286 DD 7E F9      [19]  301 	ld	a, -7 (ix)
   4289 DD 77 FE      [19]  302 	ld	-2 (ix), a
   428C DD 7E FA      [19]  303 	ld	a, -6 (ix)
   428F DD 77 FF      [19]  304 	ld	-1 (ix), a
   4292 DD 6E FE      [19]  305 	ld	l,-2 (ix)
   4295 DD 66 FF      [19]  306 	ld	h,-1 (ix)
   4298 11 04 00      [10]  307 	ld	de, #0x0004
   429B 19            [11]  308 	add	hl, de
   429C 7E            [ 7]  309 	ld	a, (hl)
   429D DD 77 FE      [19]  310 	ld	-2 (ix), a
   42A0 DD 7E FD      [19]  311 	ld	a, -3 (ix)
   42A3 DD 77 F6      [19]  312 	ld	-10 (ix), a
   42A6 DD 86 FE      [19]  313 	add	a, -2 (ix)
   42A9 DD 77 FE      [19]  314 	ld	-2 (ix), a
   42AC DD 77 F3      [19]  315 	ld	-13 (ix), a
                            316 ;src/game.c:81: sprites[i].y = y;
   42AF DD 6E FB      [19]  317 	ld	l,-5 (ix)
   42B2 DD 66 FC      [19]  318 	ld	h,-4 (ix)
   42B5 DD 7E F5      [19]  319 	ld	a, -11 (ix)
   42B8 77            [ 7]  320 	ld	(hl), a
                            321 ;src/game.c:83: sprites[i].x = x;
   42B9 DD 6E F7      [19]  322 	ld	l,-9 (ix)
   42BC DD 66 F8      [19]  323 	ld	h,-8 (ix)
   42BF DD 7E F3      [19]  324 	ld	a, -13 (ix)
   42C2 77            [ 7]  325 	ld	(hl), a
   42C3                     326 00109$:
                            327 ;src/game.c:63: for (i=0; i < MAX_SPRITES; i++) {
   42C3 DD 34 F4      [23]  328 	inc	-12 (ix)
   42C6 DD 7E F4      [19]  329 	ld	a, -12 (ix)
   42C9 D6 0A         [ 7]  330 	sub	a, #0x0a
   42CB DA 09 42      [10]  331 	jp	C, 00108$
   42CE DD F9         [10]  332 	ld	sp, ix
   42D0 DD E1         [14]  333 	pop	ix
   42D2 C9            [10]  334 	ret
                            335 ;src/game.c:88: void game(){
                            336 ;	---------------------------------
                            337 ; Function game
                            338 ; ---------------------------------
   42D3                     339 _game::
                            340 ;src/game.c:89: cpct_setBorder(HW_BLACK);
   42D3 21 10 14      [10]  341 	ld	hl, #0x1410
   42D6 E5            [11]  342 	push	hl
   42D7 CD BA 5A      [17]  343 	call	_cpct_setPALColour
                            344 ;src/game.c:91: cpct_memset ((u8*)CPCT_LVMEM_START, cpct_px2byteM0(5, 5), 0x8000); //5 is ordinal for WHITE from palette in M0 with 16c
   42DA 21 05 05      [10]  345 	ld	hl, #0x0505
   42DD E5            [11]  346 	push	hl
   42DE CD 80 5C      [17]  347 	call	_cpct_px2byteM0
   42E1 45            [ 4]  348 	ld	b, l
   42E2 21 00 80      [10]  349 	ld	hl, #0x8000
   42E5 E5            [11]  350 	push	hl
   42E6 C5            [11]  351 	push	bc
   42E7 33            [ 6]  352 	inc	sp
   42E8 2E 00         [ 7]  353 	ld	l, #0x00
   42EA E5            [11]  354 	push	hl
   42EB CD 9C 5C      [17]  355 	call	_cpct_memset
                            356 ;src/game.c:93: coord_x = 0;
   42EE 21 AD 5D      [10]  357 	ld	hl,#_coord_x + 0
   42F1 36 00         [10]  358 	ld	(hl), #0x00
                            359 ;src/game.c:95: while (1) {
   42F3                     360 00107$:
                            361 ;src/game.c:97: if (!swap_memvideo) { 				//switch
   42F3 3A 8E 5E      [13]  362 	ld	a,(#_swap_memvideo + 0)
   42F6 B7            [ 4]  363 	or	a, a
   42F7 20 0D         [12]  364 	jr	NZ,00102$
                            365 ;src/game.c:98: mem_start = (u8*) CPCT_LVMEM_START;		//lower page
   42F9 21 00 80      [10]  366 	ld	hl, #0x8000
   42FC 22 8B 5E      [16]  367 	ld	(_mem_start), hl
                            368 ;src/game.c:99: mem_page = cpct_page80;					//FIXME:: can probably delete??
   42FF 21 8D 5E      [10]  369 	ld	hl,#_mem_page + 0
   4302 36 20         [10]  370 	ld	(hl), #0x20
   4304 18 0B         [12]  371 	jr	00103$
   4306                     372 00102$:
                            373 ;src/game.c:101: mem_start = (u8*) CPCT_VMEM_START;		//upper,regular VMEM page
   4306 21 00 C0      [10]  374 	ld	hl, #0xc000
   4309 22 8B 5E      [16]  375 	ld	(_mem_start), hl
                            376 ;src/game.c:102: mem_page = cpct_pageC0;
   430C 21 8D 5E      [10]  377 	ld	hl,#_mem_page + 0
   430F 36 30         [10]  378 	ld	(hl), #0x30
   4311                     379 00103$:
                            380 ;src/game.c:106: keyboard(); 							//user movement
   4311 CD 86 41      [17]  381 	call	_keyboard
                            382 ;src/game.c:108: moveSprites();
   4314 CD F8 41      [17]  383 	call	_moveSprites
                            384 ;src/game.c:109: deleteSprites();
   4317 CD 3F 59      [17]  385 	call	_deleteSprites
                            386 ;src/game.c:110: renderSprites();
   431A CD 54 58      [17]  387 	call	_renderSprites
                            388 ;src/game.c:113: cpct_waitVSYNC();						//Wait until CRTC has printed a full frame to "repaint"
   431D CD 78 5C      [17]  389 	call	_cpct_waitVSYNC
                            390 ;src/game.c:114: cpct_setVideoMemoryPage(mem_page);		//Tell CRTC to "paint" the new page--FIXME: can this use "mem_start" instead?
   4320 FD 21 8D 5E   [14]  391 	ld	iy, #_mem_page
   4324 FD 6E 00      [19]  392 	ld	l, 0 (iy)
   4327 CD 13 5C      [17]  393 	call	_cpct_setVideoMemoryPage
                            394 ;src/game.c:115: swap_memvideo = ~swap_memvideo; 		//flip the switch
   432A FD 21 8E 5E   [14]  395 	ld	iy, #_swap_memvideo
   432E FD 7E 00      [19]  396 	ld	a, 0 (iy)
   4331 2F            [ 4]  397 	cpl
   4332 FD 77 00      [19]  398 	ld	0 (iy), a
                            399 ;src/game.c:117: cycle++;
   4335 FD 21 8A 5E   [14]  400 	ld	iy, #_cycle
   4339 FD 34 00      [23]  401 	inc	0 (iy)
                            402 ;src/game.c:118: if (cycle == 16)
   433C FD 7E 00      [19]  403 	ld	a, 0 (iy)
   433F D6 10         [ 7]  404 	sub	a, #0x10
   4341 20 B0         [12]  405 	jr	NZ,00107$
                            406 ;src/game.c:119: cycle=0;
   4343 FD 36 00 00   [19]  407 	ld	0 (iy), #0x00
   4347 18 AA         [12]  408 	jr	00107$
                            409 	.area _CODE
                            410 	.area _INITIALIZER
                            411 	.area _CABS (ABS)
